extends "res://scripts/GameMover.gd"

var shake_power = 0.001
var opacity = 0.5
var shake_color_rate = 0.001

func _ready():
	mySprite.material_override = mySprite.material_override.duplicate()

func _process(delta):
	delta = delta * global.time_dilation_multiplier

	if opacity > 0:
		opacity -= delta/10
		shake_color_rate += delta/100
		shake_power += delta/100
		mySprite.material_override.set_shader_param("shake_color_rate", shake_color_rate)
		mySprite.material_override.set_shader_param("shake_power", shake_power)
		mySprite.material_override.set_shader_param("opacity", opacity)
		if opacity <= 0:
			queue_free()

func fallthroughCollisionActivate():
	pass
	# mySprite.material_override.set_shader_param("enable_glitch", true)
	# print("set shake power...")
	# shake_power = 0.005
	# mySprite.material_override.set_shader_param("shake_power", shake_power)
