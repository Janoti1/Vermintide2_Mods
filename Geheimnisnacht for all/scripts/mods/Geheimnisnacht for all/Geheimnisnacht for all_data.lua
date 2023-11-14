local mod = get_mod("Geheimnisnacht for all")

mod:hook("Localize", function(func, id, ...)
	if not id then return end

	local localized = func(id, ...)

	if id == "halloween_eyes" then
		localized = mod:localize("halloween_eyes")
	end
	if id == "halloween_eyes_description" then
		localized = mod:localize("halloween_eyes_description")
	end

	return localized
end)

return {
	name = "Geheimnisnacht Unlimited",
	description = mod:localize("mod_description"),
	is_togglable = true,
	custom_gui_textures = {
		textures = {
			"mutator_icon_glowing_eyes"
		},
		ui_renderer_injections = {
			{
				"ingame_ui",
				"materials/Geheimnisnacht for all/mutator_icon_glowing_eyes"
			}
		}
	},
	options = {
		widgets =
		{
			{
				setting_id    = "geheimnisnacht_2021",
				type          = "checkbox",
				default_value = false,
				tooltip = "geheimnisnacht_2021_tooltip",
			},
			{
				setting_id    = "geheimnisnacht_2023",
				type          = "checkbox",
				default_value = true,
				tooltip = "geheimnisnacht_2023_tooltip",
			},
			{
				setting_id    = "night_mode",
				type          = "checkbox",
				default_value = true,
				tooltip = "night_mode_tooltip",
			},
			{
				setting_id    = "change_eye_color",
				type          = "checkbox",
				default_value = false,
				tooltip = "change_eye_color_tooltip",
			},
			{
				setting_id    = "skulls_2023",
				type          = "checkbox",
				default_value = false,
				tooltip = "skulls_2023_tooltip",
			},
		}
	},

}
