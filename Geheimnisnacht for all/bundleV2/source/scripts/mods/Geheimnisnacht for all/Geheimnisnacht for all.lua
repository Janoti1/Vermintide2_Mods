local mod = get_mod("Geheimnisnacht for all")

-- Created by Janoti 2022-10-30
-- Thanks to the former Author Craven for the mod from last year and his Code
-- Thanks to Actual Trash for helping me deciding positions and testing the mod


-- load Geheimnisnacht as Global (Not possible to load as local as the gamemode differs)
local package_name = "resource_packages/dlcs/geheimnisnacht_2021_event"
local async = true
local prioritize = false
Managers.package:load(package_name, "global", nil, async, prioritize)



local spawn_lists = {
	skaven = {
		"skaven_plague_monk",
		"skaven_clan_rat",
		"skaven_plague_monk",
		"skaven_clan_rat",
		"skaven_plague_monk",
		"skaven_clan_rat"
	},
	chaos = {
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder",
		"chaos_marauder"
	}
}
local spawn_categories = table.keys(spawn_lists)

local event_settings = {
	--test
	whitebox = { -- default spawn check
		ritual_locations = {
			{
				0,
				0,
				0,
				0
			}
		}
	},
	prologue = { --prologue
	ritual_locations = {
			{
				53.97,
				-29.81,
				-13.92,
				0
			}
		}
	},
	--helmgart
	military = { -- Rightous Stand
	ritual_locations = {
			{
				91,
				147,
				-19.5,
				90
			}
		}
	},
	catacombs = { --convocation of decay
		ritual_locations = {
			{
				178.8,
				109,
				32,
				50
			}
		}
	},
	mines = { -- Hunger in the Dark
		ritual_locations = {
			{
				-76.08,
				130,
				22.75,
				5
			}
		}
	},
	ground_zero = { -- halescourge
		ritual_locations = {
			{
				-171.5,
				102.7,
				42.094002,
				20
			}
		}
	},
	elven_ruins = { --athel yenlui
		ritual_locations = {
			{
				37.891605,
				-109,
				19.562,
				0
			}
		}
	},
	bell = { -- screaming bell
	ritual_locations = {
			{
				-62.059746,
				-178.81282,
				-34.657001,
				0
			}
		}
	},
	fort = { -- fort brachsenbrücke
	ritual_locations = {
			{
				52.39,
				306.66,
				-21.86,
				0
			}
		}
	},
	skaven_stronghold = { --into the nest
	ritual_locations = {
			{
				-85.65,
				-20.70,
				57.04,
				0
			}
		}
	},
	skittergate = { --skittergate
	ritual_locations = {
			{
				-216.85,
				-446.45,
				-67.74,
				0
			}
		}
	},
	farmlands = { --against the grain
		ritual_locations = {
			{
				223.965363,
				-253.689133,
				7.712,
				0
			}
		}
	},
	ussingen = { -- Empire in Flames
	ritual_locations = {
			{
				-4.573383,
				-160.917343,
				1.135474,
				0
			}
		}
	},
    nurgle = { -- festering ground
		ritual_locations = {
			{
				105.57,
				-224.51,
				27.82,
				0
			}
		}
	},
    warcamp = { --warcamp
		ritual_locations = {
			{
				-225.89,
				-69.38,
				17.66,
				0
			}
		}
	},
	--V1
    cemetery = { --garden of morr
		ritual_locations = {
			{
				23.04,
				-72.83,
				9.83,
				0
			}
		}
	},
    forest_ambush = { --Engines of War
		ritual_locations = {
			{
				32.61,
				-84.91,
				-3.37,
				0
			}
		}
	},
	magnus = { --horn of magnus
	ritual_locations = {
			{
				-185.71,
				77.74,
				4.79,
				0
			}
		}
	},
	plaza = { --FOW
	ritual_locations = {
			{
				51.48,
				28.90,
				3,06,
				0
			}
		}
	},
	--bogenhafen
	dlc_bogenhafen_city = { --blightreaper
		ritual_locations = {
			{
				59.76,
				78.29,
				-2.56,
				0
			}
		}
	},
    dlc_bogenhafen_slum = { --the pit
		ritual_locations = {
			{
				-125.07,
				-222.29,
				-2.64,
				0
			}
		}
	},
	--lair
    dlc_bastion = { --blood in darkness
    ritual_locations = {
            {
                75.06,
                76.24,
                -46.46,
                0
            }
        }
    },
    dlc_castle = { --Enchanters lair
    ritual_locations = {
            {
				5.584873,
				65.619408,
				0,
				-40
            }
        }
    },
    dlc_portals = { --old haunts
    ritual_locations = {
            {
				-178.758,
				224.85,
				-45.733,
				0
            }
        }
    },
	--cata
    crater = { --dark omens
    ritual_locations = {
			{
				115.57,
				-443.43,
				29.3,
				0
			}
		}
	},
	--Trail
	dlc_wizards_trail = { --trails of treachery
		ritual_locations = {
			{
				190.79,
				-14.60,
				407.12,
				0
			}
		}
	},
	dlc_wizards_tower = { --tower of treachery
		ritual_locations = {
			{
				18.94,
				17.052,
				6.99,
				0
			}
		}
	},
	--bonus
	dlc_celebrate_crawl = { --a quiet drink
		ritual_locations = {
			{
				-38.53,
				-160.55,
				-25.39,
				0
			}
		}
	},
}

