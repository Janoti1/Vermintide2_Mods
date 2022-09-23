local mod = get_mod("Classic Sister")

-- Text Localization
local _language_id = Application.user_setting("language_id")
local _localization_database = {}
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
--local buff_tweak_data = require("scripts/settings/dlcs/woods/talent_settings_woods")

mod._quick_localize = function (self, text_id)
    local mod_localization_table = _localization_database
    if mod_localization_table then
        local text_translations = mod_localization_table[text_id]
        if text_translations then
            return text_translations[_language_id] or text_translations["en"]
        end
    end
end
function mod.add_text(self, text_id, text)
    if type(text) == "table" then
        _localization_database[text_id] = text
    else
        _localization_database[text_id] = {
            en = text
        }
    end
end
function mod.add_talent_text(self, talent_name, name, description)
    mod:add_text(talent_name, name)
    mod:add_text(talent_name .. "_desc", description)
end
mod:hook("Localize", function(func, text_id)
    local str = mod:_quick_localize(text_id)
    if str then return str end
    return func(text_id)
end)

-- Buff and Talent Functions
local function is_local(unit)
	local player = Managers.player:owner(unit)

	return player and not player.remote
end
local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end
function is_at_inn()
    local game_mode = Managers.state.game_mode
    if not game_mode then return nil end
    return game_mode:game_mode_key() == "inn"
end
function mod.modify_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end

    local original_buff = TalentBuffTemplates[hero_name][buff_name]
    local merged_buff = original_buff
    for i=1, #original_buff.buffs do
        if new_talent_buff.buffs[i] then
            merged_buff.buffs[i] = merge(original_buff.buffs[i], new_talent_buff.buffs[i])
        elseif original_buff[i] then
            merged_buff.buffs[i] = merge(original_buff.buffs[i], new_talent_buff.buffs)
        else
            merged_buff.buffs = merge(original_buff.buffs, new_talent_buff.buffs)
        end
    end

    TalentBuffTemplates[hero_name][buff_name] = merged_buff
    BuffTemplates[buff_name] = merged_buff
end 
function mod.add_talent(self, career_name, tier, index, new_talent_name, new_talent_data)
    local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
    local talent_tree_index = career_settings.talent_tree_index
    
    local new_talent_index = #Talents[hero_name] + 1

    Talents[hero_name][new_talent_index] = merge({
        name = new_talent_name,
        description = new_talent_name .. "_desc",
        icon = "icons_placeholder",
        num_ranks = 1,
        buffer = "both",
        requirements = {},
        description_values = {},
        buffs = {},
        buff_data = {},
    }, new_talent_data)

    TalentTrees[hero_name][talent_tree_index][tier][index] = new_talent_name
    TalentIDLookup[new_talent_name] = {
        talent_id = new_talent_index,
        hero_name = hero_name
    }
end
function mod.modify_talent(self, career_name, tier, index, new_talent_data)
    local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
    local talent_tree_index = career_settings.talent_tree_index

    local old_talent_name = TalentTrees[hero_name][talent_tree_index][tier][index]
    local old_talent_id_lookup = TalentIDLookup[old_talent_name]
    local old_talent_id = old_talent_id_lookup.talent_id
    local old_talent_data = Talents[hero_name][old_talent_id]

    Talents[hero_name][old_talent_id] = merge(old_talent_data, new_talent_data)
end
function mod.add_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)   
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end
    TalentBuffTemplates[hero_name][buff_name] = new_talent_buff
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
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
function mod.add_buff(self, owner_unit, buff_name)
    if Managers.state.network ~= nil then
        local network_manager = Managers.state.network
        local network_transmit = network_manager.network_transmit

        local unit_object_id = network_manager:unit_game_object_id(owner_unit)
        local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
        local is_server = Managers.player.is_server

        if is_server then
            local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

            buff_extension:add_buff(buff_name)
            network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
        else
            network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end
    end
end
function mod.add_buff_function(self, name, func)
    BuffFunctionTemplates.functions[name] = func
end
function mod.add_proc_function(self, name, func)
    ProcFunctions[name] = func
end
function mod.add_explosion_template(self, explosion_name, data)
    ExplosionTemplates[explosion_name] = merge({ name = explosion_name}, data)
    local index = #NetworkLookup.explosion_templates + 1
    NetworkLookup.explosion_templates[index] = explosion_name
    NetworkLookup.explosion_templates[explosion_name] = index
end

-- Load in weapons beforehand
--[[
BackendInterfaceItemPlayfab.get_item_template = function (self, item_data, backend_id)
    local template_name = item_data.temporary_template or item_data.template
    local item_template = Weapons[template_name]
    local modified_item_templates = self._modified_templates
    local modified_item_template = nil

    if item_template then
        -- if backend_id then
            -- if not modified_item_templates[backend_id] then
                -- modified_item_template = GearUtils.apply_properties_to_item_template(item_template, backend_id)
                -- self._modified_templates[backend_id] = modified_item_template
            -- else
                -- return modified_item_templates[backend_id]
            -- end
        -- end

        -- return modified_item_template or item_template
        return item_template
    end

    item_template = Attachments[template_name]

    if item_template then
        return item_template
    end

    item_template = Cosmetics[template_name]

    if item_template then
        return item_template
    end

    fassert(false, "no item_template for item: " .. item_data.key .. ", template name = " .. template_name)
end
]]


