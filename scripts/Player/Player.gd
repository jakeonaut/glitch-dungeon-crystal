extends "PlayerGameMover.gd"

onready var pauseMenu = get_node("PauseMenu/MenuBox") if has_node("PauseMenu/MenuBox") else null
onready var screenShakeSound = get_node("Sounds/ScreenShakeSound")
onready var hurtSound = get_node("Sounds/HurtSound")
onready var hurt2Sound = get_node("Sounds/HurtSound2")
onready var hurt3Sound = get_node("Sounds/HurtSound3")
onready var broomSound = get_node("Sounds/BroomSound")
onready var noBroomSound = get_node("Sounds/NoBroomSound")
onready var broomReverseSound = get_node("Sounds/BroomReverseSound")
onready var errorSound = get_node("Sounds/ErrorSound")
onready var blinkSound = get_node("Sounds/BlinkSound")
onready var transformSound = get_node("Sounds/TransformSound")
onready var noSpellSound = get_node("Sounds/NoSpellSound")
onready var returnSound = get_node("Sounds/ReturnSound")
onready var grannyLandSound = get_node("Sounds/GrannyLandSound")
onready var poisonWaterSound = get_node("Sounds/PoisonWaterSound")
onready var reversePoisonWaterSound = get_node("Sounds/PoisonWaterReverseSound")
onready var footstepSound = get_node("Sounds/FootstepSound")
onready var waterFootstepSound = get_node("Sounds/WaterFootstepSound")
onready var sandFootstepSound = get_node("Sounds/SandFootstepSound")
onready var tileFootstepSound = get_node("Sounds/TileFootstepSound")
onready var hookSound = get_node("Sounds/HookSound")
onready var reelSound = get_node("Sounds/ReelSound")
onready var saveSound = get_node("Sounds/SaveSound")
onready var miniCubeCrystal = get_node("miniCubeCrystal")
onready var mpNumSprite = get_node("MPNumSprite")
onready var mpNumSprite2 = get_node("MPNumSprite/MPNumSprite2")
onready var mushroomSpriteAnimated = get_node("SpriteContainer/Sprite3DMushroomAnimated")
onready var mushroomSpriteVisible = get_node("SpriteContainer/Sprite3DMushroomVisible")
onready var mushroomSpriteAniPlayer = get_node("SpriteContainer/Sprite3DMushroomAnimated/AnimationPlayer")
onready var exclamationSprite = get_node("ExclamationSprite")
onready var exclamationAniPlayer = get_node("ExclamationSprite/AnimationPlayer")
var malwareBugSpriteRes = preload("res://sceneObjects/Buggies/MalwareBugSprite.tscn")

var summonedBroomRes = preload("res://sceneObjects/SummonedBroom.tscn")
var fallenBroomRes = preload("res://sceneObjects/FallenBroom.tscn")
var bubbleRes = preload("res://sceneObjects/BubbleSpell.tscn")
var broom_cooldown_timer = 0
var broom_cooldown_time_limit = 10

onready var spriteContainer = get_node("SpriteContainer")
onready var broomSpriteAnimated = get_node("SpriteContainer/Sprite3DBroomAnimated")

onready var enchantedBagSpriteAnimated = get_node("SpriteContainer/Sprite3DBagAnimated")
onready var enchantedBagSpriteVisible = get_node("SpriteContainer/Sprite3DBagVisible")

onready var textContainer = get_node("TextContainer")
onready var textBox = get_node("TextContainer/TextBox")

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0
var should_turn_on_glitch_screen_effects = true
var glitch_tickle_time_limit = 10
var can_cast_spell_timer = 0
var can_cast_spell_time_limit = 10
var poison_timer = 0
var poison_time_limit = 28
var unpoison_timer = 0
var unpoison_time_limit = 10

func _ready():
  set_process(true)
  set_physics_process(false)
  if pauseMenu: pauseMenu.hide()

  remembered_walk_speed = walk_speed
  remembered_feather_glitch_walk_speed = feather_glitch_walk_speed
  remembered_invisible_glitch_walk_speed = invisible_glitch_walk_speed
  broomSpriteVisible.get_material_override().set_shader_param("opacity", 1.0)
  broomSpriteAnimated.get_material_override().set_shader_param("opacity", 1.0)
  mySprite.get_material_override().set_shader_param("opacity", 1.0)

# make this work with FLIP GRAVITY (level.flipGravity) (and bubble form uses it too)
func processWallLadderWalking(delta):
  if physics_state == PhysicsState.BEING_TOSSED:
    return false
  var temp = pauseAnimation
  if dig_timer > 0:
    pauseAnimation = true
  .processWallLadderWalking(delta) # super
  pauseAnimation = temp
  can_broomerang_warp = true
  # if pressingMoveLeft():
  #   spriteContainer.rotation_degrees.z = 270
  # elif pressingMoveRight():
  #   spriteContainer.rotation_degrees.z = 90
  if pressingMoveLeft():
    global_transform.origin.x -= 1
    var leftTiles = getTilesLeftOf(levelTiles, 0.1)
    global_transform.origin.x += 1
    for tile_coords in leftTiles:
      if tile_coords == null: continue
      var tile_type = levelTiles.get_cell_item(tile_coords.x, tile_coords.y, tile_coords.z)
      if levelTiles.isTileDissolvingStone(tile_type):
        levelTiles.corrode(tile_coords)
  if pressingMoveRight():
    global_transform.origin.x += 1
    var rightTiles = getTilesRightOf(levelTiles, 0.1)
    global_transform.origin.x -= 1
    for tile_coords in rightTiles:
      if tile_coords == null: continue
      var tile_type = levelTiles.get_cell_item(tile_coords.x, tile_coords.y, tile_coords.z)
      if levelTiles.isTileDissolvingStone(tile_type):
        levelTiles.corrode(tile_coords)

# make this work with FLIP GRAVITY... ? (if it doesnt already)
# @override
func collideWithFloor(local_lv):
  var bottomTiles = getTilesBelow(levelTiles)
  for tile_coords in bottomTiles:
    if tile_coords == null: continue
    var tile_type = levelTiles.get_cell_item(tile_coords.x, tile_coords.y, tile_coords.z)
    if levelTiles.isTileDissolvingStone(tile_type):
      levelTiles.corrode(tile_coords)
    if justPressedDown() and levelTiles.isTileFragileSolid(tile_type) and not smallInteractionArea.is_touching_door:
      glitchTickle()
  return .collideWithFloor(local_lv)

func processNotWallLadderWalking(delta):
  .processNotWallLadderWalking(delta)
  # spriteContainer.rotation_degrees.z = 0
  # if summonedBroom:
  #   summonedBroom.rotation_degrees.z = 0

# @override
func alignMySprite():
  var pixelSize = 0.125 # 0.125 if not malware_infected else 1.0
  if spriteContainer:
    spriteContainer.global_transform.origin.x = stepify(self.global_transform.origin.x, pixelSize)
    spriteContainer.global_transform.origin.y = stepify(self.global_transform.origin.y, pixelSize) + spriteYAlignment

func tryPlayFootstepSound():
  if transformation == TransformationState.MOLE_DIGGING:
    return
  if transformation == TransformationState.UNDERGROUND_RETURNING or transformation == TransformationState.UNDERGROUND:
    return
  if transformation == TransformationState.FISHY:
    return
  if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    return

  if global.isPauseMenuOpen or global.pauseGame:
    return 
  if not (pressingMoveLeft() or pressingMoveRight()):
    return

  if on_ground or glitch_form == global.GlitchForm.LADDER:
    var whichFootStepSound = footstepSound
    if is_touching_water:
      whichFootStepSound = waterFootstepSound
    elif (not (on_ground and not (glitch_form == global.GlitchForm.LADDER and isWalkingIntoWall()))) or (glitch_form == global.GlitchForm.FLOOR and not truly_on_ground):
      whichFootStepSound = sporeSound
    elif level.tileset_type == global.TilesetType.DESERT:
      whichFootStepSound = sandFootstepSound
    elif level.tileset_type == global.TilesetType.DUNGEON:
      whichFootStepSound = tileFootstepSound

    if nesting_doll_state == global.NestingDoll.MATRIARCH:
      whichFootStepSound.pitch_scale = rand_range(0.6, 0.8)
    elif nesting_doll_state == global.NestingDoll.BABY:
      whichFootStepSound.pitch_scale = rand_range(1.2, 1.3)
    else:
      whichFootStepSound.pitch_scale = rand_range(0.9, 1.1)
    if whichFootStepSound == sporeSound or whichFootStepSound == sandFootstepSound:
      whichFootStepSound.pitch_scale *= 2.0
    whichFootStepSound.play()

func applyNextGlitch():
  applyGlitch(global.getNextGlitch(glitch_form))
  
func applyObeliskGlitch(glitch, add_spell_to_grimoire = true):
  var spellToBeForgotten = null
  if applyGlitch(glitch, false):
    if add_spell_to_grimoire and global.memory.has("spellbookPage") and not global.memory["spellbookPage"].has(glitch): # NOT HAS
      var maxSpellbookSize = 2
      if global.memory["glitched_grimoire"]:
        maxSpellbookSize = 3
      if global.memory["glitched_grimoire2"]:
        maxSpellbookSize = 4
      if global.memory["spellbookPage"].size() > 0:
        if global.memory["spellbookPage"].size() >= maxSpellbookSize:
          var spellToBeForgottenIndex = spellCastPauseIndex # - 1
          # NULL OVERRIDE!
          if global.memory["spellbookPage"].has(global.GlitchForm.NORMAL):
            spellToBeForgottenIndex = global.memory["spellbookPage"].find(global.GlitchForm.NORMAL)

          if spellToBeForgottenIndex < 0:
            spellToBeForgottenIndex = global.memory["spellbookPage"].size() - 1
          spellToBeForgotten = global.memory["spellbookPage"][spellToBeForgottenIndex]
          if maxSpellbookSize == 2:
            global.memory["spellbookPage"].pop_at(spellToBeForgottenIndex)
          else:
            global.memory["spellbookPage"][spellToBeForgottenIndex] = glitch
      if maxSpellbookSize == 2 or global.memory["spellbookPage"].size() < maxSpellbookSize:
        # NULL OVERRIDE!
        if global.memory["spellbookPage"].has(global.GlitchForm.NORMAL):
          global.memory["spellbookPage"][global.memory["spellbookPage"].find(global.GlitchForm.NORMAL)] = glitch
        else:
          global.memory["spellbookPage"].push_back(glitch)
      spellCastPauseIndex = global.memory["spellbookPage"].find(glitch)
    if add_spell_to_grimoire and global.memory.has("spellbookPage") and global.memory["spellbookPage"].has(glitch): # HAS
      spellCastPauseIndex = global.memory["spellbookPage"].find(glitch)
  if spellToBeForgotten == global.GlitchForm.NORMAL:
    return null
  return spellToBeForgotten

func isWearing(outfit):
  return global.memory["currOutfit"] == outfit

# also used in AnimationPlayer.broomSmackGlitch
func actuallyApplySpellbookGlitch():
  var spellbookSize = global.memory["spellbookPage"].size() if global.memory.has("spellbookPage") else 0
  if spellbookSize == 0:
    return
  # special case if spellbookSize == 1:
  if spellbookSize == 1 and (spellCastPauseIndex == -1 or spellCastPauseIndex == 1):
    applyGlitch(global.GlitchForm.NORMAL)
    applyObeliskGlitch(global.GlitchForm.NORMAL, false)
    return
  while spellCastPauseIndex < 0:
    spellCastPauseIndex += spellbookSize
  spellCastPauseIndex = spellCastPauseIndex % spellbookSize
  var glitch_type = global.memory["spellbookPage"][spellCastPauseIndex]
  applyGlitch(glitch_type)
  applyObeliskGlitch(glitch_type, false)
    
func applySpellbookGlitch():
  if not global.memory.has("spellbookPage") or global.memory["spellbookPage"].size() <= 0:
    return
  actuallyApplySpellbookGlitch()
  # aniPlayer.stop()
  # aniPlayer.clear_queue()
  # aniPlayer.play("broomSmackGlitch")
  # see actuallyApplySpellbookGlitch(), which is applied by this animation ^^
  # pauseInput = true
  # pauseAnimation = true

func restoreGlitchAndMP():
  if global.memory["mp"] <= 0:
    applyGlitch(global.memory["current_glitch"], true)
  global.memory["mp"] = global.memory["max_mp"]
  
func applyGlitch(glitch, notPlaySound = false):
  # if returning_to_save_point > 0:
  #   return false
  glitchTilesAroundMe(0.25, true)
  nullifySound.stop()
  if not notPlaySound:
    if glitch == self.glitch_form:
      rechargeSound.play()
    else:
      transformSound.pitch_scale = rand_range(0.8, 1.2)
      transformSound.play()
  global.memory["current_glitch"] = glitch
  if glitch != self.glitch_form:
    has_just_glitch_swapped = true
    has_just_glitch_swapped_timer = 0
  var gimmeABroom = false
  if glitch_form == global.GlitchForm.INVISIBLE and glitch != global.GlitchForm.INVISIBLE:
    gimmeABroom = true
  if glitch_form == global.GlitchForm.BUBBLE and glitch != global.GlitchForm.BUBBLE:
    level.flipGravity()
  # mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
  if glitch == global.GlitchForm.NORMAL: self.normalGlitch()
  if glitch == global.GlitchForm.FLOOR: 
    if self.glitch_form == global.GlitchForm.LADDER and (was_just_walking_on_wall or was_walking_into_wall or isWalkingIntoWall()):
      on_ground = true
    floorGlitch()
  if glitch == global.GlitchForm.FEATHER: featherGlitch()
  if glitch == global.GlitchForm.LADDER: ladderGlitch()
  if glitch == global.GlitchForm.INVISIBLE: invisibleGlitch()
  if glitch == global.GlitchForm.WALK_THROUGH_WALLS: walkThroughWallsGlitch()
  if glitch == global.GlitchForm.BUBBLE:
    getBubbleInfected(true)
  if gimmeABroom:
    getABroom()
  return true

func floorGlitch():
  spellbookGlitchSprite.frame = 1
  level.displaySpellMessageText(tr("UI.GlitchSpell.2"))
  glitch_form = global.GlitchForm.FLOOR
  level.floorGlitch()
  changeSpriteColorPalette(global.player_red_palette)
  spellbookGlitchSprite.changeSpriteColorPalette(global.red_palette)
  # should_collide_floor = not (on_ground and not truly_on_ground)

func miniUpwardGust(reverse_immediately = true):
  var upward_gust = 5
  if linear_velocity.y < 0:
    if reverse_immediately:
      linear_velocity.y = 1
      lv.y = 1
      vv = up.dot(lv)
    else:
      linear_velocity.y /= 2
      lv.y /= 2
      vv /= 2
  linear_velocity.y += upward_gust
  lv.y += upward_gust
  vv += upward_gust

func featherGlitch():
  spellbookGlitchSprite.frame = 0
  var ui = level.uiLayer
  if glitch_form != global.GlitchForm.FEATHER and not on_ground and \
     (not ui.spellMessageTextLabel.visible or ui.spell_message_text_timer > 20) and transformation != TransformationState.FISHY and \
     physics_state == PhysicsState.NORMAL:
    miniUpwardGust()
  level.displaySpellMessageText(tr("UI.GlitchSpell.1"))
  glitch_form = global.GlitchForm.FEATHER
  level.featherGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(global.green_dungeon_palette)
  spellbookGlitchSprite.changeSpriteColorPalette(global.green_palette)

func ladderGlitch():
  spellbookGlitchSprite.frame = 2
  level.displaySpellMessageText(tr("UI.GlitchSpell.3"))
  glitch_form = global.GlitchForm.LADDER
  level.ladderGlitch()
  # TODO(jaketrower):
  changeSpriteColorPalette(global.yellow_player_palette)
  spellbookGlitchSprite.changeSpriteColorPalette(global.yellow_palette)

func invisibleGlitch():
  loseBroom()
  spellbookGlitchSprite.frame = 3
  level.displaySpellMessageText(tr("UI.GlitchSpell.4"))
  glitch_form = global.GlitchForm.INVISIBLE
  level.invisibleGlitch()
  changeSpriteColorPalette(global.black_player_palette)
  spellbookGlitchSprite.changeSpriteColorPalette(global.black_palette)

