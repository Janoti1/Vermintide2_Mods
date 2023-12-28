local mod = get_mod("Classic Sister")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")


--[[
    strings have to be written directly in the DamageProfileTemplates apparently,
    the only way to do this in a way Fatshark wants it is through the function from TB I believe

    also the changes in the weapontemplate wont show in game. changes in the DamageProfileTemplate do
]]

-- fixed SnD
function mod.fixed_sword_and_dagger()

    -- the PowerLevelTemplate critical_strike_stab_smiter_M_1h is unchanged, they instead created a new one called critical_strike_stab_dual_smiter_L

    -- create new unlinked DamageProfileTemplate only for SnD
    DamageProfileTemplates.light_slashing_smiter_stab_dual_sword_and_dagger = {
        charge_value = "heavy_attack",
        cleave_distribution = {
            attack = 0.075,
            impact = 0.075
        },
        armor_modifier = {
            attack = {
                1,
                0.75,
                2.25,
                1,
                0.75
            },
            impact = {
                1,
                1,
                1,
                1,
                0.75
            }
        },
        targets = {
            {
                boost_curve_coefficient_headshot = 2,
                boost_curve_type = "smiter_curve",
                boost_curve_coefficient = 1.5,
                attack_template = "stab_smiter",
                armor_modifier = {
                    attack = {
                        1,
                        0.8,
                        2.5,
                        1,
                        0.75
                    },
                    impact = {
                        1,
                        0.5,
                        1,
                        1,
                        0.75
                    }
                },
                power_distribution = {
                    attack = 0.24,
                    impact = 0.1
                }
            }
        },
        critical_strike = { -- this got swapped with critical_strike_stab_dual_smiter_L
            attack_armor_power_modifer = {
                1,
                1,
                2.5,
                1,
                1
            },
            impact_armor_power_modifer = {
                1,
                1,
                1,
                1,
                1
            }
        },
        melee_boost_override = 4,
        default_target = {
            boost_curve_coefficient_headshot = 2,
            boost_curve_type = "smiter_curve",
            boost_curve_coefficient = 0.75,
            attack_template = "stab_smiter",
            power_distribution = {
                attack = 0.1,
                impact = 0.075
            }
        },
    }

    -- add custom Damage Profile Template to Weapon Template of SnD
    Weapons.dual_wield_sword_dagger_template_1.actions.action_one.heavy_attack_2.damage_profile_left = "light_slashing_smiter_stab_dual_sword_and_dagger"
    Weapons.dual_wield_sword_dagger_template_1.actions.action_one.heavy_attack_2.damage_profile_right = "light_slashing_smiter_stab_dual_sword_and_dagger"

    mod:chat_broadcast("fixed SnD")

end

-- add the DamageProfileTemplate to the NetworkLookup
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "light_slashing_smiter_stab_dual_sword_and_dagger"
NetworkLookup.damage_profiles["light_slashing_smiter_stab_dual_sword_and_dagger"] = index


