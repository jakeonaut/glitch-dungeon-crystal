extends "Spawner.gd"


onready var mySprite = get_node("Sprite3D")
onready var spawnSound = get_node("SpawnSound")
onready var spawnSound2 = get_node("SpawnSound2")

var has_spawned = false
var glitchParticleBurstRes = preload("res://sceneObjects/GlitchParticleBurst.tscn")
export var is_static_in_level = true

func _ready():
    mySprite.visible = false
    if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self.name):
        # TODO(jaketrower): This is actually quite new, what if GeodeSpawner has spawned an enemy that hasn't been
        # killed yet, but was removed from the level (e.g. by leaving a room and re-entering it)
        # ideally we should have memory[geodeSpawnerShortName] be either:
        # 0, null = not_spawned
        # 1 = spawned_and_alive
        # 2 = spawned_and_dead
        if global.getStaticLevelZoneLevelVar(level, self.name) == 1:
            spawn(false)
            has_spawned = true
        if global.getStaticLevelZoneLevelVar(level, self.name) == 2:
            queue_free()

func spawnEffect(child):
    level.summonSmokeClouds(child.global_transform.origin, 2, true, true)

func _process(_delta):
    var is_condition_active = isConditionActive()
    is_active = is_condition_active and not has_spawned
    if not is_condition_active:
        for child in self.get_foreign_children():
            child.visible = false

func isConditionActive():
    return global.getLevelZoneThing("crystal_geode")

# @override
func getNumForeignChildren():
    if has_spawned:
        return max_num_children
    return 0

# @override
func spawn(with_flare = true):
    should_staticify_children = is_static_in_level # this breaks dynamically created SmallKeys
    if has_spawned:
        return
    .spawn(with_flare) # super()
    has_spawned = true

    if with_flare:
        spawnSound.play()
        spawnSound2.play()

        var newSmokeCloud = glitchParticleBurstRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x
        newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y - 1
        yield(get_tree().create_timer(0.3), "timeout")
        newSmokeCloud = glitchParticleBurstRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x
        newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + 1

        if is_static_in_level and not global.getStaticLevelZoneLevelVar(level, self.name):
            global.setStaticLevelZoneLevelVar(level, self.name, 1)

# @override
func myChildDied():
    global.setStaticLevelZoneLevelVar(level, self.name, 2)
