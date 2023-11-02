extends Spatial

var id = null
onready var animationPlayer = get_node("AnimationPlayer")
export var is_locked = false
export var should_lock = false
# String is a path to a file.
export(String, FILE) var path
# partner_door_id assumes path is unset.
export var parter_door_id = ""
export var dont_recolor_me = false

export var is_passive = false
export var is_vertical = false
export var num_keys_unlock = 999

onready var npc = get_node("NPC")

onready var doorCloseSound = get_node("DoorCloseSound")
onready var doorOpenSound = get_node("DoorCloseSound")
onready var lockedSound = get_node("LockedSound")

var canPlayDoorSound = true

var spawn_timer = 0
var spawn_time_limit = 3

onready var mySprite = get_node("Sprite3D")
onready var mySprite2 = get_node("Sprite3D2")
onready var interactPromptSprite = get_node("InteractPrompt")
onready var interactionAniPlayer = get_node("InteractionAnimationPlayer")
onready var landing = get_node("landing")
onready var sparkleSprite = get_node("SparkleSprite")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var fallthroughSolid = get_node("FallthroughSolid")
var is_on_main_menu = false

var gameCamera = null
func getGameCamera():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if gameCamera == null:
    gameCamera = level.gameCamera
  return gameCamera

var player = null
func getPlayer():
  if player == null:
    player = level.player
  return player

var prev_keys = 0
func _ready():
  set_process(true)
  landing.visible = false

  if is_passive:
    mySprite.visible = false

  id = self.generateId()
  if (is_locked or should_lock) and global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.id):
    is_locked = false
    should_lock = false

  animationPlayer.clear_queue()
  animationPlayer.stop()
  if is_locked:
    animationPlayer.play("locked")
  elif should_lock:
    is_locked = true
    doorCloseSound.play()
    animationPlayer.queue("doorOpen")
    animationPlayer.queue("doorClose")
    animationPlayer.queue("locked")
  else: 
    animationPlayer.play("doorOpen")

  if is_locked or should_lock:
    var num_keys = global.getLevelZoneThing("key")
    if num_keys == null or num_keys == 0:
      if num_keys_unlock == 1:
        npc.textBoxContainer.bbText = "•locked,\nneeds a key"
      else:
        npc.textBoxContainer.bbText = "•locked,\nneeds " + str(num_keys_unlock) + " keys"
    elif num_keys != null and num_keys < num_keys_unlock:
      prev_keys = num_keys
      npc.textBoxContainer.bbText = "•locked,\nneeds " + str(num_keys_unlock - num_keys) + " more key"
    else:
      prev_keys = num_keys
      npc.textBoxContainer.bbText = "•press UP to unlock"
    npc.textBoxContainer.setVars()
    npc.textBox.can_camera_zoom = false
  else:
    npc.visible = false 
    npc.can_activate = false
    npc.is_active = false
  
  if not mySprite2.visible:
    interactPromptSprite.global_transform.origin.y -= 1
    
func _process(delta):
  if is_passive:
    mySprite.visible = false
    mySprite2.visible = false
  delta = delta * global.time_dilation_multiplier
  animationPlayer.playback_speed = global.time_dilation_multiplier

  if (is_passive or not mySprite2.visible) and fallthroughSolid.is_in_group("fallthrough"):
    fallthroughSolid.remove_from_group("fallthrough")
  elif not is_passive and mySprite2.visible and not fallthroughSolid.is_in_group("fallthrough"):
    fallthroughSolid.add_to_group("fallthrough")

  if dont_recolor_me:
    if mySprite.is_in_group("sprite"):
      mySprite.remove_from_group("sprite")
    if mySprite2.is_in_group("sprite"):
      mySprite2.remove_from_group("sprite")
  
  if global.pauseGame: return

  if is_passive:
    spawnParticles(delta)

  var num_keys = global.getLevelZoneThing("key")
  if prev_keys != num_keys and is_locked:
    prev_keys = num_keys
    if num_keys == null or num_keys == 0:
      if num_keys_unlock == 1:
        npc.textBoxContainer.bbText = "•locked,\nneeds a key"
      else:
        npc.textBoxContainer.bbText = "•locked,\nneeds " + str(num_keys_unlock) + " keys"
    elif num_keys != null and num_keys < num_keys_unlock:
      npc.textBoxContainer.bbText = "•locked,\nneeds " + str(num_keys_unlock - num_keys) + " more key"
    else:
      npc.textBoxContainer.bbText = "•press [UP] to unlock"
    npc.textBoxContainer.setVars()

