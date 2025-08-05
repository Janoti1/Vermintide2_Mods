--[[

    This mod allows people with hearing loss to use Captions on screen which show the sounds in text form
    
    The mod is originally made by Manny with the support of EXAN, all rights and credits go to them.
    The original Mod author has approved of me reuploading this very mod.
    Original Repo: https://github.com/ManuelBlanc/accessibility-captions

    This reupload fixes minor issues like the saving of the position of the caption text

    Janoti! - 2025-07-26

]]

local mod = get_mod("Captions fix")

-- Localize globals for efficiency.
local Gui, V2, V3, V3Box, Quat, M4 = Gui, Vector2, Vector3, Vector3Box, Quaternion, Matrix4x4

local MAX_HEARING_DISTANCE_SQ
local NOT_SHOW_ALL_SOUNDS
local FONT_MATERIAL = Fonts.arial[1]
local FONT_SIZE
local WIDGET_X = mod:get("widget_x")
local WIDGET_Y = mod:get("widget_y")
local RECT_W, RECT_H
local DRAGGER_HALFSIZE = 10 -- The half-width of the dragger square.
local PAD_W, PAD_H = 30, 0 -- Horizontal/vertical internal padding.
local INDICATOR_W = 20 -- The width of the directional indicators.

local caption_data = mod.caption_data
local active_captions = {}

-- Find a caption by its label. We do not build a lookup because this is an infrequent operation.
local function find_by_label(label)
    for i=1, #caption_data do
        local data = caption_data[i]
        if label == data.label then
            return data
        end
    end
end

