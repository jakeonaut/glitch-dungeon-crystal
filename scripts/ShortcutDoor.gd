extends "Door.gd"

export var memory_str = ""
export(String, "anglerShortcut", "babaShortcut", "claydolShortcut", "priestessShortcut") var starting_glitch_type

func _ready():
    if global.memory.has(memory_str) and global.memory[memory_str]:
        yield(get_tree().create_timer(0.5), "timeout")
        level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
        visible = true
    else:
        visible = false

    if global.demo_mode:
        self.path = "res://levels/EndlessFantasy/gd1/00000EndOfDemo.tscn"