local mod = get_mod("Open Inventory In Game")

------------------------------------------------------------------
---------------- Open Inventory ----------------------------------
------------------------------------------------------------------

--local function to open the inventory
mod.open_inventory = function()
  --open the inventory
  Managers.ui:handle_transition("hero_view_force", {
      menu_sub_state_name = "equipment",
      menu_state_name = "overview",
      use_fade = true,
  })
end
--local command open_the_inventory()
mod:command("open_inventory", mod:localize("command_description"), function()
mod:open_inventory()
end)


------------------------------------------------------------------
---------------- Open Character Selection Window -----------------
------------------------------------------------------------------




mod.grail_knight_quest_remove_receive = false
mod.player_unique_id_of_grail_knight_player = "11000011071b7cc:1"

-- check if someone swapped off of gk to remove the quest as host
function mod.update()
local is_server = Managers.player.is_server
  if mod.grail_knight_quest_remove_receive and is_server then
    mod.remove_grail_knight_challenges_when_swapped_off()
    mod.grail_knight_quest_remove_receive = false
  end
end

-- close the inventory when a career is swapped or revived
mod.close_menu = function ()
Managers.ui:handle_transition("close_active", {
  use_fade = true
})
end



-- Changing Progress
-- actually change the player character
mod.change_hero = function (self, new_profile_index, new_career_index)

  -- get active career indexes
  local player = Managers.player:local_player()
  local old_career_index = player:career_index()
  local old_profile_index = player:profile_index()

  -- Check if Player is on Grail Knight and if so remove their quests
  if old_career_index == 4 and old_profile_index == 5 then
    local player_unique_id = player:unique_id()
    mod.player_unique_id_of_grail_knight_player = player_unique_id
    mod.grail_knight_quest_remove_value_adjustment()
  end

  -- convert indexes to names
  local profile = SPProfiles[new_profile_index]
  local profile_name = profile.display_name
  local career_name = profile.careers[new_career_index].name

  -- Change Career
  Managers.state.network:request_profile(1, profile_name, career_name, true)

  -- Close the Inventory
  mod.close_menu()

end

-- remove grail knight quests
mod.remove_grail_knight_challenges_when_swapped_off = function ()
local is_server = Managers.player.is_server

  if is_server then
    local CHALLENGE_CATEGORY = "questing_knight"
    local challenge_manager = Managers.venture.challenge
    local player_unique_id = mod.player_unique_id_of_grail_knight_player

    challenge_manager:remove_filtered_challenges(CHALLENGE_CATEGORY, player_unique_id)
  end

end

-- send if grail knight quest has to get removed and the player_unique_id of the gk to everyone so the host will remove it next update
mod.grail_knight_quest_remove_value_adjustment = function ()
  mod.grail_knight_quest_remove_receive = true
  mod:network_send("settings_sync", "all", mod.grail_knight_quest_remove_receive, mod.player_unique_id_of_grail_knight_player)
end
mod:network_register("settings_sync", function(sender, grail_knight_quest_remove_send, player_id_of_grail_knight_player)
  mod.grail_knight_quest_remove_receive = grail_knight_quest_remove_send
  mod.player_unique_id_of_grail_knight_player = player_id_of_grail_knight_player
end)

-- check if the player owns the Career Dlc
mod.check_for_dlc_ownership = function (self, profile_index, career_index)

  local dlcs_interface = Managers.backend:get_interface("dlcs")
  local owned_dlc_data = dlcs_interface:get_owned_dlcs()

  local profile = SPProfiles[profile_index]
  local career_name = profile.careers[career_index].name
  local career_dlc_name = profile.careers[career_index].required_dlc

  local owns_dlc = false

  for i = 1, #owned_dlc_data, 1 do
    if owned_dlc_data[i] == career_dlc_name then
      owns_dlc = true
    end
  end

  return owns_dlc

end



