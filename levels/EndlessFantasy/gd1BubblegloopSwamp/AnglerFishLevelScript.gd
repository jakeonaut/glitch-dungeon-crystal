extends "../../../scripts/levelScript.gd"

onready var door = get_node("Door")
onready var anglerFishBoss = get_node("AnglerFishBoss")

# @override
func setUpRoomInitializationOverride():
    if global.memory["angler_seaman_boss"] >= 2:
        anglerFishBoss.queue_free()
    else:
        yield(get_tree().create_timer(0.5), "timeout")
        summonSmokeClouds(door.global_transform.origin, 2, true, true)
        door.queue_free()
  
# @override
func playMenuMusic():
    musicPlayer.changeSongPitch(0.5)
    # musicPlayer.tryToPlay(musicPlayer.restZonePlayer)

# @override
func restartMusic():
    musicPlayer.changeSongPitch(1.0)
    if global.memory["angler_seaman_boss"] == 1:
        musicPlayer.tryToPlay(musicPlayer.bossThemePlayer)
    else:
        musicPlayer.tryToPlay(musicPlayer.crystalThemePlayer)