-- Perk 1 A Murder of Spites instead of Blackvenom Blades

PassiveAbilitySettings.we_thornsister.buffs = {
		"kerillian_thorn_sister_passive_healing_received_aura",
		"kerillian_thorn_sister_passive_temp_health_funnel_aura",
		"kerillian_thorn_sister_damage_vs_wounded_enemies",
		"thorn_sister_ability_cooldown_on_hit",
		"thorn_sister_ability_cooldown_on_damage_taken"
}
TalentBuffTemplates.kerillian_thorn_sister_damage_vs_wounded_enemies = {
    buffs = {
        {
            perk = "missing_health_damage"
        }
    }
}
PassiveAbilitySettings.we_thornsister.perks = {
	{
		display_name = "career_passive_name_we_thornsister_a_OG",
		description = "career_passive_desc_we_thornsister_a_OG"
	},
	{
		display_name = "career_passive_name_we_thornsister_b",
		description = "career_passive_desc_we_thornsister_b"
	},
	{
		display_name = "career_passive_name_we_thornsister_c",
		description = "career_passive_desc_we_thornsister_c"
	}
}
--[[
https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/2e438eb12740ccfe196ffea7ee7d25115bd2ac23/scripts/helpers/damage_utils.lua#L2184
    if buff_extension:has_buff_perk("missing_health_damage") then
					local attacked_health_extension = ScriptUnit.extension(attacked_unit, "health_system")
					local missing_health_percentage = 1 - attacked_health_extension:current_health_percent()
					local damage_mult = 1 + missing_health_percentage / 2
					damage = damage * damage_mult
				end
]]
mod:add_text("career_passive_name_we_thornsister_a_OG", "A Murder of Spites")
mod:add_text("career_passive_desc_we_thornsister_a_OG", "Kerillian deals up to 50%% more damage to wounded targets depending on their remaining health. For example, she does no extra damage against full health enemies, 25%% extra against enemies at half health, etc.")




-- Artharti's Delight Crits instead of Poison (Works)

TalentBuffTemplates.kerillian_thorn_sister_big_bleed = {
    buffs = {
        {
            event = "on_hit",
            bleed = "thorn_sister_big_bleed",
            buff_func = "thorn_sister_add_bleed_on_hit"
        }
    }
}
ProcFunctions.thorn_sister_add_bleed_on_hit = function (player, buff, params)
    local player_unit = player.player_unit
    local hit_unit = params[1]
    local is_crit = params[6]

    if ALIVE[player_unit] and ALIVE[hit_unit] and is_crit then -- not is crit
        local template = buff.template
        local bleed = template.bleed
        local buff_system = Managers.state.entity:system("buff_system")
        local career_extension = ScriptUnit.extension(player_unit, "career_system")
        local power_level = career_extension:get_career_power_level()
        local target_buff_extension = ScriptUnit.has_extension(hit_unit, "buff_system")

        if not target_buff_extension then -- or not target_buff_extension:has_buff_perk(buff_perks.poisoned) then
            return false
        end

        local buff_params = {
            power_level = power_level,
            attacker_unit = player_unit
        }

        buff_system:add_buff_synced(hit_unit, bleed, BuffSyncType.LocalAndServer, buff_params)
    end
end
mod:modify_talent("we_thornsister", 2, 2, {
	name = "athartis_delight_name",
	description = "athartis_delight_desc",
	buffs = {
		"kerillian_thorn_sister_big_bleed"
	}
})
mod:add_text("athartis_delight_name", "Artharti's Delight")
mod:add_text("athartis_delight_desc", "Critical Strikes make the target Bleed.")




-- Isha's Bounty instead of Briar's Malice (Works)

BuffTemplates.kerillian_power_on_health_gain = {
    buffs = {
        {
            name = "kerillian_power_on_health_gain",
            max_stacks = 3,
            event_buff = true,
            event = "on_healed",
            buff_func = "add_buff_on_proc_thorn", 
            buff_to_add = "kerillian_power_on_health_gain_buff",
            health_threshold = 1,
        }
}}
BuffTemplates.kerillian_power_on_health_gain_buff = {
    buffs = {
        {
            name = "kerillian_power_on_health_gain_buff",
            max_stacks = 3,
            stat_buff = "power_level",
            icon = "kerillian_thornsister_power_on_health_gain",
            multiplier = 0.05,
            duration = 8,
            refresh_durations = true,        
        }
}}
ProcFunctions.add_buff_on_proc_thorn = function (player, buff, params)
    local player_unit = player.player_unit

    if ALIVE[player_unit] then
        local buff_extension = ScriptUnit.extension(player_unit, "buff_system") --HT
        local template = buff.template --HT
        local buff_to_add = template.buff_to_add --HT
		buff_extension:add_buff(buff_to_add) --HT
    end
