extends "../scripts/levelScript.gd"

var switch_glitch_timer = 0
var switch_glitch_time_limit = 15
var direction = -1

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # .process(delta) implicit
    # player.rotation_degrees.y += (delta)*direction
    # if player.rotation_degrees.y > 5:
    #     direction = -1
    # elif player.rotation_degrees.y < -5:
    #     direction = 1

    switch_glitch_timer += (delta*22)
    if switch_glitch_timer >= switch_glitch_time_limit:
        switch_glitch_timer = 0
        player.applyNextGlitch()

    if Input.is_action_just_pressed("ui_start"):
        switch_glitch_timer = -999999
        global.memory["current_glitch"] = global.GlitchForm.NORMAL
        player.normalGlitch()
        get_node("Door").is_on_main_menu = true
        get_node("Door").goThroughDoor(true)
