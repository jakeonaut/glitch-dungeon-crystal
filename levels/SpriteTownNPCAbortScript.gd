extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")

var doorRes = preload("res://sceneObjects/Door.tscn")

func _ready():
    pass

func activateScript():
    # IFNDEF SpriteTownLevelScript.gd
    if global.memory.has("broom"):
        global.doorSound.play()
        var newDoor = doorRes.instance()
        newDoor.visible = false
        level.add_child(newDoor)
        newDoor.global_transform.origin = npc.global_transform.origin
        newDoor.global_transform.origin.y -= 1.75
        
        # i love when nodes have to know about other nodes intimates... gossip girls much
        global.activeInteractor = null
        level.gameCamera.actual_target = level.gameCamera.initial_target
        npc.queue_free()
    else:
        npc.textBox.text_final = "•maybe I could teach you\nsome time... if you find a\nBROOM or FISHING ROD"

func isActive(debug=false):
    return true
