extends Spatial

export var should_grow = false
export var spore_on_respawn = false

var sporeRes = preload("res://sceneObjects/Environment/Spore.tscn")

onready var mySprite = get_node("Sprite3D")
onready var fallthroughSolid = get_node("FallthroughSolid")
onready var bounceSound = get_node("BounceSound")
var had_already_been_collided = false
var is_being_collided = false
var should_wiggle = false
var wiggle_timer = 0
var wiggle_time_limit = 2
var spore_origin = Vector3(0, 0, 0)

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if player == null:
    player = level.player
  return player

func _ready():
    if should_grow:
        wiggle_time_limit = 8
    spore_origin = self.global_transform.origin


func fallthroughCollisionActivate(possible_game_mover):
    if not possible_game_mover.was_on_ground and not should_wiggle:
        wiggle(possible_game_mover)
        if possible_game_mover != null and possible_game_mover == level.player and \
           level.player.nesting_doll_state == global.NestingDoll.BABY and not level.player.pressingDown():
            getPlayer().target_last_grounded_y = getPlayer().global_transform.origin.y
            var jump_val = 14
            possible_game_mover.magicJump()
            getPlayer().linear_velocity.y = jump_val
            getPlayer().lv.y = jump_val
            getPlayer().vv = jump_val
            getPlayer().applyHalfGrav = true
            getPlayer().applyHalfGravTimer = 5
            bounceSound.play()
            getPlayer().target_last_grounded_y = getPlayer().global_transform.origin.y

func wiggle(_possible_game_mover):
    should_wiggle = true
    wiggle_timer = 0
    var how_many = randi() % 2 + 2
    for _i in range(how_many):
        spawnASpore()

func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if spore_on_respawn and (global.isRespawning or global.isEnteringRoom) and not should_wiggle:
        wiggle(null)

    if should_wiggle:
        if wiggle_timer == 0:
            mySprite.global_transform.origin.y -= 0.125
        elif should_grow and wiggle_timer >= 2:
            mySprite.global_transform.origin.y += 0.125
            fallthroughSolid.global_transform.origin.y += 0.125
            spore_origin.y += 0.125
            getPlayer().global_transform.origin.y += 0.375


        wiggle_timer += (delta*22)

        if wiggle_timer >= wiggle_time_limit:
            should_grow = false
            wiggle_time_limit = 2
            should_wiggle = false
            wiggle_timer = 0
            mySprite.global_transform.origin.y += 0.125
            if should_grow:
                getPlayer().global_transform.origin.y = mySprite.global_transform.origin.y + 1
                getPlayer().magicJump()
            var _how_many = randi() % 2 + 2


func spawnASpore():
    var spore = sporeRes.instance()
    level.add_child(spore)
    spore.global_transform.origin = spore_origin
    spore.original_pos = spore_origin
    spore.randomizeTargetPos()
    spore.global_transform.origin.x += rand_range(-2.5, 2.5)
    spore.global_transform.origin.y += 1
    spore.global_transform.origin.y -= rand_range(0, .625)
    
