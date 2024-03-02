extends Area

onready var parent = get_parent()

func _ready():
    set_process(true)

func isActive(debug=false):
    return parent.has_method("isActive") and \
           parent.isActive()
