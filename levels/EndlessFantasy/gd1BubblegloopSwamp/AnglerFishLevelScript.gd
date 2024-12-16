extends "../../../scripts/levelScript.gd"

onready var door = get_node("Door")
onready var anglerFishBoss = get_node("AnglerFishBoss")
# onready var dreamOfDeceit = get_node("DreamOfDeceit")

# @override
func setUpRoomInitializationOverride():
    if global.memory["angler_seaman_boss"] >= 2:
        anglerFishBoss.okayImDead()
    else:
        yield(get_tree().create_timer(0.5), "timeout")
        summonSmokeClouds(door.global_transform.origin, 2, true, true)
        door.visible = false

func _process(_delta):
    pass
    # if global.memory["angler_seaman_boss"] >= 2:
    #     dreamOfDeceit.visible = true
    #     dreamOfDeceit.grav = 60

  
# @override
func playMenuMusic():
    musicPlayer.changeSongPitch(0.5)
    # musicPlayer.tryToPlay(musicPlayer.restZonePlayer)

# @override
func restartMusic():
    musicPlayer.changeSongPitch(1.0)
    if global.memory["angler_seaman_boss"] == 0:
        musicPlayer.tryToPlay(musicPlayer.crystalThemePlayer)
    elif global.memory["angler_seaman_boss"] == 1:
        musicPlayer.tryToPlay(musicPlayer.bossThemePlayer)
    else:
        musicPlayer.tryToPlay(musicPlayer.crystalThemePlayer)