end
mod:modify_talent("we_thornsister", 2, 3, {
	name = "ishas_bounty_name",
	description = "ishas_bounty_desc",
    buffer = "server",
	num_ranks = 1,
	icon = "kerillian_thornsister_power_on_health_gain",
	buffs = {
		"kerillian_power_on_health_gain"
	}
})
mod:add_text("ishas_bounty_name", "Isha's Bounty")
mod:add_text("ishas_bounty_desc", "Gaining health grants 5%% Power for 8 seconds. Stacks up to 3 times.")




-- Hekarti's Cruel Bargain instead of Bonded Spirit (Works)

BuffTemplates.kerillian_thorn_sister_reduce_passive_on_elite = {
    buffs = {
        {
            event = "on_elite_killed",
            time_removed_per_kill = 1,
            buff_func = "kerillian_thorn_sister_reduce_passive_on_elite_new",
        }
    }
}
ProcFunctions.kerillian_thorn_sister_reduce_passive_on_elite_new = function (player, buff, params)
    local player_unit = player.player_unit

    if ALIVE[player_unit] then
        local career_extension = ScriptUnit.extension(player_unit, "career_system")
        local passive_ability = career_extension:get_passive_ability(1)
        local template = buff.template
        local time_to_remove = template.time_removed_per_kill or 0

        career_extension:modify_extra_ability_charge(time_to_remove)
    end
end
PassiveAbilityThornsister._update_extra_abilities_info = function (self, talent_extension)
	if not talent_extension then
		return
	end

	local career_ext = self._career_extension

	if not career_ext then
		return
	end

	local max_uses = self._ability_init_data.max_stacks

	if talent_extension:has_talent("kerillian_double_passive") then
		max_uses = max_uses + 1
	end

	career_ext:update_extra_ability_uses_max(max_uses)

	local cooldown = self._ability_init_data.cooldown

	--if talent_extension:has_talent("kerillian_thorn_sister_faster_passive") then
	--	cooldown = cooldown * 0.5
	--end

	career_ext:update_extra_ability_charge(cooldown)
end
mod:modify_talent("we_thornsister", 4, 2, {
	name = "hekartis_cruel_bargain_name",
	description = "hekartis_cruel_bargain_desc",
    buffer = "server",
	num_ranks = 1,
	icon = "kerillian_thornsister_reduce_passive_on_elite",
	buffs = {
		"kerillian_thorn_sister_reduce_passive_on_elite"
	}
})
mod:add_text("hekartis_cruel_bargain_name", "Hekarti's Cruel Bargain")
mod:add_text("hekartis_cruel_bargain_desc", "For each Elite enemy slain near Kerillian, the cooldown of Radiance decreases by 1 seconds.")




-- Radiant Inheritance (for Sister only)
-- Button isnt working update?

mod.check_old_radiant = function ()
	if mod.settings.enable_old_radiant then
		
		mod:add_talent("we_thornsister", 4, 3, "kerillian_thorn_radiants", {
			num_ranks = 1,
			buffer = "both",
			icon = "kerillian_thornsister_avatar",
			buffs = {
				"kerillian_thorn_old_radiant"
			}
		})
		mod:add_talent_text("kerillian_thorn_radiants", "Radiant Inheritance", "Consuming Radiance grants Kerillian vastly increased combat potency for 15 seconds.")
	
	else
	
		mod:add_talent("we_thornsister", 4, 3, "kerillian_thorn_radiants", {
			num_ranks = 1,
			buffer = "both",
			icon = "kerillian_thornsister_avatar",
			buffs = {
				"kerillian_thorn_radiant"
			}
		})
		mod:add_talent_text("kerillian_thorn_radiants", "Radiant Inheritance", "Consuming Radiance grants Kerillian 20%% extra attack speed, move speed, power and crit power for 10 seconds.")
	
	end
end

-- Post First Nerf Radiant (Pre Rework)
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_radiant", {
    {
		name = "kerillian_thorn_radiant",
        event_buff = true,
		buff_func = "add_buff",
		event = "on_extra_ability_consumed",
		buff_to_add = "kerillian_thorn_active_radiant_1_cs"
	}
})

