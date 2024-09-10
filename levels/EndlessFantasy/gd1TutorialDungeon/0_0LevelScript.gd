extends "../../../scripts/levelScript.gd"

# onready var npcGranny = get_node("NPC") if has_node("NPC") else null
# onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
var original_granny_text = ""
var is_start_of_game = true
var has_decided = false

# @override
func setUpRoomInitializationOverride():
  # original_granny_text = npcGranny.textBox.text_final
  if global.memory.has("roomPath") and (not ("000PastoralScene" in global.memory["roomPath"])):
    is_start_of_game = false
    showInstructions = false
    # npcGranny.is_really_important = true
    # npcGranny.textBox.is_really_important = true
  else:
    global.pauseMoveInput = true
    global.shouldRenderAsCinematic = true
    player.fall_timer = 50
    uiLayer.statsTitleRect.visible = false
    uiLayer.get_node("GlitchStatusRect").visible = false
  has_decided = true
  
var showInstructions = false
func _process(_delta):
  # ._process(delta) implicit

  if not has_decided:
    return
  
  if is_start_of_game:
    global.pauseMoveInput = true
    global.shouldRenderAsCinematic = true
    player.fall_timer = 999
    if player.physics_state == player.PhysicsState.COLLAPSED or \
       player.physics_state == player.PhysicsState.CAN_WAKE_UP:
      global.pauseMoveInput = false
      global.shouldRenderAsCinematic = false
      yield(get_tree().create_timer(2.0), "timeout")
      showInstructions = true
    elif player.physics_state == player.PhysicsState.NORMAL and player.on_ground:
      is_start_of_game = false
      global.pauseMoveInput = false
      global.shouldRenderAsCinematic = false
      player.textBox.interact()
      global.activeInteractor = player.textBox
      showInstructions = false
  
  var pressCText = uiLayer.get_node("PressC")
  if global.isPauseMenuOpen or not showInstructions:
    pressCText.visible = false
  elif showInstructions:
    var is_controller_connected = Input.get_connected_joypads().size() > 0
    # TODO(jaketrower): I don't super love this but...
    pressCText.visible = (global.activeInteractor == null and not global.isPauseMenuOpen)
    if player.physics_state == player.PhysicsState.WAKING_UP or player.physics_state == player.PhysicsState.WAKING_UP:
      showInstructions = false
    if is_controller_connected:
      pressCText.bbcode_text = "        " + global.getInputText("jump_button") + " to Jump. " + global.getInputText("sub_action_button") + " to Sweep."
    else:
      pressCText.bbcode_text = global.getInputText("jump_button") + " to Jump. " + global.getInputText("sub_action_button") + " to Sweep. Arrow keys to walk.."
