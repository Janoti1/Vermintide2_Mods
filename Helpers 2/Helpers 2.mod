return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Helpers 2` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Helpers 2", {
			mod_script       = "scripts/mods/Helpers 2/Helpers 2",
			mod_data         = "scripts/mods/Helpers 2/Helpers 2_data",
			mod_localization = "scripts/mods/Helpers 2/Helpers 2_localization",
		})
	end,
	packages = {
		"resource_packages/Helpers 2/Helpers 2",
	},
}
