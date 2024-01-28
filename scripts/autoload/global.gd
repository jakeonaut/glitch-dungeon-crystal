extends Node

var kirokaze_palette = preload("res://assets/palettes/kirokaze-gameboy-1x.png")

var player_base_palette = preload("res://assets/palettes/player_base_palette.png")
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
var base_palette = preload("res://assets/palettes/base_palette.png")
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
var DELETE_ME = 2

# GlitchForm variables
enum GlitchForm {
    NORMAL,
    FLOOR,
    FEATHER,
    INVISIBLE,
    LADDER,
    WALK_THROUGH_WALLS,
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
    CAT
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

func getColorSuffixFromTilesetType(type):
    if type == TilesetType.DUNGEON:
        return ""
    if type == TilesetType.HOUSE or type == TilesetType.POISON_HOUSE:
        return "_red"
    if type == TilesetType.FOREST or type == TilesetType.BEACH or type == TilesetType.POISON_FOREST:
        return "_green"
    if type == TilesetType.ALIEN:
        return "_black"
    if type == TilesetType.DESERT:
        return "_yellow"
    if type == TilesetType.GLITCH_WORLD:
        return "_white"

var memory = {}

var activeInteractor = null
var activeThrowableObject = null
var activeThrowableObjectPath = null
var activeSavePoint = null

var isRespawning = false
var isEnteringRoom = false
var grannyEnteringRoom = false
var hasJustRespawned = false
var hasJustEnteredRoom = false
var respawnVarTimerHack = 0
var respawnVarTimerHackLimit = 2
var cameraRotation = 0

var pauseMoveInput = false # don't allow player physics or camera input??
var pauseGame = false
var isInventoryOpen = false
var isPauseMenuOpen = false

var num_cherries_eaten = 0
var num_cherries_gained = 0
var max_cherries = 5
var collectable_key_recently_got = null
var collectable_key_recently_got_timer = 0
var collectable_key_recently_got_time_limit = 40

var canGlitchScreen = true
var canChangeSongPitch = true
var crtScreenEffects = true

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

func _ready():
    set_process(true)

    # somehow this gets rid of errors LOL
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
    if canGlitchScreen: pass
    if canChangeSongPitch: pass
    if crtScreenEffects: pass
    if set_camera_position_on_respawn: pass
    if hasGottenLevelGeode: pass

    # settings?
    memory["show_crt_effect"] = true
    memory["show_dither_effect"] = true
    memory["show_color_blind"] = false

    # game stuff
    memory["broom"] = false
    memory["has_gotten_broom"] = 1
    memory["nesting_doll"] = NestingDoll.GRANDMA
    memory["max_hp"] = 1
    memory["clean_crystals"] = 0
    memory["hp"] = memory["max_hp"]
    memory["hearts_recovering"] = false
    memory["max_mp"] = 0
    memory["mp"] = memory["max_mp"]
    memory["level_zonez"] = []
    # memory["spellbookPage"] = null # we check if the key exists to see if we have it... -_-
    memory["glitched_grimoire"] = false

    # PERMANENT SPELLS
    
    memory["permanent_spells"] = [
        false, # "NORMAL", sort of a no-op for permanentSpells
        false, # "FLOOR", 
        false, # "FEATHER",
        false, # "INVISIBLE", 
        false, # "LADDER", 
        false, # "WALK_THROUGH_WALLS"
    ]

    # POWERUPS
    memory["broomerang"] = false
    memory["magic_lantern"] = false
    memory["can_nest"] = false
    memory["mario_nesting_doll"] = false
    memory["broom_flight"] = false
    memory["speed_slippers"] = true # TODO(jaketrower): turn off before beta build
    memory["zora_flippers"] = false

    # GAME MODES
    memory["random_entrances"] = false

    # EASTER EGGS
    memory["anna_mode"] = false
    memory["blue_mode"] = false

    loadGameSettings()

var anna_mode_counter = 0
var anna_key_helper = false
func processEasterEggs():
    if Input.is_physical_key_pressed(KEY_A):
        if anna_mode_counter == 0:
            anna_key_helper = true
            anna_mode_counter += 1
        elif anna_mode_counter == 3:
            if not memory.has("anna_mode"):
                memory["anna_mode"] = true
            else:
                memory["anna_mode"] = not memory["anna_mode"]
            print("ANNA_MODE = " + str(memory["anna_mode"]))
            anna_key_helper = true
            anna_mode_counter = 0
        elif not anna_key_helper:
            anna_mode_counter = 0
    elif Input.is_physical_key_pressed(KEY_N):
        if (anna_mode_counter == 1 or anna_mode_counter == 2) and not anna_key_helper:
            anna_key_helper = true
            anna_mode_counter += 1
        elif not anna_key_helper:
            anna_mode_counter = 0
    elif Input.is_physical_key_pressed(KEY_B):
        if not anna_key_helper:
            anna_mode_counter = 0
            anna_key_helper = true
            if not memory.has("blue_mode"):
                memory["blue_mode"] = true
            else:
                memory["blue_mode"] = not memory["blue_mode"]
    else:
        anna_key_helper = false


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

var is_reading_input = false
var last_read_input = null
var hasInitializedControlsConfig = false
func _input(ev):
    if is_reading_input and ev is InputEventKey and ev.pressed:
        last_read_input = ev.scancode

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


var save_game_file = "user://savegame.save"
func saveGame():
    var save_game = File.new()
    save_game.open(save_game_file, File.WRITE)
    save_game.store_line(to_json(global.memory))
    save_game.close()

func doesSaveGameExist():
    var save_game = File.new()
    return save_game.file_exists(save_game_file)

func loadGameSettings():
    var save_game = File.new()
    if not save_game.file_exists(save_game_file):
        return false # Error! We don't have a save to load.
    
    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    save_game.open(save_game_file, File.READ)

