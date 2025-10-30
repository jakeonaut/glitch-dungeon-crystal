extends Node

var OFFSET_X = 30 # 320
var OFFSET_Y = 30 # 28
var INTERNAL_VIEWPORT_WIDTH = 670
var INTERNAL_VIEWPORT_HEIGHT = 540
var SMALLER_VIEWPORT_WIDTH = 640
var SMALLER_VIEWPORT_HEIGHT = 512

var kirokaze_palette = preload("res://assets/palettes/kirokaze-gameboy-1x.png")

var all_palette = preload("res://assets/palettes/all_palette.png")
var player_base_palette = preload("res://assets/palettes/player_base_palette.png")
var player_red_palette = preload("res://assets/palettes/player_red_palette.png")
var grey_player_palette = preload("res://assets/palettes/grey_player_palette.png")
var yellow_player_palette = preload("res://assets/palettes/yellow_player_palette.png")
var black_player_palette = preload("res://assets/palettes/player_black_palette.png")
var white_player_palette = preload("res://assets/palettes/white_player_palette.png")

var grey_palette = preload("res://assets/palettes/grey_palette.png")
var red_palette = preload("res://assets/palettes/red_palette.png")
var green_palette = preload("res://assets/palettes/green_palette.png")
var black_palette = preload("res://assets/palettes/black_palette.png")
var yellow_palette = preload("res://assets/palettes/yellow_palette.png")
var white_palette = preload("res://assets/palettes/white_palette.png")
var white_palette2d = preload("res://assets/palettes2D/white_palette.png")
var base_palette = preload("res://assets/palettes/base_palette.png")
var base_palette2d = preload("res://assets/palettes2D/base_palette.png")
var base_palette_pink = preload("res://assets/palettes/base_palette_pink.png")
var weird_base_palette = preload("res://assets/palettes/weird_base_palette.png")

var intangible_red_palette = preload("res://assets/palettes/intangible_red_palette.png")
var intangible_green_palette = preload("res://assets/palettes/intangible_green_palette.png")
var intangible_black_palette = preload("res://assets/palettes/intangible_black_palette.png")
var intangible_yellow_palette = preload("res://assets/palettes/intangible_yellow_palette.png")

var red_dungeon_palette = preload("res://assets/palettes/red_dungeon_palette.png")
var green_dungeon_palette = preload("res://assets/palettes/green_dungeon_palette.png")
var black_dungeon_palette = preload("res://assets/palettes/black_dungeon_palette.png")
var yellow_dungeon_palette = preload("res://assets/palettes/yellow_dungeon_palette.png")

var dark_grey_palette = preload("res://assets/palettes/dark_grey_palette.png")
var dark_red_palette = preload("res://assets/palettes/dark_red_palette.png")
var dark_green_palette = preload("res://assets/palettes/dark_green_palette.png")
var dark_black_palette = preload("res://assets/palettes/dark_black_palette.png")
var dark_yellow_palette = preload("res://assets/palettes/dark_yellow_palette.png")
var dark_white_palette = preload("res://assets/palettes/dark_white_palette.png")

var grey_palette_town = preload("res://assets/palettes/grey_town_palette.png")
var green_palette_town = preload("res://assets/palettes/green_palette_town.png")
var black_palette_town = preload("res://assets/palettes/black_palette_town.png")

var black_palette_alien = preload("res://assets/palettes/black_palette_alien.png")

var grey_black_palette = preload("res://assets/palettes/grey_black_palette.png")
var green_black_palette = preload("res://assets/palettes/green_black_palette.png")
var red_black_palette = preload("res://assets/palettes/red_black_palette.png")
var yellow_black_palette = preload("res://assets/palettes/yellow_black_palette.png")

var tidepool_palette = preload("res://assets/palettes/tidepool_palette.png")
var bog_water_palette = preload("res://assets/palettes/bog_water_palette2.png")
var green_tidepool_palette = preload("res://assets/palettes/green_tidepool_palette.png")
var red_tidepool_palette = preload("res://assets/palettes/red_tidepool_palette.png")
var yellow_tidepool_palette = preload("res://assets/palettes/yellow_tidepool_palette.png")
var black_tidepool_palette = preload("res://assets/palettes/black_tidepool_palette.png")

var foggy_forest_palette = preload("res://assets/palettes/foggyforest.png")
var dream_palette = preload("res://assets/palettes/dream-haze-8-1x.png")
var rgb_palette = preload("res://assets/palettes/3bitrgb_palette.png")
var NES_palette = preload("res://assets/palettes/NES_base_palette.png")
var NES_broom_palette = preload("res://assets/palettes/NES_base_broom_palette.png")

onready var lifeUISound = get_node("LifeUISound")
onready var lifeUISound2 = get_node("LifeUISound2")
onready var doorSound = get_node("DoorSound")
onready var glitchedDoorSound = get_node("GlitchedDoorSound")
onready var gustSound = get_node("GustSound")
onready var panSmackSound = get_node("PanSmackSound")
onready var croneStaffSmackSound = get_node("CroneStaffSmackSound")
var DELETE_ME = 2

var fallbackPath = "res://levels/EndlessFantasy/gd1TutorialDungeon/0_1Haven.tscn"


# GlitchForm variables
enum GlitchForm {
    NORMAL,
    FLOOR,
    FEATHER,
    INVISIBLE,
    LADDER,
    WALK_THROUGH_WALLS,
    BUBBLE,
}
enum TilesetType {
    DUNGEON,
    HOUSE,
    FOREST,
    ALIEN,
    DESERT,
    GLITCH_WORLD,
    BEACH,
    POISON_FOREST,
    POISON_HOUSE,
    AUTUMN_FOREST,
    PRIMORDIAL_OOZE,
    TOMB,
    FARM_HOUSE,
}

enum ItemState {
    EMPTY,
    GOT_IT,
    USED_IT,
}
enum KeyItem {
    NORMAL,
    FISH,
    PYRAMID,
    SHROOM,
    CAT,
    CRYSTAL,
    ZONE_CRYSTAL,
    DEMO,
}

enum Inventory {
    GRIMOIRE,
    PET_0,
}

enum NestingDoll {
    BABY,
    MOM,
    GRANDMA,
    MATRIARCH,
}

enum PetFollower {
    NONE,
    CHICKEN,
    THREE_CHICKENS,
    DRAGONFLY,
    MOLE_CRICKET,
    KIZZY,
    CAT_BABUSHKA,
    CAT_JIJI,
    BIG_MOLE_CRICKET,
    FROG,
    GLITCH_SLIME,
    FISHY,
    RED_SNAKE,
}

enum GrandmaOutfit {
    BABUSHKA,           # 0
    NO_HAT,             # 1
    WITCH_HAT,          # 2
    SCARF_EARMUFFS,     # 3
    YUBABA,             # 4
    WASTE_WITCH,        # 5
    SOPHIE,             # 6
    GODDESS_MASK,       # 7
    CRONE_MASK,         # 8
    SEADEVIL_MASK,      # 9
    DOGU_MASK,          # 10
    BABA_YAGA_MASK,     # 11
    CRYSTAL_ELDER_MASK, # 12
    CAT_EARS,           # 13
    MUSHROOM_HAT,       # 14
    COZY_WINTER_SCARF,  # 15
    TURNIP_MERCHANT,    # 16
    GRUB_FACE,          # 17
    GLITCH_FACE,        # 18
    FISHERMAN,          # 19
    SKELETON,           # 20
    FROG_CRONE,         # 21
}

func getOutfitDialogText(outfit):
    match outfit:
        global.GrandmaOutfit.BABUSHKA:
            return tr("UI.Inventory.6")
        global.GrandmaOutfit.NO_HAT:
            return tr("UI.Outfit.0")
        global.GrandmaOutfit.WITCH_HAT:
            return tr("UI.Outfit.1")
        global.GrandmaOutfit.CRYSTAL_ELDER_MASK:
            return tr("UI.Outfit.2")
        global.GrandmaOutfit.GRUB_FACE:
            return tr("UI.Outfit.3")
        global.GrandmaOutfit.GLITCH_FACE:
            return tr("UI.Outfit.4")
        global.GrandmaOutfit.FISHERMAN:
            return tr("UI.Outfit.5")
        global.GrandmaOutfit.SKELETON:
            return tr("UI.Outfit.6")
        global.GrandmaOutfit.FROG_CRONE:
            return tr("UI.Outfit.7")
        global.GrandmaOutfit.CAT_EARS:
            return tr("UI.Outfit.8")
        global.GrandmaOutfit.MUSHROOM_HAT:
            return tr("UI.Outfit.9")
        global.GrandmaOutfit.YUBABA:
            return tr("UI.Outfit.10")
        global.GrandmaOutfit.WASTE_WITCH:
            return tr("UI.Outfit.11")

enum GrandmaBroom {
    NORMAL,                     # 0
    ELDER_CANE,                 # 1
    CRONE_STAFF,                # 2
    BABA_YAGA_CHICKEN_STAFF,    # 3
    BUG_NET,                    # 4
    FRYING_PAN,                 # 5
    PUMPKIN_BAG,                # 6
}

enum GrandmaBag {
    NORMAL,
    PURSE,
}

enum Locale {
    ENGLISH,
    CHINESE_SIMPLIFIED,
    JAPANESE,
    SPANISH,
    PORTUGUESE,
}
var currLocale = Locale.ENGLISH

func getGlitchTypeFromTileName(tile_name):
    if "_red" in tile_name:
        return GlitchForm.FLOOR
    if "_green" in tile_name:
        return GlitchForm.FEATHER
    if "_black" in tile_name:
        return GlitchForm.INVISIBLE
    if "_yellow" in tile_name:
        return GlitchForm.LADDER

func getColorSuffixFromTilesetType(type):
    if type == TilesetType.DUNGEON:
        return ""
    if type == TilesetType.HOUSE or type == TilesetType.POISON_HOUSE:
        return "_red"
    if type == TilesetType.FOREST or type == TilesetType.BEACH or type == TilesetType.POISON_FOREST or type == TilesetType.AUTUMN_FOREST:
        return "_green"
    if type == TilesetType.ALIEN:
        return "_black"
    if type == TilesetType.DESERT:
        return "_yellow"
    if type == TilesetType.GLITCH_WORLD:
        return "_white"
    return ""

