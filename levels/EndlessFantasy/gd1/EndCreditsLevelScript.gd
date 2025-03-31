extends "../../../scripts/levelScript.gd"

onready var label3d = get_node("Label3D")

# @override
func setUpRoomInitializationOverride():
    label3d.text = tr("EndCredits.FULL")

# @override
func _process(delta):
    if global.isPauseMenuOpen:
        return
    label3d.global_transform.origin.y += (delta*2)