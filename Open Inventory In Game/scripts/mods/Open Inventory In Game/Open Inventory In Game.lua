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

-- doesnt work
-- mod.open_weave_forge = function ()
--   Managers.ui:handle_transition("hero_view_force", {
--     use_fade = true,
--     menu_state_name = "weave_forge"
--   })
-- end



--Add functionallity to all UI versions
--Managers.Package:load("Package/ui_store_preview/world", "global")
--Managers.level:load("levels/ui_store_preview/world", "global")



------------------------------------------------------------------
---------------- Open Character Selection Window -----------------
------------------------------------------------------------------



-- UI stuff to load init
-- UI stuff to open and close

local Ui_Open_Inventory = mod:dofile("scripts/mods/Open Inventory In Game/Ui/Ui_Character_Selection")
mod.Ui_Open_Inventory = Ui_Open_Inventory:new()

mod.HeroWindowLoadoutInventory_open = false
mod.grail_knight_quest_remove_receive = false
mod.player_unique_id_of_grail_knight_player = "11000011071b7cc:1"

-- update the drawing of the imgui window every frame
function mod.update()
  -- check if someone swapped off of gk to remove the quest as host
  local is_server = Managers.player.is_server
  if mod.grail_knight_quest_remove_receive and is_server then
    mod.remove_grail_knight_challenges_when_swapped_off()
    mod.grail_knight_quest_remove_receive = false
  end

  -- check for checkbox
  if mod:get("open_character_selection_toggle") then
    -- check for if inventory is open
    if mod.Ui_Open_Inventory and mod.HeroWindowLoadoutInventory_open then
      Imgui.open_imgui() -- idea for imgui staying open
      mod.Ui_Open_Inventory:draw()
    end
  end
end

-- change variable when opening the inventory (yoinked from give weapon)
mod:hook_safe(HeroWindowLoadoutInventory, "on_enter", function(self)
	mod.HeroWindowLoadoutInventory_open = true
end)
mod:hook_safe(HeroWindowLoadoutInventory, "on_exit", function(self)
	mod.HeroWindowLoadoutInventory_open = false
end)

-- close the inventory when a career is swapped or revived
mod.close_menu = function ()
  Managers.ui:handle_transition("close_active", {
    use_fade = true
  })
end



-- Changing Progress
-- Tables for Characters and Careers

-- declaring tables with character and career strings (_revive beeing the order the game uses it)
local career_name
local profile_name
mod.lookup_profile_index = 1
local lookup_profile = {
  "empire_soldier",
  "dwarf_ranger",
  "wood_elf",
  "witch_hunter",
  "bright_wizard"
}
local lookup_profile_revive = {
  "witch_hunter",
  "bright_wizard",
  "dwarf_ranger",
  "wood_elf",
  "empire_soldier"
}
mod.lookup_career_index = 1
local lookup_career = {
  "es_mercenary",
  "es_huntsman",
  "es_knight",
  "es_questingknight",
  "dr_ranger",
  "dr_ironbreaker",
  "dr_slayer",
  "dr_engineer",
  "we_waywatcher",
  "we_maidenguard",
  "we_shade",
  "we_thornsister",
  "wh_captain",
  "wh_bountyhunter",
  "wh_zealot",
  "wh_priest",
  "bw_adept",
  "bw_scholar",
  "bw_unchained",
  "bw_necromancer"
}
local lookup_career_revive = {
  "wh_captain",
  "wh_bountyhunter",
  "wh_zealot",
  "wh_priest",
  "bw_adept",
  "bw_scholar",
  "bw_unchained",
  "bw_necromancer",
  "dr_ranger",
  "dr_ironbreaker",
  "dr_slayer",
  "dr_engineer",
  "we_waywatcher",
  "we_maidenguard",
  "we_shade",
  "we_thornsister",
  "es_mercenary",
  "es_huntsman",
  "es_knight",
  "es_questingknight"
}
local owns_career = {
  es_questingknight = false,
  dr_engineer = false,
  we_thornsister = false,
  wh_priest = false,
  bw_necromancer = false
}
local owns_dlc_check = true