var memory = {}
var userSettings = {}

var activeInteractor = null
var activeThrowableObject = null
var activeThrowableObjectPath = null
var activeSavePoint = null

var demo_mode = 0
var display_mode = 0
var dlc_mode = 0

var isEndOfGame = false
var isRespawning = false
var isEnteringRoom = false
var isBrothWarping = false
var angelWarping = false
var justAngelWarped = false
var roomEdgeVector = null
var grannyEnteringRoom = false
var hasJustRespawned = false
var hasJustEnteredRoom = false
var respawnVarTimerHack = 0
var respawnVarTimerHackLimit = 2
var cameraRotation = 0

enum ControllerType {
    KEYBOARD = 1
    GAMEPAD = 2
}
var was_last_pressed_input_type = ControllerType.KEYBOARD
var was_gamepad_connected = false
var pauseMoveInput = false # don't allow player physics or camera input??
var shouldRenderAsCinematic = false
var pauseGame = false
var isPauseMenuOpen = false

var num_cherries_eaten = 0
var num_cherries_gained = 0
var max_cherries = 5
var collectable_key_recently_got = null
var collectable_key_recently_got_timer = 0
var collectable_key_recently_got_time_limit = 40
var malware_infected = false

var time_dilation_multiplier = 1.0

var mini_cube_crystal_pitch_min = 0.5
var mini_cube_crystal_pitch_max = 2.0
var mini_cube_crystal_pitch = mini_cube_crystal_pitch_min
var mini_cube_crystal_pitch_timer = 0
var mini_cube_crystal_pitch_time_limit = 60

var set_camera_position_on_respawn = false

var hasLevelGeodeBeenSmacked = false
var hasGottenLevelGeode = false

var isAMoleDigging = false

var isOnMainMenu = false
var mainMenuPromptIndex = 0
var NUM_GEMS_FOR_BROOMERANG = 25
var NUM_GEMS_FOR_ENCHANTED_BAG = 75
var NUM_GEMS_FOR_DOUBLE_JUMP = 75
var NUM_GEMS_FOR_BROOMERANG_WARP = 99

var has_started_game = false
var has_really_started_game = false
var okay_really_really_started_game = false
var has_ever_seen_intro = false
var another_start_game_variable = false
var spellCastPauseIndex = null
var correct_ritual = ["ui_down", "ui_down", "ui_down", "restart_key"]
var has_been_baba_yaga_cursed = false
var has_revealed_an_angler_fish = false

func _ready():
    set_process(true)

    # somehow this gets rid of warnings LOL
    if isOnMainMenu: pass
    if has_started_game: pass
    if has_really_started_game: pass
    if okay_really_really_started_game: pass
    if memory: pass
    if activeInteractor: pass
    if activeThrowableObject: pass
    if activeThrowableObjectPath: pass
    if activeSavePoint: pass
    if isRespawning: pass
    if isEnteringRoom: pass
    if grannyEnteringRoom: pass
    if cameraRotation: pass
    if pauseMoveInput: pass
    if pauseGame: pass
    if num_cherries_eaten > 0: pass
    if set_camera_position_on_respawn: pass
    if hasGottenLevelGeode: pass
    if spellCastPauseIndex: pass
    if angelWarping: if justAngelWarped: pass
    if has_been_baba_yaga_cursed: pass
    if malware_infected: pass
    if self.isGamepadConnected():
        was_last_pressed_input_type = ControllerType.GAMEPAD
        was_gamepad_connected = true

    resetMemory()
    resetUserSettings()
    loadUserSettings()
    OS.window_fullscreen = userSettings["fullscreen"]
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if OS.window_fullscreen else Input.MOUSE_MODE_VISIBLE)
    changeLocale(userSettings["locale"], false)
    global.initializeControlsConfig()
    global.hasInitializedControlsConfig = true

var MAX_CRYSTALS_FOR_TOWER = 4
func resetMemory():
    memory = {}

    memory["debug"] = false
    # customization upgrades
    memory["currPet"] = PetFollower.NONE
    memory["currOutfit"] = GrandmaOutfit.BABUSHKA
    memory["currBroom"] = GrandmaBroom.NORMAL
    memory["currBag"] = GrandmaBag.NORMAL

    memory["hearts_enabled"] = true
    memory["mushroom_soul_enabled"] = true
    memory["mole_cricket_enabled"] = true
    memory["zora_flippers_enabled"] = true
    memory["broomerang_enabled"] = true
    memory["pegasus_shoes_enabled"] = true

    # game stuff
    memory["hasEverTouchedObelisk"] = false
    memory["currLevelZone"] = null
    memory["initialized_from_debug"] = false
    memory["tutorial_gem"] = 0
    memory["hammer"] = 0
    memory["broom"] = true
    memory["has_gotten_broom"] = 0
    memory["nesting_doll"] = NestingDoll.GRANDMA
    memory["transformation"] = 0 # Player.TransformationState.NORMAL
    
    memory["crone"] = 0
    memory["hearts_recovering"] = false
    memory["max_mp"] = 0
    memory["mp"] = memory["max_mp"]
    memory["level_zonez"] = []

    # ==============================================
    memory["hard_mode"] = 0
    # if you've beaten the final boss
    memory["clean_crystals"] = 0
    memory["priestess"] = 0
    memory["has_beat_the_game"] = 0
    memory["glitch_world"] = 0
    memory["glitched_grimoire"] = false
    memory["forget_me_not"] = false
    memory["glitched_grimoire2"] = false
    
    memory["mimic_heart"] = 0
    # crystal elder bosses
    memory["angler_seaman_boss"] = 0
    memory["angler_heart"] = 0
    memory["dogu_matryoshka_boss"] = 0
    memory["claydol_heart"] = 0
    memory["baba_yaga_boss"] = 0
    memory["baba_heart"] = 0
    # and associated shortcuts
    memory["anglerShortcut"] = 0
    memory["claydolShortcut"] = 0
    memory["babaShortcut"] = 0
    memory["priestessShortcut"] = 0
    # STORY OR LEVEL STATE
    memory["babushka_cat_story_hook"] = 0
    memory["fishing_rod_shortcut"] = 0

    # POWERUPS
    # memory["spellbookPage"] = [] # we check if the key exists to see if we have it... -_-
    memory["has_eggs_marked"] = false
    memory["can_force_respawn"] = 0
    memory["has_map_item"] = false
    memory["broomerang"] = 0
    memory["babushka_cat_sprint"] = 0
    memory["broom_double_jump"] = 0
    memory["zora_flippers"] = 0
    memory["pegasus_shoes"] = 0
    memory["fishingRod"] = false
    memory["mole_cricket"] = 0
    memory["flowerPot"] = false
    memory["mushroom_soul"] = 0
    memory["mushroom_soul_ver"] = 0
    memory["cutePet"] = false
    memory["glitched_broom"] = false
    memory["max_hp"] = 1
    memory["hp"] = memory["max_hp"]
    memory["angel_flute"] = false
    memory["can_freely_teleport"] = 0
    memory["has_marked_bosses_on_map"] = false
    memory["has_teleported"] = false
    # ==============================================

    # DEFUNCT POWERUPS
    memory["multi_broom"] = false
    memory["debug_broom"] = 0 # this didn't turn out that fun
    memory["magic_lantern"] = 0 # 1 # aka chesire's blessing
    memory["can_nest"] = 0
    memory["mario_nesting_doll"] = false
    memory["broom_flight"] = false
    memory["goddess_dream3"] = false

    # PERMANENT SPELLS
    memory["permanent_spells"] = [
        false, # "NORMAL", sort of a no-op for permanentSpells
        false, # "FLOOR", 
        false, # "FEATHER",
        false, # "INVISIBLE", 
        false, # "LADDER", 
        false, # "WALK_THROUGH_WALLS"
    ]

    # GAME MODES
    memory["random_entrances"] = 0

    # EASTER EGGS
    memory["anna_mode"] = false
    memory["blue_mode"] = false

func newGamePlusMemoryReset():
    memory["clean_crystals"] = 0
    memory["angler_seaman_boss"] = 0
    memory["dogu_matryoshka_boss"] = 0
    memory["baba_yaga_boss"] = 0
    # and associated shortcuts
    memory["anglerShortcut"] = 0
    memory["claydolShortcut"] = 0
    memory["babaShortcut"] = 0
    memory["priestessShortcut"] = 0
    memory["priestess"] = 0
    memory["has_beat_the_game"] = 0
    memory["glitch_world"] = 0
    memory["babushka_cat_story_hook"] = 0
    memory["fishing_rod_shortcut"] = 0
    memory["broom"] = 1
    memory.erase("savePoint")
    memory.erase("savedRoomPath")
    memory.erase("roomPath")
    memory.erase("active_save_point_x")
    memory.erase("active_save_point_y")
    memory.erase("active_save_point_z")
    if memory.has("spellbookPage"):
        memory["spellbookPage"] = []
    memory["level_zonez"] = []
    for levelZone in LEVEL_ZONES:
        if memory.has(levelZone):
            memory.erase(levelZone)
    
var LEVEL_ZONES = [
    "gd1", 
    "gd1TutorialDungeon", 
    "gd1FishingVillage", 
    "gd1ToxicJungle", 
    "gd1ShiftingSandLand", 
    "gd1CrystalTower",
    "gd1BubblegloopSwamp",
    "gd1TombSouls",
    "gd1AbstractSuburbs",
    "gd1GrandmaVillage",
    "gd1PrimordialOoze",
    "gd1DreamMemories"
]

func getNumGrannyHearts(label = false):
    if not label and not global.memory["hearts_enabled"]:
        return 0
    return global.memory["angler_heart"] + global.memory["baba_heart"] + global.memory["claydol_heart"] + global.memory["mimic_heart"]

