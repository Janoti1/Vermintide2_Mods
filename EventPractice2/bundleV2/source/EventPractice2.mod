return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`EventPractice2` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("EventPractice2", {
			mod_script       = "scripts/mods/EventPractice2/EventPractice2",
			mod_data         = "scripts/mods/EventPractice2/EventPractice2_data",
			mod_localization = "scripts/mods/EventPractice2/EventPractice2_localization",
		})
	end,
	packages = {
		"resource_packages/EventPractice2/EventPractice2",
	},
}
