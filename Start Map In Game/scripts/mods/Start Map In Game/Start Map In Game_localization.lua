local mod = get_mod("Start Map In Game")

--[[

	Create Map and Diff tables

]]

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

-- create dropdown for diff with global variable
mod.difficulty_widgets = {}
table.insert(mod.difficulty_widgets, {text = "none", value = 1})
for i, difficulty_name in ipairs( Difficulties ) do
	table.insert(mod.difficulty_widgets, {
		text = difficulty_name, value = i+1,
	})
end


--[[

	Localization

]]

-- deepClone function to generate copied loca lookup tables
local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end
local game_localize = Managers.localizer

-- loca table and general localization
mod.localization = {}
mod.localization = {
	mod_description = {
		en = "Start a campaign map with a selectable difficulty from anywhere."
	},
	selected_level = {
		en = "Level"
	},
	selected_level_tooltip = {
		en = "Base game level selection dropdown."
	},
	selected_dlc_level = {
		en = "DLC Level"
	},
	selected_dlc_level_tooltip = {
		en = "DLC level selection dropdown."
	},
	selected_difficulty = {
		en = "Difficulty"
	},
	selected_difficulty_tooltip = {
		en = "Difficulty selection dropdown."
	},
	load_selected = {
		en = "Load Selected"
	},
	load_selected_tooltip = {
		en = "Load the selected map with the selected difficulty."
	}
}

-- Difficulty Names Table
mod.difficulty_mapping = {
	normal = "Recruit",
	hard = "Veteran",
	harder = "Champion",
	hardest = "Legend",
	cataclysm = "Cataclysm",
	cataclysm_2 = "Cataclysm 2",
	cataclysm_3 = "Cataclysm 3",
	versus_base = "versus_base",
}

-- create loca table with loca code names instead of the ingame ones
mod.difficulty_widgets_localization = deepCopy(mod.difficulty_widgets)
mod.map_widgets_localization = deepCopy(mod.map_widgets)
mod.map_widgets_dlc_localization = deepCopy(mod.map_widgets_dlc)

for key, value in pairs(mod.difficulty_widgets_localization) do
	if key and key > 1 then
		local code_diff_name = mod.difficulty_widgets_localization[key].text
		mod.difficulty_widgets_localization[key].text = code_diff_name .. "_loca"
	end
end
for key, value in pairs(mod.map_widgets_localization) do
	if key and key > 1 then
		local code_map_name = mod.map_widgets_localization[key].text
		mod.map_widgets_localization[key].text = code_map_name .. "_loca"
	end
end
for key, value in pairs(mod.map_widgets_dlc_localization) do
	if key and key > 1 then
		local code_map_name = mod.map_widgets_dlc_localization[key].text
		mod.map_widgets_dlc_localization[key].text = code_map_name .. "_loca"
	end
end


-- adding localized strings to en
-- reads the table and the entry's name is used as key in the for loop to add the
-- localized text to it
for key, value in pairs(mod.difficulty_widgets_localization) do
	if key and key > 1 then
		local code_difficulty_name_localization = mod.difficulty_widgets_localization[key].text
		key = string.sub(mod.difficulty_widgets_localization[key].text, 0, -6)
		local localized_text = mod.difficulty_mapping[key]

		mod.localization[code_difficulty_name_localization] = {}
		mod.localization[code_difficulty_name_localization].en = localized_text
	end
end

for key, value in pairs(mod.map_widgets_localization) do
	if key and key > 1 then
		-- write the code name + _loca into a variable
		local code_map_name_localization = mod.map_widgets_localization[key].text
		
		-- remove the _loca part from the text to get the og code name
		key = string.sub(mod.map_widgets_localization[key].text, 0, -6)
		
		-- get the display name localization code name
		-- through the reference lookup the localized string how it is displayed in game
		local display_name_reference = LevelSettings[key].display_name
		local localized_text = game_localize:_base_lookup(display_name_reference)

		-- add the string to the mods loca table
		mod.localization[code_map_name_localization] = {}
		mod.localization[code_map_name_localization].en = localized_text
	end
end

for key, value in pairs(mod.map_widgets_dlc_localization) do
	if key and key > 1 then
		-- write the code name + _loca into a variable
		local code_map_name_localization = mod.map_widgets_dlc_localization[key].text
		
		-- remove the _loca part from the text to get the og code name
		key = string.sub(mod.map_widgets_dlc_localization[key].text, 0, -6)
		
		-- get the display name localization code name
		-- through the reference lookup the localized string how it is displayed in game
		local display_name_reference = LevelSettings[key].display_name
		local localized_text = game_localize:_base_lookup(display_name_reference)

		-- add the string to the mods loca table
		mod.localization[code_map_name_localization] = {}
		mod.localization[code_map_name_localization].en = localized_text
	end
end


return mod.localization
