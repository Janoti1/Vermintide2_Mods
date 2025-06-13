local localization = {
	mod_description = {
		en = 	"Collection of small utilities:"
				.. "\n /ult_reset to reset your ultimate."
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
				.. "\n /infinite_stamina to get infinite stamina."
				.. "\n /giga_power to make Enhanced Power a lot stronger (one shot everything)."
				.. "\n /spawns_toggle to toggle spawns and pacing."
				.. "\n /unkillable to make yourself unkillable but still take damage."
	},

	ULT = {
		en = "Ult"
	},
	ULT_description = {
		en = "Various Ult related Options."
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

	ULT_PLAYER = {
		en = "Player"
	},
	ULT_PLAYER_description = {
		en = "Toggle player ult time adjustments."
	},

	ULT_PLAYER_VALUE = {
		en = "Player Ult time"
	},
	ULT_PLAYER_VALUE_description = {
		en = "Ult cooldown length for players in seconds."
	},

	ULT_BOT = {
		en = "Bots"
	},
	ULT_BOT_description = {
		en = "Toggle bots ult time adjustments."
	},

	ULT_BOT_VALUE = {
		en = "Bots Ult time"
	},
	ULT_BOT_VALUE_description = {
		en = "Ult cooldown length for bots in seconds."
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

	PAUSE = {
		en = "Pause"
	},
	PAUSE_description = {
		en = "Various pause options."
	},
	PAUSE_HOTKEY = {
		en = "Pause"
	},
	PAUSE_HOTKEY_description = {
		en = "Hotkey to pause."
	},
	PAUSE_VALUE = {
		en = "Pause Value"
	},
	PAUSE_VALUE_description = {
		en = "Adjust the Slowdown of Pause:"
			.. "\n 1 = Slowest possible"
			.. "\n 6 = Slowest to still interact with UI"
			.. "\n 13 = Normal Speed"
			.. "\n >13 = Faster than Normal Speed"
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

	SUICIDE_HOTKEY = {
		en = "Suicide"
	},
	SUICIDE_HOTKEY_description = {
		en = "Hotkey to kill yourself."
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
		en = "Base Crit Chance"
	},
	CRIT_CHANCE_NUMERIC_description = {
		en = 	"Sets the Base Crit Chance of the current career to the chosen value."
				.. "\nBe aware that this will get reset upon restarting the game."
	},

	infinite_stamina_command_description = {
		en = "Get unlimited stamina."
	},

	fix_sound_command_description = {
		en = "Fix sound being bugged after restarting"
	},

	unkillable_command_description = {
		en = "Make yourself unkillable but still take damage."
	},

	MOVEMENT_SPEED = {
		en = "Movement Speed"
	},
	MOVEMENT_SPEED_description = {
		en = 	"Set your movement speed. Default is 4."
				.. "\nBe aware that this will get reset upon restarting the game."
	},

	TIME = {
		en = "Time"
	},
	TIME_description = {
		en = 	"Set the game time to have slow motion or speed it up. Default is 13."
				.. "\nThe number resembles a specified time interval from a list in the code."
				.. "\nThe lower the slower."
				.. "\nBe aware that this will get reset upon restarting the game."
	},

	spawns_toggle_command_description = {
		en = "Toggle enemy spawns and pacing."
	},

	--[[
	force_respawn_dead_players_command_description = {
		en = "Respawn dead players."
	},
	]]
}

return localization