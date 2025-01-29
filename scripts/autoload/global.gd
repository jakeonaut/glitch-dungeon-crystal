extends Node

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

onready var doorSound = get_node("DoorSound")
onready var glitchedDoorSound = get_node("GlitchedDoorSound")
var DELETE_ME = 2

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
}

enum GrandmaOutfit {
    BABUSHKA,
    NO_HAT,
    WITCH_HAT,
    BONNET,
    NON_LA,
    SUN_HAT,
    BUG_CATCHER,
    CROCHET,
    SCARF_EARMUFFS,
    YOUNG_BABA,
    YUBABA,
    WASTE_WITCH,
    SOPHIE,
    TOTORO_GRANNY,
    KIKI,
    MONONOKE,
}

enum GrandmaBroom {
    NORMAL,
    ELDER_CANE,
    CRONE_STAFF,
    BABA_YAGA_CHICKEN_STAFF,
    BUG_NET,
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
var NUM_GEMS_FOR_BROOMERANG = 25
var NUM_GEMS_FOR_ENCHANTED_BAG = 75
var NUM_GEMS_FOR_DOUBLE_JUMP = 75
var NUM_GEMS_FOR_BROOMERANG_WARP = 999

var has_started_game = false
var has_really_started_game = false
var okay_really_really_started_game = false
var spellCastPauseIndex = null
var correct_ritual = ["ui_down", "ui_down", "ui_down", "restart_key"]
var has_been_baba_yaga_cursed = false
var has_ever_seen_epilepsy_warning = false
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
    if has_ever_seen_epilepsy_warning: pass

    resetMemory()
    resetUserSettings()
    loadUserSettings()

func resetMemory():
    memory = {}

    # customization upgrades
    memory["currPet"] = null
    memory["allMyPets"] = [PetFollower.NONE]
    memory["currOutfit"] = GrandmaOutfit.BABUSHKA
    memory["allMyOutfits"] = [GrandmaOutfit.BABUSHKA]
    memory["currBroom"] = GrandmaBroom.NORMAL
    memory["allMyBrooms"] = [GrandmaBroom.NORMAL]
    memory["currBag"] = GrandmaBag.NORMAL
    memory["allMyBags"] = [GrandmaBag.NORMAL]

    # game stuff
    memory["hasEverTouchedObelisk"] = false
    memory["currLevelZone"] = null
    memory["initialized_from_debug"] = false
    memory["tutorial_gem"] = 0
    memory["hammer"] = 0
    memory["broom"] = true
    memory["has_gotten_broom"] = 0
    memory["nesting_doll"] = NestingDoll.GRANDMA
    
    memory["crone"] = 0
    memory["hearts_recovering"] = false
    memory["max_mp"] = 0
    memory["mp"] = memory["max_mp"]
    memory["level_zonez"] = []

    memory["demo_mode"] = 0
    # if you've beaten the midpoint boss
    memory["clean_crystals"] = 4
    memory["priestess"] = 2
    memory["glitch_world"] = 0
    memory["glitched_grimoire"] = false
    memory["forget_me_not"] = false
    memory["glitched_grimoire2"] = false
    

    # crystal elder bosses
    memory["baba_yaga_boss"] = 4
    memory["angler_seaman_boss"] = 4
    memory["dogu_matryoshka_boss"] = 4

    # STORY OR LEVEL STATE
    memory["babushka_cat_story_hook"] = 2
    memory["fishing_rod_shortcut"] = 0

    # POWERUPS
    # memory["spellbookPage"] = [] # we check if the key exists to see if we have it... -_-
    memory["can_force_respawn"] = 1
    memory["has_map_item"] = true
    memory["broomerang"] = 1
    memory["broom_double_jump"] = 1
    memory["zora_flippers"] = 1
    memory["mole_cricket"] = 1
    memory["mushroom_soul"] = 1
    memory["glitched_broom"] = false
    memory["max_hp"] = 1
    memory["hp"] = memory["max_hp"]
    memory["angel_flute"] = false
    memory["has_marked_bosses_on_map"] = true

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

func resetUserSettings():
    userSettings = {}

