extends "../../../scripts/levelScript.gd"

onready var dungeonBeginningDoor = get_node("Door")

var epilepsy_fade_timer = 0
var EPILEPSY_SHOW_TIME_LIMIT = 80
var epilepsy_cover_opacity = 1
var autosave_fade_timer = 0
var AUTOSAVE_SHOW_TIME_LIMIT = 50
var autosave_cover_opacity = 1
enum MainMenuState {
    SHOWING_AUTOSAVE_WARNING,
    HIDING_AUTOSAVE_WARNING,
}
var mainMenuState = MainMenuState.SHOWING_AUTOSAVE_WARNING
onready var autosaveWarning = get_node("../../ViewportTexture/AutosaveWarning")
onready var autosaveWarningCoverup = get_node("../../ViewportTexture/AutosaveWarning/Coverup")
onready var autosaveWarningText = get_node("../../ViewportTexture/AutosaveWarning/Text")
var has_finished_initial_initialization = false

func setUpRoomInitializationOverride():
    mainMenuState = MainMenuState.SHOWING_AUTOSAVE_WARNING
    autosaveWarning.visible = true
    autosaveWarningText.bbcode_text = tr("UI.Autosave.Warning")
    has_finished_initial_initialization = true
    transition.colorRect.rect_position = Vector2(0, 0)
    transition.colorRect.rect_size = Vector2(1920, 1080)

var bye_bye = false
# @override
func _process(delta):
    if bye_bye:
        return
    screenEffectsContainer.offset = Vector2(0, 0)
    viewportTexture.rect_position = Vector2(0, 0)
    if mainMenuState == MainMenuState.SHOWING_AUTOSAVE_WARNING or \
       mainMenuState == MainMenuState.HIDING_AUTOSAVE_WARNING:
        autosaveWarning.visible = true
        if mainMenuState == MainMenuState.SHOWING_AUTOSAVE_WARNING:
            if not has_finished_initial_initialization:
                return
            autosave_cover_opacity -= (delta)
            if autosave_cover_opacity < 0:
                autosave_cover_opacity = 0
                # autosave_fade_timer += (delta*11)
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
                dungeonBeginningDoor.goThroughDoor(true)
                bye_bye = true
                return
        autosaveWarningCoverup.color = Color(0, 0, 0, autosave_cover_opacity)
        return

func saveTheGame(_message = "saving!!"):
    pass