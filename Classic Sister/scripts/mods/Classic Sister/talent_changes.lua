local mod = get_mod("Classic Sister")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")


-- Works 5.4.2
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
mod:add_text("career_passive_desc_we_thornsister_a_OG", "Kerillian deals up to 50% more damage to wounded targets depending on their remaining health. For example, she does no extra damage against full health enemies, 25% extra against enemies at half health, etc.")


-- Works 5.4.2
-- Artharti's Delight Crits instead of Poison

mod:add_talent_buff_template("wood_elf", "kerillian_thorn_sister_big_bleed_classic_sister", {
    {
        event = "on_hit",
        bleed = "thorn_sister_big_bleed_classic_sister",
        buff_func = "thorn_sister_add_bleed_on_hit_classic_sister",
        proc_weight = 10,
    }
})
ProcFunctions.thorn_sister_add_bleed_on_hit_classic_sister = function (owner_unit, buff, params)
    --local player_unit = player.player_unit
    local hit_unit = params[1]
    local is_crit = params[6]
   
    if ALIVE[owner_unit] and ALIVE[hit_unit] and is_crit then -- not is crit
        local template = buff.template
        local bleed = template.bleed
        local buff_system = Managers.state.entity:system("buff_system")
        local career_extension = ScriptUnit.extension(owner_unit, "career_system")
        local power_level = career_extension:get_career_power_level()
        local target_buff_extension = ScriptUnit.has_extension(hit_unit, "buff_system")

        if not target_buff_extension then -- or not target_buff_extension:has_buff_perk(buff_perks.poisoned) then
            return false
        end

        local buff_params = {
            power_level = power_level,
            attacker_unit = owner_unit
        }

        buff_system:add_buff_synced(hit_unit, bleed, BuffSyncType.LocalAndServer, buff_params)
    end
    
end
mod:add_talent_buff_template ("wood_elf", "thorn_sister_big_bleed_classic_sister", {
    {
        damage_profile = "bleed",
        name = "thorn_sister_big_bleed_classic_sister",
        duration = 5,
        refresh_durations = true,
        --update_start_delay = 0.75,
        apply_buff_func = "start_dot_damage",
        time_between_dot_damages = 0.75,
        hit_zone = "neck",
        max_stacks = 5, --3
        update_func = "apply_dot_damage",
        perk = buff_perks.bleeding
    }
})
mod:modify_talent("we_thornsister", 2, 2, {
	name = "athartis_delight_name",
    description = "athartis_delight_desc",
    buffer = "server",
    icon = "kerillian_thornsister_crit_big_bleed",
 	buffs = {
 	    "kerillian_thorn_sister_big_bleed_classic_sister"
    }
})
mod:add_text("athartis_delight_name", "Artharti's Delight")
mod:add_text("athartis_delight_desc", "Critical Strikes make the target Bleed.")



-- Works 5.4.2
-- Isha's Bounty instead of Briar's Malice

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
ProcFunctions.add_buff_on_proc_thorn = function (owner_unit, buff, params)
    --local player_unit = player.player_unit

    if ALIVE[owner_unit] then
        local buff_extension = ScriptUnit.extension(owner_unit, "buff_system") --HT
        local template = buff.template --HT
        local buff_to_add = template.buff_to_add --HT
		buff_extension:add_buff(buff_to_add) --HT
    end
end
mod:modify_talent("we_thornsister", 2, 3, {
	name = "ishas_bounty_name",
	description = "ishas_bounty_desc",
    buffer = "both",
	num_ranks = 1,
	icon = "kerillian_thornsister_power_on_health_gain",
	buffs = {
		"kerillian_power_on_health_gain"
	}
})
mod:add_text("ishas_bounty_name", "Isha's Bounty")
mod:add_text("ishas_bounty_desc", "Gaining health grants 5%% Power for 8 seconds. Stacks up to 3 times.")



