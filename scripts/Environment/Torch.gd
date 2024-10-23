extends Spatial

onready var meshInstance = get_node("MeshInstance")

enum GlowDir {
  SHRINKING,
  GROWING,
}
var glow_dir = GlowDir.SHRINKING

func _process(delta):
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
