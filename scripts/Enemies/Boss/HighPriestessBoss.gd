extends Spatial

var weakEyeRes = preload("res://sceneObjects/Enemies/WeakEye.tscn")
var spawnGlitchEffectRes = preload("res://sceneObjects/SpawnGlitchEffect.tscn")
var glitchEnemyRes = preload("res://sceneObjects/Enemies/GlitchEnemy.tscn")
var fallenAngelRes = preload("res://sceneObjects/Enemies/FallenAngel.tscn")
var basicFrogEnemyRes = preload("res://sceneObjects/Enemies/BasicFrogEnemy.tscn")
var savePointRes = preload("res://sceneObjects/SavePoint.tscn")

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var mySprite = get_node("Sprite3D")
onready var staffSpawnPoint = get_node("StaffSpawnPoint")
onready var crystalsContainer = get_node("Crystals")
onready var crystal1 = get_node("Crystals/HighpriestessCrystal")
onready var crystal2 = get_node("Crystals/HighpriestessCrystal2")
onready var crystal3 = get_node("Crystals/HighpriestessCrystal3")
onready var crystal4 = get_node("Crystals/HighpriestessCrystal4")
onready var crystal5 = get_node("Crystals/HighpriestessCrystal5")
onready var attackSound = get_node("Sounds/AttackSound")
var crystalsArray = []

var big_spawn_timer = 0
var initial_big_spawn_timer = 100
var big_spawn_time_limit = 120
var num_spawns = 0
var num_spawn_limit = 3

var spawn_timer = 0
var spawn_time_limit = 2
var BULLET_SPEED = 15
var has_animated_attack = false
var MAX_NUM_HITS = 5

enum BossPhase {
    IDLE,
    CASTING,
    FROG_PLAGUE_READY,
    FROG_PLAGUE_SPAWNING,
    FROG_PLAGUE_WAITING,
    CRONE_CHASE,
    DEFEATED,
}
var boss_phase = BossPhase.CASTING

var original_pos = null
var target_pos = null

var landingArray = []
var fallenAngelSpawnPointArray = []
var saveSpawnPointArray = []
var frogArray = []
onready var laughSound = get_node("Sounds/LaughSound")
onready var spawnSound = get_node("Sounds/SpawnSound")
onready var spawnSavePointSound = get_node("Sounds/SpawnSavePointSound")
func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    original_pos = global_transform.origin
    randomizeTargetPos()

    var landings = get_tree().get_nodes_in_group("priestess_landing")
    for landing in landings:
        landing.visible = false
        landingArray.push_back(landing)

    var fallenAngelSpawnPoints = get_tree().get_nodes_in_group("fallen_angel_spawn_point")
    for fallenAngelSpawnPoint in fallenAngelSpawnPoints:
        fallenAngelSpawnPoint.visible = false
        fallenAngelSpawnPointArray.push_back(fallenAngelSpawnPoint)

    var saveSpawnPoints = get_tree().get_nodes_in_group("save_spawn_point")
    for saveSpawnPoint in saveSpawnPoints:
        saveSpawnPoint.visible = false
        saveSpawnPointArray.push_back(saveSpawnPoint)
    crystalsArray = [crystal3, crystal2, crystal5, crystal4, crystal1]
    staffSpawnPoint.visible = false

var num_hits = 0
func getHurt():
    mySprite.visible = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")
    num_spawns = 0
    big_spawn_timer = big_spawn_time_limit - ((big_spawn_time_limit - big_spawn_timer)/2.0)
    has_animated_attack = false
    landingArray.shuffle()
    fallenAngelSpawnPointArray.shuffle()

    for i in range(num_hits+1):
        if i < len(crystalsArray):
            crystalsArray[i].applyGlitchMaterial(i)
    num_hits += 1
    num_spawn_limit += 2
    if num_hits == MAX_NUM_HITS:
        yaBeatMe()

func killTheBullets():
    var glitchBullets = get_tree().get_nodes_in_group("enemies")
    for i in range(len(glitchBullets)):
        glitchBullets[i].get_node("..").getSmacked(global_transform.origin)

