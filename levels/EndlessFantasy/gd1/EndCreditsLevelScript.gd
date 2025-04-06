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
    endCreditsLabel.text = tr("EndCredits.FULL")
    Steam.set_achievement("GRANDMA_WIN")

# @override
func _process(delta):
    var locale = TranslationServer.get_locale()
    var stopPosition = global.allLocales[locale].stopPosition
    if endCreditsLabel.global_transform.origin.y >= stopPosition:
        endCreditsLabel.global_transform.origin.y = stopPosition
    else:
        endCreditsLabel.global_transform.origin.y += (delta*2)
        if Input.is_action_pressed("popup_menu"):
            endCreditsLabel.global_transform.origin.y += (delta*40)

    quitPrompt.bbcode_text = "[right]" + tr("UI.EndCredits.QuitGame") %  global.getInputText("ui_start") + "[/right]"
    if Input.is_action_just_pressed("ui_start"):
        quitPromptRect.visible = true
        holdToQuitTimer = 0
        hideHoldToQuitTimer = 0
    elif quitPromptRect.visible:
        if Input.is_action_pressed("ui_start"):
            hideHoldToQuitTimer = 0
            holdToQuitTimer += (delta*11)
            if holdToQuitTimer >= holdToQuitTimeLimit:
                get_tree().quit()
        else:
            holdToQuitTimer = 0
            hideHoldToQuitTimer += (delta*11)
            if hideHoldToQuitTimer >= hideHoldToQuitTimeLimit:
                quitPromptRect.visible = false
                hideHoldToQuitTimer = 0