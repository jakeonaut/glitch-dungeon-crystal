extends Node

onready var uiLayer = get_node("../../UILayer") if has_node("../../UILayer") else get_node("UILayer")
onready var player = get_node("Player")
onready var levelTiles = get_node("LevelTiles")
onready var fakeLevelTiles = get_node("FakeLevelTiles") if has_node("FakeLevelTiles") else null
onready var gameCamera = get_node("GameCamera")
onready var ditherPaletteEffectRect = get_node("../../ScreenEffects/DitherPaletteEffectRect")
onready var glitchScreenEffect = get_node("../../ScreenEffects/GlitchEffectRect")
var current_sprite_palette = global.grey_palette

export var show_crt_effect = false

export(int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var starting_glitch_type
# IFNDEF FakeLevelTiles.gd (if we get much more scripts doing this, put it in global)
export(int, "DUNGEON", "HOUSE", "FOREST", "ALIEN", "DESERT", "GLITCH_WORLD", "BEACH", "POISON_FOREST") var tileset_type 

export var spellbook_forbidden = false
# TODO(jaketrower): Make a debug global section???
export var has_spellbook_page = false
export(Array, int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var spellbook_spells = []
export var how_much_mp = 5
export var how_much_hp = 1
var has_ever_set_camera_position = false

export var display_title = "???"

func _ready():
  # stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
  _ready_impl()

func _ready_impl():
  get_node("..").audio_listener_enable_3d = true

  global.activeInteractor = null # somewhat of a failsafe
  set_process_input(true)
  set_process(true)

  yield(get_tree(), "idle_frame")
  yield(get_tree(), "idle_frame")
  
  levelTiles.setTileset(tileset_type, false)
  levelTiles.buildRandomTiles()
  
  if has_spellbook_page and not global.memory.has("spellbookPage"):
    global.memory["inventory"] = [global.Inventory.GRIMOIRE]
    global.memory["spellbookPage"] = []
    for spellbook_spell in spellbook_spells:
      global.memory["spellbookPage"].push_back(spellbook_spell)
  global.memory["tutorial_spellbookPage"] = false

  if global.memory["max_mp"] == 0 and global.memory["max_mp"] < how_much_mp:
    global.memory["max_mp"] = how_much_mp
    global.memory["mp"] = global.memory["max_mp"]

  if global.memory["max_hp"] == 1 and global.memory["max_hp"] < how_much_hp:
    global.memory["max_hp"] = how_much_hp
    global.memory["hp"] = global.memory["max_hp"]
    
  if global.memory.has("current_glitch"):
    if global.memory["mp"] > 0 or global.memory["max_mp"] == 0:
      player.applyGlitch(global.memory["current_glitch"], true)
  else:
    player.applyGlitch(starting_glitch_type, true)

  if global.memory.has("player_costume"):
    player.wearCostume(global.memory["player_costume"])

  restartMusic()
  tryShowUIElements()
  tryToRespawn()
  setUpRoomInitializationOverride()

  global.activeThrowableObject = null
  if global.activeThrowableObjectPath != null:
    # resource is loaded at compile time
    var carriedThrowableObject = load(global.activeThrowableObjectPath).instance() 
    add_child(carriedThrowableObject)
    carriedThrowableObject.activate()
    carriedThrowableObject.spawn_origin = carriedThrowableObject.global_transform.origin
  else:
    pass
  global.activeThrowableObjectPath = null
  player.mySprite.get_material_override().set_shader_param("enable_glitch", false)
  player.mySprite.get_material_override().set_shader_param("enable_remove_skin_tone", false)

func _process(delta):
  delta = delta * global.time_dilation_multiplier

  if not show_crt_effect:
    ditherPaletteEffectRect.visible = false
  if Input.is_action_pressed("toggle_fullscreen"):
    return

  if global.memory.has("inventory") and not global.pauseGame and not global.pauseMoveInput and global.activeInteractor == null:
    if Input.is_action_just_pressed("ui_start") and getLevelName().find("MainMenu") < 0:
    #   global.canChangeSongPitch = not global.canChangeSongPitch
    #   global.canGlitchScreen = not global.canGlitchScreen
    #   global.crtScreenEffects = not global.crtScreenEffects
      global.isInventoryOpen = true
      global.pauseGame = true
  elif global.isInventoryOpen:
    if Input.is_action_just_pressed("ui_start"):
      global.isInventoryOpen = false
      global.pauseGame = false
      if global.activeInteractor:
        global.activeInteractor.hideTextbox()
      global.activeInteractor = null
    if Input.is_action_just_pressed("jump_button") or Input.is_action_just_pressed("sub_action_button"):
      player.textContainer.bbText = uiLayer.getInventoryBBText()
      player.textContainer.setVars()
      player.textBox.interact()
    

  
  var amt = 6.0
  ditherPaletteEffectRect.material.set_shader_param("g_mult", 1.0 + (amt - amt*global.time_dilation_multiplier))
  ditherPaletteEffectRect.material.set_shader_param("b_mult", -1.0 - (amt - amt*global.time_dilation_multiplier))
  # if Input.is_action_just_pressed("place_tile_button"):
  #     var player_position = player.global_transform.origin + (player.facing * 2)
  #     var grid_cell = levelTiles.world_to_map(player_position)
  #     levelTiles.set_cell_item(grid_cell.x, grid_cell.y, grid_cell.z, 0)

func saveTheGame(message = "saving (not really)"):
  uiLayer.displaySavingText(message)
  global.saveGame()
    
func restartMusic():
  # update music
  musicPlayer.conductFromScenePath(getLevelName())
  
func tryShowUIElements():
  # TODO(jaketrower): Could be better method to fetch this without a weird node search in the ready_impl()
  uiLayer.setDisplayTitle(display_title)

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
  # print("LEVEL NAMAE: " + get_tree().get_root().get_node("Game").get_filename())
  return get_tree().get_root().get_node("Game").get_filename()
  
func getShortLevelName():
  var longLevelName = getLevelName()
  return longLevelName.substr(13, longLevelName.length() - 18)

func tryToRespawn():
  global.memory["hp"] = global.memory["max_hp"]
  self.gameCamera.initial_target = player.get_node("CameraTarget")
  if global.activeInteractor != null:
    global.activeInteractor.stopInteract()
  global.activeInteractor = null
  global.pauseMoveInput = false
  global.pauseGame = false

  var found_door = null
  if global.isEnteringRoom:
    if global.memory.has("lastDoor"):
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
      player.last_grounded_y = player.global_transform.origin.y
    elif global.memory.has("savedRoomPath") and global.memory["savedRoomPath"] != getLevelName():
      if global.memory.has("active_save_point_x"):
        transition.path = global.memory["savedRoomPath"]
        transition.change_scene()
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
    found_door.land()
  elif not global.memory.has("savedRoomPath") or global.memory["savedRoomPath"] != getLevelName():
    player.global_transform.origin = player.spawn_origin
  if not has_ever_set_camera_position:
    gameCamera.setCameraPositionNow()
    has_ever_set_camera_position = true

  global.respawnVarTimerHack = 0
  global.hasJustEnteredRoom = global.isEnteringRoom
  global.isEnteringRoom = false
  global.isRespawning = false

  self.overrideLevelRespawnEvent()


func setDoorsSpriteFrame(frame):
  var doors = get_tree().get_nodes_in_group("doors")
  for door in doors:
    if door.dont_recolor_me:
      continue
    door.get_node("Sprite3D2").frame = frame

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
  levelTiles.normalGlitch()
  if fakeLevelTiles:
    fakeLevelTiles.normalGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.grey_palette, "grey_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.grey_palette, "grey_palette")
  current_sprite_palette = levelTiles.grey_palette
  setDoorsSpriteFrame(4)
  

func floorGlitch():
  uiLayer.floorGlitch()
  levelTiles.floorGlitch()
  if fakeLevelTiles:
    fakeLevelTiles.floorGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.red_palette, "red_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.red_palette, "red_palette")
  current_sprite_palette = levelTiles.red_palette
  setDoorsSpriteFrame(9)

func featherGlitch():
  uiLayer.featherGlitch()
  levelTiles.featherGlitch()
  if fakeLevelTiles:
    fakeLevelTiles.featherGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.green_palette, "green_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.green_palette, "green_palette")
  current_sprite_palette = levelTiles.green_palette
  setDoorsSpriteFrame(14)

func ladderGlitch():
  uiLayer.ladderGlitch()
  levelTiles.ladderGlitch()
  if fakeLevelTiles:
    fakeLevelTiles.ladderGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.yellow_palette, "yellow_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.yellow_palette, "yellow_palette")
  current_sprite_palette = levelTiles.yellow_palette
  setDoorsSpriteFrame(19)

func invisibleGlitch():
  uiLayer.invisibleGlitch()
  levelTiles.invisibleGlitch()
  if fakeLevelTiles:
    fakeLevelTiles.invisibleGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.black_palette, "black_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.black_palette, "black_palette")
  current_sprite_palette = levelTiles.black_palette
  setDoorsSpriteFrame(24)

func walkThroughWallsGlitch():
  uiLayer.walkThroughWallsGlitch()
  levelTiles.walkThroughWallsGlitch()
  if fakeLevelTiles:
    fakeLevelTiles.walkThroughWallsGlitch()
  get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.white_palette, "white_palette")
  get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.white_palette, "white_palette")
  current_sprite_palette = levelTiles.white_palette
  setDoorsSpriteFrame(29)
