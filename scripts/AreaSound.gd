extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
export var repeat = true
export var max_dist = 20

onready var collisionShape = get_node("../Area/CollisionShape") if has_node("../Area/CollisionShape") else null

var max_vol = 0
func _ready():
  set_process(true)
  max_vol = self.volume_db

func _process(delta):
  if repeat and not self.is_playing() and not self.stream_paused:
    self.play()

  if collisionShape != null:
    var x = collisionShape.global_transform.origin.x
    var y = collisionShape.global_transform.origin.y
    var tb = y + collisionShape.shape.extents.y/2*collisionShape.scale.y
    var bb = y - collisionShape.shape.extents.y/2*collisionShape.scale.y
    var lb = x - collisionShape.shape.extents.x/2*collisionShape.scale.x
    var rb = x + collisionShape.shape.extents.x/2*collisionShape.scale.x

    var px = level.player.global_transform.origin.x
    var py = level.player.global_transform.origin.y

    var effective_x = 0
    var effective_y = 0
    if px < rb and px > lb:
      effective_x = px
    elif px < lb:
      effective_x = lb
    else:
      effective_x = rb

    if py < tb and py > bb:
      effective_y = py
    elif py < bb:
      effective_y = bb
    else:
      effective_y = tb

    var dist = Vector2(px, py).distance_to(Vector2(effective_x, effective_y))
    if dist >= max_dist:
      self.stream_paused = true
    else:
      self.stream_paused = false
      var calculated_vol = max_vol - dist
      self.volume_db = calculated_vol


