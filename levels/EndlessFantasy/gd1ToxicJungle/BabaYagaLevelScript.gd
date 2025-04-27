extends "../../../scripts/levelScript.gd"

onready var door = get_node("Door")
onready var shortcutDoor = get_node("ShortcutDoor")
onready var babaYagaBoss = get_node("BabaYagaBoss")
onready var eldestMonkeyNPC = get_node("EldestMonkeyNPC")

# @override
func setUpRoomInitializationOverride():
    if global.memory["baba_yaga_boss"] >= 3:
        babaYagaBoss.queue_free()
        shortcutDoor.visible = true
    else:
        eldestMonkeyNPC.queue_free()
        if global.memory["baba_yaga_boss"] == 2:
            babaYagaBoss.okayImDead()
            yield(get_tree().create_timer(0.5), "timeout")
            summonSmokeClouds(shortcutDoor.global_transform.origin, 2, true, true)
            shortcutDoor.visible = true
        else:
            yield(get_tree().create_timer(0.5), "timeout")
            summonSmokeClouds(door.global_transform.origin, 2, true, true)
            door.visible = false

# @override
func purifyAllWeakEnemies(summon_smoke_clouds = true):
    # kind of a weird little hacky thing, because we know the crystal will call this when purified...
    # that's why we love it :) 
    if global.memory["baba_yaga_boss"] <= 3:
        global.memory["baba_yaga_boss"] = 3
    .purifyAllWeakEnemies(summon_smoke_clouds)
    yield(get_tree().create_timer(0.5), "timeout")
    summonSmokeClouds(shortcutDoor.global_transform.origin, 2, true, true)
    shortcutDoor.visible = true

func _process(_delta):
    if global.memory["baba_yaga_boss"] >= 2:
        pass
  
# @override
func playMenuMusic():
    musicPlayer.changeSongPitch(0.5)
    # musicPlayer.tryToPlay(musicPlayer.restZonePlayer)

# @override
func restartMusic():
    musicPlayer.changeSongPitch(1.0)
    if global.memory["baba_yaga_boss"] == 1:
        musicPlayer.tryToPlay(musicPlayer.bossThemePlayer)
    else:
        musicPlayer.tryToPlay(musicPlayer.crystalThemePlayer)
