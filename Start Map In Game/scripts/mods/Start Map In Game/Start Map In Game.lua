local mod = get_mod("Start Map In Game")

mod.set_difficulty = false
mod.get_current_level = function()
    return Managers.state.game_mode._level_key
end

mod.load_level = function(level_name)
    Managers.state.game_mode:start_specific_level(level_name)
end

mod.change_level_difficulty = function(difficulty)
    Managers.state.difficulty:set_difficulty(difficulty, 0) -- no tweaks
end

-- check the two level dropdowns and get the correct level_key from the table
mod.on_setting_changed = function()
    if mod:get("load_selected") then

        local level = ""
        local level_number = 0
        if mod:get("selected_level") > 1 and mod:get("selected_dlc_level") > 1 then
            mod:echo("[SMIG] You can't start two levels. Please set one dropdown to none.")
            mod:set("load_selected", false)
            return
        elseif mod:get("selected_level") > 1 and mod:get("selected_dlc_level") == 1 then
            level_number = mod:get("selected_level")
            level = string.sub(mod.map_widgets[level_number].text, 2, -2)
        elseif mod:get("selected_dlc_level") > 1 and mod:get("selected_level") == 1 then
            level_number = mod:get("selected_dlc_level")
            level = string.sub(mod.map_widgets_dlc[level_number].text, 2, -2)
        else
            mod:echo("[SMIG] No map selected.")
            mod:set("load_selected", false)
            return
        end

        mod:echo(level_number)
        mod:echo(tostring(#mod.map_widgets_dlc))
        mod:echo(level)

        mod.load_level(level)
        mod.set_difficulty = true

    end
end

-- set the difficulty once loaded into the level,
-- if the level was loaded via the mod
mod.on_game_state_changed = function(status, state)
	if status == "enter" and state == "StateIngame" and mod.set_difficulty then
        if mod:get("selected_difficulty") == 1 then
            mod:set("selected_difficulty", 6)
        end
        local difficulty = Difficulties[mod:get("selected_difficulty") - 1] -- slot 1 is none here but normal in global
		mod.change_level_difficulty(difficulty)
        mod.set_difficulty = false
        mod:set("load_selected", false)
	end
end

mod:command("dump_table", "", function()
    mod:dump(mod.map_widgets_dlc, "dlc_level", 5)
end)


--[[

    TODO
    - DONE categorise the dlc maps for another set of dropdowns
    - add localisation
    - remove < > from map names (optional)
    - DONE Best just all dlc things into a seperate dropdown dlc_bogenhafen, dlc_dwarf, dlc_celebrate, dlc_wizards

]]