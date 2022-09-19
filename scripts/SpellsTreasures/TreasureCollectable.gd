extends "../../scripts/NPC.gd"

onready var collectSound = get_node("CollectSound")

var being_collected = false
var gotcha = false

func _ready():
  if is_static_in_level and global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.name):
    queue_free()
    
  set_process(true)
  set_physics_process(true)
  is_active = true
  is_important = true
  is_really_important = true
  # ._ready() implicit
  
func _process(delta):
  delta = delta * global.time_dilation_multiplier 

  if not isActive():
    return
  
  if gotcha:
    .passiveActivate(delta) # let the NPC passiveActive super script handle the textbox
  elif being_collected:
    level.player.dir = Vector3(0, 0, 0)
    if level.player.on_ground:
      # TODO(jaketrower): kinda hacky...
      if level.player.aniPlayer.assigned_animation != "getItem":
        level.player.aniPlayer.play("getItem")
        if aniPlayer:
          aniPlayer.play("getItem")
          aniPlayer = null # very weird but it's to stop the GameMover from trying to play other animations...?
          textBox.focus_me = true
          # if there is an existing textBox already... hide it... fail safe:
          if global.activeInteractor != null:
            global.activeInteractor.hideTextbox()
          global.activeInteractor = textBox # also weird but this is to get the camera to look at me
      if level.player.aniPlayer.assigned_animation == "getItem":
        if level.player.aniPlayer.is_playing():
          self.global_transform.origin.x = level.player.global_transform.origin.x
          if level.player.mySprite.flip_h:
            self.global_transform.origin.x -= 0.96
          else:
            self.global_transform.origin.x += 0.96
          self.global_transform.origin.y = level.player.global_transform.origin.y + 1.08
          self.global_transform.origin.z = level.player.global_transform.origin.z + 1
        else:
          gotcha = true
          textBox.is_really_important = true
          textBox.is_important = true
          .passiveActivate(delta) # let the NPC passiveActive super script handle the textbox
          
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
    collectSound.play()
    visible = false
    global.pauseMoveInput = true
    being_collected = true
    
    if is_static_in_level:
      if not global.memory.has(level.getShortLevelName()):
        global.memory[level.getShortLevelName()] = {}
      global.memory[level.getShortLevelName()][self.name] = true
