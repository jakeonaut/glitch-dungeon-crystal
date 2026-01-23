extends Spatial

onready var bugHead = get_node("GlitchFlyingBugHead")
onready var body1 = get_node("GlitchFlyingBugBody1")
# onready var body2 = get_node("GlitchFlyingBugBody2")
# onready var scoochSound1 = get_node("Sounds/ScoochSound1")
# onready var scoochSound2 = get_node("Sounds/ScoochSound2")
onready var playerActivationArea = get_node("PlayerActivationArea")

var am_i_dying = false
onready var aniPlayer = get_node("AnimationPlayer")
onready var level = get_tree().get_root().get_node("Game/Viewport/level")

export(int, "NORMAL", "FLOOR", "FEATHER", "INVISIBLE", "LADDER", "WALK_THROUGH_WALLS") var starting_glitch_type

# Called when the node enters the scene tree for the first time.
func _ready():
    # ._ready() implicit

    aniPlayer.play("wiggle")

    yield(TempTimer.idle_frame(self), "timeout")
    yield(TempTimer.idle_frame(self), "timeout")
    
    # bugHead.myOtherSprite.set_material_override(bugHead.myOtherSprite.get_material_override().duplicate())
    # body1.myOtherSprite.set_material_override(body1.myOtherSprite.get_material_override().duplicate())
    # body1.get_node("WingSprite1").set_material_override(body1.get_node("WingSprite1").get_material_override().duplicate())
    # body1.get_node("WingSprite2").set_material_override(body1.get_node("WingSprite2").get_material_override().duplicate())
    # body2.myOtherSprite.set_material_override(body1.myOtherSprite.get_material_override())

    bugHead.should_collide_floor = false
    bugHead.should_collide_ceil = false
    bugHead.should_only_do_middle_sensor = true
    bugHead.should_do_simple_sensor_probe = true
    bugHead.glitch_form = global.GlitchForm.FEATHER
    body1.should_collide_floor = false
    body1.should_collide_ceil = false
    body1.should_only_do_middle_sensor = true
    body1.should_do_simple_sensor_probe = true
    body1.glitch_form = global.GlitchForm.FEATHER
    # body2.should_collide_floor = false
    # body2.should_collide_ceil = false
    # body2.should_only_do_middle_sensor = true
    # body2.should_do_simple_sensor_probe = true
    # body2.glitch_form = global.GlitchForm.FEATHER

    var levelTiles = body1.getLevelTiles()
    if starting_glitch_type == global.GlitchForm.NORMAL:
        body1.myOtherSprite.changeSpriteColorPalette(levelTiles.grey_palette, "grey_palette")
        body1.get_node("WingSprite1").changeSpriteColorPalette(levelTiles.grey_palette, "grey_palette")
        body1.get_node("WingSprite2").changeSpriteColorPalette(levelTiles.grey_palette, "grey_palette")
    elif starting_glitch_type == global.GlitchForm.FLOOR:
        body1.myOtherSprite.changeSpriteColorPalette(levelTiles.red_palette, "red_palette")
        body1.get_node("WingSprite1").changeSpriteColorPalette(levelTiles.red_palette, "red_palette")
        body1.get_node("WingSprite2").changeSpriteColorPalette(levelTiles.red_palette, "red_palette")
    elif starting_glitch_type == global.GlitchForm.FEATHER:
        body1.myOtherSprite.changeSpriteColorPalette(levelTiles.green_palette, "green_palette")
        body1.get_node("WingSprite1").changeSpriteColorPalette(levelTiles.green_palette, "green_palette")
        body1.get_node("WingSprite2").changeSpriteColorPalette(levelTiles.green_palette, "green_palette")
    elif starting_glitch_type == global.GlitchForm.INVISIBLE:
        body1.myOtherSprite.changeSpriteColorPalette(levelTiles.black_palette, "black_palette")
        body1.get_node("WingSprite1").changeSpriteColorPalette(levelTiles.black_palette, "black_palette")
        body1.get_node("WingSprite2").changeSpriteColorPalette(levelTiles.black_palette, "black_palette")
    elif starting_glitch_type == global.GlitchForm.LADDER:
        body1.myOtherSprite.changeSpriteColorPalette(levelTiles.yellow_palette, "yellow_palette")
        body1.get_node("WingSprite1").changeSpriteColorPalette(levelTiles.yellow_palette, "yellow_palette")
        body1.get_node("WingSprite2").changeSpriteColorPalette(levelTiles.yellow_palette, "yellow_palette")
    elif starting_glitch_type == global.GlitchForm.WALK_THROUGH_WALLS:
        body1.myOtherSprite.changeSpriteColorPalette(levelTiles.white_palette, "white_palette")
        body1.get_node("WingSprite1").changeSpriteColorPalette(levelTiles.white_palette, "white_palette")
        body1.get_node("WingSprite2").changeSpriteColorPalette(levelTiles.white_palette, "white_palette")

