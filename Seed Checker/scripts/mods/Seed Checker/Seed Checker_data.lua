local mod = get_mod("Seed Checker")

return {
	name = mod:localize("mod_name"),
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = {
            {
                setting_id = "custom_seeds",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "level_seed_override",
                        type = "checkbox",
                        default_value = false,
                        title = "level_seed_override_title",
                        tooltip = "level_seed_override_description",
                    },
                    {
                        title = "level_seed_title",
                        setting_id = "level_seed",
                        type = "text",
                        default_value = " ",
                        tootlip = "level_seed_description"
                    },
                    {
                        setting_id = "item_seed_override",
                        type = "checkbox",
                        default_value = false,
                        title = "item_seed_override_title",
                        tooltip = "item_seed_override_description",
                    },
                    {
                        title = "item_seed_override_title",
                        setting_id = "item_seed",
                        type = "text",
                        default_value = " ",
                        tootlip = "item_seed_override_description"
                    },
                },
            },
            {
                setting_id = "seed_override_linesman_event",
                type = "checkbox",
                default_value = false,
                title = "seed_override_linesman_event_title",
                tooltip = "seed_override_linesman_event_description",
            },
        }
    }
}