--[[
Yoinked Code from ui_Improvements_switch.lua with permission by grasmann.
(slight adjustments here and there)

Author: grasmann

Lets you switch equippment of all characters / classes in inventory
--]]
-- ##### ██████╗  █████╗ ████████╗ █████╗ #############################################################################
-- ##### ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗ ############################################################################
-- ##### ██║  ██║███████║   ██║   ███████║ ############################################################################
-- ##### ██║  ██║██╔══██║   ██║   ██╔══██║ ############################################################################
-- ##### ██████╔╝██║  ██║   ██║   ██║  ██║ ############################################################################
-- ##### ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ############################################################################

mod.button_order = {4, 5, 2, 3, 1, 6}
mod.character_widgets = {}
mod.career_widgets = {}

-- ##### ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗ ###################################
-- ##### ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝ ###################################
-- ##### █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗ ###################################
-- ##### ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║ ###################################
-- ##### ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║ ###################################
-- ##### ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ###################################
--[[
Check if a career is unlocked
--]]
mod.career_unlocked = function(self, profile_index, career_index)
local unlocked = false

local profile_settings = SPProfiles[profile_index]
local display_name = profile_settings.display_name

local hero_attributes = Managers.backend:get_interface("hero_attributes")
local hero_experience = hero_attributes:get(display_name, "experience") or 0
local hero_level = ExperienceSettings.get_level(hero_experience)

local career_name = SPProfiles[profile_index].careers[career_index].name

unlocked = ProgressionUnlocks.is_unlocked_for_profile(career_name, display_name, hero_level)

return unlocked
end
--[[
Get protrait frame for given profile and career
--]]
mod.get_portrait_frame = function(self, profile_index, career_index)
local player_portrait_frame = "portrait_frame_0000"

local profile = SPProfiles[profile_index]
local career_data = profile.careers[career_index]
local career_name = career_data.name
local item = BackendUtils.get_loadout_item(career_name, "slot_frame")
local frame_name = "default"

if item then
  local item_data = item.data
  frame_name = item_data.key
  local frame_texture = UIPlayerPortraitFrameSettings[frame_name][1].texture
  player_portrait_frame = frame_texture or player_portrait_frame
end

return player_portrait_frame, frame_name
end
--[[
Create character button widget
--]]
mod.create_character_button = function(self, profile_index)

-- Values (adjusted to make space for a 6th icon)
local root = {90, 230, 20}
local size = {50, 50}
local size_selected = {70, 70}
local space = 10

local p_index = mod.button_order[profile_index]
local mp_index = mod.button_order[mod.profile_index]

-- Calculate
local pos = {root[1] + (size[1]+space)*(p_index-1), root[2], root[3]}
local is_selected = mod.profile_index == profile_index

-- Current profile
if mp_index < p_index then pos[1] = pos[1] + size_selected[1]-size[1] end

-- Textures
-- Change Icon  to Custom Icon
if profile_index == 6 then
  SPProfiles[profile_index].hero_selection_image = "open_inventory_swap_icon"
end

local icon_texture = SPProfiles[profile_index].hero_selection_image
local glow_texture = "hero_icon_glow"

local definition = {
  scenegraph_id = "hero_info_bg",
  element = {
    passes = {
      -- TEXTURES
      {
        pass_type = "texture",
        style_id = "icon",
        texture_id = "icon",
        content_check_function = function(content)
          return not content.button_hotspot.is_hover and not content.is_selected
        end
      },
      {
        pass_type = "texture",
        style_id = "icon_hovered",
        texture_id = "icon",
        content_check_function = function(content)
          return content.button_hotspot.is_hover and not content.is_selected
        end
      },
      {
        pass_type = "texture",
        style_id = "icon_selected",
        texture_id = "icon",
        content_check_function = function(content)
          return content.is_selected
        end
      },
      {
        pass_type = "texture",
        style_id = "glow_selected",
        texture_id = "glow",
        content_check_function = function(content)
          return content.is_selected
        end
      },
      -- HOTSPOT
      {
        pass_type = "hotspot",
        style_id = "button_hotspot",
        content_id = "button_hotspot",
        content_check_function = function(content)
          return not content.is_selected
        end
      },
    },
  },

  content = {
    icon = icon_texture,
    glow = glow_texture,
    profile_index = profile_index,
    button_hotspot = {},
    is_selected = is_selected,
    disable_button = false,
  },

  style = {
    -- TEXTURES
    icon = {
      offset = {0, 0, 0},
      size = size,
      color = {255, 127, 127, 127}
    },
    icon_hovered = {
      offset = {-3, 0, 0},
      size = {size[1]+6, size[2]+6},
      color = {255, 200, 200, 200}
    },
    icon_selected = {
      offset = {0, 0, 0},
      size = size_selected,
      color = {255, 255, 255, 255}
    },
    glow_selected = {
      offset = {-35, -35, 0},
      size = {size_selected[1]+70, size_selected[2]+70},
      color = {255, 200, 200, 200}
    },
    -- HOTSPOT
    button_hotspot = {
      offset = {0, 0, 0},
      size = size,
    },
  },
  offset = pos,
}

