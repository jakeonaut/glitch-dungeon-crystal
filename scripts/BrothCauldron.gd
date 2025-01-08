extends Spatial

# String is a path to a file.
export(String, FILE) var path

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var aniPlayer = get_node("AnimationPlayer")
onready var mySprite = get_node("Sprite3D")
onready var mySprite2 = get_node("Sprite3D2")
onready var swallowSound = get_node("SwallowSound")
onready var spitSound = get_node("SpitSound")
onready var spitSound2 = get_node("SpitSound2")
onready var warpSound = get_node("WarpSound")
onready var smackSound = get_node("SmackSound")
var smokeFumeRes = preload("res://sceneObjects/SmokeFume.tscn")
var smoke_fume_timer = 0
var smoke_fume_time_limit = 15
export var is_active = false
var has_popped_out = false
var spit_out_timer = 0
var spit_out_time_limit = 5

func _ready():
  set_process(true)
  mySprite.material_override = mySprite.material_override.duplicate()
  mySprite2.material_override = mySprite2.material_override.duplicate()

func _process(delta):
  is_active = global.haveIBeenToThisLevelPath(path)

  if is_active and not aniPlayer.assigned_animation == "active":
    aniPlayer.play("active")
    smoke_fume_time_limit = 5

  if is_smacked:
    smack_timer += (delta * 22)
    if smack_timer >= smack_time_limit:
        unsmack()

  smoke_fume_timer += (delta*11)
  if smoke_fume_timer >= smoke_fume_time_limit:
    smoke_fume_timer = 0
    var newSmokeFume = smokeFumeRes.instance()
    newSmokeFume.fade_out_opacity = true
    level.add_child(newSmokeFume)
    newSmokeFume.global_transform.origin = self.global_transform.origin
    newSmokeFume.global_transform.origin.y += 1.5
    newSmokeFume.global_transform.origin.x += rand_range(-1.0, 1.0)
    newSmokeFume.target_y = newSmokeFume.global_transform.origin.y + rand_range(2.0, 3.0)
    if is_active:
      newSmokeFume.material_override.set_shader_param("target_palette", global.red_palette)
      # newSmokeFume.material_override.set_shader_param("offset", 8)

  if global.pauseGame:
    return
  var speed = 10
  if who_did_i_get != null and who_did_i_get.get_ref() != null:
    var target = who_did_i_get.get_ref()
    if maybe_friend_refs.has(target.name):
      maybe_friend_refs.erase(target.name)

    if target.global_transform.origin.x < self.global_transform.origin.x:
      target.global_transform.origin.x += (delta*speed)
      if target.global_transform.origin.x > self.global_transform.origin.x:
        target.global_transform.origin.x = self.global_transform.origin.x
    if target.global_transform.origin.x > self.global_transform.origin.x:
      target.global_transform.origin.x -= (delta*speed)
      if target.global_transform.origin.x < self.global_transform.origin.x:
        target.global_transform.origin.x = self.global_transform.origin.x

    if target.global_transform.origin.y > self.global_transform.origin.y:
      target.global_transform.origin.y -= (delta*speed)
      target.spriteContainer.scale -= Vector3(delta, delta, delta)
      if target.global_transform.origin.y <= self.global_transform.origin.y:
        target.visible = false
        target.global_transform.origin.y = self.global_transform.origin.y
    else:
      if is_active:
        level.player.glitch_death_timer = 10
        level.glitchScreenEffect.visible = global.userSettings["canGlitchScreen"]
        warpSound.play()
        global.prepareForTransition(level)
        global.isBrothWarping = true
        transition.granny_teleport_to(self.path)
        pass # transfer to partner pot via Door transition
      else:
        spit_out_timer += (delta*11)
        if spit_out_timer >= spit_out_time_limit:
          spit_out_timer = 0
          spitSound.play()
          spitSound2.play()
          target.visible = true
          target.tumbleFall(Vector2(0, 1), true)
          target.global_transform.origin.x = self.global_transform.origin.x
          target.global_transform.origin.y += 1.0
          target.spriteContainer.global_transform.origin.z = 0.0
          target.spriteContainer.scale = Vector3(1.0, 1.0, 1.0)
          who_did_i_get = null
          has_popped_out = true

    if target.physics_state == target.PhysicsState.GLITCH_DYING:
      target.spriteContainer.global_transform.origin.z = 0.0
      target.spriteContainer.scale = Vector3(1.0, 1.0, 1.0)
      target.visible = true
      who_did_i_get = null
      has_popped_out = false
  elif has_popped_out:
    if level.player.on_ground and not maybe_friend_refs.has(level.player.name):
      has_popped_out = false

func unsmack():
    is_smacked = false
    mySprite.material_override.set_shader_param("time_influence", 3)
    mySprite.material_override.set_shader_param("y_div", 2.3)
    mySprite.material_override.set_shader_param("normal_offset", .02)

    mySprite2.material_override.set_shader_param("time_influence", 3)
    mySprite2.material_override.set_shader_param("y_div", 2.3)
    mySprite2.material_override.set_shader_param("normal_offset", .02)
        
var who_did_i_get = null
var maybe_friend_refs = {}
func fallthroughCollisionActivate(friend):
  if not friend.on_ground:
    return # just landed
  if friend != level.player:
    return
  if who_did_i_get != null or maybe_friend_refs.has(friend.name):
    return
  maybe_friend_refs[friend.name] = [true]
  if has_popped_out:
    return

  # var buffer = 0.2
  # var x = self.global_transform.origin.x
  # var friendX = friend.global_transform.origin.x
  # if friendX > x + buffer or friendX < x - buffer:
  #   return
  who_did_i_get = weakref(friend)
  friend.physics_state = friend.PhysicsState.IGNORE_PHYSICS
  friend.spriteContainer.global_transform.origin.z = -1.0
  friend.aniPlayer.stop()
  friend.aniPlayer.clear_queue()
  friend.aniPlayer.play("fall")
  swallowSound.play()
  spit_out_timer = 0

func fallthroughCollisionClear(exFriend):
  maybe_friend_refs.erase(exFriend.name)
  has_popped_out = false

var is_smacked = false
var smack_timer = 0
export var smack_time_limit = 5
var time_influence = 35
var y_div = 2.3
var normal_offset = .15
func getSmacked(broom_origin = null):
  if is_smacked:
    return
  smackSound.pitch_scale = rand_range(0.6, 1.0)
  smackSound.play()
  swallowSound.play()
  mySprite.material_override.set_shader_param("time_influence", time_influence)
  mySprite.material_override.set_shader_param("y_div", y_div)
  mySprite.material_override.set_shader_param("normal_offset", normal_offset)
  mySprite2.material_override.set_shader_param("time_influence", time_influence)
  mySprite2.material_override.set_shader_param("y_div", y_div)
  mySprite2.material_override.set_shader_param("normal_offset", normal_offset)
  
  smack_timer = 0
  is_smacked = true

func isActive():
  return true
