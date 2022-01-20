extends Spatial


onready var geodeSprite = get_node("GeodeSprite")
onready var geodeFaceSprite = get_node("GeodeFaceSprite")
onready var shineSprite = get_node("ShineSprite")

var geodeFaceOpacityA = 0.5
var geodeFaceOpacityB = 0.75
var geodeFaceTargetOpacity = 0.75


func _ready():
    set_process(true)


func _process(_delta):
    pass
