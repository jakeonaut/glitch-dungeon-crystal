extends "../../../scripts/levelScript.gd"

# String is a path to a file.
export(String, FILE) var memory_zone_path

onready var highPriestessBoss = weakref(get_node("HighPriestessBoss"))
onready var croneNPC = get_node("CroneNPC")
onready var croneNPCDefeated = get_node("CroneNPCDefeated")
# onready var glitchedGrimoire = get_node("GlitchedGrimoire")
onready var theGoddess = get_node("TheGoddess")
onready var savePoint = get_node("SavePoint")
onready var featherSpell = get_node("FeatherSpell")
onready var floorSpell = get_node("FloorSpell")
# onready var ladderSpell2 = get_node("LadderSpell2")
# onready var invisibleSpell = get_node("InvisibleSpell")
onready var aniPlayer = get_node("AnimationPlayer")
onready var grandmaStatues = get_node("GrandmaStatues")
onready var elderTadpoleNPC = weakref(get_node("ElderTadpoleNPC"))
onready var fishElderNPC = weakref(get_node("FishElderNPC"))
onready var sporeElderNPC = weakref(get_node("SporeElderNPC"))
onready var wormElderNPC = weakref(get_node("WormElderNPC"))
onready var secretGoddessNPC = get_node("SecretGoddessNPC")
onready var crystalsContainer = get_node("CrystalsContainer")
onready var highpriestessCrystal = get_node("CrystalsContainer/HighpriestessCrystal")
onready var highpriestessCrystal2 = get_node("CrystalsContainer/HighpriestessCrystal2")
onready var highpriestessCrystal3 = get_node("CrystalsContainer/HighpriestessCrystal3")
onready var highpriestessCrystal4 = get_node("CrystalsContainer/HighpriestessCrystal4")
onready var highpriestessCrystal5 = get_node("CrystalsContainer/HighpriestessCrystal5")
onready var goop3 = get_node("Goop3")
onready var gruesomeChildNPC = get_node("GruesomeChildNPC")
onready var glitchedGeode = get_node("GlitchedGeode")

var has_boss_started = false
var debug_start_boss_immediately = false
export var camera_size = 30
# @override
func setUpRoomInitializationOverride():
  #  TODO(jaketrower): remove this!!!
  if not global.memory.has("roomPath") and global.memory["debug"]:
    debug_start_boss_immediately = true
    # highPriestessBoss.get_ref().MAX_NUM_HITS = 1

  if global.memory["priestess"] == 1:
    debug_start_boss_immediately = true

  var croneAbortSound = croneNPC.textBox.get_node("AbortSound")
  if debug_start_boss_immediately and global.memory["priestess"] < 2:
    goop3.visible = true
    global.memory["glitch_world"] = 1
    crystalsContainer.queue_free()
    gameCamera.initial_size = camera_size
    gameCamera.zoomed_size = camera_size
    aniPlayer.stop()
    aniPlayer.clear_queue()
    unhideHighPriestess()
    has_boss_started = true
    croneAbortSound.which_one = -1
    croneAbortSound.activateScript()
    # global.setStaticLevelZoneLevelVar(self, crystalGeode.get_ref(), true)
    if elderTadpoleNPC.get_ref() != null:
      elderTadpoleNPC.get_ref().visible = false
    if fishElderNPC.get_ref() != null:
      fishElderNPC.get_ref().visible = false
    if sporeElderNPC.get_ref() != null:
      sporeElderNPC.get_ref().visible = false
    if wormElderNPC.get_ref() != null:
      wormElderNPC.get_ref().visible = false
  else:
    highPriestessBoss.get_ref().visible = false
    highPriestessBoss.get_ref().am_i_hidden = true
    highPriestessBoss.get_ref().mySprite.visible = false
    if global.memory["priestess"] >= 2:
      goop3.visible = true
      crystalsContainer.queue_free()
      grandmaStatues.queue_free()
      highPriestessBoss.get_ref().queue_free()
      croneNPC.queue_free()
      croneNPCDefeated.queue_free()
      croneAbortSound.which_one = -1
      has_boss_started = true
      is_defeated = true
      is_really_defeated = true
      # if crystalGeode.get_ref() != null:
      #   crystalGeode.get_ref().visible = false
      pacman_wrapping = false
      # glitchedGrimoire.grav = 20
      # glitchedGrimoire.visible = true
      # glitchedGrimoire.global_transform.origin.y = -4
      # theGoddess.get_node("AnimationPlayer").play("bubbleUp")
      # if global.memory["glitched_grimoire"]:
      #   ladderSpell.visible = true
      #   invisibleSpell.visible = true
      #   savePoint.visible = true

  yield(get_tree().create_timer(0.1), "timeout")
  glitchedGeode.applyGlitchMaterial(0)
  yield(get_tree().create_timer(0.1), "timeout")
  glitchedGeode.visible = false
    
