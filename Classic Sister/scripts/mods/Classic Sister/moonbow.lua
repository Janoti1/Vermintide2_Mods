local mod = get_mod("Classic Sister")

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