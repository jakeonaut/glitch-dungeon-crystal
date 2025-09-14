extends Node

onready var uiLayer = get_node("../../UILayer") if has_node("../../UILayer") else get_node("UILayer") if has_node("UILayer") else get_node("../../Viewport2/UILayer") if has_node("../../Viewport2/UILayer") else get_node("../../Viewport3/UILayer")
onready var player = get_node("Player")
onready var levelTiles = get_node("LevelTiles")
onready var fakeLevelTiles = get_node("FakeLevelTiles") if has_node("FakeLevelTiles") else null
onready var gameCamera = get_node("GameCamera")
# onready var ditherPaletteEffectRect = get_node("../../ScreenEffects/DitherPaletteEffectRect")
onready var screenEffectsContainer = get_node("../../ScreenEffects")
onready var glitchScreenEffect = get_node("../../ScreenEffects/GlitchEffectRect")
onready var ditherPaletteEffectRect2 = get_node("../../Viewport2/ScreenEffects/DitherPaletteEffectRect")
onready var paletteSwapColorBlindEffectRect2 = get_node("../../Viewport2/ScreenEffects/PaletteSwapEffectRect") 
onready var basicCrtEffectRect2 = get_node("../../Viewport2/ScreenEffects/BasicCrtEffectRect")
onready var viewportTexture = get_node("../../ViewportTexture")
onready var viewport2Texture = get_node("../../Viewport2/ViewportTexture")
onready var viewport2or3 = get_node("../../Viewport3") if has_node("../../Viewport3") else get_node("../../Viewport2")
var current_sprite_palette = global.grey_palette
export var player_message = "???"
export var is_chicken_room = false

export var dont_glitch_tiles = false
export var show_crt_effect = false
export var show_dither_effect = false
var ditherPaletteEffectRectMaterial = preload("res://materials/DitherPaletteEffectRect.tres")

