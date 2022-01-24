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
        npc.get_node("SmallInteractionArea/CollisionShape").transform.origin = Vector3(0, 0, 0)
        # this happens first...
        yield(get_tree(), "idle_frame")
        yield(get_tree(), "idle_frame")
        npc.textBox.text_final = "you made it! and my house is\na little cleaner too.. thank you!\nthat was really scary\nto reward you here is\na SCARF to keep you warm.\n but if you get hit by a glitch\nit will fall off until you respawn.."
        npc.textBox.has_been_shown = false
        npc.textBox.is_important = true
        npc.textBox.is_really_important = true
        can_complete_challenge = true
        
        level.gameCamera.how_fast_to_switch_targets = 0.1

func isActive():
    return true
