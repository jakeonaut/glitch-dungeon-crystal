extends Sprite3D

# String is a path to a file.
export(String, FILE) var path
export var can_nav_left = true
export var can_nav_right = true
export var can_nav_up = true
export var can_nav_down = true
export var hide_me_from_map = false
export var has_mole_memory = false
export var has_fish_memory = false
export var has_baba_memory = false
export var has_crypt_key = false
export var has_spore_key = false
export var has_phishing_key = false
export var has_crypt_door = false
export var has_spore_door = false
export var has_phishing_door = false
export var has_angel_statue = false
export var kill_after_glitch = false
export var has_angel_egg = 0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.