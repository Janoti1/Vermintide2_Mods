return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Classic Sister` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Classic Sister", {
			mod_script       = "scripts/mods/Classic Sister/Classic Sister",
			mod_data         = "scripts/mods/Classic Sister/Classic Sister_data",
			mod_localization = "scripts/mods/Classic Sister/Classic Sister_localization",
		})
	end,
	packages = {
		"resource_packages/Classic Sister/Classic Sister",
	},
}
