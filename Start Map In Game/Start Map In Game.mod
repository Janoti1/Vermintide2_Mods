return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Start Map In Game` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Start Map In Game", {
			mod_script       = "scripts/mods/Start Map In Game/Start Map In Game",
			mod_data         = "scripts/mods/Start Map In Game/Start Map In Game_data",
			mod_localization = "scripts/mods/Start Map In Game/Start Map In Game_localization",
		})
	end,
	packages = {
		"resource_packages/Start Map In Game/Start Map In Game",
	},
}