func spawnParticles(delta):
  spawn_timer += (delta*22)
  if spawn_timer >= spawn_time_limit:
    var x_y_min_max = calculateXYMinMax()
    var x_min = x_y_min_max[0]
    var x_max = x_y_min_max[1]
    var y_min = x_y_min_max[2]
    var y_max = x_y_min_max[3]
    var target_x_add = x_y_min_max[4]
    var target_y_add = x_y_min_max[5]

    var children = self.get_children()
    var num_children = 0
    for i in children:
      num_children += 1

    if num_children < 20:
      var newSprite = sparkleSprite.duplicate()
      newSprite.should_fizzle_out = true
      newSprite.visible = true
      newSprite.transform.origin = Vector3(
        stepify(rand_range(x_min, x_max), 0.12),
        stepify(rand_range(y_min, y_max), 0.12),
        0
      )
      newSprite.updateBaseFrame(0, 0)
      newSprite.max_frames = 2
      add_child(newSprite)
      newSprite.target_x = newSprite.global_transform.origin.x + target_x_add
      newSprite.target_y = newSprite.global_transform.origin.y + target_y_add
      newSprite.fade_out_opacity = true
      newSprite.curr_opacity = 0.6
      newSprite.start_frame = randi() % (newSprite.hframes * newSprite.vframes)
      newSprite.restart()
      newSprite.opacity_fade_rate = 5
      spawn_timer = 0
      
func calculateXYMinMax():
  var x_min = -1.0
  var x_max = 1.0
  var y_min = 0.5
  var y_max = 2.5
  var target_x_add = 0
  var target_y_add = 0
  if not is_vertical:
    if landing.global_transform.origin.x < self.global_transform.origin.x:
      x_min = -3
      x_max = -2
      target_x_add = rand_range(-3, -1.5)
    else:
      x_min = 2
      x_max = 3
      target_x_add = rand_range(1.5, 3)
  else:
    x_min = -1.0
    x_max = 1.0
    if landing.global_transform.origin.y < self.global_transform.origin.y:
      y_min = -2
      y_max = -0.5
      target_y_add = rand_range(-3, -1.5)
    else:
      y_min = 2.5
      y_max = 4.0
      target_y_add = rand_range(1.5, 3)
  # okay.... I wish godot allowed multiple return values like javascript
  return [x_min, x_max, y_min, y_max, target_x_add, target_y_add] 

func isActive():
  return visible or is_passive

func generateId():
  return get_name()

func activate(is_player):
  if not is_player:
    return false
    
  if not is_passive:
    if not is_locked and not should_lock and global.activeInteractor == null and not (getPlayer().glitch_form == global.GlitchForm.FLOOR and getPlayer().on_ground and not getPlayer().truly_on_ground):
      goThroughDoor()
    elif is_locked:
      var num_keys = global.getLevelZoneThing("key")
      if num_keys != null and num_keys >= num_keys_unlock:
        level.displayMessageText("unlocked!")
        global.pauseMoveInput = true
        global.setLevelZoneThing("key", num_keys - num_keys_unlock)
        npc.visible = false 
        npc.can_activate = false
        npc.is_active = false
        animationPlayer.clear_queue()
        animationPlayer.stop()
        doorOpenSound.play()
        animationPlayer.queue("doorOpen")
        is_locked = false
        setGlobalMemoryOfHasUnlocked()
        if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
          global.activeInteractor.stopInteract()
        global.activeInteractor = null
        goThroughDoor()
      elif not lockedSound.is_playing():
        lockedSound.play()
        npc.activate(is_player)


func passiveActivate(_delta, is_player):
  if is_passive and is_player:
    goThroughDoor()
  elif is_player and not interactPromptSprite.visible:
    interactPromptSprite.visible = true
    
func justStopPassiveActivate():
  interactPromptSprite.visible = false