BuffTemplates.kerillian_thorn_active_radiant_1_cs = {
    activation_effect = "fx/thornsister_avatar_screenspace",
    deactivation_sound = "stop_career_ability_kerilian_power_loop",
    activation_sound = "play_career_ability_kerilian_power_loop",
    buffs = {
        {
            --crit power
            name = "kerillian_thorn_active_radiant_1_cs",
            refresh_durations = true,
            multiplier = 0.2,
            stat_buff = "critical_strike_effectiveness",
            max_stacks = 1,
            duration = 10
        },
        {
            --power level
            name = "kerillian_thorn_active_radiant_2_cs",
            refresh_durations = true,
            multiplier = 0.2,
            stat_buff = "power_level",
            max_stacks = 1,
            duration = 10
        },
        {
            --movement speed
            name = "kerillian_thorn_active_radiant_3_cs",
            refresh_durations = true,
            multiplier = 1.2,
            remove_buff_func = "remove_movement_buff",
            max_stacks = 1,
            apply_buff_func = "apply_movement_buff",
            duration = 10,
            path_to_movement_setting_to_modify = {
                "move_speed"
            }  
        },
        {
            --attack speed
            name = "kerillian_thorn_active_radiant_4_cs",
            refresh_durations = true,
            multiplier = 0.2,
            duration = 10,
            stat_buff = "attack_speed",
            continuous_effect = "fx/thornsister_avatar_screenspace_loop",
            max_stacks = 1,
            icon = "kerillian_thornsister_avatar",
            priority_buff = true,
            particles = {
                {
                    orphaned_policy = "stop",
                    first_person = false,
                    third_person = true,
                    effect = "fx/thornsister_avatar_3p",
                    continuous = true,
                    destroy_policy = "stop"
                }
            }
        }   
    }
}

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_radiant_1_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_radiant_1_cs"] = index

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_radiant_2_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_radiant_2_cs"] = index

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_radiant_3_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_radiant_3_cs"] = index

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_radiant_4_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_radiant_4_cs"] = index


-- Release Radiant
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_old_radiant", {
		{
			name = "kerillian_thorn_old_radiant",
			event_buff = true,
			buff_func = "add_buff",
			event = "on_extra_ability_consumed",
			buff_to_add = "kerillian_thorn_active_old_radiant_1_cs"
		}
})

BuffTemplates.kerillian_thorn_active_old_radiant_1_cs = {
		activation_effect = "fx/thornsister_avatar_screenspace",
		deactivation_sound = "stop_career_ability_kerilian_power_loop",
		activation_sound = "play_career_ability_kerilian_power_loop",
		buffs = {
			{
				--crit power
				name = "kerillian_thorn_active_old_radiant_1_cs",
				refresh_durations = true,
				multiplier = 0.4,
				stat_buff = "critical_strike_effectiveness",
				max_stacks = 1,
				duration = 15
			},
			{
				--power level
				name = "kerillian_thorn_active_old_radiant_2_cs",
				refresh_durations = true,
				multiplier = 0.5,
				stat_buff = "power_level",
				max_stacks = 1,
				duration = 15
			},
			{
				--movement speed
				name = "kerillian_thorn_active_old_radiant_3_cs",
				refresh_durations = true,
				multiplier = 1.3,
				remove_buff_func = "remove_movement_buff",
				max_stacks = 1,
				apply_buff_func = "apply_movement_buff",
				duration = 15,
				path_to_movement_setting_to_modify = {
					"move_speed"
				}
			},
			{
				--attack speed
				name = "kerillian_thorn_active_old_radiant_4_cs",
				refresh_durations = true,
				multiplier = 0.2,
				duration = 15,
				stat_buff = "attack_speed",
				continuous_effect = "fx/thornsister_avatar_screenspace_loop",
				max_stacks = 1,
				icon = "kerillian_thornsister_avatar",
				priority_buff = true,
				particles = {
					{
						orphaned_policy = "stop",
						first_person = false,
						third_person = true,
						effect = "fx/thornsister_avatar_3p",
						continuous = true,
						destroy_policy = "stop"
					}
				}
			},
			{
				--crit chance
				name = "kerillian_thorn_active_old_radiant_5_cs",
				refresh_duration = true,
				multiplier = 0.2,
				duration = 15,
				stat_buff = "critical_strike_chance",
				max_stacks = 1,
			}
		}
}

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_old_radiant_1_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_old_radiant_1_cs"] = index

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_old_radiant_2_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_old_radiant_2_cs"] = index

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_old_radiant_3_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_old_radiant_3_cs"] = index

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_old_radiant_4_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_old_radiant_4_cs"] = index

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_old_radiant_5_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_old_radiant_5_cs"] = index




-- The Pale Queen's Choosing instead of Recursive Toxin

