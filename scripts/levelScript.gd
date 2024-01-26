extends Node

onready var uiLayer = get_node("../../UILayer") if has_node("../../UILayer") else get_node("UILayer")
onready var player = get_node("Player")
onready var levelTiles = get_node("LevelTiles")
onready var fakeLevelTiles = get_node("FakeLevelTiles") if has_node("FakeLevelTiles") else null
onready var gameCamera = get_node("GameCamera")
# onready var ditherPaletteEffectRect = get_node("../../ScreenEffects/DitherPaletteEffectRect")
onready var glitchScreenEffect = get_node("../../ScreenEffects/GlitchEffectRect")
onready var ditherPaletteEffectRect2 = get_node("../../Viewport2/ScreenEffects/DitherPaletteEffectRect")
onready var colorBlindEffectRect2 = get_node("../../Viewport2/ScreenEffects/PaletteSwapEffectRect") 
onready var basicCrtEffectRect = get_node("../../Viewport2/ScreenEffects/BasicCrtEffectRect")
onready var viewportTexture = get_node("../../ViewportTexture")
onready var viewport2 = get_node("../../Viewport2")
var current_sprite_palette = global.grey_palette
export var player_message = "???"

export var show_crt_effect = false
export var show_dither_effect = false

export(int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var starting_glitch_type
# will always activate regardless of this variable at start of game, but if this value is true, will activate an override the existing player glitch type
export var should_glitch_activate = false 
export var null_glitch = false
# TODO(jaketrower): need to make this work with grimoire

# IFNDEF FakeLevelTiles.gd (if we get much more scripts doing this, put it in global)
export(int, "DUNGEON", "HOUSE", "FOREST", "ALIEN", "DESERT", "GLITCH_WORLD", "BEACH", "POISON_FOREST", "POISON_HOUSE") var tileset_type 

export var spellbook_forbidden = false
# TODO(jaketrower): Make a debug global section???
export var has_spellbook_page = false
export(Array, int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var spellbook_spells = []
export var how_much_mp = 5
export var how_much_hp = 1

export var display_title = "???"
export var doesnt_have_broom = false

func _ready():
  # stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
  _ready_impl()

export var is_randomizing = false
func _ready_impl():
  get_node("..").audio_listener_enable_3d = true

  global.canChangeSongPitch = true
  global.activeInteractor = null # somewhat of a failsafe
  set_process(true)

  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")

  viewportTexture.texture = viewport2.get_texture()
  
  levelTiles.removeRemovedTiles()
  levelTiles.setTileset(tileset_type, false)
  levelTiles.buildRandomTiles()
  
  if has_spellbook_page and not global.memory.has("spellbookPage"):
    global.memory["inventory"] = [global.Inventory.GRIMOIRE]
    global.memory["spellbookPage"] = []
    for spellbook_spell in spellbook_spells:
      global.memory["spellbookPage"].push_back(spellbook_spell)
  global.memory["tutorial_spellbookPage"] = false
    
  if global.memory["has_gotten_broom"] > 0:
    global.memory["broom"] = true
  if doesnt_have_broom and global.memory["has_gotten_broom"] < 2:
    global.memory["broom"] = false
    global.memory["has_gotten_broom"] = 0
  elif not doesnt_have_broom:
    global.memory["broom"] = true
    global.memory["has_gotten_broom"] = 2

  if global.memory.has("current_glitch") and not should_glitch_activate:
    if global.memory["mp"] > 0 or global.memory["max_mp"] == 0:
      player.applyGlitch(global.memory["current_glitch"], true)
  else:
    player.applyGlitch(starting_glitch_type, true)
  displayMessageText("")

  if global.memory.has("player_costume"):
    player.wearCostume(global.memory["player_costume"])

  tryShowUIElements()
  tryToRespawn()
  global.tryInitializeLevelZone(self.getLevelZoneName())
  trySpawnFollowers()
  setUpRoomInitializationOverride()
  restartMusic()
  if global.hasGottenLevelGeode or is_randomizing:
    levelTiles.randomize_num += 10
    levelTiles.randomize_num_counter = 15

  global.activeThrowableObject = null
  if global.activeThrowableObjectPath != null:
    # resource is loaded at compile time
    var carriedThrowableObject = load(global.activeThrowableObjectPath).instance() 
    add_child(carriedThrowableObject)
    carriedThrowableObject.activate(true)
    carriedThrowableObject.spawn_origin = carriedThrowableObject.global_transform.origin
  else:
    pass
  global.activeThrowableObjectPath = null
  player.mySprite.get_material_override().set_shader_param("enable_glitch", false)
  player.mySprite.get_material_override().set_shader_param("enable_remove_skin_tone", false)
  if player_message != "???":
    player.sayThis(player_message)
  if global.memory.has("grav_direction") and global.memory["grav_direction"] < 0:
    flipGravity()

func _process(delta):
  delta = delta * global.time_dilation_multiplier

  ditherPaletteEffectRect2.visible = global.memory["show_dither_effect"] and show_dither_effect
  basicCrtEffectRect.visible = global.memory["show_crt_effect"] and show_crt_effect
  colorBlindEffectRect2.visible = global.memory["show_color_blind"]
  if Input.is_action_pressed("toggle_fullscreen"):
    return

  if not global.pauseGame and not global.pauseMoveInput:
    if Input.is_action_just_pressed("ui_start") and getLevelName().find("MainMenu") < 0:
      global.isPauseMenuOpen = true
      global.pauseGame = true
      player.pauseSound.play()
      musicPlayer.tryToPlay(musicPlayer.casinoThemePlayer)
  elif global.isPauseMenuOpen and Input.is_action_just_pressed("ui_start"):
    if global.is_reading_input:
      player.noBroomSound.play()
    else:
      global.isPauseMenuOpen = false
      global.pauseGame = false
      player.unpauseSound.play()
      restartMusic()

func displayMessageText(message):
  uiLayer.displayMessageText(message)

func displaySpellMessageText(message):
  uiLayer.displaySpellMessageText(message)

func saveTheGame(message = "saving!!"):
  uiLayer.displaySavingText(message)
  global.memory["roomPath"] = self.getLevelName()
  global.saveGame()
    
func restartMusic():
  # update music
  musicPlayer.conductFromScenePath(getLevelName())
  
func tryShowUIElements():
  # TODO(jaketrower): Could be better method to fetch this without a weird node search in the ready_impl()
  uiLayer.setDisplayTitle(display_title)
  uiLayer.initiateCutsceneRenderLogic()

  if global.memory.has("spellbookPage"):
    # TODO(jaketrower): less ideal
    uiLayer.get_node("EquipmentRect").visible = true
    uiLayer.get_node("EquipmentStatusRect").visible = true
  else:
    uiLayer.get_node("EquipmentRect").visible = false
    uiLayer.get_node("EquipmentStatusRect").visible = false

func overrideLevelRespawnEvent():
  pass
  
func setUpRoomInitializationOverride():
  pass

func getLevelName():
  return get_tree().get_root().get_node("Game").get_filename()
  
func getShortLevelName():
  return global.getShortLevelName(getLevelName())

func getLevelZoneName():
  return global.getLevelZoneName(getLevelName())

func tryToRespawn():
  self.gameCamera.initial_target = player.get_node("CameraTarget")
  if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
    global.activeInteractor.stopInteract()
  global.activeInteractor = null
  global.pauseMoveInput = false
  if not global.grannyEnteringRoom:
    global.pauseGame = false

  var found_door = null
  if global.isEnteringRoom and not global.isRespawning:
    if global.memory.has("lastDoor") and global.memory.has("roomPath"):
      var door_path = global.memory["roomPath"]
      var doors = get_tree().get_nodes_in_group("doors")
      for door in doors:
        if door.path == door_path:
          found_door = door
          break
  elif global.isRespawning:
    if global.memory.has("active_save_point_x") and global.memory.has("savedRoomPath") and global.memory["savedRoomPath"] == getLevelName():
      player.global_transform.origin = Vector3(
        global.memory["active_save_point_x"], 
        global.memory["active_save_point_y"], 
        global.memory["active_save_point_z"])
      gameCamera.rotation_degrees.y = global.cameraRotation
      player.last_grounded_pos = Vector3(player.global_transform.origin)
    elif global.memory.has("savedRoomPath") and global.memory["savedRoomPath"] != getLevelName():
      if global.memory.has("active_save_point_x"):
        # transition.fast_fade_to(global.memory["savedRoomPath"])
        global.isEnteringRoom = true
        transition.path = global.memory["savedRoomPath"]
        transition.change_scene()
        return
    elif global.memory.has("lastDoor"):
      var door_path = global.memory["roomPath"]
      var doors = get_tree().get_nodes_in_group("doors")
      for door in doors:
        if door.path == door_path:
          found_door = door
          break
    else:
      player.global_transform.origin = player.spawn_origin

  if found_door:
    print(found_door)
    found_door.land(true, true)
  elif not global.memory.has("savedRoomPath") or global.memory["savedRoomPath"] != getLevelName():
    player.global_transform.origin = player.spawn_origin
    global.saveMySpot(player.spawn_origin, self)
  if global.set_camera_position_on_respawn:
    player.target_last_grounded_y = player.global_transform.origin.y
    player.cameraTarget.global_transform.origin.y = player.target_last_grounded_y
    gameCamera.setCameraPositionNow()
    global.set_camera_position_on_respawn = false
  if not found_door and global.isEnteringRoom:
    if global.grannyEnteringRoom:
      transition.reverse_granny_teleport()
      global.grannyEnteringRoom = false
    else:
      transition.reverse_fade()

  global.respawnVarTimerHack = 0
  global.hasJustEnteredRoom = global.isEnteringRoom
  global.isEnteringRoom = false
  global.isRespawning = false

  player.unsmack()
  player.aniPlayer.play("land")
  player.pauseAnimation = false
  self.overrideLevelRespawnEvent()
  player.nesting_doll_state = global.memory["nesting_doll"]
  player.updateNestingDoll(global.memory["nesting_doll"]) # TODO(jaketrower): need to remember nesting doll position?
  
  if player.nesting_doll_state == global.NestingDoll.BABY:
    player.shroomAniPlayer.stop(true)
    player.shroomAniPlayer.clear_queue()
    player.shroomAniPlayer.play("shrink", -1, 999)

  if player.nesting_doll_state != global.NestingDoll.GRANDMA:
    player.mySprite.flip_h = not player.mySprite.flip_h
    player.summonFallenBroom(false, true)
    player.mySprite.flip_h = not player.mySprite.flip_h


func setDoorsSpriteFrame(_frame):
  pass
  # var doors = get_tree().get_nodes_in_group("doors")
  # for door in doors:
  #   if door.dont_recolor_me:
  #     continue
  #   door.mySprite2.frame = frame

func setTorchSpriteFrame(_v_frame):
  pass
  # var torches = get_tree().get_nodes_in_group("torch")
  # for torch in torches:
  #   torch.get_node("Sprite3D").updateBaseFrame(0, v_frame)

  # var walltorches = get_tree().get_nodes_in_group("walltorch")
  # for walltorch in walltorches:
  #   walltorch.get_node("Sprite3D").updateBaseFrame(0, v_frame)

func normalGlitch():
  uiLayer.normalGlitch()
  if not null_glitch: levelTiles.normalGlitch()
  if fakeLevelTiles and not null_glitch: fakeLevelTiles.normalGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.grey_palette, "grey_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.grey_palette, "grey_palette")
  current_sprite_palette = levelTiles.grey_palette
  setDoorsSpriteFrame(4)
  

func floorGlitch():
  uiLayer.floorGlitch()
  if not null_glitch: levelTiles.floorGlitch()
  if fakeLevelTiles and not null_glitch: fakeLevelTiles.floorGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.red_palette, "red_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.red_palette, "red_palette")
  current_sprite_palette = levelTiles.red_palette
  setDoorsSpriteFrame(9)

func featherGlitch():
  uiLayer.featherGlitch()
  if not null_glitch: levelTiles.featherGlitch()
  if fakeLevelTiles and not null_glitch: fakeLevelTiles.featherGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.green_palette, "green_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.green_palette, "green_palette")
  current_sprite_palette = levelTiles.green_palette
  setDoorsSpriteFrame(14)

func ladderGlitch():
  uiLayer.ladderGlitch()
  if not null_glitch: levelTiles.ladderGlitch()
  if fakeLevelTiles and not null_glitch: fakeLevelTiles.ladderGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.yellow_palette, "yellow_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.yellow_palette, "yellow_palette")
  current_sprite_palette = levelTiles.yellow_palette
  setDoorsSpriteFrame(19)

func invisibleGlitch():
  uiLayer.invisibleGlitch()
  if not null_glitch: levelTiles.invisibleGlitch()
  if fakeLevelTiles and not null_glitch: fakeLevelTiles.invisibleGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.black_palette, "black_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.black_palette, "black_palette")
  current_sprite_palette = levelTiles.black_palette
  setDoorsSpriteFrame(24)

func walkThroughWallsGlitch():
  uiLayer.walkThroughWallsGlitch()
  if not null_glitch: levelTiles.walkThroughWallsGlitch()
  if fakeLevelTiles and not null_glitch: fakeLevelTiles.walkThroughWallsGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.white_palette, "white_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.white_palette, "white_palette")
  current_sprite_palette = levelTiles.white_palette
  setDoorsSpriteFrame(29)



var followers = []
func trySpawnFollowers():
  var numKeys = global.getThingFromAllLevelZonez("key")
  if numKeys != null:
    for _i in range(numKeys):
      spawnKeyFollower(
        player.global_transform.origin + Vector3(
          stepify(rand_range(-1.0, 1.0), 0.125),
          stepify(rand_range(0.5, 1.5), 0.125), 
          0))
          
  var numAngelTadpoles = global.getThingFromAllLevelZonez("angelTadpole")
  if numAngelTadpoles != null:
    for _i in range(numAngelTadpoles):
      spawnAngelTadpole(
        player.global_transform.origin + Vector3(
          stepify(rand_range(-1.0, 1.0), 0.125),
          stepify(rand_range(0.5, 1.5), 0.125), 
          0
        ))

var tadpoleRes = preload("res://sceneObjects/Enemies/TadpoleEnemy.tscn")
func spawnAngelTadpole(starting_position):
  var tadpole = tadpoleRes.instance()
  self.add_child(tadpole)
  tadpole.global_transform.origin = starting_position

  followers.push_back(tadpole)
  return tadpole

var keyFollowerRes = preload("res://sceneObjects/KeyFollower.tscn")
func spawnKeyFollower(starting_position):
  var keyFollower = keyFollowerRes.instance()
  self.add_child(keyFollower)
  keyFollower.global_transform.origin = starting_position
  # this is dumb but whatever
  if not trySpawnSpecialKey(keyFollower, global.KeyItem.FISH):
    if not trySpawnSpecialKey(keyFollower, global.KeyItem.PYRAMID):
      if not trySpawnSpecialKey(keyFollower, global.KeyItem.SHROOM):
        trySpawnSpecialKey(keyFollower, global.KeyItem.CAT)

  var target = followers[-1] if followers.size() > 0 else player
  keyFollower.gameMoverTarget = weakref(target)
  followers.push_back(keyFollower)

var key_items_spawned = {}
func trySpawnSpecialKey(keyFollower, keyType):
  if not global.memory.has("key_items") or not global.memory["key_items"].has(keyType):
    return false
  if key_items_spawned.has(keyType):
    return false
  if global.memory["key_items"][keyType] == global.ItemState.GOT_IT:
    keyFollower.makeMeSpecial(keyType)
    key_items_spawned[keyType] = true
    return true


var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
func summonSmokeClouds(pos, num_clouds, play_sound = false, is_glitchy = false, override_palette = global.grey_palette):
  for _i in range(num_clouds):
    var newSmokeCloud = smokeCloudRes.instance()
    add_child(newSmokeCloud)
    newSmokeCloud.global_transform.origin.x = pos.x + rand_range(-1, 1)
    newSmokeCloud.global_transform.origin.y = pos.y + rand_range(-1, 1)
    newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
    
    if play_sound:
      newSmokeCloud.tryPlaySound()
      play_sound = false

    if is_glitchy:
        var new_material = newSmokeCloud.get_material_override().duplicate()
        new_material.set_shader_param("enable_glitch", "true")
        new_material.set_shader_param("target_palette", global.weird_base_palette)
        newSmokeCloud.set_material_override(new_material.duplicate())
    elif override_palette != global.grey_palette:
      var new_material = newSmokeCloud.get_material_override().duplicate()
      new_material.set_shader_param("target_palette", override_palette)
      newSmokeCloud.set_material_override(new_material.duplicate())

func flipGravity():
  player.grav *= -1
  # level.player.mySprite.flip_v = not level.player.mySprite.flip_v
  # level.player.broomSpriteVisible.flip_v = not level.player.broomSpriteVisible.flip_v
  player.spriteContainer.rotation_degrees.x += 180
  player.spriteContainer.rotation_degrees.x = fmod(player.spriteContainer.rotation_degrees.x, 360)

  if player.grav < 0:
    player.spriteContainer.get_node("InnerSpriteContainer").translation.z -= 1
  else:
    player.spriteContainer.get_node("InnerSpriteContainer").translation.z += 1

func clearOtherGrabbers():
  var grabbers = self.get_tree().get_nodes_in_group("grabber")
  for grabber in grabbers:
    grabber.hookTarget = null
