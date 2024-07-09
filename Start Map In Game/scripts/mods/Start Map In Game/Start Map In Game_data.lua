local mod = get_mod("Start Map In Game")

return {
	name = "Start Map In Game",
	description = mod:localize("mod_description"),
	is_togglable = true,
	is_mutator = false,
	mutator_settings = {},
	options = {
		widgets = {
			{
				setting_id = "selected_level",
				tooltip = "selected_level_tooltip",
				type = "dropdown",
				default_value = 1,
				options = mod.map_widgets_localization,
			},
			{
				setting_id = "selected_dlc_level",
				tooltip = "selected_dlc_level_tooltip",
				type = "dropdown",
				default_value = 1,
				options = mod.map_widgets_dlc_localization,
			},
			{
				setting_id = "selected_difficulty",
				tooltip = "selected_difficulty_tooltip",
				type = "dropdown",
				default_value = 5,
				options = mod.difficulty_widgets_localization,
			},
			{
				setting_id = "load_selected",
				tooltip = "load_selected_tooltip",
				type = "checkbox",
				default_value = false,
			},
		}
	}
}
