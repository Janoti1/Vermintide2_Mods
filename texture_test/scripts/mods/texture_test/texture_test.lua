--[[

	This is a debugging mod that allows to check how a given texture looks like in game by using its name only.
	It is limited to UI Textures only that are currently loaded, which should cover most usecases, if more textures are needed the renderer will need have more materials added and those most likely also loaded beforehand.

	The Mod can be opperated via commands or the usage of the VMF menu.
	Thanks to Prisimism who made the text widget feature workable in VMF

	Janoti! - 2025-07-26
	
]]

local mod = get_mod("texture_test")

-- various variable declarations
local DEBUG_FONT_NAME = "arial"
local DEBUG_FONT_MTRL = "materials/fonts/" .. DEBUG_FONT_NAME

local texture_name = " "
local texture_position = {
	mod:get("icon_position_x"),
	mod:get("icon_position_y")
}
local texture_size = {
	80,
	80
}
local display_icon = false
local stop_update = true

--local world = Managers.world:world("level_world")
--local UIRenderer = UIRenderer.create(world, "material", "materials/ui/ui_1080p_loading")
--local definitions = require("scripts/ui/views/demo_character_previewer")
--local attract_mode_video = definitions.attract_mode_video
-- "material", attract_mode_video.video_name
-- "material", "materials/ui/ui_1080p_demo_textures"
-- "material", first_time_video.video_name

-- get world
local world = Managers.world:world("top_ingame_view")

-- create renderer and add all the various UI material atlasses to it
-- https://gitlab.com/qasikfwn/bitsquid-blender-tools/-/snippets/4875347
local renderer = UIRenderer.create(world,
	"material", "materials/ui/ui_1080p_loading",
	"material", "materials/ui/ui_1080p_common",
	"material", "materials/ui/ui_1080p_watermarks",
	
	"material", "materials/ui/ui_1080p_title_screen",
	"material", "materials/ui/ui_1080p_start_screen",
	
	"material", "materials/ui/ui_1080p_hud_atlas_textures",
	"material", "materials/ui/ui_1080p_hud_single_textures",
	
	"material", "materials/ui/ui_1080p_chat",
	"material", "materials/ui/ui_1080p_voice_chat",

	"material", "materials/ui/ui_1080p_menu_cinematics_atlas",
	"material", "materials/ui/ui_1080p_menu_atlas_textures",
	"material", "materials/ui/ui_1080p_menu_single_textures",
	
	"material", "materials/ui/ui_1080p_popup",
	"material",	"materials/ui/ui_1080p_achievement_atlas_textures",
	"material", "materials/ui/ui_1080p_splash_screen",
	"material", "materials/ui/ui_1080p_inn_single_textures",
	"material", "materials/ui/ui_1080p_lock_test",
	"material", "materials/ui/ui_1080p_pose_cosmetics",
	"material", "materials/ui/ui_1080p_store_menu",
	"material", "materials/ui/esrb_console_logo",
	--"material", "materials/ui/unit_portrait_frame",

	-- Tutorial
	--"material", "materials/ui/ui_1080p_tutorial_textures" -- Crashes

	-- Chaos Wastes
	"material", "materials/ui/ui_1080p_morris_single_textures",
	"material", "materials/ui/ui_1080p_belakor_atlas",

	-- Versus
	"material",	"materials/ui/ui_1080p_versus_available_common",
	"material", "materials/ui/ui_1080p_versus_rewards_atlas",
	"material",	"materials/ui/ui_1080p_carousel_atlas",

	-- Loading Screens
	"material", "materials/ui/loading_screens/loading_screen_default",
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_arena_ruin",
	--"material", "materials/ui/loading_screens/loading_screen_carousel", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_15", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_24", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_26", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_17", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_dwarf_2", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_town", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_7", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_gorge", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_21", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_2", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_tower", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_25", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_arena_citadel", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_3", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_dwarf_1", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_14", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_verminous_1", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_dwarf_3", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_mountain", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_crag", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_snare", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_27", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_16", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_4", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_13", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_30", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_19", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_12", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_verminous_2", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_9", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_22", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_1", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_31", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_citadel", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_dwarf_4", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_verminous_3", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_arena_ice", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_8", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_6", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_volcano", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_18", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_2", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_bay", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_1", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_11", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_5", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_forest", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_mordrek", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_20", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_10", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_arena_cave", -- Crashes
	--"material", "mmaterials/ui/loading_screens/morris/deus_loading_screen_mines", -- Crashes
	--"material", "materials/ui/loading_screens/loading_screen_23", -- Crashes
	--"material", "materials/ui/loading_screens/morris/deus_loading_screen_arena_belakor", -- Crashes

	-- Fonts
	"material", "materials/fonts/gw_fonts"

	--[[
	"material", "video/tutorial_videos/tutorial_videos",
	"material", "video/area_videos/wizards/area_video_wizards",
	"material", "video/area_videos/bogenhafen/area_video_bogenhafen",
	"material", "video/area_videos/karak_azgaraz/area_video_karak_azgaraz",
	"material", "video/area_videos/penny/area_video_penny",
	"material", "video/area_videos/termite/area_video_termite",
	"material", "video/area_videos/bogenhafen/area_video_bogenhafen",
	"material", "video/area_videos/holly/area_video_holly",
	"material", "video/area_videos/scorpion/area_video_scorpion",
	"material", "video/area_videos/bogenhafen/area_video_bogenhafen",
	"material", "video/area_videos/helmgart/area_video_helmgart",
	"material", "video/career_videos/kruber/es_knight",
	"material", "video/career_videos/kerillian/we_shade",
	"material", "video/career_videos/bardin/dr_slayer",
	"material", "video/career_videos/victor/wh_zealot",
	"material", "video/career_videos/bardin/dr_slayer",
	"material", "video/career_videos/sienna/bw_adept",
	"material", "video/career_videos/bardin/dr_slayer",
	"material", "video/career_videos/bardin/dr_engineer",
	"material", "video/career_videos/victor/wh_captain",
	"material", "video/career_videos/sienna/bw_necromancer",
	"material", "video/career_videos/kerillian/we_waywatcher",
	"material", "video/career_videos/victor/wh_priest",
	"material", "video/career_videos/bardin/dr_ranger",
	"material", "video/career_videos/victor/wh_bountyhunter",
	"material", "video/career_videos/bardin/dr_slayer",
	"material", "video/career_videos/kruber/es_questingknight",
	"material", "video/career_videos/bardin/dr_ironbreaker",
	"material", "video/career_videos/kruber/es_knight",
	"material", "video/career_videos/kerillian/we_thornsister",
	"material", "video/career_videos/kruber/es_huntsman",
	"material", "video/career_videos/kruber/es_mercenary",
	"material", "video/career_videos/kerillian/we_maidenguard",
	"material", "video/career_videos/sienna/bw_scholar",
	"material", "video/career_videos/sienna/bw_unchained",
	"material", "video/career_videos/victor/wh_zealot"
	"material", "video/ui_option" -- not usable it crashes]]
)

