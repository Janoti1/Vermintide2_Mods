local mod = get_mod("EventPractice2")

-- All Rights and Credits go to Craven
-- Updated by Janoti!

local tpLocations = {
    -- Keep
    ["inn_level"] = {{19.875248, -2.043680, 2.852175}},
    -- Rightous Stand
    ["military"] = {{121.715, 120.592, -15.3158}, {-197.716, -69.3024, 70.175}},
	-- Convocation of Decay
    ["catacombs"] = { {52.90, -2.08, 24.323511}, {-103.865463, 3.967593, 0.184796}, {-255.556122, -128.045441, -56.856651}},
	-- Hunger in The Dark (is second an event?)
    ["mines"] = {{-25.18, 56.23, 14.20}, {34.759, -58.2682, 0.247534}, {253.54, -304.13, -17.644}},
	-- Halescourge
    ["ground_zero"] = { {311.024963, 89.648521, -12.895300} },
	-- Athel Yenlui
    ["elven_ruins"] = {{349.908, 331.74, 25.778}},
	-- Screaming Bell (is first an event?)
    ["bell"] = {{-5.16007, -192.023, -29.1902}, {-7.64211, -444.317, 40.8632}},
	-- Fort Brachsenbrücke (first trigger for elevator)
    ["fort"] = {{-4.12488, -8.34518, -20.9654},{-25.8038, 24.6713, -0.184609}},
	-- Into The Nest
    ["skaven_stronghold"] = { {-190.04, 94.92, 27.04}, {180.02, -74.28, 32.87} },
	-- Against The Grain
    ["farmlands"] = { {-122.428233, -40.997524, -0.453986}, {-97.762825, 177.131104, 12.798241} },
    -- Empire in Flames
    ["ussingen"] = {{-57.144, -13.573, 20.4699}},
	-- Festering Ground
    ["nurgle"] = { {-349.687347, 82.144646, 2.094658} },
	-- War Camp
    ["warcamp"] = { {178.934387, 185.609863, 17.929544}, {196.783051, -83.824829, 41.218258} },
	-- Skittergate
    ["skittergate"] = { {269.836914, 481.523315, -15.362812}, {127.629379, 334.292572, 9.914454}, {-334.596832, -410.148041, -123.939270}},
	-- Old Haunts
    ["dlc_portals"] = { {-185.013992, 119.351524, -42.627037}, {173.952271, 22.620922, 25.472994}},
	-- Blood in Darkness
    ["dlc_bastion"] = { {65.788605, 33.256676, -26.338324}, {41.785767, 53.660053, 12.333536}, {94.329514, -35.620724, -3.632232}},
	-- Enchanters Lair
    ["dlc_castle"] = { {-0.897143, 9.424833, 0}, {6.948763, 325.470917, 25.262688}},
    -- The Pit
    ["dlc_bogenhafen_slum"] = {{-56.9376, 151.794, 18.0222}, {84.846382, -37.159031, 6.264986}},
	-- Blightreaper
    ["dlc_bogenhafen_city"] = { {-54.977257, 132.112473, 3.967742}, {52.560699, 223.172287, 82.015915} },
    -- Horn of Magnus
    ["magnus"] = {{-3.72264, -5.23273, 1.3351}, {244.977, -152.234, 96.2738}},
	-- Garden of Morr
    ["cemetery"] = { {24.038063, 62.726257, 1.10111} },
	-- Engines of War
    ["forest_ambush"] = { {252.697388, -178.306717, 17.580149}, {498.607941, 28.460766, 0.098653} },
	-- Dark Omens
    ["crater"] = { {74.783218, -405.478455, 40.465588}, {-106.578682, 152.847824, -15.573997} },
    -- Trail of Treachery (kinda same with skittergate)
    ["dlc_wizards_trail"] = {{190.206024, -13.891146, 407.302745}, {115.764877, -152.758682, 386.586578}, {60.555534, -123.071014, 380.793488}, {96.209877, -32.940685, 352.027222}, {-111.540306, -63.5224235, 353.679138} },
	-- Tower of Treachery 
	["dlc_wizards_tower"] = {{-50.365894, 27.234823, 10.628690}, {85.225990, 84.022087, 98.207565}, {-6.698, 95.01, 149.292999}}
}

