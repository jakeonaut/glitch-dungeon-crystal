extends Spatial

var has_been_smacked = false
var rot_amount = 100
var rot_amount_max = 200
onready var cubeContainer = get_node("CubeContainer")
onready var aniPlayer = get_node("AnimationPlayer")
onready var npc = get_node("NPC")
onready var getHitSound = get_node("GetHitSound")
onready var getHitSound2 = get_node("GetHitSound2")
var can_do_my_power = true

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

func _ready():
    set_process(true)

func _process(delta):
    if not can_do_my_power:
        return

    if not global.hasGottenLevelGeode:
        if has_been_smacked:
            self.rotation_degrees.y -= (delta * rot_amount)
            rot_amount += (delta * 33)
            if rot_amount >= rot_amount_max:
                global.hasGottenLevelGeode = true
                aniPlayer.play("explode")
    elif global.pauseGame:
        if rot_amount > 50:
            rot_amount -= (delta * 55)
            self.rotation_degrees.y -= (delta * rot_amount)
            self.global_transform.origin.y += (delta * 1)
        else:
            self.rotation_degrees.y = 0 
            global.pauseGame = false
            npc.grav = 30
            npc.mySprite.material_override.set_shader_param("enable_palette_cycle", false)
            npc.mySprite.material_override.set_shader_param("opacity", 1.0)
            npc.mySprite.max_frames = 2
            npc.is_active = true
            can_do_my_power = false



func isActive():
    return visible and not has_been_smacked

func activate():
    has_been_smacked = true
    global.pauseGame = true
    musicPlayer.stopAll()
    getHitSound.play()
    getHitSound2.play()

    level.get_node("SavePoint").passiveActivate(0)
    # TODO(jaketrower): Make more generic, this is specific to fishingVillage
    level.get_node("NPC").queue_free()