return UIWidget.init(definition)
end
--[[
Change character
--]]
mod.change_character = function(self, profile_index)

-- when the custom button is pressed its profile_index will be 6
if profile_index == 6 then

  -- swap to current career
  mod:change_hero(mod.profile_index, mod.career_index)

elseif mod.profile_index ~= profile_index then

  -- Set selected profile index
  mod.profile_index = profile_index

  -- Set selected career index
  local profile_settings = SPProfiles[profile_index]
  local display_name = profile_settings.display_name
  local hero_attributes = Managers.backend:get_interface("hero_attributes")
  local career_index = hero_attributes:get(display_name, "career") --or mod.orig_get_career(hero_attributes, display_name, "career") -- not mod.orig_get_career and
  mod.career_index = career_index

  -- Delete career widgets ( because not all characters have the same amount of careers now )
  mod.career_widgets = {}

  -- Overwrite functions
  mod:overwrite_functions(true)

  -- Reopen view
  self:reopen_hero_view()
  
  -- Reset functions
  mod:overwrite_functions(false)
  
end

end
--[[
Create career button widget
--]]
mod.create_career_button = function(self, profile_index, career_index)

-- Values
local root = {200, 40, 20}
local size = {60, 70}
local space = 50
if #SPProfiles[profile_index].careers == 4 then
  root = {170, 40, 20}
  space = 30
end

-- Calculate
local pos = {root[1] + (size[1]+space)*(career_index-1), root[2], root[3]}
local is_selected = mod.career_index == career_index

-- Textures
local career_settings = SPProfiles[profile_index].careers[career_index]
local portrait_texture = "small_"..career_settings.portrait_image
local portrait_frame_texture, portrait_frame_name = self:get_portrait_frame(profile_index, career_index)

-- check for dlc ownership of 4th career
if career_index == 4 then
  if mod:check_for_dlc_ownership(profile_index, career_index) == false then
    return
  end
end

-- get the frame size (the values can be stored in two different places)
-- check if the frame's texture exists in gui_items_atlas
local frame_settings_exist = UIAtlasHelper.has_atlas_settings_by_texture_name(portrait_frame_texture)
local frame_settings
if frame_settings_exist == true then
  -- get frame settings from table gui_items_atlas
  frame_settings = UIAtlasHelper.get_atlas_settings_by_texture_name(portrait_frame_texture)
else
  -- get frame settings from table UIPlayerPortraitFrameSettings
  frame_settings = UIPlayerPortraitFrameSettings[portrait_frame_name][1]
end

--  calculate new frame size
local frame_size = {frame_settings.size[1] / 1.55, frame_settings.size[2] / 1.55}
local frame_pos = {size[1]/2 - frame_size[1]/2, -5, 0}

