extends Spatial


var broom_active_timer = 0
var broom_active_time_limit = 10 
var my_broom_owner = null
onready var broomSound = get_node("BroomSound")
var broomSoundTimer = 0
var broomSoundTimeLimit = 5
var broomSoundCounter = 0
var broomSoundCountLimit = 2
var smokeCloudRes = preload("res://sceneObjects/SmokeCloud.tscn")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")
onready var myArea = get_node("Area")


# Called when the node enters the scene tree for the first time.
func _ready():
    set_process(true)
    broomSound.play()
    broomSoundCounter += 1


func _process(delta):
    broom_active_timer += (delta*22)
    if broom_active_timer >= broom_active_time_limit:
        broom_active_timer = 0
        if my_broom_owner: my_broom_owner.broomStop()
        visible = false
        summonSmokeClouds()
        cleanUpGlitches()
        
    if visible:
        broomSoundTimer += (delta*22)
        if broomSoundTimer >= broomSoundTimeLimit:
            broomSoundTimer = 0
            if broomSoundCounter < broomSoundCountLimit:
                broomSound.play()
                broomSoundCounter += 1
    if not visible and not broomSound.is_playing():
        queue_free()
        
func summonSmokeClouds():
    for i in range(5):
        var newSmokeCloud = smokeCloudRes.instance()
        level.add_child(newSmokeCloud)
        newSmokeCloud.global_transform.origin.x = self.global_transform.origin.x + rand_range(-1, 1)
        newSmokeCloud.global_transform.origin.y = self.global_transform.origin.y + rand_range(-1, 1)
        newSmokeCloud.target_y = newSmokeCloud.global_transform.origin.y + rand_range(1, 3)
        
func cleanUpGlitches():
    var areas = myArea.get_overlapping_areas()
    for area in areas:
        if area.is_in_group("enemies") and area.has_method("isActive") and area.isActive():
            # TODO kill glitches or "free" them like glitch slug...
            pass
        # TODO clean up glitch tiles... set something in memory...

func isActive():
    return visible
