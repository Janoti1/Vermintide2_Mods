local mod = get_mod("gk_quest_weave")


-- localization functions
local _language_id = Application.user_setting("language_id")
local _localization_database = {}

mod._quick_localize = function (self, text_id)
    local mod_localization_table = _localization_database
    if mod_localization_table then
        local text_translations = mod_localization_table[text_id]
        if text_translations then
            return text_translations[_language_id] or text_translations["en"]
        end
    end
end
mod:hook("Localize", function(func, text_id)
    local str = mod:_quick_localize(text_id)
    if str then return str end
    return func(text_id)
end)
function mod.add_text(self, text_id, text)
    if type(text) == "table" then
        _localization_database[text_id] = text
    else
        _localization_database[text_id] = {
            en = text
        }
    end
end



-- variable checks
mod.splash_screen_check = true
mod.previos_score_big = 0

-- Add Challenge to
InGameChallengeTemplates.weave_score_percent_big = {
    default_target = 1,
    description = "challenge_description_reach_score_weave_big_01",
    events = {
        weave_score_percent_big_reached = function (t)
            return 1
        end
    }
}
local index = #NetworkLookup.challenges + 1
NetworkLookup.challenges[index] = "weave_score_percent_big"
NetworkLookup.challenges["weave_score_percent_big"] = index
mod:add_text("weave_score_percent_big", "Collect Essence")
-- Trigger Function for Weave Score (+ 1 weave score triggers)
mod.weave_score_percent_big_reached = function ()
    if mod.splash_screen_check == true then
        return
    end
    local game_mode = Managers.state.game_mode:game_mode_key()
    if game_mode == "weave" then
        local current_score = Managers.weave:current_bar_score()
        if  current_score > (mod.previos_score_big + 1) then
            mod.previos_score_big = mod.previos_score_big + 1
            local player = Managers.player:local_player()
            Managers.state.event:trigger("weave_score_percent_big_reached", player)
        end
    end
end


