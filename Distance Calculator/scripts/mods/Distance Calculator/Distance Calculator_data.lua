local mod = get_mod("Distance Calculator")

return {
	name = "Distance Calculator",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				title = "save_location_text",
				keybind_trigger = "pressed",
				type = "keybind",
				default_value = {},
				keybind_type = "function_call",
				function_name = "location_save",
				setting_id = "save_location",
				tootltip = "save_location_tootltip"
			},
			{
				title = "calculate_location_text",
				keybind_trigger = "pressed",
				type = "keybind",
				default_value = {},
				keybind_type = "function_call",
				function_name = "location_calculate",
				setting_id = "calculate_location",
				tootltip = "calculate_location_tootltip"
			}
		}
	}
}