mod.get_texture_size = function(name)
	texture_size = UIAtlasHelper.get_atlas_settings_by_texture_name(name).size
end

-- toggle the draw update on and off
mod.display_toggle = function()
	display_icon = not display_icon
	stop_update = not stop_update
end

-- command to toggle the texture on and off
mod:command("texture_test_toggle", mod:localize("texture_test_toggle_command_description"), function()
	mod.display_toggle()
end)

-- set the name of the texture and its size once given in the local variables
mod:command("texture_test_render", mod:localize("texture_test_render_command_description"), function(name)
	mod.get_texture_size(name)
	texture_name = name
	stop_update = false
end)

-- draw update the texture on screen (probably very inefficient)
function mod.update()
	if not display_icon or not UIAtlasHelper.has_texture_by_name(texture_name) or stop_update then
		stop_update = true
		return
	end
	mod.get_texture_size(texture_name)
	UIRenderer.draw_texture(renderer, texture_name, texture_position, texture_size)
end

-- adjust the position and name of the texture whenever the settings get changed
function mod.on_setting_changed()
	texture_position = {
		mod:get("icon_position_x"),
		mod:get("icon_position_y")
	}
	texture_name = mod:get("test_texture_name_setting_id")
	texture_size = mod.get_texture_size(texture_name)
	stop_update = false
end


--[[

	TODO
	- Tooltips dont work for keybind and textfield
	- Autoload other materials when needed or load all in renderer


]]