extends "../../../scripts/levelScript.gd"

onready var door = get_node("Door")
onready var anglerFishBoss = get_node("AnglerFishBoss")
onready var bigFishNPC = get_node("BigFishNPC")
onready var basicTadpoleEnemy1 = get_node("BasicTadpoleEnemy")
onready var basicTadpoleEnemy2 = get_node("BasicTadpoleEnemy2")
onready var basicTadpoleEnemy3 = get_node("BasicTadpoleEnemy3")
onready var basicTadpoleEnemy4 = get_node("BasicTadpoleEnemy4")
# onready var dreamOfDeceit = get_node("DreamOfDeceit")

# @override
func purifyAllWeakEnemies(summon_smoke_clouds = true):
    # kind of a weird little hacky thing, because we know the crystal will call this when purified...
    # that's why we love it :) 
    global.memory["angler_seaman_boss"] = 3
    .purifyAllWeakEnemies(summon_smoke_clouds)

# @override
func setUpRoomInitializationOverride():
    if global.memory["angler_seaman_boss"] >= 3:
        anglerFishBoss.queue_free()
    else:
        bigFishNPC.queue_free()
        basicTadpoleEnemy1.queue_free()
        basicTadpoleEnemy2.queue_free()
        basicTadpoleEnemy3.queue_free()
        basicTadpoleEnemy4.queue_free()
        if global.memory["angler_seaman_boss"] == 2:
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
