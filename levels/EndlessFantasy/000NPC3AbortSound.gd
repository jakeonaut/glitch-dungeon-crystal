extends AudioStreamPlayer

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var NPC3 = get_node("../../..")
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")

func _ready():
    var memory = global.getStaticLevelZoneLevelVar(level, self.name)
    if memory == null:
        return
    elif not memory:
        doActivateScriptStuff()
    elif memory:
        NPC3.queue_free()
        

var has_talked = false
func activateScript():
    if not has_talked:
        doActivateScriptStuff()
    else:
        summonSmokeClouds(NPC3, 3, true, true)
        global.activeInteractor = null
        NPC3.queue_free()
        global.setStaticLevelZoneLevelVar(level, self.name, true)

func doActivateScriptStuff():
    NPC3.get_node("NPC TextBox").bbText = " truthfully, i have nothing\nmore to say"
    NPC3.get_node("NPC TextBox").setVars()
    global.setStaticLevelZoneLevelVar(level, self.name, false)
    has_talked = true
    
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass

func isActive():
    # OVERRIDE ME... if you dare
    return true


func summonSmokeClouds(npc, num_clouds, play_sound = false, is_glitchy = false):
    for _i in range(num_clouds):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = npc.global_transform.origin.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = npc.global_transform.origin.y + rand_range(1, 2)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        if play_sound:
            newSmokeCloud.get_node("CleanGlitchSound").play()
            newSmokeCloud.get_node("CleanGlitchSound").pitch_scale = rand_range(0.8, 1.2)
            play_sound = false
        if is_glitchy:
            var new_material = newSmokeCloud.get_material_override().duplicate()
            new_material.set_shader_param("enable_glitch", "true")
            new_material.set_shader_param("target_palette", global.weird_base_palette)
            newSmokeCloud.set_material_override(new_material.duplicate())
