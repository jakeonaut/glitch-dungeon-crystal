extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")

var doorRes = preload("res://sceneObjects/Door.tscn")

func _ready():
    pass

func activateScript():
    global.doorSound.play()
    var newDoor = doorRes.instance()
    newDoor.path = "res://levels/Adventure/SpellbookIntro.tscn"
    newDoor.visible = false
    level.add_child(newDoor)
    newDoor.global_transform.origin = npc.global_transform.origin
    newDoor.global_transform.origin.y -= 1.75
    
    # i love when nodes have to know about other nodes intimates... gossip girls much
    global.activeInteractor = null
    newDoor.canPlayDoorSound = false
    newDoor.goThroughDoor()

func isActive(_debug=false):
    return true
