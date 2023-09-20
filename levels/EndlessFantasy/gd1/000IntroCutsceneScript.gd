extends "../../../scripts/levelScript.gd"


var roomPath = "res://levels/EndlessFantasy/gd1/000PastoralScene.tscn"
func setUpRoomInitializationOverride():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    if not transition.aniPlayer.assigned_animation != "really_really_long_fade_to":
        transition.really_really_long_fade_to(roomPath)
