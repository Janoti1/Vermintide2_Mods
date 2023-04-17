local mod = get_mod("Handmaiden Adjust")

-- Text Localization
local _language_id = Application.user_setting("language_id")
local _localization_database = {}
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

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
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end
function mod.set_talent(self, career_name, tier, index, talent_name, talent_data)
    local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
    local talent_tree_index = career_settings.talent_tree_index
    
    local talent_lookup = TalentIDLookup[talent_name]
    local talent_id
    if talent_lookup == nil then
        talent_id = #Talents[hero_name] + 1
    else
        talent_id = talent_lookup.talent_id
    end

    Talents[hero_name][talent_id] = merge({
        name = talent_name,
        description = talent_name .. "_desc",
        icon = "icons_placeholder",
        num_ranks = 1,
        buffer = "both",
        requirements = {},
        description_values = {},
        buffs = {},
        buff_data = {},
    }, talent_data)
    TalentTrees[hero_name][talent_tree_index][tier][index] = talent_name
    TalentIDLookup[talent_name] = {
        talent_id = talent_id,
        hero_name = hero_name
    }
    -- mod:echo("-----------------------")
    -- mod:echo("Buff: " .. dump(talent_data.buffs))
    -- mod:echo("Talent lookup for " .. hero_name .. ": " .. talent_name .. " => " .. talent_id)
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
function mod.add_buff_template_moonfire_dot(self, buff_name, buff_data, extra_data)
    local new_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_buff = merge(new_buff, extra_data)
    end
    BuffTemplates[buff_name] = new_buff
    local index = 1500
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


-- Notes:
-- Talents: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/064cf98cc8aac0d16c80182b1a7c618d0a7dcc1f/scripts/managers/talents/talent_settings_kerillian.lua
-- Buff_funcs: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/ac775f9d098f928afdfa8988fca5c347e7c4fe7b/scripts/unit_extensions/default_player_unit/buffs/buff_templates.lua
-- Base Career settings: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/a9df32390ce62b9816b7a4c1ce1dfc9982e76a28/scripts/settings/profiles/career_settings.lua
-- Career Abillities: https://github.com/Aussiemon/Vermintide-2-Source-Code/tree/064cf98cc8aac0d16c80182b1a7c618d0a7dcc1f/scripts/unit_extensions/default_player_unit/careers
-- Perks: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/03e04b0fc66e8d868a08201718aaa579a771f23d/scripts/unit_extensions/default_player_unit/careers/career_ability_settings.lua#L351


-- TalentBuffTemplates dont need the buff brakets but one additional layer of brakets, BuffTemplates do, modify talent doesnt need any additional layers
-- https://docs.google.com/document/d/1PChRYF3b6oKavkZpBSNFizJn_VfdCccHomhoQ6wLuHw/edit




-----------------------
-- Base Stats
-----------------------

-- Base Health from 125 to 150
CareerSettings.we_maidenguard.attributes.max_hp = 150 --125




-----------------------
-- Ultimate Abillity
-----------------------

-- Dashing now grants Handmaiden free Walk for 3 sec
mod:add_talent_buff_template("wood_elf", "no_clip_dash_handmaiden_adjust", {
    {
        refresh_durations = true,
        remove_buff_func = "kerillian_shade_noclip_off",
        max_stacks = 1,
        icon = "kerillian_maidenguard_activated_ability",
        apply_buff_func = "kerillian_shade_noclip_on",
        duration = 3
    }
})
--kerillian_maidenguard_activated_ability_cooldown (cool icon not in use I think)




-----------------------
-- Perks
-----------------------

-- Renewal
-- Aura range increased from 5 to 15
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_passive_stamina_regen_aura", {
    buff_to_add = "kerillian_maidenguard_passive_stamina_regen_buff",
    update_func = "activate_buff_on_distance",
    remove_buff_func = "remove_aura_buff",
    range = 15 --5
})


-- Ariel's Benison (Healing is gone, DR?)
-- Change: Now instead of healing, revived allies receive 50% DR for 15 sec. 
-- Original: Increase Kerillian's revive speed by 50%. When Kerillian revives allies, she heals them for 20 health.
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_insta_ress", {
    {
        stat_buff = "faster_revive",
        buff_func = "buff_defence_on_revived_target",
        event = "on_revived_ally",
        refresh_durations = true,
        buff_to_add = {
            "defense_on_revived_target_handmaiden_adjust"
        }
    }
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_ress_time", {
    {
        multiplier = -0.5,
        stat_buff = "faster_revive",
        buff_func = "buff_defence_on_revived_target",
        event = "on_revived_ally",
        refresh_durations = true,
        buff_to_add = {
            "defense_on_revived_target_handmaiden_adjust"
        }
    }
})
mod:add_talent_buff_template("wood_elf", "defense_on_revived_target_handmaiden_adjust", {
    {
        priority_buff = true,
        refresh_durations = true,
        stat_buff = "damage_taken",
        max_stacks = 1,
        icon = "sienna_unchained_buff_defense_on_revived_target",
        dormant = true,
        duration = 10,
		multiplier = -0.5
    }
})


