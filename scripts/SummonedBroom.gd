extends Spatial


var broom_active_timer = 0
var broom_active_time_limit = 10 
var my_broom_owner = null
onready var broomSound = get_node("BroomSound")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var myArea = get_node("Area")
onready var collisionShape1 = get_node("Area/CollisionShape")
onready var collisionShape2 = get_node("Area/CollisionShape2")
onready var collisionShape3 = get_node("Area/CollisionShape3")
onready var aniPlayer = get_node("AnimationPlayer")
var smacked_npc = null
var have_i_smacked_an_npc = false
var is_active = true

var levelTiles = null
func getLevelTiles():
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles


# Called when the node enters the scene tree for the first time.
func _ready():
  set_process(true)


func _process(delta):
  delta = delta * global.time_dilation_multiplier
  
  # if global.pauseGame: return
  hitStuff(delta)
    
  broom_active_timer += (delta*22)
  if broom_active_timer >= broom_active_time_limit:
    # broom_active_timer = 0
    if my_broom_owner: 
      if global.memory["multi_broom"]:
        my_broom_owner.summonedBroom = null
      my_broom_owner.broomStop()
    visible = false
    
  if not visible and not broomSound.is_playing():
    if global.memory["multi_broom"]:
      visible = true
      broom_active_timer = 0
      aniPlayer.play(aniPlayer.assigned_animation)
    else:
      queue_free()

# dedupe with FallenBroom
func hitStuff(_delta):
  if not visible: return
  
  smacked_npc = global.broomSmackStuff(myArea.get_overlapping_areas(), is_active, global_transform, my_broom_owner, level, smacked_npc)

  # erase glitch tiles...
  trySweepUpGlitchTiles(collisionShape1)
  trySweepUpGlitchTiles(collisionShape2)
  trySweepUpGlitchTiles(collisionShape3)
  
func trySweepUpGlitchTiles(collisionShape):
  if not collisionShape.visible:
    return

  var has_clanked = false
  var was_clank_sand = false
  var x = collisionShape.global_transform.origin.x
  var y = collisionShape.global_transform.origin.y
  var tb = y + collisionShape.shape.extents.y/2*collisionShape.scale.y + 0.25
  var bb = y - collisionShape.shape.extents.y/2*collisionShape.scale.y - 0.25
  var lb = x - collisionShape.shape.extents.x/2*collisionShape.scale.x - 0.25
  var rb = x + collisionShape.shape.extents.x/2*collisionShape.scale.x + 0.25
  
  var _has_played_sound = false
  for i in range(int(floor(bb)), int(ceil(tb))):
    for j in range(int(floor(lb)), int(ceil(rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if getLevelTiles().isTileSpikes(tile_type):
        getLevelTiles().infectSpikes(coords)
        my_broom_owner.has_sweeped_glitch = true
        # TODO(jaketrower): also reset the levelTiles array position?
      # if getLevelTiles().isTileGlitchSpikes(tile_type):
      #   has_clanked = true
      # if getLevelTiles().isTileSoftSand(tile_type):
      #   getLevelTiles().sweepUpSand(coords)
      #   has_clanked = true
      #   was_clank_sand = true
  
  if has_clanked:
    my_broom_owner.swordClank(not was_clank_sand)
    if was_clank_sand:
      my_broom_owner.digSound.play()
    queue_free()

func isActive(_debug=false):
  return visible

func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
  level.summonSmokeClouds(global_transform.origin, num_clouds, play_sound, is_glitchy)
