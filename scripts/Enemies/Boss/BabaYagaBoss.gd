extends Spatial

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var mySprite = get_node("SpriteContainer/Sprite3D")
onready var eyeSprite = get_node("SpriteContainer/EyeSprite3D")
onready var crystalsContainer = get_node("SpriteContainer/Crystals")
onready var crystal1 = get_node("SpriteContainer/Crystals/HighpriestessCrystal")
onready var runTrack = get_tree().get_root().get_node("Game/Viewport/level/RunTrack")
onready var spawnSound = get_node("Sounds/SpawnSound")
onready var wakeUpSound = get_node("Sounds/WakeUpSound")
var babaEggRes = preload("res://sceneObjects/Enemies/Boss/BabaYagaEgg.tscn")
var crowRes = preload("res://sceneObjects/Enemies/CrowWitch.tscn")
var glitchMusicNoteRes = preload("res://sceneObjects/Enemies/GlitchMusicNote.tscn")
onready var noteSpawner = get_node("SpriteContainer/Sprite3D/NoteSpawner")
onready var eyeSpawner = get_node("SpriteContainer/EyeSprite3D/EyeSpawner")
var weakEyeRes = preload("res://sceneObjects/Enemies/WeakEye.tscn")
var babaWitchRes = preload("res://sceneObjects/Enemies/Boss/BabaWitch.tscn")
var noteRefArray = []
var singing_counter = 0
var singing_count_max = 1

var MAX_NUM_HITS = 3

enum BossPhase {
    ASLEEP,
    WAKEUP
    IDLE,
    SINGING,
    RUN_AROUND,
    RUN_BACKWARDS,
    GOT_HURT,
    LAY_AN_EGG,
    DEFEATED,
    ABOUT_TO_CRASH,
}
var boss_phase = BossPhase.ASLEEP
var prev_boss_phase = BossPhase.ASLEEP
var boss_phase_should_crash = 0
var landingArray = []
var landingIndex = 0
onready var crowContainer = get_node("CrowContainer")
var crowArray = []
var crow_swoop_timer = 0
var crow_swoop_time_limit = 20
var eyeSporeSpawn_timer = 0
var eyeSporeSpawn_time_limit = 10

func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    
    var runTracks = runTrack.get_children()
    for landing in runTracks:
        landingArray.push_back(landing)

    if boss_phase == BossPhase.ASLEEP:
        babaYagaDoor.visible = true
    runTrack.visible = false

var num_hits = 0
func getHurt():
    am_i_hurt = true
    num_hits += 1
    if num_hits >= MAX_NUM_HITS:
        level.saveTheGame()
        
        secretAniPlayer.stop()
        secretAniPlayer.clear_queue()
        secretAniPlayer.play("dieMove")
        var temp_pos = crystal1.global_transform.origin
        crystalsContainer.remove_child(crystal1)
        level.add_child(crystal1)
        crystal1.global_transform.origin = temp_pos
        prev_boss_phase = boss_phase
        boss_phase = BossPhase.DEFEATED
        musicPlayer.stopAll()
        level.player.pauseInput = true
        global.pauseMoveInput = true
        global.pauseGame = true
        global.shouldRenderAsCinematic = true
        return
    if num_hits >= 2 and boss_phase_should_crash == 0:
        boss_phase_should_crash = 1
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")
    secretAniPlayer.queue("idle")
    # secretAniPlayer.queue("hibernate")
    prev_boss_phase = boss_phase
    boss_phase = BossPhase.GOT_HURT

var am_i_hurt = false
var kill_invis = false
var kill_immediately = false
func isActive():
    return not am_i_hurt

func notOuchies(_broom_origin = null):
    pass

func fallthroughCollisionActivate(possible_game_mover):
    if possible_game_mover == level.player:
        pass

func getSmacked(_broom_origin = null):
    pass
    

