return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`GiveWeaponFix` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("GiveWeaponFix", {
			mod_script       = "scripts/mods/GiveWeaponFix/GiveWeaponFix",
			mod_data         = "scripts/mods/GiveWeaponFix/GiveWeaponFix_data",
			mod_localization = "scripts/mods/GiveWeaponFix/GiveWeaponFix_localization",
		})
	end,
	packages = {
		"resource_packages/GiveWeaponFix/GiveWeaponFix",
	},
}
