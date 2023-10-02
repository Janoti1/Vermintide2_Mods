return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`gk_quest_weave` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("gk_quest_weave", {
			mod_script       = "scripts/mods/gk_quest_weave/gk_quest_weave",
			mod_data         = "scripts/mods/gk_quest_weave/gk_quest_weave_data",
			mod_localization = "scripts/mods/gk_quest_weave/gk_quest_weave_localization",
		})
	end,
	packages = {
		"resource_packages/gk_quest_weave/gk_quest_weave",
	},
}
