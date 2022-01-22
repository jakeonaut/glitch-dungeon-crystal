extends Spatial

var id = null
onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false
export var should_lock = false
# String is a path to a file.
export(String, FILE) var path

export var is_passive = false
export var is_vertical = false

onready var doorCloseSound = get_node("DoorCloseSound")
onready var lockedSound = get_node("LockedSound")

onready var landing = get_node("landing")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var hasPlayedDoorSound = false

var player = null
func getPlayer():
    if player == null:
        player = level.player
    return player

func _ready():
    landing.visible = false

    if is_passive:
        visible = false

    id = self.generateId()

    animationPlayer.clear_queue()
    animationPlayer.stop()
    if is_locked:
        animationPlayer.play("locked")
    elif should_lock:
        is_locked = true
        doorCloseSound.play()
        animationPlayer.queue("doorOpen")
        animationPlayer.queue("doorClose")
        animationPlayer.queue("locked")
    else: 
        animationPlayer.play("doorOpen")

func isActive():
    return true

func generateId():
    return get_name()

func activate():
    if not is_passive:
        if not is_locked:
            goThroughDoor()
        else:
            if not lockedSound.is_playing():
                lockedSound.play()

func passiveActivate(delta):
    if is_passive:
        goThroughDoor()
    else:
        getPlayer().showInteractPrompt()
        
func justStopPassiveActivate():
    getPlayer().hideInteractPrompt()

func goThroughDoor(start_of_game = false):
    if not global.isRespawning and not hasPlayedDoorSound:
        global.doorSound.play()
        hasPlayedDoorSound = true

    global.activeInteractor = null
    if start_of_game:
        transition.long_fade_to(self.path)
        return
        
    global.memory["cameraSize"] = level.gameCamera.initial_size
    global.memory["lastDoor"] = id
    global.memory["roomPath"] = level.getLevelName()
    global.pauseGame = true

    global.isRespawning = true
    if is_passive:
        if is_vertical:
            global.memory["feather_jump_timer"] = getPlayer().feather_jump_timer
        else:
            global.memory["player_y_offset"] = getPlayer().global_transform.origin.y - global_transform.origin.y - 1
        global.memory["linear_velocity"] = getPlayer().linear_velocity
        transition.fade_to(self.path)
    else:
        transition.long_fade_to(self.path)

func land():
    global.pauseGame = false
    # TODO(jaketrower): Oh...
    global.memory.erase("active_save_point_x")
    global.memory.erase("active_save_point_y")
    global.memory.erase("active_save_point_z")
    
    getPlayer().global_transform.origin.x = landing.global_transform.origin.x
    getPlayer().global_transform.origin.y = landing.global_transform.origin.y

    if is_passive:
        if global.memory.has("player_y_offset"):
            getPlayer().global_transform.origin.y += global.memory["player_y_offset"]
            global.memory.erase("player_y_offset")
        if global.memory.has("feather_jump_timer"):
            getPlayer().feather_jump_timer = global.memory["feather_jump_timer"]
            global.memory.erase("feather_jump_timer")
        if global.memory.has("linear_velocity"):
            getPlayer().linear_velocity = global.memory["linear_velocity"]
            global.memory.erase("linear_velocity")