local definition = {
  scenegraph_id = "hero_info_bg",
  element = {
    passes = {
      -- TEXTURES
      {
        pass_type = "texture",
        style_id = "portrait",
        texture_id = "portrait",
        content_check_function = function(content)
          return not content.button_hotspot.is_hover
        end
      },
      {
        pass_type = "texture",
        style_id = "portrait_hovered",
        texture_id = "portrait",
        content_check_function = function(content)
          return content.button_hotspot.is_hover
        end
      },
      {
        pass_type = "texture",
        style_id = "portrait_frame",
        texture_id = "portrait_frame",
        content_check_function = function(content)
          return not content.button_hotspot.is_hover
        end
      },
      {
        pass_type = "texture",
        style_id = "portrait_frame_hovered",
        texture_id = "portrait_frame",
        content_check_function = function(content)
          return content.button_hotspot.is_hover
        end
      },
      -- HOTSPOT
      {
        pass_type = "hotspot",
        style_id = "button_hotspot",
        content_id = "button_hotspot",
      },
    },
  },

  content = {
    portrait = portrait_texture,
    portrait_frame = portrait_frame_texture,
    profile_index = profile_index,
    career_index = career_index,
    button_hotspot = {},
    is_selected = is_selected,
    disable_button = false,
  },

  style = {
    -- TEXTURES
    portrait = {
      offset = {0, 0, 0},
      size = size,
      color = {255, 127, 127, 127}
    },
    portrait_hovered = {
      offset = {-3, 0, 0},
      size = {size[1]+6, size[2]+6},
      color = {255, 255, 255, 255}
    },
    portrait_frame = {
      offset = frame_pos,
      size = frame_size,
      color = {255, 127, 127, 127}
    },
    portrait_frame_hovered = {
      offset = {frame_pos[1]-3, frame_pos[2], frame_pos[3]},
      size = {frame_size[1]+6, frame_size[2]+6},
      color = {255, 255, 255, 255}
    },
    -- HOTSPOT
    button_hotspot = {
      offset = {0, 0, 0},
      size = size,
    },
  },
  offset = pos,
}

return UIWidget.init(definition)
end
--[[
Change career in Inventory
--]]
mod.change_career = function(self, profile_index, career_index)

-- Set selected profile index
mod.profile_index = profile_index

-- Set selected career index
mod.career_index = career_index

-- Overwrite functions
mod:overwrite_functions(true)

-- Reopen view
self:reopen_hero_view()

-- Reset functions
mod:overwrite_functions(false)

end
--[[
Get profile and career indices
--]]
mod.get_profile_data = function(self)
local player = Managers.player:local_player()
self.actual_profile_index = self.actual_profile_index or player:profile_index()
self.profile_index = self.profile_index or self.actual_profile_index
self.actual_career_index = self.actual_career_index or player:career_index()
self.career_index = self.career_index or self.actual_career_index
end
--[[
Delete profile and career indices
--]]
mod.delete_profile_data = function(self)
self.profile_index = nil
self.career_index = nil
self.actual_profile_index = nil
self.actual_career_index = nil
end

-- ##### ██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗███████╗ ###################################################################
-- ##### ██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██╔════╝ ###################################################################
-- ##### ███████║██║   ██║██║   ██║█████╔╝ ███████╗ ###################################################################
-- ##### ██╔══██║██║   ██║██║   ██║██╔═██╗ ╚════██║ ###################################################################
-- ##### ██║  ██║╚██████╔╝╚██████╔╝██║  ██╗███████║ ###################################################################
-- ##### ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝ ###################################################################
--[[
Update position of default hero protrait
--]]
mod:hook_safe(HeroWindowOptions, "_update_hero_portrait_frame", function(self, ...)
local offset = {
  { x = -180, },
  { x = -80, },
  { x = 30, },
}
if #SPProfiles[mod.profile_index].careers == 4 then
  offset = {
    { x = -220, },
    { x = -130, },
    { x = -40, },
    { x = 40, },
  }
end
self._portrait_widget.offset[1] = offset[mod.career_index].x
end)
--[[
Create widgets
--]]
mod:hook_safe(HeroWindowOptions, "create_ui_elements", function(self, ...)
-- Character buttons (adjusted to add 6th button)
for p = 1, 6 do -- 1, 5
  mod.character_widgets[p] = mod:create_character_button(p)
end
-- Career buttons
for c = 1, 4 do
  if SPProfiles[mod.profile_index].careers[c] then
    mod.career_widgets[c] = mod:create_career_button(mod.profile_index, c)
  else
    mod.career_widgets[c] = nil
  end
end

-- Debug
-- self._widgets_by_name.game_option_3.content.button_hotspot.disable_button = false
-- self._widgets_by_name.game_option_5.content.button_hotspot.disable_button = false
end)
--[[
Draw button widgets
--]]
mod:hook_safe(HeroWindowOptions, "draw", function(self, dt, ...)
-- Get some shit
local ui_renderer = self.ui_renderer
local ui_scenegraph = self.ui_scenegraph
local input_service = self.parent:window_input_service()
-- Begin drawing
UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)
-- Character buttons
for _, widget in pairs(mod.character_widgets) do
  UIRenderer.draw_widget(ui_renderer, widget)