-- Change Description
PassiveAbilitySettings.we_2 = {
    description = "career_passive_desc_we_2a_2",
    display_name = "career_passive_name_we_2",
    icon = "kerillian_maidenguard_passive",
    buffs = {
        "kerillian_maidenguard_passive_dodge",
        "kerillian_maidenguard_passive_dodge_speed",
        "kerillian_maidenguard_passive_stamina_regen_aura",
        "kerillian_maidenguard_passive_increased_stamina",
        "kerillian_maidenguard_ress_time",
        "kerillian_maidenguard_ability_cooldown_on_hit",
        "kerillian_maidenguard_ability_cooldown_on_damage_taken"
    },
    perks = {
        {
            display_name = "career_passive_name_we_2b",
            description = "career_passive_desc_we_2b_2"
        },
        {
            display_name = "career_passive_name_we_2c",
            description = "career_passive_desc_we_2c_2"
        }
    }
}
ActivatedAbilitySettings.we_2 = {
    {
        description = "career_active_desc_we_2_2",
        display_name = "career_active_name_we_2",
        cooldown = 20,
        icon = "kerillian_maidenguard_activated_ability",
        ability_class = CareerAbilityWEMaidenGuard
    }
}
mod:add_text("career_passive_desc_we_2c_2", "Increase Kerillian's revive speed by 50%. When Kerillian revives allies, she grants 50% damage reduction for 15 seconds.")
mod:add_text("career_active_desc_we_2_2", "Kerillian swiftly dashes forward, moving through enemies, which allows her to pass through enemies for 3 seconds.")




-----------------------
-- Talents
-----------------------

-- Bloodlust --> Vanguard
-- Change: Stagger THP
-- Original: Melee killing blows restore temporary health based on the health of the slain enemy.
local tourneybalance = get_mod("TourneyBalance")
mod.vanguard_check = function()
    if not tourneybalance then
        mod:add_buff_template("rebaltourn_vanguard", {
            multiplier = 1,
            name = "vanguard",
            event_buff = true,
            buff_func = "rebaltourn_heal_stagger_targets_on_melee",
            event = "on_stagger",
            perk = "tank_healing"
        })
        
        mod:add_proc_function("rebaltourn_heal_stagger_targets_on_melee", function (owner_unit, buff, params)
            if not Managers.state.network.is_server then
                return
            end
        
            if ALIVE[owner_unit] then
                local hit_unit = params[1]
                local damage_profile = params[2]
                local attack_type = damage_profile.charge_value
                local stagger_value = params[6]
                local stagger_type = params[4]
                local buff_type = params[7]
                local target_index = params[8]
                local breed = AiUtils.unit_breed(hit_unit)
                local multiplier = buff.multiplier
                local is_push = damage_profile.is_push
                local stagger_calulation = stagger_type or stagger_value
                local heal_amount = stagger_calulation * multiplier --stagger_value * multiplier
                local death_extension = ScriptUnit.has_extension(hit_unit, "death_system")
                local is_corpse = death_extension.death_is_done == false
        
                if is_push then
                    heal_amount = 0.6
                end
                
                local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
                local equipment = inventory_extension:equipment()
                local slot_data = equipment.slots.slot_melee
            
                if slot_data then
                    local item_data = slot_data.item_data
                    local item_name = item_data.name
                    if item_name == "wh_2h_billhook" and heal_amount == 9 then
                        heal_amount = 2
                    end
                     if item_name == "bw_flame_sword" and attack_type == "heavy_attack" and heal_amount == 1 then
                        heal_amount = 2
                     end
                end
        
                if target_index and target_index < 5 and breed and not breed.is_hero and (attack_type == "light_attack" or attack_type == "heavy_attack" or attack_type == "action_push") and not is_corpse then
                    DamageUtils.heal_network(owner_unit, owner_unit, heal_amount, "heal_from_proc")
                end
            end
        end)

        mod:add_text("vanguard_name", "Vanguard")
    end
end
mod:vanguard_check()
mod:modify_talent("we_maidenguard", 1, 2, {
    name = "vanguard_name",
    description = "vanguard_desc",
    buffs = {
        "rebaltourn_vanguard"
    }
})



-- Focused Spirit (Works)
-- Change: 15/20/25% Damage at 50/65/80% Health.
-- Original: After not taking damage for 10 seconds, increases Kerillian's power by 15.0%. Reset upon taking damage.

mod:modify_talent("we_maidenguard", 2, 1, {
    name = "focused_spirit_name",
    description = "focused_spirit_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_power_level_on_unharmed",
    buffs = {
        "focused_spirit_update",
    }
})
mod:add_text("focused_spirit_name", "Focused Spirit")
mod:add_text("focused_spirit_desc", "While above 50%% health Kerillian gains 10%% increased weapon damage. Stacks 3 times (at 65%% and 80%% health).")

mod:add_talent_buff_template("wood_elf", "focused_spirit_update", {
    {
        buff_to_add = "focused_spirit_damage_dealt_buff",
        update_func = "update_server_buff_on_health_percent_handmaiden_adjust",
        remove_buff_func = "remove_server_buff_on_health_percent_handmaiden_adjust",
        update_frequency = 0.2
    }
})
mod:add_talent_buff_template("wood_elf", "focused_spirit_damage_dealt_buff", {
    {
        max_stacks = 3,
        icon = "kerillian_maidenguard_power_level_on_unharmed",
        stat_buff = "increased_weapon_damage",
        multiplier = 0.10
    }
})
BuffFunctionTemplates.functions.update_server_buff_on_health_percent_handmaiden_adjust = function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    if ALIVE[owner_unit] then
        local health_extension = ScriptUnit.has_extension(owner_unit, "health_system")

        if health_extension then
            local max_health = health_extension:get_max_health()
            local health_threshold = buff.template.threshold
            local current_health = health_extension:current_health()
            local buff_to_add = buff.template.buff_to_add

            local health_threshold1 = 0.5
            local health_threshold2 = 0.65
            local health_threshold3 = 0.8

            if current_health > max_health * health_threshold1 and not buff.has_buff1 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff.has_buff1 = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
            elseif current_health <= max_health * health_threshold1 and buff.has_buff1 then
                local buff_system = Managers.state.entity:system("buff_system")

                buff_system:remove_server_controlled_buff(owner_unit, buff.has_buff1)

                buff.has_buff1 = nil
            end

            if current_health >= max_health * health_threshold2 and not buff.has_buff2 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff.has_buff2 = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
            elseif current_health < max_health * health_threshold2 and buff.has_buff2 then
                local buff_system = Managers.state.entity:system("buff_system")

                buff_system:remove_server_controlled_buff(owner_unit, buff.has_buff2)

                buff.has_buff2 = nil
            end

            if current_health >= max_health * health_threshold3 and not buff.has_buff3 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff.has_buff3 = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
            elseif current_health < max_health * health_threshold3 and buff.has_buff3 then
                local buff_system = Managers.state.entity:system("buff_system")

                buff_system:remove_server_controlled_buff(owner_unit, buff.has_buff3)

                buff.has_buff3 = nil
            end
        end
    end
