extends "../../scripts/levelScript.gd"

# @override
func _ready_impl():
    ._ready_impl()
    
    player.aniPlayer.clear_queue()
    player.aniPlayer.stop()
    player.aniPlayer.play("fallFlat")
    player.physics_state = player.PhysicsState.COLLAPSED
