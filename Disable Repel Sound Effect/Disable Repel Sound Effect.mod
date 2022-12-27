return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Disable Repel Sound Effect` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Disable Repel Sound Effect", {
			mod_script       = "scripts/mods/Disable Repel Sound Effect/Disable Repel Sound Effect",
			mod_data         = "scripts/mods/Disable Repel Sound Effect/Disable Repel Sound Effect_data",
			mod_localization = "scripts/mods/Disable Repel Sound Effect/Disable Repel Sound Effect_localization",
		})
	end,
	packages = {
		"resource_packages/Disable Repel Sound Effect/Disable Repel Sound Effect",
	},
}
