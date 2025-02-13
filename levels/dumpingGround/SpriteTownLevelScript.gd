extends "res://scripts/levelScript.gd"

var doorRes = preload("res://sceneObjects/Door.tscn")

# @override
func setUpRoomInitializationOverride():
    # IFNDEF BroomAbortSound.gd
    if global.memory.has("broom"):
        var broom = get_node("Broom")
        broom.is_active = false
        broom.visible = false

    # IFNDEF FishingRodAbortSound.gd
    # if global.memory.has("fishingRod"):
    #     var fishingRod = get_node("FishingRod")
    #     fishingRod.is_active = false
    #     fishingRod.visible = false

    # if player.glitch_form == global.GlitchForm.LADDER or player.glitch_form == global.GlitchForm.INVISIBLE \
    #    or global.memory.has("spellbookPage"):

    if global.memory.has("spellbookPage"):
        get_node("FrogWizardNPC").visible = true