func _process(delta):
    # need to be before global.pauseGame check so we can unpause
    if boss_phase == BossPhase.ASLEEP:
        if level.player.transformation == level.player.TransformationState.CHICKEN or global.memory["baba_yaga_boss"] == 1:
            wakeMeUp()
    elif boss_phase == BossPhase.WAKEUP:
        tryToSpawnCrowStream(delta)
        if not secretAniPlayer.is_playing():
            prev_boss_phase = boss_phase
            boss_phase = BossPhase.SINGING
            singing_counter = 0
            secretAniPlayer.queue("idle")
            secretAniPlayer.queue("idleWalk")
            secretAniPlayer.queue("idleWalk")
            secretAniPlayer.queue("idle")
            secretAniPlayer.queue("flipLeftToRight")
            secretAniPlayer.queue("idle")
            secretAniPlayer.queue("idleWalk")
            secretAniPlayer.queue("idleWalk")
            secretAniPlayer.queue("idle")
            secretAniPlayer.queue("flipRightToLeft")
            # boss_phase = BossPhase.RUN_AROUND
            # secretAniPlayer.stop()
            # secretAniPlayer.clear_queue()
            # secretAniPlayer.play("run")
            run_counter = 0
            am_i_hurt = false
            global.pauseGame = false
            global.shouldRenderAsCinematic = false
            if global.memory["baba_yaga_boss"] == 0:
                global.memory["baba_yaga_boss"] = 1
                level.restartMusic()
                level.uiLayer.setDisplayTitle("house of Yaga")
        return
    elif boss_phase == BossPhase.DEFEATED:
        if not secretAniPlayer.is_playing():
            global.pauseGame = false
            global.shouldRenderAsCinematic = false
            level.restartMusic()
            global.memory["baba_yaga_boss"] = 2

    if global.pauseGame:
        return

    if boss_phase == BossPhase.IDLE:
        tryToSpawnCrowStream(delta)
        if secretAniPlayer.assigned_animation == "suddenlyBrake":
            run_speed = 0.5
            if prev_boss_phase == BossPhase.RUN_AROUND:
                processRunLogic(delta)
            elif prev_boss_phase == BossPhase.RUN_BACKWARDS:
                processRunBackwardsLogic(delta)

        if not secretAniPlayer.is_playing():
            run_counter = 0
            prev_boss_phase = boss_phase
            boss_phase = BossPhase.SINGING
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            singing_counter = 0
            secretAniPlayer.queue("idle")
            secretAniPlayer.queue("idleWalk")
            secretAniPlayer.queue("idleWalk")
            secretAniPlayer.queue("idle")
            secretAniPlayer.queue("flipLeftToRight")
            secretAniPlayer.queue("idle")
            secretAniPlayer.queue("idleWalk")
            secretAniPlayer.queue("idleWalk")
            secretAniPlayer.queue("idle")
            secretAniPlayer.queue("flipRightToLeft")
    elif boss_phase == BossPhase.SINGING:
        if not secretAniPlayer.is_playing():
            singing_counter += 1
            if singing_counter >= singing_count_max:
                spawnWeakEye()
                for noteRef in noteRefArray:
                    if noteRef != null and noteRef.get_ref():
                        noteRef.get_ref().behavior_walk_flip = false
                noteRefArray = []
                singing_counter = 0
                prev_boss_phase = boss_phase
                boss_phase = BossPhase.IDLE
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("idle")
            else:
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("idleWalk")
                secretAniPlayer.queue("idleWalk")
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("flipLeftToRight")
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("idleWalk")
                secretAniPlayer.queue("idleWalk")
                secretAniPlayer.queue("idle")
                secretAniPlayer.queue("flipRightToLeft")
    elif boss_phase == BossPhase.RUN_AROUND:
        tryPlayBawkSound()
        tryToSpawnCrowStream(delta)
        tryToSpawnEyeSpore(delta)
        if secretAniPlayer.assigned_animation == "run" or secretAniPlayer.assigned_animation == "suddenlyBrake":
            run_speed = -0.5 if secretAniPlayer.assigned_animation == "suddenlyBrake" else 3.0
            processRunLogic(delta)
        if run_counter >= RUN_COUNT_MAX and boss_phase_should_crash == 0:
            run_counter = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            wakeUpSound.play()
            secretAniPlayer.play("suddenlyBrake")
            secretAniPlayer.queue("flipLeftToRight")
            secretAniPlayer.queue("run")
            prev_boss_phase = boss_phase
            boss_phase = BossPhase.RUN_BACKWARDS
            landingIndex = 11
    elif boss_phase == BossPhase.RUN_BACKWARDS:
        tryPlayBawkSound()
        tryToSpawnCrowStream(delta)
        tryToSpawnEyeSpore(delta)
        if secretAniPlayer.assigned_animation == "run" or secretAniPlayer.assigned_animation == "suddenlyBrake":
            run_speed = -0.5 if secretAniPlayer.assigned_animation == "suddenlyBrake" else 3.0
            processRunBackwardsLogic(delta)
        if run_counter > RUN_COUNT_MAX:
            if num_hits >= 2:
                eyeSprite.visible = true
            run_counter = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            wakeUpSound.play()
            secretAniPlayer.play("suddenlyBrake")
            secretAniPlayer.queue("flipRightToLeft")
            secretAniPlayer.queue("idle")
            # secretAniPlayer.queue("idleWalk")
            # secretAniPlayer.queue("idleWalk")
            # secretAniPlayer.queue("idle")
            # secretAniPlayer.queue("flipLeftToRight")
            # secretAniPlayer.queue("idle")
            # secretAniPlayer.queue("idleWalk")
            # secretAniPlayer.queue("idleWalk")
            # secretAniPlayer.queue("idle")
            # secretAniPlayer.queue("flipRightToLeft")
            prev_boss_phase = boss_phase
            boss_phase = BossPhase.IDLE
    elif boss_phase == BossPhase.ABOUT_TO_CRASH:
        if secretAniPlayer.assigned_animation == "suddenlyBrake":
            run_speed = 3
            self.global_transform.origin.x -= run_speed * (delta*11)
            if self.global_transform.origin.x <= -12:
                self.global_transform.origin.x = -12
                secretAniPlayer.stop()
                secretAniPlayer.play("shellExplode")
        elif secretAniPlayer.assigned_animation == "shellExplode":
            run_speed = 0.1
            self.global_transform.origin.x += run_speed * (delta*11)
            if not secretAniPlayer.is_playing():
                boss_phase = BossPhase.RUN_AROUND
                secretAniPlayer.stop()
                secretAniPlayer.clear_queue()
                secretAniPlayer.play("run") 
                eyeSporeSpawn_timer = 0
    elif boss_phase == BossPhase.GOT_HURT:
        if not secretAniPlayer.is_playing():
            run_counter = 0
            boss_phase = BossPhase.RUN_AROUND
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("run")
            wakeUpSound.play()
    elif boss_phase == BossPhase.LAY_AN_EGG:
        if crowArray.size() > 0:
            crow_swoop_timer += (delta*11)
            if crow_swoop_timer >= crow_swoop_time_limit:
                crow_swoop_timer = 0
                var crowToSwoop = crowArray.pop_front()
                while crowToSwoop == null or crowToSwoop.get_ref() == null:
                    if crowArray.size() == 0:
                        boss_phase = BossPhase.WAKEUP
                        secretAniPlayer.stop()
                        secretAniPlayer.clear_queue()
                        secretAniPlayer.play("wakeup")
                        if num_hits >= 2:
                            eyeSprite.visible = false
                        return
                    crowToSwoop = crowArray.pop_front()
                crowToSwoop.get_ref().startSwoopAttack()
                crowArray.push_back(crowToSwoop)
        elif crowContainer.get_child_count() == 0:
            return
        else:
            crow_swoop_timer = 0
            for crow in crowContainer.get_children():
                crowArray.push_back(weakref(crow))