end
BuffFunctionTemplates.functions.remove_server_buff_on_health_percent_handmaiden_adjust = function (owner_unit, buff, params)

    if ALIVE[owner_unit] and buff.has_buff then
        local buff_system = Managers.state.entity:system("buff_system")

        buff_system:remove_server_controlled_buff(owner_unit, buff.has_buff)

        buff.has_buff = nil
    end
end




-- Oak Stance (crash when swapping your ranged weapon)
-- Change: Max 15% crit chance, scales with stamina %
-- Original: Increases critical strike chance by 5.0%.

mod:modify_talent("we_maidenguard", 2, 2, {
    name = "oak_stance_name",
    description = "oak_stance_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_damage_reduction_on_last_standing",
    buffs = {
        "oak_stance_update",
    }
})
mod:add_text("oak_stance_name", "Oak Stance")
mod:add_text("oak_stance_desc", "While above 50%% stamina Kerillian gains 5%% crit chance. Stacks 3 times (at 65%% and 80%% stamina).")
mod:add_talent_buff_template("wood_elf", "oak_stance_update", {
    {
        buff_to_add = "oak_stance_crit_chance_buff",
        update_func = "crit_chance_for_stamina_handmaiden_adjust",
        remove_buff_func = "remove_server_buff_on_stamina_percent_handmaiden_adjust",
        update_frequency = 0.2
    }
})
mod:add_talent_buff_template("wood_elf", "oak_stance_crit_chance_buff", {
    {
        max_stacks = 3,
        icon = "kerillian_maidenguard_damage_reduction_on_last_standing",
        stat_buff = "critical_strike_chance",
        bonus = 0.05
    }
})
-- Check how much stamina hanmaiden has and add 1 to 3 stacks according to it
BuffFunctionTemplates.functions.crit_chance_for_stamina_handmaiden_adjust = function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    if ALIVE[owner_unit] then
        local status_extension = ScriptUnit.has_extension(owner_unit, "status_system")
        local max_fatigue = status_extension:get_current_max_fatigue_points_handmaiden_adjust()

        if status_extension and max_fatigue then

            local buff_to_add = buff.template.buff_to_add
            local current_fatigue = status_extension:current_fatigue_points()

            local fatigue_80 = max_fatigue * 0.2
            local fatigue_65 = max_fatigue * 0.35
            local fatigue_50 = max_fatigue * 0.5

            if current_fatigue < fatigue_80 and not buff.has_buff1 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff.has_buff1 = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
            elseif current_fatigue >= fatigue_80 and buff.has_buff1 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff_system:remove_server_controlled_buff(owner_unit, buff.has_buff1)
                buff.has_buff1 = nil
            end

            if current_fatigue <= fatigue_65 and not buff.has_buff2 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff.has_buff2 = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
            elseif current_fatigue >= fatigue_65 and buff.has_buff2 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff_system:remove_server_controlled_buff(owner_unit, buff.has_buff2)
                buff.has_buff2 = nil
            end

            if current_fatigue <= fatigue_50 and not buff.has_buff3 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff.has_buff3 = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
            elseif current_fatigue >= fatigue_50 and buff.has_buff3 then
                local buff_system = Managers.state.entity:system("buff_system")
                buff_system:remove_server_controlled_buff(owner_unit, buff.has_buff3)
                buff.has_buff3 = nil
            end
        end
    end
end
-- recieve stamina data without sending stamina data when ranged weapon is equipped
GenericStatusExtension.get_current_max_fatigue_points_handmaiden_adjust = function (self)
	local inventory_extension = self.inventory_extension
	local slot_name = inventory_extension:get_wielded_slot_name()
	local slot_data_name = inventory_extension:get_slot_data(slot_name)
    local weapon_slot_melee = "slot_melee"
    local weapon_slot_ranged = "slot_ranged"
    local get_wielded_slot_name = inventory_extension:get_wielded_slot_name()

    if slot_data_name and get_wielded_slot_name == weapon_slot_melee then
            local item_data = slot_data_name.item_data
            local item_template = slot_data_name.item_template or BackendUtils.get_item_template(item_data)
            local max_fatigue_points = item_template.max_fatigue_points
            max_fatigue_points = max_fatigue_points and math.clamp(self.buff_extension:apply_buffs_to_value(max_fatigue_points, "max_fatigue"), 1, 100)
            
            return max_fatigue_points

        else if slot_data_name and get_wielded_slot_name == weapon_slot_ranged then
            local item_data = slot_data_name.item_data
            local item_template = slot_data_name.item_template or BackendUtils.get_item_template(item_data)
            local max_fatigue_points = item_template.max_fatigue_points
            max_fatigue_points = 10
            
            return max_fatigue_points
        end
    end
end
BuffFunctionTemplates.functions.remove_server_buff_on_stamina_percent_handmaiden_adjust = function (owner_unit, buff, params)

    if ALIVE[owner_unit] and buff.has_buff then
        local buff_system = Managers.state.entity:system("buff_system")

        buff_system:remove_buff(owner_unit, buff.has_buff)

        buff.has_buff = nil
    end
end





