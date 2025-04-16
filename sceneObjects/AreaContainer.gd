extends Spatial

export var is_active = true
export var kill_immediately = false
export var kill_invis = false
var glitch_form = global.GlitchForm.NORMAL

func isActive():
    return visible and is_active

func notOuchies(_whatever):
    pass