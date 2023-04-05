local mod = get_mod("Classic Sister")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")


-- Ult Talents
local MAX_SIM_STEPS = 10
local MAX_SIM_TIME = 1.5
local COLLISION_FILTER = "filter_geiser_check"
local target_decal_unit_name = "units/decals/decal_thorn_sister_wall_target"
local WALL_OVERLAP_THICKNESS = 0.15
local WALL_OVERLAP_WIDTH = 0.15
local WALL_OVERLAP_HEIGHT = 0.3
local WALL_MAX_HEIGHT_OFFSET = 0.5
local WALL_OVERLAP_HEIGHT_OFFSET = 0.9 + WALL_OVERLAP_HEIGHT
local WALL_SHAPES = table.enum("linear", "radial")
local UNIT_NAMES = {
	default = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01",
	bleed = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_bleed",
	-- poison = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_poison" -- Removed from the game with 4.9
}
local WALL_TYPES = table.enum("default", "bleed")
--local buff_tweak_data = {kerillian_thorn_sister_tanky_wall = {visualizer_extra_duration = 10}}

ActionCareerWEThornsisterTargetWall.client_owner_start_action = function (self, new_action, t, chain_action_data, power_level, action_init_data)
	action_init_data = action_init_data or {}

	ActionCareerWEThornsisterTargetWall.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	self._valid_segment_positions_idx = 0
	self._current_segment_positions_idx = 1

	self._weapon_extension:set_mode(false)

	self._target_sim_gravity = new_action.target_sim_gravity
	self._target_sim_speed = new_action.target_sim_speed
	self._target_width = new_action.target_width
	self._target_thickness = new_action.target_thickness
	self._vertical_rotation = new_action.vertical_rotation
	self._wall_shape = WALL_SHAPES.linear

	if self.talent_extension:has_talent("bloodrazer_thicket_name") then
		self._target_thickness = 3
		self._target_width = 3
		self._wall_shape = WALL_SHAPES.radial
		self._num_segments_to_check = 3
		self._radial_center_offset = 0.5
		self._bot_target_unit = true
	else
		local half_thickness = self._target_thickness / 2
		self._num_segmetns_to_check = math.floor(self._target_width / half_thickness)
		self._bot_target_unit = false
	end

	local max_segments = self._max_segments
	local segment_count = self._num_segments_to_check

	if max_segments < segment_count then
		local segment_positions = self._segment_positions

		for i = max_segments, segment_count, 1 do
			for idx = 1, 2, 1 do
				segment_positions[idx][i + 1] = Vector3Box()
			end
		end

		self._max_segments = segment_count
	end

	self:_update_targeting()
end
-- no change here?
ThornSisterWallExtension.despawn = function (self)
	local owner_unit = self._owner_unit
	local do_explosion = self._is_server and self._is_explosive_wall and not self._chain_kill and ALIVE[owner_unit]	--probably old bloodrazer stuff
	local segment_count = 1
	local average_position = Vector3.zero()
	average_position = average_position + POSITION_LOOKUP[self._unit]
	local all_thorn_walls = Managers.state.entity:get_entities("ThornSisterWallExtension")

	if all_thorn_walls then
		local wall_index = self.wall_index
		local death_system = Managers.state.entity:system("death_system")
		local damage_table = {}

		for unit, extension in pairs(all_thorn_walls) do
			if extension.wall_index == wall_index and extension._owner_unit == owner_unit then
				extension._chain_kill = true

				death_system:kill_unit(unit, damage_table)

				average_position = average_position + POSITION_LOOKUP[unit]
				segment_count = segment_count + 1
			end
		end
	end

	if self._is_server and self._despawn_sound_event and (not self.group_spawn_index or self.group_spawn_index == 1) then
		Managers.state.entity:system("audio_system"):play_audio_position_event(self._despawn_sound_event, average_position / segment_count)
	end

	if do_explosion then
		local explosion_template = "blackvenom_thicket_end_explosion" -- "chaos_drachenfels_strike_missile_impact" --"we_thornsister_career_skill_debuff_wall_explosion"
		local position = average_position / segment_count
		local rotation = self._original_rotation:unbox()
		local scale = 1
		local career_power_level = self._owner_career_power_level
		local area_damage_system = Managers.state.entity:system("area_damage_system")

		area_damage_system:create_explosion(self._owner_unit, position, rotation, explosion_template, scale, "career_ability", career_power_level, false)
	end

	if self._is_server and not self._despawning then
		if self.owner_buff_id then
			local owner_unit = self._owner_unit

			if ALIVE[owner_unit] then
				local owner_buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

				if owner_buff_extension then
					owner_buff_extension:remove_buff(self.owner_buff_id)
				end
			end
		end

		self._area_damage_extension:enable(false)
	end

	Unit.flow_event(self._unit, "despawn")

	self._despawning = true