func yaBeatMe():
    killTheBullets()
    for i in range(len(crystalsArray)):
        crystalsArray[i].applyGlitchMaterial(i)
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.queue("defeatedStart")
    secretAniPlayer.queue("defeatedIdle")
    boss_phase = BossPhase.DEFEATED
    level.levelTiles.randomize_num = 999
    yield(get_tree().create_timer(1.0), "timeout")
    level.triggerCroneDefeatedDialog()
    var npcPlatforms = level.npcPlatformContainer.get_children()
    for i in range(len(npcPlatforms)):
        level.summonSmokeClouds(npcPlatforms[i].global_transform.origin, 2, true, true)
        npcPlatforms[i].queue_free()
        yield(get_tree().create_timer(0.5), "timeout")

func animationDefeatedEnd():
    boss_phase = BossPhase.FROG_PLAGUE_READY
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    level.is_really_defeated = true
    var smokeClouds = level.summonSmokeClouds(global_transform.origin, 3, true, true)
    for i in range(len(smokeClouds)):
        smokeClouds[i].scale *= 3


var am_i_hidden = false
var can_spawn_save_points = false
var has_spawned_save_points = false
var save_point_spawn_timer = 0
var save_point_spawn_time_limit = 20
var glitch_crystal_timer = 0
var glitch_crystal_time_limit = 5
func _process(delta):
    if global.pauseGame or am_i_hidden:
        return

    # rotate crystals
    var normalized_num_hits = num_hits if num_hits < 5 else 5
    crystalsContainer.rotation_degrees.y -= delta*(65 - normalized_num_hits*13)
    glitch_crystal_timer += (delta * 11)
    if glitch_crystal_timer >= glitch_crystal_time_limit:
        glitch_crystal_timer = 0
        crystalsContainer.rotation_degrees.y -= normalized_num_hits * 30
    # processSavePointSpawns(delta)

    if boss_phase == BossPhase.DEFEATED:
        pass
    elif boss_phase == BossPhase.FROG_PLAGUE_READY:
        if not secretAniPlayer.is_playing():
            mySprite.visible = false
            boss_phase = BossPhase.FROG_PLAGUE_SPAWNING
            spawn_timer = 0
            num_spawns = 0
            num_spawn_limit = 7
            laughSound.play()
    elif boss_phase == BossPhase.FROG_PLAGUE_SPAWNING:
        spawn_timer += (delta*11)
        if spawn_timer >= spawn_time_limit:
            spawn_timer = 0
            num_spawns += 1
            var frog = basicFrogEnemyRes.instance()
            # frog.is_infected = true
            frog.on_ground = true
            frog.behavior_jumping = true
            frog.behavior_walking = true
            if randi() % 2 == 0:
                frog.walk_direction.x = 1
            else:
                frog.walk_direction.x = -1
            # frog.is_fragile = true
            level.add_child(frog)
            frog.global_transform.origin = getRandomSpawnPosition(3)
            frogArray.push_back(weakref(frog))
            spawnSound.play()
            if num_spawns >= num_spawn_limit:
                num_spawns = 0
                spawn_timer = 0
                boss_phase = BossPhase.FROG_PLAGUE_WAITING
                big_spawn_timer = 20
                frogArray.shuffle()
    elif boss_phase == BossPhase.FROG_PLAGUE_WAITING:
        pass
        # var weak_enemies = level.get_tree().get_nodes_in_group("weak_enemies")
        # if weak_enemies.size() == 0:
        #     spawnWeakEye()
        #     landingArray.shuffle()
        #     fallenAngelSpawnPointArray.shuffle()
        # else:
        #     big_spawn_timer += (delta*11)
        #     if big_spawn_timer >= big_spawn_time_limit:
        #         big_spawn_timer = 20
        #         var firstInfectedIndex = 0
        #         for i in range(len(frogArray)):
        #             var frog = frogArray[i].get_ref()
        #             if frog != null and isFrogInfected(frog):
        #                 firstInfectedIndex = i
        #                 break
        #         var infectedFrog = frogArray[firstInfectedIndex]
        #         if infectedFrog.get_ref() != null:
        #             var weakEye = weakEyeRes.instance()
        #             infectedFrog.get_ref().add_child(weakEye)
        #             weakEye.global_transform.origin = infectedFrog.get_ref().global_transform.origin
        #             weakEye.global_transform.origin.y += 0.75
        #             weakEye.global_transform.origin.z += 0.5
        #         frogArray.shuffle()
    elif boss_phase == BossPhase.CASTING:
        if target_pos != null and not ((secretAniPlayer.assigned_animation == "gotHurt" or secretAniPlayer.assigned_animation == "windUpCast") and secretAniPlayer.is_playing()):
            moveAbout(delta)
        big_spawn_timer += (delta*11)
        if big_spawn_timer >= big_spawn_time_limit:
            if not has_animated_attack:
                secretAniPlayer.play("windUpCast")
                has_animated_attack = true
            spawn_timer += (delta*11)
            if spawn_timer >= spawn_time_limit:
                spawn_timer = 0
                # spawnAttack(num_spawns, false)
                # spawnFallenAngel(num_spawns, false)
                spawnGlitchBullet()
                num_spawns += 1
                if num_spawns == 2:
                    # spawnAttack(0, true)
                    # spawnFallenAngel(0, true)
                    pass
                if num_spawns >= num_spawn_limit or level.player.physics_state == level.player.PhysicsState.GLITCH_HURT:
                    if level.player.physics_state == level.player.PhysicsState.GLITCH_HURT:
                        killTheBullets()
                    spawnWeakEye()
                    num_spawns = 0
                    big_spawn_timer = 0
                    has_animated_attack = false
                    landingArray.shuffle()
                    fallenAngelSpawnPointArray.shuffle()

                    can_spawn_save_points = true
        else:
            spawn_timer = -spawn_time_limit
    elif boss_phase == BossPhase.IDLE:
        if target_pos != null and not (secretAniPlayer.assigned_animation == "gotHurt" and secretAniPlayer.is_playing()):
            moveAbout(delta)


    frogCleanup(delta)

