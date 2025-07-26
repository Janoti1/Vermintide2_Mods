local mod = get_mod("texture_test")

return {
	name = "Texture Tester",
	description = mod:localize("mod_description"),
	is_togglable = true,
    options = {
        widgets = {
            {
                title = "icon_position_x_title",
                setting_id = "icon_position_x",
                type = "numeric",
                default_value = 960,
                range = {1, 3840},
                tooltip = "icon_position_x_tooltip",
            },
            {
                title = "icon_position_y_title",
                setting_id = "icon_position_y",
                type = "numeric",
                default_value = 540,
                range = {1, 2160},
                tooltip = "icon_position_y_tooltip",
            },
            {
				title = "button_stop_texture_title",
				keybind_trigger = "pressed",
				type = "keybind",
				default_value = {},
				keybind_type = "function_call",
				function_name = "display_toggle",
				setting_id = "texture_test_stop_toggle",
				tootlip = "button_stop_texture_tooltip",
			},
            {
                title = "test_texture_name",
                setting_id = "test_texture_name_setting_id",
                type = "text",
                default_value = " ",
                tootlip = "test_texture_name_tootlip"
            },
        }
    }
}
