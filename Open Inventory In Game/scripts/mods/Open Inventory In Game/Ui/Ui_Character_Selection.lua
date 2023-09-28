Ui_Open_Inventory = class(Ui_Open_Inventory)
local mod = get_mod("Open Inventory In Game")

function Ui_Open_Inventory.init(self)
  self._is_open = false
end

function Ui_Open_Inventory.toggle(self)
  if self._is_open then
      self:close()
  else
      self:open()
  end
end

function Ui_Open_Inventory.open(self)
  self._is_open = true
  Imgui.open_imgui()
  self:capture_input()
end

function Ui_Open_Inventory.close(self)
  self._is_open = false
  Imgui.close_imgui()
  self:release_input()
end

function Ui_Open_Inventory.capture_input()
  ShowCursorStack.push()
  Imgui.enable_imgui_input_system(Imgui.KEYBOARD)
	Imgui.enable_imgui_input_system(Imgui.MOUSE)
end

function Ui_Open_Inventory.release_input()
  ShowCursorStack.pop()
  Imgui.disable_imgui_input_system(Imgui.KEYBOARD)
	Imgui.disable_imgui_input_system(Imgui.MOUSE)
end


local characters = {"Kruber", "Bardin", "Kerillian", "Saltzpyre", "Sienna"}
local career_kruber = {"Mercenary", "Huntsman", "Foot Knight", "Grail Knight"}
local career_bardin = {"Ranger Veteran", "Ironbreaker", "Slayer", "Outcast Engineer"}
local career_kerillian = {"Waystalker", "Handmaiden", "Shade", "Sister Of The Thorn"}
local career_saltspyre = {"Witch Hunter Captain", "Bounty Hunter", "Zealot", "Warrior Priest"}
local career_sienna = {"Battle Wizard", "Pyromancer", "Unchained"}


function Ui_Open_Inventory.draw(self)

  Imgui.set_next_window_size(400, 165)
  Imgui.set_next_window_pos(mod:get("window_position_x"), mod:get("window_position_y"))

  Imgui.begin_window("Character Selection")
  Imgui.spacing()
  Imgui.text(string.format("Character"))


  local last_character_index = mod.lookup_profile_index
  local character_index = Imgui.combo(" ##1", last_character_index, characters, 5)
  mod.lookup_profile_index = character_index

  if mod.lookup_profile_index ~= last_character_index then
    mod.lookup_career_index = 1
  end

  Imgui.spacing()
  Imgui.text(string.format("Career"))

  if character_index == 1 then
    local last_career_index = mod.lookup_career_index
    local career_index = Imgui.combo(" ##2", last_career_index, career_kruber, 4)
    mod.lookup_career_index = career_index
  end
  if character_index == 2 then
    local last_career_index = mod.lookup_career_index
    local career_index = Imgui.combo(" ##2", last_career_index, career_bardin, 4)
    mod.lookup_career_index = career_index
  end
  if character_index == 3 then
    local last_career_index = mod.lookup_career_index
    local career_index = Imgui.combo(" ##2", last_career_index, career_kerillian, 4)
    mod.lookup_career_index = career_index
  end
  if character_index == 4 then
    local last_career_index = mod.lookup_career_index
    local career_index = Imgui.combo(" ##2", last_career_index, career_saltspyre, 4)
    mod.lookup_career_index = career_index
  end
  if character_index == 5 then
    local last_career_index = mod.lookup_career_index
    local career_index = Imgui.combo(" ##2", last_career_index, career_sienna, 3)
    mod.lookup_career_index = career_index
  end

  Imgui.spacing()

  if Imgui.small_button("> Change Hero <") then
    mod.change_hero()
    mod.close_menu()
    --self:close()
  end

  Imgui.spacing()
  Imgui.spacing()

  if Imgui.small_button("- Rescue Yourself -") then
    mod.revive_self()
    mod.close_menu()
    --self:close()
  end

  Imgui.end_window()


end

return Ui_Open_Inventory