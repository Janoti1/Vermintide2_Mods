local mod = get_mod("Geheimnisnacht for all")

-- Created by Janoti 2022-10-30
-- Thanks to the former Author Craven for the mod from last year and his Code
-- Thanks to Actual Trash and Johnny for helping me deciding positions and testing the mod


-- load Geheimnisnacht as Global (Not possible to load as local as the gamemode differs)
local package_name = "resource_packages/dlcs/geheimnisnacht_2021_event"
local package_name_skulls = "resource_packages/dlcs/skulls_2023_event"
local async = true
local prioritize = false
Managers.package:load(package_name, "global", nil, async, prioritize)
Managers.package:load(package_name_skulls, "global", nil, async, prioritize)

-- spawns with the ring technically adjustable no need tho
--[[
local spawn_lists = {
	skaven = {
		"skaven_plague_monk",
		"skaven_clan_rat",
		"skaven_plague_monk",
		"skaven_clan_rat",
		"skaven_plague_monk",
		"skaven_clan_rat"
	},
	chaos = {
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder"
	}
}
local spawn_categories = table.keys(spawn_lists)
]]

-- locations
local event_settings = {
	--test
	whitebox = { -- default spawn check
		ritual_locations = {
			{
				0,
				0,
				0,
				0
			}
		}
	},
	prologue = { --prologue
	ritual_locations = {
			{
				53.97,
				-29.81,
				-13.92,
				0
			}
		}
	},
	--helmgart
	military = { -- Rightous Stand
	ritual_locations = {
			{
				91,
				147,
				-19.5,
				90
			}
		}
	},
	catacombs = { --convocation of decay
		ritual_locations = {
			{
				178.8,
				109,
				32,
				50
			}
		}
	},
	mines = { -- Hunger in the Dark
		ritual_locations = {
			{
				-76.08,
				130,
				22.75,
				5
			}
		}
	},
	ground_zero = { -- halescourge
		ritual_locations = {
			{
				-171.5,
				102.7,
				42.094002,
				20
			}
		}
	},
	elven_ruins = { --athel yenlui
		ritual_locations = {
			{
				37.891605,
				-109,
				19.562,
				0
			}
		}
	},
	bell = { -- screaming bell
	ritual_locations = {
			{
				-62.059746,
				-178.81282,
				-34.657001,
				0
			}
		}
	},
	fort = { -- fort brachsenbrücke
	ritual_locations = {
			{
				52.39,
				306.66,
				-21.86,
				0
			}
		}
	},
	skaven_stronghold = { --into the nest
	ritual_locations = {
			{
				-85.65,
				-20.70,
				57.04,
				0
			}
		}
	},
	skittergate = { --skittergate
	ritual_locations = {
			{
				-216.85,
				-446.45,
				-67.74,
				0
			}
		}
	},
	farmlands = { --against the grain
		ritual_locations = {
			{
				223.965363,
				-253.689133,
				7.712,
				0
			}
		}
	},
	ussingen = { -- Empire in Flames
	ritual_locations = {
			{
				-4.573383,
				-160.917343,
				1.135474,
				0
			}
		}
	},
    nurgle = { -- festering ground (fs coorfinates)
		ritual_locations = {
			{
				175.1,
				-114.5,
				2.5,
				0
			}
		}
	},
    warcamp = { --warcamp (fs coorfinates)
		ritual_locations = {
			{
				-151.1,
				-20,
				19.15,
				0
			}
		}
	},
	--V1
    cemetery = { --garden of morr
		ritual_locations = {
			{
				23.04,
				-72.83,
				9.83,
				0
			}
		}
	},
    forest_ambush = { --Engines of War
		ritual_locations = {
			{
				32.61,
				-84.91,
				-3.37,
				0
			}
		}
	},
	magnus = { --horn of magnus
	ritual_locations = {
			{
				-185.71,
				77.74,
				4.79,
				0
			}
		}
	},
	plaza = { --FOW
	ritual_locations = {
			{
				51.48,
				28.90,
				3,06,
				0
			}
		}
	},
	--bogenhafen
	dlc_bogenhafen_city = { --blightreaper
		ritual_locations = {
			{
				59.76,
				78.29,
				-2.56,
				0
			}
		}
	},
    dlc_bogenhafen_slum = { --the pit
		ritual_locations = {
			{
				-125.07,
				-222.29,
				-2.64,
				0
			}
		}
	},
	--lair
    dlc_bastion = { --blood in darkness
    ritual_locations = {
            {
				109.6,
				56.7,
				-52.8,
				0
            }
        }
    },
    dlc_castle = { --Enchanters lair (fs coorfinates)
    ritual_locations = {
            {
				5.584873,
				65.619408,
				0,
				-40
            }
        }
    },
    dlc_portals = { --old haunts
    ritual_locations = {
            {
				-178.758,
				224.85,
				-45.733,
				0
            }
        }
    },
	--cata
    crater = { --dark omens
    ritual_locations = {
			{
				115.57,
				-443.43,
				29.3,
				0
			}
		}
	},
	--Trail
	dlc_wizards_trail = { --trails of treachery
		ritual_locations = {
			{
				190.79,
				-14.60,
				407.12,
				0
			}
		}
	},
	dlc_wizards_tower = { --tower of treachery (fs coorfinates)
		ritual_locations = {
			{
				4.45,
				36.4,
				77.01,
				0
			}
		}
	},
	--Karak
	dlc_dwarf_interior = { --mercy
		ritual_locations = {
			{
				85.077263,
				37.885601,
				17.038277,
				0
			} 
		}
	},
	dlc_dwarf_exterior = { --grudge
		ritual_locations = {
			{
				-206.591476,
				-128.560135,
				-5.001165,
				0
			}
		}
	},
	dlc_dwarf_beacons = { --kaizaki (fs coorfinates)
		ritual_locations = {
			{
				-128.2,
				-102.8,
				-15.3,
				0
			}
		}
	 },
	--bonus
	dlc_celebrate_crawl = { --a quiet drink
		ritual_locations = {
			{
				-38.53,
				-160.55,
				-25.39,
				0
			}
		}
	},
}

local hard_mode_mutators = {
	"geheimnisnacht_2021_hard_mode"
}
local function side_objective_picked_up()
	-- print warning message to team
	-- local pop_chat = true
	-- local message = Localize("system_chat_geheimnisnacht_2021_hard_mode_on")
	-- Managers.chat:add_local_system_message(1, message, pop_chat)

	-- add mutator
	local mutator_handler = Managers.state.game_mode._mutator_handler
	mutator_handler:initialize_mutators(hard_mode_mutators)

	for i = 1, #hard_mode_mutators, 1 do
		mutator_handler:activate_mutator(hard_mode_mutators[i])
	end
