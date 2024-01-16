extends Spatial

var has_been_smacked = false
var rot_amount = 100
var rot_amount_max = 200
onready var cubeContainer = get_node("CubeContainer")
onready var aniPlayer = get_node("AnimationPlayer")
onready var lightAniPlayer = get_node("LightAnimationPlayer")
onready var debugDoor = get_tree().get_root().get_node("Game/Viewport/level/DebugDoor")
onready var npc = get_node("NPC")
onready var npcSprite = get_node("NPC/Sprite3D")
onready var getHitSound = get_node("GetHitSound")
onready var getHitSound2 = get_node("GetHitSound2")
onready var notGetHitSound = get_node("NotGetHitSound")
onready var directionalLight = get_node("DirectionalLight")
onready var collisionShape1 = get_node("InteractionArea/CollisionShape")
onready var collisionShape2 = get_node("InteractionArea/CollisionShape2")
var can_do_my_power = true
# String is a path to a file.
export(String, FILE) var path # unused atm

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var quietSavePoint = get_node("../QuietSavePoint") if has_node("../QuietSavePoint") else null

var levelTiles = null
func getLevelTiles():
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles

func _ready():
    set_process(true)
    if getMyStaticLevelZoneVar():
        has_been_smacked = true
        lightAniPlayer.play("lightUp")
        debugDoor.visible = true
        # musicPlayer.changeSongPitch(1.0)
    # if global.hasGottenLevelGeode:
    #     # aniPlayer.play("quick_explode")
    #     yield(TempTimer.idle_frame(self), "timeout")
    #     yield(TempTimer.idle_frame(self), "timeout")
    #     stopAnimation()

var tadpole_spin_start_timer = 0
var tadpole_spin_start_time_limit = 10
var tadpoles = []
var num_tadpoles = 0
var tadpole_index = 0
var cube_rotation = 66
var sams_weird_timeout_timer = 0
var sams_weird_timeout_time_limit = 120
var spawn_pos = null
func _process(delta):
    # if has_been_smacked:
    #     # musicPlayer.changeSongPitch(1.0)
    # else:
    #     musicPlayer.changeSongPitch(0.5)
    musicPlayer.changeSongPitch(0.5)
    if not can_do_my_power:
        return
    rot_amount = 10
    if has_been_smacked:
        rot_amount *= 2
    npc.rotation_degrees.y -= (delta * rot_amount)

var opacity = 0.8
var stop_animation_timer = 0
var stop_animation_time_limit = 20
func spinTheFroggies(delta):
    # TODO(jaketrower): start chanting and you all speed upward and teleport back to hub world...
    if tadpole_index < num_tadpoles:
        tadpole_spin_start_timer += (delta*11)
        if tadpole_spin_start_timer >= tadpole_spin_start_time_limit:
            tadpole_spin_start_timer = 0
            var tadpole = tadpoles[tadpole_index]
            tadpole.startSpinning(tadpole_index, num_tadpoles, level.player)
            tadpole.can_be_smacked = false
            tadpole_index += 1
    elif global.hasGottenLevelGeode and level.gameCamera.am_i_zooming:
        var should_stop_animation = true
        for tadpole in tadpoles:
            if not tadpole.is_evolved:
                should_stop_animation = false
        if should_stop_animation:
            stop_animation_timer += (delta*11)
            if stop_animation_timer >= stop_animation_time_limit:
                stopAnimation()

func stopAnimation():
    can_do_my_power = false
    global.hasLevelGeodeBeenSmacked = false
    # level.levelTiles.randomize_num = 1
    # level.levelTiles.randomize_num_counter = 0
    # level.player.pauseSelf = false
    # level.restartMusic()
    # level.gameCamera.am_i_zooming = false

func getSmacked(_broom_origin):
    activate(true)

func isActive():
    return visible and not has_been_smacked

func activate(_is_player):
    # if not global.memory["broom"]:
    #     if not notGetHitSound.is_playing(): notGetHitSound.play()
    #     return

    var children = self.get_children()
    for child in children:
        if child.is_in_group("event") and child.isActive():
            child.passiveActivate(0, true)




    global.setStaticLevelZoneLevelVar(level, self.name, true)
    lightAniPlayer.play("lightUp")
    level.player.glitchTickle()
    level.player.physics_state = level.player.PhysicsState.GLITCH_HURT
    level.player.glitch_death_timer = 1
    if global.canGlitchScreen: # TODO(jaketrower): RESPECT MORE
      level.glitchScreenEffect.visible = true
        # level.levelTiles.randomize_num += 10
        # level.levelTiles.randomize_num_counter = 15
    has_been_smacked = true
    # level.show_crt_effect = true
    # level.player.pauseSelf = true
    # musicPlayer.stopAll()
    # musicPlayer.changeSongPitch(1.0)
    getHitSound.play()
    getHitSound2.play()

    # if level.has_node("SavePoint"):
    #     level.get_node("SavePoint").passiveActivate(0, is_player)
    trySweepUpGlitchTiles(collisionShape1)
    trySweepUpGlitchTiles(collisionShape2)
    var crystal_shards = level.get_tree().get_nodes_in_group("crystal_shard")
    for shard in crystal_shards:
        shard.passiveActivate(0, false)
    global.memory["clean_crystals"] += 1
    global.setLevelZoneThing("crystal_geode", true)
    if quietSavePoint:
        quietSavePoint.passiveActivate(0, true)
    if debugDoor:
        level.summonSmokeClouds(debugDoor.global_transform.origin, 3, true, true)
        debugDoor.path = "res://levels/EndlessFantasy/gd1/DebugTownLilypad.tscn"
        debugDoor.visible = true


func trySweepUpGlitchTiles(collisionShape):
    if not collisionShape.visible:
        return
    
    var x = collisionShape.global_transform.origin.x
    var y = collisionShape.global_transform.origin.y
    var tb = y + collisionShape.shape.extents.y/2*collisionShape.scale.y + 1
    var bb = y - collisionShape.shape.extents.y/2*collisionShape.scale.y - 1
    var lb = x - collisionShape.shape.extents.x/2*collisionShape.scale.x - 1
    var rb = x + collisionShape.shape.extents.x/2*collisionShape.scale.x + 1
    
    var _has_played_sound = false
    for i in range(int(floor(bb)), int(ceil(tb))):
        for j in range(int(floor(lb)), int(ceil(rb))):
            var coords = getLevelTiles().world_to_map(Vector3(j, i, 0))
            var tile_type = getLevelTiles().get_cell_item(coords.x, coords.y, coords.z)
            if getLevelTiles().isTileSpikes(tile_type):
                getLevelTiles().infectSpikes(coords)
                # TODO(jaketrower): also reset the levelTiles array position?


var staticLevelZoneVar = null
func getMyStaticLevelZoneVar(refresh_if_null = false):
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if staticLevelZoneVar == null or refresh_if_null:
        staticLevelZoneVar = global.getStaticLevelZoneLevelVar(level, self.name)
        return staticLevelZoneVar
