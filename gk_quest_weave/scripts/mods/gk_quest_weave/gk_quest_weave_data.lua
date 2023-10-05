local mod = get_mod("gk_quest_weave")

return {
	name = "Grail Knight Quest Fix",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id    = "gk_quest_balance",
				type          = "checkbox",
				default_value = false,
				tootlip = "gk_quest_balance_description",
			},
		}
	}
}