var broomSheet = preload("res://assets/player_sheet_broom.png")
var broomSheetAni = preload("res://assets/sprites/broom_ani.png")
var fryingPanSheet = preload("res://assets/player_sheet_frying_pan.png")
var fryingPanSheetAni = preload("res://assets/sprites/frying_pan_ani.png")
var croneStaffSheet = preload("res://assets/outfits/player_sheet_staff.png")
var croneStaffSheetAni = preload("res://assets/outfits/staff_ani.png")
var pumpkinBagSheet = preload("res://assets/outfits/player_sheet_pumpkin.png")
func updateBroomSpriteTexture(sprite, useAniSheet):
  if global.memory["currBroom"] == global.GrandmaBroom.NORMAL:
    if useAniSheet:
        sprite.material_override.set_shader_param("texture_albedo", broomSheetAni)
    else:
        sprite.material_override.set_shader_param("texture_albedo", broomSheet)
  if global.memory["currBroom"] == global.GrandmaBroom.FRYING_PAN:
    if useAniSheet:
        sprite.material_override.set_shader_param("texture_albedo", fryingPanSheetAni)
    else:
        sprite.material_override.set_shader_param("texture_albedo", fryingPanSheet)
  if global.memory["currBroom"] == global.GrandmaBroom.CRONE_STAFF:
    if useAniSheet:
        sprite.material_override.set_shader_param("texture_albedo", croneStaffSheetAni)
    else:
        sprite.material_override.set_shader_param("texture_albedo", croneStaffSheet)
  if global.memory["currBroom"] == global.GrandmaBroom.PUMPKIN_BAG:
    if useAniSheet:
        sprite.material_override.set_shader_param("texture_albedo", broomSheetAni)
    else:
        sprite.material_override.set_shader_param("texture_albedo", pumpkinBagSheet)

func isDlcEnabled():
    return dlc_mode > 0 and allLocales[userSettings["locale"]]["dlc_enabled"]

var allLocales = {
    "en": { "code": "en", "supported": true, "label": "English", "dlc_enabled": true },
    "zh_CN": { "code": "zh_CN", "supported": true, "label": "简体字", "dlc_enabled": false }, 
    "ru": { "code": "ru", "supported": true, "label": "Pусский", "dlc_enabled": false },
    "pt_BR": { "code": "pt_BR", "supported": true, "label": "Português", "dlc_enabled": false },
    "fr": { "code": "fr", "supported": true, "label": "Français", "dlc_enabled": false },
    "ja": { "code": "ja", "supported": true, "label": "日本語", "dlc_enabled": false },
    "es": { "code": "es", "supported": true, "label": "Español", "dlc_enabled": false },
    "it": { "code": "it", "supported": true, "label": "Italiano", "dlc_enabled": false },
    "pl": { "code": "pl", "supported": true, "label": "Polski", "dlc_enabled": false },
    "de": { "code": "de", "supported": true, "label": "Deutsch", "dlc_enabled": false },
    "ko_KR": { "code": "ko_KR", "supported": true, "label": "한국어", "dlc_enabled": false },
    "uk_UA": { "code": "uk_UA", "supported": true, "label": "Українська", "dlc_enabled": false },
    "tr_TR": { "code": "tr_TR", "supported": true, "label": "Türkçe", "dlc_enabled": false }
}
func getSupportedLocalesArray():
    var supportedLocales = []
    for localeKey in allLocales:
        if not allLocales[localeKey].supported: continue
        supportedLocales.append(allLocales[localeKey])
    return supportedLocales

func normalizeLocaleHelper(locale):
    if locale == "zh":
        return "zh_CN"
    if locale == "pt":
        return "pt_BR"
    if "de_" in locale:
        return "de"
    if "it_" in locale:
        return "it"
    if "es_" in locale:
        return "es"
    if "pl_" in locale:
        return "pl"
    if "ja_" in locale:
        return "ja"
    if "fr_" in locale:
        return "fr"
    if "ru_" in locale:
        return "ru"
    if locale == "ko":
        return "ko_KR"
    if locale == "uk":
        return "uk_UA"
func normalizeLocale(locale):
    var normalizedLocale = normalizeLocaleHelper(locale)
    if not normalizedLocale in allLocales or not allLocales[normalizedLocale].supported:
        return "en"
    return normalizedLocale
    

# don't call this except for on game initialize (not game load), and only immediately preceeding
# trying to load user settings from file...
func resetUserSettings():
    userSettings = {}

    # across multiple save files game stuff
    userSettings["allMyOutfits"] = [GrandmaOutfit.BABUSHKA]
    userSettings["allMyBrooms"] = [GrandmaBroom.NORMAL]
    userSettings["allMyPets"] = [PetFollower.NONE]
    userSettings["allMyBags"] = [GrandmaBag.NORMAL]
    userSettings["hasEverBeatenGame"] = false

    # settings?
    userSettings["use_joystick"] = 1
    userSettings["deadzone_real"] = 50 # out of 100. can't figure out floats...
    userSettings["show_crt_effect"] = true
    userSettings["show_palette_swap_color_blind_filter"] = false
    userSettings["canGlitchScreen"] = true
    userSettings["colorblindMode"] = true
    userSettings["stopAllMusic"] = false
    userSettings["canChangeSongPitch"] = true
    userSettings["stopAllSfx"] = false
    userSettings["spellAssist"] = false
    userSettings["glyphType"] = GlyphType.XBOX
    userSettings["locale"] = normalizeLocale(OS.get_locale_language())
    userSettings["doorDir"] = -1
    userSettings["fullscreen"] = true
    userSettings["gles3"] = true

func getDeadzone():
    return float(float(userSettings["deadzone_real"]) / 100.0)

func changeLocale(locale, saveSettings = true):
    TranslationServer.set_locale(locale)
    if saveSettings:
        userSettings["locale"] = locale
        saveUserSettings()

var anna_mode_counter = 0
var anna_key_helper = false
func processEasterEggs():
    pass
    # if Input.is_physical_key_pressed(KEY_A):
    #     if anna_mode_counter == 0:
    #         anna_key_helper = true
    #         anna_mode_counter += 1
    #     elif anna_mode_counter == 3:
    #         if not memory.has("anna_mode"):
    #             memory["anna_mode"] = true
    #         else:
    #             memory["anna_mode"] = not memory["anna_mode"]
    #         print("ANNA_MODE = " + str(memory["anna_mode"]))
    #         anna_key_helper = true
    #         anna_mode_counter = 0
    #     elif not anna_key_helper:
    #         anna_mode_counter = 0
    # elif Input.is_physical_key_pressed(KEY_N):
    #     if (anna_mode_counter == 1 or anna_mode_counter == 2) and not anna_key_helper:
    #         anna_key_helper = true
    #         anna_mode_counter += 1
    #     elif not anna_key_helper:
    #         anna_mode_counter = 0
    # elif Input.is_physical_key_pressed(KEY_B):
    #     if not anna_key_helper:
    #         anna_mode_counter = 0
    #         anna_key_helper = true
    #         if not memory.has("blue_mode"):
    #             memory["blue_mode"] = true
    #         else:
    #             memory["blue_mode"] = not memory["blue_mode"]
    # else:
    #     anna_key_helper = false

var num_horizontal_input_presses = 0
func prepareForTransition(level, enteredDoor = null):
    global.activeInteractor = null
    global.pauseGame = true
    global.isEnteringRoom = true
    global.hasJustEnteredRoom = false
    global.respawnVarTimerHack = 0
    global.memory["on_ground"] = true

    if enteredDoor != null:
        var doors = level.get_tree().get_nodes_in_group("doors")
        for door in doors:
            global.eraseStaticLevelZoneLevelVar(level, door)
        global.setStaticLevelZoneLevelVar(level, enteredDoor, enteredDoor.DoorMemory.LAST_ENTERED)

    if not "IntroVideo" in level.getLevelName() and not "LoadingScreen" in level.getLevelName():
        global.memory["transformation"] = level.player.transformation
        global.memory["roomPath"] = level.getLevelName(true)
        global.memory["cameraSize"] = level.gameCamera.initial_size
        # global.memory["lastDoor"] = id
        # a little hack. 0*0 = 0, 1*1 = 1, but 2*2 > 2!!!!!!!
        global.num_horizontal_input_presses = level.player.num_horizontal_input_presses*level.player.num_horizontal_input_presses
    return


func _process(delta):
    delta = delta * time_dilation_multiplier

    if global.userSettings["stopAllSfx"]:
        AudioServer.set_bus_volume_db(2, -80.0)
    else:
        AudioServer.set_bus_volume_db(2, 0.0)
    processEasterEggs()

    if mini_cube_crystal_pitch >= mini_cube_crystal_pitch_max:
        mini_cube_crystal_pitch = mini_cube_crystal_pitch_min

    if mini_cube_crystal_pitch != mini_cube_crystal_pitch_min:
        mini_cube_crystal_pitch_timer += (delta*22)
        if mini_cube_crystal_pitch_timer >= mini_cube_crystal_pitch_time_limit:
            mini_cube_crystal_pitch_timer = 0
            mini_cube_crystal_pitch = mini_cube_crystal_pitch_min

    if hasJustEnteredRoom:
        respawnVarTimerHack += (delta*22)
        if respawnVarTimerHack >= respawnVarTimerHackLimit:
            respawnVarTimerHack = 0
            hasJustEnteredRoom = false
            isEnteringRoom = false

func tryGiveMemoryAchievement():
  if global.memory["zora_flippers"] > 0 and global.memory["mole_cricket"] > 0 and global.memory["mushroom_soul"] > 0:
    if global.demo_mode <= 0: Steam.set_achievement("MEMORIES")

var SACRED_LEVEL_NAME = "res://levels/EndlessFantasy"
var MINI_SACRED_LEVEL_NAME = "EndlessFantasy"
func getShortLevelName(longLevelName):
    assert("res://levels/" in longLevelName)

    if SACRED_LEVEL_NAME in longLevelName:
        return longLevelName.split(SACRED_LEVEL_NAME)[1]
    return longLevelName.split("res://")[1]

