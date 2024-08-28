extends "../../../scripts/levelScript.gd"

# onready var npcGranny = get_node("NPC") if has_node("NPC") else null
# onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
var original_granny_text = ""
var is_start_of_game = true
var has_decided = false

# @override
func setUpRoomInitializationOverride():
  # original_granny_text = npcGranny.textBox.text_final
  if (global.memory.has("roomPath") and (not ("000PastoralScene" in global.memory["roomPath"])))or not global.memory.has("roomPath"):
    is_start_of_game = false
    # npcGranny.is_really_important = true
    # npcGranny.textBox.is_really_important = true
  else:
    global.pauseMoveInput = true
    global.shouldRenderAsCinematic = true
    player.fall_timer = 50
    uiLayer.statsTitleRect.visible = false
    uiLayer.get_node("GlitchSprite").visible = false
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
      print("true 1")
    elif player.physics_state == player.PhysicsState.NORMAL and player.on_ground:
      is_start_of_game = false
      global.pauseMoveInput = false
      global.shouldRenderAsCinematic = false
      player.textBox.interact()
      global.activeInteractor = player.textBox
      showInstructions = false
      print("false 2")
  
  if showInstructions:
    uiLayer.get_node("PressC").visible = global.activeInteractor == null and player.physics_state != player.PhysicsState.WAKING_UP