-- {{{1 Playing sample sounds.
----------------------------------------------------------------------------------------------------
local playing_sample_id, playing_sample_t -- Variables used to play a sample of each sound.

-- Stop the curently playing sample sound.
local function stop_sample_sound()
    if playing_sample_t then
        local world = Managers.world:world("level_world")
        local wwise_world = Managers.world:wwise_world(world)
        WwiseWorld.stop_event(wwise_world, playing_sample_id)
        playing_sample_t = nil
    end
end

local function play_sample_sound(sample_event, max_duration)
    --mod:debug("Playing sound: %q", sample_event) --IF_LINE DEBUG
    local world = Managers.world:world("level_world")
    local wwise_world = Managers.world:wwise_world(world)
    stop_sample_sound()
    playing_sample_id = WwiseWorld.trigger_event(wwise_world, sample_event)
    playing_sample_t = max_duration or 5
end

-- Stop the sample sound after a while.
function mod.update(dt)
    if playing_sample_t then
        playing_sample_t = playing_sample_t - dt
        if playing_sample_t <= 0 then stop_sample_sound() end
    end
end

mod.stop_sample_sound = stop_sample_sound
mod.play_sample_sound = play_sample_sound

-- Hook into VMFOptionsView to silence the default checkbox sound for our mod.
function mod.on_all_mods_loaded()
    mod:hook("VMFOptionsView", "callback_setting_changed", function(func, self, mod_name, setting_id, old_value, new_value)
        if mod_name == "Captions fix" and new_value == true and find_by_label(setting_id) then
            if self.is_setting_changes_applied_immidiately then
                mod:set(setting_id, new_value, true)
            end
        else
            return func(self, mod_name, setting_id, old_value, new_value)
        end
    end)
end

-- When a setting is changed, update the globals.
function mod.on_setting_changed(setting_id)
    local data = find_by_label(setting_id)
    if data then
        data.enabled = mod:get(setting_id)
        if data.enabled then
            play_sample_sound(data[math.random(#data)], max_duration or 5)
        end
    else
        MAX_HEARING_DISTANCE_SQ = (mod:get("max_hearing_distance") or 50)^2
        NOT_SHOW_ALL_SOUNDS = not mod:get("show_all_sounds")
        FONT_SIZE = mod:get("font_size") or 14
    end
end
mod.on_setting_changed(nil)

-- on loading in keep / restarting and alike, reset the captions table
mod.on_game_state_changed = function(status, state_name)
    if status == "enter" and state_name == "StateIngame" then
        for k, _ in pairs(active_captions) do
            active_captions[k] = nil
        end
        --mod.clear_all_captions()
    end
end

-- Recompute the dimensions of the widgets.
local function recompute_data(gui)
    local max_w, max_h = 0, 0
    local font_material = FONT_MATERIAL
    for _, data in ipairs(active_captions) do
        local min, max, caret =  Gui.text_extents(gui, data.label, font_material, FONT_SIZE)
        local w, h = caret[1] - min[1], (max[2] - min[2])*1.5
        data.w, data.h = w, h
        max_w, max_h = math.max(max_w, w), math.max(max_h, h)
    end
    RECT_W, RECT_H = max_w + PAD_W*2, max_h + PAD_H*2
end

-- Trigger the caption for a given sound event.
local function trigger_event(data, pos)
    if data.automatic and NOT_SHOW_ALL_SOUNDS then return end
    local dist_sq
    local player_unit = Managers.player:local_player().player_unit
    if pos and player_unit then
        dist_sq = V3.distance_squared(Unit.world_position(player_unit, 0), pos)
        if dist_sq > MAX_HEARING_DISTANCE_SQ then return end
    else
        pos, dist_sq = V3.zero(), 1
    end
    V3Box.store(data.pos, pos)
    data.dist_sq = dist_sq
    local t_start = Managers.time:time("main") --Application.time_since_launch() -- somehow time has litterally changed...
    data.t_start, data.t_end = t_start, t_start + data.duration
    if not data.active then
        local index = #active_captions
        if not data.automatic then
            while index > 0 and active_captions[index].automatic do index = index - 1 end
        end
        table.insert(active_captions, index+1, data)
        data.active = true
    end
end

-- {{{1 Hooking sound players.
----------------------------------------------------------------------------------------------------
--local function DEBUG_SOUND_SOURCE(f, e) end --return mod:debug("%s(%q)", f, e) end --IF_LINE DEBUG

mod:hook_safe(AudioSystem, "_play_event", function(self, event, unit, object_id)
    --DEBUG_SOUND_SOURCE("AudioSystem._play_event", event) --IF_LINE DEBUG
    if mod:get("debug_mode") then
        mod:echo("Play Event called: " .. tostring(event) .. ".")
    end
    local data = caption_data[event]
    if data and data.enabled then
        return trigger_event(data, Unit.world_position(unit, 0))
    end
end)

mod:hook_safe(AudioSystem, "play_audio_unit_event", function(self, event, unit, object)
    --DEBUG_SOUND_SOURCE("AudioSystem._play_event", event) --IF_LINE DEBUG
    if mod:get("debug_mode") then
        if not event then return end
        mod:echo("Play Audio called: " .. tostring(event) .. ".")
    end
    local data = caption_data[event]
    if data and data.enabled then
        return trigger_event(data, Unit.world_position(unit, 0))
    end
end)

mod:hook_safe(MusicManager, "trigger_event", function(self, event_name)
    --DEBUG_SOUND_SOURCE("MusicManager.trigger_event", event_name) --IF_LINE DEBUG
    if mod:get("debug_mode") then
        mod:echo("Music called: " .. tostring(event_name) .. ".")
    end
    local data = caption_data[event_name]
    if data and data.enabled then
        return trigger_event(data)
    end
end)

-- Backstabs.
mod:hook_safe(DialogueSystem, "trigger_backstab", function(self, player_unit, enemy_unit, blackboard)
    if mod:get("debug_mode") then
        mod:echo("Backstab called: " .. tostring(blackboard.breed.backstab_player_sound_event) .. ".")
    end
    local player_manager = Managers.player
    local owner = player_manager:unit_owner(player_unit)
    if Unit.alive(player_unit) and owner and owner.local_player and ALIVE[enemy_unit] then
        local sound_event = blackboard.breed.backstab_player_sound_event
        local data = caption_data[sound_event]
        if data and data.enabled then
            return trigger_event(data, Unit.world_position(enemy_unit, 0))
        end
    end
end)

-- Breed stingers.
local function ai_extension(self, extension_init_context, unit, extension_init_data)
    --DEBUG_SOUND_SOURCE("AISimpleExtension.init", self._breed.combat_spawn_stinger) --IF_LINE DEBUG
    if mod:get("debug_mode") then
        if not self._breed.combat_spawn_stinger then return end
        mod:echo("AI Extension called: " .. tostring(self._breed.combat_spawn_stinger) .. ".")
    end
    local data = caption_data[self._breed.combat_spawn_stinger]
    if data and data.enabled then
        return trigger_event(data) -- No unit, because they're positionless stingers.
    end
end
mod:hook_safe(AISimpleExtension, "init", ai_extension)
mod:hook_safe(AiHuskBaseExtension, "init", ai_extension)

-- Horde stingers.
mod:hook_safe(HordeSpawner, "play_sound", function(self, stinger_name, pos)
    if mod:get("debug_mode") then
        mod:echo("Horde called: " .. tostring(stinger_name) .. ".")
    end
    local data = caption_data[stinger_name]
    if data and data.enabled then
        return trigger_event(caption_data[stinger_name], pos)
    end
end)

-- Terror horde stingers.
mod:hook_safe(TerrorEventMixer.init_functions, "play_stinger", function(event, element, t)
    --DEBUG_SOUND_SOURCE("TerrorEventMixer.init_functions.player_stiger", element.stinger_name) --IF_LINE DEBUG
    if mod:get("debug_mode") then
        mod:echo("Terror Event Found called: " .. tostring(element.stinger_name or "enemy_terror_event_stinger") .. ".")
    end
    local data = caption_data[element.stinger_name or "enemy_terror_event_stinger"]
    if data and data.enabled then
        return trigger_event(data, element.optional_pos)
    end
end)

-- Explosive barrel.
local function barrel_fuse_ticking(unit, dt, context, t, data)
    if mod:get("debug_mode") then
        mod:echo("Barrel Fuse called: " .. tostring(caption_data.__barrel_fuse_dummy_event.label) .. ".")
    end
    local data = caption_data.__barrel_fuse_dummy_event
    if data.enabled then
        mod:echo("Barrel Fuse called: " .. tostring(data.label) .. ".")
        return trigger_event(data, Unit.world_position(unit, 0))
    end
end
mod:hook_safe(DeathReactions.templates.explosive_barrel.unit, "update", barrel_fuse_ticking)
mod:hook_safe(DeathReactions.templates.explosive_barrel.husk, "update", barrel_fuse_ticking)

--[[ Music.
mod:hook_safe(Music, "set_group_state", function(self, state, value)
    local data = caption_data[value]
    if data and data.enabled then
        return trigger_event(data)
    end
end)
--]]

mod:hook_safe(WwiseFlowCallbacks, "wwise_trigger_event", function(t)
    --DEBUG_SOUND_SOURCE("WwiseFlowCallbacks.wwise_trigger_event", t.Name or t.name or "OH NO!") --IF_LINE DEBUG
    if mod:get("debug_mode") then
        local name = t.Name or t.name or ""
        mod:echo("WWise called: " .. tostring(name) .. ".")
    end
    local data = caption_data[t.Name or t.name]
    if data and data.enabled then
        local unit, pos = t.Unit or t.unit
        if unit then pos = Unit.world_position(unit, 0) end
        return trigger_event(data, pos or t.Position or t.position)
    end
end)

mod:hook_safe(_G, "flow_callback_trigger_sound", function(params)
    --DEBUG_SOUND_SOURCE("flow_callback_trigger_sound", params.event) --IF_LINE DEBUG
    if mod:get("debug_mode") then
        mod:echo("Flow Callback Trigger Sound called: " .. tostring(params.event) .. ".")
    end
    local data = caption_data[params.event]
    if data and data.enabled then
        local unit, pos = params.unit
        if unit then pos = Unit.world_position(unit, 0) end
        mod:echo("Flow Callback Trigger Sound called: " .. tostring(data.label) .. ".")
        return trigger_event(data, pos or params.position)
    end
end)

mod:hook_safe(_G, "flow_callback_wwise_trigger_event_with_environment", function(params)
    --DEBUG_SOUND_SOURCE("flow_callback_wwise_trigger_event_with_environment", params.name) --IF_LINE DEBUG
    if mod:get("debug_mode") then
        mod:echo("Flow Callback WWise called: " .. tostring(params.name) .. ".")
    end
    local data = caption_data[params.name] -- ATENTION: The event is in `name`.
    if data and data.enabled then
        local unit, pos = params.unit
        if unit then
            local node_name = params.unit_node
            local node = (node_name and node_name ~= "") and Unit.node(unit, node_name) or 0
            pos = Unit.world_position(unit, node)
        end
        return trigger_event(data, pos or params.position)
    end
end)

-- {{{1 Widget updating & drawing.
----------------------------------------------------------------------------------------------------
local dragging = false

-- Draw the widget.
mod:hook_safe(IngameUI, "update", function(self, dt, t, disable_ingame_ui, end_of_level_ui)
    if disable_ingame_ui then return end

    -- Get the local player
    local player_unit = Managers.player:local_player().player_unit
    if not (player_unit and Unit.alive(player_unit)) then return end

    -- Get the camera position and rotation.
    local first_person_extension = ScriptUnit.extension(player_unit, "first_person_system")
    --local player_pose = Unit.local_pose(first_person_extension.first_person_unit, 0)
    local player_pos = first_person_extension:current_position()
    local player_rot = first_person_extension:current_rotation()

    local plane_l = Quat.rotate(player_rot, V3( 1, -1, 0))
    local plane_r = Quat.rotate(player_rot, V3(-1, -1, 0))
    V3.set_z(plane_l, 0)
    V3.set_z(plane_r, 0)

    -- Get ahold of the Gui object.
    local gui = self.ui_renderer.gui

    -- Prepare common rendering data.
    recompute_data(self.ui_renderer.gui)
    local rect_size, rect_color = V2(RECT_W, RECT_H), Color(150, 20, 20, 20)
    local dir_offset, dir_size = RECT_W - INDICATOR_W, V2(INDICATOR_W, RECT_H)
    local font_material = FONT_MATERIAL

    -- Override local t.
    t = Managers.time:time("main")

    local dir = mod:get("widget_direction")
    local dir_h = dir % 2 > 0 and 1 or -1
    local dir_v = dir     > 1 and 1 or -1

    -- Draw all caption.
    for i=#active_captions, 1, -1 do
        local data = active_captions[i]

        do
            local v = player_pos - V3Box.unbox(data.pos)
            local len = V3.length(v)
            if V3.distance_squared(v, player_pos) > 1 and len > 1 then
                data.light_l, data.light_r = V3.dot(v, plane_l) > 0, V3.dot(v, plane_r) > 0
            else
                data.light_l, data.light_r = true, true
            end
        end

        local pos = V2(
            WIDGET_X + math.min(0, dir_h)*RECT_W,
            WIDGET_Y + math.min(0, dir_v)*RECT_H + dir_v*(i-1)*(RECT_H+5)
        )
        local t_mul = math.clamp((data.t_end - t)/data.duration, 0, 1)^2 --TODO the duration seems to be too long for some reason
        --mod:echo("data.t_end: " .. tostring(data.t_end) .. ", data.duration " .. tostring(data.duration))
        --mod:echo("t_mul: " .. tostring(t_mul) .. ", " .. tostring(t))
        local d_mul = math.clamp(MAX_HEARING_DISTANCE_SQ / 4 / math.pi / data.dist_sq, 0, 1)
        local text_pos = pos + 0.5*(rect_size - V2(data.w, 0.5*data.h))
        local lr_color_mod = data.on_left and 40 or -40
        Gui.rect(gui, pos, rect_size, rect_color)
        --Gui.rect(gui, text_pos, V2(data.w, data.h), Color(255, 255, 0, 255))  -- Debug text pos.
        if data.light_l then
            Gui.rect(gui, pos, dir_size, Color(255 * d_mul, 120, 40, 40))
        end
        if data.light_r then
            Gui.rect(gui, pos + V2(dir_offset, 0), dir_size, Color(255 * d_mul, 40, 120, 40))
        end
        local text_rg = data.automatic and 120 or 255
        Gui.text(gui, data.label, font_material, FONT_SIZE, nil, text_pos, Color(255 * t_mul, text_rg, 255, 255))
        --mod:echo("alpha = %s", 255 * t_mul)

        --local end_time = t + data.duration

        if t > data.t_end then
            table.remove(active_captions, i)
            data.active = false
            --mod:echo("removed caption.")
        end
    end

    -- Dragger.
    local chat_gui = Managers.chat.chat_gui
    if not chat_gui.chat_focused then
        dragging = false
    else
        local input_manager = self.input_manager
        local input_service = input_manager:get_service("chat_input")
        local cursor = input_service:get("cursor")

        local dh = DRAGGER_HALFSIZE
        local d_pos = V2(WIDGET_X-dh, WIDGET_Y-dh)
        local d_size = V2(dh*2, dh*2)
        Gui.rect(gui, d_pos, d_size, Color(255, 255, 255, 255))

        if input_service:get("left_press") and math.point_is_inside_2d_box(cursor, d_pos, d_size) then
            dragging = true
        elseif input_service:get("left_release") then
            dragging = false
        end

        if dragging then
            trigger_event(caption_data.EXAMPLE_1)
            trigger_event(caption_data.EXAMPLE_2)
            trigger_event(caption_data.EXAMPLE_3)
            local w, h = Gui.resolution()
            local x, y = math.clamp(cursor.x, 0, w), math.clamp(cursor.y, 0, h)
            WIDGET_X, WIDGET_Y = x, y
            mod:set("widget_x", WIDGET_X)
            mod:set("widget_y", WIDGET_Y)
        end
    end
end)


--[[

    -- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/2276fe6cb7f6befec01ed1c0c0da978a8ef8fc93/scripts/boot.lua#L178
    -- https://github.com/Aussiemon/Vermintide-2-Source-Code/blob/2276fe6cb7f6befec01ed1c0c0da978a8ef8fc93/foundation/scripts/managers/localization/localization_manager.lua#L4
    
    SNIPPETS
    -- get User Settings Language id
    Application.user_setting("language_id")

    -- set user settings language id
    Application.set_user_setting("language_id", "en")

    -- get Steam settings language_id
    Steam.language()

    Loca Debug:
    -- of english Localization / the one referred to as the Localizer
    local active_localizer = Localizer("localization/game")
    Localizer.lookup(active_localizer, "holy_hand_grenade")

    -- of currently used Loca
    Localize("holy_hand_grenade")
    Managers.localizer:lookup("holy_hand_grenade")
    -- or alternatively
    Localize("holy_hand_grenade")
    

    TODO
    - Reformat Captions Table, it is repeating all variations making it super big
    - Figure Out missing Patrol sounds
    - Figure Out which Patrol sounds are wrong
    - DONE - Make position of widget save during sessions
    - DONE - Boss Spawn Captions dont work
    - DONE - clear table on restart / level change
    - DONE - Fix caption duration being too long / captions not disappearing at all
    - DONE - Add new enemy Backstab Sounds
    - DONE - Other instances of new enemies that need to be added?
    - DONE - Localize for other languages as well? (Description of Captions and Captions themselves)
    - DONE - removed tooltips obscuring the checkboxes when going through settings
    - DONE - Fix Other languages other than german and english not working / breaking the mod
    - Maybe have other folk double check the translations?
    - Only have the debug menu be accessible in modded (in case someone is interested in sanctioning)
    - DONE - Korean Loca?
    - DONE - Brazilian Loca?

    NOTES
    ["da-dk"] = "da",
    ["de-at"] = "de",
    ["de-ch"] = "de",
    ["de-de"] = "de",
    ["en-ae"] = "en",
    ["en-au"] = "en",
    ["en-ca"] = "en",
    ["en-cz"] = "en",
    ["en-gb"] = "en",
    ["en-gr"] = "en",
    ["en-hk"] = "en",
    ["en-hu"] = "en",
    ["en-ie"] = "en",
    ["en-il"] = "en",
    ["en-in"] = "en",
    ["en-nz"] = "en",
    ["en-sa"] = "en",
    ["en-sg"] = "en",
    ["en-sk"] = "en",
    ["en-us"] = "en",
    ["en-za"] = "en",
    ["es-ar"] = "es",
    ["es-cl"] = "es",
    ["es-co"] = "es",
    ["es-es"] = "es",
    ["es-mx"] = "es",
    ["fi-fi"] = "fi",
    ["fr-be"] = "fr",
    ["fr-ca"] = "fr",
    ["fr-ch"] = "fr",
    ["fr-fr"] = "fr",
    ["it-it"] = "it",
    ["ja-jp"] = "jp",
    ["ko-kr"] = "kr",
    ["nb-no"] = "nb",
    ["nl-be"] = "nl",
    ["nl-nl"] = "nl",
    ["pl-pl"] = "pl",
    ["pt-br"] = "br-pt",
    ["pt-pt"] = "pt",
    ["ru-ru"] = "ru",
    ["sv-se"] = "sv",
    ["tr-tr"] = "tr",
    ["zh-cn"] = "zh",
    ["zh-hk"] = "zh",
    ["zh-sg"] = "zh",
    ["zh-tw"] = "zh",

    Steam
    ja: Japanese
    en: English
    fr: French
    es: Spanish
    de: German
    it: Italian
    nl: Dutch
    pt: Portuguese
    ru: Russian
    ko: Korean
    zht: Chinese (traditional)
    zhs: Chinese (simplified)
    fi: Finnish
    sv: Swedish
    da: Danish
    no: Norwegian
    pl: Polish
    hu: Hungarian
    th: Thai
    cs: Czech

]]