func getLevelZoneName(longLevelName):
    if not SACRED_LEVEL_NAME in longLevelName:
        return "levels"

    var shortLevelName = getShortLevelName(longLevelName)
    var segments = shortLevelName.split("/")
    if segments.size() <= 1:
        return null
    return segments[segments.size() - 2]

func getDisplayTitle(levelZoneName, gd1TutorialName = "???"):
    match levelZoneName:
        "gd1":
            return "???" # basically "null"
        "gd1TutorialDungeon":
            return gd1TutorialName if not global.memory["can_freely_teleport"] else tr("LevelName.0")
        "gd1FishingVillage":
            return tr("LevelName.2")
        "gd1ToxicJungle":
            return tr("LevelName.3")
        "gd1ShiftingSandLand":
            return tr("LevelName.4") # could amp up the insect-ness more
        "gd1CrystalTower":
            return tr("LevelName.5")
        "gd1BubblegloopSwamp":
            return "sea of corruption" # malware swamp
        "gd1TombSouls":
            return "forgotten crypt"
        "gd1AbstractSuburbs":
            return "yaga village"
        "gd1GrandmaVillage":
            return tr("Question.Mark")
        "gd1PrimordialOoze":
            return tr("LevelName.6")
        "gd1DreamMemories":
            return tr("LevelName.7")
        _:
            return "???"
    


func normalizeMemoryPosition(positionVariable):
    if typeof(positionVariable) == TYPE_VECTOR3:
        return positionVariable
    if typeof(positionVariable) == TYPE_VECTOR2:
        return Vector3(positionVariable.x, positionVariable.y, 0)
    if typeof(positionVariable) == TYPE_STRING:
        var positionVariableArray = positionVariable.replace("(", "").replace(")", "").split(",")
        if positionVariableArray.size() == 2:
            return Vector3(positionVariableArray[0], positionVariableArray[1], 0)
        elif positionVariableArray.size() == 3:
            return Vector3(positionVariableArray[0], positionVariableArray[1], positionVariableArray[2])
    return Vector3(0, 0, 0)


var save_game_files = [
    "user://savegame.save",
    "user://savegame2.save",
    "user://savegame3.save",
    "user://savegame4.save",
]
var user_settings_files = [
    "user://usersettings.config"
]
var save_game_index = 0
func saveGame(level, overwrite_save_game_index = -1):
    if "EndCredits" in level.getShortLevelName() or "IntroVideo" in level.getShortLevelName() or "PrimordialOoze" in level.getShortLevelName():
        return

    var temp_save_game_index = save_game_index if overwrite_save_game_index < 0 else overwrite_save_game_index
    var save_game_file = save_game_files[temp_save_game_index]
    var file = File.new()
    file.open(save_game_file, File.WRITE)
    file.store_line(to_json(global.memory))
    file.close()

func doesSaveGameExist(saveGameIndex):
    # do not set!!!
    # save_game_index = saveGameIndex
    var save_game_file = save_game_files[saveGameIndex]
    var file = File.new()
    return file.file_exists(save_game_file)

func doesAnySaveGameExist():
    var file = File.new()
    for i in range(save_game_files.size()):
        var save_game_file = save_game_files[i]
        if file.file_exists(save_game_file):
            return true
    return false

func toggleGlyphType():
    if userSettings.has("glyphType"):
        if userSettings["glyphType"] == GlyphType.XBOX:
            userSettings["glyphType"] = GlyphType.PLAYSTATION
            return
        if userSettings["glyphType"] == GlyphType.PLAYSTATION:
            userSettings["glyphType"] = GlyphType.NINTENDO
            return
        if userSettings["glyphType"] == GlyphType.NINTENDO:
            userSettings["glyphType"] = GlyphType.XBOX
            return
    userSettings["glyphType"] = GlyphType.XBOX

func saveUserSettings():
    var user_settings_file = user_settings_files[0]
    var file = File.new()
    file.open(user_settings_file, File.WRITE)
    file.store_line(to_json(global.userSettings))
    file.close()

func loadUserSettings():
    var user_settings_file = user_settings_files[0]
    var file = File.new()
    if not file.file_exists(user_settings_file):
        return false # Error! We don't have a save to load.
    
    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    file.open(user_settings_file, File.READ)

    var user_settings_contents = file.get_line()
    global.userSettings.merge(parseJsonPreserveInt(user_settings_contents), true)
    while not file.eof_reached():
        # ... ??? Is this because global.memory is stored on a single line? enigmatic..
        var _current_line = parseJsonPreserveInt(file.get_line())
    normalizeLoadedUserSettings()
        
    file.close()
    return true

var MAX_ANGEL_EGGS = 28
func loadGame(saveGameIndex, temp_memory_override = null):
    if saveGameIndex < 0 or saveGameIndex >= save_game_files.size():
        return {} # Error! out of bounds
    save_game_index = saveGameIndex
    var save_game_file = save_game_files[save_game_index]
    var file = File.new()
    if not file.file_exists(save_game_file):
        return {} # Error! We don't have a save to load.
    
    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    file.open(save_game_file, File.READ)
    
    var memoryToLoadInto = temp_memory_override if temp_memory_override != null else global.memory

    var save_game_contents = file.get_line()
    memoryToLoadInto.merge(parseJsonPreserveInt(save_game_contents), true)
    while not file.eof_reached():
        # ... ??? Is this because global.memory is stored on a single line? enigmatic..
        var _current_line = parseJsonPreserveInt(file.get_line())
    normalizeLoadedMemory(memoryToLoadInto)
        
    file.close()

    if temp_memory_override == null:
        if memoryToLoadInto.has("roomPath"):
            currLevelZone = getLevelZoneName(memoryToLoadInto["roomPath"])
            if not memoryToLoadInto["level_zonez"].has(currLevelZone):
                memoryToLoadInto["level_zonez"].push_back(currLevelZone)

        # do some achievement backloading
        if global.demo_mode <= 0 and memoryToLoadInto == global.memory:
            if memoryToLoadInto["priestess"] >= 2:
                Steam.set_achievement("PRIESTESS_BOSS")
            if memoryToLoadInto["baba_yaga_boss"] >= 2:
                Steam.set_achievement("BABA_BOSS")
            if memoryToLoadInto["dogu_matryoshka_boss"] >= 2:
                Steam.set_achievement("CLAYDOL_BOSS")
            if memoryToLoadInto["angler_seaman_boss"] >= 2:
                Steam.set_achievement("ANGLER_BOSS")
            if memoryToLoadInto["broomerang"] >= 1:
                Steam.set_achievement("BROOMERANG")
            var numAngelEggs = global.getThingFromAllLevelZonez("angelEgg")
            if numAngelEggs >= 1:
                Steam.set_achievement("ANGEL_EGG_FIRST")
            if numAngelEggs >= global.MAX_ANGEL_EGGS:
                Steam.set_achievement("ANGEL_EGG_ALL")
            elif numAngelEggs > 0:
                Steam.user_stats.indicate_achievement_progress("ANGEL_EGG_ALL", numAngelEggs, global.MAX_ANGEL_EGGS)

    # reset boss flags from 1 to 0 if we are loading, so we can start the opening cinematic again for all of them.
    # if the boss flag is 2 already, it means you've beat them, so don't reset
    if memoryToLoadInto["priestess"] == 1:
        memoryToLoadInto["priestess"] = 0
    if memoryToLoadInto["baba_yaga_boss"] == 1:        
        memoryToLoadInto["baba_yaga_boss"] = 0
    if memoryToLoadInto["angler_seaman_boss"] == 1:
        memoryToLoadInto["angler_seaman_boss"] = 0
    if memoryToLoadInto["dogu_matryoshka_boss"] == 1:
        memoryToLoadInto["dogu_matryoshka_boss"] = 0
    return memoryToLoadInto

func tryDeleteGame(saveGameIndex):
    if saveGameIndex < 0 or saveGameIndex >= save_game_files.size():
        return
    var save_game_file = save_game_files[saveGameIndex]
    var file = File.new()
    if not file.file_exists(save_game_file):
        return false # Error! We don't have a save to load.
    var dir = Directory.new()
    dir.remove(save_game_file)

func turnRealIntoIntRecursive(obj):
    if typeof(obj) == TYPE_STRING:
        # well, this will fail for "0", but hopefully we don't use that for a key anywhere.
        # luckily, "key_items", which this clause is a fix for, explicitly disallows 0 as a key
        # since 0 is reserved for "NORMAL" key_type
        if "(" in obj:
            return normalizeMemoryPosition(obj)
        elif int(obj) != 0 and len(obj) == len(str(int(obj))): # don't convert "gd1", but convert 
            # print(obj + " ;; " + str(int(obj)))
            return int(obj)
        return obj
    elif typeof(obj) == TYPE_REAL:
        return int(obj)
    elif typeof(obj) == TYPE_ARRAY:
        var new_arr = []
        for i in range(obj.size()):
            new_arr.push_back(turnRealIntoIntRecursive(obj[i]))
        return new_arr
    elif typeof(obj) == TYPE_DICTIONARY:
        var new_dict = {}
        for key in obj:
            new_dict[turnRealIntoIntRecursive(key)] = turnRealIntoIntRecursive(obj[key])
        return new_dict
    else:
        return obj

func parseJsonPreserveInt(json_str):
    var jsonResult = JSON.parse(json_str)
    if jsonResult.error == OK:
        return turnRealIntoIntRecursive(parse_json(json_str))
    print(json_str)
    return {}
    

var is_reading_input = false
var last_read_input = null
var last_read_joystick_input = null
var is_reading_keyboard_input = false
var is_reading_controller_input = false
var GLOBAL_DEADZONE = 0.5
func _input(ev):
    if not is_reading_input:
        return

    if is_reading_keyboard_input and ev is InputEventKey and ev.pressed:
        last_read_input = ev.scancode
    if is_reading_controller_input: 
        if ev is InputEventJoypadButton and ev.pressed:
            last_read_input = ev.button_index
        # why ev.axis < 4 ? so we don't count left / right analog trigger...
        elif ev is InputEventJoypadMotion and ev.axis < 4 and \
           (ev.axis_value > GLOBAL_DEADZONE or ev.axis_value < -GLOBAL_DEADZONE):
            last_read_joystick_input = [ev.axis, 1 if ev.axis_value > 0 else -1]