end
-- unchanged
ActionCareerWEThornsisterTargetWall.init = function (self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCareerWEThornsisterTargetWall.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)

	self._first_person_extension = ScriptUnit.has_extension(owner_unit, "first_person_system")
	self.talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	self._inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	self._weapon_extension = ScriptUnit.extension(weapon_unit, "weapon_system")
	self._decal_unit = nil
	self._unit_spawner = Managers.state.unit_spawner
	self._target_pos = Vector3Box()
	self._target_rot = QuaternionBox()
	self._segment_positions = {
		{
			num_segments = 0
		},
		{
			num_segments = 0
		}
	}
	self._valid_segment_positions_idx = 0
	self._current_segment_positions_idx = 1
	self._num_segments = 0
	self._max_segments = 0
	self._wall_left_offset = 0
	self._wall_right_offset = 0
	self._wall_shape = WALL_SHAPES.linear
end
-- Removed Wide Wall
ActionCareerWEThornsisterTargetWall.client_owner_start_action = function (self, new_action, t, chain_action_data, power_level, action_init_data)
	action_init_data = action_init_data or {}

	ActionCareerWEThornsisterTargetWall.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	self._valid_segment_positions_idx = 0
	self._current_segment_positions_idx = 1

	self._weapon_extension:set_mode(false)

	self._target_sim_gravity = new_action.target_sim_gravity
	self._target_sim_speed = new_action.target_sim_speed
	self._target_width = new_action.target_width
	self._target_thickness = new_action.target_thickness
	self._vertical_rotation = new_action.vertical_rotation
	self._wall_shape = WALL_SHAPES.linear
	if self.talent_extension:has_talent("bloodrazer_thicket_name") then
		self._target_thickness = 3
		self._target_width = 3
		self._wall_shape = WALL_SHAPES.radial
		self._num_segmetns_to_check = 3
		self._radial_center_offset = 0.5
		self._bot_target_unit = true
	else
		local half_thickness = self._target_thickness / 2
		self._num_segmetns_to_check = math.floor(self._target_width / half_thickness)
		self._bot_target_unit = false
	end

	local max_segments = self._max_segments
	local segment_count = self._num_segmetns_to_check

	if max_segments < segment_count then
		local segment_positions = self._segment_positions

		for i = max_segments, segment_count, 1 do
			for idx = 1, 2, 1 do
				segment_positions[idx][i + 1] = Vector3Box()
			end
		end

		self._max_segments = segment_count
	end

	self:_update_targeting()
end
-- unchanged
ActionCareerWEThornsisterTargetWall.client_owner_post_update = function (self, dt, t, world, can_damage, current_time_in_action)
	self:_update_targeting()
