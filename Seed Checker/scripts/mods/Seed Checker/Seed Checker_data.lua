local mod = get_mod("Seed Checker")

return {
	name = "Seed Checker",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
                setting_id = "seed_override",
                type = "checkbox",
                default_value = false
            },
        }
    }
}
