local mod = get_mod("Helpers 2")


--[[

	Collection of small helper snippets for testing and QOL
	Originally made by PropJoe, fixed by using similar snippets from other mods by
	raindish and isaakk, expanded with snippets provided by osmium, craven, raindish, Zaphio and myself

	https://steamcommunity.com/sharedfiles/filedetails/?id=2418326943
	https://steamcommunity.com/sharedfiles/filedetails/?id=1467035358
	https://steamcommunity.com/sharedfiles/filedetails/?id=1678844573
	https://steamcommunity.com/sharedfiles/filedetails/?id=2477335429
	https://steamcommunity.com/sharedfiles/filedetails/?id=2940810840
	https://steamcommunity.com/sharedfiles/filedetails/?id=1672222699
	https://steamcommunity.com/sharedfiles/filedetails/?id=1466489151
	https://gist.verminti.de/#!/infinite_stamina.lua
	https://gist.verminti.de/#!/change_movement.lua

	2024-06-30 - Janoti!

]]


--- Reset ult.
mod.reset_ult = function()
	local local_player_unit = Managers.player:local_player().player_unit
	local career_extension = ScriptUnit.has_extension(local_player_unit, "career_system")
	if career_extension then
		career_extension:reduce_activated_ability_cooldown_percent(1, 1)
	end
end
mod:command("reset_ult", mod:localize("reset_ult_command_description"), mod.reset_ult)


--- Kill bots.
mod.kill_bots = function()
	mod:pcall(function()
		if EAC.state() ~= "untrusted" then
			local game_mode_manager = Managers.state.game_mode
			local round_started = game_mode_manager:is_round_started()

			if round_started then
				mod:echo("[Hacks] Bots may only be killed at the start of the map.")
				return
			end
		end

		for _, bot in ipairs( Managers.player:bots() ) do
			if bot.player_unit then
				local status_ext = ScriptUnit.extension(bot.player_unit, "status_system")
				if status_ext and not status_ext:is_ready_for_assisted_respawn() then
					status_ext:set_dead(true)
				end
			end
		end
	end)
end
mod:command("kill_bots", mod:localize("kill_bots_command_description"), function() mod.kill_bots() end)


--- Pause.
mod.paused = false
mod.do_pause = function()
	if not Managers.player.is_server then
		mod:echo(mod:localize("not_server"))
		return
	end

	if mod.paused then
		Managers.state.debug:set_time_scale(13)
		mod.paused = false
		mod:echo(mod:localize("game_unpaused"))
	else
		Managers.state.debug:set_time_scale(6)
		mod.paused = true
		mod:echo(mod:localize("game_paused"))
	end
end
mod:command("pause", mod:localize("pause_command_description"), function() mod.do_pause() end)


-- Win/Fail/Restart level
-- taken from raindish's restart mod and integrated here
mod.fail_level = function()
	if DamageUtils.is_in_inn then
		mod:echo("[Hacks] You can't fail in the Keep")
	else
		if Managers.state.game_mode then
			Managers.state.game_mode:fail_level()
		end
	end
end
mod.win_level = function()
	mod:pcall(function()
		if DamageUtils.is_in_inn then
			mod:echo("[Hacks] You can't win in the Keep")
		else
			if Managers.state.game_mode then
				Managers.state.game_mode:complete_level()
			end
		end
	end)
end
mod.restart_level = function()
	mod:pcall(function()
		if DamageUtils.is_in_inn then
			mod:echo("[Hacks] You can't restart in the keep.")
			return
		else
			if Managers.state.game_mode then
				Managers.state.game_mode:retry_level()
			end
		end
	end)
end

mod.activate_win_fail_restart_commands = function()
	mod:command("fail", mod:localize("fail_level_command_description"), function() mod.fail_level() end)
	mod:command("win", mod:localize("win_level_command_description"), function() mod.win_level() end)
	mod:command("restart", mod:localize("restart_level_command_description"), function() mod.restart_level() end)
end
-- check if raindish's restart mod is active and leave commands turned off
mod.on_all_mods_loaded = function()
	local restart_mod = get_mod("GoToLevel")
	if restart_mod then
		return
	else
		mod.activate_win_fail_restart_commands()
	end
end


-- Bots on / off
-- technically an option in truesolo qol but not needed
-- only to spawn bots in the keep which can be done with photomode.. how?
--[[
mod:command("bot_toggle", mod:localize("bot_toggle_command_description"),
function()
	mod:pcall(function()
		local level_settings = LevelHelper:current_level_settings()
		level_settings.no_bots_allowed = not level_settings.no_bots_allowed
	end)
end)
]]

