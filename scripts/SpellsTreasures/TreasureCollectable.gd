extends "../../scripts/NPC.gd"

onready var collectSound = get_node("CollectSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var abortSound = get_node("NPC TextBox/TextBox/AbortSound")

var being_collected = false # actually is_opened
var really_being_collected = false
var gotcha = false
var okay_im_done = false
var okay_im_really_done_bye = false
export var stop_all_music = true
export var display_textbox = true
export var canPause = true

func _ready():
  if is_static_in_level and self.getMyStaticLevelZoneVar():
    if secretAniPlayer.has_animation("isOpen"):
      secretAniPlayer.play("isOpen")
    is_active = false
    is_important = false
    is_really_important = false
    set_process(false)
    set_physics_process(false)
    okay_im_done = true
    okay_im_really_done_bye = true
    return
    
  set_process(true)
  set_physics_process(true)
  is_active = true
  is_important = true
  is_really_important = true
  # ._ready() implicit
  
func _process(delta):
  delta = delta * global.time_dilation_multiplier 

  # i love not using FSMs -_-
  if okay_im_really_done_bye:
    return

  if okay_im_done:
    # small key escape hatch
    if not display_textbox and \
       ((level.player.aniPlayer.assigned_animation == "getItem" and not level.player.aniPlayer.is_playing()) or \
       level.player.aniPlayer.assigned_animation != "getItem"):
      if abortSound.has_method("preActivateScript"):
        abortSound.preActivateScript()
      abortSound.activateScript()
      global.activeInteractor = null
      level.player.getItemFailsafe()
      okay_im_really_done_bye = true
    return

  if gotcha or being_collected or really_being_collected:
    if level.player.summonedBroom != null:
      level.player.broomStop()
    level.player.pauseAnimation = true
    level.player.pauseInput = true
    level.player.broomSpriteVisible.visible = false
    level.player.physics_state = PhysicsState.OCCUPIED
    level.player.dir = Vector3(0, 0, 0)
    level.player.hv = 0
    level.player.lv.x = 0
    level.player.linear_velocity.x = 0
  
  if gotcha:
    finishItAll()
  elif being_collected and not really_being_collected: 
    if not canPause:
      gotcha = true
    elif secretAniPlayer.current_animation != "openUp" and secretAniPlayer.current_animation != "idle": # and level.player.aniPlayer.current_animation != "preGetItem":
      really_being_collected = true
    # elif secretAniPlayer.current_animation != "openUp":
      # level.player.global_transform.origin = self.global_transform.origin
      # level.player.aniPlayer.play("preGetItem")
  elif really_being_collected:
    level.player.dir = Vector3(0, 0, 0)
    # if not level.player.on_ground:
    #   return
    # TODO(jaketrower): kinda hacky...
    if level.player.aniPlayer.assigned_animation == "getItem":
      if level.player.aniPlayer.is_playing():
        adjustSprite()
      else:
        gotcha = true
        if display_textbox:
          textBox.is_really_important = true
          textBox.is_important = true
          # collectSound.play()
          finishItAll()
    else:
      level.player.aniPlayer.play("getItem")
      adjustSprite()
      finishItAll()


func finishItAll():
  okay_im_done = true
  if display_textbox:
    if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
      global.activeInteractor.hideTextbox()
      global.pauseMoveInput = true
    textBox.interact()  
    if global.activeInteractor == null:
      if abortSound.has_method("preActivateScript"):
        abortSound.preActivateScript()
      abortSound.activateScript()
      level.player.getItemFailsafe()

func adjustSprite():
  textBox.can_camera_zoom = false
  mySprite.global_transform.origin.x = level.player.global_transform.origin.x
  if level.player.mySprite.flip_h:
    mySprite.global_transform.origin.x -= 0.96
  else:
    mySprite.global_transform.origin.x += 0.96
  mySprite.global_transform.origin.y = level.player.global_transform.origin.y + 1.08
  mySprite.global_transform.origin.z = level.player.global_transform.origin.z + 1
          
# @override
func alignMySprite():
  pass

# @override
func activate(is_player):
  passiveActivate(0, is_player)
  
# @override
func isActive():
  return is_active and visible and not okay_im_done and global.activeInteractor == null and \
         level.player.physics_state != PhysicsState.OCCUPIED and \
         level.player.physics_state != PhysicsState.COLLAPSED and \
         level.player.physics_state != PhysicsState.IGNORE_PHYSICS

# @override
func passiveActivate(_delta, _is_player):
  if okay_im_done:
    return
    
  if not being_collected:
    if stop_all_music:
      musicPlayer.playTreasureJingle(-20)
    #visible = false
    if secretAniPlayer:
      secretAniPlayer.clear_queue()
      secretAniPlayer.play("openUp")
      secretAniPlayer.queue("idle")
    if canPause:
      global.pauseGame = true
      global.pauseMoveInput = true
    being_collected = true
    
    if is_static_in_level:
      global.setStaticLevelZoneLevelVar(level, self.name, true)
    collectMe()

func collectMe():
  pass
