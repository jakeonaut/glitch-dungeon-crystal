extends Spatial

var has_been_smacked = false

func _ready():
    set_process(true)

func _process(delta):
    if has_been_smacked:
        self.rotation_degrees.y += (delta * 11)


func isActive():
    return visible and not has_been_smacked

func activate():
    has_been_smacked = true
