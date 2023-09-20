extends Spatial

onready var aniPlayer = get_node("AnimationPlayer")
onready var player = get_node("../Player")
onready var bonkSound = get_node("BonkSound")
var has_been_hit = false

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
  for child in self.get_foreign_children():
    child.visible = false

func get_foreign_children():
  return self.get_children().slice(5, self.get_child_count())
  
func isActive():
  return not has_been_hit
  
func passiveActivate(_delta, _is_player):
  if not has_been_hit:
    if (not player.on_ground) or player.justPressedJump():
      aniPlayer.play("hit")
      performSpawn()
    # elif player.linear_velocity.y > 0:
    #   aniPlayer.play("hitDown")
    #   performSpawn()
    

func performSpawn():
  bonkSound.play()
  summonSmokeClouds(5)
  has_been_hit = true
  for child in self.get_foreign_children():
    child.visible = true
    if child.has_method("passiveActivate"):
        child.passiveActivate(33, true)
  
func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
  for _i in range(num_clouds):
    var newSmokeCloud = smokeCloudRes.instance()
    level.add_child(newSmokeCloud)
    newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
    newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(1, 2)
    newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
    if play_sound:
      newSmokeCloud.tryPlaySound()
      play_sound = false
    if is_glitchy:
      pass
      # TODO(jaketrower): testing performance # 
      # var new_material = newSmokeCloud.get_material_override().duplicate()
      # new_material.set_shader_param("enable_glitch", "true")
      # new_material.set_shader_param("target_palette", global.weird_base_palette)
      # newSmokeCloud.set_material_override(new_material.duplicate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
# pass
