extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var aniPlayer = get_node("AnimationPlayer")
onready var transformSound = get_node("TransformSound")
onready var fadeAwaySound = get_node("FadeAwaySound")
onready var sprite3D1 = get_node("Sprite3D")
onready var sprite3D2 = get_node("Sprite3D2")
onready var sprite3D3 = get_node("Sprite3D3")
onready var sprite3D4 = get_node("Sprite3D4")
onready var sprite3D5 = get_node("Sprite3D5")
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
    var newMaterial = sprite3D1.material_override.duplicate()
    sprite3D1.material_override = newMaterial
    sprite3D2.material_override = newMaterial
    sprite3D3.material_override = newMaterial
    sprite3D4.material_override = newMaterial
    sprite3D5.material_override = newMaterial

func _process(_delta):
    pass

func isActive(_debug=false):
    return is_active and visible

func passiveActivate(_delta, is_player, _is_local_broom = false):
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

var staticLevelZoneVar = null
func getMyStaticLevelZoneVar(refresh_if_null = false):
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if staticLevelZoneVar == null or refresh_if_null:
        staticLevelZoneVar = global.getStaticLevelZoneLevelVar(level, self)
    return staticLevelZoneVar