end
local function side_objective_picked_dropped()
	-- print loss message to team
	-- local pop_chat = true
	-- local message = Localize("system_chat_geheimnisnacht_2021_hard_mode_off")
	-- Managers.chat:add_local_system_message(1, message, pop_chat)

	-- remove mutator
	local mutator_handler = Managers.state.game_mode._mutator_handler
	for i = 1, #hard_mode_mutators, 1 do
		local mutator_name = hard_mode_mutators[i]
		local mutator_active = mutator_handler:has_activated_mutator(mutator_name)

		if mutator_active then
			mutator_handler:deactivate_mutator(mutator_name)
		end
	end
end

-- looks like all returns of various mutator files end up in this one global called MutatorTemplates
MutatorTemplates["geheimnisnacht_2021"]["server_start_function"] = function(context, data)
    	local level_key = Managers.state.game_mode:level_key()
		local settings = event_settings[level_key]

		if settings then
			local ritual_locations = settings.ritual_locations
			local up = Vector3.up()

			for i = 1, #ritual_locations, 1 do
				local location = ritual_locations[i]
				local pos = Vector3(location[1], location[2], location[3])
				local rot = Quaternion.axis_angle(up, math.rad(location[4]))

				data.template.spawn_ritual_ring(pos, rot)
			end

			local inventory_system = Managers.state.entity:system("inventory_system")

			inventory_system:register_event_objective("wpn_geheimnisnacht_2021_side_objective", side_objective_picked_up, side_objective_picked_dropped)
		else 
		local level_key = Managers.state.game_mode:level_key()
		if string.find(level_key, "inn_level") or string.find(level_key, "morris_hub") then 
			return
		end

      local loaded = PackageManager:has_loaded("resource_packages/dlcs/geheimnisnacht_2021_event", geheimnisnacht_2021)
      if not loaded then
        mod:echo("[Geheimnisnacht+]: Loading package: %s", resource_packages/dlcs/geheimnisnacht_2021_event)
      end

    local inventory_system = Managers.state.entity:system("inventory_system")
	inventory_system:register_event_objective("wpn_geheimnisnacht_2021_side_objective", side_objective_picked_up, side_objective_picked_dropped)

    end
end




-- Mutator 2021 and 2022

-- https://www.reddit.com/r/Vermintide/comments/qhy3ys/quick_fyi_about_geheimnisnacht_events_buff_on/
-- 125% more health (225% in total)
-- deal 25% more damage (125% in total)
-- have 90% more mass
-- stagger resistance increase by 10%