func getMushroomInfected(_shroom_pos, _ignore_ancestor = false):
    pass
   
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var player = null
func getPlayer():
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if player == null:
        player = level.player
    return player

onready var babaYagaDoor = get_node("Door")
func wakeMeUp():
    if boss_phase != BossPhase.ASLEEP:
        return

    if babaYagaDoor.visible:
        babaYagaDoor.visible = false
        level.summonSmokeClouds(babaYagaDoor.global_transform.origin, 2, true, true)
        musicPlayer.stopAll()
    boss_phase = BossPhase.WAKEUP
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("wakeup")
    global.pauseGame = true
    global.shouldRenderAsCinematic = true
    level.gameCamera.initial_size = 35
    level.gameCamera.zoomed_size = 35
    # crystal1.applyGlitchMaterial(5)

onready var tweetSound = get_node("Sounds/TweetSound")
func trySpawnAGlitchNote():
    if boss_phase == BossPhase.SINGING or boss_phase == BossPhase.WAKEUP:
        tweetSound.pitch_scale = rand_range(0.6, 0.8)
        tweetSound.play()
        var newNote = glitchMusicNoteRes.instance()
        if mySprite.rotation_degrees.y < 90:
            newNote.walk_direction.x = -1
        else:
            newNote.walk_direction.x = 1
        if num_hits >= 1:
            newNote.sine_velocity = 32
            newNote.rotation_degrees.z = 180
        level.add_child(newNote)
        newNote.global_transform.origin = noteSpawner.global_transform.origin
        newNote.global_transform.origin.z = 0
        noteRefArray.push_back(weakref(newNote))

