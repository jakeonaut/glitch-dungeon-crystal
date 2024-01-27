extends "../../../scripts/levelScript.gd"

onready var npcGranny = get_node("NPC")
onready var frogCroneNpc = weakref(get_node("GlitchTileSpawner/NPC3"))
var original_granny_text = ""
var is_start_of_game = true
var has_decided = false

# @override
func setUpRoomInitializationOverride():
  original_granny_text = npcGranny.textBox.text_final
  if not global.memory.has("roomPath") or (global.memory.has("roomPath") and (not ("001CozyHome" in global.memory["roomPath"]))):
    is_start_of_game = false
    npcGranny.is_really_important = true
    npcGranny.textBox.is_really_important = true
  else:
    global.pauseMoveInput = true
    player.fall_timer = 50
    uiLayer.statsTitleRect.visible = false
    uiLayer.get_node("GlitchSprite").visible = false
    uiLayer.get_node("GlitchStatusRect").visible = false
  has_decided = true

var snarkyCommentTimer = 0
var snarkyCommentTimeLimit = 10
func _process(delta):
  # ._process(delta) implicit

  if not has_decided:
    return
  
  if is_start_of_game:
    global.pauseMoveInput = true
    player.fall_timer = 999
    if player.physics_state == player.PhysicsState.COLLAPSED:
      global.pauseMoveInput = false
    if not global.pauseMoveInput:
      snarkyCommentTimer += (delta*11)
      if snarkyCommentTimer >= snarkyCommentTimeLimit:
        is_start_of_game = false
        # player.textBox.tinify()
        player.textBox.interact()
  else:
    if player.glitch_form == global.GlitchForm.FEATHER:
      npcGranny.textBox.text_final = "•i'm feeling... green?\nas light as a leaf\n i hope i dont get sick.."
    elif player.glitch_form == global.GlitchForm.FLOOR:
      npcGranny.textBox.text_final = "•i'm feeling RED!\nready to move!\nhoo ya!! oh dear me.."
    else:
      npcGranny.textBox.text_final = original_granny_text

  
  if has_decided:
    if frogCroneNpc.get_ref() and frogCroneNpc.get_ref().visible:
      musicPlayer.tryToPlay(musicPlayer.restZonePlayer)
    else:
      musicPlayer.tryToPlay(musicPlayer.dungeonThemePlayer2)
