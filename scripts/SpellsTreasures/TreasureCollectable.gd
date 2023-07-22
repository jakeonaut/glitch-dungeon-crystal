extends "../../scripts/NPC.gd"

onready var collectSound = get_node("CollectSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")
onready var abortSound = get_node("NPC TextBox/TextBox/AbortSound")

var being_collected = false # actually is_opened
var really_being_collected = false
var gotcha = false
var okay_im_done = false
export var stop_all_music = true
export var display_textbox = true

func _ready():
  if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self.name):
    if secretAniPlayer.has_animation("isOpen"):
      secretAniPlayer.play("isOpen")
    is_active = false
    is_important = false
    is_really_important = false
    set_process(false)
    set_physics_process(false)
    okay_im_done = true
    return
    
  set_process(true)
  set_physics_process(true)
  is_active = true
  is_important = true
  is_really_important = true
  # ._ready() implicit
  
func _process(delta):
  delta = delta * global.time_dilation_multiplier 

  if okay_im_done:
    return

  if gotcha or being_collected or really_being_collected:
    level.player.broomSpriteVisible.visible = false
  
  if gotcha:
    if display_textbox:
      .passiveActivate(delta, true) # let the NPC passiveActive super script handle the textbox
    else:
      okay_im_done = true
      textBox.abortSound.activateScript()
  elif being_collected and not really_being_collected: 
    if secretAniPlayer.current_animation != "openUp" and secretAniPlayer.current_animation != "idle" and level.player.aniPlayer.current_animation != "preGetItem":
      really_being_collected = true
    elif secretAniPlayer.current_animation != "openUp":
      level.player.global_transform.origin = self.global_transform.origin
      level.player.aniPlayer.play("preGetItem")
      if display_textbox:
        global.activeInteractor = textBox # also weird but this is to get the camera to look at me
  elif really_being_collected:
    level.player.dir = Vector3(0, 0, 0)
    # if not level.player.on_ground:
    #   return
    # TODO(jaketrower): kinda hacky...
    if level.player.aniPlayer.assigned_animation == "getItem":
      if level.player.aniPlayer.is_playing():
        mySprite.global_transform.origin.x = level.player.global_transform.origin.x
        if level.player.mySprite.flip_h:
          mySprite.global_transform.origin.x -= 0.96
        else:
          mySprite.global_transform.origin.x += 0.96
        mySprite.global_transform.origin.y = level.player.global_transform.origin.y + 1.08
        mySprite.global_transform.origin.z = level.player.global_transform.origin.z + 1
      else:
        gotcha = true
        if display_textbox:
          textBox.is_really_important = true
          textBox.is_important = true
          # collectSound.play()
          .passiveActivate(delta, true) # let the NPC passiveActive super script handle the textbox
    else:
      level.player.aniPlayer.play("getItem")
      secretAniPlayer.play("getItem")
      if display_textbox:
        textBox.focus_me = true
        # if there is an existing textBox already... hide it... fail safe:
        if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
          global.activeInteractor.hideTextbox()
        global.activeInteractor = textBox # also weird but this is to get the camera to look at me
          
# @override
func alignMySprite():
  pass

# @override
func activate(_is_player):
  pass
  
# @override
func isActive():
  return is_active and visible

# @override
func passiveActivate(_delta, _is_player):
  if okay_im_done:
    return
    
  if not being_collected:
    if stop_all_music:
      musicPlayer.stopAll()
    #visible = false
    if secretAniPlayer:
      secretAniPlayer.clear_queue()
      secretAniPlayer.queue("openUp")
      secretAniPlayer.queue("idle")
    global.pauseMoveInput = true
    global.pauseGame = true
    being_collected = true
    
    if is_static_in_level:
      global.setStaticLevelZoneLevelVar(level, self.name, true)
    collectMe()

func collectMe():
  pass