-- Asrai Alacrity (working)
-- Change: After push: 30% AS 10% Power 30% HS bonus 4 stacks 
-- Original: Blocking an attack or pushing an enemy grants the next two strikes 30% attack speed and 10% power. The buff lasts indefinitely, but does not stack. The buff is applied to any melee or ranged attack that hits an enemy. However, the buff is only consumed when hitting an enemy with a melee attack, or hitting a Skaven Special with a ranged attack.

mod:modify_talent("we_maidenguard", 2, 3, {
	name = "asrai_alacrity_name",
    description = "asrai_alacrity_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_improved_dodge",
 	buffs = {
 	    "kerillian_maidenguard_speed_on_block_handmaiden_adjust",
        "kerillian_maidenguard_speed_on_push_handmaiden_adjust"
    }
})
mod:add_text("asrai_alacrity_name", "Asrai Alacrity")
mod:add_text("asrai_alacrity_desc", "Blocking an attack or pushing an enemy grants the next 4 strikes 30%% attack speed and 10%% power and 30%% headshot bonus damage.")

-- Add 4 Stacks when Blocking
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block_handmaiden_adjust", {
    {
        buff_to_add = "kerillian_maidenguard_speed_on_block_dummy_buff",
        max_stacks = 1,
        buff_func = "maidenguard_add_power_buff_on_block_handmaiden_adjust",
        event = "on_block",
        update_func = "maidenguard_attack_speed_on_block_update_handmaiden_adjust",
        amount_to_add = 4, --2
        max_sub_buff_stacks = 4, --2
        stat_increase_buffs = {
            "kerillian_maidenguard_speed_on_block_buff",
            "kerillian_maidenguard_power_on_block_buff",
            "kerillian_maidenguard_hs_power_on_block_buff"
        }
	}
})
-- Add 4 Stacks when Pushing
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_push_handmaiden_adjust", {
    {
        buff_to_add = "kerillian_maidenguard_speed_on_block_dummy_buff",
        max_stacks = 1,
        buff_func = "maidenguard_add_power_buff_on_block_handmaiden_adjust",
        event = "on_push",
        update_func = "maidenguard_attack_speed_on_block_update_handmaiden_adjust",
        amount_to_add = 4, --2
        max_sub_buff_stacks = 4, --2
        stat_increase_buffs = {
            "kerillian_maidenguard_speed_on_block_buff",
            "kerillian_maidenguard_power_on_block_buff",
            "kerillian_maidenguard_hs_power_on_block_buff",
            "kerillian_maidenguard_power_on_blocked_attacks_remove_damage"
        }
    }
})
-- Remove 1 Stack when "dealing damage"
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_power_on_blocked_attacks_remove_damage", {
    {
        max_stacks = 1,
        chunk_size = 1,
        buff_to_remove = "kerillian_maidenguard_speed_on_block_dummy_buff",
        buff_func = "maidenguard_remove_on_block_speed_buff",
        event = "on_damage_dealt",
        reference_buffs = {
            "kerillian_maidenguard_speed_on_block_handmaiden_adjust",
            "kerillian_maidenguard_speed_on_push_handmaiden_adjust"
        }
    }
})
-- Icon and max_stacks save
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block_dummy_buff", {
    {
        max_stacks = 4, --2
        icon = "kerillian_maidenguard_improved_dodge"
    }
})
-- Attack Speed (30%)
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block_buff", {
    {
        max_stacks = 1,
        stat_buff = "attack_speed",
        multiplier = 0.3
    }
})
-- Power (10%)
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_power_on_block_buff", {
    {
        max_stacks = 1,
        stat_buff = "power_level",
        multiplier = 0.1
    }
})
-- Headshot Damage (30%)
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_hs_power_on_block_buff", {
    {
        max_stacks = 1,
        stat_buff = "headshot_multiplier",
        multiplier = 0.3
    }
})
-- Add Buff function (unchanged)
ProcFunctions.maidenguard_add_power_buff_on_block_handmaiden_adjust = function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    local template = buff.template

    if ALIVE[owner_unit] then
        local buff_to_add = template.buff_to_add
        local buff_system = Managers.state.entity:system("buff_system")

        if not buff.buff_list then
            buff.buff_list = {}
        end

        local amount_to_add = template.amount_to_add

        for i = 1, amount_to_add do
            local num_buff_list = #buff.buff_list
            local max_sub_buff_stacks = template.max_sub_buff_stacks

            if num_buff_list < max_sub_buff_stacks then
                buff.buff_list[num_buff_list + 1] = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
            end
        end
    end
end
-- Remove buff stacks function (unchanged)
BuffFunctionTemplates.functions.maidenguard_attack_speed_on_block_update_handmaiden_adjust = function (unit, buff, params)
    if Unit.alive(unit) then
        local template = buff.template
        local buff_extension = ScriptUnit.extension(unit, "buff_system")
        local stat_increase_buffs = template.stat_increase_buffs
        local activation_buff = template.buff_to_add

        for i = 1, #stat_increase_buffs do
            local stat_increase_buff = stat_increase_buffs[i]
            local has_activation_buff = buff_extension:has_buff_type(activation_buff)
            local applied_stat_increase_buff = buff_extension:get_non_stacking_buff(stat_increase_buff)

            if has_activation_buff then
                if not applied_stat_increase_buff then
                    buff_extension:add_buff(stat_increase_buff)
                end
            elseif applied_stat_increase_buff then
                buff_extension:remove_buff(applied_stat_increase_buff.id)
            end
        end
    end
end




-- Willow Stance (works)
-- Change: 5% Attack Speed on Dodge; 4 Stacks
-- Original: 5% Attack Speed on dodge; 3 Stacks

