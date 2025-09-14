extends Spatial

onready var mySprite = get_node("Sprite3D")
onready var fallthroughSolid = get_node("FallthroughSolid")
onready var dontMoveSound = get_node("DontMoveSound")
onready var activateSound = get_node("ActivateSound")
var had_already_been_collided = false
var is_being_collided = false
var should_wiggle = false
var wiggle_timer = 0
var wiggle_time_limit = 2
var has_been_activated = false

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if player == null:
    player = level.player
  return player

func fallthroughCollisionActivate(possible_game_mover):
    possible_game_mover.landed()
    if not possible_game_mover.was_on_ground and not should_wiggle:
        wiggle(possible_game_mover)
            

func wiggle(possible_game_mover):
    if possible_game_mover != null:
        if possible_game_mover == level.player:
            should_wiggle = true
            wiggle_timer = 0
            dontMoveSound.play()
        elif possible_game_mover.is_in_group("grandma_statue"):
            activateSound.play()
            has_been_activated = true
            level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
            mySprite.visible = false
    

var SHIFT_AMT = 0.0625
func _process(delta):
    delta = delta * global.time_dilation_multiplier

    if should_wiggle:
        if wiggle_timer == 0:
            mySprite.global_transform.origin.y -= SHIFT_AMT
        wiggle_timer += (delta*22)
        if wiggle_timer >= wiggle_time_limit:
            wiggle_time_limit = 2
            should_wiggle = false
            wiggle_timer = 0
            mySprite.global_transform.origin.y += SHIFT_AMT