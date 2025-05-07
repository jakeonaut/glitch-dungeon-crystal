extends Spatial

var is_purified = false
var rot_amount = 100
var rot_amount_max = 200
onready var cubeContainer = get_node("CubeContainer")
onready var lightAniPlayer = get_node("LightAnimationPlayer")
onready var npc = get_node("NPC")
onready var npcSprite = get_node("NPC/Sprite3D")
onready var getHitSound = get_node("GetHitSound")
onready var getHitSound2 = get_node("GetHitSound2")
onready var getHitSound3 = get_node("GetHitSound3")
onready var directionalLight = get_node("DirectionalLight")
onready var collisionShape1 = get_node("InteractionArea/CollisionShape")
onready var collisionShape2 = get_node("InteractionArea/CollisionShape2")
var can_do_my_power = true
# String is a path to a file.
export(String, FILE) var path # unused atm

onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var quietSavePoint = get_node("../QuietSavePoint") if has_node("../QuietSavePoint") else null
onready var meshInstance1 = get_node("CubeContainer/MeshInstance")
onready var meshInstance3 = get_node("CubeContainer/MeshInstance3")

onready var meshInstance2 = get_node("CubeContainer/MeshInstance2")
var npcRes = preload("res://sceneObjects/ElderTadpoleNPC.tscn")
var ritualDialogStartSoundScriptRes = preload("res://levels/EndlessFantasy/gd1GrandmaVillage/AngelStatueRitualNPCDialogStartSound.gd")

export var num_gems_needed = 20
export var high_priestess_crystal = false


var levelTiles = null
func getLevelTiles():
  if levelTiles == null:
    levelTiles = level.levelTiles
  return levelTiles

func _ready():
    set_process(true)

    meshInstance2.mesh = meshInstance2.mesh.duplicate()
    meshInstance2.set_material_override(meshInstance2.get_material_override().duplicate())
    meshInstance2.material_override.set_shader_param("alpha2", 0.5)
    if getMyStaticLevelZoneVar() or global.memory["clean_crystals"] >= 5:
        is_purified = true
        visible = false
        # lightAniPlayer.play("lightUpQuiet")
        yield(get_tree().create_timer(0.1), "timeout")
        freeUpPlayer()
        level.purifyAllWeakEnemies(false)
        level.purifyAllFragileBrickSolids(false)
        queue_free()
        # musicPlayer.changeSongPitch(1.0)
    # elif global.memory["priestess"] >= 2: # and global.memory["glitched_grimoire"]:
    #     global.setStaticLevelZoneLevelVar(level, self, true)
    #     global.memory["clean_crystals"] += 1
    #     global.setLevelZoneThing("crystal_geode", true)
    #     is_purified = true
    #     visible = false
    #     # lightAniPlayer.play("lightUpQuiet")
    #     yield(get_tree().create_timer(0.1), "timeout")
    #     freeUpPlayer()
    #     getLevelTiles().purifyAllSpikes()
    #     level.purifyAllWeakEnemies(false)
    #     level.purifyAllFragileBrickSolids(false)
    #     queue_free()
    #     # musicPlayer.changeSongPitch(1.0)
    else:
        lightAniPlayer.play("RESET")    
    # if global.hasGottenLevelGeode:
    #     # aniPlayer.play("quick_explode")
    #     yield(TempTimer.idle_frame(self), "timeout")
    #     yield(TempTimer.idle_frame(self), "timeout")
    #     stopAnimation()

    var levelZoneName = global.currLevelZone
    if levelZoneName == "gd1GrandmaVillage" or levelZoneName == "gd1PrimordialOoze":
        return
    match levelZoneName:
        "gd1FishingVillage":
            npcSprite.updateBaseFrame(2, 8)
        "gd1ToxicJungle":
            npcSprite.updateBaseFrame(0, 8)
        "gd1ShiftingSandLand":
            npcSprite.updateBaseFrame(4, 8)

