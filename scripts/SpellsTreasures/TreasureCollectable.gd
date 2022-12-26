extends "../../scripts/NPC.gd"

onready var collectSound = get_node("CollectSound")
onready var secretAniPlayer = get_node("SecretAnimationPlayer")

var being_collected = false # actually is_opened
var really_being_collected = false
var gotcha = false

func _ready():
  if is_static_in_level and global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.name):
    secretAniPlayer.play("isOpen")
    is_active = false
    is_important = false
    is_really_important = false
    set_process(false)
    set_physics_process(false)
    return
    
  set_process(true)
  set_physics_process(true)
  is_active = true
  is_important = true
  is_really_important = true
  # ._ready() implicit
  
func _process(delta):
  delta = delta * global.time_dilation_multiplier 

  if gotcha or being_collected or really_being_collected:
    level.player.broomSpriteVisible.visible = false
  
  if gotcha:
    .passiveActivate(delta) # let the NPC passiveActive super script handle the textbox
  elif really_being_collected:
    level.player.dir = Vector3(0, 0, 0)
    if not level.player.on_ground:
      return
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
        textBox.is_really_important = true
        textBox.is_important = true
        .passiveActivate(delta) # let the NPC passiveActive super script handle the textbox
    else:
      level.player.aniPlayer.play("getItem")
      secretAniPlayer.play("getItem")
      textBox.focus_me = true
      # if there is an existing textBox already... hide it... fail safe:
      if global.activeInteractor != null:
        global.activeInteractor.hideTextbox()
      global.activeInteractor = textBox # also weird but this is to get the camera to look at me
          
# @override
func alignMySprite():
  pass

# @override
func activate():
  pass
  
# @override
func isActive():
  return is_active and visible

# @override
func passiveActivate(_delta):
  if not isActive():
    return
    
  if not being_collected:
    musicPlayer.stopAll()
    #collectSound.play()
    #visible = false
    secretAniPlayer.clear_queue()
    secretAniPlayer.queue("openUp")
    secretAniPlayer.queue("idle")
    global.pauseMoveInput = true
    being_collected = true
    
    if is_static_in_level:
      if not global.memory.has(level.getShortLevelName()):
        global.memory[level.getShortLevelName()] = {}
      global.memory[level.getShortLevelName()][self.name] = true
    collectMe()
  elif being_collected and not really_being_collected: 
    if secretAniPlayer.current_animation != "openUp" and secretAniPlayer.current_animation != "idle" and level.player.aniPlayer.current_animation != "preGetItem":
      really_being_collected = true
    elif secretAniPlayer.current_animation != "openUp":
      level.player.aniPlayer.play("preGetItem")
      global.activeInteractor = textBox # also weird but this is to get the camera to look at me

func collectMe():
  pass