end
-- unchanged
ActionCareerWEThornsisterTargetWall._update_targeting = function (self)
	local start_pos, start_rot = self._first_person_extension:get_projectile_start_position_rotation()
	local wall_direction_func = (self._vertical_rotation and Quaternion.right) or Quaternion.forward
	local player_direction_flat = Vector3.flat(wall_direction_func(start_rot))
	local player_rotation_flat = Quaternion.look(player_direction_flat, Vector3.up())
	local velocity = Quaternion.forward(start_rot) * self._target_sim_speed
	local gravity = Vector3(0, 0, self._target_sim_gravity)
	local success, target_pos = nil

	if self.is_bot then
		success = true
		local blackboard = BLACKBOARDS[self.owner_unit]
		local target_unit = blackboard.target_unit

		if self._bot_target_unit and ALIVE[target_unit] then
			target_pos = POSITION_LOOKUP[target_unit]
		else
			target_pos = blackboard.activate_ability_data.aim_position:unbox()
		end
	else
		success, target_pos = WeaponHelper:ballistic_raycast(self.physics_world, MAX_SIM_STEPS, MAX_SIM_TIME, start_pos, velocity, gravity, COLLISION_FILTER)
	end

	if success then
		local valid, right_offset, left_offset = nil

		if self._wall_shape == WALL_SHAPES.radial then
			valid, right_offset, left_offset = self:_check_wall_radial(target_pos, player_rotation_flat, self._target_width, self._target_thickness)
		else
			valid, right_offset, left_offset = self:_check_wall_linear(target_pos, player_rotation_flat, self._target_width, self._target_thickness)
		end

		if valid then
			self._target_pos:store(target_pos)
			self._target_rot:store(player_rotation_flat)

			self._valid_segment_positions_idx = self._current_segment_positions_idx
			self._current_segment_positions_idx = self._current_segment_positions_idx % 2 + 1
			self._wall_right_offset = right_offset
			self._wall_left_offset = left_offset

			self._weapon_extension:set_mode(true)
		end
	end

	if not self._decal_unit and self._valid_segment_positions_idx > 0 and not self.is_bot then
		self._decal_unit = self._unit_spawner:spawn_local_unit(target_decal_unit_name)
	end

	if self._decal_unit then
		local half_thickness = self._target_thickness * 0.5
		local wall_start_offset = self._wall_left_offset * 0.5
		local wall_end_offset = self._wall_right_offset * 0.5
		local wall_target_offset = Quaternion.right(player_rotation_flat) * (wall_end_offset - wall_start_offset) * 0.5
		local target_pos = self._target_pos:unbox() + wall_target_offset
		local target_rot = self._target_rot:unbox()

		Unit.set_local_position(self._decal_unit, 0, target_pos)
		Unit.set_local_rotation(self._decal_unit, 0, target_rot)

		local wall_width_scale = nil

		if self._wall_shape == WALL_SHAPES.radial then
			wall_width_scale = self._target_width * 0.5
		else
			wall_width_scale = self._target_width * 0.5 + half_thickness * (wall_start_offset + wall_end_offset + 1)
		end

		Unit.set_local_scale(self._decal_unit, 0, Vector3(wall_width_scale, half_thickness, 3))
	end