func _process(delta):
    # ._process(delta) implicit
    
    delta = delta * global.time_dilation_multiplier
    aniPlayer.playback_speed = global.time_dilation_multiplier

    playerActivationArea.global_transform.origin.x = bugHead.global_transform.origin.x

    #############################
    # Only allow collision for whichever body part is about to hit the wall...
    #############################
    if bugHead.walk_direction == body1.walk_direction:
        bugHead.should_collide_with_walls = true
        body1.should_collide_with_walls = false
    #     body2.should_collide_with_walls = false
    elif bugHead.walk_direction != body1.walk_direction:
        bugHead.should_collide_with_walls = false
        body1.should_collide_with_walls = true
        # body2.should_collide_with_walls = false
    # elif bugHead.walk_direction == body1.walk_direction and body1.walk_direction != body2.walk_direction:
    #     bugHead.should_collide_with_walls = false
    #     body1.should_collide_with_walls = false
    #     body2.should_collide_with_walls = true
    # else:
    #     # should theoretically never get here...
    #     bugHead.should_collide_with_walls = true
    #     body1.should_collide_with_walls = true
    #     body2.should_collide_with_walls = true

    #############################
    # NEED TO MAKE SURE HEAD IS BEFORE BODY1 AND BODY1 IS BEFORE BODY2
    # but not too far ahead....
    #############################
    if bugHead.walk_direction.x == 1 and body1.walk_direction.x == 1:
        if bugHead.global_transform.origin.x < body1.global_transform.origin.x + 1:
            body1.slime_state_timer = 0
            body1.slime_state = body1.SlimeState.IDLE
        if bugHead.global_transform.origin.x > body1.global_transform.origin.x + 2:
            body1.slime_state_timer = 0
            body1.slime_state = body1.SlimeState.WALK
    if bugHead.walk_direction.x == -1 and body1.walk_direction.x == -1:
        if bugHead.global_transform.origin.x > body1.global_transform.origin.x - 1:
            body1.slime_state_timer = 0
            body1.slime_state = body1.SlimeState.IDLE
        if bugHead.global_transform.origin.x < body1.global_transform.origin.x - 2:
            body1.slime_state_timer = 0
            body1.slime_state = body1.SlimeState.WALK

    # if bugHead.walk_direction == 1 and body2.walk_direction == 1:
    #     if bugHead.global_transform.origin.x < body2.global_transform.origin.x + 2.5:
    #         body2.slime_state_timer = 0
    #         body2.slime_state = body2.SlimeState.IDLE
    #     if bugHead.global_transform.origin.x > body2.global_transform.origin.x + 3.5:
    #         body2.slime_state_timer = 0
    #         body2.slime_state = body2.SlimeState.WALK
    # if bugHead.walk_direction == -1 and body2.walk_direction == -1:
    #     if bugHead.global_transform.origin.x > body2.global_transform.origin.x - 2.5:
    #         body2.slime_state_timer = 0
    #         body2.slime_state = body2.SlimeState.IDLE
    #     if bugHead.global_transform.origin.x < body2.global_transform.origin.x - 3.5:
    #         body2.slime_state_timer = 0
    #         body2.slime_state = body2.SlimeState.WALK



    bugHead.tryRemoveEnemiesGroup()
    bugHead.mySprite.visible = false
    # if level.player.glitch_form == starting_glitch_type:
    #     body1.tryRemoveEnemiesGroup()
    #     body1.myOtherSprite.visible = true
    #     body1.mySprite.visible = false
    #     body2.tryRemoveEnemiesGroup()
    #     body2.myOtherSprite.visible = true
    #     body2.mySprite.visible = false
    # else:
    body1.tryAddEnemiesGroup()
    body1.myOtherSprite.visible = false
    body1.mySprite.visible = true
    # body2.tryAddEnemiesGroup()
    # body2.myOtherSprite.visible = false
    # body2.mySprite.visible = true

    bugHead.get_node("AntennaSprite").flip_h = bugHead.myOtherSprite.flip_h
    body1.get_node("WingSprite1").flip_h = body1.myOtherSprite.flip_h
    body1.get_node("WingSprite2").flip_h = body1.myOtherSprite.flip_h

    if am_i_dying:
        return

# @override
func passiveActivate(_delta, _is_player, _is_local_broom = false):
    if am_i_dying: return

func processDeath():
    pass
        
# @override
func ouchies(_broom_origin):
    if am_i_dying: return
        
    am_i_dying = true
    
    # if smallInteractionArea.is_in_group("enemies"):
    #     smallInteractionArea.remove_from_group("enemies")

    pass

func playerActivationAreaPassiveActivate():
    bugHead.am_i_really_in_range_of_player = true
    body1.am_i_really_in_range_of_player = true
    # body2.am_i_really_in_range_of_player = true
