extends "../../Door.gd"

onready var babaYaga = get_node("..")

# @overrie
func activate(is_player):
  babaYaga.wakeMeUp()