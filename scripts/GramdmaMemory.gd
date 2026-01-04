extends "NPC.gd"

var id = null
# String is a path to a file.
export(String, FILE) var path

export var is_vertical = false
export var num_keys_unlock = 999

var canPlayDoorSound = true

var spawn_timer = 0
var spawn_time_limit = 3

var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

func _ready():
  set_process(true)

  id = self.generateId()
    
func _process(delta):
  delta = delta * global.time_dilation_multiplier
  aniPlayer.playback_speed = global.time_dilation_multiplier 

func generateId():
  return get_name()

func activate(_is_player, _is_local_broom = false):
  if global.activeInteractor == null:
    goThroughDoor()

func passiveActivate(_delta, _is_player, _is_local_broom = false):
  goThroughDoor()

# TODO(jaketrower): Should probably put this onto transition as well
onready var teleportSound = get_node("TeleportSound")
func goThroughDoor():
  if global.isEnteringRoom or global.grannyEnteringRoom:
    return

  if canPlayDoorSound and not teleportSound.is_playing():
    level.player.glitchTickle()
    teleportSound.play()

  if not self.path:
    return

  # getPlayer().global_transform.origin = self.global_transform.origin
  # getPlayer().global_transform.origin.y += 1
  getPlayer().aniPlayer.stop()
  getPlayer().aniPlayer.clear_queue()
  getPlayer().aniPlayer.play("teleport")
  getPlayer().pauseAnimation = true
  getPlayer().getSmacked()

  global.activeInteractor = null
    
  global.memory["cameraSize"] = level.gameCamera.initial_size
  # global.memory["lastDoor"] = id
  global.memory["roomPath"] = level.getLevelName()
  global.pauseGame = true

  global.grannyEnteringRoom = true
  global.isEnteringRoom = true
  global.hasJustEnteredRoom = false
  global.respawnVarTimerHack = 0
  global.memory["player_flip_h"] = getPlayer().mySprite.flip_h
  global.memory["feather_jump_timer"] = getPlayer().feather_jump_timer
  global.memory["linear_velocity"] = getPlayer().linear_velocity
  transition.granny_teleport_to(self.path)

  # # TODO(jaketrower): Should probably put this onto transition:
  # # var level = get_tree().get_root().get_node("Game/Viewport/level")
  # var newLevelRes = load(self.path)
  # var newLevel = newLevelRes.instance()
  # # get_tree().get_root().add_child(newLevel)
  # var oldLevelTiles = getLevelTiles()
  # # level.add_child(newLevel)
  # var newLevelTiles = newLevel.get_node("Viewport/level/LevelTiles")

  # oldLevelTiles.queueSausageDreamFadeAwayDifference(newLevelTiles)
  # # TODO(jaketrower): When the above ^^ has completed, completely override newLevelTiles with oldLevelTiles.
  # # This would be a no-op, but I think the in-place tile randomization matters.

func land():
  global.pauseGame = false
  
  getPlayer().global_transform.origin.x = mySprite.global_transform.origin.x
  getPlayer().global_transform.origin.y = mySprite.global_transform.origin.y
  getPlayer().camera_target_y_pos = mySprite.global_transform.origin.y

  getPlayer().mySprite.get_material_override().set_shader_param("enable_glitch", false)
  getPlayer().on_ground = false