mod.get_profile_to_change = function ()
  local profile_index = mod.lookup_profile_index
  profile_name = lookup_profile[profile_index]
end

-- calculate the value of the table to get the correct career and character string
mod.get_career_to_change = function ()

  local profile_index = mod.lookup_profile_index
  local career_index = mod.lookup_career_index

  if profile_index > 1 then
    career_index = 4 * (profile_index - 1) + career_index
  end

  if career_index == 4 and owns_career.es_questingknight == false then
    owns_dlc_check = false
  elseif career_index == 8 and owns_career.dr_engineer == false then
    owns_dlc_check = false
  elseif career_index == 12 and owns_career.we_thornsister == false then
    owns_dlc_check = false
  elseif career_index == 16 and owns_career.wh_priest == false then
    owns_dlc_check = false
  elseif career_index == 20 and owns_career.bw_necromancer == false then
    owns_dlc_check = false
  end

  career_name = lookup_career[career_index]

end

-- actually change the player character with values determined before
mod.change_hero = function ()

  mod.get_profile_to_change()
  mod.get_career_to_change()

  if career_name and profile_name and owns_dlc_check == true then

    local player = Managers.player:local_player()
    local career_index = player:career_index()
    local profile_index = player:profile_index()
    local local_player_id = 1
    if career_index == 4 and profile_index == 5 then
      local player_unique_id = player:unique_id()
      mod.player_unique_id_of_grail_knight_player = player_unique_id
      mod.grail_knight_quest_remove_value_adjustment()
    end

    Managers.state.network:request_profile(local_player_id, profile_name, career_name, true)
  else
    mod:echo("[Open Inventory In Game]: You can't change to a career you don't own.")
  end

  owns_dlc_check = true

end

-- request the same profile you are already using and force respawn it
mod.revive_self = function ()

  local player = Managers.player:local_player()
  local career_index = player:career_index()
  local profile_index = player:profile_index()

  if profile_index > 1 then
    career_index = 4 * (profile_index - 1) + career_index
  end

  local profile_name = lookup_profile_revive[profile_index]
  local career_name = lookup_career_revive[career_index]

  if career_name and profile_name then
    Managers.state.network:request_profile(1, profile_name, career_name, true)
  end

end



-- sanity checks for dlc careers
-- disabling gk quest when swapping off of him


-- run once when entering the game
local dlc_check = false
mod.on_game_state_changed = function(status, state_name)
  if status == "enter" and state_name == "StateIngame" and dlc_check == false then
    mod.get_owned_dlcs()
    dlc_check = true
  end
end

-- check for character dlcs and write the ones that are owned to table
mod.get_owned_dlcs = function ()
  local dlcs_interface = Managers.backend:get_interface("dlcs")
  local owned_dlc_data = dlcs_interface:get_owned_dlcs()

  for i = 1, #owned_dlc_data, 1 do

    if owned_dlc_data[i] == "lake" then
      owns_career.es_questingknight = true
    end
    if owned_dlc_data[i] == "cog" then
      owns_career.dr_engineer = true
    end
    if owned_dlc_data[i] == "woods" then
      owns_career.we_thornsister = true
    end
    if owned_dlc_data[i] == "bless" then
      owns_career.wh_priest = true
    end
    if owned_dlc_data[i] == "sythe" then --unknown dlc just a guess
      owns_career.bw_necromancer = true
    end
  end

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


-- TODO
-- Done -- make sure not beeing able to swap to career that isnt owned
-- Done -- close inventory when swapping
-- DONE -- reset to 1st career when character is changed
-- DONE (doesnt close other windows but can still get closed by other windows) -- make sure other IMGUI windows dont also close
-- DONE (probably related to something else, no way to reproduce) -- figure out if problems exist or not in terms of balance mods
-- DONE -- Grail Knight quests reset and delete
-- DONE -- Add necromancer to ui and figure out dlc name
-- DONE -- remove quests from gk through host if possible otherwise leave it bugged ig
-- let dlc check run again when mods get reloaded
-- technically not an issue yet but if bots would change mid game gk quests would stay