mod:modify_talent("we_maidenguard", 4, 1, {
	name = "willow_stance_name",
    description = "willow_stance_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_passive_attack_speed_on_dodge",
 	buffs = {
 	    "kerillian_maidenguard_passive_attack_speed_on_dodge_handmaiden_adjust"
    }
})
mod:add_text("willow_stance_name", "Willow Stance")
mod:add_text("willow_stance_desc", "Dodging grants 5.0%% attack speed for 6 seconds. Stacks up to 4 times.")
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_passive_attack_speed_on_dodge_handmaiden_adjust", {
    {
        event = "on_dodge",
        buff_to_add = "kerillian_maidenguard_passive_attack_speed_on_dodge_handmaiden_adjust_buff",
        buff_func = "add_buff"
    }
})
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_passive_attack_speed_on_dodge_handmaiden_adjust_buff", {
    {
        refresh_durations = true,
        icon = "kerillian_maidenguard_passive_attack_speed_on_dodge",
        stat_buff = "attack_speed",
        max_stacks = 4, --3
		multiplier = 0.05,
		duration = 6
    }
})




-- Dance of Blades -> (Dance of Seasons) (Works)
-- Change: Holding block grants infinite dodge count. Dodging while not blocking grants 30% DR for 2 sec
-- Original: Dodging while blocking increases dodge range by 20%. Dodging while not blocking increases Kerillian's power by 10% for 2 seconds.

mod:modify_talent("we_maidenguard", 4, 2, {
    name = "dance_of_seasons_name",
    description = "dance_of_seasons_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_cooldown_on_nearby_allies",
    buffs = {
        "dance_of_seasons"
    }
})
mod:add_text("dance_of_seasons_name", "Dance of Blades")
mod:add_text("dance_of_seasons_desc", "Dodging while blocking grants infinite dodges for 2 seconds. Dodging while not blocking grants 30%% damage reduction for 2 seconds.")

-- Overarching Buff Handler
mod:add_talent_buff_template("wood_elf", "dance_of_seasons", {
    {
        event = "on_dodge",
        attack_buff_to_add = "dance_of_seasons_no_block",
        buff_func = "maidenguard_footwork_buff_handmaiden_adjust",
        dodge_buffs_to_add = {
            "dance_of_seasons_block"
        }
    }
})
-- Add Infinite Dodges when blocking and dodging
mod:add_talent_buff_template("wood_elf", "dance_of_seasons_block", {
    {
        buff_func = "maidenguard_footwork_buff_handmaiden_adjust",
        perk = buff_perks.infinite_dodge,
        refresh_durations = true,
        icon = "kerillian_maidenguard_activated_ability_cooldown",
        duration = 2,
        max_stacks = 1
    }
})
-- Add 25% Damage Reduction on Dodging without Blocking
mod:add_talent_buff_template("wood_elf", "dance_of_seasons_no_block", {
    {
        stat_buff = "damage_taken",
        refresh_durations = true,
        multiplier = -0.3,
        max_stacks = 1,
        icon = "kerillian_maidenguard_cooldown_on_nearby_allies",
        duration = 2
    }
})
-- Add Buff func
ProcFunctions.maidenguard_footwork_buff_handmaiden_adjust = function (owner_unit, buff, params)
    if ALIVE[owner_unit] then
        local status_extension = ScriptUnit.has_extension(owner_unit, "status_system")
        local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")
        local buff_template = buff.template

        if status_extension.blocking then
            local buffs_to_add = buff_template.dodge_buffs_to_add

            for i = 1, #buffs_to_add do
                local buff_to_add = buffs_to_add[i]

                buff_extension:add_buff(buff_to_add)
            end
        else
            local buff_to_add = buff_template.attack_buff_to_add
            local network_manager = Managers.state.network
            local network_transmit = network_manager.network_transmit
            local unit_object_id = network_manager:unit_game_object_id(owner_unit)
            local buff_template_name_id = NetworkLookup.buff_templates[buff_to_add]

            if unit_object_id then
                if Managers.state.network.is_server then
                    buff_extension:add_buff(buff_to_add, {
                        attacker_unit = owner_unit
                    })
                else
                    network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
                end
            end
        end
    end
end




-- Wraith Walk --> Wraith Pact (Works)
-- Change: Reduce dodge distance by 30%, Increases Power by 15%, gains 20% DR
-- Original: Kerillian's dodges can now pass through enemies.

mod:modify_talent("we_maidenguard", 4, 3, {
    name = "wraith_pact_name",
    description = "wraith_pact_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_passive_noclip_dodge",
    buffs = {
        "wraith_pact_power",
        "wraith_pact_damage_reduction",
        "wraith_pact_dodge_distance_buff",
        "wraith_pact_dodge_distance_speed_buff"

    }
})
mod:add_text("wraith_pact_name", "Wraith Pact")
mod:add_text("wraith_pact_desc", "Reduce dodge distance by 35%%. Gain 15%% Power and 20%% Damage Reduction.")

-- Add 15% Power
mod:add_talent_buff_template("wood_elf", "wraith_pact_power", {
    {
        max_stacks = 1,
        buff_func = "add_buff",
        stat_buff = "power_level",
        multiplier = 0.15
    }
})
-- Add 20% DR
mod:add_talent_buff_template("wood_elf", "wraith_pact_damage_reduction", {
    {
        max_stacks = 1,
        buff_func = "add_buff",
        stat_buff = "damage_taken",
        multiplier = -0.2
    }
})
-- Remove 35% Dodge Distance (from the buffed hanmaiden distance)
mod:add_talent_buff_template("wood_elf", "wraith_pact_dodge_distance_buff", {
    {
        multiplier = 0.65, -- 1
        remove_buff_func = "remove_movement_buff",
        apply_buff_func = "apply_movement_buff",
        path_to_movement_setting_to_modify = {
            "dodging",
            "distance_modifier"
        }
    }
})
-- Remove 30% Dodge Speed (otherwise the dodge speed would be too high)
mod:add_talent_buff_template("wood_elf", "wraith_pact_dodge_distance_speed_buff", {
    {
        multiplier = 0.7, -- 1
        remove_buff_func = "remove_movement_buff",
        apply_buff_func = "apply_movement_buff",
        path_to_movement_setting_to_modify = {
            "dodging",
            "speed_modifier"
        }
    }
})