mod:add_talent_buff_template("wood_elf", "kerillian_thorn_free_throw_heal_all_handler", {
    {
        buff_to_add = "kerillian_thorn_free_throw_buff",
        max_stacks = 1,
        heal_buff = "kerillian_thorn_free_heal_buff",
        timer_buff = "kerillian_thorn_free_throw_heal_all_timer",
        update_func = "kerillian_thorn_sister_free_throw_handler_update_new",
        update_frequency = 0.1,
        time_removed_per_kill = 0
    },
})
BuffFunctionTemplates.functions.kerillian_thorn_sister_free_throw_handler_update_new = function (owner_unit, buff, params)
    local player_unit = owner_unit

    if ALIVE[player_unit] then
        local template = buff.template
        local timer_buff_to_add = template.timer_buff
        local buff_to_add = template.buff_to_add
        local t = params.t
        local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

        if not buff.timer_buff then
            buff.timer_buff = buff_extension:get_non_stacking_buff(timer_buff_to_add)
        end

        local timer_buff = buff.timer_buff
        local time_remaining = 0

        if buff.timer_buff then
            local end_time = timer_buff.start_time + timer_buff.duration
            time_remaining = end_time - t
        end

        if not timer_buff or time_remaining <= 0 then
            local has_buff = buff_extension:has_buff_type(buff_to_add)

            if not has_buff and not buff.buffed then
                local buff_system = Managers.state.entity:system("buff_system")

                buff_system:add_buff(player_unit, buff_to_add, player_unit, false)

                buff.buffed = true
            elseif not has_buff and buff.buffed then
                buff_extension:add_buff(timer_buff_to_add)

                buff.timer_buff = nil
                buff.buffed = nil
            end
        end
    end
end
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_free_throw_heal_all_timer", {
    {
        is_cooldown = true,
        icon = "kerillian_thornsister_free_throw",
        max_stacks = 1,
        duration = 8
    },
})
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_free_throw_buff", {
    {
        buff_to_add = "kerillian_thorn_free_heal_buff",
        multiplier = -1,
        stat_buff = "reduced_overcharge",
        buff_func = "kerillian_thorn_sister_add_buff_remove_new",
        max_stacks = 1,
        icon = "kerillian_thornsister_free_throw",
        event = "on_ammo_used",
        perk = buff_perks.infinite_ammo,
        amount_to_heal = 3,
    },
})
ProcFunctions.kerillian_thorn_sister_add_buff_remove_new = function (player, buff, params)
    local player_unit = player.player_unit

    if ALIVE[player_unit] then
        local buff_to_add = buff.template.buff_to_add
        local buff_system = Managers.state.entity:system("buff_system")

        buff_system:add_buff(player_unit, buff_to_add, player_unit, false)

        local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

        buff_extension:remove_buff(buff.id)
    end
end
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_free_heal_buff", {
    {
        event = "on_damage_dealt",
        buff_func = "kerillian_thorn_restore_health_on_ranged_hit",
        max_stacks = 1,
        duration = 0.5,
        amount_to_heal = 3,
    },
})
ProcFunctions.kerillian_thorn_restore_health_on_ranged_hit = function (player, buff, params)
    local player_unit = player.player_unit
    local attack_type = params[7]

    if ALIVE[player_unit] and attack_type and (attack_type == "projectile" or attack_type == "instant_projectile") then
        if Managers.state.network.is_server then
            local side = Managers.state.side.side_by_unit[player_unit]
            local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
            local amount_to_heal = buff.template.amount_to_heal
            
            for i = 1, #player_and_bot_units, 1 do
                DamageUtils.heal_network(player_and_bot_units[i], player_unit, amount_to_heal, "career_passive")
            end     
        end

        local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

        buff_extension:remove_buff(buff.id)
    end
end
mod:add_talent("we_thornsister", 5, 1, "the_pales_queen_choosing", {
    num_ranks = 1,
    buffer = "server",
    icon = "kerillian_thornsister_free_throw",
    buffs = {
        "kerillian_thorn_free_throw_heal_all_handler"
    },
	
})
mod:add_text("the_pales_queen_choosing", "The Pale Queen's Choosing")
mod:add_text("the_pales_queen_choosing_desc", "Every 8 seconds, Kerillian's next Ranged Attack consumes no resource and restores 3 permanent health.")




-- Morai-Heg's Doomsight instead of Lingering Blackvenom (Works)

--amount to add
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability", {
	amount_to_add = 3,
})

--remove on use
BuffTemplates.kerillian_thorn_sister_crit_on_any_ability_handler = { 
    buffs = {
        {
            event = "on_critical_action",
            max_stacks = 1,
            buff_to_remove = "kerillian_thorn_sister_crit_on_any_ability_buff",
            buff_func = "remove_ref_buff_stack_woods"
        }
    }
}
ProcFunctions.remove_ref_buff_stack_woods = function (player, buff, params)
    local player_unit = player.player_unit

    if ALIVE[player_unit] then
        local buff_template = buff.template
        local buff_name = buff_template.buff_to_remove
        local buff_extension = ScriptUnit.extension(player_unit, "buff_system")
        local buffs = buff_extension:get_stacking_buff(buff_name)

        if buffs then
            local num_stacks = #buffs

            if num_stacks > 0 then
                local buff_id = buffs[num_stacks].id

                buff_extension:remove_buff(buff_id)
            end
        end
    end
end

