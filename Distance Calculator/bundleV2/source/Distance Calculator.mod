return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Distance Calculator` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Distance Calculator", {
			mod_script       = "scripts/mods/Distance Calculator/Distance Calculator",
			mod_data         = "scripts/mods/Distance Calculator/Distance Calculator_data",
			mod_localization = "scripts/mods/Distance Calculator/Distance Calculator_localization",
		})
	end,
	packages = {
		"resource_packages/Distance Calculator/Distance Calculator",
	},
}
