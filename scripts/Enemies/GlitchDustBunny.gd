extends "GlitchEnemy.gd"

enum BunnyState {
    IDLE,
    HOP
}
var bunny_state = BunnyState.HOP

onready var sparkleSprite = get_node("SparkleSprite")
var spawn_timer = 0
var spawn_time_limit = 3

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit
    walk_speed = 4
    jump_force = 10
    grav = Vector2(0, 40)

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier

    spawn_timer += (delta*22)
    if spawn_timer >= spawn_time_limit:
        var children = self.get_children()
        var num_children = 0
        for i in children:
            num_children += 1

        if num_children < 20:
            var newSprite = sparkleSprite.duplicate()
            newSprite.should_fizzle_out = true
            newSprite.visible = true
            var offset = Vector3(
                stepify(rand_range(-1.0, 1.0), 0.12),
                0,
                0
            )
            newSprite.updateBaseFrame(0, 0)
            newSprite.max_frames = 2
            newSprite.frame_delay = 0.15
            level.add_child(newSprite)
            newSprite.global_transform.origin = self.global_transform.origin + offset
            spawn_timer = 0
        

# @override
func glitchSetSpritesAndCollision():
    pass
