extends Area

var playerArea = null
func getPlayerArea():
    if playerArea == null:
        playerArea = get_tree().get_root().get_node("Game/Viewport/level").player.get_node("InteractionArea")
    return playerArea

var hasActivated = false

func _ready():
    set_process(true)
    self.visible = false
    
func _process(delta):
    if touchingPlayer():
        passiveActivate(delta, true)
            
func touchingPlayer():
    var areas = get_overlapping_areas()
    for area in areas:
        if area == getPlayerArea():
            return true
    return false
    
# TO BE OVERRIDDEN
func passiveActivate(delta, _is_player):
    if not hasActivated:
        var npc = get_parent().get_node("NPC")
        npc.visible = false
        hasActivated = true