    # settings?
    userSettings["show_crt_effect"] = true
    userSettings["show_palette_swap_color_blind_filter"] = false
    userSettings["canGlitchScreen"] = true
    userSettings["colorblindMode"] = true
    userSettings["stopAllMusic"] = false
    userSettings["canChangeSongPitch"] = true
    userSettings["spellAssist"] = false

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

func prepareForTransition(level, enteredDoor = null):
    global.activeInteractor = null
    global.memory["cameraSize"] = level.gameCamera.initial_size
    # global.memory["lastDoor"] = id
    global.memory["roomPath"] = level.getLevelName()
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


func _process(delta):
    delta = delta * time_dilation_multiplier

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
            return gd1TutorialName
        "gd1FishingVillage":
            return "tadpole bog"
        "gd1ToxicJungle":
            return "moldy dogwoods"
        "gd1ShiftingSandLand":
            return "cricket caves" # could amp up the insect-ness more
        "gd1CrystalTower":
            return "elder temple"
        "gd1BubblegloopSwamp":
            return "sea of corruption" # malware swamp
        "gd1TombSouls":
            return "forgotten crypt"
        "gd1AbstractSuburbs":
            return "yaga village"
        "gd1GrandmaVillage":
            return "primordial ooze"
        "gd1PrimordialOoze":
            return "primordial ooze"
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
]
var user_settings_files = [
    "user://usersettings.config"
]
var save_game_index = 0
func saveGame():
    var save_game_file = save_game_files[save_game_index]
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

func loadGame(saveGameIndex):
    if saveGameIndex < 0 or saveGameIndex >= save_game_files.size():
        return false # Error! out of bounds
    save_game_index = saveGameIndex
    var save_game_file = save_game_files[save_game_index]
    var file = File.new()
    if not file.file_exists(save_game_file):
        return false # Error! We don't have a save to load.
    
    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    file.open(save_game_file, File.READ)
    
    var save_game_contents = file.get_line()
    global.memory.merge(parseJsonPreserveInt(save_game_contents), true)
    while not file.eof_reached():
        # ... ??? Is this because global.memory is stored on a single line? enigmatic..
        var _current_line = parseJsonPreserveInt(file.get_line())
    normalizeLoadedMemory()
        
    file.close()

    if global.memory.has("roomPath"):
        currLevelZone = getLevelZoneName(global.memory["roomPath"])
        if not global.memory["level_zonez"].has(currLevelZone):
            global.memory["level_zonez"].push_back(currLevelZone)

    # reset boss flags from 1 to 0 if we are loading, so we can start the opening cinematic again for all of them.
    # if the boss flag is 2 already, it means you've beat them, so don't reset
    if global.memory["priestess"] == 1:
        global.memory["priestess"] = 0
    if global.memory["baba_yaga_boss"] == 1:        
        global.memory["baba_yaga_boss"] = 0
    if global.memory["angler_seaman_boss"] == 1:
        global.memory["angler_seaman_boss"] = 0
    if global.memory["dogu_matryoshka_boss"] == 1:
        global.memory["dogu_matryoshka_boss"] = 0
    return true

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
    return turnRealIntoIntRecursive(parse_json(json_str))

var is_reading_input = false
var last_read_input = null
var hasInitializedControlsConfig = false
var is_reading_keyboard_input = false
var is_reading_controller_input = false
func _input(ev):
    if not is_reading_input:
        return

    if is_reading_keyboard_input and ev is InputEventKey and ev.pressed:
        last_read_input = ev.scancode
    if is_reading_controller_input and ev is InputEventJoypadButton and ev.pressed:
        last_read_input = ev.button_index

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
        JOY_L3: # TODO(jaketrower): if useSpecialChar
            return "L3"
        JOY_R:
            return "W" if useSpecialChar else "R1"
        JOY_R2:
            return "P" if useSpecialChar else "R2"
        JOY_R3: # TODO(jaketrower): if useSpecialChar
            return "R3"
        _:
            return "?"

func getAxisStr(axis, axis_value, useSpecialChar = true):
    if axis == JOY_AXIS_0:
        if axis_value > 0.5:
            return "h" if useSpecialChar else "Lstick Right"
        elif axis_value < 0.5:
            return "f" if useSpecialChar else "Lstick Left"
    if axis == JOY_AXIS_1:
        if axis_value < 0.5:
            return "t" if useSpecialChar else "Lstick Up"
        elif axis_value > 0.5:
            return "b" if useSpecialChar else "Lstick Down"
    if axis == JOY_AXIS_2:
        if axis_value > 0.5:
            return "h" if useSpecialChar else "Rstick Right"
        elif axis_value < 0.5:
            return "f" if useSpecialChar else "Rstick Left"
    if axis == JOY_AXIS_3:
        if axis_value < 0.5:
            return "t" if useSpecialChar else "Rstick Up"
        elif axis_value > 0.5:
            return "b" if useSpecialChar else "Rstick Down"
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