var tadpole_spin_start_timer = 0
var tadpole_spin_start_time_limit = 10
var tadpoles = []
var num_tadpoles = 0
var tadpole_index = 0
var cube_rotation = 66
var sams_weird_timeout_timer = 0
var sams_weird_timeout_time_limit = 120
var spawn_pos = null
var pre_purification_rotate_amt = 1
func _process(delta):
    if is_purified:
        cubeContainer.rotation_degrees.y += delta*22
        if not global.hasGottenLevelGeode and global.shouldRenderAsCinematic:
            global.pauseMoveInput = false
            global.pauseGame = false
            level.player.pauseSelf = false
            level.player.physics_state = level.player.PhysicsState.NORMAL
            level.player.pauseInput = false
            level.player.ignorePhysics = false
            global.shouldRenderAsCinematic = false
    else: 
        cubeContainer.rotation_degrees.y -= delta*22 * pre_purification_rotate_amt
    # if is_purified:
    #     # musicPlayer.changeSongPitch(1.0)
    # else:
    #     musicPlayer.changeSongPitch(0.5)
    # var level_name = level.getLevelName()
    # if not "Haven" in level_name and not "MainMenu" in level_name:
    #     musicPlayer.changeSongPitch(0.5)
    if not can_do_my_power:
        return
    rot_amount = 10
    if is_purified:
        rot_amount *= 2
    # npc.rotation_degrees.y -= (delta * rot_amount)

    if is_smacked:
        smack_timer += (delta*11)
        if smack_timer >= smack_time_limit:
            smack_timer = 0
            is_smacked = false

func stopAnimation():
    can_do_my_power = false
    global.hasLevelGeodeBeenSmacked = false
    # level.levelTiles.randomize_num = 1
    # level.levelTiles.randomize_num_counter = 0
    # level.player.pauseSelf = false
    # level.restartMusic()
    # level.gameCamera.zoom_in_on_player = false

var is_smacked = false
var smack_timer = 0
var smack_time_limit = 3
var is_fake = false

func fakify():
    is_fake = true
    yield(TempTimer.idle_frame(self), "timeout")
    lightAniPlayer.stop()
    lightAniPlayer.clear_queue()
    lightAniPlayer.play("fadeIn")

var ok_byebye = false
func getSmacked(_broom_origin):
    if is_smacked or ok_byebye:
        return
    is_smacked = true
    smack_timer = 0

    if is_fake:
        lightAniPlayer.stop()
        lightAniPlayer.clear_queue()
        lightAniPlayer.play("fakeBreak")
        ok_byebye = true
        level.player.getSmacked()
    elif is_purified:
        getHitSound.play()
        level.player.glitch_death_timer = 8
        level.player.glitchTickle()
        level.glitchScreenEffect.visible = global.userSettings["canGlitchScreen"]
    else:
        if not meshInstance1.visible:
            meshInstance1.visible = true
            pre_purification_rotate_amt = -2
            level.player.glitch_death_timer = 8
            getHitSound.play()
        elif not meshInstance3.visible:
            meshInstance3.visible = true
            pre_purification_rotate_amt = 3
            level.player.glitch_death_timer = 5
            getHitSound2.play()
        else:
            getPurified()
            level.player.glitch_death_timer = 1
            getHitSound3.play()
        level.player.glitchTickle()
        level.glitchScreenEffect.visible = global.userSettings["canGlitchScreen"]
    return true

func resmack():
    level.player.getSmacked()
    

var is_active = true
func isActive(_debug=false):
    return visible and is_active

func speakToMe():
    is_purified = true
    if high_priestess_crystal:
        global.hasGottenLevelGeode = false
        global.hasLevelGeodeBeenSmacked = false
    else:
        global.hasGottenLevelGeode = true
        global.hasLevelGeodeBeenSmacked = true
    # if global.memory["clean_crystals"] == 1:
    #     level.player.sayThis("you purified a crystal.\npleasant, somehow.")
    # else:
    #     level.player.sayThis("wow, congrats, you purified a crystal!")