end
-- Career buttons
for _, widget in pairs(mod.career_widgets) do
  local career_unlocked = mod:career_unlocked(widget.content.profile_index, widget.content.career_index)
  if widget.content.career_index ~= mod.career_index and career_unlocked then
    UIRenderer.draw_widget(ui_renderer, widget)
  end
end
-- End drawing
UIRenderer.end_pass(ui_renderer)
end)
--[[
Handle hover effects
--]]
mod:hook_safe(HeroWindowOptions, "update", function(self, ...)
-- Character buttons
for _, widget in pairs(mod.character_widgets) do
  if not widget.content.disable_button and self:_is_button_hover_enter(widget) then
    if mod.profile_index ~= widget.content.profile_index then
      self:_play_sound("play_gui_equipment_button_hover")
    end
  end
end
-- Career buttons
for _, widget in pairs(mod.career_widgets) do
  if not widget.content.disable_button and self:_is_button_hover_enter(widget) then
    self:_play_sound("play_gui_equipment_button_hover")
  end
end
end)
--[[
Handle button press
--]]
mod:hook_safe(HeroWindowOptions, "post_update", function(self, ...)
--if not mod.crafting_animation_running then
  -- Character buttons
  for _, widget in pairs(mod.character_widgets) do
    if not widget.content.disable_button and self:_is_button_pressed(widget) then
      mod:change_character(widget.content.profile_index)
    end
  end
  -- Career buttons
  for _, widget in pairs(mod.career_widgets) do
    if not widget.content.disable_button and self:_is_button_pressed(widget) then
      mod:change_career(widget.content.profile_index, widget.content.career_index)
    end
  end
--end
end)
--[[
Prevent player respawn after skin change
--]]
mod:hook(HeroViewStateOverview, "update_skin_sync", function(func, self, ...)
-- If different character or career selected only update backend and menu
if mod.profile_index ~= mod.actual_profile_index or mod.career_index ~= mod.actual_career_index then
  self.skin_sync_id = self.skin_sync_id + 1
  return
end
-- Continue with original function
func(self, ...)
end)
--[[
Prevent item spawns when changing equipment
--]]
mod:hook(HeroViewStateOverview, "_set_loadout_item", function(func, self, item, strict_slot_name, ...)
-- If different character or career selected only update backend and menu
if mod.profile_index ~= mod.actual_profile_index or mod.career_index ~= mod.actual_career_index then

  local rarity_index = {common = 2, plentiful = 1, exotic = 4, rare = 3, unique = 5}
  --local slot_type = strict_slot_name or item.data.slot_type
  local slot, slot_type = nil
  if strict_slot_name then
    slot = InventorySettings.slots_by_name[strict_slot_name]
    slot_type = slot.type
  else
    slot_type = item.data.slot_type
    slot = self:_get_slot_by_type(slot_type)
  end
  --local slot = self:_get_slot_by_type(slot_type)
  local profile = SPProfiles[mod.profile_index]
  local career_name = profile.careers[mod.career_index].name
  local backend_items = Managers.backend:get_interface("items")

  backend_items:set_loadout_item(item.backend_id, career_name, slot.name)

  self.loadout_sync_id = self.loadout_sync_id + 1
  self.inventory_sync_id = self.inventory_sync_id + 1
  self.skin_sync_id = self.skin_sync_id + 1
  local highest_rarity = self.statistics_db:get_persistent_stat(self._stats_id, "highest_equipped_rarity", slot_type)
  local item_rarity = rarity_index[item.rarity]
  if item_rarity and highest_rarity < item_rarity then
    self.statistics_db:set_stat(self._stats_id, "highest_equipped_rarity", slot_type, item_rarity)
  end

  return
end
-- Continue with original function
func(self, item, strict_slot_name, ...)
end)