func getButtonIndexFromJoystick(joystickInput):
    var axis = joystickInput[0]
    var axis_value = joystickInput[1]
    if axis == JOY_AXIS_0 or axis == JOY_AXIS_2:
        if axis_value < 0:
            return JOY_DPAD_LEFT
        if axis_value > 0:
            return JOY_DPAD_RIGHT
    if axis == JOY_AXIS_1 or axis == JOY_AXIS_3:
        if axis_value < 0:
            return JOY_DPAD_UP
        if axis_value > 0:
            return JOY_DPAD_DOWN
    return null

func getJoystickAxisStr(axis, axis_value, useSpecialChar = true):
    if axis == JOY_AXIS_0:
        if axis_value < 0:
            return "a" if useSpecialChar else "Lstick Left"
        if axis_value > 0:
            return "d" if useSpecialChar else "Lstick Right"
    elif axis == JOY_AXIS_1:
        if axis_value < 0:
            return "w" if useSpecialChar else "Lstick Up"
        if axis_value > 0:
            return "x" if useSpecialChar else "Lstick Down"
    elif axis == JOY_AXIS_2:
        if axis_value < 0:
            return "f" if useSpecialChar else "Rstick Left"
        if axis_value > 0:
            return "h" if useSpecialChar else "Rstick Right"
    elif axis == JOY_AXIS_3:
        if axis_value < 0:
            return "t" if useSpecialChar else "Rstick Up"
        if axis_value > 0:
            return "b" if useSpecialChar else "Rstick Down"

    # taken from getButtonIndexStr below...
    elif axis == JOY_ANALOG_L2:
        return "O" if useSpecialChar else "L2"
    elif axis == JOY_ANALOG_R2:
        return "P" if useSpecialChar else "R2"

enum GlyphType {
    XBOX,
    NINTENDO,
    PLAYSTATION,
}
func getButtonIndexStr(button_index, glyph_type = GlyphType.NINTENDO, useSpecialChar = true):
    match button_index:
        JOY_XBOX_A:
            if glyph_type == GlyphType.XBOX:
                return "A"
            if glyph_type == GlyphType.NINTENDO:
                return "B"
            if glyph_type == GlyphType.PLAYSTATION:
                return "X"
        JOY_XBOX_B:
            if glyph_type == GlyphType.XBOX:
                return "B"
            if glyph_type == GlyphType.NINTENDO:
                return "A"
            if glyph_type == GlyphType.PLAYSTATION:
                return "C" if useSpecialChar else "Circle"
        JOY_XBOX_Y:
            if glyph_type == GlyphType.XBOX:
                return "Y"
            if glyph_type == GlyphType.NINTENDO:
                return "X"
            if glyph_type == GlyphType.PLAYSTATION:
                return "T" if useSpecialChar else "Triangle"
        JOY_XBOX_X:
            if glyph_type == GlyphType.XBOX:
                return "X"
            if glyph_type == GlyphType.NINTENDO:
                return "Y"
            if glyph_type == GlyphType.PLAYSTATION:
                return "N" if useSpecialChar else "Square"
        JOY_START:
            return "Start"
        JOY_SELECT:
            return "Select"
        JOY_DPAD_UP:
            return "^" if useSpecialChar else "Dpad Up"
        JOY_DPAD_DOWN:
            return "V" if useSpecialChar else "Dpad Down"
        JOY_DPAD_LEFT:
            return "<" if useSpecialChar else "Dpad Left"
        JOY_DPAD_RIGHT:
            return ">" if useSpecialChar else "Dpad Right"
        JOY_L:
            return "Q" if useSpecialChar else "L1"
        JOY_L2:
            return "O" if useSpecialChar else "L2"
        JOY_L3:
            return "[" if useSpecialChar else "L3"
        JOY_R:
            return "W" if useSpecialChar else "R1"
        JOY_R2:
            return "P" if useSpecialChar else "R2"
        JOY_R3:
            return "]" if useSpecialChar else "R3"
        _:
            return "?"

func getKeyCodeStr(keycode, useSpecialChar = true):
    var keycode_str = OS.get_scancode_string(keycode)
    match keycode_str:
        "Enter":
            return "E" if useSpecialChar else "Enter"
        "Control":
            return "C" if useSpecialChar else "Ctrl"
        "CapsLock", "Capslock", "Caps Lock", "Caps lock":
            return "O" if useSpecialChar else "Caps"
        "PageUp":
            return "K" if useSpecialChar else "PgUp"
        "PageDown":
            return "J" if useSpecialChar else "PgDn"
        "Delete":
            return "D" if useSpecialChar else "Del"
        "Space":
            return "Z" if useSpecialChar else "Space"
        "QuoteLeft":
            return "`"
        "Shift":
            return "S" if useSpecialChar else "Shft"
        "Minus":
            return "-"
        "Equal":
            return "="
        "BracketLeft":
            return "["
        "BracketRight":
            return "]"
        "Semicolon":
            return ";"
        "Apostrophe":
            return "'"
        "Comma":
            return ","
        "Period":
            return "."
        "Insert":
            return "I" if useSpecialChar else "Ins"
        "Slash":
            return "/"
        "BackSlash":
            return "\\" # " # idk why VSC needs this to render syntax correctly after the "\\"
        "Down":
            return "F"
        "Left":
            return "V"
        "Right":
            return "Q"
        "Up":
            return "G"
        "Home":
            return "H"
        "Tab":
            return "T"
        "ScrollLock":
            return "L"
        "Escape":
            return "R"
        "Alt":
            return "A"
        "Menu":
            return "M"
        "WinKey":
            return "W"
        "Super":
            return "W"
        "Cmd":
            return "W"
        "PrintScreen":
            return "P"
        "Pause":
            return "U"
        "BackSpace":
            return "B"
        _:
            return keycode_str.to_lower()

var hasInitializedControlsConfig = false
var controlsConfig = []
func resetControlsConfigLabels():
    # good luck! hope this never gets out of sync with global.controlsConfig!
    var controlConfigLabels = [
        { "label_str": tr("UI.InputMenu.Action.1") },
        { "label_str": tr("UI.InputMenu.Action.2") },
        { "label_str": tr("UI.InputMenu.Action.3") },
        { "label_str": tr("UI.InputMenu.Action.3_0") },
        { "label_str": tr("UI.InputMenu.Action.4") },
        { "label_str": tr("UI.InputMenu.Action.5") },
        { "label_str": tr("UI.InputMenu.Action.6") },
        { "label_str": tr("UI.InputMenu.Action.6_0") },
        { "label_str": tr("UI.InputMenu.Action.7") },
        { "label_str": tr("UI.InputMenu.Action.8") },
        { "label_str": tr("UI.InputMenu.Action.9") },
        { "label_str": tr("UI.InputMenu.Action.9_0") % "1" },
        { "label_str": tr("UI.InputMenu.Action.9_0") % "2" },
        { "label_str": tr("UI.InputMenu.Action.9_0") % "3" },
        { "label_str": tr("UI.InputMenu.Action.9_0") % "4" },
        { "label_str": tr("UI.InputMenu.Action.10") },
    ]
    for i in range(len(controlConfigLabels)):
        global.controlsConfig[i]["label_str"] = controlConfigLabels[i]["label_str"]

var JUMP_INDEX = 4
func initializeControlsConfig():
  # good luck! hope this never gets out of sync with controlConfigLabels (above)
  global.controlsConfig = [
    { "input_action": "ui_left" },
    { "input_action": "ui_right" },
    { "input_action": "ui_down" },
    { "input_action": "enter_door" }, # don't delete, idk if it will mess up savedUserSettings -_-
    { "input_action": "ui_up" },
    { "input_action": "jump_button" }, # GLOBAL_JUMP_INDEX = 4
    { "input_action": "sub_action_button" },
    { "input_action": "talk_button" },
    { "input_action": "restart_key" },
    { "input_action": "alt_action_button" },
    { "input_action": "left_button" },
    { "input_action": "spell_1" },
    { "input_action": "spell_2" },
    { "input_action": "spell_3" },
    { "input_action": "spell_4" },
    { "input_action": "open_map" },
  ]
  resetControlsConfigLabels()
  if global.userSettings.has("controls_config"):
    var rememberedControlsConfig = global.userSettings["controls_config"]
    for control_config in global.controlsConfig:
      for remembered_config in rememberedControlsConfig:
        if remembered_config.input_action == control_config.input_action:
          if remembered_config.has("key_code") and remembered_config["key_code"] != null:
            global.setKeyCode(control_config.input_action, remembered_config["key_code"])
            control_config["key_code"] = remembered_config["key_code"]
          if remembered_config.has("button_index") and remembered_config["button_index"] != null:
            global.setButtonIndex(control_config.input_action, remembered_config["button_index"], false)
            control_config["button_index"] = remembered_config["button_index"]
          if remembered_config.has("axis") and remembered_config.has("axis_value") and remembered_config["axis"] != null and remembered_config["axis_value"] != null:
            global.userSettings["use_joystick"] = 1 + remembered_config.axis
            # global.setJoystickAxis(control_config.input_action, remembered_config.axis, remembered_config.axis_value, false, false)
            # control_config["axis"] = remembered_config.axis
            # control_config["axis_value"] = remembered_config.axis_value
      # make sure its set to default if it was erased from memory
      if not control_config.has("key_code") or control_config["key_code"] == null and not control_config.input_action == "enter_door":
        control_config["key_code"] = global.getKeyCode(control_config.input_action)
    # don't wanna reset if user unbinded joystick axis soo... if you mess with the config save file it's on you!!!
    #   if not control_config.has("button_index") or control_config["button_index"] == null:
    #     control_config["button_index"] = global.getButtonIndex(control_config.input_action)
    #   if not control_config.has("axis") or not control_config.has("axis_value"):
    #     var axisVars = global.getJoystickAxis(control_config.input_action)
    #     if axisVars != null:
    #         control_config["axis"] = axisVars[0]
    #         control_config["axis_value"] = axisVars[1]
    #         var axis2Vars = global.getJoystickAxis(control_config.input_action, axisVars[0])
    #         if axis2Vars != null:
    #             control_config["axis2"] = axis2Vars[0]
    #             control_config["axis2_value"] = axis2Vars[1]
  else:
    for control_config in global.controlsConfig:
      control_config["key_code"] = global.getKeyCode(control_config.input_action)
      control_config["button_index"] = global.getButtonIndex(control_config.input_action)
      var axisVars = global.getJoystickAxis(control_config.input_action)
      if axisVars != null:
        control_config["axis"] = axisVars[0]
        control_config["axis_value"] = axisVars[1]
        var axis2Vars = global.getJoystickAxis(control_config.input_action, axisVars[0])
        if axis2Vars != null:
            control_config["axis2"] = axis2Vars[0]
            control_config["axis2_value"] = axis2Vars[1]
    global.userSettings["controls_config"] = global.controlsConfig

