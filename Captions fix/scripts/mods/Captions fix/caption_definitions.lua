local mod = get_mod("Captions fix")

-- Upvalue that holds all registered captions.
local caption_data = {}

-- The default duration a caption will show for.
local DEFAULT_CAPTION_DURATION = 3.5

-- Remove all registered captions.
local function clear_all_captions()
    table.clear(caption_data)
end

-- Register a new caption.
-- Captions can have the following fields:
-- label: The label that will show.
-- duration: Optional override for how long the caption will show for. In Seconds.
-- no_option: If true, an option will not be shown in the mod options menu.
-- automatic: If true, will be given a special color.
-- [int]: List of Wwise sound events that will trigger this caption.
local function add_caption(data)
    assert(data.label, "Caption is missing a label.")
    assert(#data > 0, "Subtitles should have at least 1 event.")

    data.pos = Vector3Box()
    data.duration = data.duration or DEFAULT_CAPTION_DURATION
    data.enabled = data.enabled == nil or data.enabled

    for _, event in ipairs(data) do
        fassert(not rawget(caption_data, event), "Repeated subtitle for the event `%s`", event)
        caption_data[event] = data
    end

    caption_data[#caption_data+1] = data
end

-- Expose the methods and data upvalue to the outside world.
-- Other mods are allowed to call add_caption and clear_all_captions.
mod.caption_data = caption_data
mod.clear_all_captions = clear_all_captions
mod.add_caption = add_caption

-- Automatic adding of subtitles for debugging. Only active in modded.
if script_data["eac-untrusted"] then
    setmetatable(caption_data, {
        __index = function(self, event)
            if event then
                return add_caption{ label = event, automatic = true, event }
            end
        end,
    })
end

-- {{{1 Caption definitions.
----------------------------------------------------------------------------------------------------

-- {{{2 Attacks & backstabs.
add_caption{ label = mod:localize("backstab_whoosh"),
    "Play_clan_rat_attack_player_back_vce",
    "Play_enemy_marauder_attack_player_back_vce",
    "Play_enemy_ungor_attack_player_back_vce",
    "play_enemy_gor_attack_player_back_vce",
    "Play_enemy_bestigor_attack_player_back_vce",
    "Play_enemy_standard_bearer_attack_player_back_vce",
    "Play_enemy_vce_chaos_warrior_attack_player_back",
    "Play_plague_monk_attack_player_back_vce",
    "Play_stormvermin_attack_player_back_vce",
    "Play_enemy_vce_shadow_champion_attack_player_back",
    "Play_enemy_vce_ecws_attack_player_back",
    "Play_enemy_undead_ethereal_skeleton_attack_vce_back",
}

-- {{{2 Horde stingers.
add_caption{ label = mod:localize("horde_approaching"), duration = 7,
    "enemy_horde_stingers_plague_monk",
    "enemy_horde_stinger",
    "enemy_terror_event_stinger",
}

-- {{{2 Globadiers.
--add_caption{ label = "Globadier dying", "Play_globadier_death_vce" }
-- The boiling sound is a loop that is started/stopped using events. Using a longer duration is a bit of a hack.
add_caption{ label = mod:localize("globadier_boiling"), duration = 10,
    "Play_enemy_foley_globadier_boiling_loop",
}
add_caption{ label = mod:localize("globadier_throwing"),
    "Play_enemy_combat_poison_throw",
    "Play_enemy_combat_globadier_poison_drop",
}
add_caption{ label = mod:localize("globadier_exploding"),
    "Play_enemy_globadier_suicide_start", -- charging
    "Play_enemy_combat_globadier_suicide_explosion",
}

-- {{{2 Ratlings and warpfires.
--add_caption{ label = "Ratling dying", "Play_enemy_vo_ratling_gunner_die"}
add_caption{ label = mod:localize("ratling_warpfire_clanking"),
    "Play_enemy_vo_warpfire_walk",
    "Play_enemy_foley_ratling_gunner",
    "Play_enemy_warpfire_thrower_foreshadowing",
    "Play_enemy_warpfire_thrower_foley",
    "Play_enemy_warpfire_thrower_tank",
    --"Play_enemy_vo_ratling_gunner_hurt",
}
add_caption{ label = mod:localize("ratling_revving"),
    "Play_ratling_gunner_winding_up_gun",
}
add_caption{ label = mod:localize("ratling_firing"),
    "Play_enemy_vce_ratling_gunner_shoot_start",
}
add_caption{ label = mod:localize("warpfire_burning"),
    "Play_enemy_warpfire_thrower_shoot",
    "Play_enemy_vce_warpfire_shoot_start",
    "Play_stormfiend_torch_loop",
}

-- {{{2 Assassins.
add_caption{ label = mod:localize("assassin_stalking"),
    "enemy_gutterrunner_stinger",
    "Play_gutterrunner_breath_vce", -- chittering
    "Play_gutterrunner_attack_vce", -- clawing
    "Play_enemy_combat_gutter_runner_knife_swing", -- clawing
    "Play_gutterrunner_die_vce", -- dying
}
add_caption{ label = mod:localize("assassin_pouncing"),
    "Play_gutterrunner_charge_vce",
}
add_caption{ label = mod:localize("assassin_vanishing"),
    "Play_chr_gutter_runner_vanish_smoke",
    "enemy_stinger_gutterrunner_vanish",
}

-- {{{2 Sorcerers
--add_caption{ label = "Sorcerer chanting", "chaos_corruptor_spawning" } -- chaos_corruptor_spawning_stop
--add_caption{ label = "Sorcerer disintegrating", "Play_enemy_sorcerer_death" }
--add_caption{ label = "Farting", "enemy_chaos_sorcerer_idle_fart",}
add_caption{ label = mod:localize("blight_Leech_teleporting"),
    "enemy_chaos_sorcerer_magic_teleport",
    "enemy_chaos_sorcerer_magic_teleport_from",
}
add_caption{ label = mod:localize("blightstormer_lurking"),
    --"enemy_chaos_sorcerer_foley_walk", -- leech and Blightstormer
    "Play_chaos_sorcerer_idle_breath_out",
    "Play_chaos_sorcerer_idle_breath_in",
    "Stop_chaos_sorcerer_vortex_skulking_around",
}
add_caption{ label = mod:localize("blightstormer_summoning"),
    "Play_enemy_sorcerer_vortex_summon_wind_loop",
}
add_caption{ label = mod:localize("leech_lurking"),
    "enemy_chaos_sorcerer_foley_staff", -- leech
}
add_caption{ label = mod:localize("leech_sucking"),
    "Play_enemy_sorcerer_magic_call",
}

-- {{{2 Packmasters.
add_caption{ label = mod:localize("packmaster_clattering"),
    "enemy_packmaster_foley",
}

-- {{{2 Standard bearers.
add_caption{ label = mod:localize("beastmen_chanting"),
    "Play_enemy_beastmen_standar_chanting_loop",
}
add_caption{ label = mod:localize("beastmen_standard_planted"),
    "Stop_enemy_beastmen_standar_chanting_loop",
}

--- {{{2 Archers
add_caption{ label = mod:localize("archers_shooting"), duration = 1,
    "Play_enemy_combat_ungor_archer_fire_bow",
}

-- {{{2 Chaos warriors / Bullwarks
add_caption{ label = mod:localize("chaos_warrior_clanking"), duration = 1,
    "enemy_chaos_foley_heavy",
    "enemy_chaos_foley_light",
    --"Play_breed_triggered_sound",
    --"Play_enemy_vce_chaos_warrior_taunt",
    --"Play_enemy_vce_chaos_warrior_breath_combat_start",
    --"Play_enemy_vce_chaos_warrior_breath_combat_end",
    --"weapon_foley_axe_2h",
}
add_caption{ label = mod:localize("bulwark_clanking"), duration = 1,
    "Play_enemy_chaos_bulwark_foley_light",
    "Play_enemy_chaos_bulwark_foley_heavy",
    "Play_enemy_chaos_bulwark_foley_swing",
}

-- {{{2 Marauders.
add_caption{ label = mod:localize("marauder_rampaging"),
    "Play_enemy_marauder_foley_light",
    "Play_enemy_marauder_foley_medium",
}
add_caption{ label = mod:localize("monk_rampaging"),
    "Play_enemy_plague_monk_start_frenzy",
}

-- {{{2 Bestigor
add_caption{ label = mod:localize("bestigor_charging"),
    --"Play_boss_aggro_enter",
    "play_enemy_bestigor_charge_start_howl",
    "play_enemy_bestigor_charge_attack_vce",
    "play_enemy_bestigor_charge_loop_impact",
    "Play_enemy_bestigor_charge_loop_grunts_vce",
}

-- {{{2 Patrols.
add_caption{ label = mod:localize("patrol_marching"),
    "Play_stormvermin_patrol_foley",
    "beastmen_patrol_foley",
    "storm_vermin_patrol_formate",
    "Play_stormvermin_patrol_forming",
    "Play_stormvemin_patrol_formated",
    "chaos_marauder_patrol_formate",
    "chaos_marauder_patrol_forming",
    "chaos_marauder_patrol_formated",
    "beastmen_patrol_formate",
    "beastmen_patrol_forming",
    "beastmen_patrol_formated",
    "Play_stormvermin_patrol_voice",
    "Play_stormvermin_patrol_shield_foley",
}
add_caption{ label = mod:localize("patrol_charging"), duration = 7,
    "storm_vermin_patrol_player_spotted",
    "beastmen_patrol_player_spotted",
    "chaos_marauder_patrol_player_spotted",
    --"storm_vermin_patrol_charge",
    --"beastmen_patrol_charge",
    --"chaos_marauder_patrol_charge",
}

-- {{{2 Bosses.
add_caption{ label = mod:localize("minotaur_roar"),
    "Play_enemy_minotaur_spawn",
    "Play_enemy_minotaur_abdominal_sound_loop",
    "Play_enemy_beastman_minotaur_necklace_foley",
    "Play_enemy_minotaur_axe_hit_ground",
    "Play_enemy_minotaur_pre_heavy_attack_vce",
    "Play_enemy_minotaur_axe_swing",
    "Play_enemy_minotaur_short_attack_vce"
}
add_caption{ label = mod:localize("minotaur_charging"),
    "Play_enemy_beastmen_minotaur_charge_start",
    "Play_enemy_beastmen_minotaur_charge_proximity",
    "Play_enemy_minotaur_charge_loop_start_vce",
    "Play_enemy_minotaur_charge_loop_grunts_vce",
}
add_caption{ label = mod:localize("chaos_spawn_squirming"),
    "Play_enemy_chaos_spawn_vce_idle_breath",
    "Play_enemy_chaos_spawn_vce_charge",
    "enemy_chaos_spawn_foley_idle_tentacles",
    "enemy_chaos_spawn_foley_light",
    "enemy_chaos_spawn_foley_heavy",
    "Play_enemy_chaos_spawn_vce_attack",
}
add_caption{ label = mod:localize("stormfiend_shriek"),
    "Play_enemy_stormfiend_commander_vce_command",
    "stormfiend_foley_un_controled_run",
    "stormfiend_foley_controled_idle",
    "Play_enemy_stormfiend_vce_breath",
}
add_caption{ label = mod:localize("rat_ogre_roar"),
    "Play_rat_ogre_charge_vce",
    "enemy_ratogre_stinger",
    "Play_rat_ogre_growl_short_vce",
    "Play_enemy_stormfiend_vce_charge",
}
add_caption{ label = mod:localize("troll_slurp"),
    "Play_enemy_troll_breath",
    "enemy_troll_foley_walk",
    "enemy_troll_foley_run",
    "Play_enemy_troll_vce_attack",
    "enemy_troll_swing",
    "enemy_troll_weapon_hit_ground",
}
add_caption{ label = mod:localize("troll_puke"),
    "Play_enemy_troll_vce_puke",
}


-- {{{2 Misc.
add_caption{ label = mod:localize("loot_rat_muttering"),
    "Play_loot_rat_near_sound",
}
add_caption{ label = mod:localize("grenade_lit"),
    "player_combat_weapon_grenade_light",
}
add_caption{ label = mod:localize("barrel_crackling"),
    "__barrel_fuse_dummy_event",
}
add_caption{ label = mod:localize("player_disabled"),
    "enemy_gutter_runner_pounced_stinger",
    "enemy_pack_master_grabbed_stinger",
}

-- {{{2 Flavour.
--add_caption{ label = "Distant thunder",
--    "Play_ambience_inn_boom_distant",
--    "Play_ambience_inn_boom_and_rattle",
--}
--add_caption{ label = "Shadow horse noises",
--    "Play_shadow_steed_hoof_scrape",
--    "Play_shadow_steed_hoof_ground",
--    "Play_shadow_steed_mystic_snort",
--}

-- Example labels shown during repositioning.
add_caption{ "EXAMPLE_1", label = "Short label", no_option = true, duration = 0.5 }
add_caption{ "EXAMPLE_2", label = "Somewhat longer label", no_option = true, duration = 0.5 }
add_caption{ "EXAMPLE_3", label = "A very, very, very long label", no_option = true, duration = 0.5 }