func walkThroughWallsGlitch():
  level.displaySpellMessageText(tr("NPC.Crystal.NULL"))
  glitch_form = global.GlitchForm.WALK_THROUGH_WALLS
  level.walkThroughWallsGlitch()
  changeSpriteColorPalette(global.white_player_palette)
  spellbookGlitchSprite.changeSpriteColorPalette(global.white_palette)

# @override
# func pressingRun():
#   return true
  # if nesting_doll_state == global.NestingDoll.BABY:
  #   return true
  # elif not canRun():
  #   return
  # elif nesting_doll_state == global.NestingDoll.MOM:
  #   return true
  # # elif Input.is_action_pressed("run_button"):
  # #   return true
  # return .pressingRun()

# @override
func canRun():
  var is_giant = nesting_doll_state == global.NestingDoll.MATRIARCH
  return not is_giant

# @override
func canSwim():
  return transformation == TransformationState.FISHY
  
func isWalkingIntoWall():
  if summonedBroom != null:
    return was_walking_into_wall
  else:
    return .isWalkingIntoWall() # super

var hideSmallTextboxTimer = null
func sayThis(message, time_to_clear = 0.0, showYesNo = false):
  if textBox.visible:
    textBox.hideTextbox()
  if hideSmallTextboxTimer != null:
    hideSmallTextboxTimer.stop()
    self.remove_child(hideSmallTextboxTimer)
    hideSmallTextboxTimer.queue_free()
    hideSmallTextboxTimer = null
  textBox.text_final = message
  if time_to_clear > 0:
    textBox.text_final = "[wave][font=res://YosterFontBig.tres]" + message + "[/font][/wave]"
    textBox.tinify()
    textBox.showTextbox()
    hideSmallTextboxTimer = Timer.new()
    hideSmallTextboxTimer.one_shot = true
    hideSmallTextboxTimer.connect("timeout", self, "_on_dialog_timer_timeout_func")
    self.add_child(hideSmallTextboxTimer)
    hideSmallTextboxTimer.start(time_to_clear)
  else:
    textBox.text_final = message
    textBox.untinify()
    textBox.interact()
    global.activeInteractor = textBox
    textBox.showYesNoOptions = showYesNo

func stopTalking():
  _on_dialog_timer_timeout_func()

func _on_dialog_timer_timeout_func():
  textBox.hideTextbox()
  if hideSmallTextboxTimer != null:
    self.remove_child(hideSmallTextboxTimer)
    hideSmallTextboxTimer.queue_free()
    hideSmallTextboxTimer = null

var returning_recover_time = 0
var returning_recover_time_limit = 3
var spriteOpacity = 1.0
var respawn_key_hp = null
func _process(delta):
  # ._process(delta) #NOTE: this super method is called automatically 
  # https://github.com/godotengine/godot/issues/6500

  if Input.is_action_just_pressed("swap_english_and_russian"):
    if global.userSettings["locale"] == "en":
      global.changeLocale("ru", true)
    else:
      global.changeLocale("en", true)

  if is_in_mini_cutscene and Input.is_action_just_pressed("sub_action_button"):
    finishCutsceneIntroAni()
  # is_turn_based = malware_infected and not physics_state == PhysicsState.BEING_TOSSED
  should_always_stop_walking_immediately = malware_infected

  # if nesting_doll_state == global.NestingDoll.BABY and not Input.is_action_pressed("jump_button") and not has_used_magic_lantern:
  #   tryToRevertFromBaby()

  if glitch_form == global.GlitchForm.INVISIBLE and global.memory["broom"]:
    global.memory["broom"] = false
  processSpriteRenderLogic(delta)
  processBroomRenderLogic(delta)
  processBagRenderLogic(delta)
  if global.isEnteringRoom:
    if "nterDoor" in aniPlayer.assigned_animation:
      spellbookGlitchSprite.global_transform.origin.x = self.global_transform.origin.x
      spellbookGlitchSprite.global_transform.origin.y = self.global_transform.origin.y + 1.685 if aniPlayer.assigned_animation == "preEnterDoor" else self.global_transform.origin.y + 1.3
    updateGrandmaHatHandSprites()
    return
  if level.pacman_wrapping:
    camera_target_y_pos = global_transform.origin.y

  if aniPlayer.assigned_animation == "getItem" and not aniPlayer.is_playing():
    getItemFailsafe()

  if Input.is_action_just_pressed("toggle_fullscreen"):
    OS.window_fullscreen = !OS.window_fullscreen
    global.userSettings["fullscreen"] = OS.window_fullscreen
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN if OS.window_fullscreen else Input.MOUSE_MODE_VISIBLE)
    level.saveUserSettings()
    level.uiLayer.pauseMenu.shouldUpdateMenuText = true
  var can_respawn_out_of_pause = not global.pauseGame or (global.activeInteractor != null and not global.shouldRenderAsCinematic)
  if not global.isRespawning and not isItWeird() and not isItKindaWeird() and global.memory["can_force_respawn"] and Input.is_action_just_pressed("restart_key") and not global.isPauseMenuOpen and can_respawn_out_of_pause: # and ritual_state_index < len(global.correct_ritual)-1:
    respawn_key_hp = global.memory["hp"]
    if global.activeInteractor != null:
      global.activeInteractor.hideTextbox()
    tryDieToEnemy(delta, true, true, true)
  
  delta = delta * global.time_dilation_multiplier

  var newSpriteOpacity = spriteOpacity
  if aniPlayer.assigned_animation == "returning":
    newSpriteOpacity = 0.5
  elif transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    newSpriteOpacity = 0.5
  elif glitch_form == global.GlitchForm.INVISIBLE:
    newSpriteOpacity = 1.0
  else:
    newSpriteOpacity = 1.0
  if newSpriteOpacity != spriteOpacity:
    spriteOpacity = newSpriteOpacity
    mySprite.get_material_override().set_shader_param("opacity", spriteOpacity)
    grandmaHatSprite.get_material_override().set_shader_param("opacity", spriteOpacity)
    grandmaHandSprite.get_material_override().set_shader_param("opacity", spriteOpacity)
    grandmaFishHatSprite.get_material_override().set_shader_param("opacity", spriteOpacity)
    broomSpriteVisible.get_material_override().set_shader_param("opacity", spriteOpacity)
  if "nterDoor" in aniPlayer.assigned_animation:
    spellbookGlitchSprite.global_transform.origin.x = self.global_transform.origin.x
    if grav > 0:
      spellbookGlitchSprite.global_transform.origin.y = self.global_transform.origin.y + 1.685 if aniPlayer.assigned_animation == "preEnterDoor" else self.global_transform.origin.y + 1.5
    else:
      spellbookGlitchSprite.global_transform.origin.y = self.global_transform.origin.y - 1.685 if aniPlayer.assigned_animation == "preEnterDoor" else self.global_transform.origin.y - 1.5
  else:
    if grav > 0:
      spellbookGlitchSprite.global_transform.origin.y = self.global_transform.origin.y + 1.935
    else:
      spellbookGlitchSprite.global_transform.origin.y = self.global_transform.origin.y - 1.935
    if mySprite.flip_h:
      spellbookGlitchSprite.global_transform.origin.x = self.global_transform.origin.x - 0.25
    else:
      spellbookGlitchSprite.global_transform.origin.x = self.global_transform.origin.x + 0.25
  spellbookGlitchSprite.visible = glitch_form != global.GlitchForm.NORMAL and global.userSettings["colorblindMode"] and transformation == TransformationState.NORMAL# and getOutfitIsSpellGlitchSpriteVisible(global.memory["currOutfit"])

  processSleepyLogic(delta)
  if global.isPauseMenuOpen:
    updateGrandmaHatHandSprites()
    return

  if aniPlayer.assigned_animation == "broomSmackGlitch":
    linear_velocity = Vector3(0, 0, 0)
    lv = linear_velocity
    vv = 0
    hv = Vector3(0, 0, 0)

  if returning_to_save_point == 1:
    linear_velocity = Vector3(0, 0, 0)
    lv = linear_velocity
    vv = 0
    hv = Vector3(0, 0, 0)
    fall_timer = 0
    global_transform.origin = moveToward2D(global_transform.origin, last_grounded_pos, delta * 22)
    if camera_target_y_pos < global_transform.origin.y:
      camera_target_y_pos = global_transform.origin.y
    if compare2D(global_transform.origin, last_grounded_pos):
      global_transform.origin = last_grounded_pos
      returning_to_save_point = 2
  if returning_to_save_point == 2:
    if aniPlayer.assigned_animation == "returning":
      aniPlayer.play("land")
    returning_recover_time += (delta*11)
    if returning_recover_time >= returning_recover_time_limit:
      returning_recover_time = 0
      ignorePhysics = false
      pauseAnimation = false
      pauseSelf = false
      physics_state = PhysicsState.NORMAL
      returning_to_save_point = 0
      global.pauseMoveInput = false
      global.pauseGame = false
  if not processGlitchHurtRecovery(delta):
    updateGrandmaHatHandSprites()
    return

  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.IGNORE_PHYSICS:
    updateGrandmaHatHandSprites()
    return
  processBubbleLogic(delta)
  processBeingTossedLogic(delta)
  processTeleportationLogic(delta)
  processCastingLogic(delta)
  processBroomLogic(delta)
  processBagLogic(delta)
  processMushroomLogic(delta)
  processFishyLogic(delta)
  processMoleLogic(delta)
  processChickenLogic(delta)
  processCurseLogic(delta)
  # processAngelStatueRitual(delta)
    
  # doTimeDilation(real_delta)

  if can_cast_spell_timer < can_cast_spell_time_limit:
    can_cast_spell_timer += (delta*22)

  # if Input.is_action_just_pressed("action_button") and can_cast_spell_timer >= can_cast_spell_time_limit:
  #   applySpellbookGlitch()
  if global.memory["debug"] and Input.is_action_just_pressed("debug_glitch_button"):
    applyNextGlitch()
  if global.memory["debug"] and Input.is_action_just_pressed("debug_toggle_spellbook"):
    if global.memory["glitched_grimoire"]:
      global.memory["glitched_grimoire"] = false
      global.memory.erase("spellbookPage")
      spellCastPauseIndex = 0
    elif global.memory.has("spellbookPage"):
      global.memory["glitched_grimoire"] = true
      global.memory["spellbookPage"] = [GlitchForm.FLOOR, GlitchForm.FEATHER, GlitchForm.LADDER, GlitchForm.INVISIBLE]
    else:
      global.memory["spellbookPage"] = [glitch_form] if glitch_form != GlitchForm.NORMAL else []
  if global.memory["debug"] and Input.is_action_just_pressed("debug_upgrade_broom"):
    if global.memory["broomerang"] == 0:
      global.memory["broomerang"] = 1
    elif global.memory["broomerang"] < 2:
      global.memory["broomerang"] = 2
  if global.memory["debug"] and Input.is_action_just_pressed("debug_more_crystals"):
    var num_keys = global.memory["key"] if global.memory.has("key") else null
    if num_keys == null:
      global.memory["key"] = 0
    global.memory["key"] += 2
    if global.getThingFromAllLevelZonez("num_mini_crystal_cubes") < 150:
      if global.getThingFromAllLevelZonez("num_mini_crystal_cubes") == 0:
        global.memory["tutorial_gem"] = 1
        level.uiLayer.get_node("GlitchStatusRect").visible = true
        level.uiLayer.get_node("GlitchStatusRect").rect_scale = Vector2(1.5, 1.5)
        level.uiLayer.get_node("GlitchStatusRect").rect_position = Vector2(200, 325)
      global.incrementLevelZoneThing("num_mini_crystal_cubes", 150)
      
    # global.memory["clean_crystals"] = 99
    
  tryDieToOffscreenCamera(delta)
      
  if gimme_mini_crystal_cubes > 0:
    gimme_mini_crystal_cubes_timer += (delta*22)
    if gimme_mini_crystal_cubes_timer >= gimme_mini_crystal_cubes_time_limit:
      gimme_mini_crystal_cubes_timer = 0
      gimme_mini_crystal_cubes -= 1
      var newCrystalCube = miniCubeCrystal.duplicate()
      newCrystalCube.visible = true
      add_child(newCrystalCube)

  if lose_mini_crystal_cubes > 0:
    lose_mini_crystal_cubes_timer += (delta*22)
    if lose_mini_crystal_cubes_timer >= lose_mini_crystal_cubes_time_limit:
      lose_mini_crystal_cubes_timer = 0
      lose_mini_crystal_cubes -= 1
      var newCrystalCube = miniCubeCrystal.duplicate()
      newCrystalCube.is_negative = true
      newCrystalCube.visible = true
      add_child(newCrystalCube)

  if glitch_tickle_timer > 0:
    glitch_tickle_timer += (delta * 22)
    if glitch_tickle_timer >= glitch_tickle_time_limit:
      glitch_tickle_timer = 0
      unglitchTickleSprite(mySprite)
      unglitchTickleSprite(grandmaHatSprite)
      unglitchTickleSprite(grandmaHandSprite)
      unglitchTickleSprite(grandmaFishHatSprite)
  
  processPoisonWaterLogic(delta)
  if pressingJump():
    tryClearFallthroughCollisionSolid(self.global_transform.origin)

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
        unsmack()

  # if global.memory.has("anna_mode") and global.memory["anna_mode"]:
  #   mySprite.material_override.set_shader_param("texture_albedo", spriteSheetTiny)
  #   broomSpriteVisible.material_override.set_shader_param("texture_albedo", broomSpriteSheetTiny)
  #   if global.memory.has("blue_mode") and global.memory["blue_mode"]:
  #     mySprite.material_override.set_shader_param("target_palette", global.base_palette)
  # if global.memory.has("blue_mode") and global.memory["blue_mode"]:
  #   mySprite.material_override.set_shader_param("target_palette", global.NES_palette)

  updateGrandmaHatHandSprites()

func updateGrandmaHatHandSprites():
  grandmaHatSprite.frame = mySprite.frame
  grandmaHatSprite.flip_h = mySprite.flip_h
  grandmaFishHatSprite.flip_h = mySprite.flip_h
  grandmaHandSprite.frame = mySprite.frame
  grandmaHandSprite.flip_h = mySprite.flip_h

  var HAT_OFFSET = 0.05
  var HAND_OFFSET = 0.1
  grandmaHatSprite.global_transform.origin.z = mySprite.global_transform.origin.z + HAT_OFFSET
  grandmaHandSprite.global_transform.origin.z = mySprite.global_transform.origin.z + HAND_OFFSET

  grandmaHatSprite.visible = nesting_doll_state == global.NestingDoll.GRANDMA and not shroomAniPlayer.is_playing()
  grandmaHandSprite.visible = grandmaHatSprite.visible and broomSpriteVisible.visible
  

var teleporting = false
var has_teleported = false
var teleport_timer = 0
var teleport_time_limit = 2
var teleport_time_limit2 = 5
var teleport_to = null
var teleport_to_origin = null
func unsmack():
  smack_timer = 0
  is_smacked = false
  if not global.hasLevelGeodeBeenSmacked and not is_mushroom_prefected:
    pauseSelf = false

  for sprite in [mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite]:
    sprite.material_override.set_shader_param("time_influence", 3)
    sprite.material_override.set_shader_param("y_div", 2.3)
    sprite.material_override.set_shader_param("normal_offset", .02)
    sprite.material_override.set_shader_param("enable_palette_cycle", false)

func startTeleport():
  if teleport_to != null and Input.is_action_just_pressed("sub_action_button") and global.activeInteractor == null:
    pauseSelf = true
    global.pauseMoveInput = true
    visible = false
    teleporting = true
    gravitySound.pitch_scale = rand_range(0.8, 1.2)
    gravitySound.play()
    for _i in range(5):
      spawnASpore(self.global_transform.origin, false)
    teleport_timer = 0
    has_teleported = false

# occurs upon respawn or level entry...
func properlyApplyTransformation():
  var transformationToApply = transformation
  transformation = TransformationState.NORMAL
  if transformationToApply == TransformationState.FISHY:
    getFishyInfected()
  elif transformationToApply == TransformationState.BUBBLE:
    getBubbleInfected()
  elif transformationToApply == TransformationState.CURSED:
    getCurseInfected()