# @override
func playMenuMusic():
  musicPlayer.changeSongPitch(0.5)
  # musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
  pass

# @override
func restartMusic():
  musicPlayer.changeSongPitch(1.0)
  if global.memory["priestess"] == 1:
    musicPlayer.tryToPlay(musicPlayer.boss2ThemePlayer)
  elif global.memory["priestess"] == 0 and debug_start_boss_immediately:
    return
  else:
    musicPlayer.conductFromScenePath(getLevelName())

# @override
func overrideLevelRespawnEvent():
  pass

var random_tiles_timer = 0
var random_tiles_time_limit = 5
var goddess_cutscene_counter = -1
var crystalSpinAmount = 1
var should_start_cutcene = 0
func _process(delta):
  # i hate this but _process is not guaranteed to occur AFTER setUpRoomInitializationOverride
  if not has_room_initialized:
    return

  if not has_boss_started and global.memory["priestess"] == 0:
    if goddess_cutscene_counter == -1 and should_start_cutcene == 1 and player.on_ground:
      global.pauseGame = true
      global.shouldRenderAsCinematic = true
      goddess_cutscene_counter = -99
      yield(get_tree().create_timer(1.0), "timeout")
      # aniPlayer.play("fadeDitherIn")
      # theGoddess.get_node("AnimationPlayer").play("bubbleUp", -1, 0.7)
      goddess_cutscene_counter = 0
      gameCamera.initial_size = camera_size
      gameCamera.zoomed_size = camera_size
    elif goddess_cutscene_counter == 0:
      levelTiles.purifyAllSpikes()
      # if not theGoddess.get_node("AnimationPlayer").is_playing():
      #   secretGoddessNPC.activate(true)
      goddess_cutscene_counter += 1
    elif goddess_cutscene_counter == 1:
      if global.activeInteractor == null:
        # global.memory["glitch_world"] = 1
        goddess_cutscene_counter = 2
        # player.glitch_death_timer = 8
        # player.glitchTickle()
        # glitchScreenEffect.visible = global.userSettings["canGlitchScreen"]
        yield(get_tree().create_timer(1.0), "timeout")
        addNPCToCrystal(fishElderNPC, highpriestessCrystal)
        yield(get_tree().create_timer(1.5), "timeout")
        addNPCToCrystal(wormElderNPC, highpriestessCrystal2)
        yield(get_tree().create_timer(1.5), "timeout")
        addNPCToCrystal(sporeElderNPC, highpriestessCrystal3)
        yield(get_tree().create_timer(1.5), "timeout")
        addNPCToCrystal(elderTadpoleNPC, highpriestessCrystal4)
    elif goddess_cutscene_counter == 2:
      tryLerpUpCrystal(highpriestessCrystal, delta)
      tryLerpUpCrystal(highpriestessCrystal2, delta)
      tryLerpUpCrystal(highpriestessCrystal3, delta)
      tryLerpUpCrystal(highpriestessCrystal4, delta)

      if crystalSpinAmount > 1:
        goop3.visible = true
        global.memory["glitch_world"] = 1
        goddess_cutscene_counter = -99
        yield(get_tree().create_timer(1.0), "timeout")
        player.glitch_death_timer = 8
        player.glitchTickle()
        # aniPlayer.play("fadeDitherOut")
        # theGoddess.get_node("AnimationPlayer").play("disintegrate", -1, 0.4)
        # summonSmokeClouds(highpriestessCrystal5, 3)
        # highpriestessCrystal5.visible = true
        goddess_cutscene_counter = 5
    elif goddess_cutscene_counter == -99:
      tryLerpUpCrystal(highpriestessCrystal, delta)
      tryLerpUpCrystal(highpriestessCrystal2, delta)
      tryLerpUpCrystal(highpriestessCrystal3, delta)
      tryLerpUpCrystal(highpriestessCrystal4, delta)
    elif goddess_cutscene_counter == 3:
      tryLerpUpCrystal(highpriestessCrystal, delta)
      tryLerpUpCrystal(highpriestessCrystal2, delta)
      tryLerpUpCrystal(highpriestessCrystal3, delta)
      tryLerpUpCrystal(highpriestessCrystal4, delta)
      if not theGoddess.get_node("AnimationPlayer").is_playing():
        # crystalGeode.get_ref().visible = true
        # crystalGeode.get_ref().applyGlitchMaterial(0)
        goddess_cutscene_counter = 5
    elif goddess_cutscene_counter == 5:
      highPriestessBoss.get_ref().laughSound.play()
      has_boss_started = true
      levelTiles.randomize_num = 1
      aniPlayer.play("appear")
      gameCamera.initial_size = camera_size
      gameCamera.zoomed_size = camera_size
      player.pauseInput = true
      player.pauseSelf = true
      global.pauseMoveInput = true
      global.pauseGame = true
      global.shouldRenderAsCinematic = true
      musicPlayer.stopAll()
      musicPlayer.tryToPlay(musicPlayer.croneThemePlayer)

  if global.memory["priestess"] <= 0 and goddess_cutscene_counter >= 2 and \
      highpriestessCrystal.global_transform.origin.y > 3 and \
      highpriestessCrystal2.global_transform.origin.y > 3 and \
      highpriestessCrystal3.global_transform.origin.y > 3 and \
      highpriestessCrystal4.global_transform.origin.y > 3:
    crystalsContainer.rotation_degrees.y += (delta*crystalSpinAmount)
    crystalsContainer.global_transform.origin.z = crystalsContainer.global_transform.origin.z + (0 - crystalsContainer.global_transform.origin.z) * (delta*2)
    if crystalSpinAmount <= 200:
      crystalSpinAmount += (delta*22)

    # if crystalGeode.get_ref() == null or crystalGeode.get_ref().getMyStaticLevelZoneVar():
    #   has_boss_started = true
    #   levelTiles.randomize_num = 1
    #   aniPlayer.play("appear")
    #   gameCamera.initial_size = camera_size
    #   gameCamera.zoomed_size = camera_size
    #   player.pauseInput = true
    #   player.pauseSelf = true
    #   global.pauseMoveInput = true
    #   global.pauseGame = true
    #   global.shouldRenderAsCinematic = true
    #   musicPlayer.stopAll()

  if is_defeated and not is_really_defeated:
    player.pauseSelf = true
    player.grav = 0
    if not player.aniPlayer.assigned_animation == "fall":
        player.aniPlayer.stop()
        player.aniPlayer.clear_queue()
        player.aniPlayer.play("fall")
  elif is_defeated and is_really_defeated:
    player.pauseSelf = false
    player.grav = 28

  if (highPriestessBoss.get_ref() != null) and (highPriestessBoss.get_ref().visible or goddess_cutscene_counter >= 0):
    random_tiles_timer += (delta*11)
    if random_tiles_timer >= random_tiles_time_limit:
      random_tiles_timer = 0
      randomizeARandomGameFrameBgSprite()
      # generateRandomTiles()
      if global.memory["priestess"] == 2:
        uiLayer.cloneGlitchedSkullSprite()

