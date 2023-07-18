local mod = get_mod("EventPractice2")

return {
	name = "EventPractice2",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
			{
				title = "toevent",
				type = "keybind",
				keybind_trigger = "pressed",
				setting_id = "toevent",
				keybind_type = "function_call",
				function_name = "toevent",
				default_value = {}
			},
			{
                setting_id = "get_loot_rats",
                type = "checkbox",
                default_value = false
            },
			{
                setting_id = "composition_chat_output",
                type = "checkbox",
                default_value = true
            },
			{
                setting_id = "composition",
                type = "checkbox",
                default_value = false
            },
			{
                setting_id = "composition_offset_x",
                type = "numeric",
                default_value = 75,
                range = {1, 100}
            }, 
			{
                setting_id = "composition_offset_y",
                type = "numeric",
                default_value = 1,
                range = {1, 100}
            },
			{
                setting_id = "pacing",
                type = "checkbox",
                default_value = false
            },
			{
                setting_id = "pacing_font_size",
                type = "numeric",
                default_value = 26,
                range = {1, 100}
            },
			{
                setting_id = "pacing_offset_x",
                type = "numeric",
                default_value = 1,
                range = {1, 100}
            }, 
			{
                setting_id = "pacing_offset_y",
                type = "numeric",
                default_value = 1,
                range = {1, 100}
            },
            {
                setting_id = "intensity",
                type = "checkbox",
                default_value = false
            },
			{
                setting_id = "intensity_offset_x",
                type = "numeric",
                default_value = 84,
                range = {1, 100}
            },
			{
                setting_id = "intensity_offset_y",
                type = "numeric",
                default_value = 15,
                range = {1, 100}
            },
        }
    }
}
