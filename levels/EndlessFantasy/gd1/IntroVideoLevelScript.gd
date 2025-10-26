extends "../../../scripts/levelScript.gd"

onready var videoPlayer = get_node("../../Viewport2/VideoPlayer")
onready var mainMenuDoor = get_node("Door")
onready var skipPrompt = get_node("../../SkipPrompt")
var hideSkipPromptTimer = 0
var hideSkipPromptTimeLimit = 15

var epilepsy_fade_timer = 0
var EPILEPSY_SHOW_TIME_LIMIT = 80
var epilepsy_cover_opacity = 1
var autosave_fade_timer = 0
var AUTOSAVE_SHOW_TIME_LIMIT = 50
var autosave_cover_opacity = 1
enum MainMenuState {
    SHOWING_EPILEPSY_WARNING,
    HIDING_EPILEPSY_WARNING,
    SHOWING_AUTOSAVE_WARNING,
    HIDING_AUTOSAVE_WARNING,
    INTRO_VIDEO
}
var mainMenuState = MainMenuState.SHOWING_EPILEPSY_WARNING
onready var epilepsyWarning = get_node("../../Viewport2/UILayer/EpilepsyWarning")
onready var epilepsyWarningCoverup = get_node("../../Viewport2/UILayer/EpilepsyWarning/Coverup")
onready var epilepsyWarningText = get_node("../../Viewport2/UILayer/EpilepsyWarning/Text")
onready var autosaveWarning = get_node("../../Viewport2/UILayer/AutosaveWarning")
onready var autosaveWarningCoverup = get_node("../../Viewport2/UILayer/AutosaveWarning/Coverup")
onready var autosaveWarningText = get_node("../../Viewport2/UILayer/AutosaveWarning/Text")
var has_finished_initial_initialization = false

func setUpRoomInitializationOverride():
    mainMenuState = MainMenuState.SHOWING_EPILEPSY_WARNING
    epilepsyWarning.visible = true
    epilepsyWarningText.bbcode_text = tr("UI.Photosensitivity.Warning")
    autosaveWarningText.bbcode_text = tr("UI.Autosave.Warning")
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
        epilepsyWarning.visible = true
        autosaveWarning.visible = false
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
                mainMenuState = MainMenuState.SHOWING_AUTOSAVE_WARNING
        epilepsyWarningCoverup.color = Color(0, 0, 0, epilepsy_cover_opacity)
        return
    elif mainMenuState == MainMenuState.SHOWING_AUTOSAVE_WARNING or \
       mainMenuState == MainMenuState.HIDING_AUTOSAVE_WARNING:
        epilepsyWarning.visible = false
        autosaveWarning.visible = true
        if mainMenuState == MainMenuState.SHOWING_AUTOSAVE_WARNING:
            if not has_finished_initial_initialization:
                return
            autosave_cover_opacity -= (delta)
            if autosave_cover_opacity < 0:
                autosave_cover_opacity = 0
                autosave_fade_timer += (delta*11)
                if autosave_fade_timer >= AUTOSAVE_SHOW_TIME_LIMIT or (
                    Input.is_action_just_pressed("sub_action_button") or \
                    Input.is_action_just_pressed("jump_button") or \
                    Input.is_action_just_pressed("ui_start") or \
                    (Input.is_action_just_pressed("popup_menu") and not Input.is_action_pressed("toggle_fullscreen"))
                ):
                    mainMenuState = MainMenuState.HIDING_AUTOSAVE_WARNING
                    transition.aniPlayer.stop()
                    transition.aniPlayer.play("long_fade_no_change")
        elif mainMenuState == MainMenuState.HIDING_AUTOSAVE_WARNING:
            autosave_cover_opacity += (delta)
            if autosave_cover_opacity >= 1:
                autosave_cover_opacity = 1
                transition.reverse_fade()
                autosaveWarning.visible = false
                mainMenuState = MainMenuState.INTRO_VIDEO
                videoPlayer.play()
        autosaveWarningCoverup.color = Color(0, 0, 0, autosave_cover_opacity)
        return

    else:
        epilepsyWarning.visible = false
        autosaveWarning.visible = false
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
        ) and not Input.is_action_just_pressed(which_input_to_skip) and not Input.is_action_just_pressed("toggle_fullscreen"):
            skipPrompt.visible = true
            hideSkipPromptTimer = 0
        if not skipPrompt.visible:
            if Input.is_action_just_pressed(which_input_to_skip) and not Input.is_action_just_pressed("toggle_fullscreen"):
                skipPrompt.visible = true
                hideSkipPromptTimer = 0
        else:
            if Input.is_action_just_pressed(which_input_to_skip) and not Input.is_action_just_pressed("toggle_fullscreen"):
                was_playing = true
                videoPlayer.stop()
            else:
                hideSkipPromptTimer += (delta*11)
                if hideSkipPromptTimer >= hideSkipPromptTimeLimit:
                    hideSkipPromptTimer = 0
                    skipPrompt.visible = false