local hard_mode_mutators = {
	"geheimnisnacht_2021_hard_mode"
}

local function side_objective_picked_up()
	local pop_chat = true
	local message = Localize("system_chat_geheimnisnacht_2021_hard_mode_on")

	Managers.chat:add_local_system_message(1, message, pop_chat)

	local mutator_handler = Managers.state.game_mode._mutator_handler

	mutator_handler:initialize_mutators(hard_mode_mutators)

	for i = 1, #hard_mode_mutators, 1 do
		mutator_handler:activate_mutator(hard_mode_mutators[i])
	end
end

local function side_objective_picked_dropped()
	local pop_chat = true
	local message = Localize("system_chat_geheimnisnacht_2021_hard_mode_off")

	Managers.chat:add_local_system_message(1, message, pop_chat)

	local mutator_handler = Managers.state.game_mode._mutator_handler

	for i = 1, #hard_mode_mutators, 1 do
		local mutator_name = hard_mode_mutators[i]
		local mutator_active = mutator_handler:has_activated_mutator(mutator_name)

		if mutator_active then
			mutator_handler:deactivate_mutator(mutator_name)
		end
	end
end


MutatorTemplates["geheimnisnacht_2021"]["server_start_function"] = function(context, data)
    	local level_key = Managers.state.game_mode:level_key()
		local settings = event_settings[level_key]

		if settings then
			local ritual_locations = settings.ritual_locations
			local up = Vector3.up()

			for i = 1, #ritual_locations, 1 do
				local location = ritual_locations[i]
				local pos = Vector3(location[1], location[2], location[3])
				local rot = Quaternion.axis_angle(up, math.rad(location[4]))

				data.template.spawn_ritual_ring(pos, rot)
			end

			local inventory_system = Managers.state.entity:system("inventory_system")

			inventory_system:register_event_objective("wpn_geheimnisnacht_2021_side_objective", side_objective_picked_up, side_objective_picked_dropped)
		else 
		local level_key = Managers.state.game_mode:level_key()
		if string.find(level_key, "inn_level") or string.find(level_key, "morris_hub") then 
			return
		end

      local loaded = PackageManager:has_loaded("resource_packages/dlcs/geheimnisnacht_2021_event", geheimnisnacht_2021)
      if not loaded then
        mod:echo("[Geheimnisnacht+]: Loading package: %s", resource_packages/dlcs/geheimnisnacht_2021_event)
      end

    local inventory_system = Managers.state.entity:system("inventory_system")
	inventory_system:register_event_objective("wpn_geheimnisnacht_2021_side_objective", side_objective_picked_up, side_objective_picked_dropped)

    end
end

mod.on_game_state_changed = function(status, state)
    if status == "enter" and state == "StateIngame" and mod:is_enabled() then
        local mutator_handler = Managers.state.game_mode._mutator_handler

        if not mutator_handler:has_activated_mutator("geheimnisnacht_2021") then
            mod:echo("[Geheimnisnacht+]: Activating %s", Localize("display_name_mutator_geheimnisnacht_2021"))
            mutator_handler:activate_mutator("geheimnisnacht_2021")
        end

        if not mutator_handler:has_activated_mutator("night_mode") then
            mod:echo("[Geheimnisnacht+]: Activating %s", Localize("display_name_mutator_night_mode"))
            mutator_handler:activate_mutator("night_mode")
        end
    end
end

mod:echo("Geheimnisnacht+ v1.2 enabled")