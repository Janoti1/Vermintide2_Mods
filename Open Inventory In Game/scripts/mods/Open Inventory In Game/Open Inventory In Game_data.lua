local mod = get_mod("Open Inventory In Game")

return {
	name = "Open Inventory In Game",
	description = mod:localize("mod_description"),
	is_togglable = true,
	is_mutator = false,
	custom_gui_textures = {
		textures = {
			"open_inventory_swap_icon"
		},
		ui_renderer_injections = {
			{
				"ingame_ui",
				"materials/open_inventory_swap_icon"
			}
		}
	},
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
		}
	}
}
