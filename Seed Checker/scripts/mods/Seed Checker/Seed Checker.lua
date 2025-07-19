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
    -- Screaming Bell
    ["bell"] = {
        1703842, -- pat monster pat. with a roger on 2nd trigger
    },
    -- Halescourge
    ["ground_zero"] = {
        3501558, -- halescourge troll pat roger
    },
}
mod.custom_item_seed_list = {}


--[[
    
    Hooks

]]

-- get level key of upcoming level, as soon as the bubble opens (overwrites if the game is cancelled and opened again)
mod:hook_safe(MatchmakingManager, "set_matchmaking_data", function(self, next_mission_id, ...)
	mod.next_level_key = next_mission_id
end)

-- Use custom seed instead of Random Seed
mod:hook_origin(LevelTransitionHandler, "create_level_seed", function ()
    if mod:get("seed_override") then
        -- get level_key of level that is about to be loaded
        local level_key = mod.next_level_key

        -- check if custom seed exists, if not use rng seed
        if mod.custom_seeding(level_key, "level") then
            local custom_seed = mod.custom_seeding(level_key)
            return custom_seed
        end
    end
    
    return mod.generate_rng_seed()

end)

--[[

    Functions

]]

-- Check if custom seeding is enabled, then get the correct seed for the next map from the table
mod.custom_seeding = function(level_key, seed_type)
    local custom_seed
    if seed_type == "item" then
        if not mod.custom_item_seed_list[level_key] then
            mod:echo("[Seed Checker] No item seeds for upcoming level '" .. tostring(level_key) .. "' found.")
            return false
        end

        custom_seed = mod.custom_item_seed_list[level_key][1]
        mod:echo("[Seed Checker] Using custom item seed '" .. tostring(custom_seed) .. "'.")
    elseif seed_type == "level" then
        if not mod.custom_seed_list[level_key] then
            mod:echo("[Seed Checker] No level seeds for upcoming level '" .. tostring(level_key) .. "' found.")
            return false
        end

        custom_seed = mod.custom_seed_list[level_key][1]
        mod:echo("[Seed Checker] Using custom level seed '" .. tostring(custom_seed) .. "'.")
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

    -- get level_key of level that is about to be loaded
    local level_key = mod.next_level_key

    -- check if custom seed exists, if not use rng seed
    if mod.custom_seeding(level_key, "item") then
        local custom_item_seed = mod.custom_seeding(level_key)
        mod.temp_seed_save = custom_item_seed

        self._seed = custom_item_seed
	    self._starting_seed = custom_item_seed
    else
        _seed = mod.generate_rng_seed() --this randomizes the item seed whilst the level seed stays custom
        mod.temp_seed_save = _seed
        func(self, _seed)
    end
end)

-- echo the item seed of the active level
mod:command("seed_get_item_seed", "Display the seed for the items of the active level.", function()
    mod:echo(tostring(mod.temp_seed_save))
end)


--[[
    TODO
    - Put all Loca into localization
    - Give Name to Checkbox
    - Create Thumbnail
    - Make Tutorial Video
    - Expand List
    - Allow Option to have players use their own seeds
        - maybe use prismisms vmf update text field thing?

]]