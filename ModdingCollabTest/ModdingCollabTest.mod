return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ModdingCollabTest` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("ModdingCollabTest", {
			mod_script       = "scripts/mods/ModdingCollabTest/ModdingCollabTest",
			mod_data         = "scripts/mods/ModdingCollabTest/ModdingCollabTest_data",
			mod_localization = "scripts/mods/ModdingCollabTest/ModdingCollabTest_localization",
		})
	end,
	packages = {
		"resource_packages/ModdingCollabTest/ModdingCollabTest",
	},
}