end
-- remove debuff wall, set explosive wall
SpawnUnitTemplates.thornsister_thorn_wall_unit = {
	spawn_func = function (source_unit, position, rotation, state_int, group_spawn_index)
		local UNIT_NAME = UNIT_NAMES[WALL_TYPES.default]
		local UNIT_TEMPLATE_NAME = "thornsister_thorn_wall_unit"
		local wall_index = state_int
		local despawn_sound_event = "career_ability_kerillian_sister_wall_disappear"
		local life_time = 6
		local area_damage_params = {
			radius = 0.3,
			area_damage_template = "we_thornsister_thorn_wall",
			invisible_unit = false,
			nav_tag_volume_layer = "temporary_wall",
			create_nav_tag_volume = true,
			aoe_dot_damage = 0,
			aoe_init_damage = 0,
			damage_source = "career_ability",
			aoe_dot_damage_interval = 0,
			damage_players = false,
			source_unit = source_unit,
			life_time = life_time
		}
		local props_params = {
			life_time = life_time,
			owner_unit = source_unit,
			despawn_sound_event = despawn_sound_event,
			--wall_index = wall_index -- new with 4.6
		}
		local health_params = {
			health = 20
		}
		local buffs_to_add = nil
		local source_talent_extension = ScriptUnit.has_extension(source_unit, "talent_system")

		if source_talent_extension then
			if source_talent_extension:has_talent("ironbark_thicket_name") then
				local life_time_mult = 1 --1
				local life_time_bonus = 4.2 --4.2
				area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
				props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
			elseif source_talent_extension:has_talent("bloodrazer_thicket_name") then
				local life_time_mult = 0.17
				local life_time_bonus = 0
				area_damage_params.create_nav_tag_volume = false
				area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
				props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
				UNIT_NAME = UNIT_NAMES[WALL_TYPES.bleed]
			elseif source_talent_extension:has_talent("blackvenom_thicket_name") then
				UNIT_NAME = UNIT_NAMES[WALL_TYPES.default]
			end
		end

		local extension_init_data = {
			area_damage_system = area_damage_params,
			props_system = props_params,
			health_system = health_params,
			death_system = {
				death_reaction_template = "thorn_wall",
				is_husk = false
			},
			hit_reaction_system = {
				is_husk = false,
				hit_reaction_template = "level_object"
			}
		}
		local wall_unit = Managers.state.unit_spawner:spawn_network_unit(UNIT_NAME, UNIT_TEMPLATE_NAME, extension_init_data, position, rotation)
		local random_rotation = Quaternion(Vector3.up(), math.random() * 2 * math.pi - math.pi)

		Unit.set_local_rotation(wall_unit, 0, random_rotation)

		local buff_extension = ScriptUnit.has_extension(wall_unit, "buff_system")

		if buff_extension and buffs_to_add then
			for i = 1, #buffs_to_add, 1 do
				buff_extension:add_buff(buffs_to_add[i])
			end
		end

		local thorn_wall_extension = ScriptUnit.has_extension(wall_unit, "props_system")

		if thorn_wall_extension then
			thorn_wall_extension.wall_index = wall_index
			thorn_wall_extension.group_spawn_index = group_spawn_index
		end
	end
}
ThornSisterWallExtension.init = function (self, extension_init_context, unit, extension_init_data)
	self._is_server = Managers.state.network.is_server
	self._unit = unit
	self._life_time = extension_init_data.life_time
	self._owner_peer = extension_init_data.owner
	self._owner_unit = extension_init_data.owner_unit
	self._despawn_sound_event = extension_init_data.despawn_sound_event
	self._despawning = false
	self._initialized = false
	self.owner_buff_id = nil
	self.world = extension_init_context.world
	self._area_damage_extension = ScriptUnit.extension(self._unit, "area_damage_system")
	local source_talent_extension = ScriptUnit.has_extension(self._owner_unit, "talent_system")

	if source_talent_extension and source_talent_extension:has_talent("blackvenom_thicket_name") then
		self._is_explosive_wall = true
		local career_extension = ScriptUnit.has_extension(self._owner_unit, "career_system")
		self._owner_career_power_level = (career_extension and career_extension:get_career_power_level()) or 100
	end

	self._original_rotation = QuaternionBox(Unit.local_rotation(unit, 0))
	local side_manager = Managers.state.side
	local side = side_manager:get_side_from_name("heroes")
	local side_id = side.side_id

	side_manager:add_unit_to_side(unit, side_id)
