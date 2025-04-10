extends "../../../scripts/levelScript.gd"

onready var videoPlayer = get_node("../../Viewport2/VideoPlayer")
onready var mainMenuDoor = get_node("Door")
onready var skipPrompt = get_node("../../SkipPrompt")
var hideSkipPromptTimer = 0
var hideSkipPromptTimeLimit = 15

var epilepsy_fade_timer = 0
var EPILEPSY_SHOW_TIME_LIMIT = 80
var epilepsy_cover_opacity = 1
enum MainMenuState {
    SHOWING_EPILEPSY_WARNING,
    HIDING_EPILEPSY_WARNING,
    INTRO_VIDEO
}
var mainMenuState = MainMenuState.SHOWING_EPILEPSY_WARNING
onready var epilepsyWarning = get_node("../../UILayer/EpilepsyWarning")
onready var epilepsyWarningCoverup = get_node("../../UILayer/EpilepsyWarning/Coverup")
onready var epilepsyWarningSprite = get_node("../../UILayer/EpilepsyWarning/Sprite")
onready var epilepsyWarningText = get_node("../../UILayer/EpilepsyWarning/Text")
var has_finished_initial_initialization = false

func setUpRoomInitializationOverride():
    mainMenuState = MainMenuState.SHOWING_EPILEPSY_WARNING
    epilepsyWarning.visible = true
    epilepsyWarningText.bbcode_text = tr("UI.Photosensitivity.Warning")
    has_finished_initial_initialization = true
    transition.colorRect.rect_position = Vector2(0, 0)
    transition.colorRect.rect_size = Vector2(1920, 1080)

var was_playing = false
# @override
func _process(delta):
    global.has_started_game = false
    screenEffectsContainer.offset = Vector2(0, 0)
    viewportTexture.rect_position = Vector2(0, 0)

    if mainMenuState == MainMenuState.SHOWING_EPILEPSY_WARNING or \
       mainMenuState == MainMenuState.HIDING_EPILEPSY_WARNING:
        if mainMenuState == MainMenuState.SHOWING_EPILEPSY_WARNING:
            if not has_finished_initial_initialization:
                return
            epilepsy_cover_opacity -= (delta)
            if epilepsy_cover_opacity < 0:
                epilepsy_cover_opacity = 0
                epilepsy_fade_timer += (delta*11)
                if epilepsy_fade_timer >= EPILEPSY_SHOW_TIME_LIMIT or (
                    Input.is_action_just_pressed("sub_action_button") or \
                    Input.is_action_just_pressed("jump_button") or \
                    Input.is_action_just_pressed("ui_start") or \
                    (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen"))
                ):
                    mainMenuState = MainMenuState.HIDING_EPILEPSY_WARNING
                    transition.aniPlayer.stop()
                    transition.aniPlayer.play("long_fade_no_change")
        elif mainMenuState == MainMenuState.HIDING_EPILEPSY_WARNING:
            epilepsy_cover_opacity += (delta)
            if epilepsy_cover_opacity >= 1:
                epilepsy_cover_opacity = 1
                transition.reverse_fade()
                epilepsyWarning.visible = false
                mainMenuState = MainMenuState.INTRO_VIDEO
                videoPlayer.play()
        epilepsyWarningCoverup.color = Color(0, 0, 0, epilepsy_cover_opacity)
        return

    else:
        epilepsyWarning.visible = false
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