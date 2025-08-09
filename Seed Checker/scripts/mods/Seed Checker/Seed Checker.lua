--[[

    This mod is a debug tool to check the various seeds used to dictate how a campaign level will play out
    Janoti! - 2025-07-19

]]
local mod = get_mod("Seed Checker")


--[[

██╗░░░░░███████╗██╗░░░██╗███████╗██╗░░░░░  ░██████╗███████╗███████╗██████╗░
██║░░░░░██╔════╝██║░░░██║██╔════╝██║░░░░░  ██╔════╝██╔════╝██╔════╝██╔══██╗
██║░░░░░█████╗░░╚██╗░██╔╝█████╗░░██║░░░░░  ╚█████╗░█████╗░░█████╗░░██║░░██║
██║░░░░░██╔══╝░░░╚████╔╝░██╔══╝░░██║░░░░░  ░╚═══██╗██╔══╝░░██╔══╝░░██║░░██║
███████╗███████╗░░╚██╔╝░░███████╗███████╗  ██████╔╝███████╗███████╗██████╔╝
╚══════╝╚══════╝░░░╚═╝░░░╚══════╝╚══════╝  ╚═════╝░╚══════╝╚══════╝╚═════╝░
]]

mod.temp_seed_save = 0
mod.custom_seed_list = {
    -- Horn of magnum icecream
    ["magnus"] = {
        3060692, -- Map - Chaos Spawn, Rat Ogre
        3060692, -- items
    },
    -- Halescourge
    ["ground_zero"] = {
        3501558, -- Map - Troll Roger
        3501558, -- items
    },
    -- hunger in the dork
    ["mines"] = {
        3079501, -- Map - Troll
        3079501, -- items
    },
    -- empire in tamales
    ["ussingen"] = {
        8785129, -- Map - Troll
        8785129, -- items
    },
}


--[[
    
    Hooks

]]

-- get level key of upcoming level, as soon as the bubble opens (overwrites if the game is cancelled and opened again)
mod:hook_safe(MatchmakingManager, "set_matchmaking_data", function(self, next_mission_id, ...)
	mod.next_level_key = next_mission_id
end)

-- Use custom seed instead of Random Seed
mod:hook(LevelTransitionHandler, "create_level_seed", function ()

    -- custom override
    if mod:get("level_seed_override") and tonumber(mod:get("level_seed")) then
        return tonumber(mod:get("level_seed"))
    end

    -- linesman override
    if mod:get("seed_override_linesman_event") then
        -- get level_key of level that is about to be loaded
        local level_key = mod.next_level_key

        -- check if custom seed exists, if not use rng seed
        if mod.linesman_custom_seeding(level_key, "level") then
            local custom_seed = mod.linesman_custom_seeding(level_key, "level")
            return custom_seed
        end
    end

    return mod.generate_rng_seed()

end)

--[[

    Functions

]]

local function is_at_inn()
    local game_mode = Managers.state.game_mode
    if not game_mode then return nil end
    return game_mode:game_mode_key() == "inn"
end

-- Check if Linesman seeding is enabled, then get the correct seed for the next map from the table
mod.linesman_custom_seeding = function(level_key, seed_type)
    
    if not level_key then
        return false
    end
    
    local custom_seed
    if seed_type == "level" then
        if not mod.custom_seed_list[level_key] then
            return false
        end
        custom_seed = mod.custom_seed_list[level_key][1]
    end

    if seed_type == "item" then
        if not mod.custom_seed_list[level_key] then
            return false
        end
        custom_seed = mod.custom_seed_list[level_key][2]
    end

    return custom_seed
end

-- generate random seed as the game does it
mod.generate_rng_seed = function ()
    local time_since_start = os.clock() * 10000 % 961748927
	local date_time = os.time()
	local low_time = tonumber(tostring(string.format("%d", date_time)):reverse():sub(1, 6))
	local seed = (time_since_start + low_time) % 15485867
	seed = math.floor(seed)

    return seed
end

--[[

    Commands

]]

-- echo a random generated seed
mod:command("seed_rng_generate", "Generates a random level seed.", function()
	mod:echo(mod.generate_rng_seed())
end)

