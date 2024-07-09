local mod = get_mod("Start Map In Game")

-- main functionality
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


-- interaction with VMF menu and tables
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
            level = mod.map_widgets[level_number].text
            mod:set("load_selected", false)
        elseif mod:get("selected_dlc_level") > 1 and mod:get("selected_level") == 1 then
            level_number = mod:get("selected_dlc_level")
            level = mod.map_widgets_dlc[level_number].text
            mod:set("load_selected", false)
        else
            mod:echo("[SMIG] No map selected.")
            mod:set("load_selected", false)
            return
        end

        mod.load_level(level)
        mod.set_difficulty = true

    end
end

-- set the difficulty once loaded into the level,
-- if the level was loaded via the mod
mod.on_game_state_changed = function(status, state)
    -- set Load Selected to false always, so when the player crashes and loads back in it's not ticked
    if status == "enter" and state == "StateIngame" then
        mod:set("load_selected", false)
    end
	if status == "enter" and state == "StateIngame" and mod.set_difficulty then

        -- if no diff is selected select Cataclysm instead
        if mod:get("selected_difficulty") == 1 then
            mod:set("selected_difficulty", 6)
        end
        
        local difficulty = mod.difficulty_widgets[mod:get("selected_difficulty")].text
        mod.change_level_difficulty(difficulty)
        mod.set_difficulty = false
	end
end

--[[
mod:hook(Presence, "set_presence", function(func, key, value)
    if key == "versus_base" then
      func(key, "versus_base")
    else
      func(key, value)
    end
end)
]]

-- Extra Commands
mod:command("load_level", "Load a level by its level_key.", function(level)
    mod.load_level(level)
end)

mod:command("set_difficulty", "Set the difficulty of the current level.", function(difficulty)
    mod.change_level_difficulty(difficulty)
end)

mod:command("current_level", "get the current level_key name", function()
    mod:echo(tostring(mod.get_current_level()))
end)



--[[

    TODO
    - DONE categorise the dlc maps for another set of dropdowns
    - DONE add localisation
    - remove < > from map names (optional)
    - DONE Best just all dlc things into a seperate dropdown dlc_bogenhafen, dlc_dwarf, dlc_celebrate, dlc_wizards

    -- UnlockableLevelsByGameMode.tutorial --> prologue
    -- UnlockableLevelsByGameMode.deus --> 367 Maps?

]]