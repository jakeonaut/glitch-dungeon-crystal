extends Spatial


var broom_active_timer = 0
var broom_active_time_limit = 10 
var my_broom_owner = null
onready var broomSound = get_node("BroomSound")
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var myArea = get_node("Area")
onready var collisionShape1 = get_node("Area/CollisionShape")
onready var collisionShape2 = get_node("Area/CollisionShape2")
onready var collisionShape3 = get_node("Area/CollisionShape3")
onready var aniPlayer = get_node("AnimationPlayer")
var has_hit_npc = null

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
    if my_broom_owner: my_broom_owner.broomStop()
    visible = false
    
  if not visible and not broomSound.is_playing():
    queue_free()
    
func summonSmokeClouds(num_clouds, play_sound = false, is_glitchy = false):
  for _i in range(num_clouds):
    var newSmokeCloud = smokeCloudRes.instance()
    level.add_child(newSmokeCloud)
    newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
    newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(-1, 1)
    newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
    if play_sound:
      newSmokeCloud.get_node("CleanGlitchSound").play()
      newSmokeCloud.get_node("CleanGlitchSound").pitch_scale = rand_range(0.8, 1.2)
      play_sound = false
    if is_glitchy:
      pass
      # TODO(jaketrower): testing performance # 
      # var new_material = newSmokeCloud.get_material_override().duplicate()
      # new_material.set_shader_param("enable_glitch", "true")
      # new_material.set_shader_param("target_palette", global.weird_base_palette)
      # newSmokeCloud.set_material_override(new_material.duplicate())
    
  # TODO(should just use the levelTiles func here)
func isTileSpikes(tile_type):
  if tile_type == GridMap.INVALID_CELL_ITEM:
    return false
  var tile_name = getLevelTiles().mesh_library.get_item_name(tile_type)
  return "Spikes" in tile_name and not "GlitchSpikes" in tile_name
    
func canActivate(area):
  var areaParent = area.get_node("..")
  return not areaParent.has_method("imAnNpc") or areaParent != has_hit_npc

func hitStuff(_delta):
  if not visible: return
  
  var areas = myArea.get_overlapping_areas()
  for area in areas:
    if area.is_in_group("weak_enemies") and area.has_method("isActive") and area.isActive():
      if not area.get_node("..").am_i_dying:
        area.get_node("..").ouchies(global_transform.origin)
        my_broom_owner.has_sweeped_glitch = true
        summonSmokeClouds(5, true, true)
        my_broom_owner.getSmacked()
    elif area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
      if global.hasGottenLevelGeode:
        if area.get_node("..").ouchies(global_transform.origin):
          my_broom_owner.getSmacked()
          my_broom_owner.has_sweeped_glitch = true
      else:
        if area.get_node("..").notOuchies(global_transform.origin):
          my_broom_owner.getSmacked()
      
      # # TODO kill glitches or "free" them like glitch slug...
      
    elif area.is_in_group("corporeal_body"):
      var areaParent = area.get_node("..")
      if canActivate(area) and areaParent != my_broom_owner and areaParent.has_method("isActive") and areaParent.isActive():
        if not area.is_in_group("tadpole"):
          my_broom_owner.getSmacked()
        if areaParent.has_method("imAnNpc"):
          has_hit_npc = areaParent
        areaParent.getSmacked(global_transform.origin)
    elif canActivate(area) and not area.is_in_group("door") and area.has_method("isActive") and area.isActive() and area.has_method("InteractActivate"):
      # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
      area.InteractActivate(false)
    elif canActivate(area) and area.has_method("isActive") and area.isActive() and area.has_method("PassiveInteractActivate"): 
      # if you want to check from the area if it is a SummonedBroom or Thrown, just check global.memory["broom"] = false
      area.PassiveInteractActivate(0, false)

  # erase glitch tiles...
  if not global.memory.has("broom"):
    return
  trySweepUpGlitchTiles(collisionShape1)
  trySweepUpGlitchTiles(collisionShape2)
  trySweepUpGlitchTiles(collisionShape3)
  
func trySweepUpGlitchTiles(collisionShape):
  if not collisionShape.visible:
    return

  var x = collisionShape.global_transform.origin.x
  var y = collisionShape.global_transform.origin.y
  var tb = y + collisionShape.shape.extents.y/2*collisionShape.scale.y
  var bb = y - collisionShape.shape.extents.y/2*collisionShape.scale.y
  var lb = x - collisionShape.shape.extents.x/2*collisionShape.scale.x
  var rb = x + collisionShape.shape.extents.x/2*collisionShape.scale.x
  
  var _has_played_sound = false
  for i in range(int(floor(bb)), int(ceil(tb))):
    for j in range(int(floor(lb)), int(ceil(rb))):
      var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
      var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
      if isTileSpikes(tile_type) and not getLevelTiles().isTileGlitchSpikes(tile_type):
        my_broom_owner.has_sweeped_glitch = true
        getLevelTiles().infectSpikes(coords)
        # TODO(jaketrower): also reset the levelTiles array position?
      if getLevelTiles().isTileGlitchSpikes(tile_type):
        my_broom_owner.getSmacked()

func isActive():
  return visible
