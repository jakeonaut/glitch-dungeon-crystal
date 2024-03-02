extends Spatial

#extends "res://scripts/_InteractionAreaEvent_template.gd"

func isActive(debug=false):
    # @override me #.isActive()
    return true

func activate(_is_player=true):
    # @override me #.activate(is_player)
    pass

func passiveActivate(_delta, _is_player=true):
    # @override me #.passiveActivate(delta, is_player)
    pass

func stopPassiveActivate():
    # @override me #.stopPassiveActivate()
    pass