func setButtonIndex(input_action, button_index):
  var inputEvents = InputMap.get_action_list(input_action)
  for inputEvent in inputEvents:
    if inputEvent is InputEventJoypadButton:
      InputMap.action_erase_event(input_action, inputEvent)
  var new_event = InputEventJoypadButton.new()
  new_event.set_button_index(button_index)
  InputMap.action_add_event(input_action, new_event)

func isControllerConnected():
    return Input.get_connected_joypads().size() > 0

func getLargeInputText(input_action, input_display = 0, use_bbtext = true):
    # TODO(jaketrower): Support both key & gamepad here based on which was pressed last ?
    var is_controller_connected = (self.isControllerConnected() or input_display == 1) and not input_display == 2

    var inputEvents = InputMap.get_action_list(input_action)
    var glyphType = GlyphType.NINTENDO
    for inputEvent in inputEvents:
        if is_controller_connected:
            if inputEvent is InputEventJoypadButton:
                if use_bbtext:
                    var buttonIndexStr = getButtonIndexStr(inputEvent.button_index, glyphType)
                    if buttonIndexStr == "Start" or buttonIndexStr == "Select":
                        return buttonIndexStr
                    return "[font=res://DarkInputExtraFont.tres]" + buttonIndexStr + "[/font]"
                else:
                    return "(" + getButtonIndexStr(inputEvent.button_index, glyphType, false) + ")"
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
                    return "[" + getKeyCodeStr(inputEvent.get_scancode(), false) + "]"
        
    return null

func getInputText(input_action, input_display = 0, use_bbtext = true, showCondensedMenu = false):
    # TODO(jaketrower): Support both key & gamepad here based on which was pressed last ?
    var is_controller_connected = (self.isControllerConnected() or input_display == 1) and not input_display == 2

    var inputEvents = InputMap.get_action_list(input_action)
    var glyphType = GlyphType.NINTENDO
    for inputEvent in inputEvents:
        if is_controller_connected:
            if inputEvent is InputEventJoypadButton:
                if use_bbtext:
                    var buttonIndexStr = getButtonIndexStr(inputEvent.button_index, glyphType)
                    if buttonIndexStr == "Start" or buttonIndexStr == "Select":
                        return buttonIndexStr
                    return "[font=res://DarkInputExtraFont_small.tres]" + buttonIndexStr + "[/font]"
                else:
                    return "(" + getButtonIndexStr(inputEvent.button_index, glyphType, false) + ")"
            # if inputEvent is InputEventJoypadMotion:
            #     if use_bbtext:
            #         return "[font=res://DarkInputExtraFont_small.tres]" + getAxisStr(inputEvent.axis, inputEvent.axis_value) + "[/font]"
            #     else:
            #         return getAxisStr(inputEvent.axis, inputEvent.axis_value, false)
        else:
            if inputEvent is InputEventKey:
                if use_bbtext:
                    if showCondensedMenu:
                        return "[font=res://DarkInputFont_smallCondensed.tres]" + getKeyCodeStr(inputEvent.get_scancode()) + "[/font]"
                    return "[font=res://DarkInputFont_small.tres]" + getKeyCodeStr(inputEvent.get_scancode()) + "[/font]"
                else:
                    return "[" + getKeyCodeStr(inputEvent.get_scancode(), false) + "]"
        
    return null

func normalizeLoadedMemory():
    if typeof(global.memory["nesting_doll"]) == TYPE_BOOL:
        global.memory["nesting_doll"] = global.NestingDoll.GRANDMA

func normalizeLoadedUserSettings():
    # global.userSettings
    pass
    
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
func doFallthroughObjectCollision(gameMover, area):
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
    var diff = -0.12
    if gameMover.grav < 0:
        lv *= -1
        diff *= -1
        var temp = atb
        atb = abb
        abb = temp

        temp = tb
        tb = bb
        bb = temp

    var truly_on_ground_memory = gameMover.truly_on_ground
    if gameMover.isRectColliding(
        ax + alb, ay + atb, ax + arb, ay + abb,
        x + lb, y + bb, x + rb, y + bb + diff
    ) and (lv < 0 or (lv == 0 and gameMover.glitch_form == global.GlitchForm.FLOOR)):
        gameMover.was_fallthrough_area_collision_triggered = true
        gameMover.fallthrough_area_collision_y = ay + atb - bb
        gameMover.linear_velocity = gameMover.collideWithFloor(gameMover.linear_velocity)
        gameMover.truly_on_ground = truly_on_ground_memory
        
        gameMover.lv = gameMover.linear_velocity
        gameMover.global_transform.origin.y = gameMover.fallthrough_area_collision_y

        if not gameMover.was_on_ground:
            gameMover.processLand()
        return true

    # the above check counts for falling down onto the fallthroughCollision,
    # but if we are already on it, we know vel.y is 0ish, and need a more constrained check
    # to see if we are still on it
    if gameMover.was_fallthrough_area_collision_triggered and \
        gameMover.isRectColliding(
            ax + alb, ay + atb, ax + arb, ay + abb,
            x + lb, y + bb, x + rb, y + bb + diff
        ):
        gameMover.on_ground = true
        return true
    return false