var frog_cleanup_timer = 0
var frog_cleanup_time_limit = 3
func frogCleanup(delta):
    if len(frogArray) == 0 or \
       boss_phase == BossPhase.FROG_PLAGUE_READY or \
       boss_phase == BossPhase.FROG_PLAGUE_SPAWNING or \
       boss_phase == BossPhase.FROG_PLAGUE_WAITING:
        return

    frog_cleanup_timer += (delta*11)
    if frog_cleanup_timer >= frog_cleanup_time_limit:
        frog_cleanup_timer = 0
        var frogRef = frogArray.pop_back()
        if frogRef.get_ref() != null:
            frogRef.get_ref().queue_free()
            level.summonSmokeClouds(frogRef.get_ref().global_transform.origin, 1, false, true)

func isFrogInfected(frog):
    return frog.is_infected
    
func moveAbout(delta):
    var step = 1
    global_transform.origin = global_transform.origin + (target_pos - global_transform.origin) * (delta*step)
    
    if stepify(target_pos.x, 0.1) == stepify(global_transform.origin.x, 0.1) and \
       stepify(target_pos.y, 0.1) == stepify(global_transform.origin.y, 0.1):
        randomizeTargetPos()

    step = 2
    var crystal_target_pos_x = 0
    if mySprite.frame >= 2:
        crystal_target_pos_x = 1
    crystalsContainer.translation.x = crystalsContainer.translation.x + (crystal_target_pos_x - crystalsContainer.translation.x) * (delta*step)

func randomizeTargetPos():
    target_pos = Vector3(
        original_pos.x + rand_range(-5, 5),
        original_pos.y + rand_range(-3, 5),
        original_pos.z
    )

func spawnWeakEye():
    var weakEye = weakEyeRes.instance()
    weakEye.is_static_in_level = false
    level.add_child(weakEye)
    weakEye.global_transform.origin = landingArray[0].global_transform.origin if len(landingArray) > 0 else getRandomSpawnPosition()

# be a bit more deterministic... ideally, we would
# 1. spawn one on or very near the player
# 2. spawn a weak eye in one of 4 positions
# 3. spawn 3 other glitches in one of like ~8 positions depending on player position?
# 4. spawn 2 other glitches out of reach just for visual flair
func getRandomSpawnPosition(theMax = 10):
    var pos = global_transform.origin
    var randX = rand_range(-theMax, theMax)
    var randY = rand_range(-theMax, theMax)
    return Vector3(pos.x + randX, pos.y + randY, pos.z)