-- Invincible
mod.invincible = false
mod:command("invincible_toggle", mod:localize("invincible_toggle_command_description"),
function()
	mod:pcall(function()
		if mod.invincible then
			script_data.player_invincible = not script_data.player_invincible
			mod.invincible = false
			mod:echo("[Hacks] You can take damage.")
		else
			script_data.player_invincible = not script_data.player_invincible
			mod.invincible = true
			mod:echo("[Hacks] You are invincible.")
		end
	end)
end)


-- toggle damage in Keep
mod.take_damage = false
mod:command("inn_dmg", mod:localize("inn_damage_command_description"),
function()
	mod:pcall(function()
		if Managers.player.is_server then
			if mod.take_damage then
				DamageUtils.is_in_inn = true
				mod.take_damage = false
				mod:echo("[Hacks] You are invincible in the keep.")
			else
				DamageUtils.is_in_inn = false
				mod.take_damage = true
				mod:echo("[Hacks] You can take damage in the keep.")
			end
		else
			mod:echo("[Hacks] Only the host can allow players to take damage in the keep.")
		end
	end)
end)


-- make yourself invisible
-- provided by osmium
local cloak_is_on = false
mod.invisible = function()
	local player_unit = Managers.player:local_player().player_unit
	if cloak_is_on == false then
		ScriptUnit.has_extension(player_unit, "status_system"):set_invisible(true, nil, "whatever_string")
		cloak_is_on = true
		mod:echo("[Hacks] Player Invisible")
	else
		ScriptUnit.has_extension(player_unit, "status_system"):set_invisible(false, nil, "whatever_string")
		cloak_is_on = false
		mod:echo("[Hacks] Player Visible")
	end
end
mod:command("invisible", "Toggles invisibilty.", function()
	mod.invisible()
end)


-- suicide
-- yoinked from raindish's mod
mod:command("die", mod:localize("die_command_description"), function()
	if DamageUtils.is_in_inn then
		mod:echo("[Hacks] You can't die in the keep.")
		return
	end

	local player_unit = Managers.player:local_player().player_unit
	local death_system = Managers.state.entity:system("death_system")
	death_system:kill_unit(player_unit, {})
	Managers.chat:send_chat_message(1, 1, "[Hacks] Guess I'll die-die...", false, nil, false)
end)


-- infinite ammo
-- yoinked from PropJoe's mod
-- only toggable when freshly loaded into a map ?
mod.infinite_ammo = false
mod.is_in_game = false
local time = 0
mod.actually_in_game = false
mod.update = function(dt)
	if DamageUtils.is_in_inn and not mod.actually_in_game then
		mod.check_spawn_tweaks()
		mod.actually_in_game = true
		-- reset players settings for movement speed
		mod:set(mod.SETTING_NAMES.MOVEMENT_SPEED, PlayerUnitMovementSettings.move_speed)
		-- set the time of the game
		mod:set(mod.SETTING_NAMES.TIME, 13)
	end

	time = time + dt
	if time >= 1 and mod.actually_in_game then
		mod.toggle_infinite_ammo()
		time = 0
	end
end
mod.on_game_state_changed = function(status, state_name)
	if status == "enter" and state_name == "StateIngame" then
		mod.is_in_game = true
	end
end
mod.toggle_infinite_ammo = function()
	if mod.infinite_ammo then
		mod.refresh_infinite_ammo_buffs()
	else
		mod.remove_infinite_ammo_buffs()
	end
end
mod.refresh_infinite_ammo_buffs = function()
	if Managers.player:local_player() then
		local local_player_unit = Managers.player:local_player().player_unit
		if local_player_unit and Unit.alive(local_player_unit) then
			local buff_extension = ScriptUnit.has_extension(local_player_unit, "buff_system")
			if buff_extension then
				buff_extension:add_buff("twitch_no_overcharge_no_ammo_reloads")
			end
		end
	end

	if Managers.player.is_server then
		local players = Managers.player:human_and_bot_players()

		for _, player in pairs(players) do
			local unit = player.player_unit

			if Unit.alive(unit) then
				local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
				if buff_extension and not buff_extension:has_buff_type("twitch_no_overcharge_no_ammo_reloads") then
					local buff_system = Managers.state.entity:system("buff_system")
					local server_controlled = false
					buff_system:add_buff(unit, "twitch_no_overcharge_no_ammo_reloads", unit, server_controlled)
				end
			end
		end
	end
