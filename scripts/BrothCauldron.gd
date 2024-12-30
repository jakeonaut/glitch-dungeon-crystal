extends Spatial

# String is a path to a file.
export(String, FILE) var path

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var aniPlayer = get_node("AnimationPlayer")
onready var mySprite = get_node("Sprite3D")
var smokeFumeRes = preload("res://sceneObjects/SmokeFume.tscn")
var smoke_fume_timer = 0
var smoke_fume_time_limit = 15
export var is_active = false

func _ready():
  set_process(true)
  mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
  is_active = global.haveIBeenToThisLevelPath(path)

  if is_active:
    aniPlayer.play("active")
    smoke_fume_time_limit = 5

  smoke_fume_timer += (delta*11)
  if smoke_fume_timer >= smoke_fume_time_limit:
    smoke_fume_timer = 0
    var newSmokeFume = smokeFumeRes.instance()
    newSmokeFume.fade_out_opacity = true
    level.add_child(newSmokeFume)
    newSmokeFume.global_transform.origin = self.global_transform.origin
    newSmokeFume.global_transform.origin.y += 1.4
    newSmokeFume.global_transform.origin.x += rand_range(-1.0, 1.0)
    newSmokeFume.target_y = newSmokeFume.global_transform.origin.y + rand_range(1.0, 2.0)
    if is_active:
      newSmokeFume.material_override.set_shader_param("target_palette", global.yellow_palette)
      newSmokeFume.material_override.set_shader_param("offset", 8)
    
var who_is_standing_on_me = {}
func fallthroughCollisionActivate(friend):
  if not friend.on_ground:
    return # just landed
  # TODO(jaketrower): The downside to this if there are multiple fallthroughSolids a game_mover is "on"
  # is that multiple of them could fight for control here
  # so TODO(jaketrower): Need to make the game_mover call like "fallthroughCollisionClear"
  # if we are on another 
  # ALSO, need to make game_mover call "fallthroughCollisionClear" if we ever
  # like jump, or fall off too...
  if not who_is_standing_on_me.has(friend.name):
    # playBounce("land")
    pass

  var relativePosition = self.global_transform.origin - friend.global_transform.origin
  who_is_standing_on_me[friend.name] = [friend, 0, relativePosition]
  if friend == level.player and not is_static:
    behavior_jumping = true
    behavior_walking = true
    jump_timer = 0

func fallthroughCollisionClear(exFriend):
  who_is_standing_on_me.erase(exFriend.name)

func moveMyFriends(delta):
  for friend_key in who_is_standing_on_me.keys():
    var friendArray = who_is_standing_on_me[friend_key]
    var friend = friendArray[0]
    var relativePosition = friendArray[2]
    if friend.linear_velocity.y > 0 or friend.should_magic_jump:
      continue
    friend.should_do_fallthrough_area_collision = true
    friend.global_transform.origin += self.global_transform.origin - lastPosition
    if not friend.on_ground or friend.global_transform.origin.x < self.global_transform.origin.x + lb or \
        friend.global_transform.origin.x > self.global_transform.origin.x + rb:
      who_is_standing_on_me.erase(friend_key)
      continue
    friend.on_ground = true
    friend.linear_velocity.y = 0
    friend.fallthrough_area_collision_y = self.global_transform.origin.y - relativePosition.y + (self.linear_velocity.y*delta)

    # try to clean up
    friendArray[1] += (delta*22)
    if friendArray[1] >= move_my_friends_time_limit:
      who_is_standing_on_me.erase(friend_key)