var bubblePopResistanceTimer = 0
var bubblePopResistanceTimeLimit = 2
func processBubbleLogic(delta):
  bubbleSprite.visible = transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE
  if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    bubblePopResistanceTimer += (delta*11)
    var just_pressed_jump = false # justPressedJump()
    if (horizontal_collision or on_ground or just_pressed_jump) and physics_state != PhysicsState.GLITCH_DYING and bubblePopResistanceTimer >= bubblePopResistanceTimeLimit:
      getBubbleCured()
    else:
      if glitch_form == global.GlitchForm.LADDER:
        override_terminal_vel = 4
        level.flipGravity(1)
      else:
        override_terminal_vel = null
        level.flipGravity(-1)

func processBeingTossedLogic(_delta):
  if physics_state == PhysicsState.BEING_TOSSED and not "tumble" in aniPlayer.assigned_animation:
    if linear_velocity.x < 0:
      aniPlayer.queue("tumbleLeft")
    elif linear_velocity.x > 0:
      aniPlayer.queue("tumbleRight")
    elif linear_velocity.y > 0:
      aniPlayer.queue("tumbleRight")
    elif linear_velocity.y < 0:
      aniPlayer.queue("tumbleLeft")

func processTeleportationLogic(delta):
  if teleporting:
    teleport_timer += (delta*22)
    if teleport_timer >= teleport_time_limit:
      if not has_teleported:
        # TODO
        # reassembleSound.play()
        if teleport_to_origin != null:
          self.global_transform.origin = teleport_to_origin
          self.camera_target_y_pos = self.global_transform.origin.y
        has_teleported = true
        teleport_to = null
        teleport_to_origin = null
      # gravitySound2.pitch_scale = rand_range(0.8, 1.2)
      # gravitySound2.play()
      for _i in range(1):
        spawnASpore(self.global_transform.origin, true)
    if teleport_timer >= teleport_time_limit2:
      teleporting = false
      visible = true
      pauseSelf = false
      global.pauseMoveInput = false

var pausingFromSpellCasting = false
var tryPauseFromSpellCasting = false
var spellCastPauseIndex = 0
var spellCastPauseTimer = 0
var spellCastPauseTimeLimit = 0
var num_spell_casts_used = 0
var spellCastCounterResetTimer = 0
var spellCastCounterResetTimeLimit = 30
func processCastingLogic(_delta):
  if not global.memory.has("spellbookPage"):
    return

  if global.userSettings["spellAssist"]:
    # automatic mode
    var desired_spell = global.GlitchForm.NORMAL
    if touching_glitch_or_spikes:
      desired_spell = global.GlitchForm.INVISIBLE
    elif horizontal_collision and (pressingMoveLeft() or pressingMoveRight()):
      desired_spell = global.GlitchForm.LADDER
    elif justPressedJump():
      desired_spell = global.GlitchForm.FEATHER
    elif was_on_ground and not on_ground and not pressingJump() and (pressingMoveLeft() or pressingMoveRight()) and not pressingDown():
      desired_spell = global.GlitchForm.FLOOR
      on_ground = true
      
    tryToApplySpellAssist(desired_spell)
  else:
    # manual mode
    if Input.is_action_just_pressed("alt_action_button"):
      if global.memory["spellbookPage"].size() <= 0:
        noSpellSound.play()
      else:
        spellCastPauseIndex += 1
        applySpellbookGlitch()
        level.summonSmokeClouds(self.global_transform.origin, 1, true, true)
    elif Input.is_action_just_pressed("left_button"):
      if global.memory["spellbookPage"].size() <= 0:
        noSpellSound.play()
      else:
        spellCastPauseIndex -= 1
        applySpellbookGlitch()
        level.summonSmokeClouds(self.global_transform.origin, 1, true, true)

    # TODO(REMAP)
    if global.memory.has("spellbookPage") and global.memory["glitched_grimoire"]:
      # TODO(): do these only work if you have > 2 spells?
      var spellbookSize = len(global.memory["spellbookPage"])
      if Input.is_action_just_pressed("spell_1"):
        if spellbookSize >= 1:
          spellCastPauseIndex = 0
          applySpellbookGlitch()
          level.summonSmokeClouds(self.global_transform.origin, 1, true, true)
      if Input.is_action_just_pressed("spell_2"):
        if spellbookSize >= 2:
          spellCastPauseIndex = 1
          applySpellbookGlitch()
          level.summonSmokeClouds(self.global_transform.origin, 1, true, true)
      if Input.is_action_just_pressed("spell_3"):
        if spellbookSize >= 3:
          spellCastPauseIndex = 2
          applySpellbookGlitch()
          level.summonSmokeClouds(self.global_transform.origin, 1, true, true)
      if Input.is_action_just_pressed("spell_4"):
        if spellbookSize >= 4:
          spellCastPauseIndex = 3
          applySpellbookGlitch()
          level.summonSmokeClouds(self.global_transform.origin, 1, true, true)

func tryToApplySpellAssist(desired_spell):
  if not global.userSettings["spellAssist"]:
    return
  if glitch_form != desired_spell and desired_spell != global.GlitchForm.NORMAL and doIHaveSpell(desired_spell):
    var newSpellIndex = findSpellInSpellbook(desired_spell)
    if newSpellIndex >= 0:
      spellCastPauseIndex = newSpellIndex
      applySpellbookGlitch()
      level.summonSmokeClouds(self.global_transform.origin, 3, true, true)

func summonBroomSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
  level.summonSmokeClouds(secretSweepActualCollisionShape.global_transform.origin, num_clouds, play_sound, is_glitchy)

func getDistToLeftEdge(): return max(global_transform.origin.x - getGameCamera().leftmost_x, 0.0)
func getDistToRightEdge(): return max(getGameCamera().rightmost_x - global_transform.origin.x, 0.0)
func getDistToTopEdge(): return max(getGameCamera().topmost_y - global_transform.origin.y, 0.0)
func getDistToBottomEdge(): return max(global_transform.origin.y - getGameCamera().botmost_y, 0.0)
  
var returning_to_save_point = 0
func tryDieToOffscreenCamera(_delta):
  if "IntroVideo" in level.getLevelName() or "LoadingScreen" in level.getLevelName():
    return
  if getGameCamera().rightmost_x <= -999 or global.isEnteringRoom or global.pauseGame or physics_state == PhysicsState.GLITCH_DYING:
    return

  var passive_door = self.smallInteractionArea.is_touching_passive_door
  var curr_coords = level.getLevelManagerCoords() if (not level.pacman_wrapping or passive_door) else null

  var repositioned_player = global_transform.origin
  var try_to_recover = false
  var DEATH_MARGIN = -1
  var ADJUSTMENT_MARGIN = -1

  if global_transform.origin.x > getGameCamera().rightmost_x + DEATH_MARGIN:
    global.roomEdgeVector = Vector3(1, 0, 0)
    repositioned_player.x = getGameCamera().rightmost_x + ADJUSTMENT_MARGIN
  if global_transform.origin.x < getGameCamera().leftmost_x - DEATH_MARGIN:
    global.roomEdgeVector = Vector3(-1, 0, 0)
    repositioned_player.x = getGameCamera().leftmost_x - ADJUSTMENT_MARGIN
  DEATH_MARGIN = 1
  ADJUSTMENT_MARGIN = 1
  var next_room = transition.mapManager.getRelativeRoomPath(curr_coords, Vector3(0, 1, 0)) if curr_coords != null else null
  if next_room != null:
    DEATH_MARGIN = 0
  if global_transform.origin.y > getGameCamera().topmost_y + DEATH_MARGIN:
    global.roomEdgeVector = Vector3(0, 1, 0)
    repositioned_player.y = getGameCamera().topmost_y + ADJUSTMENT_MARGIN
    if next_room == null:
      if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
        getBubbleCured()
      elif transformation == TransformationState.UNDERGROUND_RETURNING:
        bumpSound.play()
        fastStepSound.stop()
        getSmacked()
        transformation = TransformationState.UNDERGROUND
      # elif grav < 0:
      #   level.flipGravity(1)
  if global_transform.origin.y > getGameCamera().topmost_y and DEATH_MARGIN == 1:
    glitchTilesAroundMe(-2.5) # just show the player where they are...

  DEATH_MARGIN = 1
  # only relocate back to safety if off bottom screen
  if global_transform.origin.y < getGameCamera().botmost_y - DEATH_MARGIN:
    global.roomEdgeVector = Vector3(0, -1, 0)
    # if glitch_form == global.GlitchForm.WALK_THROUGH_WALLS:
    #   repositioned_player.y = getGameCamera().botmost_y - ADJUSTMENT_MARGIN
    #   if not on_ground:
    #     landed()
    # else:
    try_to_recover = true

  if global.roomEdgeVector != null:
    if global.roomEdgeVector.x != 0:
      var yDiff = getGameCamera().topmost_y - getGameCamera().botmost_y
      global.memory["player_y_offset"] = (global_transform.origin.y - getGameCamera().botmost_y) / yDiff
      global.memory["prevYDiff"] = yDiff
      global.memory.erase("player_x_offset")
      global.memory.erase("prevXDiff")
    if global.roomEdgeVector.y != 0:
      var xDiff = getGameCamera().rightmost_x - getGameCamera().leftmost_x
      global.memory["player_x_offset"] = (global_transform.origin.x - getGameCamera().leftmost_x) / xDiff
      global.memory["prevXDiff"] = xDiff
      global.memory.erase("player_y_offset")
      global.memory.erase("prevYDiff")

    next_room = transition.mapManager.getRelativeRoomPath(curr_coords, global.roomEdgeVector) if curr_coords != null else null
    if passive_door and self.smallInteractionArea.touched_passive_door != null:
      next_room = self.smallInteractionArea.touched_passive_door.path
    elif level.pacman_wrapping or (
      level.horizontal_pacman_wrapping and global.roomEdgeVector.y == 0 and global.roomEdgeVector.x != 0
    ):
      next_room = null 

    if next_room != null:
      try_to_recover = false
      global.prepareForTransition(level)
      transition.edge_fade_to(next_room)
      global.isEnteringRoom = true
      global.memory["transformation"] = self.transformation
      global.memory["player_flip_h"] = mySprite.flip_h
      global.memory["feather_jump_timer"] = feather_jump_timer
      global.memory["linear_velocity"] = linear_velocity
      global.memory["roomPath"] = level.getLevelName()
      global.pauseGame = true
      return
    else:
      global.memory.erase("player_y_offset")
      global.memory.erase("prevYDiff")
      global.memory.erase("player_x_offset")
      global.memory.erase("prevXDiff")
      if (level.pacman_wrapping or (
        level.horizontal_pacman_wrapping and global.roomEdgeVector.x != 0
      )) and not passive_door:
        DEATH_MARGIN = -1
        just_pacman_flipped_timer = 0
        was_walk_direction_flipped = shouldFlipWalkingDirection()
        # print("was_walk_dir_flipped: " + str(was_walk_direction_flipped))
        if global.roomEdgeVector == Vector3(1, 0, 0):
          global_transform.origin.x = getGameCamera().leftmost_x - DEATH_MARGIN
          if pressingMoveRight() or pressingMoveLeft():
            just_pacman_flipped_timer = -10
        if global.roomEdgeVector == Vector3(-1, 0, 0):
          global_transform.origin.x = getGameCamera().rightmost_x + DEATH_MARGIN
          if pressingMoveLeft() or pressingMoveRight():
            just_pacman_flipped_timer = -10
        if global.roomEdgeVector == Vector3(0, -1, 0):
          global_transform.origin.y = getGameCamera().topmost_y + DEATH_MARGIN
        if global.roomEdgeVector == Vector3(0, 1, 0):
          global_transform.origin.y = getGameCamera().botmost_y - DEATH_MARGIN

        if level.weird_pacman_wrapping:
          just_pacman_flipped = true
          gravitySound.pitch_scale = rand_range(0.8, 1.2)
          gravitySound.play()
          glitchTickle()
          level.flipGravity(-1 * (grav / abs(grav)))
          if glitch_form == global.GlitchForm.FEATHER:
            lv.y *= 2
            vv *= 2
            linear_velocity.y *= 2
        else:
          glitchTickle()
        global.roomEdgeVector = null
        return

    # otherwise you just can't go there...
    if global.roomEdgeVector == Vector3(0, 1, 0) and grav < 0:
      level.flipGravity(1)
      gravitySound.pitch_scale = rand_range(0.8, 1.2)
      gravitySound.play()
    global.roomEdgeVector = null

    if try_to_recover:
      tryToRecover()
    else:
      global_transform.origin = repositioned_player
      if isItWeird() and not isItKindaWeird() and global.activeInteractor == null:
        sayThis("NPC.GhostGirl.1")
      if physics_state == PhysicsState.BEING_TOSSED:
        bigBump()
        pauseAnimation = false
        physics_state = PhysicsState.NORMAL
      # elif physics_state == PhysicsState.BEING_TOSSED:
      #   collideWithWall(linear_velocity)
  
func doTimeDilation(_delta):
  pass
  # var real_delta_multiplier = 8

  # var gtdm = global.time_dilation_multiplier
  # var low = 0.6
  # var high = 1.0
  # if Input.is_action_pressed("ui_select"):
  #   mySprite.material_override.set_shader_param("palette_cycle_speed", 4.0)
  #   gtdm = gtdm + (low - gtdm) * (delta*real_delta_multiplier)
  #   if stepify(gtdm, 0.01) == stepify(low, 0.01):
  #     gtdm = low
  #     mySprite.material_override.set_shader_param("palette_cycle_speed", 2.5)
      
  #   mySprite.material_override.set_shader_param("enable_palette_cycle", true)
  # else:
  #   gtdm = gtdm + (high - gtdm) * (delta*real_delta_multiplier)
  #   mySprite.material_override.set_shader_param("enable_palette_cycle", false)
      
  #   if stepify(gtdm, 0.01) == stepify(high, 0.01):
  #     gtdm = high
  # global.time_dilation_multiplier = gtdm

func tryToRecover():
  if not has_landed_since_recovering:
    global.memory["hp"] = 0
    tryDieToEnemy(0, true, true, true)
    has_landed_since_recovering = true
    return
  returning_to_save_point = 1
  returning_recover_time = 0
  returnSound.play()
  pauseSelf = true
  ignorePhysics = true
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("returning")
  has_landed_since_recovering = false
  pauseAnimation = true
  physics_state = PhysicsState.GLITCH_RECOVERY
  if global_transform.origin.y > getGameCamera().topmost_y:
    if global.memory.has("grav_direction") and global.memory["grav_direction"] < 0:
      level.flipGravity(1)

func canIGetCaught(can_they_catch_invis = false):
  if not visible:
    return false
  if physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_RECOVERY:
    return false
  if glitch_form == global.GlitchForm.INVISIBLE and not can_they_catch_invis:
    glitchTickle(false)
    return false
  
  return true
  