local NDX = 0
local TABLE_CLEARED = false
local pl = require'pl.import_into'()
local stringx = require'pl.stringx'
mod.compositionHolder = nil
mod.compositionName = nil
mod.world = nil
mod.screen_gui = nil

mod.on_enabled = function()
    pcall(function()
        mod.world = Managers.world:world("level_world")
        mod.screen_gui = World.create_screen_gui(mod.world, "material", "materials/fonts/gw_fonts", "immediate")
    end)  
end  
 
mod.on_setting_changed = function(self)
    mod.world = Managers.world:world("level_world")
    mod.screen_gui = World.create_screen_gui(mod.world, "material", "materials/fonts/gw_fonts", "immediate")
end

mod.on_game_state_changed = function(status, state)
    NDX = 0
    TABLE_CLEARED = false
    mod.compositionHolder = nil
    mod.compositionName = nil

    if status == "enter" and state == "StateIngame" then
        mod.world = Managers.world:world("level_world")
        mod.screen_gui = World.create_screen_gui(mod.world, "material", "materials/fonts/gw_fonts", "immediate")
    end
end

mod.update = function()
    if mod.compositionHolder and mod:get("composition") then
        mod.debugComposition()
    end
end

mod:command("startFOWAtWave", "", function(wave)
	if Managers.state.game_mode._level_key ~= "plaza" then 
		mod:echo("[EventPractice]: Invalid level")
		return
	end
	
	local startWave = tonumber(wave)
	if not startWave or startWave < 1 or startWave > 8 then
		mod:echo("[EventPractice]: Invalid Wave Input (1-8)")
		return
	end

	local adventure_spawning = Managers.state.game_mode:game_mode()._adventure_spawning 
	if adventure_spawning._respawns_enabled then
		adventure_spawning:set_respawning_enabled(false)
	end

	Managers.state.conflict:start_terror_event("plaza_wave_" .. wave)
	
end) 

mod:command("getLocationData", "", function()
    local player_unit = Managers.player:local_player().player_unit
    local position = Unit.local_position(player_unit, 0)
    local rotation = Unit.local_rotation(player_unit, 0)
    mod:echo("[\"%s\"] = { {%f, %f, %f} }", Managers.state.game_mode._level_key, position.x, position.y, position.z)
end)

function clearEvents()
    local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local terror_spawners = level_analysis.terror_spawners
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then return false end

    local terror_event_kind = "event_boss"
    local data = terror_spawners[terror_event_kind]
    local spawners = data.spawners
    local h = Vector3(0, 0, 1)

    table.clear(enemy_recycler.main_path_events)

    for i = 1, #spawners, 1 do
        local spawner = spawners[i]

        local spawner_pos = Unit.local_position(spawner[1], 0)
        local boxed_pos = Vector3Box(spawner_pos)
        local event_data = {event_kind = "event_boss"}

        enemy_recycler:add_main_path_terror_event(boxed_pos,
                                                  "rare_event_loot_rat", 45,
                                                  event_data)

    end
