extends Spatial

onready var meshInstance = get_node("MeshInstance")
onready var mySprite = get_node("Sprite3D")

enum GlowDir {
  SHRINKING,
  GROWING,
}
var glow_dir = GlowDir.SHRINKING

func _ready():
  mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
  if is_extinguished:
    return
  if glow_dir == GlowDir.SHRINKING:
    meshInstance.scale.x -= 0.35 * delta
    meshInstance.scale.y = meshInstance.scale.x
    meshInstance.scale.z = meshInstance.scale.x
    if meshInstance.scale.x <= 0.75:
      glow_dir = GlowDir.GROWING
  elif glow_dir == GlowDir.GROWING:
    meshInstance.scale.x += 0.35 * delta
    meshInstance.scale.y = meshInstance.scale.x
    meshInstance.scale.z = meshInstance.scale.x
    if meshInstance.scale.x >= 1:
      glow_dir = GlowDir.SHRINKING

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var extinguishSound = get_node("ExtinguishSound")
var extinguishedTorchSheet = preload("res://assets/torch_extinguished.png")
var is_extinguished = false
func isActive():
  return visible and not is_extinguished

func getSmacked(_broom_origin):
  print("smack torch")
  if is_extinguished:
    return
  is_extinguished =  true
  level.summonSmokeClouds(self.global_transform.origin, 2)
  extinguishSound.pitch_scale = rand_range(0.9, 1.1)
  extinguishSound.play()
  mySprite.material_override.set_shader_param("texture_albedo", extinguishedTorchSheet)
  meshInstance.visible = false
