local mod = get_mod("Disable Repel Sound Effect")

return {
	name = "Disable Repel Sound Effect",
	description = mod:localize("mod_description"),
	is_togglable = false,
	options = {
		widgets =
		{
			{
				setting_id    = "disable_repel_sound_effect_id",
				type          = "checkbox",
				default_value = true,
				tooltip = "disable_repel_sound_effect_tooltip",
			}
		}
	}
}