var currLevelZone = null
const HUB_LEVEL_ZONE = "gd1" 
func tryInitializeLevelZone(levelZone):
    if currLevelZone == levelZone:
        return

    if not self.memory.has(levelZone):
        self.memory[levelZone] = {}
    
    if currLevelZone == HUB_LEVEL_ZONE and levelZone != HUB_LEVEL_ZONE:
        # entering the level from the hub world, restart!
        # resetLevelZone(levelZone)
        pass
    elif hasGottenLevelGeode and currLevelZone != null and currLevelZone != HUB_LEVEL_ZONE and levelZone == HUB_LEVEL_ZONE:
        pass
        # # just got back to the hub!, record the levelZone's results
        # var highScoreStr = currLevelZone + "_highscore"
        # if not self.memory.has(highScoreStr):
        #     self.memory[currLevelZone + "_highscore"] = {}

        # setLevelZoneThingHighScoreMemory(highScoreStr, "num_mini_crystal_cubes", 1)
        # setLevelZoneThingHighScoreMemory(highScoreStr, "angelTadpole", 1)
        # setLevelZoneThingHighScoreMemory(highScoreStr, "num_deaths", -1)
        # setLevelZoneThingHighScoreMemory(highScoreStr, "num_jumps", -1)
        # setLevelZoneThingHighScoreMemory(highScoreStr, "num_glitch_tiles", 1)
        # setLevelZoneThingHighScoreMemory(highScoreStr, "num_broom_sweeps", -1)
        # setLevelZoneThingHighScoreMemory(highScoreStr, "hiscore", 1)
    currLevelZone = levelZone
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
    tryInitializeLevelZone(level.getLevelZoneName())
    if currLevelZone == null or not global.memory.has(currLevelZone): 
        return null

    if not global.memory[currLevelZone].has(level.getShortLevelName()):
        global.memory[currLevelZone][level.getShortLevelName()] = {}
    global.memory[currLevelZone][level.getShortLevelName()]["have_i_been_here"] = true

func haveIBeenToThisLevel(level):
    tryInitializeLevelZone(level.getLevelZoneName())
    if currLevelZone == null or not global.memory.has(currLevelZone):
        return null

    if not global.memory[currLevelZone].has(level.getShortLevelName()):
        return false
    if not global.memory[currLevelZone][level.getShortLevelName()].has("have_i_been_here"):
        return false
    return global.memory[currLevelZone][level.getShortLevelName()]["have_i_been_here"]

func haveIBeenToThisLevelPath(levelPath):
    var shortLevelName = getShortLevelName(levelPath)
    tryInitializeLevelZone(getLevelZoneName(levelPath))
    if currLevelZone == null or not global.memory.has(currLevelZone):
        return null

    if not global.memory[currLevelZone].has(shortLevelName):
        return false
    if not global.memory[currLevelZone][shortLevelName].has("have_i_been_here"):
        return false
    return global.memory[currLevelZone][shortLevelName]["have_i_been_here"]

func eraseStaticLevelZoneLevelVar(level, node):
    if node == null:
        return
    var name = getNameRelativeToLevel(level, node)
    if name == null: return # failure

    tryInitializeLevelZone(level.getLevelZoneName())
    if currLevelZone == null or not global.memory.has(currLevelZone): 
        return null

    if not global.memory[currLevelZone].has(level.getShortLevelName()):
        global.memory[currLevelZone][level.getShortLevelName()] = {}
    global.memory[currLevelZone][level.getShortLevelName()].erase(name)

func setStaticLevelZoneLevelVar(level, node, val):
    if node == null:
        return
    var name = getNameRelativeToLevel(level, node)
    if name == null: return # failure

    tryInitializeLevelZone(level.getLevelZoneName())
    if currLevelZone == null or not global.memory.has(currLevelZone): 
        return null

    if not global.memory[currLevelZone].has(level.getShortLevelName()):
        global.memory[currLevelZone][level.getShortLevelName()] = {}
    global.memory[currLevelZone][level.getShortLevelName()][name] = val