func spawnAttack(which_spawn, spawn_on_player):
    var newGlitchEnemy = glitchEnemyRes.instance()
    newGlitchEnemy.is_static_in_level = false
    newGlitchEnemy.visible = true
    newGlitchEnemy.grav = 0
    newGlitchEnemy.get_node("Sprite3D").frame_delay = 0.2
    newGlitchEnemy.behavior_evolve = true
    newGlitchEnemy.behavior_fizzle_out_after_evolve = true
    level.add_child(newGlitchEnemy)
    if spawn_on_player:
        newGlitchEnemy.global_transform.origin = getPlayer().global_transform.origin
    else:
        newGlitchEnemy.global_transform.origin = landingArray[which_spawn].global_transform.origin if which_spawn < len(landingArray) else getRandomSpawnPosition()
    var newGlitchMaterial = newGlitchEnemy.mySprite.get_material_override().duplicate()
    if newGlitchEnemy.mySprite.is_in_group("sprite"):
        newGlitchEnemy.mySprite.remove_from_group("sprite")
    if newGlitchMaterial is ShaderMaterial:
        newGlitchMaterial.set_shader_param("target_palette", global.weird_base_palette)
    newGlitchEnemy.mySprite.set_material_override(newGlitchMaterial)

    var newSpawnGlitchEffect = spawnGlitchEffectRes.instance()
    level.add_child(newSpawnGlitchEffect)
    newSpawnGlitchEffect.global_transform.origin = newGlitchEnemy.global_transform.origin

func spawnFallenAngel(which_spawn, spawn_above_player):
    var fallenAngel = fallenAngelRes.instance()
    fallenAngel.is_static_in_level = false
    fallenAngel.visible = true
    level.add_child(fallenAngel)
    if spawn_above_player:
        fallenAngel.global_transform.origin = getPlayer().global_transform.origin
        fallenAngel.global_transform.origin.y += 8
    else:
        fallenAngel.global_transform.origin = fallenAngelSpawnPointArray[which_spawn].global_transform.origin if which_spawn < len(fallenAngelSpawnPointArray) else getRandomSpawnPosition()
    if fallenAngel.global_transform.origin.y <= getPlayer().global_transform.origin.y + 2:
        fallenAngel.global_transform.origin.y = getPlayer().global_transform.origin.y + 5 + randi() % 3
    var newGlitchMaterial = fallenAngel.myOtherSprite.get_material_override().duplicate()
    fallenAngel.myOtherSprite.set_material_override(newGlitchMaterial)

    var newSpawnGlitchEffect = spawnGlitchEffectRes.instance()
    level.add_child(newSpawnGlitchEffect)
    newSpawnGlitchEffect.global_transform.origin = fallenAngel.global_transform.origin

func spawnGlitchBullet():
    attackSound.play()
    var bullet = glitchEnemyRes.instance()
    bullet.is_static_in_level = false
    bullet.visible = true
    bullet.behavior_directional_bullet = true

    var player_pos = level.player.global_transform.origin
    var staff_pos = staffSpawnPoint.global_transform.origin
    var bullet_direction_vector = Vector3(
        player_pos.x - staff_pos.x,
        player_pos.y - staff_pos.y,
        0
    ).normalized() * BULLET_SPEED
    bullet.bullet_direction_vector = bullet_direction_vector
    level.add_child(bullet)

    bullet.global_transform.origin = staff_pos

func processSavePointSpawns(delta):
    if can_spawn_save_points and not has_spawned_save_points:
        save_point_spawn_timer += (delta*11)
        if save_point_spawn_timer >= save_point_spawn_time_limit:
            save_point_spawn_timer = 0
            if level.altarSprite.visible:
                level.altarSprite.visible = false
                var newSavePoint = savePointRes.instance()
                level.add_child(newSavePoint)
                newSavePoint.global_transform.origin = level.altarSprite.global_transform.origin
                spawnSavePointSound.play()
            else:
                var saveSpawnPoint = null
                if len(saveSpawnPointArray) > 0:
                    saveSpawnPoint = saveSpawnPointArray.pop_front()
                if saveSpawnPoint != null:
                    var newSavePoint = savePointRes.instance()
                    level.add_child(newSavePoint)
                    newSavePoint.global_transform.origin = saveSpawnPoint.global_transform.origin
                    spawnSavePointSound.play()

                if len(saveSpawnPointArray) <= 0:
                    has_spawned_save_points = true


onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if player == null:
        player = level.player
    return player