func resetKeyBindings():
  var tempControlsConfig = global.userSettings["controls_config"] if global.userSettings.has("controls_config") else {}
  for control_config in tempControlsConfig:
    if control_config.has("key_code"):
        control_config.erase("key_code")
  global.userSettings["controls_config"] = tempControlsConfig
  InputMap.load_from_globals() # reset ALL input_actions to default...
  global.initializeControlsConfig() # will load in the "remembered" ControllerBindings

func resetControllerBindings():
  var tempControlsConfig = global.userSettings["controls_config"] if global.userSettings.has("controls_config") else {}
  for control_config in tempControlsConfig:
    if control_config.has("button_index"):
        control_config.erase("button_index")
    if control_config.has("axis"):
        control_config.erase("axis")
    if control_config.has("axis_value"):
        control_config.erase("axis_value")
  global.userSettings["controls_config"] = tempControlsConfig
  InputMap.load_from_globals() # reset ALL input_actions to default...
  global.initializeControlsConfig() # will load in the "remembered" KeyBindings


func getKeyCode(input_action):
  var inputEvents = InputMap.get_action_list(input_action)
  for inputEvent in inputEvents:
    if inputEvent is InputEventKey:
      return inputEvent.get_scancode()
  return null

func setKeyCode(input_action, key_code):
  var inputEvents = InputMap.get_action_list(input_action)
  for inputEvent in inputEvents:
    if inputEvent is InputEventKey:
      InputMap.action_erase_event(input_action, inputEvent)
  var new_event = InputEventKey.new()
  new_event.set_scancode(key_code)
  InputMap.action_add_event(input_action, new_event)

func getButtonIndex(input_action):
  var inputEvents = InputMap.get_action_list(input_action)
  for inputEvent in inputEvents:
    if inputEvent is InputEventJoypadButton:
      return inputEvent.get_button_index()
  return null

func setButtonIndex(input_action, button_index, erase_joystick = true):
  var inputEvents = InputMap.get_action_list(input_action)
  for inputEvent in inputEvents:
    if inputEvent is InputEventJoypadButton:
      InputMap.action_erase_event(input_action, inputEvent)
    # ENFORCING ONE OR THE OTHER...
    if erase_joystick and inputEvent is InputEventJoypadMotion:
      InputMap.action_erase_event(input_action, inputEvent)
  var new_event = InputEventJoypadButton.new()
  new_event.set_button_index(button_index)
  InputMap.action_add_event(input_action, new_event)

func getJoystickAxis(input_action, axis_to_skip = null):
    var inputEvents = InputMap.get_action_list(input_action)
    for inputEvent in inputEvents:
        if inputEvent is InputEventJoypadMotion:
            var axis = inputEvent.get_axis()
            if axis == axis_to_skip: continue
            return [axis, inputEvent.get_axis_value()]
    return null

func setJoystickAxis(input_action, axis, axis_value, erase_joystick = true, erase_joypad = true):
    if axis_value == 0:
        return

    var inputEvents = InputMap.get_action_list(input_action)
    for inputEvent in inputEvents:
        if erase_joystick and inputEvent is InputEventJoypadMotion:
            InputMap.action_erase_event(input_action, inputEvent)
        # ENFORCING ONE OR THE OTHER...
        if erase_joypad and inputEvent is InputEventJoypadButton:
            InputMap.action_erase_event(input_action, inputEvent)
    var new_event = InputEventJoypadMotion.new()
    new_event.set_axis(axis)
    new_event.set_axis_value(axis_value)
    InputMap.action_add_event(input_action, new_event)

func getEnterDoorDirection():
    var enterDoorActions = InputMap.get_action_list("enter_door")
    for inputEvent in enterDoorActions:
        if inputEvent is InputEventJoypadButton:
            if inputEvent.button_index == JOY_DPAD_DOWN:
                return -1
            if inputEvent.button_index == JOY_DPAD_UP:
                return 1
    if userSettings.has("doorDir"):
        return userSettings["doorDir"]
    return -1

func toggleEnterDoorDirection():
    var dir = getEnterDoorDirection()
    if dir == 1:
        userSettings["doorDir"] = -1
    elif dir == -1:
        userSettings["doorDir"] = 1

func isGamepadConnected():
    return Input.get_connected_joypads().size() > 0

func getLargeInputText(input_action, input_display = 0, use_bbtext = true):
    var should_render_as_controller_input = input_display == 1 or (input_display == 0 and was_last_pressed_input_type == ControllerType.GAMEPAD)

    var inputEvents = InputMap.get_action_list(input_action)
    for inputEvent in inputEvents:
        if should_render_as_controller_input:
            if inputEvent is InputEventJoypadButton:
                if use_bbtext:
                    var buttonIndexStr = getButtonIndexStr(inputEvent.button_index, userSettings["glyphType"])
                    if buttonIndexStr == "Start" or buttonIndexStr == "Select":
                        return buttonIndexStr
                    return "[font=res://DarkInputExtraFont.tres]" + buttonIndexStr + "[/font]"
                else:
                    return getButtonIndexStr(inputEvent.button_index, userSettings["glyphType"], false)
            elif inputEvent is InputEventJoypadMotion:
                if use_bbtext:
                    var joystickAxisStr = getJoystickAxisStr(inputEvent.axis, inputEvent.axis_value)
                    return "[font=res://DarkInputExtraFont.tres]" + joystickAxisStr + "[/font]"
                else:
                    return getJoystickAxisStr(inputEvent.axis, inputEvent.axis_value, false)
            # if inputEvent is InputEventJoypadMotion:
            #     if use_bbtext:
            #         return "[font=res://DarkInputExtraFont.tres]" + getAxisStr(inputEvent.axis, inputEvent.axis_value) + "[/font]"
            #     else:
            #         return getAxisStr(inputEvent.axis, inputEvent.axis_value, false)
        else:
            if inputEvent is InputEventKey:
                if use_bbtext:
                    return "[font=res://DarkInputFont.tres]" + getKeyCodeStr(inputEvent.get_scancode()) + "[/font]"
                else:
                    return getKeyCodeStr(inputEvent.get_scancode(), false)
        
    return null

func getInputText(input_action, input_display = 0, use_bbtext = true, showCondensedMenu = false):
    var should_render_as_controller_input = input_display == 1 or (input_display == 0 and self.was_last_pressed_input_type == ControllerType.GAMEPAD)

    var inputEvents = InputMap.get_action_list(input_action)
    var strToReturn = ""
    for inputEvent in inputEvents:
        if should_render_as_controller_input:
            if inputEvent is InputEventJoypadButton:
                if use_bbtext:
                    var buttonIndexStr = getButtonIndexStr(inputEvent.button_index, userSettings["glyphType"])
                    if buttonIndexStr == "Start" or buttonIndexStr == "Select":
                        strToReturn += buttonIndexStr
                    else:
                        strToReturn += "[font=res://DarkInputExtraFont_small.tres]" + buttonIndexStr + "[/font]"
                else:
                    strToReturn += getButtonIndexStr(inputEvent.button_index, userSettings["glyphType"])
            elif inputEvent is InputEventJoypadMotion:
                if use_bbtext:
                    var joystickAxisStr = getJoystickAxisStr(inputEvent.axis, inputEvent.axis_value)
                    strToReturn += "[font=res://DarkInputExtraFont_small.tres]" + joystickAxisStr + "[/font]"
                else:
                    strToReturn += getJoystickAxisStr(inputEvent.axis, inputEvent.axis_value)
        else:
            if inputEvent is InputEventKey:
                if use_bbtext:
                    if showCondensedMenu:
                        return "[font=res://DarkInputFont_smallCondensed.tres]" + getKeyCodeStr(inputEvent.get_scancode()) + "[/font]"
                    return "[font=res://DarkInputFont_small.tres]" + getKeyCodeStr(inputEvent.get_scancode()) + "[/font]"
                else:
                    return getKeyCodeStr(inputEvent.get_scancode(), false)
    return strToReturn

func normalizeLoadedMemory(memoryToLoadInto):
    if typeof(memoryToLoadInto["nesting_doll"]) == TYPE_BOOL:
        memoryToLoadInto["nesting_doll"] = global.NestingDoll.GRANDMA
    memoryToLoadInto["priestess"] = 0

func normalizeLoadedUserSettings():
    # should eventually normalize so that this is a no-op.
    # but we want to ensure this is populated from the last saved source
    userSettings["doorDir"] = getEnterDoorDirection()
    
func getNextGlitch(glitch_form):
    if glitch_form == global.GlitchForm.NORMAL: return global.GlitchForm.FEATHER
    if glitch_form == global.GlitchForm.FEATHER: return global.GlitchForm.FLOOR
    if glitch_form == global.GlitchForm.FLOOR: return global.GlitchForm.LADDER
    if glitch_form == global.GlitchForm.LADDER: return global.GlitchForm.INVISIBLE
    if glitch_form == global.GlitchForm.INVISIBLE: return global.GlitchForm.WALK_THROUGH_WALLS
    if glitch_form == global.GlitchForm.WALK_THROUGH_WALLS: return global.GlitchForm.NORMAL

