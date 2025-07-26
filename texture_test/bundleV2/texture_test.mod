return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`texture_test` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("texture_test", {
			mod_script       = "scripts/mods/texture_test/texture_test",
			mod_data         = "scripts/mods/texture_test/texture_test_data",
			mod_localization = "scripts/mods/texture_test/texture_test_localization",
		})
	end,
	packages = {
		"resource_packages/texture_test/texture_test",
	},
}