func processGlitchHurtRecovery(delta):
  if physics_state == PhysicsState.GLITCH_HURT:
    global.pauseGame = true
    lv = Vector3(0, 0, 0)
    dir = Vector3(0, 0, 0)
    glitch_death_timer += (delta*22)
    glitchTilesAroundMe()

    var material = level.glitchScreenEffect.get_material()
    if material is ShaderMaterial:
      var shakeColorRate = 0.01 + (glitch_death_timer*0.002)
      if did_force_respawn:
        shakeColorRate /= 4
      material.set_shader_param("shake_color_rate", shakeColorRate)
    if glitch_death_timer >= 10:
      global.pauseGame = false
      global.pauseMoveInput = false
      self.feather_jump_timer = remembered_feather_jump_timer
      self.lv.y = remembered_y_vel
      self.linear_velocity.y = remembered_y_vel
      self.vv = remembered_y_vel
      self.on_ground = remembered_on_ground
      self.physics_state = PhysicsState.GLITCH_RECOVERY
      has_sweeped_glitch = false

    return false
  elif physics_state == PhysicsState.GLITCH_DYING:
    global.pauseGame = true
    lv = Vector3(0, 0, 0)
    dir = Vector3(0, 0, 0)
    glitch_death_timer += (delta*22)
    glitchTilesAroundMe()

    var material = level.glitchScreenEffect.get_material()
    if material is ShaderMaterial:
      var shakeColorRate = 0.01 + (glitch_death_timer*0.002)
      if did_force_respawn:
        shakeColorRate /= 4
      material.set_shader_param("shake_color_rate", shakeColorRate)
    if glitch_death_timer >= 10:
      global.pauseGame = false
      level.tryToRespawn()
      if global.isEnteringRoom: return
      should_collide_horizontally = true
      should_collide_floor = true 
      should_collide_ceil = true
      self.feather_jump_timer = remembered_feather_jump_timer if glitch_form != global.GlitchForm.FLOOR else 0
      self.lv.y = remembered_y_vel if glitch_form != global.GlitchForm.FLOOR else 0
      self.linear_velocity.y = remembered_y_vel if glitch_form != global.GlitchForm.FLOOR else 0
      self.vv = remembered_y_vel if glitch_form != global.GlitchForm.FLOOR else 0
      self.on_ground = remembered_on_ground if glitch_form != global.GlitchForm.FLOOR else true
      if grav < 0:
        self.global_transform.origin.y -= 1
      else:
        self.global_transform.origin.y += 1
      camera_target_y_pos = global_transform.origin.y
      global.memory["hearts_recovering"] = true
      self.physics_state = PhysicsState.GLITCH_RECOVERY

    return false
  else:
    if glitch_death_timer != 0:
      glitch_death_timer += (delta*22)
      applyGlitchDeathEffects(abs(glitch_death_timer))
      if glitch_death_timer >= 10:
        level.glitchScreenEffect.visible = global.userSettings["canGlitchScreen"] and should_turn_on_glitch_screen_effects
      if glitch_death_timer >= 40:
        musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
        level.glitchScreenEffect.visible = false
        global.pauseGame = false
        should_turn_on_glitch_screen_effects = false
        glitch_death_timer = 0
        if physics_state == PhysicsState.GLITCH_RECOVERY:
          self.physics_state = PhysicsState.NORMAL
        global.isRespawning = false
        if nesting_doll_state == global.NestingDoll.BABY and has_used_magic_lantern >= MAX_DOUBLE_JUMPS:
          return true
        for sprite in [mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite]:
          sprite.material_override.set_shader_param("enable_glitch", false)
          sprite.material_override.set_shader_param("enable_remove_skin_tone", false)

    return true

func applyGlitchDeathEffects(x):
  if global.userSettings["canChangeSongPitch"] and (x < 0 or x > 20):
    musicPlayer.changeSongPitch(abs(sin(x*.05)+.02))
  if x > 10:
    for sprite in [mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite]:
      sprite.material_override.set_shader_param("enable_glitch", self.physics_state == PhysicsState.GLITCH_RECOVERY)
      sprite.material_override.set_shader_param("enable_remove_skin_tone", self.physics_state == PhysicsState.GLITCH_RECOVERY)

  var material = level.glitchScreenEffect.get_material()
  if material is ShaderMaterial:
    var shakePower = -.00005*pow(x-25, 2) + .005
    var shakeColorRate = -.0001*pow(x-25, 2) + .005
    if did_force_respawn:
      shakePower /= 4
      shakeColorRate /= 4
    material.set_shader_param("shake_power", shakePower)
    material.set_shader_param("shake_color_rate", shakeColorRate)

func tryRotateCamera(_delta):
  pass

func nullify():
  glitchTickle(false)
  if global.memory["forget_me_not"]:
    level.displaySpellMessageText("unaffected")
    return

  level.displaySpellMessageText(tr("HolyAura.Display"))
  var did_erase = false
  global.memory["mp"] = 0
  self.can_cast_spell_timer = 0
  if global.memory.has("spellbookPage"):
    # intentional if weird, we treat the index as the int enum glitch_form
    for glitch_type in range(global.memory["permanent_spells"].size()):
      if not global.memory["permanent_spells"][glitch_type]:
        var found_index = global.memory["spellbookPage"].find(glitch_type)
        global.memory["spellbookPage"].erase(glitch_type)
        if found_index >= 0:
          did_erase = true 
  else:
    if glitch_form != global.GlitchForm.NORMAL:
      level.resetGrandmaStatues()
      nullifySound.play()
      glitchTilesAroundMe(0.25, true)
      self.applyGlitch(global.GlitchForm.NORMAL, true)
    return

  if did_erase or glitch_form != global.GlitchForm.NORMAL:
    level.resetGrandmaStatues()
    spellCastPauseIndex = 0
    nullifySound.play()
    glitchTilesAroundMe(0.25, true)
    self.applyGlitch(global.GlitchForm.NORMAL, true)    

# need this to have it available in the aniPlayer
func firstAdjustmentForNestingDolls():
  .adjustStuffForNestingDolls()
  
func loseBroom():
  if summonedBroom:
    broomStop()
  if global.memory["broom"]:
    mySprite.flip_h = not mySprite.flip_h
    summonFallenBroom(false, true, false)
    mySprite.flip_h = not mySprite.flip_h

func allSpritesBackToNormal(spritesToBeVisible):
  pauseAnimation = false
  spriteBackToNormal(mySprite)
  spriteBackToNormal(grandmaHatSprite)
  spriteBackToNormal(grandmaHandSprite)
  spriteBackToNormal(grandmaFishHatSprite)
  spriteBackToNormal(fishySprite)
  spriteBackToNormal(moleSprite)
  spriteBackToNormal(chickenSprite)
  if not mySprite in spritesToBeVisible:
    pauseAnimation = true
  for spriteToBeVisible in spritesToBeVisible:
    spriteToBeVisible.visible = true

func spriteBackToNormal(sprite):
  sprite.visible = false
  sprite.material_override.set_shader_param("enable_glitch", false)
  sprite.material_override.set_shader_param("shake_power", 0.01)
  sprite.material_override.set_shader_param("enable_remove_skin_tone", false)

var fish_broom_timer = 0
var fish_broom_time_limit = 2
var has_fish_broom = true
var bubble_timer = 0
var bubble_time_limit = 2
onready var fishFormSound = get_node("Sounds/FishFormSound")
func processFishyLogic(_delta):
  if not global.memory["zora_flippers"] or not global.memory["zora_flippers_enabled"]:
    if transformation == TransformationState.FISHY:
      getFishyCured()
    elif fishySprite.visible and not aniPlayer.assigned_animation == "revertFromFishy":
      allSpritesBackToNormal([mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite])
    return

  var has_been_in_water = (is_touching_water and was_touching_water) or (is_touching_sandstream and was_touching_sandstream)
  if touched_water_area != null and touched_water_area.get_node("..").is_cleansing:
    malwareCured()
    
  if transformation != TransformationState.FISHY and has_been_in_water and not truly_on_ground and not was_truly_on_ground and not recentlyJustPressedJump() and physics_state != PhysicsState.BEING_TOSSED and transformation != TransformationState.BUBBLE:
    getFishyInfected()
    fishFormSound.pitch_scale = rand_range(0.8, 1.2)
    fishFormSound.play()
  elif transformation == TransformationState.FISHY:
    if not fishySprite.visible and not aniPlayer.assigned_animation == "transformToFishy":
      allSpritesBackToNormal([fishySprite, grandmaFishHatSprite])
    fishySprite.flip_h = mySprite.flip_h
    grandmaFishHatSprite.flip_h = mySprite.flip_h
    physics_vars.should_apply_gravity = pressingDown()
    glitchTilesAroundMe(-2)
    if (not is_touching_water and not was_touching_water and not is_touching_sandstream and not was_touching_sandstream) or physics_state == PhysicsState.BEING_TOSSED:
      getFishyCured()
      gravitySound.pitch_scale = rand_range(0.8, 1.2)
      gravitySound.play()
  elif fishySprite.visible and not aniPlayer.assigned_animation == "revertFromFishy":
    # aniPlayer.stop()
    # aniPlayer.clear_queue()
    # aniPlayer.play("revertFromFishy")
    # aniPlayer.queue("land")
    allSpritesBackToNormal([mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite])


  # weird recovery
  var canAnimate = not pauseAnimation or aniPlayer.assigned_animation == "hookCaught"
  if transformation != TransformationState.FISHY and fishySprite.visible and canAnimate and not aniPlayer.assigned_animation == "revertFromFishy":
    getFishyCured()
  elif transformation == TransformationState.FISHY and not fishySprite.visible and canAnimate and not aniPlayer.assigned_animation == "transformToFishy":
    getFishyInfected()

# @override
func justPressedJump():
  return .justPressedJump() or (transformation == TransformationState.FISHY and Input.is_action_just_pressed("ui_up") and not pauseInput and not isTextboxPausingMe())


var bubble_temp_grav = 60
var bubble_temp_true_terminal_vel = 14
func getBubbleInfected(applyViaGlitchForm = false):
  if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    if not "tumble" in aniPlayer.assigned_animation:
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("tumbleRight", -1, 0.5)
    return
  bubblePopResistanceTimer = 0
  pauseAnimation = true
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("tumbleRight", -1, 0.5)

  miniUpwardGust(false)
  if summonedBroom:
    broomStop()
    # summonFallenBroom(true, false, false)
  # global.memory["broom"] = false
  transformation = TransformationState.BUBBLE
  if applyViaGlitchForm:
    glitch_form = global.GlitchForm.BUBBLE
  on_ground = false
  gravitySound.play()
  level.flipGravity(-1)

func getBubbleCured():
  if transformation != TransformationState.BUBBLE and glitch_form != global.GlitchForm.BUBBLE:
    return
  transformation = TransformationState.NORMAL
  if glitch_form == global.GlitchForm.BUBBLE:
    applyGlitch(global.GlitchForm.NORMAL)
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.queue("land")
  pauseAnimation = false
  override_terminal_vel = null

  getABroom()
  level.flipGravity(1)
  tickleSound.pitch_scale = 1.0
  tickleSound.play()
  var bubble = bubbleRes.instance()
  level.add_child(bubble)
  # bubble.mySprite.material_override.set_shader_param("enable_no_transparency", true)
  bubble.setAsParent(self)
  bubble.global_transform.origin = global_transform.origin
  bubble.my_original_pos = bubble.global_transform.origin.y
  bubble.bubbleStartPop()
  bubble.mySprite.pixel_size = 0.25
  # physics_vars.should_apply_gravity = true
  # should_collide_floor = true
  # should_collide_ceil = true
  # should_collide_horizontally = true
  # grav = bubble_temp_grav
  # true_terminal_vel = bubble_temp_true_terminal_vel

func restartMusic(): # maybe an animation uses this idk, dont delete it
  level.restartMusic()

func normalizePlayerTransformation():
  if transformation == TransformationState.FISHY:
    getFishyCured()
  if transformation == TransformationState.MOLE_DIGGING or \
     transformation == TransformationState.UNDERGROUND_RETURNING or \
     transformation == TransformationState.UNDERGROUND:
    getMoleCured()
  if transformation == TransformationState.BUBBLE:
    getBubbleCured()
  if transformation == TransformationState.CHICKEN:
    getChickenCured()
  if transformation == TransformationState.CURSED:
    getCurseCured()
  if is_mushroom_infected:
    getMushroomCured()
  if malware_infected:
    malwareCured()

# var temp_cleansed_fish_glitch = null
func getFishyInfected():
  if is_mushroom_infected or nesting_doll_state == global.NestingDoll.MATRIARCH or transformation == TransformationState.MOLE_DIGGING or transformation == TransformationState.UNDERGROUND_RETURNING or transformation == TransformationState.UNDERGROUND or nesting_doll_state == global.NestingDoll.BABY:
    return
  tryClearFallthroughCollisionSolid(self.global_transform.origin)
  # if summonedBroom:
  #   broomStop()
  #   summonFallenBroom(true, false, false)
  # global.memory["broom"] = false
  getABroom()
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
  if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    level.flipGravity(1)
  elif grav == 0:
    grav = PLAYER_GRAV
  transformation = TransformationState.FISHY
  aniPlayer.stop()
  aniPlayer.clear_queue()
  on_ground = false
  #   temp_cleansed_fish_glitch = glitch_form
  #   normalGlitch() # FORCE NOT ALLOW SWAPPING
  # if global.memory["zora_flippers"] == 1:
  #   musicPlayer.stopAll()
  #   aniPlayer.play("transformToFishy_first")
  #   global.memory["zora_flippers"] = 2
  #   dir = Vector3(0, 0, 0)
  #   lv.x = 0
  #   lv.y = 0
  #   linear_velocity.x = 0
  #   linear_velocity.y = 0
  #   vv = 0
  #   hv = Vector3(0, 0, 0)
  #   pauseInput = true
  # else:
  #   aniPlayer.play("transformToFishy")
  fall_timer = 0
  aniPlayer.play("transformToFishy")
  pauseAnimation = true
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true
  fish_broom_timer = 0
  has_fish_broom = true
  
func getFishyCured():
  if transformation != TransformationState.FISHY:
    return
  # if temp_cleansed_fish_glitch != null:
  #   glitch_form = temp_cleansed_fish_glitch # JUST APPLY SPELLBOOKPAUSEINDEX GLITCH
  can_broomerang_warp = true
  transformation = TransformationState.NORMAL
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("revertFromFishy")
  aniPlayer.queue("land")
  fall_timer = 0
  pauseAnimation = true
  if glitch_form == global.GlitchForm.FLOOR and not pressingDown() and physics_state != PhysicsState.BEING_TOSSED:
    on_ground = true
  was_just_on_ground_timer = 0
  jump_squat_jump_input_timer = 0
  feather_jump_timer = feather_jump_time_limit if glitch_form == global.GlitchForm.FLOOR else 0
  jump_press_timer = jump_press_time_limit
  # pauseInput = true
  physics_vars.should_apply_gravity = true
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true

func stopTransformationAni():
  pauseAnimation = false
  pauseInput = false

var chicken_timer = 0
var chicken_time_limit = 90
func processChickenLogic(delta):
  if transformation == TransformationState.CHICKEN:
    if not chickenSprite.visible and not aniPlayer.assigned_animation == "transformToChicken":
      allSpritesBackToNormal([chickenSprite])
    chickenSprite.flip_h = mySprite.flip_h
    glitchTilesAroundMe(-2)
    chicken_timer += (delta*11)
    if chicken_timer >= chicken_time_limit:
      getChickenCured()
      gravitySound.play()
  elif chickenSprite.visible and not aniPlayer.assigned_animation == "revertFromChicken":
    allSpritesBackToNormal([mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite])

func getChickenInfected():
  if is_mushroom_infected or nesting_doll_state == global.NestingDoll.MATRIARCH or transformation == TransformationState.CHICKEN:
    return
  if not global.has_been_baba_yaga_cursed:
    # if not "BabaYagaBossRoom" in level.getLevelName():
    #   self.sayThis("Baba Yaga's curse")
    global.has_been_baba_yaga_cursed = true
  chicken_timer = 0
  summonFallenBroom(false, true, false)
  # TODO(jaketrower): could probably DRY some of this stuff...
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
  loseBroom()
  if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    level.flipGravity(1)
  elif grav == 0:
    grav = PLAYER_GRAV
  transformation = TransformationState.CHICKEN
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("transformToChicken")
  chicken_jumps = 0
  pauseAnimation = true
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true

var curse_timer = 0
var curse_time_limit = 10
func processCurseLogic(delta):
  if transformation == TransformationState.CURSED:
    glitchTilesAroundMe(-2)
    curse_timer += (delta*11)
    if curse_timer >= curse_time_limit:
      getCurseCured()
      gravitySound.play()

func getCurseInfected():
  curse_timer = 0
  summonFallenBroom(false, true, false)
  # TODO(jaketrower): could probably DRY some of this stuff...
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
  loseBroom()
  if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    level.flipGravity(1)
  elif grav == 0:
    grav = PLAYER_GRAV
  transformation = TransformationState.CURSED
  
func getCurseCured():
  if transformation != TransformationState.CURSED:
    return
  transformation = TransformationState.NORMAL
  getABroom()

var snoring = false
var sleepy_timer = 0
var sleepy_time_limit = 90
func processSleepyLogic(delta):
  if global.shouldRenderAsCinematic:
    sleepy_timer = 0
    return
  var effective_sleepy_time_limit = sleepy_time_limit
  if global.activeInteractor != null: # grandma respects social norms
    effective_sleepy_time_limit *= 2
  if transformation == TransformationState.NORMAL and on_ground and not summonedBroom and physics_state == self.PhysicsState.NORMAL and not anyOtherRitualInputsDetected(false) and aniPlayer.assigned_animation == "stand":
    sleepy_timer += (delta*11)
    if sleepy_timer >= effective_sleepy_time_limit:
      snoring = true
      aniPlayer.stop()
      aniPlayer.clear_queue()
      aniPlayer.play("yawn")
      aniPlayer.queue("sleepy")
  elif not global.isPauseMenuOpen and not global.isOnMainMenu:
    sleepy_timer = 0