-- Heart of Oak
-- 50% DR against Area Aura
-- Original: Increases max health by 15.0%.

mod:modify_talent("we_maidenguard", 5, 1, {
    name = "heart_of_oak_name",
    description = "heart_of_oak_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_max_stamina",
    buffs = {
        "heart_of_oak_aura"
    }
})
mod:add_text("heart_of_oak_name", "Heart of Oak")
mod:add_text("heart_of_oak_desc", "Aura that reduces area damage by 50%% for the entire team.")
-- Create Aura (Teambuff with Range)
mod:add_talent_buff_template("wood_elf", "heart_of_oak_aura", {
    {
        update_func = "activate_buff_on_distance",
        remove_buff_func = "remove_aura_buff",
        buff_to_add = "heart_of_oak_buff",
        range = 15,
    }
})
-- 50% Poison DR Teambuff active in the aura
mod:add_talent_buff_template("wood_elf", "heart_of_oak_buff", {
    {
        max_stacks = 1,
        icon = "kerillian_maidenguard_max_stamina",
        stat_buff = "protection_aoe",
        multiplier = -0.5,
    }
})
-- Fix Poison Damage Reduction not Working
local POISON_DAMAGE_TYPES = {
	aoe_poison_dot = true,
	poison = true,
	arrow_poison = true,
	arrow_poison_dot = true
}
local POISON_DAMAGE_SOURCES = {
	skaven_poison_wind_globadier = true,
	poison_dot = true
}
mod:hook(DamageUtils, "apply_buffs_to_damage", function (func, current_damage, attacked_unit, attacker_unit, damage_source, ...)
    if ScriptUnit.has_extension(attacked_unit, "buff_system") then
        local buff_extension = ScriptUnit.extension(attacked_unit, "buff_system")
        
        if DAMAGE_TYPES_AOE[damage_type] or POISON_DAMAGE_TYPES[damage_type] or POISON_DAMAGE_SOURCES[damage_source] then
            current_damage = buff_extension:apply_buffs_to_value(current_damage, "protection_aoe")
        end

    end
    
    return func(current_damage, attacked_unit, attacker_unit, damage_source, ...)
end)




-- Birch Stance (works)
-- 2 Stamina Shield/4 Stamina Aura
-- Original: Reduces block cost by 30.0%.

mod:modify_talent("we_maidenguard", 5, 2, {
    name = "birch_stance_name",
    description = "birch_stance_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_block_cost",
    buffs = {
        "birch_stance_aura"
    }
})
mod:add_text("birch_stance_name", "Birch Stance")
mod:add_text("birch_stance_desc", "The Ubersreik five will receive 2 stamina shields when staying close to Kerillian.")
-- Create Aura (Teambuff with Range)
mod:add_talent_buff_template("wood_elf", "birch_stance_aura", {
    {
        update_func = "activate_buff_on_distance",
        remove_buff_func = "remove_aura_buff",
        buff_to_add = "birch_stance_buff",
        range = 15,
    }
})
-- Add 4 Stamina (2 Stamina Shields) in the Aura
mod:add_talent_buff_template("wood_elf", "birch_stance_buff", {
    {
        max_stacks = 1,
        icon = "kerillian_maidenguard_block_cost",
        stat_buff = "max_fatigue",
        bonus = 4, -- 4 Stamina = 2 Stamina Shields
    }
})




-- Quiver of Plenty (scrounger version works)
-- Change: Scrounger Aura
-- Original: Increases ammunition amount by 40.0%

mod:modify_talent("we_maidenguard", 5, 3, {
    name = "quiver_of_plenty_name",
    description = "quiver_of_plenty_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_max_ammo",
    buffs = {
        "quiver_of_plenty_aura"
    }
})
mod:add_text("quiver_of_plenty_name", "Quiver of Plenty")
mod:add_text("quiver_of_plenty_desc", "Kerillian allows teamembers in close proximity and herself to restore 5%% of maximum ammunition when hitting a critical hit.")
-- Create Aura (Teambuff with Range)
mod:add_talent_buff_template("wood_elf", "quiver_of_plenty_aura", {
    {
        update_func = "activate_buff_on_distance",
        remove_buff_func = "remove_aura_buff",
        buff_to_add = "quiver_of_plenty_buff",
        range = 15,
    }
})
-- Add Scrounger to Aura
mod:add_talent_buff_template("wood_elf", "quiver_of_plenty_buff", {
    {
        event = "on_critical_hit",
        buff_func = "ammo_fraction_gain_on_crit_handmaiden_adjust",
        icon = "kerillian_maidenguard_max_ammo",
        ammo_bonus_fraction = 0.05,
        max_stacks = 1
    }
})
ProcFunctions.ammo_fraction_gain_on_crit_handmaiden_adjust = function (owner_unit, buff, params)
    local player = Managers.player:owner(owner_unit)

    if player and player.remote then
        return
    end

    local attack_type = params[2]

    if not attack_type then
        return
    end

    local is_ranged = false

    if attack_type == "projectile" or attack_type == "instant_projectile" then
        is_ranged = true
    end

    if Unit.alive(owner_unit) and is_ranged then
        local buff_template = buff.template
        local weapon_slot = "slot_ranged"
        local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
        local slot_data = inventory_extension:get_slot_data(weapon_slot)
        local target_number = params[4]
        local right_unit_1p = slot_data.right_unit_1p
        local left_unit_1p = slot_data.left_unit_1p
        local ammo_extension = GearUtils.get_ammo_extension(right_unit_1p, left_unit_1p)
        local ammo_bonus_fraction = buff_template.ammo_bonus_fraction

        if ammo_extension and (attack_type == "instant_projectile" or attack_type == "projectile") then
            local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)

            if target_number == 1 then
                buff.has_procced = false
            end

            local has_procced = buff.has_procced

            if not has_procced then
                ammo_extension:add_ammo_to_reserve(ammo_amount)

                buff.has_procced = true
            end
        end
    end
