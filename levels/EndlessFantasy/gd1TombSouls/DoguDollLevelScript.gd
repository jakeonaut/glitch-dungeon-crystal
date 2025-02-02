extends "../../../scripts/levelScript.gd"

onready var door = get_node("Door")
onready var doguMatryoshkaBoss = get_node("ClaydolBoss")
onready var lostSoulsNPC = get_node("LostSoulsNPC")
# onready var dreamOfDeath = get_node("DreamOfDeath")

# @override
func setUpRoomInitializationOverride():
    if global.memory["dogu_matryoshka_boss"] >= 3:
        doguMatryoshkaBoss.queue_free()
    else:
        lostSoulsNPC.queue_free()
        if global.memory["dogu_matryoshka_boss"] == 2:
            doguMatryoshkaBoss.okayImDead()
        else:
            yield(get_tree().create_timer(0.5), "timeout")
            summonSmokeClouds(door.global_transform.origin, 2, true, true)
            door.visible = false

# @override
func purifyAllWeakEnemies(summon_smoke_clouds = true):
    # kind of a weird little hacky thing, because we know the crystal will call this when purified...
    # that's why we love it :) 
    if global.memory["dogu_matryoshka_boss"] <= 3:
        global.memory["dogu_matryoshka_boss"] = 3
    .purifyAllWeakEnemies(summon_smoke_clouds)

func _process(_delta):
    # if global.memory["dogu_matryoshka_boss"] >= 2:
    #     dreamOfDeath.visible = true
    #     dreamOfDeath.grav = 60
    pass
  
# @override
func playMenuMusic():
    musicPlayer.changeSongPitch(0.5)
    # musicPlayer.tryToPlay(musicPlayer.restZonePlayer)

# @override
func restartMusic():
    musicPlayer.changeSongPitch(1.0)
    if global.memory["dogu_matryoshka_boss"] == 0:
        musicPlayer.tryToPlay(musicPlayer.crystalThemePlayer)
    elif global.memory["dogu_matryoshka_boss"] == 1:
        musicPlayer.tryToPlay(musicPlayer.bossThemePlayer)
    else:
        musicPlayer.tryToPlay(musicPlayer.crystalThemePlayer)