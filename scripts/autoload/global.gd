extends Node

var grey_palette = preload("res://assets/palettes/grey_palette.png")
var red_palette = preload("res://assets/palettes/red_palette.png")
var green_palette = preload("res://assets/palettes/green_palette.png")
var black_palette = preload("res://assets/palettes/black_palette.png")
var yellow_palette = preload("res://assets/palettes/yellow_palette.png")
var white_palette = preload("res://assets/palettes/white_palette.png")
var weird_base_palette = preload("res://assets/palettes/weird_base_palette.png")

var dark_grey_palette = preload("res://assets/palettes/dark_grey_palette.png")
var dark_red_palette = preload("res://assets/palettes/dark_red_palette.png")
var dark_green_palette = preload("res://assets/palettes/dark_green_palette.png")
var dark_black_palette = preload("res://assets/palettes/dark_black_palette.png")
var dark_yellow_palette = preload("res://assets/palettes/dark_yellow_palette.png")
var dark_white_palette = preload("res://assets/palettes/dark_white_palette.png")

var grey_palette_town = preload("res://assets/palettes/grey_town_palette.png")
var green_palette_town = preload("res://assets/palettes/green_palette_town.png")
var black_palette_town = preload("res://assets/palettes/black_palette_town.png")

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
    GLITCH_WORLD
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
