extends "GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")

const GlitchEnemyResource = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")
const bullet_enemy_sheet = preload("res://assets/enemy_sheet.png")

enum AngelState {
    HIDDEN,
    IDLE,
    SHOOT_BULLET_WINDUP,
}
var angel_state = AngelState.HIDDEN
var angel_state_timer = 0
var angel_state_idle_time_limit = 40

var original_pos = null
var target_pos = null

var player = null
func getPlayer():
    if player == null:
        player = level.player
    return player

func _ready():
    set_process(true)
    
    if angel_state == AngelState.HIDDEN:
        myOtherSprite.visible = false
        get_node("HaloSprite").visible = false
        get_node("WingsSprite").visible = false

    original_pos = global_transform.origin
    randomizeTargetPos()
    
    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier
    secretAniPlayer.playback_speed = global.time_dilation_multiplier

    if am_i_in_range_of_player:
        if angel_state == AngelState.HIDDEN:
            if not secretAniPlayer.assigned_animation == "flickerIn":
                secretAniPlayer.play("flickerIn")
            elif not secretAniPlayer.is_playing():
                angel_state = AngelState.IDLE    
        elif angel_state == AngelState.IDLE:
            flutterAndRandomizeLocation(delta)
            
            if not secretAniPlayer.assigned_animation == "idle":
                secretAniPlayer.play("idle");
            angel_state_timer += (delta*22)
            if angel_state_timer >= angel_state_idle_time_limit:
                angel_state_timer = 0
                secretAniPlayer.clear_queue()
                secretAniPlayer.stop()
                secretAniPlayer.play("shootBulletWindup")
                angel_state = AngelState.SHOOT_BULLET_WINDUP
        elif angel_state == AngelState.SHOOT_BULLET_WINDUP:
            if not secretAniPlayer.is_playing():
                if secretAniPlayer.assigned_animation == "shootBulletWindup":
                    secretAniPlayer.clear_queue()
                    secretAniPlayer.stop()
                    secretAniPlayer.play("shootBullet")
                    spawnGlitchBullet()
                else:
                    angel_state = AngelState.IDLE
                    angel_state_timer = 0

    if am_i_dying:
        return
        
func flutterAndRandomizeLocation(delta):
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*5)
    var diff = target_pos - global_transform.origin
    var step = 0.1
    if stepify(abs(diff.x), step) == 0 and stepify(abs(diff.y), step) == 0:
        randomizeTargetPos()
        
func spawnGlitchBullet():
    var newGlitchEnemy = GlitchEnemyResource.instance()
    newGlitchEnemy.visible = true
    newGlitchEnemy.grav = 0
    newGlitchEnemy.get_node("Sprite3D").frame_delay = 0.2
    level.add_child(newGlitchEnemy)
    newGlitchEnemy.global_transform.origin = self.global_transform.origin
    var newGlitchMaterial = newGlitchEnemy.mySprite.get_material_override().duplicate()
    if newGlitchEnemy.is_in_group("sprite"):
        newGlitchEnemy.mySprite.remove_from_group("sprite")
    if newGlitchMaterial is ShaderMaterial:
        newGlitchMaterial.set_shader_param("target_palette", global.weird_base_palette)
    newGlitchEnemy.mySprite.set_material_override(newGlitchMaterial)
    
    newGlitchEnemy.mySprite.hframes = mySprite.hframes * 2
    newGlitchEnemy.mySprite.vframes = mySprite.vframes * 2
    var smallInteractionAreaCollisionShape = newGlitchEnemy.smallInteractionArea.get_node("CollisionShape")
    smallInteractionAreaCollisionShape.shape = smallInteractionAreaCollisionShape.shape.duplicate()
    smallInteractionAreaCollisionShape.shape.radius /= 2
    smallInteractionAreaCollisionShape.shape.height /= 2
    newGlitchEnemy.mySprite.material_override = newGlitchEnemy.mySprite.material_override.duplicate()
    newGlitchEnemy.mySprite.material_override.set_shader_param("texture_albedo", bullet_enemy_sheet)
    
    var bullet_speed = 10
    newGlitchEnemy.behavior_directional_bullet = true
    newGlitchEnemy.bullet_direction_vector = Vector3(
        getPlayer().global_transform.origin.x - self.global_transform.origin.x,
        getPlayer().global_transform.origin.y - self.global_transform.origin.y,
        0
    ).normalized() * bullet_speed

func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-1, 1),
        original_pos.y + rand_range(-1, 1),
        original_pos.z
    )
        
# @override
func glitchSetSpritesAndCollision():
    pass