-- fixed fs game_mode checks and changed to different table
PassiveAbilityQuestingKnight._get_possible_challenges = function (self)
	local mechanism_name = Managers.state.game_mode:game_mode_key()
	local settings = mod.challenge_settings_adjusted[mechanism_name] or mod.challenge_settings_adjusted.default
	local possible_challenges = settings.possible_challenges

	fassert(possible_challenges, "[PassiveAbilityQuestingKnight] possible_challenges not defined for the current mechanism")

	local filtered_challenges = {}

	for possible_challenges_index = 1, #possible_challenges do
		local possible_challenge = possible_challenges[possible_challenges_index]

		if not possible_challenge.condition or possible_challenge.condition() then
			filtered_challenges[#filtered_challenges + 1] = possible_challenge
		end
	end

	return filtered_challenges
end

PassiveAbilityQuestingKnight._get_side_quest_challenge = function (self)
	local mechanism_name = Managers.state.game_mode:game_mode_key()
	local settings = mod.challenge_settings_adjusted[mechanism_name] or mod.challenge_settings_adjusted.default
	local side_quest_challenge = settings.side_quest_challenge

	fassert(side_quest_challenge, "[PassiveAbilityQuestingKnight] side_quest_challenge not defined for the current mechanism")

	return side_quest_challenge
end

PassiveAbilityQuestingKnight._always_reset_quest_pool = function (self)
	local mechanism_name = Managers.state.game_mode:game_mode_key()
	local settings = mod.challenge_settings_adjusted[mechanism_name] or mod.challenge_settings_adjusted.default

	return settings.always_reset_quest_pool or false
end


-- register code changes once
mod.gk_weave_event_register = function ()
    -- register weave +1 score event (75 score max)
    Managers.state.event:register(mod, "weave_score_percent_big_reached", "weave_score_percent_big_reached")
    -- create one big table for all gamemodes
    mod.challenge_settings_adjusted = {
        default = {
            possible_challenges = {
                {
                    reward = "markus_questing_knight_passive_power_level",
                    type = "kill_elites",
                    amount = {
                        1,
                        15,
                        15,
                        20,
                        20,
                        30,
                        30,
                        30
                    }
                },
                {
                    reward = "markus_questing_knight_passive_attack_speed",
                    type = "kill_specials",
                    amount = {
                        1,
                        10,
                        10,
                        15,
                        15,
                        20,
                        20,
                        20
                    }
                },
                {
                    reward = "markus_questing_knight_passive_cooldown_reduction",
                    type = "kill_monsters",
                    amount = {
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1
                    }
                },
                {
                    reward = "markus_questing_knight_passive_health_regen",
                    type = "find_grimoire",
                    amount = {
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1
                    }
                },
                {
                    reward = "markus_questing_knight_passive_damage_taken",
                    type = "find_tome",
                    amount = {
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1
                    }
                }
            },
            side_quest_challenge = {
                reward = "markus_questing_knight_passive_strength_potion",
                type = "kill_enemies",
                amount = {
                    1,
                    100,
                    125,
                    150,
                    175,
                    200,
                    200,
                    200
                }
            }
        },
        weave = {
            possible_challenges = {
                {
                    reward = "markus_questing_knight_passive_power_level",
                    type = "kill_elites",
                    amount = {
                        1,
                        15,
                        15,
                        20,
                        20,
                        30,
                        30,
                        30
                    }
                },
                {
                    reward = "markus_questing_knight_passive_attack_speed",
                    type = "kill_specials",
                    amount = {
                        1,
                        10,
                        10,
                        15,
                        15,
                        20,
                        20,
                        20
                    }
                },
                {
                    reward = "markus_questing_knight_passive_cooldown_reduction",
                    type = "kill_monsters",
                    amount = {
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1
                    }
                },
                {
                    reward = "markus_questing_knight_passive_health_regen",
                    type = "weave_score_percent_big",
                    amount = {
                        25,
                        25,
                        25,
                        25,
                        25,
                        25,
                        25,
                        25
                    }
                },
                {
                    reward = "markus_questing_knight_passive_damage_taken",
                    type = "kill_roamers",
                    amount = {
                        1,
                        25,
                        30,
                        35,
                        40,
                        50,
                        50,
                        50
                    }
                }
            },
            side_quest_challenge = {
                reward = "markus_questing_knight_passive_strength_potion",
                type = "kill_enemies",
                amount = {
                    1,
                    50,
                    60,
                    75,
                    85,
                    100,
                    100,
                    100
                }
            }
        },
        deus = {
            --always_reset_quest_pool = true, -- remove resetting the quests when gk dies or the stage ends in cw
            possible_challenges = {
                {
                    reward = "deus_markus_questing_knight_passive_power_level",
                    type = "kill_elites",
                    amount = {
                        1,
                        7,
                        7,
                        10,
                        10,
                        15,
                        15,
                        15
                    }
                },
                {
                    reward = "deus_markus_questing_knight_passive_attack_speed",
                    type = "kill_specials",
                    amount = {
                        1,
                        5,
                        5,
                        7,
                        7,
                        10,
                        10,
                        10
                    }
                },
                {
                    reward = "deus_markus_questing_knight_passive_cooldown_reduction",
                    type = "kill_monsters",
                    amount = {
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1
                    }
                },
                {
                    reward = "deus_markus_questing_knight_passive_damage_taken",
                    type = "find_deus_soft_currency",
                    amount = {
                        1,
                        5,
                        5,
                        5,
                        5,
                        5,
                        5,
                        5
                    }
                    --condition = only_on_travel_and_signature_levels
                },
                {
                    reward = "deus_markus_questing_knight_passive_health_regen",
                    type = "cleanse_cursed_chest",
                    amount = {
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1,
                        1
                    }
                    --condition = only_on_travel_and_signature_levels
                }
            },
            side_quest_challenge = {
                reward = "markus_questing_knight_passive_strength_potion",
                type = "kill_enemies",
                amount = { -- changed to be the same values as campaign
                    1,
                    75,
                    90,
                    110,
                    130,
                    150,
                    150,
                    150
                }
            }
        }
    }

    -- remove stars from description in chaos wastes
    mod:add_text("deus_markus_questing_knight_passive_cooldown_reduction", "+10%% Cooldown Regen")
    mod:add_text("deus_markus_questing_knight_passive_cooldown_reduction_improved", "+15%% Cooldown Regen")

    mod:add_text("deus_markus_questing_knight_passive_attack_speed", "+5%% Attack Speed")
    mod:add_text("deus_markus_questing_knight_passive_attack_speed_improved", "+7.5%% Attack Speed")

    mod:add_text("deus_markus_questing_knight_passive_power_level", "+10%% Power Level")
    mod:add_text("deus_markus_questing_knight_passive_power_level_improved", "+15%% Power Level")

    mod:add_text("deus_markus_questing_knight_passive_damage_taken", "+10%% Damage Reduction")
    mod:add_text("deus_markus_questing_knight_passive_damage_taken_improved", "+15%% Damage Reduction")

    mod:add_text("deus_markus_questing_knight_passive_health_regen", "Health Regen")
    mod:add_text("deus_markus_questing_knight_passive_health_regen_improved", "Improved Health Regen")

end


local gk_weave_register = false
mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateIngame" then
        mod.splash_screen_check = false
    end
    if state_name == "StateLoading" or state_name == "StateSplashScreen" then
        mod.splash_screen_check = true
    end
    if status == "enter" and state_name == "StateIngame" and gk_weave_register == false then
        mod.gk_weave_event_register()
        gk_weave_register = true
    end
end

function mod.update()
    mod.weave_score_percent_big_reached()
end







-- Notes
-- weave manager: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/71af1489627732309fdc01630c458c9f0a727577/scripts/managers/weave/weave_manager.lua#L778
-- file per weave (including seeds and terror events, mostly data)
-- file per objective with all the various functions


-- gk quest data: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/master/scripts/settings/dlcs/lake/passive_ability_questing_knight.lua
-- gk quest functions: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/71af1489627732309fdc01630c458c9f0a727577/scripts/settings/dlcs/lake/passive_ability_questing_knight.lua#L155
-- gk quest in chaos wastes: HP --> Complete a chest of trials, dr --> find 5 pilgrim's coins boxes
-- gk quest data in cw: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/71af1489627732309fdc01630c458c9f0a727577/scripts/settings/dlcs/morris/morris_ingame_challenge.lua#L19
-- gk quest description: https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/71af1489627732309fdc01630c458c9f0a727577/scripts/managers/challenges/in_game_challenge_templates.lua#L55


-- Managers.weave = WeaveManager
-- current_bar_score --> ui element score
-- bar_cutoff --> max bar score value (apparently always 75)