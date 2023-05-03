extends Node

var grey_player_palette = preload("res://assets/palettes/grey_player_palette.png")
var yellow_player_palette = preload("res://assets/palettes/yellow_player_palette.png")

var grey_palette = preload("res://assets/palettes/grey_palette.png")
var red_palette = preload("res://assets/palettes/red_palette.png")
var green_palette = preload("res://assets/palettes/green_palette.png")
var black_palette = preload("res://assets/palettes/black_palette.png")
var yellow_palette = preload("res://assets/palettes/yellow_palette.png")
var white_palette = preload("res://assets/palettes/white_palette.png")
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

var tidepool_palette = preload("res://assets/palettes/tidepool_palette.png")
var green_tidepool_palette = preload("res://assets/palettes/green_tidepool_palette.png")
var red_tidepool_palette = preload("res://assets/palettes/red_tidepool_palette.png")
var yellow_tidepool_palette = preload("res://assets/palettes/yellow_tidepool_palette.png")
var black_tidepool_palette = preload("res://assets/palettes/black_tidepool_palette.png")

var foggy_forest_palette = preload("res://assets/palettes/foggyforest.png")
var dream_palette = preload("res://assets/palettes/dream-haze-8-1x.png")
var rgb_palette = preload("res://assets/palettes/3bitrgb_palette.png")

onready var doorSound = get_node("DoorSound")

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
}

enum Inventory {
    GRIMOIRE,
    PET_0,
}

func getColorSuffixFromTilesetType(type):
    if type == TilesetType.DUNGEON:
        return ""
    if type == TilesetType.HOUSE:
        return "_red"
    if type == TilesetType.FOREST or type == TilesetType.BEACH or type == TilesetType.POISON_FOREST:
        return "_green"
    if type == TilesetType.ALIEN:
        return "_black"
    if type == TilesetType.DESERT:
        return "_yellow"
    if type == TilesetType.GLITCH_WORLD:
        return "_white"

var hasLoadedGame = false
var memory = {}

var activeInteractor = null
var activeThrowableObject = null
var activeThrowableObjectPath = null
var activeSavePoint = null

var isRespawning = false
var isEnteringRoom = false
var hasJustRespawned = false
var hasJustEnteredRoom = false
var respawnVarTimerHack = 0
var respawnVarTimerHackLimit = 2
var cameraRotation = 0

var pauseMoveInput = false # don't allow player physics or camera input??
var pauseGame = false
var isInventoryOpen = false

var num_cherries_eaten = 0
var num_cherries_gained = 0
var max_cherries = 5
var collectable_key_recently_got = null
var collectable_key_recently_got_timer = 0
var collectable_key_recently_got_time_limit = 40

var num_mini_crystal_cubes = 0

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

var hasGottenLevelGeode = false

func _ready():
    set_process(true)

    # somehow this gets rid of errors LOL
    if hasLoadedGame: pass
    if memory: pass
    if activeInteractor: pass
    if activeThrowableObject: pass
    if activeThrowableObjectPath: pass
    if activeSavePoint: pass
    if isRespawning: pass
    if isEnteringRoom: pass
    if cameraRotation: pass
    if pauseMoveInput: pass
    if pauseGame: pass
    if num_cherries_eaten > 0: pass
    if canGlitchScreen: pass
    if canChangeSongPitch: pass
    if crtScreenEffects: pass
    if set_camera_position_on_respawn: pass
    if hasGottenLevelGeode: pass

    memory["broom"] = true
    memory["broom_level"] = 0
    memory["nesting_doll"] = false
    memory["max_hp"] = 1
    memory["hp"] = memory["max_hp"]
    memory["hearts_recovering"] = false
    memory["max_mp"] = 0
    memory["mp"] = memory["max_mp"]
    memory["key"] = 0

func _process(delta):
    delta = delta * time_dilation_multiplier

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
            


var save_game_file = "user://savegame.save"
func saveGame():
    var save_game = File.new()
    save_game.open(save_game_file, File.WRITE)
    save_game.store_line(to_json(global.memory))
    save_game.close()

func loadGame():
    var save_game = File.new()
    if not save_game.file_exists("user://savegame.save"):
        return # Error! We don't have a save to load.
    
    # Load the file line by line and process that dictionary to restore
    # the object it represents.
    save_game.open(save_game_file, File.READ)
    
    global.memory = parse_json(save_game.get_line())
    while not save_game.eof_reached():
        # ... ??? Is this because global.memory is stored on a single line? enigmatic..
        var _current_line = parse_json(save_game.get_line())
        
    save_game.close()
    
func getNextGlitch(glitch_form):
    if glitch_form == global.GlitchForm.NORMAL: return global.GlitchForm.FLOOR
    if glitch_form == global.GlitchForm.FLOOR: return global.GlitchForm.FEATHER
    if glitch_form == global.GlitchForm.FEATHER: return global.GlitchForm.INVISIBLE
    if glitch_form == global.GlitchForm.INVISIBLE: return global.GlitchForm.LADDER
    if glitch_form == global.GlitchForm.LADDER: return global.GlitchForm.WALK_THROUGH_WALLS
    if glitch_form == global.GlitchForm.WALK_THROUGH_WALLS: return global.GlitchForm.NORMAL

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

    var x = gameMover.global_transform.origin.x
    var y = gameMover.global_transform.origin.y
    if not gameMover.has_node("CollisionShape") \
        or not gameMover.get_node("CollisionShape").shape is CylinderShape \
        or not "should_do_fallthrough_area_collision" in gameMover:
        return false
        
    # check for fallThroughSolid collision while falling
    var rb = gameMover.get_node("CollisionShape").shape.radius
    var lb = -rb
    var tb = gameMover.get_node("CollisionShape").shape.height/2
    var bb = -tb
    if gameMover.isRectColliding(
        ax + alb, ay + atb, ax + arb, ay + abb,
        x + lb, y + bb, x + rb, y + bb - 0.12
    ) and (gameMover.linear_velocity.y < 0 or (gameMover.linear_velocity.y == 0 and gameMover.glitch_form == global.GlitchForm.FLOOR)):
        gameMover.should_do_fallthrough_area_collision = true
        gameMover.fallthrough_area_collision_y = ay + atb - bb
        return true

    # the above check counts for falling down onto the fallthroughCollision,
    # but if we are already on it, we know vel.y is 0ish, and need a more constrained check
    # to see if we are still on it
    if gameMover.should_do_fallthrough_area_collision and \
        gameMover.isRectColliding(
            ax + alb, ay + atb, ax + arb, ay + abb,
            x + lb, y + bb, x + rb, y + bb - 0.12
        ):
        return true
    return false

var currLevelZone = null
const HUB_LEVEL_ZONE = "gd1" 
func tryInitializeLevelZone(levelZone):
    if not self.memory.has(levelZone):
        self.memory[levelZone] = {}
    
    if currLevelZone == HUB_LEVEL_ZONE and levelZone != HUB_LEVEL_ZONE:
        # entering the level from the hub world, restart!
        hasGottenLevelGeode = false
        self.memory[levelZone] = {}
        pass
    elif currLevelZone != HUB_LEVEL_ZONE and levelZone == HUB_LEVEL_ZONE:
        # just got back to the hub!, record the levelZone's results
        self.memory[levelZone + "_highscore"] = self.memory[levelZone]
    currLevelZone = levelZone

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

func incrementLevelZoneGlitchTiles(amt):
    incrementLevelZoneThing("num_glitch_tiles", amt)

func incrementLevelZoneSecretEggs():
    incrementLevelZoneThing("num_secret_eggs", 1)