end


--[[
-- One free shot every 15 sec Aura
-- Original: Increases ammunition amount by 40.0%
mod:modify_talent("we_maidenguard", 5, 3, {
    name = "quiver_of_plenty_name",
    description = "quiver_of_plenty_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_max_ammo",
    buffs = {
        "quiver_of_plenty_aura"
    }
})
mod:add_text("quiver_of_plenty_name", "Quiver of Plenty")
mod:add_text("quiver_of_plenty_desc", "good stuff")

-- Create Aura (Teambuff with Range)
mod:add_talent_buff_template("wood_elf", "quiver_of_plenty_aura", {
    {
        update_func = "activate_buff_on_distance",
        remove_buff_func = "remove_aura_buff",
        buff_to_add = "quiver_of_plenty_buff",
        range = 15,
        --icon = "kerillian_maidenguard_max_ammo",
    }
})
-- Overarching Free Shot Buff Handler
mod:add_talent_buff_template("wood_elf", "quiver_of_plenty_buff", {
    {
        buff_to_add = "kerillian_thorn_free_throw_buff_handmaiden_adjust",
        max_stacks = 1,
        timer_buff = "kerillian_thorn_free_throw_heal_all_timer_handmaiden_adjust",
        update_func = "kerillian_thorn_sister_free_throw_handler_update_handmaiden_adjust",
        update_frequency = 0.1,
        time_removed_per_kill = 0
    }
})
-- Counter and Icon
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_free_throw_heal_all_timer_handmaiden_adjust", {
    {
        is_cooldown = true,
        icon = "kerillian_maidenguard_max_ammo",
        max_stacks = 1,
        duration = 15
    }
})
-- Free Shot Buff itself
mod:add_talent_buff_template("wood_elf", "kerillian_thorn_free_throw_buff_handmaiden_adjust", {
    {
        multiplier = -1,
        stat_buff = "reduced_overcharge",
        buff_func = "kerillian_thorn_sister_add_buff_remove_handmaiden_adjust",
        max_stacks = 1,
        event = "on_ammo_used",
        perk = buff_perks.infinite_ammo
    }
})

-- Update function for the timer
BuffFunctionTemplates.functions.kerillian_thorn_sister_free_throw_handler_update_handmaiden_adjust = function (owner_unit, buff, params)
    local player_unit = owner_unit

    if ALIVE[player_unit] then
        local template = buff.template
        local timer_buff_to_add = template.timer_buff
        --local buff_to_add = template.buff_to_add
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
-- function to add and remove the free shot buff
ProcFunctions.kerillian_thorn_sister_add_buff_remove_handmaiden_adjust = function (owner_unit, buff, params)
    if ALIVE[owner_unit] then
        local buff_to_add = buff.template.buff_to_add
        local buff_system = Managers.state.entity:system("buff_system")

        buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)

        local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

        buff_extension:remove_buff(buff.id)
    end
end
]]




-- Gift of Ladrielle (works)
-- Invis last 3 sec, Now applies old Bladedancer bleed
-- Original: Kerillian disappears from enemy perception for 2 seconds after using Dash.

mod:modify_talent("we_maidenguard", 6, 1, {
    name = "gift_of_ladrielle_name",
    description = "gift_of_ladrielle_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_activated_ability_invis_duration",
    buffs = {
        "kerillian_maidenguard_activated_ability_invis_duration",
    }
})
mod:add_text("gift_of_ladrielle_name", "Gift of Ladrielle")
mod:add_text("gift_of_ladrielle_desc", "Kerillian's dashes cause hit enemies to bleed and herself to become invisible for 3 seconds.")

-- Increase Invis duration to 5 seconds
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_activated_ability_invis_duration", {
    {
        refresh_durations = true,
        name = "kerillian_maidenguard_activated_ability",
        icon = "kerillian_maidenguard_activated_ability_invis_duration",
        max_stacks = 1,
        remove_buff_func = "end_maidenguard_activated_ability",
        duration = 3 -- 2
    }
})

