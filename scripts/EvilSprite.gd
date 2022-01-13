extends "NPC.gd"

enum AttackState {
    IDLE,
    NOTICED_PLAYER,
    WIND_UP,
    CAST_GLITCH,
    COOLDOWN
}
var attackState = AttackState.IDLE
var attackStateTimer = 0
var attackStateNoticePlayerTimeLimit = 10
var attackStateWindUpTimeLimit = 10
var attackStateCastGlitchTimeLimit = 20
var attackStateRecoveryTimeLimit = 30

onready var castGlitchSound = get_node("CastGlitchSound")
onready var noticeSound = get_node("NoticeSound")
onready var windUpSound = get_node("WindUpSound")
onready var smallerInteractionArea = get_node("SmallerInteractionArea")

onready var sparkleSprite = get_node("SparkleSprite")
var spawn_timer = 0
var spawn_time_limit = 5

export var behavior_summon_glitch = true

const GlitchEnemyResource = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")

var player = null
func getPlayer():
    if player == null:
        player = level.player
    return player

func _ready():
    # .ready() implicit
    set_process(true)
    set_physics_process(true)

    is_active = false

func passiveActivate(delta):
    .passiveActivate(delta) # let NPC.gd handle facing player... but is_active = false so no textbox

    spawn_timer += (delta*22)
    if spawn_timer >= spawn_time_limit:
        var children = self.get_children()
        var num_children = 0
        for i in children:
            num_children += 1

        if num_children < 20:
            var newSprite = sparkleSprite.duplicate()
            newSprite.should_fizzle_out = true
            newSprite.visible = true
            newSprite.transform.origin = Vector3(
                stepify(rand_range(-1.0, 1.0), 0.12),
                stepify(rand_range(0.5, 1.5), 0.12),
                0
            )
            newSprite.updateBaseFrame(0, 0)
            newSprite.max_frames = 2
            add_child(newSprite)
            spawn_timer = 0

    if attackState == AttackState.IDLE:
        noticeSound.play()
        attackState = AttackState.NOTICED_PLAYER
        mySprite.frame_delay = 0.1
        mySprite.should_randomize_frame_delay = false
    elif attackState == AttackState.NOTICED_PLAYER:
        attackStateTimer += (delta*22)
        if attackStateTimer >= attackStateNoticePlayerTimeLimit:
            windUpSound.play()
            attackStateTimer = 0
            attackState = AttackState.WIND_UP
            mySprite.frame_delay = 0.8
            var my_material = mySprite.get_material_override()
            if my_material is ShaderMaterial:
                my_material.set_shader_param("enable_palette_cycle", true)

func stopPassiveActivate():
    .stopPassiveActivate()
    if attackState == AttackState.IDLE or attackState == AttackState.NOTICED_PLAYER:
        resetStateToIdle()

func resetStateToIdle():
    if attackState != AttackState.IDLE:
        attackState = AttackState.IDLE
        attackStateTimer = 0
        smallerInteractionArea.remove_from_group("enemies")
        mySprite.frame_delay = 1.4
        mySprite.should_randomize_frame_delay = true
        var my_material = mySprite.get_material_override().duplicate()
        if my_material is ShaderMaterial:
            my_material.set_shader_param("enable_glitch", false)
            my_material.set_shader_param("enable_palette_cycle", false)
        mySprite.set_material_override(my_material)

func _process(delta):
    # this state should be handled in the process event instead of passiveActivate
    # because if the player leaves the detection radius while we're casting a glitch
    # we still want to cast it and start "recovery"
    if attackState == AttackState.WIND_UP:
        attackStateTimer += (delta*22)
        if attackStateTimer >= attackStateWindUpTimeLimit:
            attackStateTimer = 0
            attackState = AttackState.CAST_GLITCH
            smallerInteractionArea.add_to_group("enemies")
            var my_material = mySprite.get_material_override().duplicate()
            if my_material is ShaderMaterial:
                my_material.set_shader_param("enable_glitch", true)
                my_material.set_shader_param("enable_palette_cycle", false)
            mySprite.set_material_override(my_material)

            castGlitchSound.play()
            # spawn a baby glitch that will evolve to a normal one that should fizzle out
            if behavior_summon_glitch:
                var newGlitchEnemy = GlitchEnemyResource.instance()
                newGlitchEnemy.visible = true
                newGlitchEnemy.grav = 0
                newGlitchEnemy.get_node("Sprite3D").frame_delay = 0.1
                newGlitchEnemy.behavior_evolve = true
                newGlitchEnemy.behavior_fizzle_out_after_evolve = true
                self.add_child(newGlitchEnemy)
                newGlitchEnemy.global_transform.origin = getPlayer().global_transform.origin
    elif attackState == AttackState.CAST_GLITCH:
        attackStateTimer += (delta*22)
        if attackStateTimer >= attackStateCastGlitchTimeLimit:
            attackStateTimer = 0
            attackState = AttackState.COOLDOWN
            smallerInteractionArea.remove_from_group("enemies")
            var my_material = mySprite.get_material_override().duplicate()
            if my_material is ShaderMaterial:
                my_material.set_shader_param("enable_glitch", false)
            mySprite.set_material_override(my_material)
    elif attackState == AttackState.COOLDOWN:
        attackStateTimer += (delta*22)
        if attackStateTimer >= attackStateRecoveryTimeLimit:
            resetStateToIdle()
