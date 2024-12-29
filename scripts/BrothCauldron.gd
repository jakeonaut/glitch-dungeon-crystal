extends Spatial

# String is a path to a file.
export(String, FILE) var path

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var aniPlayer = get_node("AnimationPlayer")
onready var mySprite = get_node("Sprite3D")
var smokeFumeRes = preload("res://sceneObjects/SmokeFume.tscn")
var smoke_fume_timer = 0
var smoke_fume_time_limit = 15
export var is_active = false

func _ready():
  set_process(true)
  mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
  if is_active:
    aniPlayer.play("active")
    smoke_fume_time_limit = 5

  smoke_fume_timer += (delta*11)
  if smoke_fume_timer >= smoke_fume_time_limit:
    smoke_fume_timer = 0
    var newSmokeFume = smokeFumeRes.instance()
    newSmokeFume.fade_out_opacity = true
    level.add_child(newSmokeFume)
    newSmokeFume.global_transform.origin = self.global_transform.origin
    newSmokeFume.global_transform.origin.y += 1.4
    newSmokeFume.global_transform.origin.x += rand_range(-1.0, 1.0)
    newSmokeFume.target_y = newSmokeFume.global_transform.origin.y + rand_range(1.0, 2.0)
    if is_active:
      newSmokeFume.material_override.set_shader_param("target_palette", global.yellow_palette)
      newSmokeFume.material_override.set_shader_param("offset", 8)
    
