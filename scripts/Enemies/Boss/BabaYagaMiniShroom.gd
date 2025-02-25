extends Spatial

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var eyeSpawner = get_node("EyeSpawner")
var weakEyeRes = preload("res://sceneObjects/Enemies/WeakEye.tscn")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


func spawnWeakEye():
  return

  # var newEye = weakEyeRes.instance()
  # newEye.is_fast = true
  # level.add_child(newEye)
  # newEye.global_transform.origin = eyeSpawner.global_transform.origin
  # newEye.global_transform.origin.z = 0
  # newEye.global_rotation = self.global_rotation
  # secretAniPlayer.stop()
  # secretAniPlayer.play("waitForWeakEye")
  # secretAniPlayer.queue("wither")