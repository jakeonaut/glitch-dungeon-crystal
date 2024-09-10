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
export var locked_to_monsters = false
export var is_level_door = false

onready var npc = get_node("NPC")

onready var doorCloseSound = get_node("DoorCloseSound")
onready var doorOpenSound = get_node("DoorCloseSound")
onready var warpSound = get_node("WarpSound")
onready var lockedSound = get_node("LockedSound")
onready var keySound = get_node("KeySound")
onready var sillySound = get_node("SillySound")
onready var chickenRes = preload("res://sceneObjects/FreeChicken.tscn")

var canPlayDoorSound = true

var spawn_timer = 0
var spawn_time_limit = 3

onready var mySprite = get_node("Sprite3D")
onready var mySprite2 = get_node("Sprite3D2")
onready var landing = get_node("landing")
onready var sparkleSprite = get_node("SparkleSprite")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var fallthroughSolid = get_node("FallthroughSolid")
onready var activeCollisionShape = get_node("InteractionArea/ActiveCollisionShape")
onready var passiveCollisionShape = get_node("InteractionArea/PassiveCollisionShape")
var is_on_main_menu = false

export var is_immediate = false
export(int, "NORMAL", "FISH", "PYRAMID", "SHROOM", "CAT", "CRYSTAL") onready var key_type

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

  if num_keys_unlock == null:
    num_keys_unlock = 0

  if is_passive:
    mySprite.visible = false
    mySprite2.visible = false
    if activeCollisionShape != null: activeCollisionShape.disabled = true
    if passiveCollisionShape != null: passiveCollisionShape.disabled = false
  else:
    mySprite.material_override = mySprite.material_override.duplicate()
    mySprite2.material_override = mySprite.material_override
    if activeCollisionShape != null: activeCollisionShape.disabled = false
    if passiveCollisionShape != null: passiveCollisionShape.disabled = true
  if not self.path:
    mySprite.material_override.set_shader_param("target_palette", global.grey_palette)

  id = self.generateId()
  var _generateChickens = false
  if (is_locked or should_lock) and global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.id):
    is_locked = false
    should_lock = false
    _generateChickens = true

  animationPlayer.clear_queue()
  animationPlayer.stop()
  if is_locked:
    queueLockAnimation()
  elif should_lock or locked_to_monsters:
    is_locked = true
    doorCloseSound.play()
    animationPlayer.queue("doorBarred")
  else: 
    animationPlayer.play("doorOpen")

  if key_type == null:
    key_type = global.KeyItem.NORMAL
  if is_locked:
    if key_type == global.KeyItem.NORMAL:
      var num_keys = global.getLevelZoneThing("key")
      if num_keys == null or num_keys == 0:
        if num_keys_unlock == 1:
          npc.textBoxContainer.bbText = "•locked,\nneeds a key"
        else:
          npc.textBoxContainer.bbText = "•locked,\nneeds " + str(num_keys_unlock) + " keys"
      elif num_keys != null and num_keys < num_keys_unlock:
        prev_keys = num_keys
        npc.textBoxContainer.bbText = "•locked,\nneeds " + str(num_keys_unlock - num_keys) + " [wave]more[/wave] keys\n(" + str(num_keys_unlock) +" total)"
      else:
        prev_keys = num_keys
        npc.textBoxContainer.bbText = "•"
    else:
      var x_more_crystals = num_keys_unlock - global.memory["clean_crystals"]
      var key_name = getKeyName(x_more_crystals)
      npc.textBoxContainer.bbText = "•locked,\nneeds [wave]" + key_name + "[/wave]"
    npc.textBoxContainer.setVars()
    npc.textBox.can_camera_zoom = false
  else:
    npc.visible = false 
    npc.can_activate = false
    npc.is_active = false

  # if _generateChickens and num_keys_unlock < 10:
  #   yield(get_tree().create_timer(0.5), "timeout")
  #   for _i in range(num_keys_unlock):
  #     spawnChicken()

func getKeyName(x_more_crystals):
  var key_name = "FISH KEY"
  if key_type == global.KeyItem.PYRAMID:
    key_name = "PYRAMID KEY"
  elif key_type == global.KeyItem.SHROOM:
    key_name = "SHROOM KEY"
  elif key_type == global.KeyItem.CAT:
    key_name = "CAT KEY"
  elif key_type == global.KeyItem.CRYSTAL:
    key_name = str(x_more_crystals) + " more CRYSTALS\nto be purified"
  return key_name

