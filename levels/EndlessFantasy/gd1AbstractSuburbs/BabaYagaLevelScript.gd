extends "../../../scripts/levelScript.gd"

onready var door = get_node("Door")
onready var babaYagaBoss = get_node("BabaYagaBoss")
onready var dreamOfDemon = get_node("DreamOfDemon")

# @override
func setUpRoomInitializationOverride():
    if global.memory["baba_yaga_boss"] >= 2:
        babaYagaBoss.queue_free()
    else:
        yield(get_tree().create_timer(0.5), "timeout")
        summonSmokeClouds(door.global_transform.origin, 2, true, true)
        door.queue_free()

func _process(_delta):
    if global.memory["baba_yaga_boss"] >= 2:
        dreamOfDemon.visible = true
        dreamOfDemon.grav = 60
  
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
        musicPlayer.tryToPlay(musicPlayer.windPlayer)