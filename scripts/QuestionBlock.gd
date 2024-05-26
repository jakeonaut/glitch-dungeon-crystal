extends Spatial

onready var aniPlayer = get_node("AnimationPlayer")
onready var player = get_node("../Player")
onready var bonkSound = get_node("BonkSound")
var has_been_hit = false
var num_hits = 0
export var max_num_hits = 1
var hit_cooldown = 0
var hit_cooldown_limit = 5
export(String, FILE) var spawned_object_path
export var is_static_in_level = true
var spawned_object_res = null

onready var level = get_tree().get_root().get_node("Game/Viewport/level")

# Called when the node enters the scene tree for the first time.
func _ready():
  for child in self.get_foreign_children():
    child.visible = false
  yield(TempTimer.idle_frame(self), "timeout")
  yield(TempTimer.idle_frame(self), "timeout")
  if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self.name):
    passiveActivate(0, true)
  if spawned_object_path.length() != 0:
    spawned_object_res = load(spawned_object_path)

func _process(delta):
  if not has_been_hit and hit_cooldown > 0:
    hit_cooldown -= (delta*22)
    if hit_cooldown <= 0:
      aniPlayer.play("reset")

func get_foreign_children():
  return self.get_children().slice(4, self.get_child_count())
  
func isActive(_debug=false):
  return not has_been_hit
  
func passiveActivate(_delta, is_player):
  if not has_been_hit and not hit_cooldown > 0:
    if (not player.on_ground) or player.justPressedJump() or not is_player:
      if not is_player:
        player.getSmacked()
      aniPlayer.play("hit")
      performSpawn()
      hit_cooldown = hit_cooldown_limit
      if is_static_in_level:
        global.setStaticLevelZoneLevelVar(level, self.name, true)
    # elif player.linear_velocity.y > 0:
    #   aniPlayer.play("hitDown")
    #   performSpawn()
    

var myDynamicSpawnedChild = null 
func performSpawn():
  level.summonSmokeClouds(global_transform.origin, 5)
  num_hits += 1
  
  if num_hits >= max_num_hits:
    has_been_hit = true
    for child in self.get_foreign_children():
      if myDynamicSpawnedChild and child == myDynamicSpawnedChild.get_ref():
        continue
      bonkSound.play()
      child.visible = true
      if child.has_method("passiveActivate"):
          child.passiveActivate(33, false)

    if spawned_object_res != null:
      has_been_hit = false
      if (myDynamicSpawnedChild == null or not myDynamicSpawnedChild.get_ref()):
        bonkSound.play()
        var newObject = spawned_object_res.instance()
        add_child(newObject)
        newObject.global_transform.origin = self.global_transform.origin
        newObject.global_transform.origin.y += 2
        if newObject.has_method("setAsParent"):
            newObject.setAsParent(self)
        myDynamicSpawnedChild = weakref(newObject)
  else:
    bonkSound.play()
    var child = self.get_foreign_children()[num_hits - 1]
    child.visible = true
    if child.has_method("passiveActivate"):
        child.passiveActivate(33, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
# pass
