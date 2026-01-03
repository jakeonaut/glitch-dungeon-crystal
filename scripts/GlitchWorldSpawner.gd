extends "Spawner.gd"

onready var spawnSound = get_node("SpawnSound")
onready var spawnSound2 = get_node("SpawnSound2")

var has_spawned = false
var glitchParticleBurstRes = preload("res://sceneObjects/GlitchParticleBurst.tscn")
export var is_static_in_level = true

func _ready():
    mySprite.visible = false
    if is_static_in_level and global.getStaticLevelZoneLevelVar(level, self):
        # TODO(jaketrower): This is actually quite new, what if GeodeSpawner has spawned an enemy that hasn't been
        # killed yet, but was removed from the level (e.g. by leaving a room and re-entering it)
        # ideally we should have memory[geodeSpawnerShortName] be either:
        # 0, null = not_spawned
        # 1 = spawned_and_alive
        # 2 = spawned_and_dead
        if global.getStaticLevelZoneLevelVar(level, self) == 1:
            spawn(false)
            has_spawned = true
        if global.getStaticLevelZoneLevelVar(level, self) == 2:
            has_spawned = true

func spawnEffect(child, with_flare):
    if with_flare:
        level.summonSmokeClouds(child.global_transform.origin, 2, true, true)

# @override
func processSpawningLogic(_delta):
    if has_spawned:
        return

    am_i_in_range_of_player = am_i_really_in_range_of_player or (not only_activate_in_range)
    am_i_really_in_range_of_player = false
    is_active = isConditionActive()
 
    if not is_active:
        # should I put this in _ready ?
        for child in self.get_foreign_children():
            child.visible = false
        return

    spawn()

func isConditionActive():
    return global.memory["world_of_ruin"] and am_i_in_range_of_player

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
    if level.player:
        level.player.glitchTickle()
    glitchTilesAroundMe()

    if with_flare:
        level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
        if is_static_in_level and not global.getStaticLevelZoneLevelVar(level, self):
            global.setStaticLevelZoneLevelVar(level, self, 1)

    if spawned_object_instance != null and spawned_object_instance.has_method("evilSetAsParent"):
        spawned_object_instance.evilSetAsParent(self)

# @override
func myChildDied():
    global.setStaticLevelZoneLevelVar(level, self, 2)
