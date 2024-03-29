local mod = get_mod("Classic Sister")
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

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
			range_modifier_settings = carbine_dropoff_ranges
		},
		--targets = {} --not in game (shouldnt affect anything)
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
		--targets = {} --not in game (shouldnt affect anything)
	}
	-- longer dot (buff {} is NOT needed)
	mod.add_buff_template_moonfire_dot("wood_elf", "we_deus_01_dot", {
		--dlc_settings.buff_templates
		duration = 5,
		name = "we_deus_01_dot",
		end_flow_event = "smoke",
		start_flow_event = "burn",
		death_flow_event = "burn_death",
		remove_buff_func = "remove_dot_damage_old_moonfirebow",
		apply_buff_func = "start_dot_damage_old_moonfirebow",
		time_between_dot_damages = 0.75,
		damage_type = "burninating",
		damage_profile = "we_deus_01_dot",
		update_func = "apply_dot_damage",
		perks = {buff_perks.burning_elven_magic} -- prior 5.1 "burning"
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
	Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.impact_data.aoe = nil -- Remove AOE

	--half charges shot
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.hit_effect = ARROW_HIT_EFFECT
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.impact_data.damage_profile = "we_deus_01_special_charged"
	Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.impact_data.aoe = nil -- Remove AOE

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
			range_modifier_settings = carbine_dropoff_ranges
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
			--targets = {} -- nicht in aktuellem code
	}

	-- longer dot (buff {} is NOT needed)
	mod.add_buff_template_moonfire_dot("wood_elf", "we_deus_01_dot", {
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
		perks = {buff_perks.burning_elven_magic} -- prior 5.1 "burning"
	})

end

-- remove_dot_damage buff_func added again (for some reason it got removed in 5.1)
BuffFunctionTemplates.functions.remove_dot_damage_old_moonfirebow = function (unit, buff, params)
	if Unit.is_frozen(unit) then
		return
	end

	local end_flow_event = buff.template.end_flow_event

	if end_flow_event then
		Unit.flow_event(unit, end_flow_event)
	end

	if not HEALTH_ALIVE [unit] then -- Was AiUtils.unit_alive(unit) prior 5.2
		local death_flow_event = buff.template.death_flow_event

		if death_flow_event then
			Unit.flow_event(unit, death_flow_event, params)
		end
	end
end
-- start_dot_damage	got slightly changed in 5.2
BuffFunctionTemplates.functions.start_dot_damage_old_moonfirebow = function (unit, buff, params)

	-- this if loop got removed in 5.2
	if buff.template.start_flow_event then
		Unit.flow_event(unit, buff.template.start_flow_event, params)
	end

	if buff.template.damage_type == "burninating" then
		local attacker_unit = params.attacker_unit
		local attacker_buff_extension = attacker_unit and ScriptUnit.has_extension(attacker_unit, "buff_system")
		local target_buff_extension = ScriptUnit.has_extension(unit, "buff_system")

		if target_buff_extension and attacker_buff_extension and attacker_buff_extension:has_buff_type("sienna_unchained_burn_increases_damage_taken") then
			local buff_data = attacker_buff_extension:get_non_stacking_buff("sienna_unchained_burn_increases_damage_taken")

			table.clear(clearable_params)

			clearable_params.external_optional_multiplier = buff_data.multiplier
			clearable_params.external_optional_duration = buff.duration

			target_buff_extension:add_buff("increase_damage_recieved_while_burning", clearable_params)
		end
	end
end



-- Old Moonfirebow (damage_profile_templates and buff_templates are not used in game)

-- introducing damage profiles and buff templates once
-- base impact
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01"
NetworkLookup.damage_profiles["we_deus_01"] = index

-- dot damage profile
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_dot"
NetworkLookup.damage_profiles["we_deus_01_dot"] = index



-- Official Balance Backup 
-- In Case FS pushes another MFB patch, this will override the base version

-- uncharged shot Live Balance
DamageProfileTemplates.we_deus_01_fast = { 
	charge_value = "projectile",
	allow_dot_finesse_hit = true,
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	ignore_stagger_reduction = true,
	critical_strike = {
		attack_armor_power_modifer = {
			0.8,
			0.7,
			1,
			0.75,
			1,
			0.25 
		},
		impact_armor_power_modifer = {
			1,
			0.7,
			1,
			0.75,
			1,
			0.25
		}
	},
	armor_modifier = {
		attack = {
			0.6,
			0.4,
			0.75,
			0.5,
			0.75,
			0.25
		},
		impact = {
			1,
			0.5,
			1,
			0.5,
			0.75,
			0.25
		}
	},
	armor_modifier_far = {
		attack = {
			0.6,
			0.4,
			0.75,
			0.5,
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
		dot_template_name = "we_deus_01_dot_fast",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "elven_magic_arrow_carbine",
		power_distribution_near = {
			attack = 0.41,
			impact = 0.3
		},
	power_distribution_far = {
		attack = 0.3,
		impact = 0.25
	},
	range_modifier_settings = carbine_dropoff_ranges
	}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_fast"
NetworkLookup.damage_profiles["we_deus_01_fast"] = index

-- copy of we_deus_01_fast with changed dot_template_name to "we_deus_01_dot_charged"
DamageProfileTemplates.we_deus_01_charged = { 
	charge_value = "projectile",
	allow_dot_finesse_hit = true,
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	ignore_stagger_reduction = true,
	critical_strike = {
		attack_armor_power_modifer = {
			0.8,
			0.7,
			1,
			0.75,
			1,
			0.25 
		},
		impact_armor_power_modifer = {
			1,
			0.7,
			1,
			0.75,
			1,
			0.25
		}
	},
	armor_modifier = {
		attack = {
			0.6,
			0.4,
			0.75,
			0.5,
			0.75,
			0.25
		},
		impact = {
			1,
			0.5,
			1,
			0.5,
			0.75,
			0.25
		}
	},
	armor_modifier_far = {
		attack = {
			0.6,
			0.4,
			0.75,
			0.5,
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
		dot_template_name = "we_deus_01_dot_charged",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "elven_magic_arrow_carbine",
		power_distribution_near = {
			attack = 0.41,
			impact = 0.3
		},
	power_distribution_far = {
		attack = 0.3,
		impact = 0.25
	},
	range_modifier_settings = carbine_dropoff_ranges
	}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_charged"
NetworkLookup.damage_profiles["we_deus_01_charged"] = index

-- copy of we_deus_01_fast with changed dot_template_name to "we_deus_01_dot_special_charged"
DamageProfileTemplates.we_deus_01_special_charged = { 
	charge_value = "projectile",
	allow_dot_finesse_hit = true,
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	ignore_stagger_reduction = true,
	critical_strike = {
		attack_armor_power_modifer = {
			0.8,
			0.7,
			1,
			0.75,
			1,
			0.25 
		},
		impact_armor_power_modifer = {
			1,
			0.7,
			1,
			0.75,
			1,
			0.25
		}
	},
	armor_modifier = {
		attack = {
			0.6,
			0.4,
			0.75,
			0.5,
			0.75,
			0.25
		},
		impact = {
			1,
			0.5,
			1,
			0.5,
			0.75,
			0.25
		}
	},
	armor_modifier_far = {
		attack = {
			0.6,
			0.4,
			0.75,
			0.5,
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
		dot_template_name = "we_deus_01_dot_special_charged",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "elven_magic_arrow_carbine",
		power_distribution_near = {
			attack = 0.41,
			impact = 0.3
		},
	power_distribution_far = {
		attack = 0.3,
		impact = 0.25
	},
	range_modifier_settings = carbine_dropoff_ranges
	}
}
local index = #NetworkLookup.damage_profiles + 1
NetworkLookup.damage_profiles[index] = "we_deus_01_special_charged"
NetworkLookup.damage_profiles["we_deus_01_special_charged"] = index

mod.add_buff_template_moonfire_dot("wood_elf", "we_deus_01_dot_fast", {
	name = "we_deus_01_dot_fast",
	ticks = 2,
	apply_buff_func = "start_dot_damage",
	update_start_delay = 0.75,
	time_between_dot_damages = 0.75,
	damage_type = "burninating",
	damage_profile = "we_deus_01_dot",
	update_func = "apply_dot_damage",
	perks = {buff_perks.burning_elven_magic} -- prior 5.1 "burning"
})
mod.add_buff_template_moonfire_dot("wood_elf", "we_deus_01_dot_special_charged", {
	name = "we_deus_01_dot_special_charged",
	ticks = 4,
	apply_buff_func = "start_dot_damage",
	update_start_delay = 0.75,
	time_between_dot_damages = 0.75,
	damage_type = "burninating",
	damage_profile = "we_deus_01_dot",
	update_func = "apply_dot_damage",
	perks = {buff_perks.burning_elven_magic} -- prior 5.1 "burning"
})
mod.add_buff_template_moonfire_dot("wood_elf", "we_deus_01_dot_charged", {
	name = "we_deus_01_dot_charged",
	ticks = 6,
	apply_buff_func = "start_dot_damage",
	update_start_delay = 0.75,
	time_between_dot_damages = 0.75,
	damage_type = "burninating",
	damage_profile = "we_deus_01_dot",
	update_func = "apply_dot_damage",
	perks = {buff_perks.burning_elven_magic} -- prior 5.1 "burning"
})




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
-- no clue what it does nor if it does anything at all
DLCSettings.morris.buff_templates.we_deus_01_kerillian_critical_bleed_dot_disable = {
	buffs = {
		{
			name = "we_deus_01_kerillian_critical_bleed_dot_disable",
			perks = {buff_perks.kerillian_critical_bleed_dot_disable}
		}
	}
}

-- DLCSettings (could affect corus, either code better or leave out)
--[[
DLCSettings.morris.dot_type_lookup = {
	we_deus_01_dot_fast = "burning_dot",
	burning_magma_dot = "burning_dot", -- corus
	we_deus_01_dot = "burning_dot",
	we_deus_01_dot_special_charged = "burning_dot",
	we_deus_01_dot_charged = "burning_dot"
}
]]

-- check if enabled
mod.check_old_mfb = function ()
	if mod.settings.enable_old_moonbow then mod:moonfirebow_changes() else mod:official_moonfirebow() end
end