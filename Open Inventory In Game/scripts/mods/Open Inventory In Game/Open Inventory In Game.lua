local mod = get_mod("Open Inventory In Game")

local function is_at_inn()
    local game_mode = Managers.state.game_mode
    if not game_mode then return nil end
    return game_mode:game_mode_key() == "inn"
  end

mod:command("open_inventory", "Open Inventory In Game", function()
    if is_at_inn() then
      mod:echo("Use I you idiot.")
      return
    else
      Managers.ui:handle_transition("hero_view_force", {
        menu_sub_state_name = "equipment",
        menu_state_name = "overview",
        use_fade = true
    end
  })
  end)