extends AudioStreamPlayer


var savePoint = preload("res://sceneObjects/SavePoint.tscn")
var new_self = null

var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")

func _ready():
    pass
    
func preActivateScript():
    var npc = get_node("../../..")
    var material = npc.mySprite.get_material_override()
    material.set_shader_param("enable_palette_cycle", true)
    
    new_self = savePoint.instance()
    new_self.global_transform.origin = npc.global_transform.origin
    npc.get_parent().add_child(new_self)
    new_self.get_node("TriangleContainer").visible = false
    new_self.get_node("Sprite3D2").visible = false
    new_self.animation_speed_multiplier = 0.3
    new_self.passiveActivate(0)

func activateScript():
    var npc = get_node("../../..")
    if npc.has_node("../GlitchEnemy13"):
        npc.mySprite.visible = false
        npc.can_activate = false
        npc.is_active = false
        npc.get_node("../Player").glitch_death_timer = 0
        musicPlayer.changeSongPitch(0.5)
        npc.get_node("../GlitchEnemy13").visible = false

        var newSpawnGlitchEffect = spawnGlitchEffectRes.instance()
        npc.add_child(newSpawnGlitchEffect)
        
    else:
        npc.textBox.text_final = "hey... thanks for helping me\ni still need to recover my strength..\n\nstrength st r enth"

func isActive():
    # OVERRIDE ME... if you dare
    return true