-- echo the level seed of the active level
mod:command("seed_get_level_seed", "Display the seed of the active level.", function()
    local level_seed = Managers.level_transition_handler:get_current_level_seed()
    mod:echo(tostring(level_seed))
end)

--[[

██████╗░██╗░█████╗░██╗░░██╗██╗░░░██╗██████╗░  ░██████╗███████╗███████╗██████╗░
██╔══██╗██║██╔══██╗██║░██╔╝██║░░░██║██╔══██╗  ██╔════╝██╔════╝██╔════╝██╔══██╗
██████╔╝██║██║░░╚═╝█████═╝░██║░░░██║██████╔╝  ╚█████╗░█████╗░░█████╗░░██║░░██║
██╔═══╝░██║██║░░██╗██╔═██╗░██║░░░██║██╔═══╝░  ░╚═══██╗██╔══╝░░██╔══╝░░██║░░██║
██║░░░░░██║╚█████╔╝██║░╚██╗╚██████╔╝██║░░░░░  ██████╔╝███████╗███████╗██████╔╝
╚═╝░░░░░╚═╝░╚════╝░╚═╝░░╚═╝░╚═════╝░╚═╝░░░░░  ╚═════╝░╚══════╝╚══════╝╚═════╝░
]]

mod:hook(PickupSystem, "set_seed", function(func, self, _seed)

    -- custom override
    if mod:get("item_seed_override") and tonumber(mod:get("item_seed")) then
        _seed = tonumber(mod:get("item_seed"))
        self._starting_seed = tonumber(mod:get("item_seed"))
        mod.temp_seed_save = tonumber(mod:get("item_seed"))
        func(self, _seed)
        return
    end

    -- linesman event seed override
    if mod:get("seed_override_linesman_event") then
        -- get level_key of level that is about to be loaded
        local level_key = mod.next_level_key

        -- check if custom seed exists, if not use rng seed
        if mod.linesman_custom_seeding(level_key, "item") then
            local custom_item_seed = mod.linesman_custom_seeding(level_key, "item")
            mod.temp_seed_save = custom_item_seed

            _seed = custom_item_seed
            self._starting_seed = custom_item_seed
            func(self, _seed)
            return
        end
    end

    _seed = mod.generate_rng_seed() --this randomizes the item seed whilst the level seed stays custom
    mod.temp_seed_save = _seed
    self._starting_seed = _seed
    func(self, _seed)
end)

-- echo the item seed of the active level
mod:command("seed_get_item_seed", "Display the seed for the items of the active level.", function()
    mod:echo(tostring(mod.temp_seed_save))
end)

-- echo when loading in a map
mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateIngame" and status == "enter" and not is_at_inn() then
        local level_seed = Managers.level_transition_handler:get_current_level_seed()
        local next_level_key = mod.next_level_key
        if mod:get("item_seed_override") and mod.temp_seed_save == tonumber(mod:get("item_seed")) then
            mod:echo("[Seed Checker] Custom item seed override " .. tostring(mod:get("item_seed")))
        end
        if mod:get("level_seed_override") and level_seed == tonumber(mod:get("level_seed")) then
            mod:echo("[Seed Checker] Custom level seed override " .. tostring(mod:get("level_seed")))
        end
        if mod:get("seed_override_linesman_event") and level_seed == mod.custom_seed_list[next_level_key][1] then
            mod:echo("[Seed Checker] Linesman seed override.")
            mod:echo("[Seed Checker] Level: " .. tostring(mod.custom_seed_list[next_level_key][1]) .. " Items: " .. tostring(mod.custom_seed_list[next_level_key][2]))
        end
    end
end


--[[
    TODO
    - DONE - Put all Loca into localization
    - DONE - Give Name to Checkbox
    - Create Thumbnail
    - Make Tutorial Video
    - DONE - Expand List
    - DONE - Allow Option to have players use their own seeds
    - DONE - maybe use prismisms vmf update text field thing?

    local mod = get_mod("VMF")
    mod:echo(tostring(Managers.level_transition_handler:get_current_level_seed()))

]]