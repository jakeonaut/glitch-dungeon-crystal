extends "res://scripts/levelScript.gd"

var doorRes = preload("res://sceneObjects/Door.tscn")

# @override
func overrideLevelRespawnEvent():
    musicPlayer.changeSongPitch(0.5)

# @override
func setUpRoomInitializationOverride():
    # IFNDEF HubWorld0NPCAbortScript.gd
    # i love when nodes have to know about other nodes intimates... gossip girls much
    if global.memory.has("talkedToHubWorld0Wizard"):
        var newDoor = doorRes.instance()
        newDoor.path = "res://levels/SpriteTown/SpriteTownWelcome.tscn"
        newDoor.visible = false
        self.add_child(newDoor)
        newDoor.global_transform.origin = get_node("NPC").global_transform.origin
        newDoor.global_transform.origin.y -= 1.75
        
        # i love when nodes have to know about other nodes intimates... gossip girls much
        if "HubWorld1" in global.memory["roomPath"]:
            newDoor.land()
        get_node("NPC").queue_free()