end
--20
local triggerIndex = 1
mod:command("toTrigger", "", function() 
	mod:echo(triggerIndex)
	local level_analysis = Managers.state.conflict.level_analysis
    local boss_waypoints = level_analysis.boss_waypoints
    local terror_spawners = level_analysis.terror_spawners
    local enemy_recycler = level_analysis.enemy_recycler

    if not boss_waypoints then return false end

    local terror_event_kind = "event_boss"
    local data = terror_spawners[terror_event_kind]
    local spawners = data.spawners
    local h = Vector3(0, 0, 1)
	local spawner = spawners[triggerIndex]
	local spawner_pos = Unit.local_position(spawner[1], 0)
	local player_unit = Managers.player:local_player().player_unit
	local rotation = Unit.local_rotation(player_unit, 0)
	local locomotion_extension =
		ScriptUnit.extension(player_unit, "locomotion_system")
	locomotion_extension:teleport_to(spawner_pos, rotation)
	triggerIndex = triggerIndex + 1


    -- -- table.clear(enemy_recycler.main_path_events)

    -- for i = 1, #spawners, 1 do
    --     local spawner = spawners[i]

    --     local spawner_pos = Unit.local_position(spawner[1], 0)
    --     local boxed_pos = Vector3Box(spawner_pos)
    --     local event_data = {event_kind = "event_boss"}

    --     enemy_recycler:add_main_path_terror_event(boxed_pos,
    --                                               "rare_event_loot_rat", 45,
    --                                               event_data)

    -- end
end)

mod:command("toevent", "", function()
    mod:toevent()
end)

mod.toevent = function()
    if mod:get("get_loot_rats") then
        if not TABLE_CLEARED then 
            clearEvents()
            TABLE_CLEARED = true
        end
    end
    local level_key = Managers.state.game_mode._level_key

    if not tpLocations[level_key] then
        mod:echo("[EventPractice]: No locations saved for level")
        return
    end

	-- if tpLocations["skittergate"] then
	-- 	mod:echo("[EventPractice]: Use chat commands to initiate and start the end event.")
	-- end

    local position = tpLocations[level_key][NDX + 1]
    position = Vector3(position[1], position[2],position[3])
    NDX = (NDX + 1) % #tpLocations[level_key]

    local human_players = Managers.player:human_players()
    local network_manager = Managers.state.network
    for _, player in pairs(human_players) do
        pcall(function()
            if not player.local_player then
                unit_id =
                    network_manager:unit_game_object_id(player.player_unit)
                if unit_id then
                    local locomotion_extension =
                        ScriptUnit.extension(player.player_unit,
                                             "locomotion_system")

                    local rotation = Unit.local_rotation(player.player_unit, 0)
                    network_manager.network_transmit:send_rpc_clients(
                        "rpc_teleport_unit_to", unit_id, position, rotation)

                    locomotion_extension:teleport_to(position, rotation)
                end
            else
                local rotation = Unit.local_rotation(player.player_unit, 0)
                local locomotion_extension =
                    ScriptUnit.extension(player.player_unit, "locomotion_system")
                locomotion_extension:teleport_to(position, rotation)
            end
        end)
    end

end

---------------------
-- HORDE COMP
---------------------

mod.parseComposition = function(composition) 
    local formatComposition = {}
    for k, v in pairs(composition) do 
        if v["breeds"] then
            local breed = {}
            local enemy = ""
            local quantity = ""
            for k2, v2 in pairs(v["breeds"]) do 
                if k2 % 2 == 1 then
                    enemy = v2
                elseif k2 % 2 == 0 and type(v2) == "table" then 
                    quantity = tostring(v2[1]) .. " or " .. tostring(v2[2])
                    table.insert( breed, enemy .. " " .. quantity )
                else
                    mod:dump(composition, "composition error", 5)
                end
            end
            table.insert(formatComposition, breed)
        end
    end
    return formatComposition
end

