extends Spatial

#extends "res://scripts/_InteractionAreaEvent_template.gd"

var prev_fallthrough_collision_area = null
var prev_prev_fallthrough_collision_area = null
func isActive(_debug=false):
    # @override me #.isActive()
    return true

func activate(_is_player=true, _is_local_broom=false):
    # @override me #.activate(is_player, is_local_broom)
    pass

func passiveActivate(_delta, _is_player=true, _is_local_broom=false):
    # @override me #.passiveActivate(delta, is_player, is_local_broom)
    pass

func stopPassiveActivate():
    # @override me #.stopPassiveActivate()
    pass