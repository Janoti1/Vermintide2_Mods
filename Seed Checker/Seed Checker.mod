return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Seed Checker` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Seed Checker", {
			mod_script       = "scripts/mods/Seed Checker/Seed Checker",
			mod_data         = "scripts/mods/Seed Checker/Seed Checker_data",
			mod_localization = "scripts/mods/Seed Checker/Seed Checker_localization",
		})
	end,
	packages = {
		"resource_packages/Seed Checker/Seed Checker",
	},
}
