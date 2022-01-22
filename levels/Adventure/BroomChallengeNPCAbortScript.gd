extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var npc = get_node("../../..")

var doorRes = preload("res://sceneObjects/Door.tscn")
var can_complete_challenge = false

func _ready():
    pass

func activateScript():
    # IFNDEF BroomChallengeLevelScript.gd
    if can_complete_challenge:
        npc.textBox.text_final = "here's SCARF to keep you warm.\n but if you get hit by a glitch\nit will fall off until you respawn..\nstay cozy!"
    else:
        # this happens first...
        npc.textBox.text_final = "you made it! any my house is a little \ncleaner too.. thank you! to reward you here is\na SCARF to keep you warm.\n but if you get hit by a glitch\nit will fall off until you respawn.."
        npc.get_node("SmallInteractionArea/CollisionShape").transform.origin = Vector3(0, 0, 0)
        can_complete_challenge = true
        
        # Wait two frames so that level.gameCamera doesn't set its own variable after
        yield(get_tree(), "idle_frame")
        yield(get_tree(), "idle_frame")
        level.gameCamera.how_fast_to_switch_targets = 0.1

func isActive():
    return true