export(int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var starting_glitch_type
# will always activate regardless of this variable at start of game, but if this value is true, will activate an override the existing player glitch type
export var should_glitch_activate = false 
export var null_glitch = false
# TODO(jaketrower): need to make this work with grimoire

# IFNDEF FakeLevelTiles.gd (if we get much more scripts doing this, put it in global)
export(int, "DUNGEON", "HOUSE", "FOREST", "ALIEN", "DESERT", "GLITCH_WORLD", "BEACH", "POISON_FOREST", "POISON_HOUSE", "AUTUMN_FOREST", "PRIMORDIAL_OOZE", "TOMB", "FARM_HOUSE") var tileset_type 

export var spellbook_forbidden = false
# TODO(jaketrower): Make a debug global section???
export var has_spellbook_page = false
export var has_glitched_grimoire = false
export(Array, int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var spellbook_spells = []

export var display_title = "???"
export var doesnt_have_broom = false
var has_room_initialized = false
export var pacman_wrapping = false
export var weird_pacman_wrapping = false
var malwareDragonflyRes = preload("res://sceneObjects/Buggies/MalwareDragonfly.tscn")

var gameFrameBackgroundRes = preload("res://sceneObjects/GameFrameBackground.tscn")

func _ready():
  has_room_initialized = false
  # stupid workaround https://godotengine.org/qa/23950/_ready-call-order-is-reversed-from-typical-inheritance#:~:text=When%20inheriting%2C%20typically%20the%20child,the%20parent%2C%20then%20the%20child.
  _ready_impl()
  # ditherPaletteEffectRect2.material = ditherPaletteEffectRectMaterial

export var is_randomizing = false
# this will be a map of global.GlitchForm => weakref(instance)
var grandmaStatueCatalogue = {}
func resetGrandmaStatues():
  var grandmaStatues = get_tree().get_nodes_in_group("grandma_statue")
  for i in range(len(grandmaStatues)):
    var grandmaStatue = grandmaStatues[i]
    summonSmokeClouds(grandmaStatue.global_transform.origin, 2, true, true)
    grandmaStatue.visible = false
    grandmaStatue.glitch_form = grandmaStatue.original_glitch_form
    grandmaStatue.resetPositionInASecond()

  reindexGrandmaStatueCatalogue()

func reindexGrandmaStatueCatalogue(is_start_of_level = false):
  grandmaStatueCatalogue = {}
  var grandmaStatues = get_tree().get_nodes_in_group("grandma_statue")
  for i in range(len(grandmaStatues)):
    var grandmaStatue = grandmaStatues[i]
    if is_start_of_level:
      grandmaStatue.preprocessGlitchFormTeleportation()
    if grandmaStatueCatalogue.has(grandmaStatue.glitch_form):
      pass # TODO(jaketrower): should probably NULLIFY if is_start_of_level
    else:
      grandmaStatueCatalogue[grandmaStatue.glitch_form] = weakref(grandmaStatue)

var should_offset_ui = false 
func _ready_impl():
  # if not "0_1Haven" in self.getLevelName() and not global.memory["glitch_world"]:
  #   self.purifyAllFragileBrickSolids(false)

  if not global.memory.has("roomPath") and not "MainMenu" in self.getLevelName() and not "IntroVideo" in self.getLevelName():
    global.has_started_game = true
    global.has_really_started_game = true
    if not "0_0" in self.getLevelName() or "Fish" in self.getLevelName():
      global.okay_really_really_started_game = true

  global.isOnMainMenu = false
  has_room_initialized = false
  get_node("..").audio_listener_enable_3d = true

  global.activeInteractor = null # somewhat of a failsafe
  set_process(true)

  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  if not self.has_node("../../Viewport2/UILayer") and self.has_node("UILayer"):
    self.remove_child(uiLayer)
    self.get_node("../../Viewport2").add_child_below_node(viewport2Texture, uiLayer)
  if not self.has_node("../../Viewport2/UILayer") and self.has_node("../../UILayer"):
    self.get_node("../..").remove_child(uiLayer)
    self.get_node("../../Viewport2").add_child_below_node(viewport2Texture, uiLayer)
  # should_offset_ui = true
  uiLayer.offset = Vector2(0, 0)
  uiLayer.betaBuildLabel.rect_position.x = 510
  uiLayer.edgeDistortion.offset = Vector2(0, 0)
  uiLayer.textBoxes.rect_position = Vector2(0, 0)
  screenEffectsContainer.offset = Vector2(320, 28)
  
  if not get_tree().get_root().has_node("Game/GameFrameBackground"):
    viewportTexture.rect_position = Vector2(320, 28)
  tryToAddGameFrameBackground()

  viewportTexture.texture = viewport2or3.get_texture()

  if global.memory.has("current_glitch") and not should_glitch_activate:
    # if global.memory["mp"] > 0 or global.memory["max_mp"] == 0:
    player.applyGlitch(global.memory["current_glitch"], true)
  if global.spellCastPauseIndex:
    player.spellCastPauseIndex = global.spellCastPauseIndex
  reindexGrandmaStatueCatalogue(true)
  
  global.memory["tutorial_spellbookPage"] = false
  tryInitializeFromDebug()
    
  if global.memory["has_gotten_broom"] > 0:
    if global.malware_infected:
      player.malware_infected = true
      var newMalwareDragonfly = malwareDragonflyRes.instance()
      newMalwareDragonfly.original_pos = player.global_transform.origin
      newMalwareDragonfly.target_pos = newMalwareDragonfly.original_pos
      self.add_child(newMalwareDragonfly)
      newMalwareDragonfly.global_transform.origin = player.global_transform.origin
      newMalwareDragonfly.do_i_belong_here = false
      newMalwareDragonfly.is_following_player = true
      newMalwareDragonfly.smallInteractionArea.remove_from_group("bug")
    player.getABroom()
  if doesnt_have_broom and global.memory["has_gotten_broom"] < 2:
    global.memory["broom"] = false
    global.memory["has_gotten_broom"] = 0
  # elif not doesnt_have_broom:
  #   player.getABroom()
  #   global.memory["has_gotten_broom"] = 2

  displayMessageText("")

  player.changeOutfit(global.memory["currOutfit"], false)

  if global.memory.has("grav_direction") and global.memory["grav_direction"] < 0:
    if global.isRespawning:
      global.memory["grav_direction"] = 1
    else:
      flipGravity(-1)
  
  tryToRespawn()
  global.tryInitializeLevelZone(self.getLevelZoneName(), true)
  levelTiles.removeRemovedTiles()
  levelTiles.setTileset(tileset_type, false)
  levelTiles.buildRandomTiles()
  if global.memory["currLevelZone"] != global.currLevelZone and not global.memory["glitch_world"]:
    uiLayer.setDisplayTitle(global.getDisplayTitle(self.getLevelZoneName()))
  tryShowUIElements()
  trySpawnFollowers()
  for sprite in [player.mySprite, player.grandmaHatSprite, player.grandmaHandSprite]:
    sprite.material_override.set_shader_param("black_offset", 1)
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
  for sprite in [player.mySprite, player.grandmaHatSprite, player.grandmaHandSprite]:
    sprite.get_material_override().set_shader_param("enable_glitch", false)
    sprite.get_material_override().set_shader_param("enable_remove_skin_tone", false)
  if global.memory["mushroom_soul"] > 0 and global.memory["mushroom_soul_ver"] == 0:
    global.memory["mushroom_soul_ver"] = 1
    player.sayThis(tr("NPC.Secret.2") + "\n" + tr("NPC.Treasure.9"))
  elif player_message != "???":
    player.sayThis(player_message)

  player.transformation = global.memory["transformation"] if global.memory.has("transformation") else player.TransformationState.NORMAL
  player.properlyApplyTransformation()
  has_room_initialized = true
  global.setHaveIBeenToLevel(self)
  if not "EndCredits" in getShortLevelName():
    global.setLevelZoneStartTime()
  # if not global.userSettings["gles3"]:
  #   convertAll3dSpritesFromGles3ToGles2()

  if is_chicken_room:
    player.getChickenInfected()
    player.chicken_timer = -player.chicken_time_limit * 4


var hasGameFrameBackground = false
func tryToAddGameFrameBackground():
  var gameTree = get_tree().get_root().get_node("Game")
  if not gameTree.has_node("GameFrameBackground"):
    var newGameBackground = gameFrameBackgroundRes.instance()
    gameTree.add_child_below_node(viewport2or3, newGameBackground)
  hasGameFrameBackground = true

func randomizeARandomGameFrameBgSprite():
  var gameTree = get_tree().get_root().get_node("Game")
  if gameTree.has_node("GameFrameBackground"):
    var randomSpriteNum = (randi() % 120) + 1
    var bgSprite = gameTree.get_node("GameFrameBackground/Sprites/BgSprite" + str(randomSpriteNum))
    bgSprite.totallyRandomizeFrame()

func tryInitializeFromDebug():
  return
  if global.memory["initialized_from_debug"]:
    pass
  else:
    global.memory["initialized_from_debug"] = true
    global.memory["priestess"] = 0
    if (has_spellbook_page or has_glitched_grimoire) and not global.memory.has("spellbookPage"):
      global.memory["spellbookPage"] = []
      for spellbook_spell in spellbook_spells:
        global.memory["spellbookPage"].push_back(spellbook_spell)
      player.applyGlitch(global.memory["spellbookPage"][0] if global.memory["spellbookPage"].size() > 0 else global.GlitchForm.NORMAL)
    else:
      player.applyGlitch(starting_glitch_type)
    if has_glitched_grimoire or global.memory["glitched_grimoire"]:
      global.memory["glitched_grimoire"] = true
      global.memory["spellbookPage"] = [global.GlitchForm.FEATHER, global.GlitchForm.LADDER, global.GlitchForm.FLOOR, global.GlitchForm.INVISIBLE]

      # debug "hack" to set angel_statues on debug_initialization
      # # set for tutorial dungeon
      # global.tryInitializeLevelZone("gd1TutorialDungeon")
      # global.setLevelZoneThing("angel_statue", 
      #   ["tutorial dungeon", "res://levels/EndlessFantasy/gd1TutorialDungeon/0_1Haven.tscn"])
      # # set for tadpole bog
      # global.tryInitializeLevelZone("gd1FishingVillage")
      # global.setLevelZoneThing("angel_statue", 
      #   ["tadpole bog", "res://levels/EndlessFantasy/gd1FishingVillage/AnglerFishBossRoom.tscn"])
      # # set for mushroom forest
      # global.tryInitializeLevelZone("gd1ToxicJungle")
      # global.setLevelZoneThing("angel_statue", 
      #   ["moldy dogwoods", "res://levels/EndlessFantasy/gd1ToxicJungle/BabaYagaBossRoom.tscn"])
      # # set for cricket caves
      # global.tryInitializeLevelZone("gd1ShiftingSandLand")
      # global.setLevelZoneThing("angel_statue", 
      #   ["cricket caves", "res://levels/EndlessFantasy/gd1ShiftingSandLand/ClaydolBossRoom.tscn"])
      # # set for dream temple
      # global.tryInitializeLevelZone("gd1CrystalTower")
      # global.setLevelZoneThing("angel_statue", 
      #   ["elder temple", "res://levels/EndlessFantasy/gd1CrystalTower/HighPriestessRoom.tscn"])
      # # reset levelZone
      # global.currLevelZone = self.getLevelZoneName()

# var gles3Shader = preload("res://shaders/Sprite3D.shader")
# var gles2Shader = preload("res://shaders/Sprite3D_gles2.shader")

# func convertAll3dSpritesFromGles3ToGles2(fromNode = null):
#   if fromNode == null: fromNode = self
#   for node in fromNode.get_children():
#     if node is Sprite3D:
#       convertSprite3dFromGles3ToGles2(node)
#     convertAll3dSpritesFromGles3ToGles2(node)

# func convertAll3dSpritesFromGles2ToGles3(fromNode = null):
#   if fromNode == null: fromNode = self
#   for node in fromNode.get_children():
#     if node is Sprite3D:
#       convertSprite3dFromGles2ToGles3(node)
#     convertAll3dSpritesFromGles2ToGles3(node)

# func convertSprite3dFromGles3ToGles2(sprite):
#   if not sprite.material_override or not sprite.material_override is ShaderMaterial:
#     return
#   if not sprite.material_override.shader or sprite.material_override.shader != gles3Shader:
#     return
#   # var texture_albedo = sprite.material_override.get_shader_param("texture_albedo")
#   # var base_palette = sprite.material_override.get_shader_param("base_palette")
#   # var target_palette = sprite.material_override.get_shader_param("target_palette")
#   sprite.material_override.shader = gles2Shader
#   # sprite.material_override.set_shader_param("texture_albedo", texture_albedo)
#   # sprite.material_override.set_shader_param("base_palette", base_palette)
#   # sprite.material_override.set_shader_param("target_palette", target_palette)

# func convertSprite3dFromGles2ToGles3(sprite):
#   if not sprite.material_override or not sprite.material_override is ShaderMaterial:
#     return
#   if not sprite.material_override.shader or not sprite.material_override.shader == gles2Shader:
#     return
#   sprite.material_override.shader = gles3Shader

func _process(delta):
  delta = delta * global.time_dilation_multiplier
  if should_adjust_player:
    adjustPlayerForEdgeTransition()

  ditherPaletteEffectRect2.visible = global.userSettings["show_crt_effect"] and show_dither_effect
  basicCrtEffectRect2.visible = global.userSettings["show_crt_effect"] and show_crt_effect
  paletteSwapColorBlindEffectRect2 = global.userSettings["show_palette_swap_color_blind_filter"]
  if Input.is_action_pressed("toggle_fullscreen"):
    return

  if global.isGamepadConnected():
    if not global.was_gamepad_connected:
      global.was_last_pressed_input_type = global.ControllerType.GAMEPAD
    global.was_gamepad_connected = true
  else:
    if global.was_gamepad_connected:
      global.was_last_pressed_input_type = global.ControllerType.KEYBOARD
    global.was_gamepad_connected = false
  processPauseMenu()
  processGrandmaStatueSavePoints()
  processBossHealth(delta)

func canOpenPauseMenu():
  return true

func processPauseMenu():
  if player.isItWeird() or player.isItKindaWeird():
    return

  if global.shouldRenderAsCinematic:
    global.is_reading_input = false
    global.is_reading_keyboard_input = false
    global.is_reading_controller_input = false
    if global.isPauseMenuOpen:
      global.isPauseMenuOpen = false
      player.unpauseSound.play()
      restartMusic()
  else:
    if not global.isPauseMenuOpen and global.activeInteractor == null and canOpenPauseMenu():
      if Input.is_action_just_pressed("ui_start"):
        yield(get_tree().create_timer(0.1), "timeout")
        glitchScreenEffect.visible = false
        uiLayer.pauseMenu.pauseMenuState = uiLayer.pauseMenu.PauseMenuState.NORMAL
        uiLayer.pauseMenu.normalOptionIndex = 0
        uiLayer.pauseMenu.shouldUpdateMenuText = true
        global.isPauseMenuOpen = true
        global.pauseGame = true
        player.pauseSound.play()
        playMenuMusic()
      elif (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen")) and not global.isOnMainMenu:
        yield(get_tree().create_timer(0.1), "timeout")
        if global.has_really_started_game:
          glitchScreenEffect.visible = false
          uiLayer.pauseMenu.pauseMenuState = uiLayer.pauseMenu.PauseMenuState.INVENTORY
          uiLayer.pauseMenu.selectedGlitchSprite = -1
          uiLayer.pauseMenu.inventoryOptionIndex = 4 if Input.is_action_pressed("open_map") and global.memory["has_map_item"] else 0
          uiLayer.pauseMenu.mapRect.rect_scale = Vector2(1, 1)
          uiLayer.pauseMenu.inventoryOptionIndexX = 0
          global.isPauseMenuOpen = true
          global.pauseGame = true
          player.inventorySound.play()

func redrawMap():
  uiLayer.pauseMenu.forceRedrawMap()

var closest_extra_life = null
func processGrandmaStatueSavePoints():
  return
  # var last_closest_extra_life = closest_extra_life
  # closest_extra_life = null

  # var extra_lives = []
  # var grandmaStatues = get_tree().get_nodes_in_group("grandma_statue")
  # for i in range(len(grandmaStatues)):
  #   if grandmaStatues[i].is_extra_life:
  #     grandmaStatues[i].is_extra_life_active = false
  #     extra_lives.push_back(grandmaStatues[i])

  # if len(extra_lives) > 0:
  #   closest_extra_life = extra_lives[0]
  #   var closest_extra_life_dist = player.global_transform.origin.distance_to(extra_lives[0].global_transform.origin)
  #   for i in range(1, len(extra_lives)):
  #     var extra_life = extra_lives[i]
  #     var distance = player.global_transform.origin.distance_to(extra_life.global_transform.origin)
  #     if distance < closest_extra_life_dist:
  #       closest_extra_life_dist = distance
  #       closest_extra_life = extra_life
  #   if closest_extra_life != last_closest_extra_life:
  #     # closest_extra_life.saveSound.play()
  #     pass
  #   closest_extra_life.is_extra_life_active = true

func displayMessageText(message):
  uiLayer.displayMessageText(message)

func displaySpellMessageText(message):
  if global.isOnMainMenu:
    return
  uiLayer.displaySpellMessageText(message)

func getLevelManagerCoords():
  return transition.mapManager.getCoords(self.getLevelName())

func saveTheGame(message = "saving!!"):
  uiLayer.displaySavingText(message)
  global.memory["transformation"] = self.player.transformation
  global.memory["roomPath"] = self.getLevelName()
  global.saveGame(self)

func saveUserSettings(message = "saving settings.."):
  uiLayer.displaySavingText(message)
  global.saveUserSettings()
    
func playMenuMusic():
  musicPlayer.tryToPlay(musicPlayer.restZonePlayer)

func restartMusic():
  musicPlayer.conductFromScenePath(getLevelName())

func stopAllMusic():
  musicPlayer.stopAll()
  
func tryShowUIElements():
  # TODO(jaketrower): Could be better method to fetch this without a weird node search in the ready_impl()
  uiLayer.initiateCutsceneRenderLogic()

func overrideLevelRespawnEvent():
  pass
  
func setUpRoomInitializationOverride():
  pass

var overrideRoomPath = null
func getLevelName(allow_override = false):
  if allow_override and overrideRoomPath != null:
    return overrideRoomPath
  return get_node("../..").get_filename()
  
func getShortLevelName():
  return global.getShortLevelName(getLevelName())

func getLevelZoneName():
  return global.getLevelZoneName(getLevelName())

func isAnyMoleDigging():
  var moles = get_tree().get_nodes_in_group("mole")
  for mole in moles:
    if mole.mole_state == mole.MoleState.DIG:
      return true
  return false

func tryToRespawn():
  self.gameCamera.initial_target = player.get_node("CameraTarget")
  if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
    global.activeInteractor.stopInteract()
  global.activeInteractor = null
  global.pauseMoveInput = false
  if not global.grannyEnteringRoom:
    global.pauseGame = false

  var found_door = null
  var found_broth = null

  if global.isEnteringRoom and not global.isRespawning:
    player.num_horizontal_input_presses = global.num_horizontal_input_presses
    if global.memory.has("roomPath"):
      var door_path = global.memory["roomPath"]
      var doors = get_tree().get_nodes_in_group("doors")
      for door in doors:
        if door.path == door_path:
          found_door = door
          break
      # if we didn't find a door, try to find last entered door in the room
      # useful for weird triangle circuit navigation
      if found_door == null and global.roomEdgeVector == null:
        for door in doors:
          if global.getStaticLevelZoneLevelVar(self, door) == door.DoorMemory.LAST_ENTERED:
            found_door = door
            break
      if not found_door and self.has_node("ShortcutDoor"):
        found_door = self.get_node("ShortcutDoor")
      var broths = get_tree().get_nodes_in_group("broths")
      for broth in broths:
        if broth.path == door_path:
          found_broth = broth
          break
  elif global.isRespawning:
    player.num_horizontal_input_presses = global.num_horizontal_input_presses
    global.memory["hp"] = global.memory["max_hp"]
    # if closest_extra_life != null and closest_extra_life.isActive():
    #   global.memory["hp"] = 1 # respawning at a grandma statue, don't restore bag
    #   if player.respawn_key_hp != null:
    #     global.memory["hp"] = player.respawn_key_hp
    #     player.respawn_key_hp = null
    #   # player.global_transform.origin = closest_extra_life.global_transform.origin + Vector3(0, -1, 0)
    #   # gameCamera.rotation_degrees.y = global.cameraRotation
    #   # player.last_grounded_pos = Vector3(player.global_transform.origin)
    #   # yield(TempTimer.idle_frame(self), "timeout") # idk why i gotta do this
    #   # player.global_transform.origin = closest_extra_life.global_transform.origin
    #   summonSmokeClouds(closest_extra_life.global_transform.origin, 3, true, true)
    #   closest_extra_life.queue_free()
    #   player.saveSound.play()
    if global.memory.has("savePoint") and global.memory.has("savedRoomPath") and global.memory["savedRoomPath"] == getLevelName():
      var savePoint = get_node(global.memory["savePoint"])
      if savePoint != null:
        player.global_transform.origin = savePoint.global_transform.origin + Vector3(0, -1, 0)
      gameCamera.rotation_degrees.y = global.cameraRotation
      player.last_grounded_pos = Vector3(player.global_transform.origin)
      yield(TempTimer.idle_frame(self), "timeout") # idk why i gotta do this
      if savePoint != null:
        player.global_transform.origin = savePoint.global_transform.origin
        player.properlyApplyTransformation()
    elif global.memory.has("active_save_point_x") and global.memory.has("savedRoomPath") and global.memory["savedRoomPath"] == getLevelName():
      player.global_transform.origin = Vector3(
        global.memory["active_save_point_x"], 
        global.memory["active_save_point_y"], 
        global.memory["active_save_point_z"])
      player.properlyApplyTransformation()
      if global.isEnteringRoom:
        player.global_transform.origin.y += 1
      gameCamera.rotation_degrees.y = global.cameraRotation
      player.last_grounded_pos = Vector3(player.global_transform.origin)
    elif global.memory.has("room_save_point_x"):
      player.global_transform.origin = Vector3(
        global.memory["room_save_point_x"], 
        global.memory["room_save_point_y"], 
        player.global_transform.origin.z)
      gameCamera.rotation_degrees.y = global.cameraRotation
      player.last_grounded_pos = Vector3(player.global_transform.origin)
    elif global.memory.has("savedRoomPath") and global.memory["savedRoomPath"] != getLevelName():
      if global.memory.has("active_save_point_x"):
        # transition.fast_fade_to(global.memory["savedRoomPath"])
        global.isEnteringRoom = true
        global.pauseGame = true
        transition.die_fade_to(global.memory["savedRoomPath"])
        return
    elif global.memory.has("roomPath"):
      var door_path = global.memory["roomPath"]
      var doors = get_tree().get_nodes_in_group("doors")
      for door in doors:
        door.tryProcessGlitchedPath()
        if door.path == door_path:
          found_door = door
          break
    else:
      player.global_transform.origin = player.spawn_origin

  if global.set_camera_position_on_respawn:
    player.camera_target_y_pos = player.global_transform.origin.y
    player.cameraTarget.global_transform.origin.y = player.camera_target_y_pos
    gameCamera.setCameraPositionNow()
    global.set_camera_position_on_respawn = false

  global.justAngelWarped = global.angelWarping
  if global.memory.has("on_ground"): player.on_ground = global.memory["on_ground"]
  if global.isEnteringRoom:
    # levelTiles.tryToSayTidy()
    if global.malware_infected:
      player.malware_infected = true
    player.getABroom() # after malware infection so we don't improperly give a broom
    if global.isBrothWarping and found_broth:
      transition.reverse_granny_teleport()
      found_broth.spitSound.play()
      found_broth.spitSound2.play()
      found_broth.has_popped_out = true
      player.visible = true
      player.tumbleFall(Vector2(0, 1), true)
      player.global_transform.origin.x = found_broth.global_transform.origin.x
      player.global_transform.origin.y = found_broth.global_transform.origin.y + 1.0
    elif global.angelWarping:
      var angelStatues = get_tree().get_nodes_in_group("angel_statue")
      if len(angelStatues) > 0:
        player.global_transform.origin = angelStatues[0].global_transform.origin
    elif found_door:
      found_door.land(true, true)
    elif global.roomEdgeVector != null:
      should_adjust_player = true
      remembered_edge_vector = global.roomEdgeVector
      transition.reverse_fade()
    elif not global.memory.has("savedRoomPath") or global.memory["savedRoomPath"] != getLevelName():
      player.global_transform.origin = player.spawn_origin
    if not found_door:
      if global.grannyEnteringRoom or global.isBrothWarping:
        transition.reverse_granny_teleport()
      else:
        transition.reverse_fade()
    gameCamera.setCameraPositionNow()

  global.respawnVarTimerHack = 0
  global.hasJustEnteredRoom = global.isEnteringRoom
  global.isEnteringRoom = false
  global.grannyEnteringRoom = false
  global.isBrothWarping = false
  global.angelWarping = false
  global.roomEdgeVector = null
  global.isRespawning = false
  global.shouldRenderAsCinematic = false

  player.visible = true
  player.unsmack()
  player.aniPlayer.play("land")
  player.camera_target_y_pos = player.global_transform.origin.y
  player.pauseAnimation = false
  self.overrideLevelRespawnEvent()
  if global.memory["zora_flippers"] and global.memory["zora_flippers"] < 3:
    global.memory["zora_flippers"] = 3
  player.nesting_doll_state = global.memory["nesting_doll"]
  player.updateNestingDoll(global.memory["nesting_doll"]) # TODO(jaketrower): need to remember nesting doll position?
  player.getABroom()
  
  # if player.nesting_doll_state == global.NestingDoll.BABY:
  #   player.shroomAniPlayer.stop(true)
  #   player.shroomAniPlayer.clear_queue()
  #   player.shroomAniPlayer.play("shrink", -1, 999)

  # if player.nesting_doll_state != global.NestingDoll.GRANDMA:
  #   player.mySprite.flip_h = not player.mySprite.flip_h
  #   player.summonFallenBroom(false, true)
  #   player.mySprite.flip_h = not player.mySprite.flip_h

var should_adjust_player = false
var remembered_edge_vector = null

func adjustPlayerForEdgeTransition():
  if global.memory.has("player_flip_h"):
    player.mySprite.flip_h = global.memory["player_flip_h"]
    global.memory.erase("player_flip_h")
  if global.memory.has("feather_jump_timer"):
    player.feather_jump_timer = global.memory["feather_jump_timer"]
    global.memory.erase("feather_jump_timer")
  if global.memory.has("linear_velocity"):
    player.linear_velocity = global.memory["linear_velocity"]
    global.memory.erase("linear_velocity")

  var LANDING_MARGIN = 2

  var xDiff = gameCamera.rightmost_x - gameCamera.leftmost_x
  if global.memory.has("player_x_offset"):
    var prevXDiff = global.memory["prevXDiff"]
    player.global_transform.origin.x = gameCamera.leftmost_x + (xDiff*global.memory["player_x_offset"])
    if prevXDiff > xDiff:
      while player.checkSolidTilesOnMe():
        player.global_transform.origin.x += 1
    else:
      while player.checkSolidTilesOnMe():
        player.global_transform.origin.x -= 1
    global.memory.erase("player_x_offset")
    global.memory.erase("prevXDiff")
  elif remembered_edge_vector.x > 0:
    player.global_transform.origin.x = gameCamera.leftmost_x + LANDING_MARGIN
  elif remembered_edge_vector.x < 0:
    player.global_transform.origin.x = gameCamera.rightmost_x - LANDING_MARGIN
  else:
    player.global_transform.origin.x = gameCamera.leftmost_x + (xDiff/2)

  var yDiff = gameCamera.topmost_y - gameCamera.botmost_y
  if global.memory.has("player_y_offset"):
    var prevYDiff = global.memory["prevYDiff"]
    player.global_transform.origin.y = gameCamera.botmost_y + (yDiff*global.memory["player_y_offset"])
    if prevYDiff > yDiff:
      while player.checkSolidTilesOnMe():
        player.global_transform.origin.y += 1
    else:
      while player.checkSolidTilesOnMe():
        player.global_transform.origin.y -= 1
    global.memory.erase("player_y_offset")
    global.memory.erase("prevYDiff")
  elif remembered_edge_vector.y > 0:
    player.global_transform.origin.y = gameCamera.botmost_y + LANDING_MARGIN
    if player.glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
      player.global_transform.origin.y += 1
  elif remembered_edge_vector.y < 0:
    player.global_transform.origin.y = gameCamera.topmost_y - LANDING_MARGIN
  else:
    player.global_transform.origin.y = gameCamera.topmost_y + (yDiff/2)
  player.last_grounded_pos = Vector3(player.global_transform.origin)
  should_adjust_player = false
  remembered_edge_vector = null



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
  # get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.grey_palette, "grey_palette")
  # get_tree().call_group("dark_sprite","changeSpriteColorPalette", global.dark_grey_palette, "grey_palette")
  # get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.grey_palette, "grey_palette")
  current_sprite_palette = levelTiles.grey_palette
  setDoorsSpriteFrame(4)
  

func floorGlitch():
  uiLayer.floorGlitch()
  if not null_glitch: levelTiles.floorGlitch()
  # if fakeLevelTiles and not null_glitch: fakeLevelTiles.floorGlitch()
  # get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.red_palette, "red_palette")
  # get_tree().call_group("dark_sprite","changeSpriteColorPalette", global.dark_red_palette, "grey_palette")
  # get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.red_palette, "red_palette")
  current_sprite_palette = levelTiles.red_palette
  setDoorsSpriteFrame(9)

func featherGlitch():
  uiLayer.featherGlitch()
  if not null_glitch: levelTiles.featherGlitch()
  # if fakeLevelTiles and not null_glitch: fakeLevelTiles.featherGlitch()
  # get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.green_palette, "green_palette")
  # get_tree().call_group("dark_sprite","changeSpriteColorPalette", global.dark_green_palette, "grey_palette")
  # get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.green_palette, "green_palette")
  current_sprite_palette = levelTiles.green_palette
  setDoorsSpriteFrame(14)

func ladderGlitch():
  uiLayer.ladderGlitch()
  if not null_glitch: levelTiles.ladderGlitch()
  # if fakeLevelTiles and not null_glitch: fakeLevelTiles.ladderGlitch()
  # get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.yellow_palette, "yellow_palette")
  # get_tree().call_group("dark_sprite","changeSpriteColorPalette", global.dark_yellow_palette, "grey_palette")
  # get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.yellow_palette, "yellow_palette")
  current_sprite_palette = levelTiles.yellow_palette
  setDoorsSpriteFrame(19)

func invisibleGlitch():
  uiLayer.invisibleGlitch()
  if not null_glitch: levelTiles.invisibleGlitch()
  # if fakeLevelTiles and not null_glitch: fakeLevelTiles.invisibleGlitch()
  # get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.black_palette, "black_palette")
  # get_tree().call_group("dark_sprite","changeSpriteColorPalette", global.dark_black_palette, "grey_palette")
  # get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.black_palette, "black_palette")
  current_sprite_palette = levelTiles.black_palette
  setDoorsSpriteFrame(24)

func walkThroughWallsGlitch():
  uiLayer.walkThroughWallsGlitch()
  if not null_glitch: levelTiles.walkThroughWallsGlitch()
  # if fakeLevelTiles and not null_glitch: fakeLevelTiles.walkThroughWallsGlitch()
  # get_tree().call_group("sprite","changeSpriteColorPalette", levelTiles.white_palette, "white_palette")
  # get_tree().call_group("dark_sprite","changeSpriteColorPalette", global.dark_white_palette, "grey_palette")
  # get_tree().call_group("glitchSprite","changeSpriteColorPalette", levelTiles.white_palette, "white_palette")
  current_sprite_palette = levelTiles.white_palette
  setDoorsSpriteFrame(29)

var followers = []
func tryResetFollowers():
  for follower in followers:
    if follower != null and follower.get_ref() != null:
      follower.queue_free()
  followers = []
  trySpawnFollowers()

func trySpawnFollowers():
  spawnPetFollower(
    player.global_transform.origin + Vector3(
      stepify(rand_range(-1.0, 1.0), 0.125),
      stepify(rand_range(0.5, 1.5), 0.125), 
      0))

  # spawnSpecialKeyFollowers(
  #   player.global_transform.origin + Vector3(
  #     stepify(rand_range(-1.0, 1.0), 0.125),
  #     stepify(rand_range(0.5, 1.5), 0.125),
  #     0
  #   )
  # )
  var numKeys = global.memory["key"] if global.memory.has("key") else null
  if numKeys != null:
    for _i in range(numKeys):
      spawnKeyFollower(
        player.global_transform.origin + Vector3(
          stepify(rand_range(-1.0, 1.0), 0.125),
          stepify(rand_range(0.5, 1.5), 0.125), 
          0))

  # var numEggs = global.getThingFromAllLevelZonez("angelEgg")
  # if numEggs != null:
  #   for _i in range(numEggs):
  #     spawnAngelEggFollower(
  #       player.global_transform.origin + Vector3(
  #         stepify(rand_range(-1.0, 1.0), 0.125),
  #         stepify(rand_range(0.5, 1.5), 0.125), 
  #         0))

  # if getLevelName().find("0_1Haven") > 0 or getLevelName().find("EndOfDemo") > 0:
  #   var numAngelTadpoles = global.getThingFromAllLevelZonez("angelTadpole")
  #   if numAngelTadpoles != null:
  #     for _i in range(numAngelTadpoles):
  #       spawnAngelTadpole(
  #         player.global_transform.origin + Vector3(
  #           stepify(rand_range(-1.0, 1.0), 0.125),
  #           stepify(rand_range(0.5, 1.5), 0.125), 
  #           0
  #         ))

func purifyAllWeakEnemies(summon_smoke_clouds = true):
  var weak_enemies = self.get_tree().get_nodes_in_group("weak_enemies")
  for i in range(weak_enemies.size()):
    var weak_enemy_area = weak_enemies[i]
    var weak_enemy = weak_enemy_area.get_node("..")
    if weak_enemy.isActive() and not weak_enemy.am_i_dying:
      weak_enemy.ouchies(weak_enemy.global_transform.origin)
      if i < weak_enemies.size() - 1:
        if weak_enemy.dieSound != null:
          weak_enemy.dieSound.stop()
        if weak_enemy.notDieSound != null:
          weak_enemy.notDieSound.stop()
      if summon_smoke_clouds:
        self.summonSmokeClouds(weak_enemy.global_transform.origin, 3, false, true)

func purifyAllFragileBrickSolids(summon_smoke_clouds = true):
  levelTiles.purifyAllFragileBrickSolids(summon_smoke_clouds)

var tadpoleRes = preload("res://sceneObjects/Enemies/TadpoleEnemy.tscn")
func spawnAngelTadpole(starting_position):
  var tadpole = tadpoleRes.instance()
  self.add_child(tadpole)
  tadpole.global_transform.origin = starting_position

  followers.push_back(weakref(tadpole))
  return tadpole

var keyFollowerRes = preload("res://sceneObjects/KeyFollower.tscn")
func spawnSpecialKeyFollowers(starting_position):
  if trySpawnSpecialKey(global.KeyItem.FISH):
    var keyFollower = spawnKeyFollower(starting_position)
    keyFollower.makeMeSpecial(global.KeyItem.FISH)
  if trySpawnSpecialKey(global.KeyItem.PYRAMID):
    var keyFollower = spawnKeyFollower(starting_position)
    keyFollower.makeMeSpecial(global.KeyItem.PYRAMID)
  if trySpawnSpecialKey(global.KeyItem.SHROOM):
    var keyFollower = spawnKeyFollower(starting_position)
    keyFollower.makeMeSpecial(global.KeyItem.SHROOM)
  if trySpawnSpecialKey(global.KeyItem.CAT):
    var keyFollower = spawnKeyFollower(starting_position)
    keyFollower.makeMeSpecial(global.KeyItem.CAT)

var key_items_spawned = {}
func trySpawnSpecialKey(keyType):
  if not global.memory.has("key_items") or not global.memory["key_items"].has(keyType):
    return false
  if key_items_spawned.has(keyType):
    return false
  if global.memory["key_items"][keyType] == global.ItemState.GOT_IT:
    key_items_spawned[keyType] = true
    return true

func spawnKeyFollower(starting_position):
  var keyFollower = keyFollowerRes.instance()
  self.add_child(keyFollower)
  keyFollower.global_transform.origin = starting_position

  var target = followers[-1] if followers.size() > 0 else null
  keyFollower.gameMoverTarget = target if target != null else weakref(player)
  followers.push_back(weakref(keyFollower))
  return keyFollower

var angelEggFollowerRes = preload("res://sceneObjects/AngelEggFollower.tscn")
func spawnAngelEggFollower(starting_position):
  var angelEggFollower = angelEggFollowerRes.instance()
  self.add_child(angelEggFollower)
  angelEggFollower.global_transform.origin = starting_position

  var target = followers[-1] if followers.size() > 0 else null
  angelEggFollower.gameMoverTarget = target if target != null else weakref(player)
  followers.push_back(weakref(angelEggFollower))

var petChickenFollowerRes = preload("res://sceneObjects/PetChickenFollower.tscn")
var petBabushkaCatFollowerRes = preload("res://sceneObjects/BabushkaCatFollower.tscn")
var petSnakeFollowerRes = preload("res://sceneObjects/PetSnakeFollower.tscn")
func spawnPetFollower(starting_position):
  var currPet = global.memory["currPet"]
  if currPet == null or currPet == global.PetFollower.NONE:
    return

  
  var petFollowerRes = null
  var how_many = 1
  
  match currPet:
    global.PetFollower.CHICKEN:
      petFollowerRes = petChickenFollowerRes
    global.PetFollower.THREE_CHICKENS:
      how_many = 3
      petFollowerRes = petChickenFollowerRes
    global.PetFollower.CAT_BABUSHKA:
      petFollowerRes = petBabushkaCatFollowerRes
    global.PetFollower.RED_SNAKE:
      petFollowerRes = petSnakeFollowerRes

  for _i in range(0, how_many):
    var petFollower = petFollowerRes.instance()
    self.add_child(petFollower)
    petFollower.global_transform.origin = starting_position
    var target = followers[-1] if followers.size() > 0 else null
    petFollower.gameMoverTarget = target if target != null else weakref(player)
    followers.push_back(weakref(petFollower))


var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
func summonSmokeClouds(pos, num_clouds, play_sound = false, is_glitchy = false, override_palette = global.grey_palette, horizontal = 0, vertical = 1):
  var smokeClouds = []
  for _i in range(num_clouds):
    var newSmokeCloud = smokeCloudRes.instance()
    add_child(newSmokeCloud)
    newSmokeCloud.global_transform.origin.x = pos.x + rand_range(-1, 1)
    newSmokeCloud.global_transform.origin.y = pos.y + rand_range(-1, 1)
    if horizontal != 0:
      newSmokeCloud.target_x = newSmokeCloud.global_transform.origin.x + rand_range(horizontal, 3*horizontal)
    else:
      newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(vertical, 3*vertical)
    
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
    smokeClouds.push_back(newSmokeCloud)
  return smokeClouds

func flipGravity(specific_dir = null):
  if specific_dir == 1:
    player.grav = player.PLAYER_GRAV
  elif specific_dir == -1:
    player.grav = -player.PLAYER_GRAV
  elif specific_dir == null:
    player.grav = -1 * player.PLAYER_GRAV
  else:
    player.grav = specific_dir
  if player.grav >= 0:
    global.memory["grav_direction"] = 1
  elif player.grav < 0:
    global.memory["grav_direction"] = -1

func clearOtherGrabbers(gameMover):
  var grabbers = self.get_tree().get_nodes_in_group("grabber")
  for grabber in grabbers:
    if grabber.hookTarget != null and grabber.hookTarget.get_ref() == gameMover:
      grabber.hookTarget = null

func getBoss():
  if self.has_node("HighPriestessBoss"):
    return get_node("HighPriestessBoss")
  elif has_node("ClaydolBoss"):
    return get_node("ClaydolBoss")
  elif has_node("BabaYagaBoss"):
    return get_node("BabaYagaBoss")
  elif has_node("AnglerFishBoss"):
    return get_node("AnglerFishBoss")
  return null

var animate_life_timer = 0
var animate_life_time_limit = 5
var num_visible_boss_lives = 0
var kill_cheat_code_timer = 0
var kill_cheat_code_time_limit = 30
var kill_cheat_code_counter = 0
func processBossHealth(delta):
  var whichBoss = getBoss()
  if whichBoss == null or whichBoss.getMyVariable() == 0:
    uiLayer.livesRect.visible = false
    return

  animate_life_timer += (delta*11)
  uiLayer.livesRect.visible = true
  if kill_cheat_code_counter <= 5:
    if kill_cheat_code_counter > 0:
      kill_cheat_code_timer += (delta*11)
      if kill_cheat_code_timer >= kill_cheat_code_time_limit:
        kill_cheat_code_timer = 0
        kill_cheat_code_counter = 0
    if Input.is_action_just_pressed("CHEAT_Y"):
      kill_cheat_code_counter = 1
      kill_cheat_code_timer = 0
    elif Input.is_action_just_pressed("CHEAT_U"):
      if kill_cheat_code_counter == 1:
        kill_cheat_code_counter += 1
        kill_cheat_code_timer = 0
      else:
        kill_cheat_code_counter = 0
        kill_cheat_code_timer = 0
    elif Input.is_action_just_pressed("CHEAT_N"):
      if kill_cheat_code_counter == 2 or kill_cheat_code_counter == 4:
        kill_cheat_code_counter += 1
        kill_cheat_code_timer = 0
      else:
        kill_cheat_code_counter = 0
        kill_cheat_code_timer = 0
    elif Input.is_action_just_pressed("CHEAT_I"):
      if kill_cheat_code_counter == 3:
        kill_cheat_code_counter += 1
        kill_cheat_code_timer = 0
      else:
        kill_cheat_code_counter = 0
        kill_cheat_code_timer = 0
    elif Input.is_action_just_pressed("CHEAT_G"):
      if kill_cheat_code_counter == 5:
        kill_cheat_code_counter = 99
        whichBoss.yaBeatMe()
        global.lifeUISound2.play()
      else:
        kill_cheat_code_counter = 0
        kill_cheat_code_timer = 0
    
  # if health_cheat_code_counter < 3:
  #   if Input.is_action_just_pressed("health_cheat_code"):
  #     health_cheat_code_counter += 1
  #   if health_cheat_code_counter >= 3:
  #     whichBoss.num_granny_hits += 3
  #     global.lifeUISound2.play()
  # if kill_cheat_code_counter < 7:
  #   if Input.is_action_just_pressed("kill_cheat_code"):
  #     kill_cheat_code_counter += 1
  #   if kill_cheat_code_counter >= 7:
  #     whichBoss.yaBeatMe()
  #     global.lifeUISound2.play()
  # a bit esoteric logic given that we're hard coding it

  if animate_life_timer >= animate_life_time_limit*1 and animate_life_timer < animate_life_time_limit*4 and not uiLayer.grannyLifeSprite1.visible:
    global.lifeUISound.play()
  uiLayer.grannyLifeSprite1.visible = whichBoss.num_granny_hits >= 1 and (animate_life_timer >= animate_life_time_limit*1)
  if animate_life_timer >= animate_life_time_limit*2 and animate_life_timer < animate_life_time_limit*4 and not uiLayer.grannyLifeSprite2.visible:
    global.lifeUISound.play()
  uiLayer.grannyLifeSprite2.visible = whichBoss.num_granny_hits >= 2 and (animate_life_timer >= animate_life_time_limit*2)
  if animate_life_timer >= animate_life_time_limit*3 and animate_life_timer < animate_life_time_limit*4 and not uiLayer.grannyLifeSprite3.visible:
    global.lifeUISound.play()
  uiLayer.grannyLifeSprite3.visible = whichBoss.num_granny_hits >= 3 and (animate_life_timer >= animate_life_time_limit*3)
  uiLayer.grannyLifeSprite4.visible = whichBoss.num_granny_hits >= 4 and (animate_life_timer >= animate_life_time_limit*4)
  uiLayer.grannyLifeSprite5.visible = whichBoss.num_granny_hits >= 5 and (animate_life_timer >= animate_life_time_limit*5)
  uiLayer.grannyLifeSprite6.visible = whichBoss.num_granny_hits >= 6 and (animate_life_timer >= animate_life_time_limit*6)
  uiLayer.grannyLifeSprite7.visible = whichBoss.num_granny_hits >= 7 and (animate_life_timer >= animate_life_time_limit*7)
  uiLayer.grannyLifeSprite8.visible = whichBoss.num_granny_hits >= 8 and (animate_life_timer >= animate_life_time_limit*8)
  uiLayer.grannyLifeSprite9.visible = whichBoss.num_granny_hits >= 9 and (animate_life_timer >= animate_life_time_limit*9)

  # a bit esoteric logic given that we're hard coding it
  if whichBoss.MAX_NUM_HITS == 6:
    if animate_life_timer >= animate_life_time_limit*4 and animate_life_timer < animate_life_time_limit*20 and not uiLayer.bossLifeSprite1.visible:
      global.lifeUISound.play()
    uiLayer.bossLifeSprite1.visible = whichBoss.num_hits < whichBoss.MAX_NUM_HITS and (animate_life_timer >= animate_life_time_limit*4)
    if animate_life_timer >= animate_life_time_limit*5 and animate_life_timer < animate_life_time_limit*20 and not uiLayer.bossLifeSprite2.visible:
      global.lifeUISound.play()
    uiLayer.bossLifeSprite2.visible = whichBoss.num_hits <= 4 and (animate_life_timer >= animate_life_time_limit*5)
    if animate_life_timer >= animate_life_time_limit*6 and animate_life_timer < animate_life_time_limit*20 and not uiLayer.bossLifeSprite3.visible:
      global.lifeUISound.play()
    uiLayer.bossLifeSprite3.visible = whichBoss.num_hits <= 3 and (animate_life_timer >= animate_life_time_limit*6)
    if animate_life_timer >= animate_life_time_limit*8 and animate_life_timer < animate_life_time_limit*20 and not uiLayer.bossLifeSprite4.visible:
      global.lifeUISound.play()
    uiLayer.bossLifeSprite4.visible = whichBoss.num_hits <= 2 and (animate_life_timer >= animate_life_time_limit*8)
    if animate_life_timer >= animate_life_time_limit*10 and animate_life_timer < animate_life_time_limit*20 and not uiLayer.bossLifeSprite5.visible:
      global.lifeUISound.play()
    uiLayer.bossLifeSprite5.visible = whichBoss.num_hits <= 1 and (animate_life_timer >= animate_life_time_limit*10)
    if animate_life_timer >= animate_life_time_limit*12 and animate_life_timer < animate_life_time_limit*20 and not uiLayer.bossLifeSprite6.visible:
      global.lifeUISound.play()
    uiLayer.bossLifeSprite6.visible = whichBoss.num_hits == 0 and (animate_life_timer >= animate_life_time_limit*12)
  elif whichBoss.MAX_NUM_HITS == 3:
    uiLayer.bossLifeSprite1.visible = whichBoss.num_hits < whichBoss.MAX_NUM_HITS and (animate_life_timer >= animate_life_time_limit*4)
    uiLayer.bossLifeSprite2.visible = whichBoss.num_hits <= 1 and (animate_life_timer >= animate_life_time_limit*5)
    uiLayer.bossLifeSprite3.visible = whichBoss.num_hits <= 0 and (animate_life_timer >= animate_life_time_limit*6)
    uiLayer.bossLifeSprite4.visible = false # whichBoss.num_hits == 0 and (animate_life_timer >= animate_life_time_limit*7)
    uiLayer.bossLifeSprite5.visible = false
    uiLayer.bossLifeSprite6.visible = false

  # Text!
  # uiLayer.bossTextLabel.visible = whichBoss.num_hits == whichBoss.MAX_NUM_HITS
  