func spawnWeakEye():
    var newEye = weakEyeRes.instance()
    level.add_child(newEye)
    newEye.global_transform.origin = eyeSpawner.global_transform.origin
    newEye.global_transform.origin.z = 0

func spawnBabaWitch():
    return
    # var newWitch = babaWitchRes.instance()
    # level.add_child(newWitch)
    # newWitch.global_transform.origin = mySprite.global_transform.origin
    # newWitch.global_transform.origin.z = 0
    # newWitch.laughSound.play()

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles

var run_counter = 0
var RUN_COUNT_MAX = 1
var run_speed = 3
func processRunLogic(delta):
    var currLanding = landingArray[landingIndex]
    self.rotation_degrees.z = currLanding.rotation_degrees.z
    if landingIndex == 0 or landingIndex == 5 or landingIndex == 6 or landingIndex == 11 or landingIndex == 12 or landingIndex == 13:
        self.global_transform.origin.y = currLanding.global_transform.origin.y
    if landingIndex == 2 or landingIndex == 3 or landingIndex == 8 or landingIndex == 9:
        self.global_transform.origin.x = currLanding.global_transform.origin.x

    var angle_mult = 0.72
    if landingIndex == 0:
        self.global_transform.origin.x -= run_speed * (delta*11)
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x:
            if boss_phase_should_crash == 1:
                boss_phase_should_crash = 2
                boss_phase = BossPhase.ABOUT_TO_CRASH
                wakeUpSound.play()
                secretAniPlayer.stop()
                secretAniPlayer.play("suddenlyBrake")
            else:
                landingIndex += 1
    elif landingIndex == 1:
        self.global_transform.origin.x -= run_speed * (delta*11) * angle_mult
        self.global_transform.origin.y += run_speed * (delta*11) * angle_mult
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x and self.global_transform.origin.y >= currLanding.global_transform.origin.y:
            landingIndex += 1
    elif landingIndex == 2 or landingIndex == 3:
        self.global_transform.origin.y += run_speed * (delta*11)
        if self.global_transform.origin.y >= currLanding.global_transform.origin.y:
            landingIndex += 1
    elif landingIndex == 4:
        self.global_transform.origin.x += run_speed * (delta*11) * angle_mult
        self.global_transform.origin.y += run_speed * (delta*11) * angle_mult
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x and self.global_transform.origin.y >= currLanding.global_transform.origin.y:
            landingIndex += 1
    elif landingIndex == 5:
        self.global_transform.origin.x += run_speed * (delta*11)
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x:
            landingIndex = 13
    elif landingIndex == 13:
        self.global_transform.origin.x += run_speed * (delta*11)
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x:
            landingIndex = 6
            # if num_hits >= 1:
            #     run_counter += 1
    elif landingIndex == 6:
        self.global_transform.origin.x += run_speed * (delta*11)
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x:
            landingIndex += 1
    elif landingIndex == 7:
        self.global_transform.origin.x += run_speed * (delta*11) * angle_mult
        self.global_transform.origin.y -= run_speed * (delta*11) * angle_mult
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x and self.global_transform.origin.y <= currLanding.global_transform.origin.y:
            landingIndex += 1
    elif landingIndex == 8 or landingIndex == 9:
        self.global_transform.origin.y -= run_speed * (delta*11)
        if self.global_transform.origin.y <= currLanding.global_transform.origin.y:
            landingIndex += 1
    elif landingIndex == 10:
        self.global_transform.origin.x -= run_speed * (delta*11) * angle_mult
        self.global_transform.origin.y -= run_speed * (delta*11) * angle_mult
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x and self.global_transform.origin.y <= currLanding.global_transform.origin.y:
            landingIndex += 1
    elif landingIndex == 11:
        self.global_transform.origin.x -= run_speed * (delta*11)
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x:
            landingIndex += 1
    elif landingIndex == 12:
        self.global_transform.origin.x -= run_speed * (delta*11)
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x:
            landingIndex = 0
            # if num_hits < 1:
            run_counter += 1