func miniWakeup():
  sleepy_timer = 0
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("land")
  # on_ground = false

onready var ritualSound = get_node("Sounds/RitualSound")
onready var angelZoneLevelDoor = get_node("AngelZoneLevelDoor")
var ritual_state_index = 0
func processAngelStatueRitual(_delta):
  if global.isEnteringRoom or global.isPauseMenuOpen:
    return
  if global.pauseGame or pauseInput or global.pauseMoveInput or pauseSelf:
    if ritual_state_index > 1:
      tickleSound.play()
    ritual_state_index = 0
    ritualSound.stop()
    return

  if ritual_state_index == len(global.correct_ritual):
    # angelZoneLevelDoor.goThroughDoor()
    global.isPauseMenuOpen = true
    global.pauseGame = true
    level.uiLayer.pauseMenu.pauseMenuState = level.uiLayer.pauseMenu.PauseMenuState.SECRET_RITUAL
    level.uiLayer.pauseMenu.shouldUpdateMenuText = true
    level.uiLayer.pauseMenu.secretRitualOptionIndex = 0
    ritual_state_index = 0
    return
  
  if Input.is_action_just_pressed(global.correct_ritual[ritual_state_index]) and (on_ground or ritual_state_index == len(global.correct_ritual) - 1):
    if ritual_state_index > 0:
      ritualSound.stop()
      ritualSound.pitch_scale = 0.5 + (ritual_state_index * 0.1)
      ritualSound.play()
      glitchTickle(false)
    ritual_state_index += 1
    
  elif anyOtherRitualInputsDetected():
    if ritual_state_index > 1:
      tickleSound.play()
    ritual_state_index = 0
    ritualSound.stop()
    
  

func anyOtherRitualInputsDetected(just_pressed = true):
  var inputs = ["ui_left", "ui_right", "ui_up", "ui_down", "jump_button", "sub_action_button", "alt_action_button", "restart_key", "ui_start", "popup_menu", "left_button", "talk_button"]
  if rawPressingMoveDown() or rawPressingMoveUp() or rawPressingMoveLeft() or rawPressingMoveRight():
    return true
  for input in inputs:
    if just_pressed and Input.is_action_just_pressed(input):
      return true
    elif Input.is_action_pressed(input):
      return true
  return false

func checkSolidTilesBeneathMe():
  var solid_tiles = getTilesBelow(getLevelTiles())
  for i in range(len(solid_tiles)):
      if solid_tiles[i] != null:
        return true
  return false

func checkSolidTilesOnMyRight(nearby = false):
  if nearby: global_transform.origin.x += 1
  var solid_tiles = getTilesRightOf(getLevelTiles())
  for i in range(len(solid_tiles)):
      if solid_tiles[i] != null:
        if nearby: global_transform.origin.x -= 1
        return true
  if nearby: global_transform.origin.x -= 1
  return false

func checkSolidTilesOnMyLeft(nearby = false):
  if nearby: global_transform.origin.x -= 1
  var solid_tiles = getTilesLeftOf(getLevelTiles())
  for i in range(len(solid_tiles)):
      if solid_tiles[i] != null:
        if nearby: global_transform.origin.x += 1
        return true
  if nearby: global_transform.origin.x += 1
  return false

func checkSolidTilesOnMe():
  var is_true = false
  global_transform.origin.y += 1
  if checkSolidTilesBeneathMe():
    is_true = true
  global_transform.origin.y += 1
  if checkSolidTilesBeneathMe():
    is_true = true
  global_transform.origin.y -= 2
  return is_true

func processMoleLogic(delta):
  if transformation == TransformationState.MOLE_DIGGING:
    # if not moleSprite.visible and not aniPlayer.assigned_animation == "transformToMole":
    #   allSpritesBackToNormal([moleSprite])
    dig_smoke_timer += (delta*11)
    if dig_smoke_timer >= dig_smoke_time_limit:
      dig_smoke_timer = 0
      summonSmokeClouds(1)
    moleSprite.flip_h = mySprite.flip_h
    if returning_to_save_point > 0 or dig_direction == null or (dig_direction.y >= 0 and not pressingJump()) or (dig_direction.y <= 0 and not pressingDown()):
      getMoleCured()
      dig_timer = 0
      was_just_on_ground_timer = 0
      jump_squat_jump_input_timer = 0
      feather_jump_timer = feather_jump_time_limit if glitch_form == global.GlitchForm.FLOOR else feather_jump_time_limit / 2
      jump_press_timer = jump_press_time_limit / 2
      on_ground = true
    # elif glitch_form == global.GlitchForm.INVISIBLE and dig_direction != null:
    #   if dig_direction.x > 0 and pressingMoveRight():
    #     processMoleDigTimer(Vector3(2, 0, 0))
    #   if dig_direction.x < 0 and pressingMoveLeft():
    #     processMoleDigTimer(Vector3(-2, 0, 0))
  elif transformation == TransformationState.UNDERGROUND_RETURNING:
    getCoveredInDirt()
    if returning_to_save_point > 0:
      getMoleCured()
      return
    override_camera_y = global_transform.origin.y
    dig_below_timer = 0
    glitchTilesAroundMe(-2.5)
    fastStepSound.pitch_scale = 2.0
    fastStepSound.volume_db = -8
    if not fastStepSound.is_playing():
      fastStepSound.play()
    var solidTilesToCheck = getTilesBelow(getLevelTiles())
    if dig_direction != null and dig_direction.x > 0:
      solidTilesToCheck = getTilesRightOf(getLevelTiles())
    elif dig_direction != null and dig_direction.x < 0:
      solidTilesToCheck = getTilesLeftOf(getLevelTiles())
    elif dig_direction != null and dig_direction.y > 0:
      solidTilesToCheck = getTilesAbove(getLevelTiles())
    var areAnyTilesToCheckGlitched = false
    for i in range(solidTilesToCheck.size()):
      var coords = solidTilesToCheck[i]
      if coords == null: continue
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if getLevelTiles().isTileFragileSolid(tile_type):
        areAnyTilesToCheckGlitched = true
        break
    if areAnyTilesToCheckGlitched:
      bumpSound.play()
      fastStepSound.stop()
      getSmacked()
      smack_timer = -4
      transformation = TransformationState.UNDERGROUND
      global_transform.origin -= dig_direction / 2.0
    elif checkSolidTilesOnMe():
      global_transform.origin += (dig_direction * delta*11.0)
    else:
      self.global_transform.origin += dig_direction * 0.5
      if dig_direction != null and dig_direction.y > 0:
        should_magic_jump = true
        self.vv = 5
        self.camera_target_y_pos = self.global_transform.origin.y
        self.on_ground = false
        self.truly_on_ground = false
        self.was_on_ground = false
        self.lv.y = self.vv
        self.linear_velocity.y = self.vv
        self.was_fallthrough_area_collision_triggered = false
      getMoleCured()
  elif transformation == TransformationState.UNDERGROUND:
    getCoveredInDirt()
    if returning_to_save_point > 0:
      getMoleCured()
      return
    override_camera_y = global_transform.origin.y
    dig_below_timer = 0
    glitchTilesAroundMe(-2.5)
    if is_smacked:
      return
    fastStepSound.pitch_scale = 1.0
    fastStepSound.volume_db = -16
    if not fastStepSound.is_playing():
      fastStepSound.play()
    if checkSolidTilesOnMe():
      global_transform.origin -= (dig_direction * delta*11.0)
    else:
      if dig_direction != null and dig_direction.y > 0:
        should_magic_jump = true
        # might be weird with gravity?? should just disable with gravity?? idk
        self.vv = -2
        self.camera_target_y_pos = self.global_transform.origin.y
        self.on_ground = false
        self.truly_on_ground = false
        self.was_on_ground = false
        self.lv.y = self.vv
        self.linear_velocity.y = self.vv
        self.was_fallthrough_area_collision_triggered = false
      getMoleCured()
  else:
    dig_smoke_timer = 0
    # TODO(jaketrower): TODO(jaketrower): TODO(jaketrower): TODO(jaketrower):
    if dig_direction != null and dig_timer > 0 and transformation != TransformationState.MOLE_DIGGING and (
      (pressingJump() and dig_direction.y >= 0 and on_ceiling and not was_on_ceiling) or
      (pressingDown() and dig_direction.y <= 0 and on_ground) or
      (pressingMoveRight() and dig_direction.x >= 0 and horizontal_collision) or 
      (pressingMoveLeft() and dig_direction.x <= 0 and horizontal_collision)
    ):
      transformation = TransformationState.MOLE_DIGGING
      # aniPlayer.stop()
      # aniPlayer.clear_queue()
      # aniPlayer.play("transformToMole")
      # pauseAnimation = true
      # if summonedBroom:
      #   broomStop()
      #   summonFallenBroom(true, false, false)
      # global.memory["broom"] = false
    else:
      dig_timer = 0
    if not pressingJump() and on_ground:
      can_dig_up = true
    # if moleSprite.visible and not aniPlayer.assigned_animation == "revertFromMole":
    #   allSpritesBackToNormal([mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite])
    #   getABroom()
    if is_covered_in_dirt:
      is_covered_in_dirt_timer += (delta*11)
      if is_covered_in_dirt_timer >= is_covered_in_dirt_time_limit:
        cleanUpDirtCoverage()

func getCoveredInDirt():
  is_covered_in_dirt_timer = 0
  if is_covered_in_dirt:
    return
  var temp_palette = what_was_my_last_palette
  changeSpriteColorPalette(global.yellow_player_palette)
  what_was_my_last_palette = temp_palette
  is_covered_in_dirt = true

func cleanUpDirtCoverage():
  is_covered_in_dirt = false
  is_covered_in_dirt_timer = 0
  # glitchTickle()
  if what_was_my_last_palette != null:
    changeSpriteColorPalette(what_was_my_last_palette)

func applyGravity(delta):
  if dig_timer > 0 and (pressingJump() or glitch_form == global.GlitchForm.LADDER and isWalkingIntoWall()) and can_dig_up and (on_ceiling or was_on_ceiling):
    createG(delta)
    lv -= g * delta * 1
    return
  # if glitch_form == GlitchForm.FLOOR and dig_timer > 0 and can_dig_up:
  #   on_ground = true
  #   was_on_ground = true
  # if glitch_form == GlitchForm.FEATHER and dig_timer > 0 and can_dig_up:
  #   on_ground = true
  #   was_on_ground = true
  #   feather_jump_timer = 0
  if not on_ground:
    dig_timer = 0
  .applyGravity(delta)

func collideWithCeiling(local_lv):
  if grav == 0:
    grav = PLAYER_GRAV
  if physics_state == PhysicsState.BEING_TOSSED:
    physics_state = PhysicsState.NORMAL
    pauseAnimation = false
    if physics_state == PhysicsState.BEING_TOSSED:
      on_ground = true # needs to be BEFORE tryDieToEnemy to set remembered_on_ground correctly
      bigBump()
  on_ceiling = true
  var solidTilesAbove = getTilesAbove(getLevelTiles())
  var areAnyTilesAboveMeFragileBrickSolid = false
  var areAnyTilesAboveMeSpikes = false
  for i in range(solidTilesAbove.size()):
    var coords = solidTilesAbove[i]
    if coords == null: continue
    var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
    if not areAnyTilesAboveMeFragileBrickSolid and getLevelTiles().isTileFragileSolid(tile_type):
      areAnyTilesAboveMeFragileBrickSolid = true
      if pressingJump():
        if not noBroomSound.is_playing() and (global.memory["mole_cricket"] > 0 and global.memory["mole_cricket_enabled"]) and glitch_form == global.GlitchForm.FEATHER:
          noBroomSound.play()
          # glitchTilesAroundMe()
        glitchTickle()
    if not areAnyTilesAboveMeSpikes and getLevelTiles().isTileSpikes(tile_type):
      areAnyTilesAboveMeSpikes = true
  if (
    local_lv.y < 0 or not can_dig_up or
    global.memory["mole_cricket"] == 0 or not global.memory["mole_cricket_enabled"] or
    nesting_doll_state == global.NestingDoll.MATRIARCH or
    nesting_doll_state == global.NestingDoll.BABY or
    not pressingJump() or
    (dig_timer == 0 and ((pressingMoveLeft() or pressingMoveRight()) and not pressingMoveUp())) or 
    areAnyTilesAboveMeFragileBrickSolid or
    (transformation == TransformationState.CHICKEN or transformation == TransformationState.UNDERGROUND or transformation == TransformationState.UNDERGROUND_RETURNING or transformation == TransformationState.BUBBLE)
    or (glitch_form != global.GlitchForm.INVISIBLE and areAnyTilesAboveMeSpikes)
  ):
    local_lv.y = 0
    getMoleCured()
    return local_lv
  local_lv.y = 0
  processMoleDigTimer(Vector3(0, 2, 0))
  return local_lv

func getMoleCured():
  if transformation != TransformationState.UNDERGROUND_RETURNING and \
     transformation != TransformationState.UNDERGROUND and \
     transformation != TransformationState.MOLE_DIGGING:
    return
  if transformation == TransformationState.UNDERGROUND_RETURNING:
    override_camera_y = null
    global_transform.origin.y -= 2
    summonSmokeClouds(3, true, true, 0)
    digSound2.play()
    global_transform.origin.y += 2
    for sprite in [mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite]:
      sprite.visible = true
    pauseAnimation = false
    can_update_last_grounded_pos = true
    physics_vars.should_apply_gravity = true
    was_just_on_ground_timer = 0
    jump_squat_jump_input_timer = 0
    feather_jump_timer = 0
    jump_press_timer = jump_press_time_limit
  elif transformation == TransformationState.UNDERGROUND:
    override_camera_y = null
    global_transform.origin.y += 2
    summonSmokeClouds(3, true, true, 0)
    digSound2.play()
    global_transform.origin.y -= 2
    for sprite in [mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite]:
      sprite.visible = true
    pauseAnimation = false
    can_update_last_grounded_pos = true
    physics_vars.should_apply_gravity = true
    on_ground = false
  should_collide_floor = true
  should_collide_ceil = true
  should_collide_horizontally = true
  dig_timer = 0
  dig_below_timer = 0
  # aniPlayer.stop()
  # aniPlayer.clear_queue()
  # aniPlayer.play("revertFromMole")
  transformation = TransformationState.NORMAL
  getABroom() # HAS TO BE AFTER SETTING THE TRANSFORMATION STATE
  


var is_mushroom_prefected = false
func getMushroomInfected(): 
  tryClearFallthroughCollisionSolid(self.global_transform.origin)
  if is_mushroom_infected or is_mushroom_prefected:
    # glitchTickle(0)
    # getSmacked()
    return false
  is_mushroom_prefected = true
  loseBroom()

  musicPlayer.changeSongPitch(0.5)
  # mushroom_turn_timer = 0
  # physics_state = PhysicsState.GLITCH_HURT
  glitchTickle(0)
  getSmacked()
  # glitch_death_timer = 0
  global.pauseMoveInput = true
  pauseAnimation = true
  if mySprite.flip_h:
    mushroom_infection_direction = -1
  else:
    mushroom_infection_direction = 1
  yield(TempTimer.idle_frame(self), "timeout")
  
  mushroomSpriteAniPlayer.stop()
  mushroomSpriteAniPlayer.clear_queue()
  mushroomSpriteAniPlayer.play("sprout")

func finalizeMushroomInfection():
  pauseAnimation = false
  pauseSelf = false
  global.pauseMoveInput = false
  is_mushroom_prefected = false
  is_mushroom_infected = true

func getMushroomCured():
  if not is_mushroom_infected:
    return

  musicPlayer.changeSongPitch(1.0)
  returnSound.play()
  # mushroom_turn_timer = 0
  # physics_state = PhysicsState.GLITCH_HURT
  # glitchTickle(0)
  getSmacked()
  glitch_death_timer = 0
  global.pauseMoveInput = false 
  getABroom()
  is_mushroom_infected = false
  mushroomSpriteVisible.visible = false
  mushroomSpriteAniPlayer.stop()
  mushroomSpriteAniPlayer.clear_queue()
  mushroomSpriteAniPlayer.play("RESET")


