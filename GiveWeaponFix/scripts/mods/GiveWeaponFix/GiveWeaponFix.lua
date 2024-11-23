local mod = get_mod("GiveWeaponFix")

--[[

	This Mod is a substitute mod for GiveWeapon which fixes some weapons spawning as their versus counterpart,
	which makes them not accessible in the adventure mode.

	GiveWeapon is created by PropJoe

	Janoti! - 2024-11-23

]]

local give_weapon = get_mod("GiveWeapon")
local pl = require'pl.import_into'()
mod:hook_origin(give_weapon, "create_weapon", function(item_type, give_random_skin, rarity, no_skin)

    if not give_weapon.current_careers then
		local player = Managers.player:local_player()
		local profile_index = player:profile_index()
		give_weapon.current_careers = pl.List(SPProfiles[profile_index].careers)
	end
	local current_career_names = give_weapon.current_careers:map(function(career) return career.name end)
	for item_key, item in pairs( ItemMasterList ) do

        if item.item_type == item_type
		and item.template
		and item.can_wield
        and string.sub(tostring(item_key), 1, 2) ~= "vs"
		and pl.List(item.can_wield) -- check if the item is valid career-wise
			:map(function(career_name) return current_career_names:contains(career_name) end)
			:reduce('or')
		then
			if item.skin_combination_table or pl.List{"necklace", "ring", "trinket"}:contains(item_type) then
				local skin
				if item.skin_combination_table and give_weapon.skin_names then
					skin = give_weapon.skin_names[give_weapon.sorted_skin_names[give_weapon.skins_dropdown.index]]
				end
				if give_weapon:get(give_weapon.SETTING_NAMES.NO_SKINS) then
					skin = nil
				end
				if give_random_skin then
					local skins = give_weapon.get_skins(item_type)
					skin = skins[math.random(#skins)]
				end

				local custom_properties = "{"
				for _, prop_name in ipairs( give_weapon.properties ) do
					custom_properties = custom_properties..'\"'..prop_name..'\":1,'
				end
				custom_properties = custom_properties.."}"

				local properties = {}
				for _, prop_name in ipairs( give_weapon.properties ) do
					properties[prop_name] = 1
				end

				local custom_traits = "["
				for _, trait_name in ipairs( give_weapon.traits ) do
					custom_traits = custom_traits..'\"'..trait_name..'\",'
				end
				custom_traits = custom_traits.."]"

				local rnd = math.random(1000000) -- uhh yeah
				local new_backend_id =  tostring(item_key) .. "_" .. rnd .. "_from_GiveWeapon"
				local entry = table.clone(ItemMasterList[item_key], true)
				entry.mod_data = {
				    backend_id = new_backend_id,
				    ItemInstanceId = new_backend_id,
				    CustomData = {
						-- traits = "[\"melee_attack_speed_on_crit\", \"melee_timed_block_cost\"]",
						traits = custom_traits,
						power_level = "300",
						properties = custom_properties,
						rarity = "exotic",
					},
					rarity = "exotic",
				    -- traits = { "melee_timed_block_cost", "melee_attack_speed_on_crit" },
				    traits = table.clone(give_weapon.traits, true),
				    power_level = 300,
				    properties = properties,
				}
				if skin then
					entry.mod_data.CustomData.skin = skin
					entry.mod_data.skin = skin
					entry.mod_data.inventory_icon = WeaponSkins.skins[skin].inventory_icon
				end

				entry.rarity = "exotic"

				entry.rarity = "default"
				entry.mod_data.rarity = "default"
				entry.mod_data.CustomData.rarity = "default"

				give_weapon.more_items_library:add_mod_items_to_local_backend({entry}, "GiveWeapon")

				give_weapon:echo("Spawned "..item_key)

				Managers.backend:get_interface("items"):_refresh()

				ItemHelper.mark_backend_id_as_new(new_backend_id)

				local backend_items = Managers.backend:get_interface("items")
				local new_item = backend_items:get_item_from_id(new_backend_id)

				if rarity then
					new_item.rarity = rarity
					new_item.data.rarity = rarity
					new_item.CustomData.rarity = rarity
				end

				if no_skin then
					new_item.skin = nil
				end

				give_weapon.properties = {}
				give_weapon.traits = {}
				return new_backend_id
			end
		end
	end
end)
