local mod = get_mod("Helpers 2")

local mod_data = {
	name = "Hacks",
	description = mod:localize("mod_description"),
	is_togglable = true,
	allow_rehooking = true,
}

mod.SETTING_NAMES = {}
for _, setting_name in ipairs( {
	"ULT_RESET_HOTKEY",
	"ULT",
	"ULT_PLAYER",
	"ULT_PLAYER_VALUE",
	"ULT_BOT",
	"ULT_BOT_VALUE",
	"KILL_BOTS_HOTKEY",
	"SUICIDE_HOTKEY",
	"PAUSE",
	"PAUSE_HOTKEY",
	"PAUSE_VALUE",
	"RESTART_LEVEL_HOTKEY",
	"WIN_LEVEL_HOTKEY",
	"FAIL_LEVEL_HOTKEY",
	"INVISIBLE_HOTKEY",
	"CRIT_CHANCE_NUMERIC",
	"MOVEMENT_SPEED",
	"TIME"
} ) do
	mod.SETTING_NAMES[setting_name] = setting_name
end

mod_data.options = {
	widgets = {
		{
			setting_id = mod.SETTING_NAMES.ULT,
			type = "group",
			default_value = false,
			sub_widgets = {
				{
					setting_id = mod.SETTING_NAMES.ULT_RESET_HOTKEY,
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "reset_ult",
					default_value = {},
				},
				{
					setting_id = mod.SETTING_NAMES.ULT_PLAYER,
					type = "checkbox",
					default_value = false,
					sub_widgets = {
						{
							setting_id = mod.SETTING_NAMES.ULT_PLAYER_VALUE,
							type = "numeric",
							range = {0, 120},
							decimal_number = 1,
							default_value = 0
						}
					}
				},
				{
					setting_id = mod.SETTING_NAMES.ULT_BOT,
					type = "checkbox",
					default_value = false,
					sub_widgets = {
						{
							setting_id = mod.SETTING_NAMES.ULT_BOT_VALUE,
							type = "numeric",
							range = {0, 120},
							decimal_number = 1,
							default_value = 0
						}
					}
				},
			}
		},
		{
			setting_id = mod.SETTING_NAMES.KILL_BOTS_HOTKEY,
			type = "keybind",
			keybind_trigger = "pressed",
			keybind_type = "function_call",
			function_name = "kill_bots",
			default_value = {},
		},
		{
			setting_id = mod.SETTING_NAMES.SUICIDE_HOTKEY,
			type = "keybind",
			keybind_trigger = "pressed",
			keybind_type = "function_call",
			function_name = "die",
			default_value = {},
		},
		{
			setting_id = mod.SETTING_NAMES.PAUSE,
			type = "group",
			default_value = false,
			sub_widgets = {
				{
					setting_id = mod.SETTING_NAMES.PAUSE_HOTKEY,
					type = "keybind",
					keybind_trigger = "pressed",
					keybind_type = "function_call",
					function_name = "do_pause",
					default_value = {},
				},
				{
					setting_id = mod.SETTING_NAMES.PAUSE_VALUE,
					type = "numeric",
					default_value = 1,
					range = {1, 24}
				}
			}
		},
		{
		  setting_id = mod.SETTING_NAMES.RESTART_LEVEL_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "restart_level",
		  default_value = {},
		},
		{
		  setting_id = mod.SETTING_NAMES.WIN_LEVEL_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "win_level",
		  default_value = {},
		},
		{
		  setting_id = mod.SETTING_NAMES.FAIL_LEVEL_HOTKEY,
		  type = "keybind",
		  keybind_trigger = "pressed",
		  keybind_type = "function_call",
		  function_name = "fail_level",
		  default_value = {},
		},
		{
			setting_id = mod.SETTING_NAMES.INVISIBLE_HOTKEY,
			type = "keybind",
			keybind_trigger = "pressed",
			keybind_type = "function_call",
			function_name = "invisible",
			default_value = {},
		},
		{
			setting_id = mod.SETTING_NAMES.CRIT_CHANCE_NUMERIC,
			type = "numeric",
			default_value = 5,
			range = {1, 100},
		},
		{
			setting_id = mod.SETTING_NAMES.MOVEMENT_SPEED,
			type = "numeric",
			default_value = 4,
			range = {0, 30},
			decimals_number = 0.1
		},
		{
			setting_id = mod.SETTING_NAMES.TIME,
			type = "numeric",
			default_value = 13,
			range = {1, 24}, -- (time_scale_list)
		},
	},
}

return mod_data