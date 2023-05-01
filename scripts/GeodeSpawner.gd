extends "Spawner.gd"


onready var mySprite = get_node("Sprite3D")
onready var spawnSound = get_node("SpawnSound")
onready var spawnSound2 = get_node("SpawnSound2")

var has_spawned = false
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
var glitchParticleBurstRes = preload("res://sceneObjects/GlitchParticleBurst.tscn")

func _ready():
    mySprite.visible = false

func _process(_delta):
    is_active = global.hasGottenLevelGeode and not has_spawned

# @override
func getNumChildren():
    if has_spawned:
        return max_num_children
    return 0

# @override
func spawn():
    if has_spawned:
        return
    .spawn() # super()
    has_spawned = true
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