func processRunBackwardsLogic(delta):
    var currLanding = landingArray[landingIndex]
    self.rotation_degrees.z = currLanding.rotation_degrees.z
    if landingIndex == 0 or landingIndex == 5 or landingIndex == 6 or landingIndex == 11 or landingIndex == 12 or landingIndex == 13:
        self.global_transform.origin.y = currLanding.global_transform.origin.y
    if landingIndex == 2 or landingIndex == 3 or landingIndex == 8 or landingIndex == 9:
        self.global_transform.origin.x = currLanding.global_transform.origin.x

    var angle_mult = 0.72
    if landingIndex == 0:
        self.global_transform.origin.x += run_speed * (delta*11)
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x:
            landingIndex = 12
    elif landingIndex == 1:
        self.global_transform.origin.x += run_speed * (delta*11) * angle_mult
        self.global_transform.origin.y -= run_speed * (delta*11) * angle_mult
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x and self.global_transform.origin.y <= currLanding.global_transform.origin.y:
            landingIndex -= 1
    elif landingIndex == 2 or landingIndex == 3:
        self.global_transform.origin.y -= run_speed * (delta*11)
        if self.global_transform.origin.y <= currLanding.global_transform.origin.y:
            landingIndex -= 1
    elif landingIndex == 4:
        self.global_transform.origin.x -= run_speed * (delta*11) * angle_mult
        self.global_transform.origin.y -= run_speed * (delta*11) * angle_mult
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x and self.global_transform.origin.y <= currLanding.global_transform.origin.y:
            landingIndex -= 1
    elif landingIndex == 5:
        self.global_transform.origin.x -= run_speed * (delta*11)
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x:
            landingIndex -= 1
    elif landingIndex == 13:
        self.global_transform.origin.x -= run_speed * (delta*11)
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x:
            landingIndex = 5
            # if num_hits >= 1:
            run_counter = 999
    elif landingIndex == 6:
        self.global_transform.origin.x -= run_speed * (delta*11)
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x:
            landingIndex = 13
    elif landingIndex == 7:
        self.global_transform.origin.x -= run_speed * (delta*11) * angle_mult
        self.global_transform.origin.y += run_speed * (delta*11) * angle_mult
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x and self.global_transform.origin.y >= currLanding.global_transform.origin.y:
            landingIndex -= 1
    elif landingIndex == 8 or landingIndex == 9:
        self.global_transform.origin.y += run_speed * (delta*11)
        if self.global_transform.origin.y >= currLanding.global_transform.origin.y:
            landingIndex -= 1
    elif landingIndex == 10:
        self.global_transform.origin.x += run_speed * (delta*11) * angle_mult
        self.global_transform.origin.y += run_speed * (delta*11) * angle_mult
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x and self.global_transform.origin.y >= currLanding.global_transform.origin.y:
            landingIndex -= 1
    elif landingIndex == 11:
        self.global_transform.origin.x += run_speed * (delta*11)
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x:
            landingIndex -= 1
    elif landingIndex == 12:
        self.global_transform.origin.x += run_speed * (delta*11)
        if self.global_transform.origin.x >= currLanding.global_transform.origin.x:
            landingIndex -= 1
            # if num_hits < 1:
            # run_counter += 1