func addNPCToCrystal(npcRef, crystal):
  if npcRef.get_ref() == null: return

  theGoddess.get_node("CrystalSound").play()
  summonSmokeClouds(crystal.global_transform.origin, 2)
  crystal.visible = true
  npcRef.get_ref().grav = 0
  self.remove_child(npcRef.get_ref())
  crystal.add_child(npcRef.get_ref())
  npcRef.get_ref().scale = Vector3(0.5, 0.5, 0.5)
  npcRef.get_ref().global_transform.origin = crystal.global_transform.origin

func tryLerpUpCrystal(crystal, delta):
  if crystal.get_child_count() == 2:
    crystal.global_transform.origin.y = crystal.global_transform.origin.y + (4.029 - crystal.global_transform.origin.y) * (delta*2)

func triggerCroneDialog():
  print("trigger crone dialog?")
  croneNPC.activate(true)

var is_defeated = false
var is_really_defeated = false
func triggerCroneDefeatedDialog():
  croneNPCDefeated.activate(true)
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("glitchTransitionStart")
  is_defeated = true
  player.pauseSelf = true
  global.shouldRenderAsCinematic = true
  musicPlayer.stopAll()
  # yield(get_tree().create_timer(0.5), "timeout")
  # summonSmokeClouds(ladderSpell2.global_transform.origin, 1, true, true)
  var grandmaStatueArr = grandmaStatues.get_children()
  for grandmaStatue in grandmaStatueArr:
    summonSmokeClouds(grandmaStatue.global_transform.origin, 1)
    grandmaStatue.queue_free()
    yield(get_tree().create_timer(0.5), "timeout")

