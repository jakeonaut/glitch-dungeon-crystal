extends Node

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

var tidepool_palette = preload("res://assets/palettes/tidepool_palette.png")
var green_tidepool_palette = preload("res://assets/palettes/green_tidepool_palette.png")
var red_tidepool_palette = preload("res://assets/palettes/red_tidepool_palette.png")
var yellow_tidepool_palette = preload("res://assets/palettes/yellow_tidepool_palette.png")
var black_tidepool_palette = preload("res://assets/palettes/black_tidepool_palette.png")

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
}

var hasLoadedGame = false
var memory = {}

var activeInteractor = null
var activeThrowableObject = null
var activeThrowableObjectPath = null
var activeSavePoint = null

var isRespawning = false
var cameraRotation = 0

var pauseMoveInput = false # don't allow player physics or camera input??
var pauseGame = false   

var can_broom = true
var num_cherries_eaten = 0
var max_cherries = 5

var canGlitchScreen = true
var canChangeSongPitch = true
var crtScreenEffects = true

var time_dilation_multiplier = 1.0

func _ready():

    # somehow this gets rid of errors LOL
    if hasLoadedGame: pass
    if memory: pass
    if activeInteractor: pass
    if activeThrowableObject: pass
    if activeThrowableObjectPath: pass
    if activeSavePoint: pass
    if isRespawning: pass
    if cameraRotation: pass
    if pauseMoveInput: pass
    if pauseGame: pass
    if can_broom: pass
    if num_cherries_eaten > 0: pass
    if canGlitchScreen: pass
    if canChangeSongPitch: pass
    if crtScreenEffects: pass

    memory["total_hearts"] = 1
    memory["hearts"] = 1
    memory["hearts_recovering"] = false


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
        var current_line = parse_json(save_game.get_line())
        
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
func doFallthroughObjectCollision(gameMover, area, debug = false):
    if area.get_node("..").has_method("fallthroughCollisionActivate"):
        area.get_node("..").fallthroughCollisionActivate()

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
        if debug:
            print(
                str(not gameMover.has_node("CollisionShape")) + ", " +
                str(not gameMover.get_node("CollisionShape").shape is CylinderShape)
                + ", " + str(not "should_do_fallthrough_area_collision" in gameMover)
            )
            print(gameMover.get_node("CollisionShape"))
            print(gameMover.get_node("CollisionShape").shape is CylinderShape)
        return false
        
    var rb = gameMover.get_node("CollisionShape").shape.radius
    var lb = -rb
    var tb = gameMover.get_node("CollisionShape").shape.height/2
    var bb = -tb
    if gameMover.isRectColliding(
        ax + alb, ay + atb, ax + arb, ay + abb,
        x + lb, y + bb, x + rb, y + bb - 0.12
    ) and gameMover.linear_velocity.y < 0:
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
