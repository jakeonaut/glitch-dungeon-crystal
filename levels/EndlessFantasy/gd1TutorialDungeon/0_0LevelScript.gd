extends "../../../scripts/levelScript.gd"

onready var npcGranny = get_node("NPC") if has_node("NPC") else null
onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
var original_granny_text = ""
var is_start_of_game = true
var has_decided = false

# @override
func setUpRoomInitializationOverride():
  # original_granny_text = npcGranny.textBox.text_final
  if (global.memory.has("roomPath") and (not ("001CozyHome" in global.memory["roomPath"]))): # or not global.memory.has("roomPath"):
    is_start_of_game = false
    # npcGranny.is_really_important = true
    # npcGranny.textBox.is_really_important = true
  else:
    global.pauseMoveInput = true
    player.fall_timer = 50
    uiLayer.statsTitleRect.visible = false
    uiLayer.get_node("GlitchSprite").visible = false
    uiLayer.get_node("GlitchStatusRect").visible = false
  has_decided = true
  
func _process(delta):
  # ._process(delta) implicit

  if not has_decided:
    return
  
  if is_start_of_game:
    global.pauseMoveInput = true
    player.fall_timer = 999
    if player.physics_state == player.PhysicsState.COLLAPSED or \
       player.physics_state == player.PhysicsState.CAN_WAKE_UP:
      global.pauseMoveInput = false
    elif player.physics_state == player.PhysicsState.NORMAL and player.on_ground:
      is_start_of_game = false
      global.pauseMoveInput = false
      player.textBox.interact()
        

  if not global.isPauseMenuOpen:
    if not musicPlayer.restZonePlayer.is_playing():
      if frogCroneNpc.get_ref() and frogCroneNpc.get_ref().visible:
        musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
    elif not musicPlayer.dungeonThemePlayer2.is_playing():
      if not (frogCroneNpc.get_ref() and frogCroneNpc.get_ref().visible):
        musicPlayer.tryToPlay(musicPlayer.dungeonThemePlayer2)


# @override
func restartMusic():  
  if has_decided and not global.isPauseMenuOpen:
    if frogCroneNpc.get_ref() and frogCroneNpc.get_ref().visible:
      musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
    else:
      musicPlayer.tryToPlay(musicPlayer.dungeonThemePlayer2)