    var save_game_contents = save_game.get_line()
    var fake_memory = parse_json(save_game_contents)
    if fake_memory.has("controls_config"):
        global.memory["controls_config"] = fake_memory["controls_config"]

func loadGame():
    var save_game = File.new()
    if not save_game.file_exists(save_game_file):
        return false # Error! We don't have a save to load.
    
    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    save_game.open(save_game_file, File.READ)
    
    var save_game_contents = save_game.get_line()
    global.memory.merge(parse_json(save_game_contents), true)
    while not save_game.eof_reached():
        # ... ??? Is this because global.memory is stored on a single line? enigmatic..
        var _current_line = parse_json(save_game.get_line())
    normalizeLoadedMemory()
        
    save_game.close()

    if global.memory.has("roomPath"):
        currLevelZone = getLevelZoneName(global.memory["roomPath"])
        if not global.memory["level_zonez"].has(currLevelZone):
            global.memory["level_zonez"].push_back(currLevelZone)
    return true

func normalizeLoadedMemory():
    if typeof(global.memory["nesting_doll"]) == TYPE_BOOL:
        global.memory["nesting_doll"] = global.NestingDoll.GRANDMA
    
func getNextGlitch(glitch_form):
    if glitch_form == global.GlitchForm.NORMAL: return global.GlitchForm.FLOOR
    if glitch_form == global.GlitchForm.FLOOR: return global.GlitchForm.FEATHER
    if glitch_form == global.GlitchForm.FEATHER: return global.GlitchForm.INVISIBLE
    if glitch_form == global.GlitchForm.INVISIBLE: return global.GlitchForm.LADDER
    if glitch_form == global.GlitchForm.LADDER: return global.GlitchForm.WALK_THROUGH_WALLS
    if glitch_form == global.GlitchForm.WALK_THROUGH_WALLS: return global.GlitchForm.NORMAL

func strip_bbcode(source):
  var regex = RegEx.new()
  regex.compile("\\[.+?\\]")
  return regex.sub(source, "", true)

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

    if gameMover.physics_state != gameMover.PhysicsState.NORMAL:
        return false

    var x = gameMover.global_transform.origin.x
    var y = gameMover.global_transform.origin.y
    if (gameMover.pressingDown() and (gameMover.on_ground or (y - gameMover.tb) < (ay + atb))) or \
       (not "should_do_fallthrough_area_collision" in gameMover):
        if "should_do_fallthrough_area_collision" in gameMover:
            gameMover.should_do_fallthrough_area_collision = false
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

    if gameMover.isRectColliding(
        ax + alb, ay + atb, ax + arb, ay + abb,
        x + lb, y + bb, x + rb, y + bb + diff
    ) and (lv < 0 or (lv == 0 and gameMover.glitch_form == global.GlitchForm.FLOOR)):
        gameMover.should_do_fallthrough_area_collision = true
        gameMover.fallthrough_area_collision_y = ay + atb - bb
        gameMover.linear_velocity = gameMover.collideWithFloor(gameMover.linear_velocity)
        gameMover.lv = gameMover.linear_velocity
        gameMover.global_transform.origin.y = gameMover.fallthrough_area_collision_y

        if not gameMover.was_on_ground:
            gameMover.processLand()
        return true

    # the above check counts for falling down onto the fallthroughCollision,
    # but if we are already on it, we know vel.y is 0ish, and need a more constrained check
    # to see if we are still on it
    if gameMover.should_do_fallthrough_area_collision and \
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

func setStaticLevelZoneLevelVar(level, name, val):
    tryInitializeLevelZone(level.getLevelZoneName())
    if currLevelZone == null or not global.memory.has(currLevelZone): 
        return null

    if not global.memory[currLevelZone].has(level.getShortLevelName()):
        global.memory[currLevelZone][level.getShortLevelName()] = {}
    global.memory[currLevelZone][level.getShortLevelName()][name] = val

func getStaticLevelZoneLevelVar(level, name):
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
        return
    if not self.memory.has(currLevelZone):
        return
    if not self.memory[currLevelZone].has(thing):
        return
    return self.memory[currLevelZone][thing]

# assumes that we can make a sum of thing
func getThingFromAllLevelZonez(thing):
    var thingSum = 0
    for levelZone in global.memory["level_zonez"]:
        if not self.memory.has(levelZone):
            continue
        if not self.memory[levelZone].has(thing):
            continue
        thingSum += self.memory[levelZone][thing]
    return thingSum

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

func saveMySpot(position, level):
    global.memory["active_save_point_x"] = position.x
    global.memory["active_save_point_y"] = position.y
    global.memory["active_save_point_z"] = position.z
    global.memory["savedRoomPath"] = level.getLevelName()