-- Works 5.4.2
-- Hekarti's Cruel Bargain instead of Bonded Spirit 

BuffTemplates.kerillian_thorn_sister_reduce_passive_on_elite = {
    buffs = {
        {
            event = "on_elite_killed",
            time_removed_per_kill = 1,
            buff_func = "kerillian_thorn_sister_reduce_passive_on_elite_new",
        }
    }
}
ProcFunctions.kerillian_thorn_sister_reduce_passive_on_elite_new = function (owner_unit, buff, params)
    --local player_unit = player.player_unit

    if ALIVE[owner_unit] then
        local career_extension = ScriptUnit.extension(owner_unit, "career_system")
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
    buffer = "both",
	num_ranks = 1,
	icon = "kerillian_thornsister_reduce_passive_on_elite",
	buffs = {
		"kerillian_thorn_sister_reduce_passive_on_elite"
	}
})
mod:add_text("hekartis_cruel_bargain_name", "Hekarti's Cruel Bargain")
mod:add_text("hekartis_cruel_bargain_desc", "For each Elite enemy slain near Kerillian, the cooldown of Radiance decreases by 1 seconds.")



-- Works 5.4.2
-- Radiant Inheritance (for Sister only)

mod.check_old_radiant = function ()
	if mod.settings.enable_old_radiant then
		
        mod:add_text("kerillian_thorn_radiants_desc", "Consuming Radiance grants Kerillian vastly increased combat potency for 15 seconds.")
        
	else
	
        mod:add_text("kerillian_thorn_radiants_desc", "Consuming Radiance grants Kerillian 20%% extra attack speed, move speed, power and crit power for 10 seconds.")
        
	end
end

--Change Talent 
mod:add_text("kerillian_thorn_radiants_name", "Radiant Inheritance")
mod:modify_talent("we_thornsister", 4, 3, {
	num_ranks = 1,
	name = "kerillian_thorn_radiants_name",
	description = "kerillian_thorn_radiants_desc",
	buffer = "client",
	icon = "kerillian_thornsister_avatar",
	buffs = {
		"kerillian_thorn_radiant"
	}
})

-- Buff Talent (change buff_func)
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_radiant", {
    {
		name = "kerillian_thorn_radiant",
        event_buff = true,
		buff_func = "add_buff_sister",
		event = "on_extra_ability_consumed",
	}
})

--Buff talent function
ProcFunctions.add_buff_sister = function (owner_unit, buff, params)
	--local player_unit = player.player_unit

	if ALIVE[owner_unit] then
		local buff_name = nil
		if mod.settings.enable_old_radiant then
			buff_name = "kerillian_thorn_active_old_radiant_1_cs"
		else
			buff_name = "kerillian_thorn_active_radiant_1_cs"
		end
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
		local network_manager = Managers.state.network
		local network_transmit = network_manager.network_transmit
		local unit_object_id = network_manager:unit_game_object_id(owner_unit)
		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

		if Managers.player.is_server then
			buff_extension:add_buff(buff_name, {
				attacker_unit = owner_unit
			})
			network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
		else
			network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
		end
	end
end

-- Post First Nerf Radiant (Pre Rework)
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

-- Release Radiant
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
				--crit chance
				name = "kerillian_thorn_active_old_radiant_4_cs",
				refresh_duration = true,
				bonus = 0.2,
				duration = 15,
				stat_buff = "critical_strike_chance",
				max_stacks = 1
			},
			{
				--attack speed
				name = "kerillian_thorn_active_old_radiant_5_cs",
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
			}
		}
}

local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "kerillian_thorn_active_old_radiant_1_cs"
NetworkLookup.buff_templates["kerillian_thorn_active_old_radiant_1_cs"] = index