mod.debugComposition = function()
    local font_size = 11
    local font = "arial"
    local font_mtrl = "materials/fonts/" .. font 
    local gui = mod.screen_gui 
	local cm = Managers.state.conflict
	local res_x, res_y = Application.resolution()
	local text_height = 0.01
	local width = 0.15
	local height = 0.2
	local wedge = 0.0025
	local win_x = mod:get("composition_offset_x") * 0.01
	local win_y = mod:get("composition_offset_y") * 0.01
	local row = win_y
	local info = CurrentPacing.name or "default"

    ScriptGUI.itext(gui, res_x, res_y, mod.compositionName, font_mtrl, font_size, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))
    row = row + 0.01
    if mod.compositionHolder then
        local table = pl.pretty.write(mod.compositionHolder, nil, nil, 4) 
        local lines = stringx.splitlines(table):slice(0, 100)
        lines:foreach(function(line)
            ScriptGUI.itext(gui, res_x, res_y, line, font_mtrl, font_size, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))
            row = row + 0.01
        end)
    end
    ScriptGUI.irect(gui, res_x, res_y, win_x, win_y, win_x + width, row + 0.01, 2, Color(100, 10, 10, 10))
end

mod:hook_safe(HordeSpawner, "_execute_event_horde", function(self, t, side_id, composition_type, limit_spawners, silent, group_template, strictly_not_close_to_players, sound_settings, use_closest_spawners, source_unit, optional_data)
    if not mod:get("composition") then return end
    local composition = nil

	fassert(side_id, "Missing side id in event horde")

	if HordeCompositions[composition_type] then
		local current_difficulty_rank, difficulty_tweak = Managers.state.difficulty:get_difficulty_rank()
		local composition_difficulty_rank = DifficultyTweak.converters.composition_rank(current_difficulty_rank, difficulty_tweak)
		composition_difficulty_rank = composition_difficulty_rank - 1
		composition = CurrentHordeSettings.compositions[composition_type][composition_difficulty_rank]
	elseif HordeCompositionsPacing[composition_type] then
		composition = CurrentHordeSettings.compositions_pacing[composition_type]
	end

    
    mod.compositionHolder = mod.parseComposition(composition)
    mod.compositionName = composition_type
    if mod:get("composition_chat_output") then
        mod:echo(mod.compositionName)
    end
end)

