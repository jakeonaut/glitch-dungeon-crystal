extends Spatial

onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var mySprite = get_node("SpriteContainer/Sprite3D")
onready var crystalsContainer = get_node("SpriteContainer/Crystals")
onready var crystal1 = get_node("SpriteContainer/Crystals/HighpriestessCrystal")
onready var runTrack = get_tree().get_root().get_node("Game/Viewport/level/RunTrack")
onready var spawnSound = get_node("Sounds/SpawnSound")
var babaEggRes = preload("res://sceneObjects/Enemies/Boss/BabaYagaEgg.tscn")

var MAX_NUM_HITS = 3

enum BossPhase {
    ASLEEP,
    WAKEUP
    IDLE,
    RUN_AROUND,
    RUN_BACKWARDS,
    GOT_HURT,
    LAY_AN_EGG
}
var boss_phase = BossPhase.ASLEEP
var landingArray = []
var landingIndex = 0

func _ready():
    set_process(true)
    # Wait two frames cuz idk
    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    crystal1.applyGlitchMaterial(5)
    
    var runTracks = runTrack.get_children()
    for landing in runTracks:
        landingArray.push_back(landing)

var num_hits = 0
func getHurt():
    pass

var am_i_hurt = false
var kill_invis = false
var kill_immediately = false
func isActive():
    return not am_i_hurt

func notOuchies(_broom_origin = Vector3(0, 0, 0)):
    pass

func fallthroughCollisionActivate(possible_game_mover):
    if possible_game_mover == level.player:
        pass

func getSmacked(_broom_origin = Vector3(0, 0, 0)):
    am_i_hurt = true
    secretAniPlayer.stop()
    secretAniPlayer.clear_queue()
    secretAniPlayer.play("gotHurt")
    secretAniPlayer.queue("hibernate")
    boss_phase = BossPhase.GOT_HURT

func _process(delta):
    if global.pauseGame:
        return

    if boss_phase == BossPhase.ASLEEP:
        if Input.is_action_just_pressed("sub_action_button"):
            boss_phase = BossPhase.WAKEUP
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("wakeup")
    elif boss_phase == BossPhase.WAKEUP:
        if not secretAniPlayer.is_playing():
            run_counter = 0
            boss_phase = BossPhase.RUN_AROUND
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("run")
    elif boss_phase == BossPhase.IDLE:
        if not secretAniPlayer.is_playing():
            run_counter = 0
            boss_phase = BossPhase.RUN_AROUND
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("run")
    elif boss_phase == BossPhase.RUN_AROUND:
        if secretAniPlayer.assigned_animation == "run":
            processRunLogic(delta)
        if run_counter == RUN_COUNT_MAX:
            run_counter = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("flipLeftToRight")
            secretAniPlayer.queue("run")
            boss_phase = BossPhase.RUN_BACKWARDS
            landingIndex = 11
    elif boss_phase == BossPhase.RUN_BACKWARDS:
        if secretAniPlayer.assigned_animation == "run":
            processRunBackwardsLogic(delta)
        if run_counter > RUN_COUNT_MAX:
            run_counter = 0
            secretAniPlayer.stop()
            secretAniPlayer.clear_queue()
            secretAniPlayer.play("flipRightToLeft")
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
            boss_phase = BossPhase.IDLE
            landingIndex = 0
    elif boss_phase == BossPhase.GOT_HURT:
        if not secretAniPlayer.is_playing():
            boss_phase = BossPhase.LAY_AN_EGG
            var newEgg = babaEggRes.instance()
            level.add_child(newEgg)
            newEgg.global_transform.origin = Vector3(7, 6, 0)

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

var levelTiles = null
func getLevelTiles():
  if level == null:
    level = get_tree().get_root().get_node("Game/Viewport/level")
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles

var run_counter = 0
var RUN_COUNT_MAX = 1
func processRunLogic(delta):
    var currLanding = landingArray[landingIndex]
    self.rotation_degrees.z = currLanding.rotation_degrees.z
    if landingIndex == 0 or landingIndex == 5 or landingIndex == 6 or landingIndex == 11 or landingIndex == 12 or landingIndex == 13:
        self.global_transform.origin.y = currLanding.global_transform.origin.y
    if landingIndex == 2 or landingIndex == 3 or landingIndex == 8 or landingIndex == 9:
        self.global_transform.origin.x = currLanding.global_transform.origin.x

    var run_speed = 3
    var angle_mult = 0.72
    if landingIndex == 0:
        self.global_transform.origin.x -= run_speed * (delta*11)
        if self.global_transform.origin.x <= currLanding.global_transform.origin.x:
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
            run_counter += 1

func processRunBackwardsLogic(delta):
    var currLanding = landingArray[landingIndex]
    self.rotation_degrees.z = currLanding.rotation_degrees.z
    if landingIndex == 0 or landingIndex == 5 or landingIndex == 6 or landingIndex == 11 or landingIndex == 12 or landingIndex == 13:
        self.global_transform.origin.y = currLanding.global_transform.origin.y
    if landingIndex == 2 or landingIndex == 3 or landingIndex == 8 or landingIndex == 9:
        self.global_transform.origin.x = currLanding.global_transform.origin.x

    var run_speed = 3
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
            run_counter += 1

func stepInIdleDir():
    var step_dist = 1
    if round(mySprite.rotation_degrees.y) == 0.0:
        self.global_transform.origin.x -= step_dist
    elif round(mySprite.rotation_degrees.y) == 180.0:
        self.global_transform.origin.x += step_dist

func stopInIdleDir():
    pass
