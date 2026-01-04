extends "../../Door.gd"

onready var babaYaga = get_node("..")

# @overrie
func activate(_is_player, _is_local_broom = false):
  babaYaga.wakeMeUp()