end
-- removed debuff wall, set explosive wall for Bots
BTConditions.can_activate.we_thornsister = function (blackboard)
	local self_unit = blackboard.unit
	local talent_extension = ScriptUnit.has_extension(self_unit, "talent_system")
	local is_smiter_ability = talent_extension and talent_extension:has_talent("bloodrazer_thicket_name") --(4.4)
    --local is_smiter_ability = talent_extension and talent_extension:has_talent("kerillian_thorn_sister_debuff_wall") (4.6)

	if not is_smiter_ability then
		local threat, num_enemies = Managers.state.conflict:get_threat_value()

		if num_enemies < 20 then
			return false
		end
	end

	local self_position = POSITION_LOOKUP[self_unit]
	local target_unit = blackboard.target_unit
	local target_blackboard = BLACKBOARDS[target_unit]
	local wall_target = nil
	local forward_offset = 0

	if target_unit then
		local wall_target_distance_sq = Vector3.distance_squared(self_position, POSITION_LOOKUP[target_unit])

		if wall_target_distance_sq <= wall_max_distance_sq and wall_target_distance_sq >= 4 then
			if is_smiter_ability then
				local target_breed = target_blackboard and target_blackboard.breed
				local target_threat_value = (target_breed and target_breed.threat_value) or 0

				if target_unit == blackboard.priority_target_enemy or target_unit == blackboard.urgent_target_enemy or target_unit == blackboard.opportunity_target_enemy or target_threat_value >= 8 then
					wall_target = target_unit
				end
			else
				local proximite_enemies = blackboard.proximite_enemies
				local num_proximite_enemies = #proximite_enemies

				if num_proximite_enemies >= 10 then
					wall_target = target_unit
					forward_offset = -(math.sqrt(wall_target_distance_sq) / wall_placement_bias)
				end
			end
		end
	end

	if wall_target then
		local wall_target_position = POSITION_LOOKUP[wall_target]
		local wall_target_direction = Vector3.normalize(wall_target_position - self_position)
		local check_position = wall_target_position + wall_target_direction * math.max(forward_offset, 0)
		local nav_world = blackboard.nav_world
		local navigation_extension = target_blackboard and target_blackboard.navigation_extension
		local traverse_logic = navigation_extension and navigation_extension:traverse_logic()
		local success = is_smiter_ability or LocomotionUtils.ray_can_go_on_mesh(nav_world, self_position, check_position, traverse_logic, 1, 1)

		if success then
			local target_pos = wall_target_position + wall_target_direction * forward_offset

			blackboard.activate_ability_data.aim_position:store(target_pos)

			return true
		end
	end

	return false
end
-- replaced new ults with old ones
ActionCareerWEThornsisterWall.client_owner_start_action = function (self, new_action, t, chain_action_data, power_level, action_init_data)
	action_init_data = action_init_data or {}

	ActionCareerWEThornsisterWall.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	local target_data = chain_action_data
	local num_segments = (target_data and target_data.num_segments) or 0

	if num_segments > 0 then
		self:_play_vo()

		local position = target_data.position:unbox()
		local rotation = target_data.rotation:unbox()
		local segments = target_data.segments
		local explosion_template = "base_wall_explosion"
		local scale = 1
		local career_extension = self.career_extension
		local career_power_level = career_extension:get_career_power_level()
		local area_damage_system = Managers.state.entity:system("area_damage_system")

		if self.talent_extension:has_talent("bloodrazer_thicket_name") then
			explosion_template = "bloodrazer_thicket_explosion"
		elseif self.talent_extension:has_talent("blackvenom_thicket_name") then
			explosion_template = "blackvenom_thicket_explosion"
		end

        --with 4.6 they added the other 2 ults in here
		self:_spawn_wall(num_segments, segments, rotation)

		area_damage_system:create_explosion(self.owner_unit, position, rotation, explosion_template, scale, "career_ability", career_power_level, false)
		career_extension:start_activated_ability_cooldown()
	end
end
-- small change (idk what it changes)
--[[
ActionCareerWEThornsisterWall._spawn_wall = function (self, num_segments, segments, wall_rotation)
	--local wall_index = self:_get_next_wall_index() --(4.6)
	local wall_index = self._wall_index + 1
	self._wall_index = wall_index
	local owner_unit = self.owner_unit
	local forward = Quaternion.forward(wall_rotation)
	local right = Quaternion.right(wall_rotation)
	local WALL_FORWARD_OFFSET_RANGE_NEW = WALL_FORWARD_OFFSET_RANGE

	for i = 1, num_segments, 1 do
		local position = segments[i]:unbox()
		local rotation = wall_rotation
		local spawn_position = position + forward * (math.random() * WALL_FORWARD_OFFSET_RANGE_NEW * 2 - WALL_FORWARD_OFFSET_RANGE_NEW) + right * (math.random() * WALL_FORWARD_OFFSET_RANGE_NEW * 2 - WALL_FORWARD_OFFSET_RANGE_NEW)

		Managers.state.unit_spawner:request_spawn_network_unit(UNIT_TEMPLATE_NAME, spawn_position, rotation, owner_unit, wall_index, i)
	end
end
]]



