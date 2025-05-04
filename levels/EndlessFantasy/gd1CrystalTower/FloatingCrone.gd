extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  if global.memory["priestess"] > 0:
    queue_free()
    return
  set_process(true)
  

var vv = 0
func _process(delta):
  vv += 2*delta
  if vv >= 5:
    vv = 5
  global_transform.origin.y += vv*delta