var remembered_feather_jump_timer = 0
var remembered_y_vel = 0
var remembered_on_ground = false
var did_force_respawn = false
# @override
# aka func ouchies():
func tryDieToEnemy(delta, should_glitch, should_kill_invis, should_immediately_die = false):
  touching_glitch_or_spikes = true
  tryToApplySpellAssist(global.GlitchForm.INVISIBLE)
  if transitioning or global.isEnteringRoom:
    return
  var no_trust_me_guys = Input.is_action_just_pressed("restart_key")
  if isOnSavePoint(no_trust_me_guys):
    return
  if not no_trust_me_guys and (physics_state == PhysicsState.GLITCH_DYING or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.GLITCH_HURT or physics_state == PhysicsState.GLITCH_RECOVERY):
    return

  if (glitch_form == global.GlitchForm.INVISIBLE or returning_to_save_point > 0)and not should_kill_invis:
    spawnSparkles(delta, true)
    glitchTickle(true)
    return

  did_force_respawn = false
  # if is_mushroom_infected:
  #   getABroom()
  #   for _i in range(5):
  #     spawnASpore(0, -1)
  #   var x_offset = 0
  #   if pressingMoveLeft():
  #     x_offset = 1
  #   elif pressingMoveRight():
  #     x_offset = -1
  #   global_transform.origin.x += x_offset
  #   global_transform.origin.y += 1
  #   var carcass = spawnACarcass()
  #   carcass.mushroomSprite.visible = true
  #   global_transform.origin.x -= x_offset
  #   global_transform.origin.y -= 1
  #   is_mushroom_infected = false

  if physics_state == PhysicsState.BEING_TOSSED:
    if grav == 0:
      grav = PLAYER_GRAV
    pauseAnimation = false
    should_big_bump = false

  if global.activeInteractor:
    global.activeInteractor.hideTextbox()
  global.activeInteractor = null
  var hurtSound_pitch_scale = 1.0
  if nesting_doll_state == global.NestingDoll.BABY:
    hurtSound_pitch_scale = rand_range(1.5, 2.0)
  elif nesting_doll_state == global.NestingDoll.MATRIARCH:
    hurtSound_pitch_scale = rand_range(0.4, 0.8)
  else:
    hurtSound_pitch_scale = rand_range(0.8, 1.5)

  if should_immediately_die and not no_trust_me_guys:
    hurt3Sound.pitch_scale = hurtSound_pitch_scale
    hurt3Sound.volume_db = -18
    hurt3Sound.play()
  elif randi() % 3 == 0:
    hurt2Sound.pitch_scale = hurtSound_pitch_scale
    hurt2Sound.play()
  else:
    hurtSound.pitch_scale = hurtSound_pitch_scale
    hurtSound.play()
  if no_trust_me_guys:
    did_force_respawn = true
    global.memory.erase("weird_active_save_point_x")
    global.memory.erase("weird_active_save_point_y")
    global.memory.erase("weird_active_save_point_z")
    mySporeSavePoint.global_transform.origin = Vector3(999, 999, 999)
  else:
    bumpSound.pitch_scale = hurtSound_pitch_scale
    bumpSound.play()
  global.pauseGame = true
  global.pauseMoveInput = true
  global.memory["on_ground"] = on_ground
  # on_ground = false

  level.glitchScreenEffect.material.set_shader_param("shake_power", 0.01)
  level.glitchScreenEffect.material.set_shader_param("shake_color_rate", 0.01)
  for sprite in [mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite]:
    sprite.material_override.set_shader_param("enable_glitch", true)
    sprite.material_override.set_shader_param("enable_remove_skin_tone", true)
  
  if global.userSettings["canChangeSongPitch"]:
    musicPlayer.changeSongPitch(rand_range(0.8, 1.5))

  var whichBoss = level.getBoss()
  if whichBoss != null and whichBoss.getMyVariable() > 0:
    whichBoss.num_granny_hits -= 1
    global.incrementLevelZoneDeaths()
    level.glitchScreenEffect.visible = global.userSettings["canGlitchScreen"]
  else:
    global.memory["hp"] -= 1
  # if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
  #   getBubbleCured()
  #   physics_state = PhysicsState.GLITCH_HURT
  #   global.pauseGame = false
  #   global.pauseMoveInput = false
  #   glitchTickle(true)
  #   getSmacked()
  #   on_ground = false
  #   global.memory["on_ground"] = false
  #   lv.y = 0
  #   global.pauseMoveInput = false 
  #   glitch_death_timer = 10
  var GRANNY_BOSS_HP_CUTOFF = -1 if global.memory.has("weird_active_save_point_x") and global.memory.has("weird_active_save_point_y") else 0
  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    global.memory["hp"] += 1
    physics_state = PhysicsState.GLITCH_HURT
    glitchTickle(true)
    getSmacked()
    glitch_death_timer = 0
    shroomAniPlayer.stop()
    shroomAniPlayer.clear_queue()
    shroomAniPlayer.play("RESET")
    shroomAniPlayer.queue("shrinkFromBig")
    shroomAniPlayer.queue("adjust")
    nesting_doll_state = global.NestingDoll.GRANDMA
    updateNestingDoll(nesting_doll_state)
    global.pauseMoveInput = false
  # elif nesting_doll_state == global.NestingDoll.GRANDMA and global.memory["mushroom_soul"] >= 1 and global.memory["mushroom_soul_enabled"] and not should_immediately_die and whichBoss == null:
  #   global.memory["hp"] += 1
  #   physics_state = PhysicsState.GLITCH_HURT
  #   glitchTickle(true)
  #   getSmacked()
  #   glitch_death_timer = 0
  #   shroomAniPlayer.stop()
  #   shroomAniPlayer.clear_queue()
  #   shroomAniPlayer.play("RESET")
  #   shroomAniPlayer.queue("shrink")
  #   shroomAniPlayer.queue("adjust")
  #   nesting_doll_state = global.NestingDoll.BABY
  #   global.memory["nesting_doll"] = global.NestingDoll.BABY
  #   updateNestingDoll(global.NestingDoll.BABY)
  #   loseBroom()
  elif global.memory["hp"] <= 0 or should_immediately_die or (whichBoss != null and whichBoss.num_granny_hits <= GRANNY_BOSS_HP_CUTOFF):
    if summonedBroom:
      broomStop()
    summonFallenBroom(false, true, false)
    actuallyProcessDeath(should_glitch)
    getSmacked()
  else:
    physics_state = PhysicsState.GLITCH_HURT
    glitchTickle(true)
    getSmacked()
    glitch_death_timer = 0
    global.pauseMoveInput = false 

    if global.memory["hp"] <= 1 and enchantedBagSpriteVisible.visible:
      summonSmokeClouds(3, true, true, -1)
      enchantedBagSpriteVisible.visible = false
    # self.nullify()
    if whichBoss != null and global.memory.has("weird_active_save_point_x") and global.memory.has("weird_active_save_point_y"):
      global_transform.origin = Vector3(
        global.memory["weird_active_save_point_x"], 
        global.memory["weird_active_save_point_y"], 
        global.memory["weird_active_save_point_z"])
      properlyApplyTransformation()
      last_grounded_pos = Vector3(global_transform.origin)
      global.memory.erase("weird_active_save_point_x")
      global.memory.erase("weird_active_save_point_y")
      global.memory.erase("weird_active_save_point_z")
      mySporeSavePoint.global_transform.origin = Vector3(999, 999, 999)
      mushroomClone()
      on_ground = false
  remembered_feather_jump_timer = self.feather_jump_timer
  remembered_y_vel = lv.y
  remembered_on_ground = on_ground

func actuallyProcessDeath(should_glitch):
  if global.memory["priestess"] >= 2:
    return
  if transformation == TransformationState.FISHY:
    getFishyCured()
  if transformation == TransformationState.UNDERGROUND_RETURNING or transformation == TransformationState.UNDERGROUND or transformation == TransformationState.MOLE_DIGGING:
    getMoleCured()
  if transformation == TransformationState.CHICKEN:
    getChickenCured()
  global.incrementLevelZoneDeaths()
  global.memory["hp"] = 0
  self.textBox.hideTextbox()
  global.isRespawning = true
  physics_state = PhysicsState.GLITCH_DYING
  glitch_death_timer = 0
  # TODO(jaketrower): RESPECT MORE
  if global.userSettings["canGlitchScreen"] and should_glitch:
    level.glitchScreenEffect.visible = true
  if summonedBroom:
    broomStop()
  tryClearFallthroughCollisionSolid(self.global_transform.origin)

export var time_influence = 35
export var y_div = 2.3
export var normal_offset = .15
var is_smacked = false
var smack_timer = 0
var smack_time_limit = 4
func getSmacked(_broom_origin = null, _silently = false, _is_local_broom = false):
  if is_smacked or physics_state == PhysicsState.BEING_TOSSED:
    return
  for sprite in [mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite]:
    sprite.material_override.set_shader_param("time_influence", time_influence)
    sprite.material_override.set_shader_param("y_div", y_div)
    sprite.material_override.set_shader_param("normal_offset", normal_offset)
  smack_timer = 0
  is_smacked = true
  pauseSelf = true

var shroomRes = preload("res://sceneObjects/Enemies/BasicShroomEnemy.tscn")
var summonedShroom = null
func summonSporeShroom():
  # return
  if summonedShroom and summonedShroom.get_ref():
    summonedShroom.get_ref().queue_free()
    
  var newShroom = shroomRes.instance()
  level.add_child(newShroom)
  newShroom.setAsParent(self)
  newShroom.global_transform.origin = self.global_transform.origin
  if mySprite.flip_h:
    newShroom.global_transform.origin.x -= 2
    newShroom.walk_direction.x = -1
  else:
    newShroom.global_transform.origin.x += 2
    newShroom.walk_direction.x = 1
  summonedShroom = weakref(newShroom)

func malwareCorruptMe():
  # aniPlayer.stop()
  # aniPlayer.clear_queue()
  # aniPlayer.play("corruptMe")
  malware_infected = true
  infectSound.play()
  # if not pressingMoveLeft() and not pressingMoveRight():
  #   mySprite.flip_h = not mySprite.flip_h
  # loseBroom()

func malwareCured():
  malware_infected = false
  infectReverseSound.play()
  # getABroom()

func tumbleFall(direction_vector, is_corrupted = false):
  if physics_state == PhysicsState.GLITCH_DYING:
    return

  should_free_when_falling = false
  aniPlayer.stop()
  aniPlayer.clear_queue()
  var x_val = 0
  var jump_val = 5 if not is_corrupted else 0
  if direction_vector.x < 0:
    aniPlayer.queue("tumbleLeft")
    x_val = -10
    on_ground = true
  elif direction_vector.x > 0:
    aniPlayer.queue("tumbleRight")
    x_val = 10
    on_ground = true
  elif direction_vector.y > 0:
    if mySprite.flip_h:
      aniPlayer.queue("tumbleLeft")
    else:
      aniPlayer.queue("tumbleRight")
    jump_val = 10
    should_free_when_falling = true
    on_ground = false
    # grav = 0
  elif direction_vector.y < 0:
    if mySprite.flip_h:
      aniPlayer.queue("tumbleLeft")
    else:
      aniPlayer.queue("tumbleRight")
    jump_val = -10
    on_ground = false

  if is_corrupted:
    grav = 0
    # on_ground = false
    should_big_bump = true
  else:
    # on_ground = true
    grav = PLAYER_GRAV
  physics_state = PhysicsState.BEING_TOSSED
  global.pauseGame = false
  global.pauseMoveInput = false
  pauseAnimation = true
  should_collide_floor = true
  can_collide_with_floor = true
  hv = Vector3(x_val, 0, 0)
  dir = Vector3(x_val, 0.0, 0.0)
  linear_velocity.x = x_val
  lv.x = x_val

  linear_velocity.y = jump_val
  lv.y = jump_val
  vv = up.dot(lv)

  yield(TempTimer.idle_frame(self), "timeout")
  fall_timer = fall_time_max - 5

# @override
func isFeatherLike():
  return glitch_form == global.GlitchForm.FEATHER and physics_state != PhysicsState.BEING_TOSSED and not isHeavy()

var is_covered_in_dirt = false
var is_covered_in_dirt_timer = 0
var is_covered_in_dirt_time_limit = 5
func isHeavy():
  return glitch_form == global.GlitchForm.LADDER or is_covered_in_dirt

func corruptAllSprites():
  corruptSprite(mySprite)
  corruptSprite(grandmaHatSprite)
  corruptSprite(grandmaHandSprite)
  corruptSprite(grandmaFishHatSprite)
  corruptSprite(fishySprite)
  corruptSprite(moleSprite)
  corruptSprite(chickenSprite)
  spellbookGlitchSprite.material_override.set_shader_param("enable_glitch", true)
  spellbookGlitchSprite.material_override.set_shader_param("disable_glitch_dither", false)

func uncorruptAllSprites():
  uncorruptSprite(mySprite)
  uncorruptSprite(grandmaHatSprite)
  uncorruptSprite(grandmaHandSprite)
  uncorruptSprite(grandmaFishHatSprite)
  uncorruptSprite(fishySprite)
  uncorruptSprite(moleSprite)
  uncorruptSprite(chickenSprite)
  spellbookGlitchSprite.material_override.set_shader_param("enable_glitch", false)

func corruptSprite(sprite):
  # sprite.material_override.set_shader_param("enable_dither", true)
  # sprite.material_override.set_shader_param("enable_remove_skin_tone", true)
  sprite.material_override.set_shader_param("enable_glitch", true)
  sprite.material_override.set_shader_param("enable_glitch_3d", false)
  sprite.material_override.set_shader_param("enable_palette_cycle", not malware_infected)
  # sprite.material_override.set_shader_param("enable_no_transparency", true)
  # sprite.material_override.set_shader_param("shake_power", 0.1)
  # sprite.material_override.set_shader_param("shake_color_rate", 0.5)
  # sprite.material_override.set_shader_param("shake_block_size", 10)
  # sprite.material_override.set_shader_param("target_palette", global.weird_base_palette)
  
func uncorruptSprite(sprite):
  # sprite.material_override.set_shader_param("enable_dither", false)
  # sprite.material_override.set_shader_param("enable_remove_skin_tone", false)
  if glitch_tickle_timer <= 0:
    sprite.material_override.set_shader_param("enable_glitch", false)
  sprite.material_override.set_shader_param("enable_glitch_3d", false)
  sprite.material_override.set_shader_param("enable_palette_cycle", false)
  # sprite.material_override.set_shader_param("enable_no_transparency", false)
  # sprite.material_override.set_shader_param("shake_power", 0.01)
  # sprite.material_override.set_shader_param("shake_color_rate", 0)
  # sprite.material_override.set_shader_param("shake_block_size", 20)
  # sprite.material_override.set_shader_param("target_palette", the_proper_palette)

func processBagLogic(_delta):
  pass