func stepInIdleDir():
    var step_dist = 1
    if round(mySprite.rotation_degrees.y) == 0.0:
        self.global_transform.origin.x -= step_dist
    elif round(mySprite.rotation_degrees.y) == 180.0:
        self.global_transform.origin.x += step_dist

func stopInIdleDir():
    pass

var eyeSporeRef = null
var eyeSporeRes = preload("res://sceneObjects/Enemies/Boss/BabaYagaMiniShroom.tscn")
func tryToSpawnEyeSpore(delta):
    if boss_phase_should_crash < 2:
        return

    if eyeSporeRef == null:
        eyeSporeSpawn_timer += (delta*11)
        if eyeSporeSpawn_timer >= eyeSporeSpawn_time_limit:
            eyeSporeSpawn_timer = 0
            var newEyeSpore = eyeSporeRes.instance()
            var randomPosition = landingArray[randi() % landingArray.size()]
            level.add_child(newEyeSpore)
            newEyeSpore.global_transform.origin = randomPosition.global_transform.origin
            newEyeSpore.rotation_degrees = randomPosition.rotation_degrees
            eyeSporeRef = weakref(newEyeSpore)
            
    else:
        if eyeSporeRef.get_ref() == null:
            eyeSporeRef = null
            eyeSporeSpawn_timer = 0

var crow_stream_spawn_timer = 0
var crow_stream_spawn_time_limit = 10
func tryToSpawnCrowStream(delta):
    return

    var CROW_SPEED = 10
    if num_hits >= 2:
        crow_stream_spawn_timer += (delta*11)
        if crow_stream_spawn_timer >= crow_stream_spawn_time_limit:
            crow_stream_spawn_timer = 0
            var crowSpawner = level.get_node("CrowSpawner")
            var newCrow = crowRes.instance()
            newCrow.behavior_directional_bullet = true
            newCrow.bullet_direction_vector = Vector3(CROW_SPEED, 0, 0)
            newCrow.behavior_phase_through_walls = true
            newCrow.crow_state = newCrow.CrowState.SWOOP_DIVE
            crowSpawner.add_child(newCrow)
            newCrow.global_transform.origin = crowSpawner.global_transform.origin
            newCrow.global_transform.origin.x += 1
            newCrow.secretAniPlayer.stop()
            newCrow.secretAniPlayer.clear_queue()
            newCrow.secretAniPlayer.play("flyAway")
            # newCrow.reenemize(true)
            newCrow.behavior_phase_through_walls = true

func tryPlayBawkSound():
    pass
    # if not wakeUpSound.is_playing():
    #     wakeUpSound.pitch_scale = rand_range(0.8, 1.2)
    #     wakeUpSound.play()