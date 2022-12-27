local mod = get_mod("Disable Repel Sound Effect")

-- functions
local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end
function mod.add_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end
    TalentBuffTemplates[hero_name][buff_name] = new_talent_buff
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end


-- Repel (deactivate sound effect)	
mod:add_talent_buff_template ("wood_elf", "kerillian_thorn_sister_big_push_buff", {
    --activation_sound = "career_ability_kerilian_push",
    buffs = {
        {
            stat_buff = "push_range",
            buff_func = "thorn_sister_big_push"
        }
    }
})

