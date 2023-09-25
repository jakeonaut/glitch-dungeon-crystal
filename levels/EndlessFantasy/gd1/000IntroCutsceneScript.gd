extends "../../../scripts/levelScript.gd"


var roomPath = "res://levels/EndlessFantasy/gd1/000PastoralScene.tscn"
func setUpRoomInitializationOverride():
    player.pauseSelf = true

var door_timer = 0
var door_time_limit = 360
var has_activated_door = false
onready var door = get_node("Door")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if not has_activated_door:
        door_timer += (delta * 22)
        if door_timer >= door_time_limit:
            door.canPlayDoorSound = false
            door.activate(true)
            has_activated_door = true
