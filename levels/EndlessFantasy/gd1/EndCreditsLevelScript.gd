extends "../../../scripts/levelScript.gd"

onready var endCreditsNPC = get_node("EndCreditsNPC")

# @override
func setUpRoomInitializationOverride():
    pass

# @override
func _process(delta):
    if global.activeInteractor == null:
        endCreditsNPC.activate(true)
    