func spawnChicken():
  var freeChicken = chickenRes.instance()
  level.add_child(freeChicken)
  freeChicken.global_transform.origin = global_transform.origin
  freeChicken.global_transform.origin.x += rand_range(-2, 2)
  freeChicken.global_transform.origin.y += rand_range(0.5, 3)
  freeChicken.spawn_origin = freeChicken.global_transform.origin
  level.summonSmokeClouds(freeChicken.global_transform.origin, 1, false, true)
    
func _process(delta):
  if is_passive and parter_door_id:
    canPlayDoorSound = false

  if locked_to_monsters and is_locked:
    var weak_enemies = level.get_tree().get_nodes_in_group("weak_enemies")
    if weak_enemies.size() == 0:
      startDoorUnlock()
      is_locked = false
      locked_to_monsters = false
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

  # if is_passive:
  #   spawnParticles(delta)

  if locked_to_monsters:
    npc.textBoxContainer.bbText = "•it won't open"
    npc.textBoxContainer.setVars()
  elif key_type == global.KeyItem.NORMAL:
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
        npc.textBoxContainer.bbText = "•"
      npc.textBoxContainer.setVars()
  else:
    pass

  if is_unlocking and not keySound.playing:
    if unlocking_key_array.size() == 0:
      actuallyUnlockAndEnterDoor()
      level.player.getItemFailsafe()
      is_unlocking = false
    else:
      var key = unlocking_key_array[0]
      if not key.flying_to_target:
        key.flyToTarget(npc)
      elif not key.is_returning:
        keySound.play()
        unlocking_key_array.remove(0)
        key.queue_free()
        # spawnChicken()


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
  if not is_vertical and not is_level_door:
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
    if landing.global_transform.origin.y < self.global_transform.origin.y and not is_level_door:
      y_min = -2
      y_max = -0.5
      target_y_add = rand_range(-3, -1.5)
    else:
      y_min = 2.5
      y_max = 4.0
      target_y_add = rand_range(1.5, 3)
  # okay.... I wish godot allowed multiple return values like javascript
  return [x_min, x_max, y_min, y_max, target_x_add, target_y_add] 

func isActive(_debug=false):
  return (visible or is_passive) and getPlayer().nesting_doll_state != global.NestingDoll.MATRIARCH

func generateId():
  return get_name()

func activate(is_player):
  if not is_player:
    return false
    
  if not is_passive and getPlayer().on_ground:
    if not is_locked:
      goThroughDoor()
    elif is_locked:
      if key_type == global.KeyItem.NORMAL:
        var num_keys = global.getLevelZoneThing("key")
        if num_keys != null and num_keys >= num_keys_unlock:
          startDoorUnlock()
        elif not lockedSound.is_playing():
          lockedSound.play()
          npc.activate(is_player)
      elif key_type == global.KeyItem.CRYSTAL:
        var has_special_key = global.memory["clean_crystals"] >= num_keys_unlock
        if has_special_key:
          # npc.textBoxContainer.bbText = "•you are worthy"
          # npc.textBoxContainer.setVars()
          # npc.activate(is_player)
          # was_i_just_unlocked = true
          startDoorUnlock()
        elif not lockedSound.is_playing():
          lockedSound.play()
          npc.activate(is_player)
      else:
        var has_special_key = global.memory.has("key_items") and global.memory["key_items"].has(key_type) and global.memory["key_items"][key_type] == global.ItemState.GOT_IT
        if has_special_key:
          # var key_name = getKeyName(0)
          # npc.textBoxContainer.bbText = "•used [wave]" + key_name + "[/wave]"
          # npc.textBoxContainer.setVars()
          # npc.activate(is_player)
          # was_i_just_unlocked = true
          startDoorUnlock()
        elif not lockedSound.is_playing():
          lockedSound.play()
          npc.activate(is_player)

func unpause():
  global.pauseMoveInput = false