--add when ulti
BuffTemplates.kerillian_thorn_sister_crit_on_any_ability = { 
    buffs = {
        {
            name = "kerillian_thorn_sister_crit_on_any_ability_buff",
            event = "on_ability_activated",
            buff_func = "add_buff_reff_buff_stack",
            max_stacks = 1,
            reference_buff = "kerillian_thorn_sister_crit_on_any_ability_handler"
        }
    }
}
ProcFunctions.add_buff_reff_buff_stack = function (player, buff, params)
    local player_unit = player.player_unit
    --local triggering_unit = params[1] (4.6)

    if ALIVE[player_unit] then -- and triggering_unit == player_unit (4.6)
        local template = buff.template
        local buff_name = template.buff_to_add
        local amount_to_add = template.amount_to_add
        local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

        for i = 1, amount_to_add, 1 do
            buff_extension:add_buff(buff_name)
        end
    end
end
--numbers saved
BuffTemplates.kerillian_thorn_sister_crit_on_any_ability_buff = { 
    buffs = {
        {
            icon = "kerillian_thornsister_crit_on_any_ability",
            perk = buff_perks.guaranteed_crit,
            max_stacks = math.huge
        }
    }
}
mod:modify_talent("we_thornsister", 5, 2, {
	name = "moraihegs_doomsight_name",
	description = "moraihegs_doomsight_desc",
    buffer = "server",
	num_ranks = 1,
	icon = "kerillian_thornsister_crit_on_any_ability",
	buffs = {
		"kerillian_thorn_sister_crit_on_any_ability",
        "kerillian_thorn_sister_crit_on_any_ability_handler",
	}
})
mod:add_text("moraihegs_doomsight_name", "Morai-Heg's Doomsight")
mod:add_text("moraihegs_doomsight_desc", "Gain 3 guaranteed Critical Strikes each time a career skill is used.")


-- Repel (deactivate sound effect)


mod.check_repel_sound = function ()

	if mod.settings.disable_repel_sound then
		
		mod:add_talent_buff_template ("wood_elf", "kerillian_thorn_sister_big_push_buff", {
			--activation_sound = "career_ability_kerilian_push",
			buffs = {
				{
					stat_buff = "push_range",
					buff_func = "thorn_sister_big_push"
				}
			}
		})
	
	else
		
		mod:add_talent_buff_template ("wood_elf", "kerillian_thorn_sister_big_push_buff", {
			activation_sound = "career_ability_kerilian_push",
			buffs = {
				{
					stat_buff = "push_range",
					buff_func = "thorn_sister_big_push"
				}
			}
		})

	end
end

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
	poison = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_poison"
}
local WALL_TYPES = table.enum("default", "bleed", "poison")
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
				UNIT_NAME = UNIT_NAMES[WALL_TYPES.poison]
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



-- Moonfire Bow (Changed dot and made it the same over all attacks)

-- moonfirebow changes that directly change the official mfb
mod.moonfirebow_changes = function ()

	local ARROW_HIT_EFFECT = "we_deus_01_arrow_impact"

	--uncharged shot
	Weapons.we_deus_01_template_1.actions.action_one.default.hit_effect = ARROW_HIT_EFFECT
	Weapons.we_deus_01_template_1.actions.action_one.default.impact_data.damage_profile = "we_deus_01"

	--charged shot
	Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.hit_effect = ARROW_HIT_EFFECT
	Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.impact_data.damage_profile = "we_deus_01"
	Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.impact_data.aoe = ExplosionTemplates.we_deus_01_large

	--half charges shot
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.hit_effect = ARROW_HIT_EFFECT
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.impact_data.damage_profile = "we_deus_01"
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.impact_data.aoe = ExplosionTemplates.we_deus_01_small


	--base impact
	DamageProfileTemplates.we_deus_01 = {
			charge_value = "projectile",
			no_stagger_damage_reduction_ranged = true,
			require_damage_for_dot = true,
			ignore_stagger_reduction = true,
			critical_strike = {
				attack_armor_power_modifer = {
					1,
					0.5,
					1,
					1,
					1,
					0.25
				},
				impact_armor_power_modifer = {
					1,
					0.5,
					1,
					1,
					1,
					0.25
				}
			},
			armor_modifier = {
				attack = {
					1,
					0.5,
					1,
					0.75,
					0.75,
					0.25
				},
				impact = {
					1,
					0.5,
					1,
					0.75,
					0.75,
					0.25
				}
			},
			armor_modifier_far = {
				attack = {
					1,
					0.5,
					1,
					0.75,
					0.75,
					0.25
				},
				impact = {
					1,
					0.5,
					1,
					0.75,
					0.75,
					0.25
				}
			},
			cleave_distribution = {
				attack = 0.15,
				impact = 0.15
			},
			default_target = {
				boost_curve_coefficient_headshot = 1,
				dot_template_name = "we_deus_01_dot",
				boost_curve_type = "ninja_curve",
				boost_curve_coefficient = 0.75,
				attack_template = "arrow_carbine",
				power_distribution_near = {
					attack = 0.41,
					impact = 0.3
				},
				power_distribution_far = {
					attack = 0.3,
					impact = 0.25
				},
				range_dropoff_settings = carbine_dropoff_ranges
			},
			targets = {}
	}

	--dot damage profile
	DamageProfileTemplates.we_deus_01_dot = {
			is_dot = true,
			charge_value = "n/a",
			no_stagger_damage_reduction_ranged = true,
			no_stagger = true,
			cleave_distribution = {
				attack = 0.25,
				impact = 0.25
			},
			armor_modifier = {
				attack = {
					2,
					1,
					3,
					2,
					1,
					0.5
				},
				impact = {
					1,
					0.5,
					1,
					1,
					1,
					0
				}
			},
			default_target = {
				damage_type = "burninating",
				boost_curve_type = "tank_curve",
				boost_curve_coefficient = 0.2,
				attack_template = "light_blunt_tank",
				power_distribution = {
					attack = 0.07,
					impact = 0.05
				}
			},
			targets = {}
	}

	-- longer dot (buff {} is NOT needed)
	mod.add_buff_template("wood_elf", "we_deus_01_dot", {
			--dlc_settings.buff_templates
			duration = 5,
			name = "we_deus_01_dot",
			end_flow_event = "smoke",
			start_flow_event = "burn",
			death_flow_event = "burn_death",
			remove_buff_func = "remove_dot_damage",
			apply_buff_func = "start_dot_damage",
			time_between_dot_damages = 0.75,
			damage_type = "burninating",
			damage_profile = "we_deus_01_dot",
			update_func = "apply_dot_damage",
			perk = buff_perks.burning
	})

