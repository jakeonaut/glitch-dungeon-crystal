extends "../../../scripts/levelScript.gd"

# @override
func setUpRoomInitializationOverride():
  var roomPath = global.memory["roomPath"] if global.memory.has("roomPath") else null
  if not global.has_sneezed and (roomPath == null or "0_1Haven" in roomPath):
    gameCamera.zoom_in_on_player = true
    gameCamera.zoomed_size = 3 * gameCamera.initial_size / 4
    player.override_press_move_left = true
    yield(get_tree().create_timer(0.2), "timeout")
    player.override_press_move_left = false
    global.shouldRenderAsCinematic = true
    global.pauseMoveInput = true
    player.pauseInput = true
    yield(get_tree().create_timer(0.2), "timeout")
    player.startCutsceneIntroAni("sneeze")
    global.has_sneezed = true
    