func getStaticLevelZoneLevelVar(level, node):
    var name = getNameRelativeToLevel(level, node)
    if name == null: return null # failure

    tryInitializeLevelZone(level.getLevelZoneName())
    if currLevelZone == null or not global.memory.has(currLevelZone): 
        return null

    if not global.memory[currLevelZone].has(level.getShortLevelName()):
        return null
    if not global.memory[currLevelZone][level.getShortLevelName()].has(name):
        return null
    return global.memory[currLevelZone][level.getShortLevelName()][name]

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
func getThingFromAllLevelZonez(thing):
    var thingSum = 0
    for levelZone in global.memory["level_zonez"]:
        if not self.memory.has(levelZone):
            continue
        if not self.memory[levelZone].has(thing):
            continue
        thingSum += int(self.memory[levelZone][thing])
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

var removedLevelZoneTilesKey = "removed_tiles"
func removeLevelZoneTile(levelName, coords):
    if currLevelZone == null:
        return

    if not self.memory.has(currLevelZone):
        self.memory[currLevelZone] = {}
    if not self.memory[currLevelZone].has(levelName):
        self.memory[currLevelZone][levelName] = {}
    if not self.memory[currLevelZone][levelName].has(removedLevelZoneTilesKey):
        self.memory[currLevelZone][levelName][removedLevelZoneTilesKey] = []
    self.memory[currLevelZone][levelName][removedLevelZoneTilesKey].append(coords)

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


func broomSmackStuff(areas, is_active, global_transform, my_broom_owner, level, smacked_npc):
  var have_i_smacked_an_npc = false
  for area in areas:
    if area.get_node("..") == my_broom_owner or area.get_node("../..") == my_broom_owner:
        continue
    if area.is_in_group("tadpole"):
      continue
    elif area.is_in_group("weak_enemies") and area.has_method("isActive") and area.isActive() and is_active:
      if not area.get_node("..").am_i_dying:
        area.get_node("..").ouchies(global_transform.origin)
        level.summonSmokeClouds(global_transform.origin, 5, true, true)
        if my_broom_owner:
          my_broom_owner.has_sweeped_glitch = true
          my_broom_owner.glitchTickle()
          my_broom_owner.getSmacked()
          if my_broom_owner.teleport_to == null:
            my_broom_owner.teleport_to = weakref(area.get_parent())
            my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
    # thisisn't working because it's the PassiveInteractionArea that has the enemy group, not the active?
    elif area.is_in_group("enemies") and area.has_method("isActive") and area.isActive() and is_active:
      if global.memory["glitched_broom"]: # see GlitchEnemy.activate cuz it gets there first...
        if area.get_node("..").ouchies(global_transform.origin):
          if my_broom_owner:
            my_broom_owner.getSmacked()
            my_broom_owner.has_sweeped_glitch = true
            my_broom_owner.glitchTickle()
      else:
        if area.get_node("..").notOuchies(global_transform.origin):
          if my_broom_owner:
            my_broom_owner.getSmacked()
            my_broom_owner.has_sweeped_glitch = true
            my_broom_owner.glitchTickle()
            if my_broom_owner.teleport_to == null:            
                my_broom_owner.teleport_to = weakref(area.get_parent())
                my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
      
      # # TODO kill glitches or "free" them like glitch slug...
      
    elif area.is_in_group("corporeal_body") and is_active:
      var areaParent = area.get_node("..")
      if canActivate(area, smacked_npc, have_i_smacked_an_npc) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive() and areaParent.visible:
        var smackResult = areaParent.getSmacked(global_transform.origin)
        if areaParent == level.player and my_broom_owner and my_broom_owner != level.player and my_broom_owner.summonedBroom and my_broom_owner.summonedBroom.is_evil:
          level.player.tryDieToEnemy(0, true, false)

        if areaParent.has_method("imAnNpc") and smackResult == null:
          smacked_npc = weakref(areaParent)
          have_i_smacked_an_npc = true
        if not area.is_in_group("tadpole") and smackResult == null:
          if my_broom_owner:
            my_broom_owner.getSmacked()
            if my_broom_owner.teleport_to == null:
                my_broom_owner.teleport_to = weakref(area.get_parent())
                my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
    elif area.is_in_group("bug") and is_active:
      var areaParent = area.get_node("..")
      if canActivate(area, smacked_npc, have_i_smacked_an_npc) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive():
        var smackResult = areaParent.getSmacked(global_transform.origin)
        if not (area.is_in_group("tadpole") and smackResult == null):
          if my_broom_owner:
            my_broom_owner.getSmacked()
            if my_broom_owner.teleport_to == null:
                my_broom_owner.teleport_to = weakref(area.get_parent())
                my_broom_owner.teleport_to_origin = area.get_parent().global_transform.origin
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