end

-- moonfirebow changes that will revert the OG moonfirebow to it's official form
mod.official_moonfirebow = function ()

	local ARROW_HIT_EFFECT = nil

	--uncharged shot
	Weapons.we_deus_01_template_1.actions.action_one.default.hit_effect = ARROW_HIT_EFFECT
	Weapons.we_deus_01_template_1.actions.action_one.default.impact_data.damage_profile = "we_deus_01_fast"

	--charged shot
	Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.hit_effect = ARROW_HIT_EFFECT
	Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.impact_data.damage_profile = "we_deus_01_charged"
	Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.impact_data.aoe = nil

	--half charges shot
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.hit_effect = ARROW_HIT_EFFECT
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.impact_data.damage_profile = "we_deus_01_special_charged"
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.impact_data.aoe = nil

	--base impact
	DamageProfileTemplates.we_deus_01 = {
		charge_value = "projectile",
		no_stagger_damage_reduction_ranged = true,
		require_damage_for_dot = true,
		ignore_stagger_reduction = true,
		critical_strike = {
			attack_armor_power_modifer = {
				1,
				0.5,
				1,
				1,
				1,
				0.25
			},
			impact_armor_power_modifer = {
				1,
				0.5,
				1,
				1,
				1,
				0.25
			}
		},
		armor_modifier = {
			attack = {
				1,
				0.5,
				1,
				0.75,
				0.75,
				0.25
			},
			impact = {
				1,
				0.5,
				1,
				0.75,
				0.75,
				0.25
			}
		},
		armor_modifier_far = {
			attack = {
				1,
				0.5,
				1,
				0.75,
				0.75,
				0.25
			},
			impact = {
				1,
				0.5,
				1,
				0.75,
				0.75,
				0.25
			}
		},
		cleave_distribution = {
			attack = 0.15,
			impact = 0.15
		},
		default_target = {
			boost_curve_coefficient_headshot = 1,
			dot_template_name = "we_deus_01_dot",
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient = 0.75,
			attack_template = "arrow_carbine",
			power_distribution_near = {
				attack = 0.41,
				impact = 0.3
			},
			power_distribution_far = {
				attack = 0.3,
				impact = 0.25
			},
			range_dropoff_settings = carbine_dropoff_ranges
		},
		targets = {}
	}

	--dot damage profile
	DamageProfileTemplates.we_deus_01_dot = {
			is_dot = true,
			charge_value = "n/a",
			no_stagger_damage_reduction_ranged = true,
			no_stagger = true,
			cleave_distribution = {
				attack = 0.25,
				impact = 0.25
			},
			armor_modifier = {
				attack = {
					1.5,
					1.2,
					1.5,
					1.2,
					0.75,
					0.2
				},
				impact = {
					1,
					0.5,
					1,
					1,
					1,
					0
				}
			},
			default_target = {
				damage_type = "burninating",
				boost_curve_type = "tank_curve",
				boost_curve_coefficient = 0.2,
				attack_template = "light_blunt_tank",
				power_distribution = {
					attack = 0.07,
					impact = 0.05
				}
			},
			targets = {}
	}

	-- longer dot (buff {} is NOT needed)
	mod.add_buff_template("wood_elf", "we_deus_01_dot", {
		--dlc_settings.buff_templates
		duration = 2,
		name = "we_deus_01_dot",
		end_flow_event = "smoke",
		start_flow_event = "burn",
		death_flow_event = "burn_death",
		remove_buff_func = "remove_dot_damage",
		apply_buff_func = "start_dot_damage",
		update_start_delay = 0.75,
		time_between_dot_damages = 0.75,
		damage_type = "burninating",
		damage_profile = "we_deus_01_dot",
		update_func = "apply_dot_damage",
		perk = buff_perks.burning
	})