func strip_bbcode(source):
  var lb_regex = RegEx.new()
  lb_regex.compile("\\[lb\\]")
  var rb_regex = RegEx.new()
  rb_regex.compile("\\[rb\\]")

  var lb_rb_source = rb_regex.sub(lb_regex.sub(source, "［", true), "］", true)

  var regex = RegEx.new()
  regex.compile("\\[.+?\\]")
  return regex.sub(lb_rb_source, "", true)

# why is this here and not in PlayerInteractionArea/InteractionAreaPassive or GameMover?
# well, we don't want to copy the function three times for the InteractionAreas...
#   (although we should probably have a better method of dealing with that since we already copy some)
# and we don't want it in gameMover because it makes InteractionAreas do more checks to see if they
# are the child of a GameMover....
# anyways this way works even though global is bad :)
func doFallthroughObjectCollision(gameMover, area, debug = false):
    var areaShape = area.get_node("CollisionShape")
    var ax = areaShape.global_transform.origin.x
    var ay = areaShape.global_transform.origin.y
    var arb = areaShape.shape.extents.x
    var alb = -arb
    var atb = areaShape.shape.extents.y
    var abb = -atb

    if not gameMover.should_collide_fallthrough_area:
        return false

    if gameMover.physics_state != gameMover.PhysicsState.NORMAL:
        return false

    var x = gameMover.global_transform.origin.x
    var y = gameMover.global_transform.origin.y
    if (gameMover.pressingDown() and (gameMover.on_ground or (y - gameMover.tb) < (ay + atb))) or \
       (not "was_fallthrough_area_collision_triggered" in gameMover):
        if "was_fallthrough_area_collision_triggered" in gameMover:
            gameMover.was_fallthrough_area_collision_triggered = false
        if gameMover.on_ground and gameMover.pressingDown() and (y - gameMover.tb) >= (ay + atb):
            gameMover.global_transform.origin.y = ay + atb + gameMover.tb + 0.125
        return false

        
    # check for fallThroughSolid collision while falling
    var rb = gameMover.rb
    var lb = gameMover.lb
    var tb = gameMover.tb
    var bb = gameMover.bb

    var lv = gameMover.linear_velocity.y
    var tb_diff = 0
    var bb_diff = -0.12
    if gameMover.grav < 0:
        lv *= -1
        tb_diff = -bb_diff
        bb_diff = 0
        var temp = tb
        tb = bb
        bb = temp

    var truly_on_ground_memory = gameMover.truly_on_ground
    if debug:
        print("lv: " + str(lv))
        print(str(ay) + ", " + str(abb) + ", " + str(atb) + ", :: " + str(y) + ", " + str(bb) + ", " + str(tb))
    if gameMover.isRectColliding(
        ax + alb, ay + atb, ax + arb, ay + abb,
        x + lb, y + bb + tb_diff, x + rb, y + bb + bb_diff, debug
    ) and (lv < 0 or (lv == 0 and gameMover.glitch_form == global.GlitchForm.FLOOR)):
        gameMover.was_fallthrough_area_collision_triggered = true
        gameMover.fallthrough_area_collision_y = ay + atb - bb
        gameMover.linear_velocity = gameMover.collideWithFloor(gameMover.linear_velocity)
        gameMover.truly_on_ground = truly_on_ground_memory
        
        gameMover.lv = gameMover.linear_velocity
        gameMover.global_transform.origin.y = gameMover.fallthrough_area_collision_y

        if not gameMover.was_on_ground:
            gameMover.processLand()
        gameMover.truly_on_ground = true
        return true

    # the above check counts for falling down onto the fallthroughCollision,
    # but if we are already on it, we know vel.y is 0ish, and need a more constrained check
    # to see if we are still on it
    if gameMover.was_fallthrough_area_collision_triggered and \
        gameMover.isRectColliding(
            ax + alb, ay + atb, ax + arb, ay + abb,
            x + lb, y + bb + tb_diff, x + rb, y + bb + bb_diff
        ):
        gameMover.on_ground = true
        gameMover.truly_on_ground = true
        return true
    return false

var currLevelZone = null
const HUB_LEVEL_ZONE = "gd1" 
func tryInitializeLevelZone(levelZone, should_set_currLevelZone = false):
    if should_set_currLevelZone:
        currLevelZone = levelZone
    if not self.memory.has(levelZone):
        self.memory[levelZone] = {}
    if not global.memory["level_zonez"].has(currLevelZone):
        global.memory["level_zonez"].push_back(currLevelZone)

func setLevelZoneThingHighScoreMemory(highScoreStr, levelZoneThing, score_mult):
    if not self.memory.has(highScoreStr):
        self.memory[highScoreStr] = {}
    if not self.memory.has(currLevelZone) or not self.memory[currLevelZone].has(levelZoneThing):
        return

    var curr_score = self.memory[currLevelZone][levelZoneThing]
    if not self.memory[highScoreStr].has(levelZoneThing) or \
       curr_score * score_mult > self.memory[highScoreStr][levelZoneThing]:
        self.memory[highScoreStr][levelZoneThing] = curr_score

func resetLevelZone(_levelZone):
    return 
    # if not levelZone == HUB_LEVEL_ZONE:
    #     self.memory[levelZone] = {}
    # if self.memory.has("spellbookPage"):
    #     self.memory["spellbookPage"] = []

func getNameRelativeToLevel(level, node):
  var nameRelativeToLevelPath = node.name
  var parent = node.get_parent()
  while true:
    if parent == null: return null
    if parent == level: break
    nameRelativeToLevelPath = parent.name + "/" + nameRelativeToLevelPath
    parent = parent.get_parent()
  return nameRelativeToLevelPath

func setHaveIBeenToLevel(level):
    var tempLevelZone = level.getLevelZoneName()
    var levelName = level.getShortLevelName()
    if tempLevelZone == null:
        return null
    tryInitializeLevelZone(tempLevelZone)
    if not global.memory.has(tempLevelZone): 
        return null

    if not global.memory[tempLevelZone].has(levelName):
        global.memory[tempLevelZone][levelName] = {}
    if not global.memory[tempLevelZone][levelName].has("have_i_been_here") or not global.memory[tempLevelZone][levelName]["have_i_been_here"]:
        level.levelTiles.tryToCountAndIncrementTotalGlitchTiles()
    global.memory[tempLevelZone][levelName]["have_i_been_here"] = true

func haveIBeenToThisLevelPath(levelPath):
    var shortLevelName = getShortLevelName(levelPath)
    var tempLevelZone = getLevelZoneName(levelPath)
    tryInitializeLevelZone(tempLevelZone)
    if tempLevelZone == null or not global.memory.has(tempLevelZone):
        return null

    if not global.memory[tempLevelZone].has(shortLevelName):
        return false
    if not global.memory[tempLevelZone][shortLevelName].has("have_i_been_here"):
        return false
    return global.memory[tempLevelZone][shortLevelName]["have_i_been_here"]

func eraseStaticLevelZoneLevelVar(level, node):
    if node == null:
        return
    var name = getNameRelativeToLevel(level, node)
    if name == null: return # failure

    var tempLevelZone = level.getLevelZoneName()
    tryInitializeLevelZone(tempLevelZone)
    if tempLevelZone == null or not global.memory.has(tempLevelZone): 
        return null

    if not global.memory[tempLevelZone].has(level.getShortLevelName()):
        global.memory[tempLevelZone][level.getShortLevelName()] = {}
    global.memory[tempLevelZone][level.getShortLevelName()].erase(name)

func setStaticLevelZoneLevelVar(level, node, val):
    if node == null:
        return
    var name = getNameRelativeToLevel(level, node)
    if name == null: return # failure

    var tempLevelZone = level.getLevelZoneName()
    tryInitializeLevelZone(tempLevelZone)
    if tempLevelZone == null or not global.memory.has(tempLevelZone): 
        return null

    if not global.memory[tempLevelZone].has(level.getShortLevelName()):
        global.memory[tempLevelZone][level.getShortLevelName()] = {}
    global.memory[tempLevelZone][level.getShortLevelName()][name] = val

func getStaticLevelZoneLevelVar(level, node):
    var name = getNameRelativeToLevel(level, node)
    if name == null: return null # failure

    var tempLevelZone = level.getLevelZoneName()
    tryInitializeLevelZone(tempLevelZone)
    if tempLevelZone == null or not global.memory.has(tempLevelZone):
        return null

    if not global.memory[tempLevelZone].has(level.getShortLevelName()):
        return null
    if not global.memory[tempLevelZone][level.getShortLevelName()].has(name):
        return null
    return global.memory[tempLevelZone][level.getShortLevelName()][name]

func getHighScoreLevelZoneThing(highScoreStr, levelZoneThing):
    if not self.memory.has(highScoreStr) or not self.memory[highScoreStr].has(levelZoneThing):
        return null
    return self.memory[highScoreStr][levelZoneThing]

func getLevelZoneThing(thing):
    if currLevelZone == null:
        return null
    if not self.memory.has(currLevelZone):
        return null
    if not self.memory[currLevelZone].has(thing):
        return null
    return self.memory[currLevelZone][thing]

# assumes that we can make a sum of thing
func getThingFromAllLevelZonez(thing, memoryOverride = null):
    var memoryToLoadFrom = memoryOverride if memoryOverride != null else global.memory
    var thingSum = 0
    for levelZone in memoryToLoadFrom["level_zonez"]:
        if not memoryToLoadFrom.has(levelZone):
            continue
        if not memoryToLoadFrom[levelZone].has(thing):
            continue
        thingSum += int(memoryToLoadFrom[levelZone][thing])
    return thingSum

func getThingArrayFromAllLevelZonez(thing):
    var thingArr = []
    for levelZone in global.memory["level_zonez"]:
        if not self.memory.has(levelZone):
            continue
        if not self.memory[levelZone].has(thing):
            continue
        thingArr.push_back(self.memory[levelZone][thing])
    return thingArr