mod:hook_safe(HordeSpawner, "execute_vector_horde", function(self, extra_data, side_id, fallback)
    if not mod:get("composition") then return end
    local settings = CurrentHordeSettings.vector
	local max_spawners = settings.max_spawners
	local start_delay = (extra_data and extra_data.start_delay) or settings.start_delay
	local only_behind = extra_data and extra_data.only_behind
	local silent = extra_data and extra_data.silent
	local side = Managers.state.side:get_side(side_id)
	local player_and_bot_positions = side.ENEMY_PLAYER_AND_BOT_POSITIONS

	print("setting up vector-horde")

	local clusters, clusters_sizes = ConflictUtils.cluster_positions(player_and_bot_positions, 7)
	local biggest_cluster = ConflictUtils.get_biggest_cluster(clusters_sizes)
	local main_target_pos = clusters[biggest_cluster]
	local success, horde_spawners, found_cover_points, composition_type, override_composition = nil
	local override_composition_type = extra_data and extra_data.override_composition_type
	local optional_wave_composition = extra_data and extra_data.optional_wave_composition

	if override_composition_type and CurrentHordeSettings.compositions[override_composition_type] then
		local override_composition_table = CurrentHordeSettings.compositions[override_composition_type]
		local current_difficulty_rank, difficulty_tweak = Managers.state.difficulty:get_difficulty_rank()
		local composition_difficulty_rank = DifficultyTweak.converters.composition_rank(current_difficulty_rank, difficulty_tweak)
		override_composition = override_composition_table[composition_difficulty_rank - 1]

		fassert(override_composition.loaded_probs, " Vector horde override type %s is missing loaded probabilty table!", override_composition_type)

		composition_type = override_composition_type
	elseif optional_wave_composition then
		local chosen_wave_composition = HordeWaveCompositions[optional_wave_composition]
		composition_type = chosen_wave_composition[math.random(#chosen_wave_composition)]
	else
		composition_type = CurrentHordeSettings.vector_composition or "medium"
	end

	assert(composition_type, "Vector Horde missing composition_type")

	local composition = override_composition or CurrentHordeSettings.compositions_pacing[composition_type]

    
    mod.compositionHolder = mod.parseComposition(composition)
    mod.compositionName = composition_type
    if mod:get("composition_chat_output") then
        mod:echo(mod.compositionName)
    end
end)

mod:hook_safe(HordeSpawner, "execute_vector_blob_horde", function(self, extra_data, side_id, fallback)
    if not mod:get("composition") then return end
    local settings = CurrentHordeSettings.vector_blob
	local roll = math.random()
	local spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead

	print("wants to spawn " .. ((spawn_horde_ahead and "ahead") or "behind") .. " within distance: ", settings.main_path_dist_from_players)

	local success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

	if not success then
		print("\tcould not, tries to spawn" .. ((not spawn_horde_ahead and "ahead") or "behind"))

		success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(not spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

		if not success then
			local roll = math.random()
			local spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead
			local distance_bonus = 20
			success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players + distance_bonus, settings.raw_dist_from_players, side_id)
		end
	end

	if not blob_pos then
		print("\no spawn position found at all, failing horde")

		return
	end

	local composition_type = nil
	local optional_wave_composition = extra_data and extra_data.optional_wave_composition

	if optional_wave_composition then
		local chosen_wave_composition = HordeWaveCompositions[optional_wave_composition]
		composition_type = chosen_wave_composition[math.random(#chosen_wave_composition)]
	else
		composition_type = (extra_data and extra_data.override_composition_type) or CurrentHordeSettings.vector_composition or "medium"
	end

	assert(composition_type, "Vector Blob Horde missing composition_type")

	local composition = CurrentHordeSettings.compositions_pacing[composition_type]

    
    mod.compositionHolder = mod.parseComposition(composition)
    mod.compositionName = composition_type
    if mod:get("composition_chat_output") then
        mod:echo(mod.compositionName)
    end
end)

mod:hook_safe(HordeSpawner, "execute_ambush_horde", function(self, extra_data, side_id, fallback, override_epicenter_pos, optional_data)
    if not mod:get("composition") then return end
	mod:echo(extra_data.sound_settings) 
    print("setting up ambush-horde")

	local settings = CurrentHordeSettings.ambush
	local min_spawners = settings.min_spawners
	local max_spawners = settings.max_spawners
	local min_dist = settings.min_horde_spawner_dist
	local max_dist = settings.max_horde_spawner_dist
	local hidden_min_dist = settings.min_hidden_spawner_dist
	local hidden_max_dist = settings.max_hidden_spawner_dist
	local start_delay = settings.start_delay
	local composition_type, override_composition = nil
	local override_composition_type = extra_data and extra_data.override_composition_type

	if override_composition_type and CurrentHordeSettings.compositions[override_composition_type] then
		local override_composition_table = CurrentHordeSettings.compositions[override_composition_type]
		local current_difficulty_rank, difficulty_tweak = Managers.state.difficulty:get_difficulty_rank()
		local composition_difficulty_rank = DifficultyTweak.converters.composition_rank(current_difficulty_rank, difficulty_tweak)
		override_composition = override_composition_table[composition_difficulty_rank - 1]

		fassert(override_composition.loaded_probs, " Ambush horde %s is missing loaded probabilty table!", override_composition_type)

		composition_type = override_composition_type
	else
		local wave_composition_type = nil
		local optional_wave_composition = extra_data and extra_data.optional_wave_composition

		if optional_wave_composition then
			local chosen_wave_composition = HordeWaveCompositions[optional_wave_composition]
			wave_composition_type = chosen_wave_composition[math.random(#chosen_wave_composition)]
		else
			wave_composition_type = CurrentHordeSettings.vector_composition or "medium"
		end

		composition_type = override_composition_type or wave_composition_type

		fassert(composition_type, "Ambush Horde missing composition_type")
	end

	local composition = override_composition or CurrentHordeSettings.compositions_pacing[composition_type]

    
    mod.compositionHolder = mod.parseComposition(composition)
    mod.compositionName = composition_type
    if mod:get("composition_chat_output") then
        mod:echo(mod.compositionName)
    end
end) 

---------------------------
--  Pacing
--------------------------

mod:hook_safe(ConflictDirector, "update_horde_pacing", function(self, t, dt)
    if mod:get("pacing") then
        mod.debugPacing(t, dt)
    end

	if mod:get("intensity") then
		mod.debugIntensity(t, dt)
    end
end)

mod.debugPacing = function(t, dt)
    local font_size = mod:get("pacing_font_size")
    local font_size_medium = mod:get("pacing_font_size") - 0.15
    local font_size_blackboard = mod:get("pacing_font_size") - 0.4
    local font = "arial"
    local font_mtrl = "materials/fonts/" .. font
	local rowcalc = mod:get("pacing_font_size") * 0.88
	local rowcalc2 = mod:get("pacing_font_size") - rowcalc
	local rowspace = rowcalc2 * 0.01
	local gui = mod.screen_gui
	local cm = Managers.state.conflict
	local res_x, res_y = Application.resolution()
	local text_height = 0.02
	local width = 0.3
	local height = 0.2
	local wedge = 0.0025
	local win_x = mod:get("pacing_offset_x") * 0.01
	local win_y = mod:get("pacing_offset_y") * 0.01
	local row = win_y
	local info = CurrentPacing.name or "default"
	local nx = ScriptGUI.itext_next_xy(gui, res_x, res_y, "Pacing: ", font_mtrl, font_size, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))
	nx = ScriptGUI.itext_next_xy(gui, res_x, res_y, info, font_mtrl, font_size, font, nx, row + text_height, 3, Color(255, 137, 237, 137))
	nx = ScriptGUI.itext_next_xy(gui, res_x, res_y, "Conflict setting: ", font_mtrl, font_size, font, nx, row + text_height, 3, Color(255, 237, 237, 152))
	nx = ScriptGUI.itext_next_xy(gui, res_x, res_y, tostring(cm.current_conflict_settings), font_mtrl, font_size, font, nx, row + text_height, 3, Color(255, 137, 237, 137))
    
	row = row + rowspace
	local text, spawning_text = nil
	local state_name, state_start_time, threat_population, specials_population, horde_population, end_time = cm.pacing:get_pacing_data()
	local roamers = (threat_population > 0 and "[Roamers]") or "[NO Roamers]"
	local specials = (specials_population > 0 and "[Specials]") or "[NO Specials]"
	local horde = (horde_population > 0 and "[Hordes]") or "[NO Hordes]"

	if end_time then
		local count_down = math.clamp(end_time - t, 0, 999999)
		text = string.format("State: %s time left: %.1f", state_name, count_down)
		spawning_text = string.format("%s%s%s", roamers, specials, horde)
	else
		text = string.format("State: %s runtime: %.1f", state_name, t - state_start_time)
		spawning_text = string.format("%s%s%s", roamers, specials, horde)
	end

	ScriptGUI.itext(gui, res_x, res_y, text, font_mtrl, font_size_medium, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))

	row = row + rowspace

	ScriptGUI.itext(gui, res_x, res_y, spawning_text, font_mtrl, font_size_medium, font, win_x + wedge, row + text_height, 3, Color(255, 137, 237, 152))

	row = row + rowspace
	
	local s1 = nil

	if script_data.ai_horde_spawning_disabled then
		s1 = string.format("Horde spawning is disabled")
	else
		local next_horde_time, hordes, multiple_horde_count = cm:get_horde_data()

		if #hordes > 0 then
			s1 = string.format("Number of hordes active: %d  horde size:%d", #hordes, cm:horde_size())
		elseif horde_population > 0 then
			if next_horde_time then
				s1 = string.format("Next horde in: %.1fs horde size:%d", next_horde_time - t, cm:horde_size())
			else
				s1 = "Next horde in: N/A"
			end
		else
			s1 = string.format("No horde will spawn during this state")
		end

		if multiple_horde_count then
			local textmc = string.format("Horde waves left: %d", multiple_horde_count)

			ScriptGUI.itext(gui, res_x, res_y, textmc, font_mtrl, font_size_medium, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))

			row = row + rowspace
		end
	end

	ScriptGUI.itext(gui, res_x, res_y, s1, font_mtrl, font_size_medium, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))

	row = row + rowspace

	if cm.players_speeding_dist then
		local max_dist = CurrentPacing.relax_rushing_distance
		local s = string.format("Players rushing dist: %d / %d", cm.players_speeding_dist, max_dist)

		ScriptGUI.itext(gui, res_x, res_y, s, font_mtrl, font_size_medium, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))

		row = row + rowspace
	end
    local nx = ScriptGUI.itext_next_xy(gui, res_x, res_y, "Threat: ", font_mtrl, font_size, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))
	nx = ScriptGUI.itext_next_xy(gui, res_x, res_y, tostring(cm.threat_value), font_mtrl, font_size, font, nx, row + text_height, 3, Color(255, 137, 237, 137))
	row = row + rowspace

    if EVENT_NAME then
        local nx = ScriptGUI.itext_next_xy(gui, res_x, res_y, "Event Name: ", font_mtrl, font_size, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))
        nx = ScriptGUI.itext_next_xy(gui, res_x, res_y, EVENT_NAME, font_mtrl, font_size, font, nx, row + text_height, 3, Color(255, 137, 237, 137))
		row = row + rowspace
    end

    if compositionHolder then
        local table = pl.pretty.write(compositionHolder, nil, nil, 4) 
        local lines = stringx.splitlines(table):slice(0, 135)
        lines:foreach(function(line)
            ScriptGUI.itext(gui, res_x, res_y, line, font_mtrl, font_size_medium, font, win_x + wedge, row + text_height, 3, Color(255, 237, 237, 152))
			row = row + rowspace
        end)
    end
    row = row + rowspace

	ScriptGUI.irect(gui, res_x, res_y, win_x, win_y, win_x + width, row, 2, Color(100, 10, 10, 10))
	
