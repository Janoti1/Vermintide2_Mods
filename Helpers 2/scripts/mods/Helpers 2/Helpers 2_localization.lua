local localization = {
	mod_description = {
		en = 	"Collection of small utilities:"
				.. "\n /reset_ult to reset your ultimate."
				.. "\n /kill_bots to kill all bots."
				.. "\n /pause to savely pause the game."
				.. "\n /restart to restart the current level."
				.. "\n /fixSound to fix the sound issue when restarting whilst in a storm."
				.. "\n /win to win the current level."
				.. "\n /fail to fail the current level."
				--.. "\n /bot_toggle to toggle bots for the current level."
				.. "\n /invincible_toggle to toggle invincibility for you and bots / clients."
				.. "\n /inn_dmg to turn on taking damage in the keep."
				.. "\n /invisible to toggle invisibility."
				.. "\n /die to kill yourself."
				.. "\n /infinite_ammo_heat to get infinite ammo and over heat."
				.. "\n /giga_power to make Enhanced Power a lot stronger (one shot everything)."
	},

	ULT_RESET_HOTKEY = {
		en = "Ult Reset"
	},
	ULT_RESET_HOTKEY_description = {
		en = "Make ult ready."
	},
	reset_ult_command_description = {
		en = "Make ult ready."
	},

	KILL_BOTS_HOTKEY = {
		en = "Kill Bots"
	},
	KILL_BOTS_HOTKEY_description = {
		en = "Hotkey to kill the bots."
	},
	kill_bots_command_description = {
		en = "Kill the bots."
	},

	PAUSE_HOTKEY = {
		en = "Pause"
	},
	PAUSE_HOTKEY_description = {
		en = "Hotkey to pause."
	},
	pause_command_description = {
		en = "Pause or unpause the game. Host only."
	},
	game_paused = {
		en = "[Hacks] Game paused!"
	},
	game_unpaused = {
		en = "[Hacks] Game unpaused!"
	},
	not_server = {
		en = "[Hacks] You need to be host to pause!"
	},

	fail_level_command_description = {
		en = "Lose the level."
	},
	win_level_command_description = {
		en = "Win the level."
	},
	WIN_LEVEL_HOTKEY = {
		en = "Win Level"
	},
	WIN_LEVEL_HOTKEY_description = {
		en = "Win the level hotkey."
	},
	FAIL_LEVEL_HOTKEY = {
		en = "Fail Level"
	},
	FAIL_LEVEL_HOTKEY_description = {
		en = "Fail the level hotkey."
	},
	RESTART_LEVEL_HOTKEY = {
		en = "Restart Level"
	},
	RESTART_LEVEL_HOTKEY_description = {
		en = "Restart the level hotkey."
	},
	restart_level_command_description = {
		en = "Restart the level."
	},

	bot_toggle_command_description = {
		en = 	"Toggle bots on/off for current level."
				.. "\nUse to spawn bots in inn."
				.. "\nInn bots can lead to a rare nav crash."
	},

	invincible_toggle_command_description = {
		en = "Toggle player and bot invincibility."
	},

	inn_damage_command_description = {
		en = "Toggle taking damage in the Keep."
	},

	INVISIBLE_HOTKEY = {
		en = "Invisible"
	},
	INVISIBLE_HOTKEY_description = {
		en = "Hotkey to make yourself invisible."
	},

	die_command_description = {
		en = "Kill yourself."
	},

	infinite_ammo_heat_command_description = {
		en = "Get unlimited ammo and overheat."
	},

	giga_power_command_description = {
		en = "Make Enhanced Power 13333x stronger."
	},

	CRIT_CHANCE_NUMERIC = {
		en = "Set Base Crit Chance"
	},
	CRIT_CHANCE_NUMERIC_description = {
		en = 	"Sets the Base Crit Chance of the current career to the chosen value."
				.. "\nBe aware that this will get restart upon restarting the game."
	}

	--[[
	force_respawn_dead_players_command_description = {
		en = "Respawn dead players."
	},
	]]
}

return localization