--[[
Yoinked Code from ui_improvements.lua with permission from grassmann
--]]
-- ##### ██████╗  █████╗ ████████╗ █████╗ #############################################################################
-- ##### ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗ ############################################################################
-- ##### ██║  ██║███████║   ██║   ███████║ ############################################################################
-- ##### ██║  ██║██╔══██║   ██║   ██╔══██║ ############################################################################
-- ##### ██████╔╝██║  ██║   ██║   ██║  ██║ ############################################################################
-- ##### ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ############################################################################

mod.actual_profile_index = nil
mod.profile_index = nil
mod.actual_career_index = nil
mod.career_index = nil
mod.orig_profile_by_peer = nil
mod.orig_get_career = nil
mod.sub_screen = "equipment"
mod.crafting_animation_running = false
mod.window_settings = {
loadout = "equipment",
talents = "talents",
crafting = "forge",
cosmetics_loadout = "cosmetics",
}
-- thanks for the tip to use this table @Sir Aiedail
mod.machine_empty = {}

-- ##### ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗ ###################################
-- ##### ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝ ###################################
-- ##### █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗ ###################################
-- ##### ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║ ###################################
-- ##### ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║ ###################################
-- ##### ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ###################################

--[[
Get hero view and check if view is open
--]]
mod.get_hero_view = function(self)
local ui = Managers.ui
local ingame_ui = ui and ui._ingame_ui
local hero_view_active = ingame_ui and ingame_ui.current_view == "hero_view"
local hero_view = hero_view_active and ingame_ui.views["hero_view"]

return hero_view
end
--[[
Reopen hero view
--]]
mod.reopen_hero_view = function(self)
local hero_view = mod:get_hero_view()
hero_view:_change_screen_by_name("overview", mod.sub_screen, mod.machine_empty)
end
--[[
Overwrite profile and career functions
fixed career function not getting called (adjusted calling same function as profile function instead)
--]]
mod.overwrite_functions = function(self, overwrite)
local hero_view = mod:get_hero_view()
local ingame_ui_context = hero_view.ingame_ui_context

if overwrite then

  -- Backup orig profile function
  if not mod.orig_profile_by_peer then
    mod.orig_profile_by_peer = ingame_ui_context.profile_synchronizer.profile_by_peer
  end

  -- Overwrite profile and career function (fixed)
  ingame_ui_context.profile_synchronizer.profile_by_peer = function(self, peer_id, local_player_id)
    if mod.profile_index or mod.career_index then
      return mod.profile_index, mod.career_index
    else
      mod.orig_profile_by_peer(self, peer_id, local_player_id)
    end
  end

  -- Backup original career function
  -- if not mod.orig_get_career then
  -- 	mod.orig_get_career = Managers.backend._interfaces["hero_attributes"].get
  -- end

  -- Overwrite career function (seems to not work as intended)
  -- Managers.backend._interfaces["hero_attributes"].get = function(self, hero_name, attribute_name)
  -- 	if attribute_name == "career" then
  -- 		mod:echo("in here")
  -- 		return mod.career_index or mod.orig_get_career(self, hero_name, attribute_name)
  -- 	end
  -- 	return mod.orig_get_career(self, hero_name, attribute_name)
  -- end

  -- local get = Managers.backend._interfaces["hero_attributes"].get
  -- get:()

else

  -- Reset profile function
  if mod.orig_profile_by_peer then
    ingame_ui_context.profile_synchronizer.profile_by_peer = mod.orig_profile_by_peer
    mod.orig_profile_by_peer = nil
  end

  -- Reset career function
  -- if mod.orig_get_career then
  -- 	Managers.backend._interfaces["hero_attributes"].get = mod.orig_get_career
  -- 	mod.orig_get_career = nil
  -- end