func setLevelZoneThing(thing, val):
    # also set the total counter
    if not self.memory.has(thing):
        self.memory[thing] = 0
    self.memory[thing] = val
    if currLevelZone == null:
        return
    if currLevelZone == null:
        return

    if not self.memory.has(currLevelZone):
        self.memory[currLevelZone] = {}
    if not self.memory[currLevelZone].has(thing):
        self.memory[currLevelZone][thing] = 0
    self.memory[currLevelZone][thing] = val

func incrementLevelZoneThing(thing, amt):
    # also increment the total counter
    if not self.memory.has(thing):
        self.memory[thing] = 0
    self.memory[thing] += amt
    if currLevelZone == null:
        return

    if not self.memory.has(currLevelZone):
        self.memory[currLevelZone] = {}
    if not self.memory[currLevelZone].has(thing):
        self.memory[currLevelZone][thing] = 0
    self.memory[currLevelZone][thing] += amt

func incrementLevelZoneDeaths():
    incrementLevelZoneThing("num_deaths", 1)

func incrementLevelZoneJumps():
    incrementLevelZoneThing("num_jumps", 1)

func incrementLevelZoneSweeps():
    incrementLevelZoneThing("num_broom_sweeps", 1)

func incrementLevelZoneGlitchTiles(amt):
    incrementLevelZoneThing("num_glitch_tiles", amt)

func incrementLevelZoneTotalGlitchTiles(amt):
    incrementLevelZoneThing("total_num_glitch_tiles", amt)

func updateLevelZoneTime():
    if not global.has_started_game: return
    var startTime = getLevelZoneThing("start_time")
    if startTime == null:
        return
    var currTime = Time.get_unix_time_from_system()
    # print("add " + str(currTime - startTime) + " to " + str(currLevelZone))
    incrementLevelZoneTime(currTime - startTime)
    setLevelZoneThing("start_time", null)
func setLevelZoneStartTime():
    if not global.has_started_game: return
    # print("set " + str(currLevelZone) + " start time to " + str(Time.get_unix_time_from_system()))
    setLevelZoneThing("start_time", Time.get_unix_time_from_system())

func incrementLevelZoneTime(amt):
    incrementLevelZoneThing("total_time", amt)

var removedLevelZoneTilesKey = "removed_tiles"
func removeLevelZoneTile(levelName, coords):
    if currLevelZone == null:
        return

    var rt = removedLevelZoneTilesKey
    if not self.memory.has(currLevelZone):
        self.memory[currLevelZone] = {}
    if not self.memory[currLevelZone].has(levelName):
        self.memory[currLevelZone][levelName] = {}
    if not self.memory[currLevelZone][levelName].has(rt):
        self.memory[currLevelZone][levelName][rt] = []
    self.memory[currLevelZone][levelName][rt].append(coords)

func incrementLevelZoneSecretEggs():
    incrementLevelZoneThing("num_secret_eggs", 1)

func vec3ToVec2(vec3):
    return Vector2(vec3.x, vec3.y)

func moveToward2D(sourceVec3, targetVec3, delta):
    var z = sourceVec3.z
    var sourceVec2 = vec3ToVec2(sourceVec3)
    var targetVec2 = vec3ToVec2(targetVec3)

    sourceVec2 = sourceVec2.move_toward(targetVec2, delta)
    return Vector3(sourceVec2.x, sourceVec2.y, z)

func compare2D(sourceVec3, targetVec3, closeness_amt = 0.5):
    var sourceVec2 = vec3ToVec2(sourceVec3)
    var targetVec2 = vec3ToVec2(targetVec3)
    return (sourceVec2 - targetVec2).length() < closeness_amt    

func saveMySpot(savePoint, position, level):
    global.memory["savePoint"] = savePoint
    global.memory["active_save_point_x"] = position.x
    global.memory["active_save_point_y"] = position.y
    global.memory["active_save_point_z"] = position.z
    global.memory["savedRoomPath"] = level.getLevelName()

func broomSmackSound():
    if global.memory["currBroom"] == global.GrandmaBroom.FRYING_PAN:
        global.panSmackSound.play()
    if global.memory["currBroom"] == global.GrandmaBroom.CRONE_STAFF:
        global.croneStaffSmackSound.play()

func broomSmackStuff(areas, is_active, global_transform, my_broom_owner, level, smacked_npc):
  var have_i_smacked_an_npc = false
  for area in areas:
    if area.get_node("..") == my_broom_owner or area.get_node("../..") == my_broom_owner:
        continue
    if area.is_in_group("tadpole"):
      continue
    elif (area.is_in_group("weak_enemies")or area.is_in_group("nonviolent_enemies")) and area.has_method("isActive") and area.isActive() and is_active:
      if not area.get_node("..").am_i_dying:
        broomSmackSound()
        area.get_node("..").ouchies(global_transform.origin)
        level.summonSmokeClouds(global_transform.origin, 5, true, true)
        if my_broom_owner:
          my_broom_owner.has_sweeped_glitch = true
          my_broom_owner.glitchTickle()
          my_broom_owner.getSmacked()
        #   if my_broom_owner.teleport_to == null:
        #     my_broom_owner.teleport_to = weakref(area.get_parent())
        #     my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
    # thisisn't working because it's the PassiveInteractionArea that has the enemy group, not the active?
    elif area.is_in_group("enemies") and area.has_method("isActive") and area.isActive() and is_active:
      if global.memory["glitched_broom"]: # see GlitchEnemy.activate cuz it gets there first...
        if area.get_node("..").ouchies(global_transform.origin):
          broomSmackSound()
          if my_broom_owner:
            my_broom_owner.getSmacked()
            my_broom_owner.has_sweeped_glitch = true
            my_broom_owner.glitchTickle()
      else:
        if area.get_node("..").notOuchies(global_transform.origin):
          broomSmackSound()
          if my_broom_owner:
            my_broom_owner.getSmacked()
            my_broom_owner.has_sweeped_glitch = true
            my_broom_owner.glitchTickle()
            # if my_broom_owner.teleport_to == null:            
            #     my_broom_owner.teleport_to = weakref(area.get_parent())
            #     my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
      
      # # TODO kill glitches or "free" them like glitch slug...
      
    elif area.is_in_group("corporeal_body") and is_active:
      var areaParent = area.get_node("..")
      if canActivate(area, smacked_npc, have_i_smacked_an_npc) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive() and areaParent.visible:
        var smackResult = areaParent.getSmacked(global_transform.origin)
        if smackResult != false:
            broomSmackSound()
        if areaParent == level.player and my_broom_owner and my_broom_owner != level.player and my_broom_owner.summonedBroom and my_broom_owner.summonedBroom.is_evil:
          level.player.tryDieToEnemy(0, true, false)

        if areaParent.has_method("imAnNpc") and smackResult == null:
          smacked_npc = weakref(areaParent)
          have_i_smacked_an_npc = true
        if not area.is_in_group("tadpole") and smackResult == null:
          if my_broom_owner:
            my_broom_owner.getSmacked()
            # if my_broom_owner.teleport_to == null:
            #     my_broom_owner.teleport_to = weakref(area.get_parent())
            #     my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
    elif area.is_in_group("bug") and is_active:
      var areaParent = area.get_node("..")
      if canActivate(area, smacked_npc, have_i_smacked_an_npc) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive():
        var smackResult = areaParent.getSmacked(global_transform.origin)
        if smackResult != false:
            broomSmackSound()
        if not (area.is_in_group("tadpole") and smackResult == null):
          if my_broom_owner:
            my_broom_owner.getSmacked()
            # if my_broom_owner.teleport_to == null:
            #     my_broom_owner.teleport_to = weakref(area.get_parent())
            #     my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
    elif canActivate(area, smacked_npc, have_i_smacked_an_npc) and not area.is_in_group("door") and not area.is_in_group("true_small_door") and area.has_method("isActive") and area.isActive() and area.has_method("InteractActivate") and is_active:
      # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
      # TODO(jaketrower): Will be not true when broomerang >= 2
      area.InteractActivate(false)
    elif canActivate(area, smacked_npc, have_i_smacked_an_npc) and area.has_method("isActive") and area.isActive() and area.has_method("PassiveInteractActivate"): 
      # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
      # TODO(jaketrower): Will be not true when broomerang >= 2
      area.PassiveInteractActivate(0, false)
  return smacked_npc


func canActivate(area, smacked_npc, have_i_smacked_an_npc):
  var areaParent = area.get_node("..")
  # sorry!
  return not areaParent.has_method("imAnNpc") or smacked_npc == null or \
         (not have_i_smacked_an_npc and smacked_npc.get_ref() and \
            (areaParent != smacked_npc.get_ref() or \
              (smacked_npc.get_ref().textBox == global.activeInteractor and \
                !smacked_npc.get_ref().textBox.isWaitingForEndPrompt())))

func getKeyInMemory(key_type, level):
    if key_type != 0: # thank god
        if not global.memory.has("key_items"):
            global.memory["key_items"] = {}
        global.memory["key_items"][key_type] = global.ItemState.GOT_IT
        var key_name = "PHISHING KEY"
        if key_type == global.KeyItem.PYRAMID:
            key_name = "CRYPT KEY"
        elif key_type == global.KeyItem.SHROOM:
            key_name = "SHROOM KEY"
        elif key_type == global.KeyItem.CAT:
            key_name = "SPORE KEY"
        level.player.sayThis("Got the " + key_name + "!")
    else:
        var num_keys = global.memory["key"] if global.memory.has("key") else null
        if num_keys == null:
            global.memory["key"] = 0
            level.uiLayer.get_node("KeyStatusRect").visible = true
            level.uiLayer.get_node("KeyStatusRect").rect_scale = Vector2(1.5, 1.5)
            level.uiLayer.get_node("KeyStatusRect").rect_position = Vector2(200, 325)
        global.memory["key"] += 1

func isTileSolid(tile_type, mesh_library):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = mesh_library.get_item_name(tile_type)
  return ("BrickSolid" in tile_name or "SoftSand" in tile_name or "DissolvingStone" in tile_name or "SolidTransientTile" in tile_name) and not "Spikes" in tile_name