-- old DD
function mod.revert_dual_daggers()

    -- create new DamageProfileTemplate for the old version of Dual Daggers
    DamageProfileTemplates.light_slashing_smiter_stab_dual_daggers = {
        charge_value = "heavy_attack",
        cleave_distribution = {
            attack = 0.075,
            impact = 0.075
        },
        armor_modifier = {
            attack = {
                1,
                0.75,
                2.25,
                1,
                0.75
            },
            impact = {
                1,
                1,
                1,
                1,
                0.75
            }
        },
        targets = {
            {
                boost_curve_coefficient_headshot = 2,
                boost_curve_type = "smiter_curve",
                boost_curve_coefficient = 1.5,
                attack_template = "stab_smiter",
                armor_modifier = {
                    attack = {
                        1,
                        0.8,
                        2.5,
                        1,
                        0.75
                    },
                    impact = {
                        1,
                        0.5,
                        1,
                        1,
                        0.75
                    }
                },
                power_distribution = {
                    attack = 0.24,
                    impact = 0.1
                }
            }
        },
        critical_strike = { -- this got swapped with critical_strike_stab_dual_smiter_L
            attack_armor_power_modifer = {
                1,
                1,
                2.5,
                1,
                1
            },
            impact_armor_power_modifer = {
                1,
                1,
                1,
                1,
                1
            }
        },
        melee_boost_override = 4,
        default_target = {
            boost_curve_coefficient_headshot = 2,
            boost_curve_type = "smiter_curve",
            boost_curve_coefficient = 0.75,
            attack_template = "stab_smiter",
            power_distribution = {
                attack = 0.1,
                impact = 0.075
            }
        },
    }


    -- add custom Damage Profile Template to Weapon Template of DD
    Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack_stab.damage_profile_left = "light_slashing_smiter_stab_dual_daggers"
    Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack_stab.damage_profile_right = "light_slashing_smiter_stab_dual_daggers"
    Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack.damage_profile_left = "light_slashing_smiter_stab_dual_daggers"
    Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack.damage_profile_right = "light_slashing_smiter_stab_dual_daggers"

    --mod:chat_broadcast("old DD")

end


-- new DD
function mod.reset_dual_daggers_to_official()

    -- new DD
    DamageProfileTemplates.light_slashing_smiter_stab_dual_daggers = {
        charge_value = "heavy_attack",
        cleave_distribution = {
            attack = 0.075,
            impact = 0.075
        },
        armor_modifier = {
            attack = {
                1,
                0.75,
                2.25,
                1,
                0.75
            },
            impact = {
                1,
                1,
                1,
                1,
                0.75
            }
        },
        targets = { -- this template got changed numerically
            {
                boost_curve_coefficient_headshot = 2,
                boost_curve_type = "smiter_curve",
                boost_curve_coefficient = 1.5,
                attack_template = "stab_smiter",
                armor_modifier = {
                    attack = {
                        1,
                        0.8,
                        2.1, --2.5
                        1,
                        0.75
                    },
                    impact = {
                        1,
                        0.5,
                        1,
                        1,
                        0.75
                    }
                },
                power_distribution = {
                    attack = 0.24,
                    impact = 0.1
                }
            }
        },
        critical_strike = { -- previously critical_strike_stab_smiter_M_1h 
            attack_armor_power_modifer = {
                1,
                1,
                2.1, --2.5
                1,
                1
            },
            impact_armor_power_modifer = {
                1,
                1,
                1,
                1,
                1
            }
        },
        melee_boost_override = 4,
        default_target = {
            boost_curve_coefficient_headshot = 2,
            boost_curve_type = "smiter_curve",
            boost_curve_coefficient = 0.75,
            attack_template = "stab_smiter",
            power_distribution = {
                attack = 0.1,
                impact = 0.075
            }
        },
    }

    -- add custom Damage Profile Template to Weapon Template of DD
    Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack_stab.damage_profile_left = "light_slashing_smiter_stab_dual_daggers"
    Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack_stab.damage_profile_right = "light_slashing_smiter_stab_dual_daggers"
    Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack.damage_profile_left = "light_slashing_smiter_stab_dual_daggers"
    Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack.damage_profile_right = "light_slashing_smiter_stab_dual_daggers"

    --mod:chat_broadcast("new DD")

end

-- add the DamageProfileTemplate for dual daggers to the NetworkLookup
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "light_slashing_smiter_stab_dual_daggers"
NetworkLookup.damage_profiles["light_slashing_smiter_stab_dual_daggers"] = index


-- activate Sword and Dagger Fix by default
mod:fixed_sword_and_dagger()


-- check if enabled
mod.check_old_dual_daggers = function ()
	if mod.settings.enable_old_dual_daggers then mod:revert_dual_daggers() else mod:reset_dual_daggers_to_official() end
end