-- ExplosionTemplates
mod.add_explosion_template("wood_elf", "base_wall_explosion",{
	--we_thornsister_career_skill_wall_explosion
	explosion = {
		use_attacker_power_level = true,
		radius = 3.5,
		no_friendly_fire = true,
		hit_sound_event = "thorn_wall_damage_light",
		sound_event_name = "career_ability_kerillian_sister_wall_spawn",
		alert_enemies = true,
		alert_enemies_radius = 10,
		hit_sound_event_cap = 1,
		damage_type = "kinetic",
		damage_profile = "base_thorn_wall_explosion",
		explosion_forward_scaling = 0.2
	}
})
mod.add_explosion_template("wood_elf", "bloodrazer_thicket_explosion",{
	--we_thornsister_career_skill_explosive_wall_explosion
	explosion = {
		use_attacker_power_level = true,
		radius = 3.4,
		explosion_right_scaling = 0.5,
		hit_sound_event = "thorn_wall_damage_heavy",
		dot_template_name = "thorn_sister_bloodrazer_bleed",
		effect_name = "fx/thornwall_spike_damage",
		sound_event_name = "career_ability_kerilian_sister_wall_spawn_damage",
		hit_sound_event_cap = 1,
		alert_enemies = true,
		no_friendly_fire = true,
		alert_enemies_radius = 10,
		damage_type = "kinetic",
		damage_profile = "bloodrazer_thorn_wall_explosion_improved_damage",
		explosion_forward_scaling = 0.5
	}
})

-- Bloodrazer Bleed
BuffTemplates.thorn_sister_bloodrazer_bleed = {
	--thorn_sister_wall_bleed
	buffs = {
		{
			damage_profile = "bleed",
			name = "thorn_sister_bloodrazer_bleed",
			duration = 10,
			refresh_durations = true,
			apply_buff_func = "start_dot_damage",
			time_between_dot_damages = 0.25,
			hit_zone = "neck",
			max_stacks = 1,
			update_func = "apply_dot_damage",
			perk = buff_perks.bleeding
		}
	}
}
local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "thorn_sister_bloodrazer_bleed"
NetworkLookup.buff_templates["thorn_sister_bloodrazer_bleed"] = index

local index = #NetworkLookup.dot_type_lookup + 1
NetworkLookup.dot_type_lookup[index] = "thorn_sister_bloodrazer_bleed"
NetworkLookup.dot_type_lookup["thorn_sister_bloodrazer_bleed"] = index
DotTypeLookup.thorn_sister_bloodrazer_bleed = "poison_dot"

mod.add_explosion_template("wood_elf", "blackvenom_thicket_explosion", {
	--we_thornsister_career_skill_debuff_wall_spawn_explosion
	explosion = {
		use_attacker_power_level = true,
		radius = 3.5,
		damage_type = "kinetic",
		hit_sound_event = "thorn_wall_damage_light",
		alert_enemies = true,
		alert_enemies_radius = 10,
		hit_sound_event_cap = 1,
		sound_event_name = "career_ability_kerilian_sister_wall_spawn_poison",
		damage_profile = "base_thorn_wall_explosion",
		explosion_forward_scaling = 0.2
	}
})
mod.add_explosion_template("wood_elf", "blackvenom_thicket_end_explosion",{
	--we_thornsister_career_skill_debuff_wall_explosion
	explosion = {
		use_attacker_power_level = true,
		radius = 8,
		damage_type = "kinetic",
		hit_sound_event = "thorn_hit_poison",
		effect_name = "fx/thornwall_poison_spikes",
		no_friendly_fire = true,
		no_prop_damage = true,
		hit_sound_event_cap = 3,
		always_hurt_players = false,
		alert_enemies = true,
		sound_event_name = "career_ability_kerillian_sister_wall_poison_disappear",
		damage_profile = "ability_push", -- overall damage_profile no changes since release
		alert_enemies_radius = 10,
		ignore_attacker_unit = true,
		explosion_forward_scaling = 0.7,
		enemy_debuff = {
			"kerillian_thorn_sister_debuff_wall_buff"
		}
	}
})

