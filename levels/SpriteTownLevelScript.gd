extends "../../scripts/levelScript.gd"

# @override
func overrideLevelRespawnEvent():
    pass
    # IFNDEF BroomAbortSound.gd
    if global.memory.has("broom"):
        var broom = get_node("Broom")
        broom.is_active = false
        broom.visible = false
        get_node("NPC").textBox.text_final = "oh cool! now we can clean together\n... well i don't have a broom..\n\nanyway, to sweep, just stand in front\nof a glitch and press [C]"

    # IFNDEF FishingRodAbortSound.gd
    if global.memory.has("fishingRod"):
        var fishingRod = get_node("FishingRod")
        fishingRod.is_active = false
        fishingRod.visible = false
        get_node("NPC").textBox.text_final = "oh cool! now we can\nfish together... well i\ndon't have a fishing rod\nanyway, to fish, just stand\nin front of some water and\npress [DOWN]\nyou can find different fish\nin different areas.... \nso i've heard"

    if player.glitch_form == global.GlitchForm.LADDER or player.glitch_form == global.GlitchForm.INVISIBLE \
       or global.memory.has("spellbookPage"):
        get_node("NPC3").textBox.text_final = "you're here now... \nenjoy your freedom."

    if global.memory.has("spellbookPage"):
        get_node("FrogWizardNPC").visible = true
