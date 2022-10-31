return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Geheimnisnacht for all` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Geheimnisnacht for all", {
			mod_script       = "scripts/mods/Geheimnisnacht for all/Geheimnisnacht for all",
			mod_data         = "scripts/mods/Geheimnisnacht for all/Geheimnisnacht for all_data",
			mod_localization = "scripts/mods/Geheimnisnacht for all/Geheimnisnacht for all_localization",
		})
	end,
	packages = {
		"resource_packages/Geheimnisnacht for all/Geheimnisnacht for all",
	},
}
