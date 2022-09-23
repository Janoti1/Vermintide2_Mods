local mod = get_mod("Classic Sister")

return {
	name = "Classic Sister",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "classic_sister_enable_old_radiant",
				type          = "checkbox",
				tooltip       = "radiant_tooltip",
				default_value = false
			},
			{
				setting_id    = "classic_sister_enable_old_moonbow",
				type          = "checkbox",
				tooltip       = "moonbow_tooltip",
				default_value = false
			},
			{
				setting_id    = "classic_sister_disable_repel_sound",
				type          = "checkbox",
				tooltip       = "repel_tooltip",
				default_value = false
			}
		}
	}
}