var is_unlocking = false
var unlocking_key_array = []
var was_i_just_unlocked = false
func startDoorUnlock():
  var num_keys = global.getLevelZoneThing("key")

  if not locked_to_monsters:
    unlocking_key_array = []
    if key_type != global.KeyItem.NORMAL:
      num_keys_unlock = 1

    for i in range(level.followers.size() - 1, -1, -1):
      var follower = level.followers[i]
      if follower.is_in_group("keys"):
        if key_type == global.KeyItem.NORMAL or follower.key_type == self.key_type:
          follower.popFromFollowers()
          unlocking_key_array.push_back(follower)
          if unlocking_key_array.size() >= num_keys_unlock:
            break
        
    if not key_type == global.KeyItem.CRYSTAL:
      global.setLevelZoneThing("key", num_keys - num_keys_unlock)
  npc.visible = false 
  npc.can_activate = false
  npc.is_active = false
  is_locked = false
  if locked_to_monsters:
    npc.textBox.hideTextbox()
    animationPlayer.clear_queue()
    animationPlayer.stop()
    global.pauseMoveInput = true
    doorOpenSound.play()
    animationPlayer.queue("doorUnbarred")
  else:
    level.player.physics_state = level.player.PhysicsState.OCCUPIED
    global.pauseMoveInput = true
    getPlayer().pauseSelf = true
    setGlobalMemoryOfHasUnlocked()
    is_unlocking = true
    getPlayer().hv = 0
    getPlayer().linear_velocity.x = 0
    getPlayer().lv.x = 0
    getPlayer().dir = Vector3(0, 0, 0)
    getPlayer().global_transform.origin.x = self.global_transform.origin.x
    getPlayer().aniPlayer.stop()
    getPlayer().aniPlayer.clear_queue()
    getPlayer().aniPlayer.play("preGetItem")
    getPlayer().playBounce("land")

func actuallyUnlockAndEnterDoor():
  # level.displayMessageText("unlocked!")
  if key_type != global.KeyItem.NORMAL and key_type != global.KeyItem.CRYSTAL:
    global.memory["key_items"][key_type] = global.ItemState.USED_IT
  animationPlayer.clear_queue()
  animationPlayer.stop()
  doorOpenSound.play()
  animationPlayer.queue("doorOpen")
  if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
    global.activeInteractor.stopInteract()
  global.activeInteractor = null
  goThroughDoor(false, was_i_just_unlocked, false)
  global.pauseMoveInput = false


func passiveActivate(_delta, _is_player):
  return # just let player tryDieToOffscreenCamera handle it!!!
  # if is_passive and is_player:
  #   goThroughDoor()
    
func justStopPassiveActivate():
  pass

func goThroughDoor(start_of_game = false, really_long_fade = false, really_really_long_fade = false):
  if path == "" and parter_door_id == "":
    if not sillySound.is_playing():
      sillySound.play()
    return
  if global.isEnteringRoom:
    return

  if "LevelDoor" in self.id:
    get_node("TeleportSound").play()
  elif canPlayDoorSound:
    global.doorSound.play()
  elif is_passive and parter_door_id:
    warpSound.play()

  if not is_passive:
    getPlayer().global_transform.origin = self.global_transform.origin
    if getPlayer().nesting_doll_state == global.NestingDoll.BABY:
      getPlayer().global_transform.origin.y += 0.5
      if getPlayer().grav < 0:
        getPlayer().global_transform.origin.y += 1
    else:
      getPlayer().global_transform.origin.y += 1
    if getPlayer().summonedBroom:
      getPlayer().summonedBroom.visible = false
      getPlayer().broomStop()
    if "LevelDoor" in self.id:
      getPlayer().aniPlayer.stop()
      getPlayer().aniPlayer.clear_queue()
      getPlayer().aniPlayer.play("teleport")
      getPlayer().getSmacked()
    else:
      getPlayer().aniPlayer.stop()
      getPlayer().aniPlayer.clear_queue()
      getPlayer().aniPlayer.play("enterDoor")
      getPlayer().playBounce("land")
    getPlayer().pauseAnimation = true
    getPlayer().pauseInput = true
  getPlayer().pauseSelf = true

  global.activeInteractor = null

  if not self.path:
    if not parter_door_id:
      return
    var partnerDoor = level.get_node(parter_door_id) if level.has_node(parter_door_id) else null
    if partnerDoor and partnerDoor.has_method("land"):
      global.pauseGame = true
      if not is_passive:
        yield(get_tree().create_timer(0.50), "timeout")
      partnerDoor.land(false)
      getPlayer().aniPlayer.stop()
      getPlayer().aniPlayer.clear_queue()
      getPlayer().aniPlayer.play("stand")
      getPlayer().playBounce("land")
      getPlayer().pauseSelf = false
      getPlayer().pauseAnimation = false
      getPlayer().pauseInput = false
    return

  if start_of_game:
    transition.really_long_fade_to(self.path)
    return
    
  global.memory["cameraSize"] = level.gameCamera.initial_size
  # global.memory["lastDoor"] = id
  global.memory["roomPath"] = level.getLevelName()
  global.pauseGame = true

  global.isEnteringRoom = true
  global.hasJustEnteredRoom = false
  global.respawnVarTimerHack = 0
  
  global.memory["on_ground"] = true
  if "LevelDoor" in self.id:
    transition.granny_teleport_to(self.path)
  elif is_passive:
    global.memory["on_ground"] = getPlayer().on_ground
    global.memory["player_flip_h"] = getPlayer().mySprite.flip_h
    global.memory["linear_velocity"] = getPlayer().linear_velocity
    transition.fast_fade_to(self.path)
  elif really_really_long_fade:
    transition.really_really_long_fade_to(self.path)
  elif really_long_fade:
    transition.really_long_fade_to(self.path)
  else:
    transition.long_fade_to(self.path)
  # if is_immediate or is_passive:
  #   transition.change_scene()

