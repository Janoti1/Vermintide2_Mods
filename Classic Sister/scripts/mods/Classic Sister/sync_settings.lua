local mod = get_mod("Classic Sister")

local settings_sync_package_id = "settings_sync"
local enable_old_radiant_setting_id = "classic_sister_enable_old_radiant"
local enable_old_moonbow_setting_id = "classic_sister_enable_old_moonbow"
local disable_repel_sound_setting_id = "classic_sister_disable_repel_sound"
mod.settings = {
 	enable_old_radiant = true,
	enable_old_moonbow = false,
 	disable_repel_sound = false
}

-- Change settings
local function print_settings()
	mod:echo("Old radiant " .. (mod.settings.enable_old_radiant and "enabled" or "disabled") .. ".")
	mod:echo("Old moonbow " .. (mod.settings.enable_old_moonbow and "enabled" or "disabled") .. ".")
	mod:echo("Repel sound " .. (mod.settings.disable_repel_sound and "disabled" or "enabled") .. ".")
end

local function load_mod_settings()
	mod.settings.enable_old_radiant = mod:get(enable_old_radiant_setting_id)
	mod.settings.enable_old_moonbow = mod:get(enable_old_moonbow_setting_id)
	mod.settings.disable_repel_sound = mod:get(disable_repel_sound_setting_id)
	mod.apply_settings()
end

local function sync_mod_settings()
	mod:echo("Syncing settings with clients.")
	mod:network_send(
		settings_sync_package_id,
		"others",
		mod.settings.enable_old_radiant,
		mod.settings.enable_old_moonbow,
		mod.settings.disable_repel_sound
	)
end

function mod:on_setting_changed()
	mod:echo("Local settings changed.")
	if Managers.player.is_server then
		load_mod_settings()
		sync_mod_settings()
	else
		mod:echo("Only the host can change the settings.")
	end
	print_settings()
end

mod.on_user_joined = function(player)
	mod:echo("New player '" .. player:name() .. "' joined.")
	if Managers.player.is_server then
		sync_mod_settings()
	end
end

mod:network_register(settings_sync_package_id, function(sender, host_enable_old_radiant, host_enable_old_moonbow, host_disable_repel_sound)
	mod:echo("Received settings from host.")

	mod.settings.enable_old_radiant = host_enable_old_radiant
	mod.settings.enable_old_moonbow = host_enable_old_moonbow
	mod.settings.disable_repel_sound = host_disable_repel_sound

	mod.apply_settings()
	print_settings()
end)

-- load host settings again after leaving another host as client
mod.on_game_state_changed = function(status, state_name)
	if status == "enter" and state_name == "StateIngame" and is_at_inn() then
		if Managers.player.is_server then
			mod:echo("Adjusting Settings.")
			load_mod_settings()
		end
	end
end

load_mod_settings()

-- TODO when exiting the game and beeing host adjust values to settings again