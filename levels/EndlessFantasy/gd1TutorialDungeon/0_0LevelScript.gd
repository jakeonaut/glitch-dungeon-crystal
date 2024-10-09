extends "../../../scripts/levelScript.gd"

# onready var npcGranny = get_node("NPC") if has_node("NPC") else null
# onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
var has_decided = false
var should_i_show_prompt = false

# @override
func setUpRoomInitializationOverride():
  if not global.okay_really_really_started_game:
    global.pauseMoveInput = true
    global.shouldRenderAsCinematic = true
    player.fall_timer = 50
    uiLayer.statsTitleRect.visible = false
    uiLayer.get_node("GlitchStatusRect").visible = false
    should_i_show_prompt = true
  has_decided = true
  
var showInstructions = false
onready var pressCText = get_node("../../UILayer/PressC")
onready var optionsMenuPrompt = get_node("../../UILayer/OptionsMenuPrompt")
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
      yield(get_tree().create_timer(3.0), "timeout")
      if player.physics_state == player.PhysicsState.COLLAPSED or \
         player.physics_state == player.PhysicsState.CAN_WAKE_UP:
        showInstructions = true
    elif player.physics_state == player.PhysicsState.NORMAL and player.on_ground:
      global.pauseMoveInput = false
      global.shouldRenderAsCinematic = false
      player.textBox.interact()
      global.activeInteractor = player.textBox
      showInstructions = false
      should_i_show_prompt = false
  

  if showInstructions:
    pressCText.visible = true
    optionsMenuPrompt.visible = true
    if global.isPauseMenuOpen:
      pressCText.visible = false
      optionsMenuPrompt.visible = false
    var is_controller_connected = Input.get_connected_joypads().size() > 0
    # TODO(jaketrower): I don't super love this but...
    pressCText.visible = (global.activeInteractor == null and not global.isPauseMenuOpen)
    optionsMenuPrompt.visible = pressCText.visible
    if player.physics_state == player.PhysicsState.WAKING_UP or player.physics_state == player.PhysicsState.WAKING_UP:
      showInstructions = false
    optionsMenuPrompt.bbcode_text = "Press " + global.getInputText("ui_start") + " for OPTIONS"
    pressCText.bbcode_text = global.getInputText("sub_action_button") + " to Sweep. " + global.getInputText("jump_button") + " to Jump. " + global.getInputText("ui_left")  + global.getInputText("ui_right") + " to walk"
  else:
    pressCText.visible = false
    optionsMenuPrompt.visible = false
