local mod = get_mod("Open Inventory In Game")

return {
	name = "Open Inventory In Game",
	description = "mod_description",
	is_togglable = true,
	is_mutator = false,
	mutator_settings = {},
	options = {
		widgets = {
			{
				title = "open_inventory_hotkey_text",
				keybind_trigger = "pressed",
				type = "keybind",
				default_value = {"i"},
				keybind_type = "function_call",
				function_name = "open_inventory",
				setting_id = "open_inventory_toggle",
				tootlip = "open_inventory_hotkey_tooltip",
			},
			{
				setting_id    = "open_character_selection_toggle",
				type          = "checkbox",
				default_value = true,
				tootlip = "open_character_selection_hotkey_tooltip",
			},
			{
				title = "open_character_selection_hotkey_text_x",
				type = "numeric",
				default_value = 156,
				range = {1, 1920},
				setting_id = "window_position_x",
				tootlip = "open_character_selection_hotkey_tooltip_x"
			},
			{
				title = "open_character_selection_hotkey_text_y",
				type = "numeric",
				default_value = 5,
				range = {1, 1080},
				setting_id = "window_position_y",
				tootlip = "open_character_selection_hotkey_tooltip_y"
			}
		}
	}
}
