local mod = get_mod("Start Map In Game")

-- create drop downs for maps, by splitting them by dlc or not
mod.map_widgets = {}
mod.map_widgets_dlc = {}
table.insert(mod.map_widgets, {text = "none", value = 1})
table.insert(mod.map_widgets_dlc, {text = "none", value = 1})

local map = 1
local map_dlc = 1
for i, map_name in ipairs( UnlockableLevelsByGameMode.adventure ) do
	if string.sub(map_name, 1, 3) == "dlc" then
		map_dlc = map_dlc + 1
		table.insert(mod.map_widgets_dlc, {
			text = map_name, value = map_dlc,
		})
	else
		map = map + 1
		table.insert(mod.map_widgets, {
			text = map_name, value = map,
		})
	end
end

-- UnlockableLevelsByGameMode.tutorial --> prologue
-- UnlockableLevelsByGameMode.deus --> 367 Maps?

-- create dropdown for diff with global variable
mod.difficulty_widgets = {}
table.insert(mod.difficulty_widgets, {text = "none", value = 1})
for i, difficulty_name in ipairs( Difficulties ) do
	table.insert(mod.difficulty_widgets, {
		text = difficulty_name, value = i+1,
	})
end


return {
	name = "Start Map In Game",
	description = mod:localize("mod_description"),
	is_togglable = true,
	is_mutator = false,
	mutator_settings = {},
	options = {
		widgets = {
			{
				setting_id = "selected_level",
				tooltip = "selected_level_tooltip",
				type = "dropdown",
				default_value = 1,
				options = mod.map_widgets,
			},
			{
				setting_id = "selected_dlc_level",
				tooltip = "selected_dlc_level_tooltip",
				type = "dropdown",
				default_value = 1,
				options = mod.map_widgets_dlc,
			},
			{
				setting_id = "selected_difficulty",
				tooltip = "selected_difficulty_tooltip",
				type = "dropdown",
				default_value = 5,
				options = mod.difficulty_widgets,
			},
			{
				setting_id = "load_selected",
				tooltip = "load_selected_tooltip",
				type = "checkbox",
				default_value = false,
			},
		}
	}
}
