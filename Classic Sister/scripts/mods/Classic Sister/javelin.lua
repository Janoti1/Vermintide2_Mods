local mod = get_mod("Classic Sister")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")


-- just in case that gets also changed
local carbine_dropoff_ranges = {
	dropoff_start = 15,
	dropoff_end = 30
}
local sniper_dropoff_ranges = {
	dropoff_start = 30,
	dropoff_end = 50
}

-- Reverts Javelin's Damage Profiles to Prior 5.2

mod.javelin_old = function()

    DamageProfileTemplates.medium_javelin_smiter_stab = {
        charge_value = "light_attack",
        critical_strike = {
            attack_armor_power_modifer = {
                1,
                0.4,
                2.3,
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
        armor_modifier = {
            attack = {
                1,
                0.25,
                2.25,
                1,
                0.75
            },
            impact = {
                1,
                0.75,
                1,
                1,
                0.75
            }
        },
        cleave_distribution = {
            attack = 0.075,
            impact = 0.075
        },
        default_target = {
            boost_curve_coefficient_headshot = 2.5,
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient = 1,
            attack_template = "stab_smiter",
            power_distribution = {
                attack = 0.25,
                impact = 0.125
            }
        },
        targets = {}
    }
    DamageProfileTemplates.medium_javelin_smiter_stab_bleed = {
        charge_value = "light_attack",
        critical_strike = {
            attack_armor_power_modifer = {
                1,
                0.4,
                2.3,
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
        armor_modifier = {
            attack = {
                1,
                0.25,
                2.25,
                1,
                0.75
            },
            impact = {
                1,
                0.75,
                1,
                1,
                0.75
            }
        },
        cleave_distribution = {
            attack = 0.075,
            impact = 0.075
        },
        default_target = {
            boost_curve_coefficient_headshot = 2.5,
            dot_template_name = "weapon_bleed_dot_javelin",
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient = 1,
            attack_template = "stab_smiter",
            power_distribution = {
                attack = 0.25,
                impact = 0.125
            }
        },
        targets = {}
    }
    DamageProfileTemplates.heavy_javelin_smiter_stab_bleed = {
        charge_value = "heavy_attack",
        critical_strike = {
            attack_armor_power_modifer = {
                1,
                0.5,
                2.3,
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
        cleave_distribution = {
            attack = 0.075,
            impact = 0.075
        },
        armor_modifier = {
            attack = {
                1,
                0.3,
                2,
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
        default_target = {
            boost_curve_coefficient_headshot = 1,
            boost_curve_type = "ninja_curve",
            boost_curve_coefficient = 0.75,
            attack_template = "heavy_stab_smiter",
            power_distribution = {
                attack = 0.2,
                impact = 0.15
            }
        },
        targets = {
            {
                boost_curve_coefficient_headshot = 2,
                boost_curve_type = "ninja_curve",
                boost_curve_coefficient = 0.75,
                attack_template = "heavy_stab_smiter",
                armor_modifier = {
                    attack = {
                        1,
                        0.45,
                        2,
                        1,
                        0.75
                    },
                    impact = {
                        1,
                        0.65,
                        1,
                        1,
                        0.75
                    }
                },
                power_distribution = {
                    attack = 0.45,
                    impact = 0.25
                }
            }
        }
    }
    DamageProfileTemplates.thrown_javelin = {
        charge_value = "projectile",
        no_stagger_damage_reduction_ranged = true,
        shield_break = true,
        critical_strike = {
            attack_armor_power_modifer = {
                1,
                1,
                1.3,
                1,
                0.75,
                0.5
            },
            impact_armor_power_modifer = {
                1,
                1,
                1,
                1,
                1,
                0.75
            }
        },
        armor_modifier_near = {
            attack = {
                1,
                0.7,
                1.1,
                1,
                0.75,
                0.25
            },
            impact = {
                1,
                1,
                1,
                1,
                1,
                0.75
            }
        },
        armor_modifier_far = {
            attack = {
                1,
                0.7,
                1.1,
                1,
                0.75,
                0.25
            },
            impact = {
                1,
                1,
                1,
                1,
                1,
                0.5
            }
        },
        cleave_distribution = {
            attack = 0.8,
            impact = 0.8
        },
        default_target = {
            boost_curve_coefficient_headshot = 1.6,
            boost_curve_type = "smiter_curve",
            boost_curve_coefficient = 1,
            attack_template = "projectile_javelin",
            power_distribution_near = {
                attack = 0.8,
                impact = 0.85
            },
            power_distribution_far = {
                attack = 0.8,
                impact = 0.85
            },
            range_modifier_settings = sniper_dropoff_ranges -- changed in 5.10.1 from "range_dropoff_settings"
        },
        targets = {}
    }

    -- the dot template (doesnt work for some reason)
    mod:add_buff_template("weapon_bleed_dot_javelin_old", {
        duration = 4,
        name = "weapon_bleed_dot_javelin",
        max_stacks = 1,
        refresh_durations = true,
        apply_buff_func = "start_dot_damage",
        update_start_delay = 0.5,
        time_between_dot_damages = 0.5,
        hit_zone = "neck",
        damage_profile = "bleed_maidenguard",
        update_func = "apply_dot_damage",
        perks = {
            buff_perks.bleeding
        }
	})

end

mod.javelin_live = function()

    DamageProfileTemplates.medium_javelin_smiter_stab = {
		charge_value = "light_attack",
		melee_boost_override = 2.8,
		critical_strike = {
			attack_armor_power_modifer = {
				1,
				0.4,
				2.2,
				1,
				1,
			},
			impact_armor_power_modifer = {
				1,
				1,
				1,
				1,
				1,
			},
		},
		armor_modifier = {
			attack = {
				1,
				0.25,
				2,
				1,
				0.75,
			},
			impact = {
				1,
				0.75,
				1,
				1,
				0.75,
			},
		},
		cleave_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
		default_target = {
			attack_template = "stab_smiter",
			boost_curve_coefficient = 1,
			boost_curve_coefficient_headshot = 2.2,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.25,
				impact = 0.125,
			},
		},
        targets = {}
	}
    DamageProfileTemplates.medium_javelin_smiter_stab_bleed = {
		charge_value = "light_attack",
		critical_strike = {
			attack_armor_power_modifer = {
				1,
				0.4,
				2.2,
				1,
				1,
			},
			impact_armor_power_modifer = {
				1,
				1,
				1,
				1,
				1,
			},
		},
		armor_modifier = {
			attack = {
				1,
				0.25,
				2.1,
				1,
				0.75,
			},
			impact = {
				1,
				0.75,
				1,
				1,
				0.75,
			},
		},
		cleave_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
		default_target = {
			attack_template = "stab_smiter",
			boost_curve_coefficient = 1,
			boost_curve_coefficient_headshot = 2.2,
			boost_curve_type = "ninja_curve",
			dot_template_name = "weapon_bleed_dot_javelin",
			melee_boost_override = 2.8,
			power_distribution = {
				attack = 0.25,
				impact = 0.125,
			},
		},
        targets = {}
	}
    DamageProfileTemplates.heavy_javelin_smiter_stab_bleed = {
		charge_value = "heavy_attack",
		critical_strike = {
			attack_armor_power_modifer = {
				1,
				0.5,
				2.2,
				1,
				1,
			},
			impact_armor_power_modifer = {
				1,
				1,
				1,
				1,
				1,
			},
		},
		cleave_distribution = {
			attack = 0.075,
			impact = 0.075,
		},
		armor_modifier = {
			attack = {
				1,
				0.3,
				2,
				1,
				0.75,
			},
			impact = {
				1,
				0.5,
				1,
				1,
				0.75,
			},
		},
		default_target = {
			attack_template = "heavy_stab_smiter",
			boost_curve_coefficient = 0.75,
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "ninja_curve",
			power_distribution = {
				attack = 0.2,
				impact = 0.15,
			},
		},
		targets = {
			{
				attack_template = "heavy_stab_smiter",
				boost_curve_coefficient = 0.75,
				boost_curve_coefficient_headshot = 2,
				boost_curve_type = "ninja_curve",
				armor_modifier = {
					attack = {
						1,
						0.45,
						2,
						1,
						0.75,
					},
					impact = {
						1,
						0.65,
						1,
						1,
						0.75,
					},
				},
				power_distribution = {
					attack = 0.45,
					impact = 0.25,
				},
			},
		},
	}
    DamageProfileTemplates.thrown_javelin = {
		charge_value = "projectile",
		no_stagger_damage_reduction_ranged = true,
		shield_break = true,
		critical_strike = {
			attack_armor_power_modifer = {
				1,
				1,
				1.3,
				1,
				0.75,
				0.5,
			},
			impact_armor_power_modifer = {
				1,
				1,
				1,
				1,
				1,
				0.75,
			},
		},
		armor_modifier_near = {
			attack = {
				1,
				0.63,
				1.1,
				1,
				0.75,
				0.2,
			},
			impact = {
				1,
				1,
				1,
				1,
				1,
				0.75,
			},
		},
		armor_modifier_far = {
			attack = {
				1,
				0.63,
				1.1,
				1,
				0.75,
				0.2,
			},
			impact = {
				1,
				1,
				1,
				1,
				1,
				0.5,
			},
		},
		cleave_distribution = {
			attack = 0.15,
			impact = 0.15,
		},
		default_target = {
			attack_template = "projectile_javelin",
			boost_curve_coefficient = 1,
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "smiter_curve",
			power_distribution_near = {
				attack = 0.76,
				impact = 0.85,
			},
			power_distribution_far = {
				attack = 0.55,
				impact = 0.4,
			},
			range_modifier_settings = {
				dropoff_end = 30,
				dropoff_start = 15,
			},
		},
        targets = {}
	}

    -- unchanged (doesnt work for some reason)
    mod:add_buff_template("weapon_bleed_dot_javelin_live", {
        --name = "weapon_bleed_dot_javelin", -- live called weapon bleed dot javelin (without the underscores)
        apply_buff_func = "start_dot_damage",
        damage_profile = "bleed_maidenguard",
        duration = 4,
        hit_zone = "neck",
        max_stacks = 1,
        name = "weapon bleed dot javelin",
        refresh_durations = true,
        time_between_dot_damages = 0.5,
        update_func = "apply_dot_damage",
        update_start_delay = 0.5,
        perks = {
            buff_perks.bleeding,
        },
	})

end

-- javelin bleed lookup (could affect other dots too so commented out for now)
--[[
DLCSettings.woods.dot_type_lookup = {
	thorn_sister_passive_poison_improved = "poison_dot",
	weapon_bleed_dot_javelin = "poison_dot",
	thorn_sister_wall_bleed = "poison_dot",
	thorn_sister_passive_poison = "poison_dot"
}
]]

-- check if enabled
mod.check_old_javelin = function ()
	if mod.settings.enable_old_javelin then mod:javelin_old() else mod:javelin_live() end
end