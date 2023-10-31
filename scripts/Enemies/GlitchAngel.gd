extends "GlitchEnemy.gd"

onready var playerActivationAreaCollisionShape = get_node("PlayerActivationArea/CollisionShape")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")

const NullificationBulletResource = preload("res://sceneObjects/SpellsTreasureCollectables/NullificationBullet.tscn")

enum AngelState {
    HIDDEN,
    IDLE,
    SHOOT_BULLET_WINDUP,
}
var angel_state = AngelState.IDLE
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
    
    # flightPathAniPlayer.play("flySquare")
    if angel_state == AngelState.HIDDEN:
        myOtherSprite.visible = false
        get_node("HaloSprite").visible = false
        get_node("WingsSprite").visible = false
    
    mySprite.material_override = mySprite.material_override.duplicate() # make unique
    myOtherSprite.material_override = myOtherSprite.material_override.duplicate() # make unique

    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = spawn_origin
    randomizeTargetPos()

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
                    spawnNullificationBullet()
                else:
                    angel_state = AngelState.IDLE
                    angel_state_timer = 0

    if am_i_dying:
        return
        
func flutterAndRandomizeLocation(delta):
    global_transform.origin = moveToward2D(global_transform.origin, target_pos, delta * 22)
    if compare2D(global_transform.origin, target_pos, 0.1):
        randomizeTargetPos()
        
func spawnNullificationBullet():
    var newNullBullet = NullificationBulletResource.instance()
    level.add_child(newNullBullet)
    newNullBullet.global_transform.origin = self.global_transform.origin
    
    var bullet_speed = 10
    newNullBullet.bullet_direction_vector = Vector3(
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