func playGlitchTransitionAnimation():
  aniPlayer.stop()
  aniPlayer.clear_queue()
  aniPlayer.play("glitchTransition")
  highPriestessBoss.get_ref().secretAniPlayer.stop()
  highPriestessBoss.get_ref().secretAniPlayer.clear_queue()
  highPriestessBoss.get_ref().secretAniPlayer.play("defeatedEnd")

var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
func glitchNextGrandmaStatue(glitch_form):
  var grandmaStatueToGlitch = null
  var grandmaStatueArr = grandmaStatues.get_children()
  for grandmaStatue in grandmaStatueArr:
    if grandmaStatue.is_in_group("grandma_statue"):
      grandmaStatueToGlitch = grandmaStatue
      break
  if grandmaStatueToGlitch == null:
    return

  var newSpawnGlitchEffect = spawnGlitchEffectRes.instance()
  self.add_child(newSpawnGlitchEffect)
  newSpawnGlitchEffect.global_transform.origin = grandmaStatueToGlitch.global_transform.origin

  summonSmokeClouds(grandmaStatueToGlitch.global_transform.origin, 3)
  var newGlitchGrandmaManager = grandmaStatueToGlitch.glitchMyself(glitch_form)
  newGlitchGrandmaManager.override_am_i_in_range_of_player = true
  reindexGrandmaStatueCatalogue()

func showTheGruesomeChild():
  summonSmokeClouds(gruesomeChildNPC.global_transform.origin, 3, true, true)
  gruesomeChildNPC.visible = true
  gruesomeChildNPC.grav = 60

func enterMemoryZone():
  is_really_defeated = true
  aniPlayer.play("glitchTransitionEnd")
  # aniPlayer.queue("croneTwitch")
  glitchTickle(1)
  # generateEyeTiles()
  # player.grav = player.PLAYER_GRAV
  # player.pauseSelf = false
  # player.nullify()
  # global.shouldRenderAsCinematic = false
  # highPriestessBoss.get_ref().queue_free()
  # self.summonSmokeClouds(glitchedGrimoire.global_transform.origin, 5, true, true)
  # glitchedGrimoire.grav = 20
  # glitchedGrimoire.visible = true
  global.pauseGame = false
  global.shouldRenderAsCinematic = false
  # croneNPC.grav = 20
  # croneNPC.mySprite.updateBaseFrame(6, 7)
  # croneNPC.is_active = true
  # self.pacman_wrapping = false
  global.grannyEnteringRoom = true
  global.isEnteringRoom = true
  # global.memory["roomPath"] = self.getLevelName()
  transition.colorRect.visible = false
  transition.granny_teleport_to("res://levels/EndlessFantasy/gd1CrystalTower/PrimordialOozeRoom.tscn")

func glitchTickle(glitch_death_timer):
  if glitch_death_timer > 1:
    return # lol
  player.glitch_death_timer = glitch_death_timer
  player.glitchTickle()
  glitchScreenEffect.visible = true

func unhideHighPriestess():
  crystalsContainer.queue_free()
  highPriestessBoss.get_ref().visible = true
  highPriestessBoss.get_ref().am_i_hidden = false
  highPriestessBoss.get_ref().mySprite.visible = true
  highPriestessBoss.get_ref().big_spawn_timer = highPriestessBoss.get_ref().initial_big_spawn_timer
  highPriestessBoss.get_ref().laughSound.play()
  global.pauseMoveInput = false
  global.pauseGame = false
  player.pauseInput = false
  player.pauseSelf = false
  global.shouldRenderAsCinematic = false
  uiLayer.setDisplayTitle(tr("UI.BossName.4"))
  # if crystalGeode.get_ref() != null:
  #   crystalGeode.get_ref().queue_free()
  #   crystalGeode2.get_ref().queue_free()
  #   crystalGeode3.get_ref().queue_free()
  #   crystalGeode4.get_ref().queue_free()
  #   crystalGeode5.get_ref().queue_free()
  global.memory["priestess"] = 1
  musicPlayer.stopAll()
  musicPlayer.tryToPlay(musicPlayer.boss2ThemePlayer)
  global.memory["priestess"] = 1
  levelTiles.randomize_num = 1
  # global.memory.erase("spellbookPage")
  # player.nullify()
  # global.memory["broom"] = false
  # generateEyeTiles()

# var climbToEyeLevel = preload("res://levels/EndlessFantasy/gd1CrystalTower/HighPriestessRoom_001climbToEye.tscn")
# func generateEyeTiles():
#   var climbToEyeLevelInstance = climbToEyeLevel.instance()
#   var newLevelTiles = climbToEyeLevelInstance.get_node("Viewport/level/LevelTiles")
#   levelTiles.queueSausageDreamFadeAwayDifference(newLevelTiles, false)
