return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Captions fix` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Captions fix", {
			mod_script       = "scripts/mods/Captions fix/Captions fix",
			mod_data         = "scripts/mods/Captions fix/Captions fix_data",
			mod_localization = "scripts/mods/Captions fix/Captions fix_localization",
		})
	end,
	packages = {
		"resource_packages/Captions fix/Captions fix",
	},
}