end
mod.remove_infinite_ammo_buffs = function()
	if Managers.player:local_player() then
		local local_player_unit = Managers.player:local_player().player_unit
		if local_player_unit and Unit.alive(local_player_unit) then
			local buff_extension = ScriptUnit.has_extension(local_player_unit, "buff_system")
			if buff_extension and buff_extension:has_buff_type("twitch_no_overcharge_no_ammo_reloads") then
				local inf_ammo_buff = buff_extension:get_non_stacking_buff("twitch_no_overcharge_no_ammo_reloads")
				buff_extension:remove_buff(inf_ammo_buff.id)
			end
		end
	end

	if Managers.player.is_server then
		local players = Managers.player:human_and_bot_players()

		for _, player in pairs(players) do
			local unit = player.player_unit
			if Unit.alive(unit) then
				local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
				if buff_extension and buff_extension:has_buff_type("twitch_no_overcharge_no_ammo_reloads") then
					local inf_ammo_buff = buff_extension:get_non_stacking_buff("twitch_no_overcharge_no_ammo_reloads")
					buff_extension:remove_buff(inf_ammo_buff.id)
				end
			end
		end
	end
end


-- remove infinite ammo buff from spawn tweaks if it exists
mod.check_spawn_tweaks = function()
	local spawn_tweaks = get_mod("SpawnTweaks")

	if not spawn_tweaks then
		return
	end
	spawn_tweaks.infinite_ammo_mutator_update_func = function()
		return
	end
	mod:echo("[Hacks] SpawnTweaks detected, overriding infinite ammo function.")

end
mod:command("infinite_ammo_heat", mod:localize("infinite_ammo_heat_command_description"), function()
	if mod.is_in_game then
		mod.infinite_ammo = not mod.infinite_ammo
		mod.toggle_infinite_ammo()
		if mod.infinite_ammo then
			mod:echo("[Hacks] Unlimited ammo and overheat.")
		else
			mod:echo("[Hacks] Limited ammo and overheat.")
		end
	end
end)


-- unlimited Power
-- set EP to very high value
mod.giga_power = false
mod.giga_power_toggle = function()
	if mod.giga_power then
		BuffTemplates.power_level_unbalance.buffs[1].multiplier = 0.075
		mod.giga_power = false
		mod:echo("[Hacks] GigaPower Disabled, Reequip the talent!")
	else
		BuffTemplates.power_level_unbalance.buffs[1].multiplier = 1000
		mod.giga_power = true
		mod:echo("[Hacks] GigaPower Activated, Reequip the talent!")
	end
end
mod:command("giga_power", mod:localize("giga_power_command_description"), function()
	mod.giga_power_toggle()
end)


-- Base Crit Chance Adjustments for the Using Player
mod.crit_chance_value = 5 -- default is 5 for most careers (exception shade and whc)
mod.get_career_name = function()
	local player = Managers.player:local_player()
	local profile_index = player:profile_index()
	local career_index = player:career_index()
	local profile = SPProfiles[profile_index]
	local career_name = profile.careers[career_index].name

	return career_name
end
mod.crit_chance = function(crit_chance)
	local career_name = mod.get_career_name()
	CareerSettings[career_name].attributes.base_critical_strike_chance = crit_chance
end
mod.on_setting_changed = function()
	-- for crit chance
	if mod.crit_chance_value ~= (mod:get(mod.SETTING_NAMES.CRIT_CHANCE_NUMERIC) / 100) then
		mod.crit_chance_value = mod:get(mod.SETTING_NAMES.CRIT_CHANCE_NUMERIC)
		mod:echo("[Hacks] Set crit chance to: " .. mod.crit_chance_value .. "%%")
		mod.crit_chance_value = mod.crit_chance_value / 100
		mod.crit_chance(mod.crit_chance_value)
	end

	-- for movement speed
	mod.movement_speed()

	-- for time
	mod.time()
end
mod.set_default_crit_chance = function()
	local career_name = mod.get_career_name()
	mod.crit_chance_value = CareerSettings[career_name].attributes.base_critical_strike_chance
	mod.crit_chance_value = mod.crit_chance_value * 100
	mod:set(mod.SETTING_NAMES.CRIT_CHANCE_NUMERIC, mod.crit_chance_value)
end
-- set default crit chance value for mod settings
-- on career changed
mod:hook_safe(ProfileRequester, "request_profile", function(self, ...)
	mod.set_default_crit_chance()
end)
-- on keep entered after choosing career
mod:hook_safe(GameModeInn, "_cb_start_menu_closed", function()
	mod.set_default_crit_chance()
end)