-- Wall debuff (talent buff template doesnt work) using OG (same)
--[[
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_sister_blackvenom_thicket", {
	--kerillian_thorn_sister_debuff_wall_buff
	buffs = {
		{
			start_flow_event = "poisoned",
			name = "kerillian_thorn_sister_blackvenom_thicket",
			stat_buff = "damage_taken",
			death_flow_event = "poisoned_death",
			refresh_durations = true,
			end_flow_event = "poisoned_end",
			update_start_delay = 1,
			apply_buff_func = "start_dot_damage",
			time_between_dot_damages = 1,
			max_stacks = 1,
			multiplier = 0,2,
			duration = 10,
			radius = 3
		}
	}
}
)
]]


-- Damage Profiles
DamageProfileTemplates.base_thorn_wall_explosion = {
	--thorn_wall_explosion
	is_explosion = true,
	charge_value = "ability",
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0.5,
			1,
			1,
			0.25
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.25
		}
	},
	cleave_distribution = {
		attack = 0.2,
		impact = 1
	},
	default_target = {
		damage_type = "grenade",
		attack_template = "blade_storm",
		power_distribution = {
		attack = 0.2,
		impact = 1
		}
	},
	targets = {}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "base_thorn_wall_explosion"
NetworkLookup.damage_profiles["base_thorn_wall_explosion"] = index

DamageProfileTemplates.bloodrazer_thorn_wall_explosion_improved_damage = {
	--thorn_wall_explosion_improved_damage
	is_explosion = true,
	charge_value = "ability",
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			1,
			2.5,
			1,
			0.75,
			1.1
		},
		impact = {
			1,
			1,
			100,
			1,
			1,
			10
		}
	},
	cleave_distribution = {
		attack = 1,
		impact = 1
	},
	default_target = {
		damage_type = "grenade",
		attack_template = "blade_storm",
		power_distribution = {
			attack = 1,
			impact = 2
		}
	},
	targets = {}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "bloodrazer_thorn_wall_explosion_improved_damage"
NetworkLookup.damage_profiles["bloodrazer_thorn_wall_explosion_improved_damage"] = index




-- Change Ult Talents

-- Ironbark Thicket small (works)
mod:add_talent("we_thornsister", 6, 1, "ironbark_thicket_name", {
	name = "ironbark_thicket_name",
	--kerillian_thorn_sister_tanky_wall
	description = "ironbark_thicket_desc",
    buffer = "server",
	num_ranks = 1,
	icon = "kerillian_thornsister_healing_wall",
	buffs = {}
})
mod:add_text("ironbark_thicket_name", "Ironbark Thicket")
mod:add_text("ironbark_thicket_desc", "Increase the duration of the Thorn Wall to 10 seconds.")

-- Bloodrazer Thicket instead of Tangelgrasp Thicket (works)
mod:add_talent("we_thornsister", 6, 2, "bloodrazer_thicket_name", {
	name = "bloodrazer_thicket_name",
	--kerillian_thorn_sister_explosive_wall
	description = "bloodrazer_thicket_desc",
    buffer = "server",
	num_ranks = 1,
	icon = "kerillian_thornsister_explosive_wall",
	buffs = {} 
})
mod:add_text("bloodrazer_thicket_name", "Bloodrazer Thicket")
mod:add_text("bloodrazer_thicket_desc", "Increases the Thorn Wall's eruption damage and makes it apply Bleed, but lower both size and duration.")

-- Blackvenom Thicket (wall instead of euroption) (works)
mod:add_talent("we_thornsister", 6, 3, "blackvenom_thicket_name", {
	name = "blackvenom_thicket_name",
	--kerillian_thorn_sister_debuff_wall
	description = "blackvenom_thicket_desc",
    buffer = "server",
	num_ranks = 1,
	icon = "kerillian_thornsister_debuff_wall",
	buffs = {}
})
mod:add_text("blackvenom_thicket_name", "Blackvenom Thicket")
mod:add_text("blackvenom_thicket_desc", "When the Thorn Wall espires, poisonous thorns explode outwards, causing nearby enemies to take 20%% increased damage for 10 seconds.")

