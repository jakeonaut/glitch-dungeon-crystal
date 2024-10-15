extends Spatial

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var transformSound = get_node("TransformSound")
onready var fadeAwaySound = get_node("FadeAwaySound")
var nullSmokeCloudRes = preload("res://sceneObjects/NullSmokeCloud.tscn")
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

var smoke_spawn_timer = 0
var smoke_spawn_time_limit = 5
func _process(delta):
    smoke_spawn_timer += (delta*11)
    if smoke_spawn_timer >= smoke_spawn_time_limit:
      smoke_spawn_timer = 0
      var newNullSmoke = nullSmokeCloudRes.instance()
      newNullSmoke.opacity = rand_range(0.6, 0.4)
      newNullSmoke.y_speed = rand_range(0.5, 1)
      level.add_child(newNullSmoke)
      newNullSmoke.global_transform.origin.x = global_transform.origin.x + rand_range(-1, 1)
      newNullSmoke.global_transform.origin.y = global_transform.origin.y + rand_range(-1, 1)

func isActive(_debug=false):
    return is_active and visible

func passiveActivate(_delta, is_player):
    if is_player:
        getPlayer().nullify()
        if global.memory["forget_me_not"]:
            fadeAwaySound.play()
            is_active = false
            setGlobalMemoryOfHasBeenDefeated()
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
