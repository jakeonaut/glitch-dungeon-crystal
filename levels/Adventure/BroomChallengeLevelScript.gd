extends "res://scripts/levelScript.gd"

# @override
func setUpRoomInitializationOverride():
    # IFNDEF BroomChallengeNPCAbortScript.gd
    # if I've already completed the challenge...
    if global.memory.has("broomChallenge") and global.memory["broomChallenge"]:
        get_node("NPC").textBox.text_final = "here's SCARF to keep you warm.\n but if you get hit by a glitch\nit will fall off until you respawn..\nstay cozy!"
        get_node("NPC").get_node("SmallInteractionArea/CollisionShape").transform.origin = Vector3(0, 0, 0)
        get_node("NPC").textBox.showTextbox()
    else:
        self.gameCamera.how_fast_to_switch_targets = 0.5
