extends KinematicBody

onready var textBox = get_node("Object TextBox").get_node("TextBox")

var player = null
func getPlayer():
    if player == null:
        player = get_tree().get_root().get_node("level").player
    return player

func _ready():
    set_process_input(true)

func _input(event):
    if textBox.visible \
    and event is InputEventMouseButton \
    and event.button_index == BUTTON_LEFT \
    and event.pressed:
        activate()


func isActive():
    return visible

func activate():
    if global.activeInteractor == null:
        global.activeInteractor = textBox
        textBox.interact()
        
        match get_node("Sprite3D").frame:
            0: getPlayer().wearCostume("normal")
            1: getPlayer().wearCostume("moth")
            # 2:
            3: getPlayer().wearCostume("bugcatcher")
            4: getPlayer().wearCostume("cleric")
            # 5: 
            6: getPlayer().wearCostume("luckycat")
            7: getPlayer().wearCostume("nightgown")
        # visible = false