var force_a_sweep = false
func processBroomLogic(delta):
  if (pauseInput or global.shouldRenderAsCinematic) and summonedBroom == null:
    return
  if global.pauseMoveInput or aniPlayer.assigned_animation == "getItem":
    return

  if should_respawn_broom:
    if glitch_form != global.GlitchForm.INVISIBLE and (
          physics_state == PhysicsState.NORMAL or physics_state == PhysicsState.GLITCH_RECOVERY or physics_state == PhysicsState.GLITCH_HURT
    ) and not global.memory["broom"]:
      respawn_broom_timer += (delta*11)
      if respawn_broom_timer >= respawn_broom_time_limit:
        respawn_broom_timer = 0
        should_respawn_broom = false
        level.summonSmokeClouds(self.global_transform.origin, 1, false, true)
        global.memory["broom"] = true
    else:
      should_respawn_broom = false


  var can_throw_broom = global.memory["broomerang"] and not isItWeird() and global.memory["broomerang_enabled"]

  var aa = aniPlayer.assigned_animation
  if (aa == "broomSmackGlitch" or aa == "sweepFloor") and not aniPlayer.is_playing():
    if global.memory["multi_broom"]:
      summonedBroom = null
    else:
      broomStop()

  if (global.pauseMoveInput and global.activeInteractor == null) or physics_state == PhysicsState.BEING_TOSSED or transformation == TransformationState.UNDERGROUND_RETURNING or transformation == TransformationState.UNDERGROUND or transformation == TransformationState.MOLE_DIGGING or transformation == TransformationState.CHICKEN:
    if Input.is_action_just_pressed("sub_action_button"):
      noBroomSound.play()
    return

  var which_broom_attack = 1
  if not global.memory["broom"]:
    # if nesting_doll_state == global.NestingDoll.BABY and Input.is_action_just_pressed("sub_action_button") and Input.is_action_pressed("ui_down"):
    #   summonSporeShroom()
    if global.memory["has_gotten_broom"] > 0 and Input.is_action_just_pressed("sub_action_button") and not noBroomSound.is_playing() and global.memory["broomerang"] >= 1 and not isItWeird():
      # if fallenBroomRef.get_ref() and not fallenBroomRef.get_ref().returning:
      #   var distance = global_transform.origin.distance_to(fallenBroomRef.get_ref().global_transform.origin)
      #   if distance >= 2:
      #     fallenBroomRef.get_ref().returning = true
      # if nesting_doll_state == global.NestingDoll.BABY:
      #   tryToRevertFromBaby()
      #   return
      if global.memory["broomerang"] >= 2:
        return
      var found_fallen_broom = false
      var fallenBroomArray = self.get_tree().get_nodes_in_group("fallen_broom_group")
      for fallenBroom in fallenBroomArray:
        if fallenBroom.visible and global.memory["broomerang"] >= 2 and can_broomerang_warp:
          fallenBroom.warpToIt()
        elif not fallenBroom.returning and fallenBroom.visible and not fallenBroom.should_die_on_land and not fallenBroom.is_dying and fallenBroom.should_return and fallenBroom.can_return_via_input:
          fallenBroom.returning = true
          found_fallen_broom = true
      if found_fallen_broom:
        broomReverseSound.play()
      elif fallenBroomArray.size() == 0:
        noBroomSound.play()
    return

  if not summonedBroom and is_in_broom_cooldown:
    broom_cooldown_timer += (delta*22)
    if broom_cooldown_timer >= broom_cooldown_time_limit:
      broom_cooldown_timer = 0
      is_in_broom_cooldown = false
      which_broom_attack = 1

  if (Input.is_action_just_pressed("sub_action_button") or force_a_sweep) and not summonedBroom and not pauseSelf and not aa == "sweepFloor" and not global.hasGottenLevelGeode and not isTextboxPausingMe(): # and (global.activeInteractor == null or global.activeInteractor.is_tiny):
    teleport_to = null
    doBroomAttack(which_broom_attack)
    if linear_velocity.y < 0 and transformation != TransformationState.FISHY:
      linear_velocity.y = 0
  elif Input.is_action_just_pressed("sub_action_button") and summonedBroom and not pauseSelf and not global.pauseGame:
    if can_throw_broom:
      teleport_to = null
      summonedBroom.queue_free()
      broomStop()
      if not on_ground:
        var amt = 2
        self.vv = amt
        self.linear_velocity.y = amt
        self.lv.y = amt
      summonFallenBroom(true)
    elif on_ground or was_walking_into_wall:
      summonedBroom.queue_free()
      broomStop()
      doBroomAttack(1)
  # elif Input.is_action_pressed("sub_action_button") and not summonedBroom and not pauseSelf and on_ground and is_pressing_horizontal_input:
  #   hitStuff(delta)
  # elif aniPlayer.assigned_animation == "sweepFloor" and isKindOfOnGround():
  #   vv = 0
  #   lv.y = 0
  #   linear_velocity.y = 0
  #   hitStuff(delta)
  #   # global_transform.origin.y = last_grounded_pos.y
  #   if can_throw_broom and Input.is_action_just_pressed("sub_action_button"):
  #     broomStop()
  #     summonFallenBroom(true)
  force_a_sweep = false

func sneezeCloud():
  gravitySound.pitch_scale = rand_range(0.8, 1.2)
  gravitySound.play()
  glitchTickle()
  summonSmokeClouds(1, false, true, 1)

var is_in_mini_cutscene = false
func startCutsceneIntroAni(aniName):
  if summonedBroom:
    broomStop()
  is_in_mini_cutscene = true
  pauseAnimation = true
  pauseInput = true
  pauseSelf = true
  global.pauseMoveInput = true
  global.shouldRenderAsCinematic = true
  level.gameCamera.zoom_in_on_player = true
  level.gameCamera.zoomed_size = 3 * level.gameCamera.initial_size / 4
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play(aniName)

func finishCutsceneIntroAni():
  is_in_mini_cutscene = false
  pauseAnimation = false
  pauseInput = false
  pauseSelf = false
  global.pauseMoveInput = false
  global.shouldRenderAsCinematic = false
  level.gameCamera.zoom_in_on_player = false
  level.gameCamera.zoomed_size = level.gameCamera.initial_size
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("fall")


var SOFT_SAND_TOP_TILE = 275
func doBroomAttack(which_broom_attack):
  if isItWeird():
    return
  # TODO(jaketrower): has just turned around
  # if Input.is_action_pressed("ui_down") and isKindOfOnGround():
  #   aniPlayer.play("sweepFloor")
  #   which_broom_attack = 0
  #   summonSporeShroom()

  if transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE:
    getBubbleCured()

  var is_turn_around_attack = false # (is_pressing_horizontal_input and ((mySprite.flip_h and lv.x > -1) or (not mySprite.flip_h and lv.x < 1)))
  if not force_a_sweep and is_turn_around_attack: #is_in_broom_cooldown or is_turn_around_attack:
    mySprite.flip_h = pressingMoveLeft() and not pressingMoveRight()
    which_broom_attack = 2

  if transformation != TransformationState.FISHY:
    aniPlayer.stop()
    aniPlayer.clear_queue()
    pauseAnimation = true
    if which_broom_attack == 1:
      aniPlayer.play("broomSmack")
    else:
      aniPlayer.play("broomSmack2")

  is_in_broom_cooldown = false
  broom_cooldown_timer = 0
  # elif glitch_form == global.GlitchForm.FEATHER:
  #   broom_cooldown_timer = -broom_cooldown_time_limit * 1.5
  # velocity_dampener = 2.0
  if on_ground and transformation != TransformationState.FISHY:
    walk_speed = 0
    feather_glitch_walk_speed = 0
    invisible_glitch_walk_speed = 0
  global.incrementLevelZoneSweeps()
  jump_press_timer = jump_press_broom_time_limit
  if which_broom_attack > 0:
    pauseInput = transformation != TransformationState.FISHY
    summonedBroom = summonedBroomRes.instance()
    level.add_child(summonedBroom)
    if which_broom_attack == 2:
      summonedBroom.aniPlayer.stop()
      summonedBroom.aniPlayer.clear_queue()
      summonedBroom.aniPlayer.play("broomSmack2")
      summonedBroom.broom_active_time_limit = 15
      is_in_broom_cooldown = false
    if smacked_npc != null or (global.activeInteractor != null and is_instance_valid(global.activeInteractor)):
      if smacked_npc == null:
        smacked_npc = global.activeInteractor.textboxParent
      summonedBroom.smacked_npc = smacked_npc
    summonedBroom.my_broom_owner = self
    adjustSummonedBroomSpritePosition()
    # if global.memory["zora_flippers"] > 0 and global.memory["zora_flippers_enabled"]:
    #   var bubble = bubbleRes.instance()
    #   # bubble.mySprite.material_override.set_shader_param("enable_no_transparency", true)
    #   bubble.can_broom_pop_me = false
    #   bubble.is_horizontal = true
    #   level.add_child(bubble)
    #   bubble.setAsParent(self)
    #   bubble.global_transform.origin = global_transform.origin
    #   if mySprite.flip_h:
    #     bubble.global_transform.origin.x -= 2
    #     bubble.horizontal_direction = -1
    #   else:
    #     bubble.global_transform.origin.x += 2
    #     bubble.horizontal_direction = 1
    #   bubble.my_original_pos = bubble.global_transform.origin.y
    #   bubble.my_target_pos = bubble.global_transform.origin.y  + rand_range(-1, 1)
    #   if abs(linear_velocity.x) > 1:
    #     bubble.my_speed = abs(linear_velocity.x) * 0.9
  
  # if global.memory["debug_broom"]:
  #   var x = global_transform.origin.x
  #   var y = global_transform.origin.y
  #   var z = global_transform.origin.z
  #   if mySprite.flip_h:
  #     if checkSolidTilesOnMyLeft(true):
  #       levelTiles.removeTile(Vector3(x - 3, y + 0, z), false)
  #       levelTiles.removeTile(Vector3(x - 4, y + 0, z), false)
  #       levelTiles.removeTile(Vector3(x - 3, y - 1, z), false)
  #       levelTiles.removeTile(Vector3(x - 4, y - 1, z), false)
  #     else:
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x - 3, y + 0, z), false, false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x - 4, y + 0, z), false, false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x - 3, y - 1, z), false, false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x - 4, y - 1, z), false, false)
  #   else:
  #     if checkSolidTilesOnMyRight(true):
  #       levelTiles.removeTile(Vector3(x + 1, y + 0, z), false)
  #       levelTiles.removeTile(Vector3(x + 2, y + 0, z), false)
  #       levelTiles.removeTile(Vector3(x + 1, y - 1, z), false)
  #       levelTiles.removeTile(Vector3(x + 2, y - 1, z), false)
  #     else:
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x + 1, y + 0, z), false, false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x + 2, y + 0, z), false, false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x + 1, y - 1, z), false, false)
  #       levelTiles.addTile(SOFT_SAND_TOP_TILE, Vector3(x + 2, y - 1, z), false, false)

onready var snoreSound = get_node("Sounds/SnoreSound")
onready var exhaleSound = get_node("Sounds/ExhaleSound")
func getSnorePitchMin():
  if nesting_doll_state == global.NestingDoll.BABY:
    return 2.5
  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    return 0.4
  return 0.8
func getSnorePitchMax():
  if nesting_doll_state == global.NestingDoll.BABY:
    return 3.0
  if nesting_doll_state == global.NestingDoll.MATRIARCH:
    return 0.8
  return 1.2

func breathInSnore():
  snoreSound.pitch_scale = rand_range(getSnorePitchMin(), getSnorePitchMax())
  snoreSound.play()

func spawnSnoreBubble():
  exhaleSound.pitch_scale = rand_range(getSnorePitchMin(), getSnorePitchMax())
  exhaleSound.play()
  if global.memory["zora_flippers"] > 0 and global.memory["zora_flippers_enabled"]:
    var bubble = bubbleRes.instance()
    bubble.is_horizontal = true
    level.add_child(bubble)
    bubble.setAsParent(self)
    bubble.global_transform.origin = global_transform.origin
    if mySprite.flip_h:
      bubble.global_transform.origin.x -= 2
      bubble.horizontal_direction = -1
    else:
      bubble.global_transform.origin.x += 2
      bubble.horizontal_direction = 1
    bubble.my_original_pos = bubble.global_transform.origin.y
    bubble.my_target_pos = bubble.global_transform.origin.y  + rand_range(-1, 1)
  else:
    summonSmokeClouds(1, false, true, 1)

var spore_spawn_timer = 0
var spore_spawn_time_limit = 15
onready var inventorySound = get_node("Sounds/InventorySound")
onready var pauseSound = get_node("Sounds/PauseSound")
onready var unpauseSound = get_node("Sounds/UnpauseSound")
func processMushroomLogic(_delta):
  if is_mushroom_infected:
    glitchTickle()
  # mushroomSpriteVisible.visible = is_mushroom_infected
  # should_collide_horizontally = not is_mushroom_infected # careful! interacts with processMoleLogic
  # if not is_mushroom_infected:
  #   return

  # var my_y = global_transform.origin.y
  # global_transform.origin.y += 1
  # var solid_tiles = getTilesBelow(getLevelTiles())
  # if solid_tiles[0] != null or solid_tiles[1] != null or solid_tiles[2] != null:
  #   # my_y += delta*11
  #   glitchTickle()
  # global_transform.origin.y = my_y
  
  # spore_spawn_timer += (delta*22)
  # if spore_spawn_timer >= spore_spawn_time_limit:
  #   spore_spawn_timer = 0
  #   spawnASpore()
  #   # sporeSound.pitch_scale = rand_range(2.0, 2.8)
  #   # sporeSound.play()

  # mushroomSpriteVisible.frame = mushroomSpriteAnimated.frame
  # mushroomSpriteVisible.translation = mushroomSpriteAnimated.translation
  # mushroomSpriteVisible.scale = mushroomSpriteAnimated.scale
  # mushroomSpriteVisible.flip_h = false
  # if mySprite.flip_h:
  #   mushroomSpriteVisible.flip_h = true
  #   mushroomSpriteVisible.translation.x *= -1

var should_flip = false
# @override
func processHorizontalInputs(delta):
  .processHorizontalInputs(delta)
  if transformation == TransformationState.MOLE_DIGGING and glitch_form != global.GlitchForm.FLOOR:
    hv = Vector3(0, 0, 0)
  # if is_mushroom_infected:
  #   should_flip = not should_flip
  #   var turning_left = mushroom_infection_direction == 1 and Input.is_action_pressed("ui_left")
  #   var turning_right = mushroom_infection_direction == -1 and Input.is_action_pressed("ui_right")
  #   if turning_left or turning_right:
  #     mushroom_turn_timer += (delta*22) if on_ground else mushroom_turn_time_limit
  #     if should_flip: mySprite.flip_h = not mySprite.flip_h
  #     if mushroom_turn_timer >= mushroom_turn_time_limit:
  #       mushroom_turn_timer = 0
  #       mushroom_infection_direction *= -1
  #   else:
  #     mushroom_turn_timer = 0

func adjustSummonedBroomSpritePosition():
  var xAddition = 0
  var yAddition = 0
  if summonedBroom.aniPlayer.assigned_animation == "broomSmack" or summonedBroom.aniPlayer.assigned_animation == "sweepWall":
    xAddition = .875
    yAddition = .625
  elif summonedBroom.aniPlayer.assigned_animation == "broomSmack2":
    xAddition = .4
    yAddition = 0

  broomSpriteVisible.visible = false
  if mySprite.flip_h:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x - xAddition
    summonedBroom.rotation_degrees = Vector3(0, 180, 0)
  else:
    summonedBroom.global_transform.origin.x = self.global_transform.origin.x + xAddition
    summonedBroom.rotation_degrees = Vector3(0, 0, 0)

  if self.grav < 0:
    summonedBroom.rotation_degrees.x = 180
    yAddition *= -1
    # yAddition -= 3.146
  else:
    summonedBroom.rotation_degrees.x = 0
  summonedBroom.rotation_degrees.z = spriteContainer.rotation_degrees.z

  summonedBroom.global_transform.origin.y = self.global_transform.origin.y + yAddition
  summonedBroom.global_transform.origin.z = self.global_transform.origin.z + 1.5

func shouldAirHaveFriction():
  return summonedBroom == null and .shouldAirHaveFriction()

var cloud_timer = 0
var cloud_time_limit = 15
var bug_sprite_timer = 0
var bug_sprite_time_limit = 5
func processSpriteRenderLogic(delta):
  if malware_infected: # or physics_state == PhysicsState.BEING_TOSSED: 
    corruptAllSprites()
    cloud_timer += (delta*11)
    if cloud_timer >= cloud_time_limit:
      cloud_timer = 0
      glitchTickle()
      # getSmacked()
    # bug_sprite_timer += (delta*11)
    # if bug_sprite_timer >= bug_sprite_time_limit:
    #   bug_sprite_timer = 0
    #   var newMalwareBugSprite = malwareBugSpriteRes.instance()
    #   var which_dir_x = ((randi() % 3) - 1)
    #   var which_dir_y = ((randi() % 3) - 1) if which_dir_x != 0 else -1 if (randi() % 2) == 0 else 1 # complicated...
    #   newMalwareBugSprite.which_direction = Vector3(which_dir_x, which_dir_y, 0)
    #   level.add_child(newMalwareBugSprite)
    #   newMalwareBugSprite.global_transform.origin = self.global_transform.origin + newMalwareBugSprite.which_direction
    #   newMalwareBugSprite.global_transform.origin.z += 1
  elif physics_state == PhysicsState.NORMAL and not malware_infected:
    uncorruptAllSprites()

  if grav < 0:
    if spriteContainer.rotation_degrees.x != 180:
      spriteContainer.get_node("InnerSpriteContainer").translation.z = -1
      spriteContainer.rotation_degrees.x = 180
  else:
    if spriteContainer.rotation_degrees.x != 0:
      spriteContainer.get_node("InnerSpriteContainer").translation.z = 0
      spriteContainer.rotation_degrees.x = 0