local function geheimnisnacht_2021()
	-- Instant Spawn of Chaos warrior when breaking the Ritual remove
	GenericTerrorEvents.geheimnisnacht_2021_event = {
		{
			"set_master_event_running",
			name = "geheimnisnacht_2021_event"
		},
		{
			"one_of",
			{
				{
					"inject_event",
					event_name_list = {
						"geheimnisnacht_2021_event_faction_skaven"
					},
					faction_requirement_list = {
						"skaven"
					}
				},
				{
					"inject_event",
					event_name_list = {
						"geheimnisnacht_2021_event_faction_chaos"
					},
					faction_requirement_list = {
						"chaos"
					}
				},
				{
					"inject_event",
					event_name_list = {
						"geheimnisnacht_2021_event_faction_beastmen"
					},
					faction_requirement_list = {
						"beastmen"
					}
				}
			}
		}
	}
	-- chance to get a chaos warrior with a grudge mark removed
	MutatorTemplates["geheimnisnacht_2021_hard_mode"]["possible_grudge_marks"] = {}
	MutatorTemplates["geheimnisnacht_2021_hard_mode"]["post_ai_spawned_function"] = function (mutator_context, mutator_data, breed, optional_data)
		-- local breed_name = breed.name
		-- local grudge_data = mod.possible_grudge_marks [breed_name]
		-- if grudge_data then
		-- 	local state_by_breed = mutator_data.grudge_mark_state_by_breed or { }
		-- 	mutator_data.grudge_mark_state_by_breed = state_by_breed
	
		-- 	local success = nil
		-- 	local chance = optional_data.spawn_chance or grudge_data.chance
		-- 	local breed_state = state_by_breed [breed_name]
		-- 	success, breed_state = PseudoRandomDistribution.flip_coin(breed_state, chance)
		-- 	state_by_breed [breed_name] = breed_state
	
		-- 	if success then
		-- 		local names = grudge_data.names
		-- 		local grudge_mark_name = names [math.random(1, #names)]
	
		-- 		local list = optional_data.enhancements or { }
		-- 		local base_grudgemark_name = grudge_data.base_grudgemark_name
		-- 		if base_grudgemark_name then
		-- 			list [#list + 1] = BreedEnhancements [base_grudgemark_name]
		-- 		end
		-- 		list [#list + 1] = BreedEnhancements [grudge_mark_name]
	
		-- 		optional_data.enhancements = list
		-- 	end
		-- end
	end
end




-- Mutator 2023 (added cw with grudge mark)

-- https://www.reddit.com/r/Vermintide/comments/17h0l0l/quick_fyi_about_2023_geheimnisnacht_events_buff/
-- The Chosen of Blosphoros Chaos Warrior is a guaranteed spawn after disrupting the ritual.
-- And when you carrying the skull, there is a 15% chance any Chaos Warrior spawned as one.
-- They have 425% health, dealing 45% more damage(145% in total) and its knockback distance is reduced by 70%.
-- If they carry Replusive grudge mark, all their attacks will send small enemies and player flying within 4.5 units.
-- If they carry Nurgle's Rotten Resilience as grudge mark, all other enemy units within 4 units cannot be killed.

local function geheimnisnacht_2023()
	-- chaos warrior spawn when destroying the ritual
	local function setup_altar_chaos_warrior(optional_data, difficulty, breed_name, event, difficulty_tweak, enhancement_list)
		local names = {
			"shockwave",
			"ignore_death_aura"
		}
		local base_grudgemark_name = "elite_base"
		local grudge_mark_name = names [math.random(1, #names)]
		local list = optional_data.enhancements or { }
		list [#list + 1] = BreedEnhancements [base_grudgemark_name]
		list [#list + 1] = BreedEnhancements [grudge_mark_name]

		optional_data.enhancements = list
		return optional_data
	end
	local function size_chaos_warrior(breed, extension_init_data, optional_data, spawn_pos, spawn_rot)
		return
	end
	GenericTerrorEvents.geheimnisnacht_2021_event = {
		{
			"set_master_event_running",
			name = "geheimnisnacht_2021_event"
		},
		{
			"spawn",
			{
				1,
				1
			},
			breed_name = "chaos_warrior",
			pre_spawn_func = setup_altar_chaos_warrior,
			optional_data = {
				spawn_chance = 1,
				spawned_func = AiUtils.magic_entrance_optional_spawned_func,
				prepare_func = size_chaos_warrior
			}
		},
		{
			"one_of",
			{
				{
					"inject_event",
					event_name_list = {
						"geheimnisnacht_2021_event_faction_skaven"
					},
					faction_requirement_list = { 
						"skaven"
					}
				},
				{
					"inject_event",
					event_name_list = {
						"geheimnisnacht_2021_event_faction_chaos"
					},
					faction_requirement_list = {
						"chaos"
					}
				},
				{
					"inject_event",
					event_name_list = {
						"geheimnisnacht_2021_event_faction_beastmen"
					},
					faction_requirement_list = {
						"beastmen"
					}
				}
			}
		}
	}

	-- chance to get a chaos warrior with a grudge mark added
	mod.possible_grudge_marks = {
		chaos_warrior = {
			chance = 0.15,
			base_grudgemark_name = "elite_base",
			names = {
				"shockwave",
				"ignore_death_aura"
			}
		}
	}
	MutatorTemplates["geheimnisnacht_2021_hard_mode"]["post_ai_spawned_function"] = function (mutator_context, mutator_data, breed, optional_data)
		local breed_name = breed.name
		local grudge_data = mod.possible_grudge_marks [breed_name]
		if grudge_data then
			local state_by_breed = mutator_data.grudge_mark_state_by_breed or { }
			mutator_data.grudge_mark_state_by_breed = state_by_breed
	
			local success = nil
			local chance = optional_data.spawn_chance or grudge_data.chance
			local breed_state = state_by_breed [breed_name]
			success, breed_state = PseudoRandomDistribution.flip_coin(breed_state, chance)
			state_by_breed [breed_name] = breed_state
	
			if success then
				local names = grudge_data.names
				local grudge_mark_name = names [math.random(1, #names)]
	
				local list = optional_data.enhancements or { }
				local base_grudgemark_name = grudge_data.base_grudgemark_name
				if base_grudgemark_name then
					list [#list + 1] = BreedEnhancements [base_grudgemark_name]
				end
				list [#list + 1] = BreedEnhancements [grudge_mark_name]
	
				optional_data.enhancements = list
			end
		end
	end
end




-- Change Eye Color of Enemies

-- create mutator for it
mod.initiate_mutator = function ()

	-- create buff containing just the eye color change
	local function merge(dst, src)
		for k, v in pairs(src) do
			dst[k] = v
		end
		return dst
	end
	function mod.add_buff_template(self, buff_name, buff_data, extra_data)
		local new_buff = {
			buffs = {
				merge({ name = buff_name }, buff_data),
			},
		}
		if extra_data then
			new_buff = merge(new_buff, extra_data)
		end
		BuffTemplates[buff_name] = new_buff
		local index = #NetworkLookup.buff_templates + 1
		NetworkLookup.buff_templates[index] = buff_name
		NetworkLookup.buff_templates[buff_name] = index
	end
	mod:add_buff_template("geheimnisnacht_eye_glow", {
		remove_buff_func = "geheimnisnacht_2021_remove_eye_glow",
		name = "geheimnisnacht_eye_glow",
		apply_buff_func = "geheimnisnacht_2021_apply_eye_glow"
	})

	-- bufffunctiontemplates for eyes also in the game/ in case it gets removed comment in
	--[[
	BuffFunctionTemplates.functions.geheimnisnacht_2021_apply_eye_glow = function (unit, buff, params)
		local buff_ext = ScriptUnit.has_extension(unit, "buff_system")
		if not ALIVE [unit] then return
		end
		if not buff_ext.reset_material_cache then
			buff_ext.reset_material_cache = Unit.get_material_resource_id(unit, "mtr_eyes")
		end

		Unit.set_material(unit, "mtr_eyes", "units/beings/enemies/mtr_eyes_geheimnisnacht")
	end
	BuffFunctionTemplates.functions.geheimnisnacht_2021_remove_eye_glow = function (unit, buff, params)
		local buff_ext = ScriptUnit.has_extension(unit, "buff_system")
		if not ALIVE [unit] or not buff_ext.reset_material_cache then return
		end
		Unit.set_material_from_id(unit, "mtr_eyes", buff_ext.reset_material_cache)
	end
	]]


	local function modify_breed_health_start(context, data)
		local template = data.template
		local modify_health_breeds = template.modify_health_breeds
		if modify_health_breeds then
			local health_modifier = template.health_modifier
			local vanilla_breed_health = { }
			for _, breed_name in ipairs(modify_health_breeds) do
				local breed = Breeds [breed_name]
				local max_health = breed.max_health
				vanilla_breed_health [breed_name] = table.clone(max_health)

				for i, health in ipairs(max_health) do
					max_health [i] = health * health_modifier
				end
			end
			data.vanilla_breed_health = vanilla_breed_health
		end
	end
	local function modify_breed_health_stop(context, data)
		if data.vanilla_breed_health then
			for breed_name, max_health in pairs(data.vanilla_breed_health) do
				Breeds [breed_name].max_health = max_health
			end
		end
	
	end
	local function modify_breed_armor_category_start(context, data)
		local template = data.template
		local modify_primary_armor_category_breeds = template.modify_primary_armor_category_breeds
		if modify_primary_armor_category_breeds then
			local primary_armor_category = template.primary_armor_category
			local vanilla_breed_primary_armor_category = { }
			for _, breed_name in ipairs(modify_primary_armor_category_breeds) do
				local breed = Breeds [breed_name]
				local old_primary_armor_category = breed.primary_armor_category
	
				if old_primary_armor_category then
					vanilla_breed_primary_armor_category [breed_name] = old_primary_armor_category
				else
					vanilla_breed_primary_armor_category [breed_name] = false
				end
	
				breed.primary_armor_category = primary_armor_category
			end
			if not data.vanilla_breed_primary_armor_category then
				data.vanilla_breed_primary_armor_category = vanilla_breed_primary_armor_category
			end
		end
	end
	local function modify_breed_armor_category_stop(context, data)
		if data.vanilla_breed_primary_armor_category then
			for breed_name, primary_armor_category in pairs(data.vanilla_breed_primary_armor_category) do
				if primary_armor_category then
					Breeds [breed_name].primary_armor_category = primary_armor_category
				else
					Breeds [breed_name].primary_armor_category = nil
				end
			end
		end
	end
	local function modify_breed_primary_armor_category_start(context, data)
		local template = data.template
		local modify_armor_category_breeds = template.modify_armor_category_breeds
		if modify_armor_category_breeds then
			local armor_category = template.armor_category
			local vanilla_breed_armor_category = { }
			for _, breed_name in ipairs(modify_armor_category_breeds) do
				local breed = Breeds [breed_name]
				local old_armor_category = breed.armor_category
	
				if old_armor_category then
					vanilla_breed_armor_category [breed_name] = old_armor_category
					breed.armor_category = armor_category
				end
			end
			if not data.vanilla_breed_armor_category then
				data.vanilla_breed_armor_category = vanilla_breed_armor_category
			end
		end
	end
	local function modify_breed_primary_armor_category_stop(context, data)
		if data.vanilla_breed_armor_category then
			for breed_name, armor_category in pairs(data.vanilla_breed_armor_category) do
				Breeds [breed_name].armor_category = armor_category
			end
		end
	end
	local function default_start_function_server(context, data)
		local template = data.template
		local remove_pickup_settings = template.remove_pickups
		if remove_pickup_settings then
			local pickup_types = { }
			for i = 1, #remove_pickup_settings do
				local pickup_type = remove_pickup_settings [i]
				pickup_types [pickup_type] = true
			end
			local excluded_pickup_item_names = template.excluded_pickup_item_names
			local pickup_units = Managers.state.entity:get_entities("PickupUnitExtension")
			for unit, extension in pairs(pickup_units) do
				local pickup_settings = extension:get_pickup_settings()
				local is_excluded = excluded_pickup_item_names and excluded_pickup_item_names [pickup_settings.item_name]
				if not is_excluded and pickup_types.all or pickup_types [pickup_settings.type] then
	
					Managers.state.unit_spawner:mark_for_deletion(unit)
				end
			end
		end
	end
	local function default_stop_function_server(context, data)
		modify_breed_health_stop(context, data)
		modify_breed_armor_category_stop(context, data)
		modify_breed_primary_armor_category_stop(context, data)
	end
	local function default_hot_join_sync_function_server(context, data, peer_id)
		return
	end
	local function default_player_disabled_function_server(context, data, killed_unit, killer_unit, death_data, killing_blow)
		return
	end
	local function default_ai_killed_function_server(context, data, killed_unit, killer_unit, death_data, killing_blow)
		return
	end
	local function default_level_object_killed_function_server(context, data, killed_unit, killing_blow)
		return
	end
	local function default_ai_hit_by_player_function_server(context, data, hit_unit, attacking_unit, attack_data)
		return
	end
	local function default_player_hit_function_server(context, data, hit_unit, attacking_unit, attack_data)
		return
	end
	local function default_player_respawned_function_server(context, data, spawned_unit)
		return
	end
	local function default_damage_taken_function_server(context, data, attacked_unit, attacker_unit, damage, damage_source, damage_type)
		return
	end
	local function default_ai_spawned_function_server(context, data, spawned_unit)
		return
	end
	local function default_pre_ai_spawned_function(context, data, breed, optional_data)
		return
	end
	local function default_post_ai_spawned_function(context, data, ai_unit, breed, optional_data)
		return
	end
	local function default_start_function_client(context, data)
		modify_breed_armor_category_start(context, data)
		modify_breed_primary_armor_category_start(context, data)
	end
	local function default_stop_function_client(context, data)
		modify_breed_armor_category_stop(context, data)
		modify_breed_primary_armor_category_stop(context, data)
	end
	local function default_hot_join_sync_function_client(context, data, peer_id)
		return
	end
	local function default_ai_killed_function_client(context, data, killed_unit, killer_unit, death_data, killing_blow)
		return
	end
	local function default_level_object_killed_function_client(context, data, killed_unit, killing_blow)
		return
	end
	local function default_ai_hit_by_player_function_client(context, data, hit_unit, attacking_unit, attack_data)
		return
	end
	local function default_player_hit_function_client(context, data, hit_unit, attacking_unit, attack_data)
		return
	end
	local function default_player_respawned_function_client(context, data, spawned_unit)
		return
	end
	local function default_damage_taken_function_client(context, data, attacked_unit, attacker_unit, damage, damage_source, damage_type)
		return
	end
	local function default_ai_spawned_function_client(context, data, spawned_unit)
		return
	end
	local function default_server_players_left_safe_zone(context, data)
		return
	end
	local function default_initialize_function_server(context, data)
		modify_breed_health_start(context, data)
		modify_breed_armor_category_start(context, data)
		modify_breed_primary_armor_category_start(context, data)
	end
	local function create_mutator(mutator_template, mutator_name)
		mutator_template.name = mutator_name
		mutator_template.server = { }
		mutator_template.client = { }

		if mutator_template.check_dependencies then
			local all_good = mutator_template.check_dependencies()
			fassert(all_good, "Mutator (%s) failed dependency check! :(", mutator_name)
		end

		if mutator_template.server_initialize_function then
			local function initialize_function(context, data)
				default_initialize_function_server(context, data)
				mutator_template.server_initialize_function(context, data)
			end
			mutator_template.server.initialize_function = initialize_function
		else
			mutator_template.server.initialize_function = default_initialize_function_server
		end

		if mutator_template.server_start_function then
			local function start_function(context, data)
				default_start_function_server(context, data)
				mutator_template.server_start_function(context, data)
			end
			mutator_template.server.start_function = start_function
		else
			mutator_template.server.start_function = default_start_function_server
		end

		if mutator_template.server_stop_function then
			local function stop_function(context, data, is_destroy)
				default_stop_function_server(context, data)
				mutator_template.server_stop_function(context, data, is_destroy)
			end
			mutator_template.server.stop_function = stop_function
		else
			mutator_template.server.stop_function = default_stop_function_server
		end

		if mutator_template.server_hot_join_sync then
			local function hot_join_sync_function(context, data, peer_id)
				default_hot_join_sync_function_server(context, data, peer_id)
				mutator_template.server_hot_join_sync(context, data, peer_id)
			end
			mutator_template.server.hot_join_sync_function = hot_join_sync_function
		else
			mutator_template.server.hot_join_sync_function = default_hot_join_sync_function_server
		end

		if mutator_template.server_player_disabled_function then
			local function player_disabled_function(context, data, disabling_event, target_unit, attacker_unit)
				default_player_disabled_function_server(context, data, disabling_event, target_unit, attacker_unit)
				mutator_template.server_player_disabled_function(context, data, disabling_event, target_unit, attacker_unit)
			end
			mutator_template.server.player_disabled_function = player_disabled_function
		else
			mutator_template.server.player_disabled_function = default_player_disabled_function_server
		end

		if mutator_template.server_ai_killed_function then
			local function ai_killed_function(context, data, killed_unit, killer_unit, death_data, killing_blow)
				default_ai_killed_function_server(context, data, killed_unit, killer_unit, death_data, killing_blow)
				mutator_template.server_ai_killed_function(context, data, killed_unit, killer_unit, death_data, killing_blow)
			end
			mutator_template.server.ai_killed_function = ai_killed_function
		else
			mutator_template.server.ai_killed_function = default_ai_killed_function_server
		end

		if mutator_template.server_level_object_killed_function then
			local function level_object_killed_function(context, data, killed_unit, killer_unit, death_data, killing_blow)
				default_level_object_killed_function_server(context, data, killed_unit, killer_unit, death_data, killing_blow)
				mutator_template.server_level_object_killed_function(context, data, killed_unit, killer_unit, death_data, killing_blow)
			end
			mutator_template.server.level_object_killed_function = level_object_killed_function
		else
			mutator_template.server.level_object_killed_function = default_level_object_killed_function_server
		end

		if mutator_template.server_ai_hit_by_player_function then
			local function ai_hit_by_player_function(context, data, hit_unit, attacking_unit, attack_data)
				default_ai_hit_by_player_function_server(context, data, hit_unit, attacking_unit, attack_data)
				mutator_template.server_ai_hit_by_player_function(context, data, hit_unit, attacking_unit, attack_data)
			end
			mutator_template.server.ai_hit_by_player_function = ai_hit_by_player_function
		else
			mutator_template.server.ai_hit_by_player_function = default_ai_hit_by_player_function_server
		end

		if mutator_template.server_player_hit_function then
			local function player_hit_function(context, data, hit_unit, attacking_unit, attack_data)
				default_player_hit_function_server(context, data, hit_unit, attacking_unit, attack_data)
				mutator_template.server_player_hit_function(context, data, hit_unit, attacking_unit, attack_data)
			end
			mutator_template.server.player_hit_function = player_hit_function
		else
			mutator_template.server.player_hit_function = default_player_hit_function_server
		end

		if mutator_template.server_player_respawned_function then
			local function player_respawned_function(context, data, spawned_unit)
				default_player_respawned_function_server(context, data, spawned_unit)
				mutator_template.server_player_respawned_function(context, data, spawned_unit)
			end
			mutator_template.server.player_respawned_function = player_respawned_function
		else
			mutator_template.server.player_respawned_function = default_player_respawned_function_server
		end

		if mutator_template.server_damage_taken_function then
			local function damage_taken_function(context, data, attacked_unit, attacker_unit, damage, damage_source, damage_type)
				default_damage_taken_function_server(context, data, attacked_unit, attacker_unit, damage, damage_source, damage_type)
				mutator_template.server_damage_taken_function(context, data, attacked_unit, attacker_unit, damage, damage_source, damage_type)
			end
			mutator_template.server.damage_taken_function = damage_taken_function
		else
			mutator_template.server.damage_taken_function = default_damage_taken_function_server
		end

		if mutator_template.server_ai_spawned_function then
			local function ai_spawned_function(context, data, spawned_unit)
				default_ai_spawned_function_server(context, data, spawned_unit)
				mutator_template.server_ai_spawned_function(context, data, spawned_unit)
			end
			mutator_template.server.ai_spawned_function = ai_spawned_function
		else
			mutator_template.server.ai_spawned_function = default_ai_spawned_function_server
		end

		if mutator_template.pre_ai_spawned_function then
			local function pre_ai_spawned_function(context, data, breed, optional_data)
				default_pre_ai_spawned_function(context, data, breed, optional_data)
				mutator_template.pre_ai_spawned_function(context, data, breed, optional_data)
			end
			mutator_template.server.pre_ai_spawned_function = pre_ai_spawned_function
		else
			mutator_template.server.pre_ai_spawned_function = default_pre_ai_spawned_function
		end

		if mutator_template.post_ai_spawned_function then
			local function post_ai_spawned_function(context, data, ai_unit, breed, optional_data)
				default_post_ai_spawned_function(context, data, ai_unit, breed, optional_data)
				mutator_template.post_ai_spawned_function(context, data, ai_unit, breed, optional_data)
			end
			mutator_template.server.post_ai_spawned_function = post_ai_spawned_function
		else
			mutator_template.server.post_ai_spawned_function = default_post_ai_spawned_function
		end

		if mutator_template.server_players_left_safe_zone then
			local function server_players_left_safe_zone(context, data)
				default_server_players_left_safe_zone(context, data)
				mutator_template.server_players_left_safe_zone(context, data)
			end
			mutator_template.server.server_players_left_safe_zone = server_players_left_safe_zone
		else
			mutator_template.server.server_players_left_safe_zone = default_server_players_left_safe_zone
		end

		if mutator_template.client_start_function then
			local function start_function(context, data)
				default_start_function_client(context, data)
				mutator_template.client_start_function(context, data)
			end
			mutator_template.client.start_function = start_function
		else
			mutator_template.client.start_function = default_start_function_client
		end

		if mutator_template.client_stop_function then
			local function stop_function(context, data, is_destroy)
				default_stop_function_client(context, data)
				mutator_template.client_stop_function(context, data, is_destroy)
			end
			mutator_template.client.stop_function = stop_function
		else
			mutator_template.client.stop_function = default_stop_function_client
		end

		if mutator_template.client_hot_join_sync then
			local function hot_join_sync_function(context, data, peer_id)
				default_hot_join_sync_function_client(context, data, peer_id)
				mutator_template.client_hot_join_sync(context, data, peer_id)
			end
			mutator_template.client.hot_join_sync_function = hot_join_sync_function
		else
			mutator_template.client.hot_join_sync_function = default_hot_join_sync_function_client
		end

		if mutator_template.client_ai_killed_function then
			local function ai_killed_function(context, data, killed_unit, killer_unit, killing_blow)
				default_ai_killed_function_client(context, data, killed_unit, killer_unit, killing_blow)
				mutator_template.client_ai_killed_function(context, data, killed_unit, killer_unit, killing_blow)
			end
			mutator_template.client.ai_killed_function = ai_killed_function
		else
			mutator_template.client.ai_killed_function = default_ai_killed_function_client
		end

		if mutator_template.client_level_object_killed_function then
			local function level_object_killed_function(context, data, killed_unit, killer_unit, killing_blow)
				default_level_object_killed_function_client(context, data, killed_unit, killer_unit, killing_blow)
				mutator_template.client_level_object_killed_function(context, data, killed_unit, killer_unit, killing_blow)
			end
			mutator_template.client.level_object_killed_function = level_object_killed_function
		else
			mutator_template.client.level_object_killed_function = default_level_object_killed_function_client
		end

		if mutator_template.client_ai_hit_by_player_function then
			local function ai_hit_by_player_function(context, data, hit_unit, attacking_unit, attack_data)
				default_ai_hit_by_player_function_client(context, data, hit_unit, attacking_unit, attack_data)
				mutator_template.client_ai_hit_by_player_function(context, data, hit_unit, attacking_unit, attack_data)
			end
			mutator_template.client.ai_hit_by_player_function = ai_hit_by_player_function
		else
			mutator_template.client.ai_hit_by_player_function = default_ai_hit_by_player_function_client
		end

		if mutator_template.client_player_hit_function then
			local function player_hit_function(context, data, hit_unit, attacking_unit, attack_data)
				default_player_hit_function_client(context, data, hit_unit, attacking_unit, attack_data)
				mutator_template.client_player_hit_function(context, data, hit_unit, attacking_unit, attack_data)
			end
			mutator_template.client.player_hit_function = player_hit_function
		else
			mutator_template.client.player_hit_function = default_player_hit_function_client
		end

		if mutator_template.client_player_respawned_function then
			local function player_respawned_function(context, data, spawned_unit)
				default_player_respawned_function_client(context, data, spawned_unit)
				mutator_template.client_player_respawned_function(context, data, spawned_unit)
			end
			mutator_template.client.player_respawned_function = player_respawned_function
		else
			mutator_template.client.player_respawned_function = default_player_respawned_function_client
		end

		if mutator_template.client_damage_taken_function then
			local function damage_taken_function(context, data, attacked_unit, attacker_unit, damage, damage_source, damage_type)
				default_damage_taken_function_client(context, data, attacked_unit, attacker_unit, damage, damage_source, damage_type)
				mutator_template.client_damage_taken_function(context, data, attacked_unit, attacker_unit, damage, damage_source, damage_type)
			end
			mutator_template.client.damage_taken_function = damage_taken_function
		else
			mutator_template.client.damage_taken_function = default_damage_taken_function_client
		end

		if mutator_template.client_ai_spawned_function then
			local function ai_spawned_function(context, data, spawned_unit)
				default_ai_spawned_function_client(context, data, spawned_unit)
				mutator_template.client_ai_spawned_function(context, data, spawned_unit)
			end
			mutator_template.client.ai_spawned_function = ai_spawned_function
		else
			mutator_template.client.ai_spawned_function = default_ai_spawned_function_client
		end

		if mutator_template.server_pre_update_function then
			mutator_template.server.pre_update = mutator_template.server_pre_update_function
		end

		if mutator_template.client_pre_update_function then
			mutator_template.client.pre_update = mutator_template.client_pre_update_function
		end

		if mutator_template.server_update_function then
			mutator_template.server.update = mutator_template.server_update_function
		end

		if mutator_template.client_update_function then
			mutator_template.client.update = mutator_template.client_update_function
		end

		if MutatorTemplates [mutator_name] then
			MutatorTemplates [mutator_name] = table.create_copy(MutatorTemplates [mutator_name], mutator_template)
		else
			MutatorTemplates [mutator_name] = mutator_template end
	end

	local mutator_name = "geheimnisnacht_eye_glow_mutator"
	local mutator_template = {}

	-- Content of mutator template
	mutator_template.name = {mutator_name}
	mutator_template.server = { }
	mutator_template.client = { }

	-- TODO -- change icon
	-- TODO -- remove <> from description
	mutator_template.icon = "mutator_icon_glowing_eyes"
	mutator_template.display_name = "halloween_eyes"
	mutator_template.description = "halloween_eyes_description"

	--Localize

	mutator_template.server_ai_spawned_function = function (context, data, spawned_unit)
		data.enemies_to_be_buffed[#data.enemies_to_be_buffed + 1] = spawned_unit
	end
	mutator_template.server_start_function = function (context, data)
		Managers.telemetry_events:geheimnisnacht_hard_mode_toggled(true)

		local hero_side = Managers.state.side:get_side_from_name("heroes")
		local spawned_enemies = hero_side:enemy_units()
		local num_enemies = #spawned_enemies
		local buff_system = Managers.state.entity:system("buff_system")
		data.enemies_to_be_buffed = { }
		for i = 1, num_enemies do
			local unit = spawned_enemies [i]
			if ALIVE [unit] then
				local buff_ext = ScriptUnit.has_extension(unit, "buff_system")
				if buff_ext then
					local has_buff = buff_ext:get_buff_type("geheimnisnacht_eye_glow")
					if buff_system and not has_buff then
						buff_system:add_buff(unit, "geheimnisnacht_eye_glow", unit)
					end
				end
			end
		end
	end
	mutator_template.client_stop_function = function (context, data, is_destroy)
		-- if not is_destroy then
		-- 	local pop_chat = true
		-- 	local message = Localize("system_chat_geheimnisnacht_2021_hard_mode_off")
		-- 	Managers.chat:add_local_system_message(1, message, pop_chat)
		-- end
	
		local hero_side = Managers.state.side:get_side_from_name("heroes")
		local spawned_enemies = hero_side:enemy_units()
		local num_enemies = #spawned_enemies
	
		for i = 1, num_enemies do
			local unit = spawned_enemies [i]
			if ALIVE [unit] then
				local buff_ext = ScriptUnit.has_extension(unit, "buff_system")
				if buff_ext then
					local has_buff = buff_ext:get_buff_type("geheimnisnacht_eye_glow")
					if has_buff then
						buff_ext:remove_buff(has_buff.id)
					end
				end
			end
		end
	end
	mutator_template.client_start_function = function (context, data)
		-- local pop_chat = true
		-- local message = "STARE"
		-- Managers.chat:add_local_system_message(1, message, pop_chat)
	end
	mutator_template.server_stop_function = function (context, data, is_destroy)
		if not is_destroy then
			Managers.telemetry_events:geheimnisnacht_hard_mode_toggled(false)
		end
	
		local hero_side = Managers.state.side:get_side_from_name("heroes")
		local spawned_enemies = hero_side:enemy_units()
		local num_enemies = #spawned_enemies
	
		for i = 1, num_enemies do
			local unit = spawned_enemies [i]
			if ALIVE [unit] then
				local buff_ext = ScriptUnit.has_extension(unit, "buff_system")
				if buff_ext then
					local has_buff = buff_ext:get_buff_type("geheimnisnacht_eye_glow")
					if has_buff then
						buff_ext:remove_buff(has_buff.id)
					end
				end
			end
		end
	end
	mutator_template.server_update_function = function (context, data, dt, t)
		local enemies_to_be_buffed = data.enemies_to_be_buffed
		if table.size(enemies_to_be_buffed) == 0 then
			return
		end
	
		local network_manager = Managers.state.network
		local buff_system = Managers.state.entity:system("buff_system")
	
		for i = #enemies_to_be_buffed, 1, -1 do
			local enemy_unit = enemies_to_be_buffed [i]
			local unit_id = network_manager:unit_game_object_id(enemy_unit)
			if unit_id and buff_system then
	
				buff_system:add_buff(enemy_unit, "geheimnisnacht_eye_glow", enemy_unit)
				table.swap_delete(enemies_to_be_buffed, i)
			end
		end
	end
	mutator_template.post_ai_spawned_function = function (mutator_context, mutator_data, breed, optional_data)
		-- local breed_name = breed.name
		-- local grudge_data = possible_grudge_marks [breed_name]
		-- if grudge_data then
		-- 	local state_by_breed = mutator_data.grudge_mark_state_by_breed or { }
		-- 	mutator_data.grudge_mark_state_by_breed = state_by_breed
	
		-- 	local success = nil
		-- 	local chance = optional_data.spawn_chance or grudge_data.chance
		-- 	local breed_state = state_by_breed [breed_name]
		-- 	success, breed_state = PseudoRandomDistribution.flip_coin(breed_state, chance)
		-- 	state_by_breed [breed_name] = breed_state
	
		-- 	if success then
		-- 		local names = grudge_data.names
		-- 		local grudge_mark_name = names [math.random(1, #names)]
	
		-- 		local list = optional_data.enhancements or { }
		-- 		local base_grudgemark_name = grudge_data.base_grudgemark_name
		-- 		if base_grudgemark_name then
		-- 			list [#list + 1] = BreedEnhancements [base_grudgemark_name]
		-- 		end
		-- 		list [#list + 1] = BreedEnhancements [grudge_mark_name]
	
		-- 		optional_data.enhancements = list
		-- 	end
		-- end
	end

	-- put all the needed template info into one template and add all the default template info
	create_mutator(mutator_template, mutator_name)

	-- add mutator
	MutatorTemplates.geheimnisnacht_eye_glow_mutator = mutator_template

	-- add mutator to network lookup
	local index = #NetworkLookup.mutator_templates + 1
	NetworkLookup.mutator_templates[index] = mutator_name
	NetworkLookup.mutator_templates[mutator_name] = index

end




-- skulls for the skull throne deed

-- load its package
local package_name_skulls = "resource_packages/dlcs/skulls_2023_event"
Managers.package:load(package_name_skulls, "global", nil, async, prioritize)

-- remove pickup removal from tourney balance if it is turned on
mod.on_all_mods_loaded = function()
	if get_mod("TourneyBalance") then
		local function _has_grimoire(inventory_extension)
			local slot_data = inventory_extension:get_slot_data("slot_potion")
		
			if not slot_data then
				return false
			end
		
			local item_template = inventory_extension:get_item_template(slot_data)
		
			if item_template.is_grimoire then
				return true
			end
		
			local additional_items = inventory_extension:get_additional_items("slot_potion")
		
			if additional_items then
				for i = 1, #additional_items do
					local additional_item = additional_items[i]
					local additional_item_template = BackendUtils.get_item_template(additional_item)
		
					if additional_item_template.is_grimoire then
						return true
					end
				end
			end
		
			return false
		end
		local function _replaceable_item_filter(pickup_item_name)
			local function filter(other_data)
				return pickup_item_name ~= other_data.name
			end
		
			return filter
		end
		mod:hook(InteractionDefinitions.pickup_object.client, "can_interact", function(func, interactor_unit, interactable_unit, data, config, world)
			local return_value = not Unit.get_data(interactable_unit, "interaction_data", "used")
			local pickup_extension = ScriptUnit.extension(interactable_unit, "pickup_system")
			local pickup_settings = pickup_extension:get_pickup_settings()
			local slot_name = pickup_settings.slot_name
			local fail_reason = nil

			if return_value and pickup_extension.can_interact then
				return_value = pickup_extension:can_interact()
			end

			if return_value and pickup_settings.can_interact_func then
				return_value = pickup_settings.can_interact_func(interactor_unit, interactable_unit, data)
			end

			local inventory_extension = ScriptUnit.extension(interactor_unit, "inventory_system")
			local item_data, right_hand_weapon_extension, left_hand_weapon_extension = CharacterStateHelper.get_item_data_and_weapon_extensions(inventory_extension)

			if return_value and item_data then
				local current_action_settings, current_action_extension, current_action_hand = CharacterStateHelper.get_current_action_data(left_hand_weapon_extension, right_hand_weapon_extension)

				if current_action_settings and current_action_settings.block_pickup then
					return_value = false
				end
			end

			if return_value and slot_name == "slot_level_event" then
				local wielded_slot_name = inventory_extension:get_wielded_slot_name()

				if wielded_slot_name == "slot_level_event" then
					return_value = false
				end
			end

			local slot_data = slot_name and inventory_extension:get_slot_data(slot_name)

			if return_value and slot_name == "slot_potion" and _has_grimoire(inventory_extension) then
				fail_reason = "grimoire_equipped"
				return_value = false
			end

			local can_hold_more = inventory_extension:can_store_additional_item(slot_name)
			local slot_item_data = slot_data and slot_data.item_data

			if return_value and slot_item_data and slot_item_data.is_not_droppable then
				local can_add_anyway = can_hold_more or inventory_extension:has_droppable_item(slot_name, _replaceable_item_filter(pickup_settings.item_name))

				if not can_add_anyway then
					fail_reason = "not_droppable"
					return_value = false
				end
			end

			if return_value and slot_item_data and not can_hold_more then
				local has_replaceable_item = inventory_extension:has_droppable_item(slot_name, _replaceable_item_filter(pickup_settings.item_name))

				if not has_replaceable_item then
					fail_reason = "already_equipped"
					return_value = false
				end
			end

			if return_value and ScriptUnit.has_extension(interactable_unit, "death_system") then
				local death_extension = ScriptUnit.extension(interactable_unit, "death_system")
				local death_reaction_data = death_extension.death_reaction_data

				if death_reaction_data and death_reaction_data.exploded then
					return_value = false
				end
			end

			if return_value and pickup_settings.type == "ammo" then
				if inventory_extension:is_ammo_blocked() then
					fail_reason = "ammo_blocked"
					return_value = false
				elseif inventory_extension:has_ammo_consuming_weapon_equipped("throwing_axe") and pickup_settings.pickup_name == "all_ammo" then
					fail_reason = "throwing_axe"
					return_value = false
				elseif inventory_extension:has_full_ammo() then
					fail_reason = "ammo_full"
					return_value = false
				end
			end

			return return_value, fail_reason
		end)
		mod:hook(InteractionDefinitions.pickup_object.client, "can_interact", function(func,interactor_unit, interactable_unit, data, config, world)
			if Unit.has_data(interactable_unit, "unit_name") then
				if Unit.get_data(interactable_unit, "unit_name") == "units/mutator/skulls_2023/pup_skull_of_fury" then
					return false
				end
			end
			return func(interactor_unit, interactable_unit, data, config, world)
		end)
	end
end



mod.mutator_check = false
mod.on_game_state_changed = function(status, state)
	if status == "enter" and state == "StateIngame" and mod.mutator_check == false and mod:get("change_eye_color") then
		mod.initiate_mutator()
		mod.mutator_check = true
	end

	if status == "enter" and state == "StateIngame" and mod:is_enabled() then
		local mutator_handler = Managers.state.game_mode._mutator_handler

		if not mutator_handler:has_activated_mutator("geheimnisnacht_2021") then
				if mod:get("geheimnisnacht_2021") then
					mutator_handler:activate_mutator("geheimnisnacht_2021")
				end
				if mod:get("geheimnisnacht_2023") then
					mutator_handler:activate_mutator("geheimnisnacht_2021")
				end
		end

		if not mutator_handler:has_activated_mutator("night_mode") then
			if mod:get("night_mode") then
				--mod:echo("[Geheimnisnacht+]: Activating %s", Localize("display_name_mutator_night_mode"))
				mutator_handler:activate_mutator("night_mode")
			end
		end

		if not mutator_handler:has_activated_mutator("skulls_2023") then
			if mod:get("skulls_2023") then
				mutator_handler:activate_mutator("skulls_2023")
			end
		end

		if not mutator_handler:has_activated_mutator("geheimnisnacht_eye_glow_mutator") and mod:get("change_eye_color") == true then
			mutator_handler:activate_mutator("geheimnisnacht_eye_glow_mutator")
		elseif mutator_handler:has_activated_mutator("geheimnisnacht_eye_glow_mutator") and mod:get("change_eye_color") == false then
			mutator_handler:deactivate_mutator("geheimnisnacht_eye_glow_mutator")
		end

		if mod:get("geheimnisnacht_2021") then
			geheimnisnacht_2021()
		elseif mod:get("geheimnisnacht_2023") then
			geheimnisnacht_2023()
		end

	end
end



-- failsave so that not both versions of geheimnisnacht are running at the same time
mod.settings_failsave = true
function mod:on_setting_changed()
	if mod:get("geheimnisnacht_2021") == true and mod.settings_failsave == true then
		mod:set("geheimnisnacht_2023", false)
		mod.settings_failsave = false
	end
	if mod:get("geheimnisnacht_2023") == true and mod.settings_failsave == false then
		mod:set("geheimnisnacht_2021", false)
		mod.settings_failsave = true
	end
end







-- mod:echo("Geheimnisnacht+ v2.0 enabled")

-- TODO
-- DONE -- change locations of new maps too the fatshark locations
-- DONE -- add skulls for the skull throne (skull event mutator)
-- DONE -- make toggle to switch between the twoo different variations of geheimnisnacht events
-- DONE -- add eye color buff to game somehow
-- DONE -- two notes for skull in chat? - remove one
-- DONE -- Fix Failsave for mutator version
-- DONE!! -- create and import icon for mutator
-- DONE -- remove pickup removal from tourney balance
-- DONE -- add globals to hook (tb removal)
-- Extend list for mutators
-- (make it so you cant pick up potions when holding the skull)

--[[
Changelog v2.0:
- Rebranded The Mod from "Geheimnisnacht+" to "Geheimnisnacht Unlimited"
- Changed Thumbnail
- Changed the locations of the Ritual sites to the position that fatshark used in the event.
(Maps affected: Festering Ground, Khazukan Kazakit-ha!, War Camp, Tower of Treachery, Blood in the Darkness)
- Added multiple new options in the mod menu:
	- You can Choose to pick the event in the version it used to in 2021 and 2022 or in 2023
	- You can toggle the Night mode (Helloween Image Filter) seperately
	- You can change the eye color of enemies without having to play the deed/ picking up the skull
	- Added another Event modifier "Skulls for the Skull Throne"
	- Removed various chat prompts to less spam the chat

Notes:
	- ALL party members need to have this mod installed
	- The Hosts settings will override the clients ones
	- Removes the pickup ban on skulls in tourney balance (You can play the Skull Mutator with Tourney Balance Enabled)
	- Added Texture for Eye Deed
	- The Eye Deed is purely cosmetic and doesnt change enemy behaviour

]]


-- NOTES
-- 5.2 https://github.com/thewhitegoatcb/Vermintide-2-Source-Code/blob/60a2d29f171e92f2eac117c733a8c3eb91032881/scripts/settings/mutators/mutator_geheimnisnacht_2021.lua#L132

-- Fatsharks Event Coordinates:
-- 2021: Old Haunts, Screaming Bell, Enchanter's Lair, Empire in Flames, Righteous Stand
-- 2022: Athel Yenlui, Hunger in the Dark, Halescourge, Against the Grain, Convocation of Decay
-- 2023: Festering Ground (the cave), Khazukan Kazakit-ha!, War Camp, Tower of Treachery, Blood in the Darkness