extends "../../../scripts/levelScript.gd"

# onready var npcGranny = get_node("NPC") if has_node("NPC") else null
# onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
var has_decided = false
var should_i_show_prompt = false

onready var innerPeaceSound = get_node("InnerPeaceSound")
onready var innerPeaceReverseSound = get_node("InnerPeaceReverseSound")
onready var towerSprite1 = get_node("TowerSprite1")
var croneHatTreasureRes = preload("res://sceneObjects/SpellsTreasureCollectables/Outfits/CroneHatTreasure.tscn")


# @override
func setUpRoomInitializationOverride():
  if not global.okay_really_really_started_game:
    global.pauseMoveInput = true
    global.shouldRenderAsCinematic = true
    player.fall_timer = 50
    uiLayer.statsTitleRect.visible = false
    uiLayer.get_node("GlitchStatusRect").visible = false
    should_i_show_prompt = true
    # yield(get_tree().create_timer(0.01), "timeout")
    # innerPeaceSound.play()
  if global.memory["clean_crystals"] >= 1:
    get_node("GlitchTileSpawner").queue_free()
    get_node("InverseGlitchTileSpawner").queue_free()
    var outfitTreasure = croneHatTreasureRes.instance()
    self.add_child(outfitTreasure)
    outfitTreasure.global_transform.origin = Vector3(24, 7, 0)
  if global.memory["clean_crystals"] >= 4:
    towerSprite1.visible = true
  has_decided = true
  
var showInstructions = false
onready var pressCText = get_node("../../Viewport2/UILayer/PressC")
onready var optionsMenuPrompt = get_node("../../Viewport2/UILayer/OptionsMenuPrompt")
var has_played_sound = false
func _process(_delta):
  # ._process(delta) implicit
  if not has_decided:
    return
  
  if not global.okay_really_really_started_game and should_i_show_prompt:
    global.pauseMoveInput = true
    global.shouldRenderAsCinematic = true
    player.fall_timer = 999
    if player.physics_state == player.PhysicsState.COLLAPSED or \
       player.physics_state == player.PhysicsState.CAN_WAKE_UP:
      global.pauseMoveInput = false
      global.shouldRenderAsCinematic = false
      if not has_played_sound:
          # musicPlayer.tryToPlay(musicPlayer.windPlayer)
          innerPeaceReverseSound.play()
          has_played_sound = true
      yield(get_tree().create_timer(3.0), "timeout")
      if player.physics_state == player.PhysicsState.COLLAPSED or \
         player.physics_state == player.PhysicsState.CAN_WAKE_UP:
        showInstructions = true
    elif player.physics_state == player.PhysicsState.WAKING_UP:
      global.pauseMoveInput = true
    elif player.physics_state == player.PhysicsState.NORMAL and player.on_ground:
      if innerPeaceReverseSound.is_playing():
        innerPeaceReverseSound.stop()
      innerPeaceSound.play()
      global.pauseMoveInput = false
      global.shouldRenderAsCinematic = false
      player.textBox.interact()
      global.okay_really_really_started_game = true
      global.activeInteractor = player.textBox
      showInstructions = false
      should_i_show_prompt = false
  

  if showInstructions:
    pressCText.visible = true
    optionsMenuPrompt.visible = true
    if global.isPauseMenuOpen:
      pressCText.visible = false
      optionsMenuPrompt.visible = false
    # TODO(jaketrower): I don't super love this but...
    pressCText.visible = (global.activeInteractor == null and not global.isPauseMenuOpen)
    optionsMenuPrompt.visible = pressCText.visible
    if player.physics_state == player.PhysicsState.WAKING_UP or player.physics_state == player.PhysicsState.WAKING_UP:
      showInstructions = false
    optionsMenuPrompt.bbcode_text = "" # "Press " + global.getInputText("ui_start") + " for OPTIONS"
    pressCText.bbcode_text = tr("UI.Tutorial.InputPrompt.1") % [global.getInputText("sub_action_button"), global.getInputText("jump_button"), global.getInputText("ui_left"), global.getInputText("ui_right")]
  else:
    pressCText.visible = false
    optionsMenuPrompt.visible = false

# # @override
# func restartMusic():
#     musicPlayer.changeSongPitch(1.0)
#     musicPlayer.tryToPlay(musicPlayer.croneThemePlayer)