-- Add Bladedancer to Gift of Ladrielle
-- Change the width of career skill from 1.5 to 5
-- Add No Clip for 3 seconds to ult
CareerAbilityWEMaidenGuard._run_ability = function (self)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local status_extension = self._status_extension
	local career_extension = self._career_extension
	local buff_extension = self._buff_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local buff_names = {
		"kerillian_maidenguard_activated_ability",
        "no_clip_dash_handmaiden_adjust"
	}

	if talent_extension:has_talent("kerillian_maidenguard_activated_ability_invis_duration", "wood_elf", true) then
		buff_names = {
			"kerillian_maidenguard_activated_ability_invis_duration"
		}
	end

	if talent_extension:has_talent("kerillian_maidenguard_activated_ability_insta_ress", "wood_elf", true) then
		buff_names[#buff_names + 1] = "kerillian_maidenguard_insta_ress"
	end

	local unit_object_id = network_manager:unit_game_object_id(owner_unit)

	for i = 1, #buff_names do
		local buff_name = buff_names[i]
		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

		if is_server then
			buff_extension:add_buff(buff_name, {
				attacker_unit = owner_unit
			})
			network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
		else
			network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
		end
	end

	if is_server and bot_player or local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:animation_event("shade_stealth_ability")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_maiden_guard_charge", owner_unit, 0)
		career_extension:set_state("kerillian_activate_maiden_guard")

		if local_player then
			first_person_extension:play_hud_sound_event("Play_career_ability_maiden_guard_charge")
		end
	end

	status_extension:set_noclip(true, "skill_maiden_guard")

    -- Bladedancer and Gift of Ladrielle in one Talent
    local damage_profile = "maidenguard_dash_ability"
    local bleed = talent_extension:has_talent("kerillian_maidenguard_activated_ability_invis_duration")

	if talent_extension:has_talent("kerillian_maidenguard_activated_ability_invis_duration", "wood_elf", true) then

	    damage_profile = "maidenguard_dash_ability_bleed"

		status_extension:set_invisible(true, nil, "skill_maiden_guard")

		if local_player then
			MOOD_BLACKBOARD.skill_maiden_guard = true
		end
	end

	if network_manager:game() then
		status_extension:set_is_dodging(true)

		local unit_id = network_manager:unit_game_object_id(owner_unit)

		network_transmit:send_rpc_server("rpc_status_change_bool", NetworkLookup.statuses.dodging, true, unit_id, 0)
	end


	status_extension.do_lunge = {
		animation_end_event = "maiden_guard_active_ability_charge_hit",
		allow_rotation = false,
		first_person_animation_end_event = "dodge_bwd",
		first_person_hit_animation_event = "charge_react",
		falloff_to_speed = 5,
		dodge = true,
		first_person_animation_event = "shade_stealth_ability",
		first_person_animation_end_event_hit = "dodge_bwd",
		duration = 0.65,
		initial_speed = 25,
		animation_event = "maiden_guard_active_ability_charge_start",
		damage = {
			depth_padding = 0.4,
			height = 1.8,
			collision_filter = "filter_explosion_overlap_no_player",
			hit_zone_hit_name = "full",
			ignore_shield = true,
			interrupt_on_max_hit_mass = false,
			interrupt_on_first_hit = false,
			width = 5, --1.5
			allow_backstab = true,
			damage_profile = damage_profile,
			power_level_multiplier = bleed and 1 or 0,
			stagger_angles = {
				max = 90,
				min = 90
			}
		}
	}

	career_extension:start_activated_ability_cooldown()
	self:_play_vo()
end




-- Bladedancer (works)
-- Each enemy hit by Dash increases cleave by 20% and Health Regen by 10% for 15 sec, stack up to 5 times
-- Original: Dashing through an enemy causes them to bleed for significant damage over time.

mod:modify_talent("we_maidenguard", 6, 2, {
    name = "bladedancer_name",
    description = "bladedancer_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_activated_ability_damage",
    buffs = {
        "bladedancer_event_handmaiden_adjust",
    }
})
mod:add_text("bladedancer_name", "Bladedancer")
mod:add_text("bladedancer_desc", "Each enemy hit with Dash grants 20%% cleave power and 10%% increased healing for 15 seconds. Stacks up to 5 times.")

mod:add_talent_buff_template("wood_elf", "bladedancer_event_handmaiden_adjust", {
    {
        event = "on_charge_ability_hit",
        buff_to_add = "bladedancer_buff_handmaiden_adjust",
        buff_func = "add_buff"
    }
})
BuffTemplates.bladedancer_buff_handmaiden_adjust = {
    buffs = {
        {
            name = "bladedancer_buff_handmaiden_adjust_1",
            refresh_durations = true,
            stat_buff = "power_level_melee_cleave",
            max_stacks = 5,
            duration = 15,
            multiplier = 0.2
        },
        {
            name = "bladedancer_buff_handmaiden_adjust_2",
            icon = "kerillian_maidenguard_activated_ability_damage",
            refresh_durations = true,
            priority_buff = true,
            stat_buff = "healing_received",
            max_stacks = 5,
            duration = 15,
            multiplier = 0.1
        }
    }
}
local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "bladedancer_buff_handmaiden_adjust"
NetworkLookup.buff_templates["bladedancer_buff_handmaiden_adjust"] = index




-- Power from Pain (works)
-- Each enemy hit by Dash increases crit chance by 6% and crit power by 10% for 15 sec, stack up to 5 times
-- Original: Each enemy hit with Dash grants 5.0% critical strike chance for 15 seconds. Stacks up to 5 times.

mod:modify_talent("we_maidenguard", 6, 3, {
    name = "power_from_pain_name",
    description = "power_from_pain_desc",
    num_ranks = 1,
    buffer = "both",
    icon = "kerillian_maidenguard_activated_ability_buff_on_enemy_hit",
    buffs = {
        "power_from_pain_event_handmaiden_adjust",
    }
})
mod:add_text("power_from_pain_name", "Power from Pain")
mod:add_text("power_from_pain_desc", "Each enemy hit with Dash grants 6%% critical strike chance and 10%% crit power for 15 seconds. Stacks up to 5 times.")

mod:add_talent_buff_template("wood_elf", "power_from_pain_event_handmaiden_adjust", {
    {
        event = "on_charge_ability_hit",
        buff_to_add = "power_from_pain_buff_handmaiden_adjust",
        buff_func = "add_buff"
    }
})
BuffTemplates.power_from_pain_buff_handmaiden_adjust = {
    buffs = {
        {
            name = "power_from_pain_buff_handmaiden_adjust_1",
            refresh_durations = true,
            stat_buff = "critical_strike_chance",
            max_stacks = 5,
            duration = 15,
            bonus = 0.06
        },
        {
            name = "power_from_pain_buff_handmaiden_adjust_2",
            icon = "kerillian_maidenguard_activated_ability_buff_on_enemy_hit",
            refresh_durations = true,
            priority_buff = true,
            stat_buff = "critical_strike_effectiveness",
            max_stacks = 5,
            duration = 15,
            multiplier = 0.1
        }
    }
}
local index = #NetworkLookup.buff_templates + 1
NetworkLookup.buff_templates[index] = "power_from_pain_buff_handmaiden_adjust"
NetworkLookup.buff_templates["power_from_pain_buff_handmaiden_adjust"] = index



mod:echo("Handmaiden Adjust v1.0.1 enabled")