end

mod.debugIntensity = function(t, dt)
	local font_size = 26
	local font = "arial"
	local font_mtrl = "materials/fonts/" .. font 
	local xcol = {
		Color(200, 160, 145, 0),
		Color(200, 90, 150, 170),
		Color(200, 10, 200, 100),
		Color(200, 190, 50, 190)
	}
	local gui = mod.screen_gui
	local res_x, res_y = Application.resolution()
	local players = Managers.player:human_players()
	local bar_width = 0.15
	local bar_height = 0.02
	local wedge = 0.0025
	--local win_x = mod:get("intensity_offset_x") * 0.01
	--local win_y = mod:get("intensity_offset_y") * 0.01
	local win_x = 1 - (bar_width + wedge)
	local win_y = 0.15
	local row = win_y
	local conflict_director = Managers.state.conflict
	local pacing = conflict_director.pacing
	local sum_pacing_intensity, player_intensity = pacing:get_pacing_intensity()

	for k = 1, #player_intensity, 1 do
		local int = player_intensity[k] * 0.01
		local x1 = win_x
		local y1 = row + bar_height
		local x2 = win_x + bar_width * int
		local y2 = row

		ScriptGUI.irect(gui, res_x, res_y, x1, y1, win_x + bar_width, y2, 1, Color(100, 10, 10, 10))
		ScriptGUI.irect(gui, res_x, res_y, x1, y1, x2, y2, 2, xcol[k])

		row = row + bar_height + wedge
	end

	ScriptGUI.itext(gui, res_x, res_y, "[Player Intensity]", font_mtrl, font_size, font, win_x, win_y, 3, Color(255, 237, 237, 152))

	row = row + bar_height * 1

	ScriptGUI.itext(gui, res_x, res_y, "[Total Intensity]", font_mtrl, font_size, font, win_x, row + bar_height * 0.75, 3, Color(255, 237, 237, 152))

	row = row + bar_height * 1

	ScriptGUI.irect(gui, res_x, res_y, win_x, row + bar_height, win_x + bar_width, row, 1, Color(100, 90, 10, 10))
	ScriptGUI.irect(gui, res_x, res_y, win_x, row + bar_height, win_x + bar_width * sum_pacing_intensity * 0.01, row, 2, Color(200, 130, 10, 10))

	local decay_text = ""
	local frozen = conflict_director:intensity_decay_frozen()

	if frozen then
		decay_text = string.format("decay delay frozen: %.1f", math.clamp(conflict_director.frozen_intensity_decay_until - t, 0, 100))
	elseif pacing:ignore_pacing_intensity_decay_delay() then
		decay_text = "decay delay: ignored"
	else
		local player = Managers.player:local_player(1)
		local status_extension = ScriptUnit.has_extension(player.player_unit, "status_system")

		if status_extension then
		end
	end

	row = row + bar_height * 1.5
	local small_font_size = 22

	ScriptGUI.itext(gui, res_x, res_y, decay_text, font_mtrl, small_font_size, font, win_x, row + bar_height * 0.75, 3, Color(255, 200, 200, 32))