func isLandingOutsideOfCameraBounds():
  var DEATH_MARGIN = 0
  if getGameCamera().rightmost_x > -999:
      if landing.global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN or \
      landing.global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN or \
      landing.global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN or \
      landing.global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
        return true
  return false

func land(should_change_shader_params = true, should_play_transition = false):
  # TODO(jaketrower): Oh...
  # global.memory.erase("active_save_point_x")
  # global.memory.erase("active_save_point_y")
  # global.memory.erase("active_save_point_z")
  global.pauseGame = false
  if is_locked:
    is_locked = false
    should_lock = false
    animationPlayer.clear_queue()
    animationPlayer.stop()
    doorOpenSound.play()
    animationPlayer.queue("doorOpen")
    if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
      global.activeInteractor.stopInteract()
    global.activeInteractor = null
    npc.visible = false 
    npc.can_activate = false
    npc.is_active = false
  
  if isLandingOutsideOfCameraBounds():
    if global.grannyEnteringRoom:
      transition.reverse_granny_teleport()
      global.grannyEnteringRoom = false
    elif is_passive: transition.fast_reverse_fade()
    else: transition.reverse_fade()
    return
  getPlayer().global_transform.origin.x = landing.global_transform.origin.x
  getPlayer().global_transform.origin.y = landing.global_transform.origin.y
  landing.global_transform.origin.z = 0
  getPlayer().target_last_grounded_y = landing.global_transform.origin.y

  getPlayer().mySprite.get_material_override().set_shader_param("enable_glitch", false)

  if is_passive:
    if should_play_transition:
      if global.grannyEnteringRoom:
        transition.reverse_granny_teleport()
        global.grannyEnteringRoom = false
      else:
        transition.fast_reverse_fade()

    if is_vertical:
      getPlayer().on_ground = false
  else:
    if should_play_transition:
      if global.grannyEnteringRoom:
        transition.reverse_granny_teleport()
        global.grannyEnteringRoom = false
      else:
        transition.reverse_fade()
    # SNEAKY SNEAKY
    # global.saveMySpot(self.translation, level) 
    getPlayer().playBounce("land")
    if not (global.memory.has("grav_direction") and global.memory["grav_direction"] == -1):
      getPlayer().on_ground = false
    if should_change_shader_params:
      greyMeOut()

func greyMeOut():
  mySprite.material_override.set_shader_param("enable_dither", true)
  mySprite.material_override.set_shader_param("opacity", 0.9)
  mySprite.material_override.set_shader_param("target_palette", global.grey_palette)

func setGlobalMemoryOfHasUnlocked():
  if not global.memory.has(level.getShortLevelName()):
    global.memory[level.getShortLevelName()] = {}
  global.memory[level.getShortLevelName()][self.id] = true


func lockMeUp(num_keys):
  if is_locked:
    return
  doorCloseSound.play()
  animationPlayer.stop()
  animationPlayer.clear_queue()
  animationPlayer.queue("doorClose")
  queueLockAnimation()
  is_locked = true
  num_keys_unlock = num_keys

func queueLockAnimation():
  if key_type == global.KeyItem.FISH:
    animationPlayer.queue("fishLocked")
  elif key_type == global.KeyItem.PYRAMID:
    animationPlayer.queue("pyramidLocked")
  elif key_type == global.KeyItem.SHROOM:
    animationPlayer.queue("shroomLocked")
  elif key_type == global.KeyItem.CAT:
    animationPlayer.queue("catLocked")
  elif key_type == global.KeyItem.CRYSTAL:
    animationPlayer.queue("crystalLocked")
  else:
    animationPlayer.queue("locked")