end
end

-- ##### ██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗███████╗ ###################################################################
-- ##### ██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██╔════╝ ###################################################################
-- ##### ███████║██║   ██║██║   ██║█████╔╝ ███████╗ ###################################################################
-- ##### ██╔══██║██║   ██║██║   ██║██╔═██╗ ╚════██║ ###################################################################
-- ##### ██║  ██║╚██████╔╝╚██████╔╝██║  ██╗███████║ ###################################################################
-- ##### ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝ ###################################################################
--[[
Hero view screen change
--]]
mod:hook(HeroView, "_change_screen_by_name", function(func, self, screen_name, sub_screen_name, optional_params, ...)
-- Get or delete data
if screen_name == "overview" then
  mod:get_profile_data()
elseif screen_name ~= "loot" then
  mod:delete_profile_data()
end
-- Orig function
func(self, screen_name, sub_screen_name, optional_params, ...)
end)
--[[
Set current sub screen in hero view
--]]
mod:hook_safe(HeroViewStateOverview, "_change_window", function(self, window_index_, window_name, ...)
mod.sub_screen = mod.window_settings[window_name] or mod.sub_screen
end)
--[[
Create window when opening hero view
--]]
mod:hook(HeroView, "on_enter", function(func, self, params, ...)
-- Skip when overview
if params.menu_state_name ~= "overview" then
  func(self, params, ...)
  return
end
-- Set values
mod:get_profile_data()
-- Orig function
func(self, params, ...)
end)
--[[
Reset values
--]]
mod:hook(HeroView, "on_exit", function(func, ...)
-- Reset values
mod:delete_profile_data()
-- Orig function
func(...)
end)





--[[
Author: grasmann

Prevents crashes when switching cosmetics items for other characters
Reopens saved cosmetics pages
--]]

-- ##### ██████╗  █████╗ ████████╗ █████╗ #############################################################################
-- ##### ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗ ############################################################################
-- ##### ██║  ██║███████║   ██║   ███████║ ############################################################################
-- ##### ██║  ██║██╔══██║   ██║   ██╔══██║ ############################################################################
-- ##### ██████╔╝██║  ██║   ██║   ██║  ██║ ############################################################################
-- ##### ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ############################################################################

local dont_save = false
local saved_index = 1

-- ##### ██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗███████╗ ###################################################################
-- ##### ██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██╔════╝ ###################################################################
-- ##### ███████║██║   ██║██║   ██║█████╔╝ ███████╗ ###################################################################
-- ##### ██╔══██║██║   ██║██║   ██║██╔═██╗ ╚════██║ ###################################################################
-- ##### ██║  ██║╚██████╔╝╚██████╔╝██║  ██╗███████║ ###################################################################
-- ##### ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝ ###################################################################
--[[
  Change saved cosmetics category on enter
--]]
mod:hook(HeroWindowCosmeticsInventory, "on_enter", function(func, self, ...)

  -- Prevent saved cosmetics category to be overwritten
dont_save = true
func(self, ...)
  dont_save = false
  
  -- Open saved cosmetics category
if saved_index and mod:get("remember_categories") then
  self.parent:set_selected_cosmetic_slot_index(saved_index)
  end
  
end)
--[[
  Save selected cosmetics category
--]]
mod:hook_safe(HeroWindowCosmeticsInventory, "_change_category_by_index", function(self, index, ...)

  -- Save opened cosmetics category
if not dont_save then saved_index = index end
  
end)




--[[
Author: grasmann

  Shows correct comparison tooltip on equipment for other characters
  Reopens saved inventory pages
--]]

-- ##### ██████╗  █████╗ ████████╗ █████╗ #############################################################################
-- ##### ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗ ############################################################################
-- ##### ██║  ██║███████║   ██║   ███████║ ############################################################################
-- ##### ██║  ██║██╔══██║   ██║   ██╔══██║ ############################################################################
-- ##### ██████╔╝██║  ██║   ██║   ██║  ██║ ############################################################################
-- ##### ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ############################################################################

local saved_index = 1
local dont_save = false
mod.orig_profile_index = nil
mod.orig_career_index = nil

