extends "res://scripts/levelScript.gd"

var doorRes = preload("res://sceneObjects/Door.tscn")

# @override
func setUpRoomInitializationOverride():
    # IFNDEF BroomAbortSound.gd
    if global.memory.has("broom"):
        var broom = get_node("Broom")
        broom.is_active = false
        broom.visible = false
        get_node("NPC").textBox.text_final = "•you found the broom! now you\ncan help me clean my house...\n•i have a great reward buried somewhere under the dust!\nplease, come in."

    # IFNDEF FishingRodAbortSound.gd
    # if global.memory.has("fishingRod"):
    #     var fishingRod = get_node("FishingRod")
    #     fishingRod.is_active = false
    #     fishingRod.visible = false
    #     get_node("NPC").textBox.text_final = "•oh cool! now we can\nfish together... well i\ndon't have a fishing rod\nanyway, to fish, just stand\nin front of some water and\npress [DOWN]\nyou can find different fish\nin different areas.... \nso i've heard"

    # if player.glitch_form == global.GlitchForm.LADDER or player.glitch_form == global.GlitchForm.INVISIBLE \
    #    or global.memory.has("spellbookPage"):
    #     get_node("NPC3").textBox.text_final = "•you're here now... \nenjoy your freedom."

    if global.memory.has("spellbookPage"):
        get_node("FrogWizardNPC").visible = true
