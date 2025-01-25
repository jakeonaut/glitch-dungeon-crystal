extends "../../../scripts/levelScript.gd"

onready var door = get_node("Door")
onready var babaYagaBoss = get_node("BabaYagaBoss")

# @override
func purifyAllWeakEnemies(summon_smoke_clouds = true):
    # kind of a weird little hacky thing, because we know the crystal will call this when purified...
    # that's why we love it :) 
    global.memory["baba_yaga_boss"] = 3
    .purifyAllWeakEnemies(summon_smoke_clouds)

# @override
func setUpRoomInitializationOverride():
    if global.memory["baba_yaga_boss"] >= 2:
        babaYagaBoss.okayImDead()
    else:
        yield(get_tree().create_timer(0.5), "timeout")
        summonSmokeClouds(door.global_transform.origin, 2, true, true)
        door.visible = false

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
