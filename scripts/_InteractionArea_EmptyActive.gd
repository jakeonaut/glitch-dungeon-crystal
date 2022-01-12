extends Area

onready var parent = get_parent()

func _ready():
    set_process(true)

func isActive():
    return parent.has_method("isActive") and \
           parent.isActive()
