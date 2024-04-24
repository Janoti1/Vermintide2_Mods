local mod = get_mod("Disable Repel Sound Effect")

-- Repel (deactivate sound effect)	
local function disable_repel_sound_effect()
    if mod:get("disable_repel_sound_effect_id") then
        BuffTemplates.kerillian_thorn_sister_big_push_buff.activation_sound  = nil
    else
        BuffTemplates.kerillian_thorn_sister_big_push_buff.activation_sound  = "career_ability_kerilian_push"
    end
end

function mod:on_setting_changed()
    disable_repel_sound_effect()
end