-- infinite stamina
mod.infinite_stamina_function_backup = GenericStatusExtension.add_fatigue_points
mod.infinite_stamina_toggle = false
mod.infinite_stamina = function()
	if mod.infinite_stamina_toggle then
		mod:hook_disable(GenericStatusExtension, "add_fatigue_points", function() end)
		mod:echo("[Hacks] Infinite stamina disabled.")
		mod.infinite_stamina_toggle = false
	else
		mod:hook_origin(GenericStatusExtension, "add_fatigue_points", function() end)
		mod:hook_enable(GenericStatusExtension, "add_fatigue_points", function() end)
		mod:echo("[Hacks] Infinite stamina enabled.")
		mod.infinite_stamina_toggle = true
	end
end
mod:command("infinite_stamina", mod:localize("infinite_stamina_command_description"), function()
	mod.infinite_stamina()
end)


-- movement speed
mod.movement_speed_value = 4 -- default is 4
mod.movement_speed = function()
	if mod.movement_speed_value ~= mod:get(mod.SETTING_NAMES.MOVEMENT_SPEED) then
		mod.movement_speed_value = mod:get(mod.SETTING_NAMES.MOVEMENT_SPEED)
		PlayerUnitMovementSettings.move_speed = mod.movement_speed_value

		local _, units_player_movement_setting = debug.getupvalue(PlayerUnitMovementSettings.unregister_unit, 1)
		if not units_player_movement_setting then return end
		for _, settings in pairs(units_player_movement_setting) do
			settings.move_speed = mod.movement_speed_value
		end
		mod:echo("[Hacks] Movement speed set to: " .. mod.movement_speed_value)
	end
end


-- time scale
-- time values are based on this list;
-- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/dafc183b5b4c6f4940b055b6365a8436d9e43552/scripts/managers/debug/debug_manager.lua#L18
mod.time_scale_value = 13
mod.time = function()
	if mod.time_scale_value ~= mod:get(mod.SETTING_NAMES.TIME) then
		mod.time_scale_value = mod:get(mod.SETTING_NAMES.TIME)
		Managers.state.debug:set_time_scale(mod.time_scale_value)
		mod:echo("[Hacks] Time set to: " .. GLOBAL_TIME_SCALE)
	end
end


-- Force Respawn Dead Players
--[[
mod:command("respawn_dead", mod:localize("force_respawn_dead_players_command_description"), function()
	if DamageUtils.is_in_inn then
		mod:echo("You can't respawn in the Keep")
	else
		GameModeManager:force_respawn_dead_players()
	end
end)
]]

-- Fix restart Sound Bug on command
-- yoinked from the mod from Craven
mod:command("fixSound", mod:localize("fix_sound_command_description"), function() 
    mod.fixSound()
end)
mod.fixSound = function()
    if string.find(Managers.state.game_mode._level_key, "inn_level") then
        mod:echo("[Hacks] Unable to remove sound bug in keep, must be in mission")
        return
    end
    local local_player = Managers.player:local_player()
    local player_unit = local_player.player_unit
    local first_person_extension = ScriptUnit.has_extension(player_unit, "first_person_system")
    first_person_extension:play_hud_sound_event("sfx_player_in_vortex_false")
end


-- Fixes for something
mod:hook(VolumetricsFlowCallbacks, "unregister_fog_volume", function(func, params, ...)
    if (Unit.alive(params.unit)) then
        return func(params, ...)
    end
end)
mod:hook(VolumetricsFlowCallbacks, "unregister_fog_volume",
function(func, params, ...)
	local unit = params.unit

	if not unit or not Unit.alive(unit) then
		return
	end

	return func(params, ...)
end)

mod:hook(Unit, "get_data",
function(func, unit, ...)
	if not unit then
		return
	end

	return func(unit, ...)
end)





--[[
mod:command("get_scoreboard", "sdf", function()
	local player = Managers.player:local_player()
	GameModeAdventure:get_end_screen_config(true, false, player)
	UIManager.activate_end_screen_ui(...)
end)
]]


--[[ TODO

- DONE Echo for ammo toggle
- DONE fix infinite ammo
- check why fail level takes so long
- DONE unlimited power? Table value increased or give player gazillion EP buffs?
- POSTPONED fix bot toggle or remove?, works in photomode
- invisible (does it make clients also invis? schould it?) 
- DONE add restart mod failsave
- DONE Add mod name in brakets before every echo
- DONE rebrand
- DONE thumbnail
- POSTPONED scoreboard thing (win condition func?)
- DONE Crit Chance in percent intervals?
- DONE set the original crit chance upon changing career in
- DONE set it automatically upon changing the settings
- DONE Add Inf Stam
- DONE Add Set Movespeed
- DONE Add custom time scale?
- no reloading ammo ? https://github.com/ronvoluted/darktide-mods/blob/48daad31913115fd4ed6c5a5643c40f8b30db70b/WillOfTheEmperor/scripts/mods/WillOfTheEmperor/modules/bestowments.lua#L165

]]