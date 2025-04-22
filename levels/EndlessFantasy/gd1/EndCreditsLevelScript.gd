extends "../../../scripts/levelScript.gd"

onready var endCreditsLabel = get_node("EndCreditsLabel")
onready var quitPromptRect = get_node("../../ColorRect")
onready var quitPrompt = get_node("../../ColorRect/QuitPrompt")
var holdToQuitTimer = 0
var holdToQuitTimeLimit = 20
var hideHoldToQuitTimer = 0
var hideHoldToQuitTimeLimit = 20

# @override
func setUpRoomInitializationOverride():
    # endCreditsLabel.text = tr("EndCredits.FULL")
    if global.demo_mode <= 0: Steam.set_achievement("GRANDMA_WIN")

var STOP_POSITION = 415
# @override
func _process(delta):
    # var locale = TranslationServer.get_locale()
    if endCreditsLabel.global_transform.origin.y >= STOP_POSITION:
        endCreditsLabel.global_transform.origin.y = STOP_POSITION
    else:
        endCreditsLabel.global_transform.origin.y += (delta*2)
        if Input.is_action_pressed("popup_menu"):
            endCreditsLabel.global_transform.origin.y += (delta*40)

    if global.pauseGame:
        return
    quitPrompt.bbcode_text = "[right]" + tr("UI.EndCredits.QuitGame") %  global.getInputText("ui_start") + "[/right]"
    if not quitPromptRect.visible and (
        Input.is_action_just_pressed("restart_key") or 
        Input.is_action_just_pressed("open_map") or
        Input.is_action_just_pressed("ui_cancel") or
        Input.is_action_just_pressed("ui_cancel_controller") or
        Input.is_action_just_pressed("ui_start")
    ):
        quitPromptRect.visible = true
        holdToQuitTimer = 0
        hideHoldToQuitTimer = 0
    elif quitPromptRect.visible:
        if Input.is_action_just_pressed("ui_start"):
            global.pauseGame = true
            transition.colorRect.visible = true
            transition.reset_game("res://levels/EndlessFantasy/gd1/MainMenu.tscn")
            quitPromptRect.visible = false
        else:
            holdToQuitTimer = 0
            hideHoldToQuitTimer += (delta*11)
            if hideHoldToQuitTimer >= hideHoldToQuitTimeLimit:
                quitPromptRect.visible = false
                hideHoldToQuitTimer = 0