-- ##### ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗ ###################################
-- ##### ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝ ###################################
-- ##### █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗ ###################################
-- ##### ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║ ###################################
-- ##### ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║ ###################################
-- ##### ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝ ###################################
--[[
  Overwrite functions
--]]
mod.overwrite_item_functions = function(self, overwrite)
  local player = Managers.player:local_player()

  if overwrite then

      -- Backup original profile function
      mod.orig_profile_index = player.profile_index

      -- Overwrite profile function
      player.profile_index = function(self)
          return mod.profile_index or mod.orig_profile_index(self)
      end

      -- Backup original career function
      mod.orig_career_index = player.career_index

      -- Overwrite career function
      player.career_index = function(self)
          return mod.career_index or mod.orig_career_index(self)
      end

  else

      -- Reset original profile functions
      if mod.orig_profile_index then
          player.profile_index = mod.orig_profile_index
          mod.orig_profile_index = nil
      end

      -- Reset original career functions
      if mod.orig_career_index then
          player.career_index = mod.orig_career_index
          mod.orig_career_index = nil
      end

  end

end

-- ##### ██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗███████╗ ###################################################################
-- ##### ██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██╔════╝ ###################################################################
-- ##### ███████║██║   ██║██║   ██║█████╔╝ ███████╗ ###################################################################
-- ##### ██╔══██║██║   ██║██║   ██║██╔═██╗ ╚════██║ ###################################################################
-- ##### ██║  ██║╚██████╔╝╚██████╔╝██║  ██╗███████║ ###################################################################
-- ##### ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝ ###################################################################
--[[
Render correct item tooltips
--]]
mod:hook(UIPasses.item_tooltip, "draw", function(func, ...)

  -- Overwrite item functions
  mod:overwrite_item_functions(true)

-- Original function
func(...)

-- Reset functions
  mod:overwrite_item_functions(false)

end)
--[[
Get correct items for selected character
--]]
mod:hook(ItemGridUI, "_get_items_by_filter", function(func, self, ...)

-- Overwrite item functions
  mod:overwrite_item_functions(true)

-- Orig function
  local items = func(self, ...)

-- Reset functions
  mod:overwrite_item_functions(false)

  -- local widget = self._widget
  -- local content = widget.content
  -- local passes = widget.element.passes
  -- mod:dump(passes, "passes", 2)

return items
end)
--[[
  Open saved inventory category on enter
--]]
mod:hook(HeroWindowLoadoutInventory, "on_enter", function(func, self, ...)

  -- Prevent saved inventory category being overwritten
dont_save = true
func(self, ...)
  dont_save = false
  
  -- Open saved inventory category
if saved_index and mod:get("remember_categories") then
  self.parent:set_selected_loadout_slot_index(saved_index)
  end
  
end)
--[[
  Save opened inventory category
--]]
mod:hook_safe(HeroWindowLoadoutInventory, "_change_category_by_index", function(self, index, ...)

  -- Save selected inventory category
  if not dont_save then saved_index = index end
  
end)





-- TODO
-- Done -- make sure not beeing able to swap to career that isnt owned
-- Done -- close inventory when swapping
-- DONE -- reset to 1st career when character is changed
-- DONE (doesnt close other windows but can still get closed by other windows) -- make sure other IMGUI windows dont also close
-- DONE (probably related to something else, no way to reproduce) -- figure out if problems exist or not in terms of balance mods
-- DONE -- Grail Knight quests reset and delete
-- DONE -- Add necromancer to ui and figure out dlc name
-- DONE -- remove quests from gk through host if possible otherwise leave it bugged ig
-- DONE -- let dlc check run again when mods get reloaded
-- technically not an issue yet but if bots would change mid game gk quests would stay
-- DONE -- Better DLC career Sanity Check to implement into the new version
-- Make it not work when ui improvements is turned on (atm not necessary imo)
-- DONE -- add check for frames that cant get found and use default instead or figure out where other  frames are stored
-- fix unknown issue when swapping to necromancer, hard to reproduce dunno if open inv is even the issue (skeleton ui material something)