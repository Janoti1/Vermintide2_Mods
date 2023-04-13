return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Handmaiden Adjust` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Handmaiden Adjust", {
			mod_script       = "scripts/mods/Handmaiden Adjust/Handmaiden Adjust",
			mod_data         = "scripts/mods/Handmaiden Adjust/Handmaiden Adjust_data",
			mod_localization = "scripts/mods/Handmaiden Adjust/Handmaiden Adjust_localization",
		})
	end,
	packages = {
		"resource_packages/Handmaiden Adjust/Handmaiden Adjust",
	},
}