# var broom_flip_h = false
func processBroomRenderLogic(_delta):
  broomSpriteVisible.frame = broomSpriteAnimated.frame
  broomSpriteVisible.translation = broomSpriteAnimated.translation
  broomSpriteVisible.scale = broomSpriteAnimated.scale
  global.updateBroomSpriteTexture(broomSpriteVisible, false)

  secretSweepActualCollisionShape.translation = secretSweepCollisionShape.translation
  broomSpriteVisible.flip_h = false
  if not can_broomerang_warp:
    broomSpriteVisible.material_override.set_shader_param("target_palette", global.black_player_palette)
  else:
    broomSpriteVisible.material_override.set_shader_param("target_palette", global.player_red_palette)
  if mySprite.flip_h:
    broomSpriteVisible.flip_h = true
    broomSpriteVisible.translation.x *= -1
    secretSweepActualCollisionShape.translation.x *= -1
  if aniPlayer.assigned_animation != "broomSmackGlitch":
    if global.memory["glitched_broom"]:
      broomSpriteVisible.material_override.set_shader_param("enable_glitch", true)
      broomSpriteVisible.material_override.set_shader_param("enable_palette_cycle", true)
      # mySprite.material_override.set_shader_param("enable_palette_cycle", true)
    else:
      broomSpriteVisible.material_override.set_shader_param("enable_glitch", false)
      broomSpriteVisible.material_override.set_shader_param("enable_palette_cycle", false)
      # mySprite.material_override.set_shader_param("enable_palette_cycle", false)
    
  if physics_state == PhysicsState.OCCUPIED:
    broomSpriteVisible.visible = false
    if nesting_doll_state == global.NestingDoll.GRANDMA:
      mySprite.material_override.set_shader_param("texture_albedo", spriteSheetNoBroom)
      for sprite in [self.mySprite, self.grandmaHatSprite, self.grandmaHandSprite, self.grandmaFishHatSprite]:
        sprite.material_override.set_shader_param("black_offset", 0)
  elif summonedBroom != null:
    adjustSummonedBroomSpritePosition()
  elif global.memory["broom"] and not isHoldingMultiBroom() and not (transformation == TransformationState.BUBBLE or glitch_form == global.GlitchForm.BUBBLE):
    broomSpriteVisible.visible = true
    if nesting_doll_state == global.NestingDoll.GRANDMA:
      mySprite.material_override.set_shader_param("texture_albedo", spriteSheet)
      for sprite in [self.mySprite, self.grandmaHatSprite, self.grandmaHandSprite, self.grandmaFishHatSprite]:
        sprite.material_override.set_shader_param("black_offset", 0 if (level.getLevelName().find("MainMenu") > 0 and global.has_started_game) else 1)
  else:
    broomSpriteVisible.visible = false
    if nesting_doll_state == global.NestingDoll.GRANDMA and not isHoldingMultiBroom():
      mySprite.material_override.set_shader_param("texture_albedo", spriteSheetNoBroom)
      for sprite in [self.mySprite, self.grandmaHatSprite, self.grandmaHandSprite, self.grandmaFishHatSprite]:
        sprite.material_override.set_shader_param("black_offset", 0)

func processBagRenderLogic(_delta):
  enchantedBagSpriteVisible.frame = enchantedBagSpriteAnimated.frame
  enchantedBagSpriteVisible.translation = enchantedBagSpriteAnimated.translation
  enchantedBagSpriteVisible.flip_h = false
  if mySprite.flip_h:
    enchantedBagSpriteVisible.flip_h = true
    enchantedBagSpriteVisible.translation.x *= -1
    
  # if summonedBroom != null:
  #   adjustSummonedBroomSpritePosition()
  if global.memory["hp"] > 1 and transformation != TransformationState.UNDERGROUND_RETURNING and transformation != TransformationState.UNDERGROUND:
    enchantedBagSpriteVisible.visible = true
  else:
    enchantedBagSpriteVisible.visible = false


func processPoisonWaterLogic(_delta):
  pass
#  var is_touching_poison_water = is_touching_water and touched_water_area != null and touched_water_area.get_node("..").is_poison

  # if is_touching_poison_water:
  #   is_mushroom_infected = true
  #   grav = 0

  # if is_touching_poison_water:
  #   if glitch_form == global.GlitchForm.INVISIBLE:
  #     tryDieToEnemy(delta, true, false)
  #   else:
  #     if poison_timer == 0 or unpoison_timer > 0:
  #       poisonWaterSound.play()
  #     elif reversePoisonWaterSound.is_playing():
  #       # TODO(jaketrower): Could be put in a function
  #       var playback_position = reversePoisonWaterSound.get_playback_position()
  #       var sound_length = reversePoisonWaterSound.stream.get_length()
  #       poisonWaterSound.play(sound_length - playback_position)
  #       reversePoisonWaterSound.stop()
  #     # If trying to jump out of water a lot... poison harder!
  #     if unpoison_timer > 0:
  #       poison_timer += (delta * 220)
  #       unpoison_timer = 0
  #     poison_timer += (delta*22)
  #     if poison_timer > 7:
  #       glitchTickle(0)
  #     if poison_timer >= poison_time_limit:
  #       tryDieToEnemy(delta, true, false)
  #       poison_timer = 0
  #       poisonWaterSound.stop()

  # if (not is_touching_poison_water or glitch_form == global.GlitchForm.INVISIBLE) and poison_timer > 0:
  #   if poisonWaterSound.is_playing():
  #     # TODO(jaketrower): Could be put in a function
  #     var playback_position = poisonWaterSound.get_playback_position()
  #     var sound_length = poisonWaterSound.stream.get_length()
  #     reversePoisonWaterSound.play(sound_length - playback_position)
  #     poisonWaterSound.stop()
  #   # decrease more slowly than it increases... toxic
  #   unpoison_timer += (delta * 22)
  #   if unpoison_timer >= unpoison_time_limit:
  #     poison_timer -= (delta * 22)
  #     if poison_timer <= 0:
  #       poison_timer = 0
  #       level.glitchScreenEffect.visible = false
  #       musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
  #       reversePoisonWaterSound.stop()

  # if poison_timer > 0:
  #   level.glitchScreenEffect.visible = global.userSettings["canGlitchScreen"]
  #   level.glitchScreenEffect.get_material().set_shader_param("shake_color_rate", (poison_timer*.0005))
  #   musicPlayer.changeSongPitch(abs(sin(poison_timer*.05)+.02))
  # if poison_timer < 0:
  #   poison_timer = 0
  #   level.glitchScreenEffect.visible = false
  #   musicPlayer.changeSongPitch(musicPlayer.default_song_pitch)
  #   reversePoisonWaterSound.stop()
    
var has_landed_since_recovering = true
# @override
func landed():
  if dig_direction == null or not dig_direction.y <= 0 or not pressingDown():
    dig_timer = 0
  .landed()
  if not (is_mushroom_infected or is_mushroom_prefected):
    has_landed_since_recovering = true
  has_broom_flown = not global.memory["broom"]
  if has_broom_flown:
    has_landed_since_last_flight = true
  num_spell_casts_used = 0
  camera_target_y_pos = global_transform.origin.y
  broom_cooldown_timer = 0
  is_in_broom_cooldown = false
  if physics_state != PhysicsState.BEING_TOSSED and \
     physics_state != PhysicsState.OCCUPIED and \
     transformation != TransformationState.FISHY and \
     not is_pressing_horizontal_input and not was_pressing_horizontal_input:
    summonSmokeClouds(1, false, false, 1)

  has_used_magic_lantern = 0
  if glitch_tickle_timer <= 0:
    for sprite in [mySprite, grandmaHatSprite, grandmaHandSprite, grandmaFishHatSprite]:
      sprite.get_material_override().set_shader_param("enable_remove_skin_tone", false)
  # if nesting_doll_state == global.NestingDoll.BABY and not Input.is_action_pressed("jump_button"):
  #   tryToRevertFromBaby()
  if nesting_doll_state == global.NestingDoll.MOM:
    var lt = getLevelTiles()
    var original_y = global_transform.origin.y
    for _i in range(4):
      var tiles = getTilesBelow(lt)
      if tiles[0] != null:
        lt.rerandomizeTile(tiles[0], lt.getRandomGlitchType())
      if tiles[1] != null:
        lt.rerandomizeTile(tiles[1], lt.getRandomGlitchType())
      if tiles[2] != null:
        lt.rerandomizeTile(tiles[2], lt.getRandomGlitchType())
      global_transform.origin.y -= 1
    global_transform.origin.y = original_y

func tryToRevertFromBaby():
  if nesting_doll_state == global.NestingDoll.BABY:
    shroomAniPlayer.stop()
    shroomAniPlayer.clear_queue()
    shroomAniPlayer.play("RESET")
    shroomAniPlayer.queue("grow")
    shroomAniPlayer.queue("adjust")
    nesting_doll_state = global.NestingDoll.GRANDMA
    global.memory["nesting_doll"] = global.NestingDoll.GRANDMA
    updateNestingDoll(global.NestingDoll.GRANDMA)
    getABroom()
    for _i in range(5):
      spawnASpore(self.global_transform.origin, false)

# @override
func playJumpSound():
  .playJumpSound()
  global.incrementLevelZoneJumps()
  # grannyLandSound.pitch_scale = rand_range(0.6, 1.0)
  # grannyLandSound.play()

func faceDown():
  pass # mySprite.faceDown()

var gimme_mini_crystal_cubes = 0
var gimme_mini_crystal_cubes_timer = 0
var gimme_mini_crystal_cubes_time_limit = 5
func giveMeMiniCrystalCubes(how_many):
  gimme_mini_crystal_cubes = how_many
  gimme_mini_crystal_cubes_timer = 0

var lose_mini_crystal_cubes = 0
var lose_mini_crystal_cubes_timer = 0
var lose_mini_crystal_cubes_time_limit = 5
func loseMiniCrystalCubes(how_many):
  lose_mini_crystal_cubes = how_many
  lose_mini_crystal_cubes_timer = 0

var fallenBroomRef = null
func iFellFlat():
  summonFallenBroom(false, true, false)

var respawn_broom_timer = 0
var respawn_broom_time_limit = 3
var should_respawn_broom = false
func summonFallenBroom(was_thrown, should_die_on_land = false, should_return = true):
  if not global.memory["broom"] or not broomSpriteVisible.visible or isTextboxPausingMe():
    return null
  broomSpriteVisible.visible = false
  summonSmokeClouds(3, false, false)
  var fallenBroom = fallenBroomRes.instance()
  level.add_child(fallenBroom)
  if smacked_npc != null:
    fallenBroom.smacked_npc = smacked_npc
  fallenBroom.mySprite.flip_h = self.mySprite.flip_h
  fallenBroom.should_die_on_land = should_die_on_land
  fallenBroom.should_return = should_return
  fallenBroom.global_transform.origin = self.global_transform.origin
  fallenBroom.global_transform.origin.x += -1 if mySprite.flip_h else 1
  fallenBroom.walk_direction = Vector2(-1 if mySprite.flip_h else 1, 0)
  if grav > 0:
    fallenBroom.global_transform.origin.y += 2
  if was_thrown:
    global.incrementLevelZoneSweeps()
    fallenBroom.grav = 1
    fallenBroom.projectile = true
    # if global.memory["magic_lantern"]:
    #   fallenBroom.should_collide_ceil = false
    #   fallenBroom.should_collide_floor = false
    #   fallenBroom.should_collide_horizontally = false
    fallenBroom.global_transform.origin.y -= 1
    # if global.memory["broom_flight"] and not has_broom_flown and not on_ground:
    #   fallenBroom.global_transform.origin.y = self.global_transform.origin.y
    #   fallenBroom.taking_the_player_with_me = true
    fallenBroom.true_terminal_vel = 0
    fallenBroom.walk_speed *= (2.0 if pressingRun() else 1.5)
    fallenBroom.get_node("BroomSound").play()
    var x_direction = 0
    if rawPressingMoveLeft():
      x_direction = -1
    elif rawPressingMoveRight():
      x_direction = 1
    if rawPressingMoveUp():
      fallenBroom.walk_speed *= .7
      fallenBroom.walk_direction = Vector2(x_direction, 1)
      fallenBroom.just_pressed_jump = true
      fallenBroom.pressing_jump = true
      fallenBroom.grav = 0
      fallenBroom.jump_force = 12.0 if x_direction == 0 else 12 * .7
      fallenBroom.thrown_direction.y = 1
    elif rawPressingMoveDown():
      fallenBroom.walk_speed *= .7
      fallenBroom.walk_direction = Vector2(x_direction, -1)
      fallenBroom.grav = 600
      fallenBroom.true_terminal_vel = 12.0 if x_direction == 0 else 12 * .7
      fallenBroom.thrown_direction.y = -1
    elif x_direction != 0:
      fallenBroom.walk_direction.x = x_direction
    fallenBroom.thrown_direction.x = fallenBroom.walk_direction.x
    if global.memory["zora_flippers"] > 0 and global.memory["zora_flippers_enabled"] and can_spawn_broomerang_bubbles:
      can_spawn_broomerang_bubbles = on_ground
      for _i in range(3):
        var bubble = bubbleRes.instance()
        # bubble.mySprite.material_override.set_shader_param("enable_no_transparency", true)
        bubble.can_broom_pop_me = false
        level.add_child(bubble)
        bubble.setAsParent(self)
        bubble.global_transform.origin = global_transform.origin
        bubble.global_transform.origin.x += rand_range(-1, 1)
        bubble.global_transform.origin.y += rand_range(0, 1)
        if mySprite.flip_h:
          bubble.global_transform.origin.x -= 3
        else:
          bubble.global_transform.origin.x += 3
        bubble.global_transform.origin.y -= 1
        bubble.my_original_pos = bubble.global_transform.origin.x
        bubble.my_target_pos = bubble.global_transform.origin.x  + rand_range(-1, 1)

  global.memory["broom"] = false # global.memory["broomerang"] >= 2
  if global.memory["broomerang"] >= 2 and was_thrown:
    should_respawn_broom = true
    respawn_broom_timer = 0
  # var fallenBroomArray = self.get_tree().get_nodes_in_group("fallen_broom_group")
  # if was_thrown and fallenBroomArray.size() < global.memory["broomerang"]:
  #   global.memory["broom"] = true

  if (fallenBroom.walk_direction.x < 0 or mySprite.flip_h) and was_thrown:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse", -1, 2.0)
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin", -1, 2.0)
  elif (fallenBroom.walk_direction.x < 0 or mySprite.flip_h) and not was_thrown:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin")
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse")
  elif (fallenBroom.walk_direction.x > 0  or not mySprite.flip_h) and was_thrown:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin", -1, 2.0)
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse", -1, 2.0)
  else:
    if grav > 0:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpinReverse")
    else:
      fallenBroom.get_node("SecretAnimationPlayer").play("AirSpin")
  fallenBroomRef = weakref(fallenBroom)
  return fallenBroomRef

func iJustPressedDown():
  if glitch_form == global.GlitchForm.FLOOR and on_ground and not truly_on_ground:
    sporeSound.play()
    .iJustPressedDown() # super
    return

  on_ground = false
  was_fallthrough_area_collision_triggered = false
  tryClearFallthroughCollisionSolid(self.global_transform.origin)

var is_active = true
func setGlobalMemoryOfHasSpoken(_set_vars = false):
  # no-op for now
  pass
func idleTalk():
  # no-op for now
  pass
func appendNextTextCharacter():
  # no-op for now
  pass

# used for positioning secretSweepActualArea
onready var secretSweepArea = get_node("SpriteContainer/SecretSweepArea")
onready var secretSweepCollisionShape = get_node("SpriteContainer/SecretSweepArea/CollisionShape")
# used for actually sweeping up glitch tiles
onready var secretSweepActualArea = get_node("SpriteContainer/SecretSweepAreaActual")
onready var secretSweepActualCollisionShape = get_node("SpriteContainer/SecretSweepAreaActual/CollisionShape")

func swordClank(play_sound = true):
  if summonedBroom:
    broomStop()
  getSmacked()
  if play_sound:
    broomSound.play()

func getItemFailsafe():
  if global.activeInteractor == null:
    if physics_state == PhysicsState.OCCUPIED:
      physics_state = PhysicsState.NORMAL
      global.isRespawning = false
    pauseAnimation = false
    pauseSelf = false
    global.pauseMoveInput = false
    global.pauseGame = false
