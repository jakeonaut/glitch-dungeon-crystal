extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var aniPlayer = get_node("AnimationPlayer")
onready var transformSound = get_node("TransformSound")
onready var fadeAwaySound = get_node("FadeAwaySound")
var original_position = null
var previous_point = null
var interpolation_point = null
var t = 0
var is_active = true

var player = null
func getPlayer():
    if player == null:
        player = get_tree().get_root().get_node("Game/Viewport/level").player
    return player

func _ready():
    if self.getMyStaticLevelZoneVar():
        set_process(false)
        queue_free()
        return
    set_process(true)
    original_position = global_transform.origin
    previous_point = original_position
    interpolation_point = Vector3(original_position.x, original_position.y + 1, original_position.z)

func _process(_delta):
    pass

func isActive(_debug=false):
    return is_active and visible

func passiveActivate(_delta, is_player):
    if is_player:
        getPlayer().nullify()
        if global.memory["forget_me_not"]:
            fadeAwaySound.play()
            is_active = false
            setGlobalMemoryOfHasBeenDefeated()
            aniPlayer.stop()
            aniPlayer.clear_queue()
            aniPlayer.play("fadeAway")
            return

        if getPlayer().glitch_form != global.GlitchForm.NORMAL and global.memory["clean_crystals"] < 1 and global.memory["priestess"] == 0:
            level.uiLayer.glitchSpriteContainer.rect_scale = Vector2(1.5, 1.5)
            level.uiLayer.glitchSpriteContainer.rect_position = Vector2(300, 250)
            level.uiLayer.spellMessageTextLabel.rect_scale = Vector2(1.5, 1.5)
            level.uiLayer.spellMessageTextLabel.rect_position = Vector2(320, 250)

func setGlobalMemoryOfHasBeenDefeated():
    global.setStaticLevelZoneLevelVar(level, self, self.global_transform.origin)
