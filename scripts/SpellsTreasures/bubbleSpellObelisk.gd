extends Spatial

onready var collectSound = get_node("CollectSound")
onready var mySprite = get_node("Sprite3D")
onready var sparkleSprite = get_node("SparkleSprite3D") if has_node("SparkleSprite3D") else null
var spawn_timer = 0
var spawn_time_limit = 5
var num_sparkles_spawned = 0
var num_sparkles_spawned_limit = 5
var is_active = true
var is_spawning = false

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

func _ready():
  set_process(true)

func _process(delta):
  delta = delta * global.time_dilation_multiplier

  if num_sparkles_spawned < num_sparkles_spawned_limit and sparkleSprite != null:
    spawn_timer += (delta*22)
    if spawn_timer >= spawn_time_limit:
      var newSprite = sparkleSprite.duplicate()
      newSprite.should_fizzle_out = true
      newSprite.visible = true
      newSprite.transform.origin = Vector3(
          stepify(rand_range(-1.0, 1.0), 0.125),
          stepify(rand_range(0.5, 1.5), 0.125),
          0
      )
      newSprite.updateBaseFrame(0, 0)
      newSprite.max_frames = 2
      add_child(newSprite)
      spawn_timer = 0
      num_sparkles_spawned += 1

  if is_spawning:
    processBubbleLogic(delta)
  else:
    bubbleSpawnTimer = 0

var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")
var bubbleSpawnTimer = 0
var bubbleSpawnTimeLimit = 5
func processBubbleLogic(delta):
  bubbleSpawnTimer += (delta * 22)
  if bubbleSpawnTimer >= bubbleSpawnTimeLimit:
    bubbleSpawnTimer = 0
    summonBubble()

func summonBubble():
  # var x_diff_start = 2
  # var x_diff_target = 5
  # if mySprite.flip_h:
  #   x_diff_start *= -1
  #   x_diff_target *= -1

  var bubble = bubbleRes.instance()
  level.add_child(bubble)
  bubble.x_diff_max = 1
  bubble.global_transform.origin = self.global_transform.origin
  # bubble.global_transform.origin.x += x_diff_start
  bubble.original_pos_x = bubble.global_transform.origin.x
  bubble.target_pos_x = self.global_transform.origin.x + rand_range(-0.5, .5) # + x_diff_target
  # bubble.y_speed_start = rand_range(-2, -3)
  bubble.mySprite.remove_from_group("sprite")
  # bubble.setAsParent(self)

func isActive():
  return is_active

func activate(is_player):
  passiveActivate(0, is_player)

func passiveActivate(_delta, _is_player):
  level.player.getSmacked()
  is_active = false
  is_spawning = true
  collectSound.play()
  num_sparkles_spawned = 0

  mySprite.frame_delay = 0.1
  mySprite.should_randomize_frame_delay = false
  mySprite.updateBaseFrame(0, 1)
  mySprite.should_soft_fizzle_out = true