-- AMMO REFUND BUGGED WITH 5.2 or 5.3
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
    --local player_unit = owner_unit

    if ALIVE[owner_unit] then
        local template = buff.template
        local timer_buff_to_add = template.timer_buff
        local buff_to_add = template.buff_to_add
        local t = params.t
        local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

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

                buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)

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
        event = "on_ammo_used",
        perk = {
            buff_perks.infinite_ammo,
        },
        --amount_to_heal = 3,
    },
})

-- prob doesnt work
mod:add_talent_buff_template("wood_elf", "kerilliand_thorn_free_ammo_test", {
    {
        event = "on_ammo_used",
        max_stacks = 1,
        priority_buff = true,
        remove_on_proc = true,
        buff_func = "dummy_function",
        perk = {
            buff_perks.infinite_ammo,
        },
    }
})
ProcFunctions.kerillian_thorn_sister_add_buff_remove_new = function (owner_unit, buff, params)
    --local player_unit = player.player_unit

    if ALIVE[owner_unit] then
        local buff_to_add = buff.template.buff_to_add
        local buff_system = Managers.state.entity:system("buff_system")

        buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)

        local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

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
ProcFunctions.kerillian_thorn_restore_health_on_ranged_hit = function (owner_unit, buff, params)
    --local player_unit = player.player_unit
    local attack_type = params[7]

    if ALIVE[owner_unit] and attack_type and (attack_type == "projectile" or attack_type == "instant_projectile") then
        if Managers.state.network.is_server then
            local side = Managers.state.side.side_by_unit[owner_unit]
            local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
            local amount_to_heal = buff.template.amount_to_heal

            for i = 1, #player_and_bot_units, 1 do
                DamageUtils.heal_network(player_and_bot_units[i], owner_unit, amount_to_heal, "career_passive")
            end
        end

        local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

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
mod:add_text("the_pales_queen_choosing_desc", "(ammo refund bugged) Every 8 seconds, Kerillian's next Ranged Attack consumes no resource and restores 3 permanent health.")



-- Works 5.4.2
-- Morai-Heg's Doomsight instead of Lingering Blackvenom

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
ProcFunctions.remove_ref_buff_stack_woods = function (owner_unit, buff, params)
    --local player_unit = player.player_unit

    if ALIVE[owner_unit] then
        local buff_template = buff.template
        local buff_name = buff_template.buff_to_remove
        local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
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
            buff_to_add = "kerillian_thorn_sister_crit_on_any_ability_buff",
            event = "on_ability_activated",
            buff_func = "add_buff_reff_buff_stack",
            max_stacks = 1,
            reference_buff = "kerillian_thorn_sister_crit_on_any_ability_handler"
        }
    }
}
ProcFunctions.add_buff_reff_buff_stack = function (owner_unit, buff, params)
    --local player_unit = player.player_unit
    --local triggering_unit = params[1] (4.6)

    if ALIVE[owner_unit] then -- and triggering_unit == player_unit (4.6)
        local template = buff.template
        local buff_name = template.buff_to_add
        local amount_to_add = template.amount_to_add
        local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

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
    buffer = "both",
	num_ranks = 1,
	icon = "kerillian_thornsister_crit_on_any_ability",
	buffs = {
		"kerillian_thorn_sister_crit_on_any_ability",
        "kerillian_thorn_sister_crit_on_any_ability_handler",
	}
})
mod:add_text("moraihegs_doomsight_name", "Morai-Heg's Doomsight")
mod:add_text("moraihegs_doomsight_desc", "Gain 3 guaranteed Critical Strikes each time a career skill is used.")



-- Works 5.4.2
-- Repel (deactivate sound effect) Credits to Isaakk for not needing to restart anymore 
mod.check_repel_sound = function ()

	if mod.settings.disable_repel_sound then
		
        BuffTemplates.kerillian_thorn_sister_big_push_buff.activation_sound  = nil
	
	else
		
        BuffTemplates.kerillian_thorn_sister_big_push_buff.activation_sound  = "career_ability_kerilian_push"

	end
end