end


---------------------------
-- Skittergate Specials
---------------------------
mod:command("skittergate_initiate", "", function ()
	skittergate_end_event_initiate()
end)
mod:command("skittergate_start", "", function ()
	skittergate_end_event_start()
end)

function skittergate_end_event_initiate()
	-- Managers.state.conflict:start_terror_event_from_template("skittergate_chaos_boss", "skittergate_chaos_boss")
	Managers.state.conflict:start_terror_event_from_template("skittergate_terror_event_02", "terror_event_02")
	-- delete everything automatically
end

function skittergate_end_event_start()
	Managers.state.conflict:start_terror_event_from_template("skittergate_rasknitt_boss", "skittergate_rasknitt_boss")
end



--------------------------------
-- Trail of Treachery Specials
--------------------------------
--[[
--https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/d838a139bbc0715041a846b290b2b09472a04297/scripts/settings/terror_events/terror_events_dlc_wizards_trail.lua

mod:command("trails_middle_event_initiate", "", function()
	trails_middle_event_initiate()
end)

function trails_middle_event_initiate()
	Managers.state.conflict:start_terror_event_from_template("trail_drawbridge_wallbreaker", "drawbridge_wall_breaker_01")
	Managers.state.conflict:start_terror_event_from_template("trail_grim_path_ambush", "path_ambush_spawner_01")
	Managers.state.conflict:start_terror_event_from_template("trail_mid_event_recons", "trail_mid_event_recons_special_02")
end


mod:command("trails_middle_event_start", "", function()
	trails_middle_event_start()
end)

function trails_middle_event_start()
	Managers.state.conflict:start_terror_event_from_template("trail_mid_event_01", "trail_mid_event_spawn_01")
	--Managers.state.conflict:start_terror_event_from_template("trail_mid_event_04", "trail_mid_event_spawn_04")
end


mod:command("trails_end_event_start", "", function()
	trails_end_event_start()
end)

function trails_end_event_start()
	Managers.state.conflict:start_terror_event_from_template("trail_end_event_first_wave", "trail_end_event_spawner_under_water")
	--Managers.state.conflict:start_terror_event_from_template("trail_end_event_01", "trail_end_event_spawner_1")
	--Managers.state.conflict:start_terror_event_from_template("trail_end_event_first_wave", "trail_end_event_spawner_1")
end
]]