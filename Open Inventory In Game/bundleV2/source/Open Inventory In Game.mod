return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Open Inventory In Game` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Open Inventory In Game", {
			mod_script       = "scripts/mods/Open Inventory In Game/Open Inventory In Game",
			mod_data         = "scripts/mods/Open Inventory In Game/Open Inventory In Game_data",
			mod_localization = "scripts/mods/Open Inventory In Game/Open Inventory In Game_localization",
		})
	end,
	packages = {
		"resource_packages/Open Inventory In Game/Open Inventory In Game",
	},
}