var soft_is_purified = false
func getPurified():
    if is_purified or soft_is_purified:
        return
    var children = self.get_children()
    for child in children:
        if child.is_in_group("event") and child.isActive():
            child.passiveActivate(0, true)

    if global.activeInteractor != null and is_instance_valid(global.activeInteractor):
        global.activeInteractor.stopInteract()

    global.setStaticLevelZoneLevelVar(level, self, true)
    lightAniPlayer.play("lightUp")
    level.player.physics_state = level.player.PhysicsState.OCCUPIED
    level.player.pauseAnimation = false
    level.player.pauseSelf = true
    level.player.pauseInput = true
    global.pauseMoveInput = true
    global.pauseGame = true
    global.shouldRenderAsCinematic = true
    # level.levelTiles.randomize_num += 10
    # level.levelTiles.randomize_num_counter = 15
    soft_is_purified = true
    # level.show_crt_effect = true
    # level.player.pauseSelf = true
    # musicPlayer.stopAll()
    # musicPlayer.changeSongPitch(1.0)

    getLevelTiles().purifyAllSpikes()
    level.purifyAllWeakEnemies()
    level.purifyAllFragileBrickSolids()
    if global.getLevelZoneThing("angel_statue") == null:
        global.setLevelZoneThing("angel_statue", [
            global.getDisplayTitle(level.getLevelZoneName(), tr("LevelName.1")),
            level.getLevelName()
        ])
    # if level.has_node("SavePoint"):
    #     level.get_node("SavePoint").passiveActivate(0, is_player)
    # trySweepUpGlitchTiles(collisionShape1)
    # trySweepUpGlitchTiles(collisionShape2)
    var crystal_shards = level.get_tree().get_nodes_in_group("crystal_shard")
    for shard in crystal_shards:
        if shard.cubeSound != null:
            shard.cubeSound.volume_db = -99
        shard.cubeSound2.volume_db = -99
        shard.passiveActivate(0, false)
    musicPlayer.playTreasureJingle(-80)
    global.memory["clean_crystals"] += 1
    global.setLevelZoneThing("crystal_geode", true)
    if "HighPriestessRoom" in level.getShortLevelName():
        # print("excuse me?")
        level.restartMusic()

    level.saveTheGame()

export var spawn_an_elder = true
# actually "spawn elderNPC" but the animations are already calling it...
func freeUpPlayer():
    # print("?")
    is_active = false

    if is_fake or not spawn_an_elder or high_priestess_crystal or (global.memory["priestess"] > 0 and global.justAngelWarped):
        return

    # print("??")
    var elderNPC = npcRes.instance()
    level.add_child(elderNPC)
    level.summonSmokeClouds(global_transform.origin, 3, true, true)
    elderNPC.global_transform.origin = global_transform.origin
    elderNPC.global_transform.origin.y -= 0.5
    elderNPC.am_i_glitchy = true
    elderNPC.secretAniPlayer.stop()
    elderNPC.secretAniPlayer.clear_queue()
    elderNPC.secretAniPlayer.play("glitchTickle")
    # if global.memory["priestess"] > 0:
    #     elderNPC.textBox.dialogStartSound.script = ritualDialogStartSoundScriptRes
    #     elderNPC.am_i_sleepy = false
    # else:
    elderNPC.processLevelZone()

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
                getLevelTiles().infectSpikes(coords, false)
                # TODO(jaketrower): also reset the levelTiles array position?


var staticLevelZoneVar = null
func getMyStaticLevelZoneVar(refresh_if_null = false):
    if level == null:
        level = get_tree().get_root().get_node("Game/Viewport/level")
    if staticLevelZoneVar == null or refresh_if_null:
        staticLevelZoneVar = global.getStaticLevelZoneLevelVar(level, self)
    return staticLevelZoneVar

var glitchedMaterial = preload("res://materials/PriestessCrystalGlitch.tres")
var is_glitched = false
func applyGlitchMaterial(influence):
  if is_glitched:
    return
  is_glitched = true
  var new_glitched_material = glitchedMaterial.duplicate()
  new_glitched_material.set_shader_param("corruption_amount", 0.1 + influence*0.1)
  new_glitched_material.set_shader_param("uv_scrolling_velocity", Vector2(influence*0.1, influence*0.1))
  new_glitched_material.set_shader_param("normal_offset", influence*0.125 + 0.25)
  new_glitched_material.set_shader_param("time_influence", influence + 2)
  new_glitched_material.set_shader_param("y_div", influence * 0.5 + 3)
  meshInstance2.set_material_override(new_glitched_material)