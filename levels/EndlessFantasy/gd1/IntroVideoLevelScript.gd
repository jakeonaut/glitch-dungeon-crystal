extends "../../../scripts/levelScript.gd"

onready var videoPlayer = get_node("../../Viewport2/VideoPlayer")
onready var mainMenuDoor = get_node("Door")
onready var skipPrompt = get_node("../../SkipPrompt")
var hideSkipPromptTimer = 0
var hideSkipPromptTimeLimit = 15

# @override
func setUpRoomInitializationOverride():
    pass

var was_playing = false
# @override
func _process(delta):
    global.has_started_game = false
    screenEffectsContainer.offset = Vector2(0, 0)
    viewportTexture.rect_position = Vector2(0, 0)
    var which_input_to_skip = "popup_menu"
    skipPrompt.bbcode_text = tr("UI.MainMenu.3") % global.getInputText(which_input_to_skip)

    if not was_playing:
        if videoPlayer.is_playing():
            was_playing = true
        return
    else:
        if not videoPlayer.is_playing():
            mainMenuDoor.goThroughDoor(true)
            return

    if (
        Input.is_action_just_pressed("ui_right") or
        Input.is_action_just_pressed("ui_left") or
        Input.is_action_just_pressed("ui_up") or
        Input.is_action_just_pressed("ui_down") or
        Input.is_action_just_pressed("jump_button") or
        Input.is_action_just_pressed("sub_action_button") or
        Input.is_action_just_pressed("alt_action_button") or
        Input.is_action_just_pressed("left_button") or
        Input.is_action_just_pressed("restart_key") or 
        Input.is_action_just_pressed("ui_right") or
        Input.is_action_just_pressed("open_map") or
        Input.is_action_just_pressed("ui_cancel") or
        Input.is_action_just_pressed("ui_cancel_controller") or
        Input.is_action_just_pressed("ui_start")
    ) and not Input.is_action_just_pressed(which_input_to_skip):
        skipPrompt.visible = true
        hideSkipPromptTimer = 0
    if not skipPrompt.visible:
        if Input.is_action_just_pressed(which_input_to_skip):
            skipPrompt.visible = true
            hideSkipPromptTimer = 0
    else:
        if Input.is_action_just_pressed(which_input_to_skip):
            was_playing = true
            videoPlayer.stop()
        else:
            hideSkipPromptTimer += (delta*11)
            if hideSkipPromptTimer >= hideSkipPromptTimeLimit:
                hideSkipPromptTimer = 0
                skipPrompt.visible = false

func tryToAddGameFrameBackground():
    pass