func goThroughDoor(start_of_game = false, really_long_fade = false, really_really_long_fade = false):
  if global.isEnteringRoom:
    return

  if canPlayDoorSound:
    global.doorSound.play()

  if not is_passive:
    getPlayer().global_transform.origin = self.global_transform.origin
    getPlayer().global_transform.origin.y += 1
    if getPlayer().summonedBroom:
      getPlayer().summonedBroom.visible = false
      getPlayer().broomStop()
    getPlayer().aniPlayer.stop()
    getPlayer().aniPlayer.clear_queue()
    getPlayer().aniPlayer.play("enterDoor")
    getPlayer().playBounce("land")
  getPlayer().pauseSelf = true

  global.activeInteractor = null

  if not self.path:
    if not parter_door_id:
      return
    var partnerDoor = level.get_node(parter_door_id) if level.has_node(parter_door_id) else null
    if partnerDoor and partnerDoor.has_method("land"):
      global.pauseGame = true
      yield(get_tree().create_timer(0.50), "timeout")
      partnerDoor.land()
      getPlayer().aniPlayer.stop()
      getPlayer().aniPlayer.clear_queue()
      getPlayer().aniPlayer.play("stand")
      getPlayer().playBounce("land")
      getPlayer().pauseSelf = false
    return

  if start_of_game:
    transition.long_fade_to(self.path)
    return
    
  global.memory["cameraSize"] = level.gameCamera.initial_size
  global.memory["lastDoor"] = id
  global.memory["roomPath"] = level.getLevelName()
  global.pauseGame = true

  global.isEnteringRoom = true
  global.hasJustEnteredRoom = false
  global.respawnVarTimerHack = 0
  if is_passive:
    global.memory["player_flip_h"] = getPlayer().mySprite.flip_h
    if is_vertical:
      global.memory["feather_jump_timer"] = getPlayer().feather_jump_timer
    else:
      global.memory["player_y_offset"] = getPlayer().global_transform.origin.y - global_transform.origin.y - 1
    global.memory["linear_velocity"] = getPlayer().linear_velocity
    transition.fade_to(self.path)
  elif really_really_long_fade:
    transition.really_really_long_fade_to(self.path)
  elif really_long_fade:
    transition.really_long_fade_to(self.path)
  else:
    transition.long_fade_to(self.path)

func isLandingOutsideOfCameraBounds():
  var DEATH_MARGIN = 0
  if getGameCamera().rightmost_x > -999:
      if landing.global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
      landing.global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
      landing.global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
      landing.global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
        return true
  return false

func land():
  # TODO(jaketrower): Oh...
  # global.memory.erase("active_save_point_x")
  # global.memory.erase("active_save_point_y")
  # global.memory.erase("active_save_point_z")
  global.pauseGame = false
  
  if isLandingOutsideOfCameraBounds():
    return
  getPlayer().global_transform.origin.x = landing.global_transform.origin.x
  getPlayer().global_transform.origin.y = landing.global_transform.origin.y
  getPlayer().target_last_grounded_y = landing.global_transform.origin.y

  getPlayer().mySprite.get_material_override().set_shader_param("enable_glitch", false)

  if is_passive:
    if global.memory.has("player_flip_h"):
      getPlayer().mySprite.flip_h = global.memory["player_flip_h"]
      global.memory.erase("player_flip_h")
    if global.memory.has("player_y_offset"):
      getPlayer().global_transform.origin.y += global.memory["player_y_offset"]
    if global.memory.has("feather_jump_timer"):
      getPlayer().feather_jump_timer = global.memory["feather_jump_timer"]
      global.memory.erase("feather_jump_timer")
    if global.memory.has("linear_velocity"):
      getPlayer().linear_velocity = global.memory["linear_velocity"]
      global.memory.erase("linear_velocity")

    if is_vertical:
      getPlayer().on_ground = false
  else:
    # SNEAKY SNEAKY
    global.saveMySpot(self.translation, level) 
    getPlayer().playBounce("land") 

func setGlobalMemoryOfHasUnlocked():
  if not global.memory.has(level.getShortLevelName()):
    global.memory[level.getShortLevelName()] = {}
  global.memory[level.getShortLevelName()][self.id] = true
