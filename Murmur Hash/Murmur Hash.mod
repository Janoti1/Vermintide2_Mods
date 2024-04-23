return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Murmur Hash` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Murmur Hash", {
			mod_script       = "scripts/mods/Murmur Hash/Murmur Hash",
			mod_data         = "scripts/mods/Murmur Hash/Murmur Hash_data",
			mod_localization = "scripts/mods/Murmur Hash/Murmur Hash_localization",
		})
	end,
	packages = {
		"resource_packages/Murmur Hash/Murmur Hash",
	},
}
