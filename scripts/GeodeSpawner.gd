extends "Spawner.gd"


onready var mySprite = get_node("Sprite3D")
onready var spawnSound = get_node("SpawnSound")
onready var spawnSound2 = get_node("SpawnSound2")

var has_spawned = false
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var glitchParticleBurstRes = preload("res://sceneObjects/GlitchParticleBurst.tscn")
export var is_static_in_level = true

func _ready():
    mySprite.visible = false
    if is_static_in_level and global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.name):
        # TODO(jaketrower): This is actually quite new, what if GeodeSpawner has spawned an enemy that hasn't been
        # killed yet, but was removed from the level (e.g. by leaving a room and re-entering it)
        # ideally we should have memory[geodeSpawnerShortName] be either:
        # 0 = not_spawned
        # 1 = spawned_and_alive
        # 2 = spawned_and_dead
        if global.memory[level.getShortLevelName()][self.name] == 1:
            spawn(false)
        has_spawned = true
        queue_free()
        return

func _process(_delta):
    is_active = global.hasGottenLevelGeode and not has_spawned

# @override
func getNumChildren():
    if has_spawned:
        return max_num_children
    return 0

# @override
func spawn(with_flare = true):
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

        if is_static_in_level and not (global.memory.has(level.getShortLevelName()) and global.memory[level.getShortLevelName()].has(self.name)):
            if not global.memory.has(level.getShortLevelName()):
                global.memory[level.getShortLevelName()] = {}
            global.memory[level.getShortLevelName()][self.name] = 1