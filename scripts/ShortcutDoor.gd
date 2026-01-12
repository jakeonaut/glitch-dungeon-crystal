extends "Door.gd"

export var memory_str = ""
export(String, "anglerShortcut", "babaShortcut", "claydolShortcut", "priestessShortcut") var starting_glitch_type

func _ready():
    is_shortcut = true
    if memory_str == "":
        return
        
    if global.memory.has(memory_str) and global.memory[memory_str]:
        yield(get_tree().create_timer(0.5), "timeout")
        level.summonSmokeClouds(self.global_transform.origin, 3, true, true)
        visible = true

        if global.getLevelZoneThing("angel_statue") == null:
            global.setLevelZoneThing("angel_statue", [
                global.getDisplayTitle(level.getLevelZoneName(), level.getLevelName()),
                level.getLevelName()
            ])
    else:
        visible = false

    if global.demo_mode:
        self.path = "res://levels/EndlessFantasy/gd1/00000EndOfDemo.tscn"
    elif not global.memory["has_teleported"] and global.memory["has_map_item"]:
        self.path = "res://levels/EndlessFantasy/gd1TutorialDungeon/LiminalAngelFluteRoom.tscn"