end

-- introducing damage_profiles in network lookup once
-- dot damage profile
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_dot"
NetworkLookup.damage_profiles["we_deus_01_dot"] = index

--base impact
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01"
NetworkLookup.damage_profiles["we_deus_01"] = index


-- not used from the main game

-- half charged shot Aoe
DamageProfileTemplates.we_deus_01_small_explosion = {
	charge_value = "aoe",
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			0,
			1,
			1,
			0.75,
			0
		}
	},
	default_target = {
		attack_template = "burning",
		dot_template_name = "we_deus_01_dot",
		damage_type = "burn",
		power_distribution = {
			attack = 0.1,
			impact = 0.2
		}
	},
	targets = {}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_small_explosion"
NetworkLookup.damage_profiles["we_deus_01_small_explosion"] = index

-- half charged shot Aoe glance
DamageProfileTemplates.we_deus_01_small_explosion_glance = {
	charge_value = "aoe",
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			0,
			1,
			1,
			0.75,
			0
		}
	},
	default_target = {
		attack_template = "burning",
		dot_template_name = "we_deus_01_dot",
		damage_type = "burn",
		power_distribution = {
			attack = 0.1,
			impact = 0.2
		}
	},
	targets = {}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_small_explosion_glance"
NetworkLookup.damage_profiles["we_deus_01_small_explosion_glance"] = index

-- full charged shot aoe
DamageProfileTemplates.we_deus_01_large_explosion = {
	charge_value = "aoe",
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0.25,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0
		}
	},
	default_target = {
		attack_template = "burning",
		dot_template_name = "we_deus_01_dot",
		damage_type = "burn",
		power_distribution = {
			attack = 0.25,
			impact = 0.5
		}
	},
	targets = {}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_large_explosion"
NetworkLookup.damage_profiles["we_deus_01_large_explosion"] = index

-- full charged shot aoe glance
DamageProfileTemplates.we_deus_01_large_explosion_glance = {
	charge_value = "aoe",
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0.25,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75,
			0
		}
	},
	default_target = {
		attack_template = "burning",
		dot_template_name = "we_deus_01_dot",
		damage_type = "burn",
		power_distribution = {
			attack = 0.25,
			impact = 0.5
		}
	},
	targets = {}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_large_explosion_glance"
NetworkLookup.damage_profiles["we_deus_01_large_explosion_glance"] = index


-- copied sourcecode (still in the code)
DLCSettings.morris.explosion_templates.we_deus_01_small = {
	explosion = {
		use_attacker_power_level = true,
		radius_min = 0.5,
		radius_max = 1,
		attacker_power_level_offset = 0.25,
		max_damage_radius_min = 0.1,
		damage_profile_glance = "we_deus_01_small_explosion_glance",
		max_damage_radius_max = 0.75,
		sound_event_name = "we_deus_01_big_hit",
		damage_profile = "we_deus_01_small_explosion",
		effect_name = "fx/wpnfx_we_deus_01_impact"
	}
}
DLCSettings.morris.explosion_templates.we_deus_01_large = {
	explosion = {
		use_attacker_power_level = true,
		radius_min = 1.25,
		sound_event_name = "we_deus_01_big_hit",
		radius_max = 3,
		attacker_power_level_offset = 0.25,
		max_damage_radius_min = 0.5,
		alert_enemies_radius = 10,
		damage_profile_glance = "we_deus_01_large_explosion_glance",
		max_damage_radius_max = 2,
		alert_enemies = true,
		damage_profile = "we_deus_01_large_explosion",
		effect_name = "fx/wpnfx_we_deus_01_explosion"
	}
}
DLCSettings.morris.buff_templates.we_deus_01_kerillian_critical_bleed_dot_disable = {
	buffs = {
		{
			name = "we_deus_01_kerillian_critical_bleed_dot_disable",
			perk = buff_perks.kerillian_critical_bleed_dot_disable
		}
	}
}


-- check if enabled
mod.check_old_mfb = function ()
	if mod.settings.enable_old_moonbow then mod:moonfirebow_changes() else mod:official_moonfirebow() end
end

-- check settings
function mod.apply_settings()
	mod:check_old_radiant()
	mod:check_old_mfb()
	mod:check_repel_sound()
end


-- run other files
dofile("scripts/mods/Classic Sister/sync_settings")


-- Chat Echo Enabled
local function updateValues()
	for _, buffs in pairs(TalentBuffTemplates) do
		table.merge_recursive(BuffTemplates, buffs)
	end

	return

end
mod.on_enabled = function (self)
	mod:echo("Classic Sister v0.0.4 enabled")
	updateValues()
end
