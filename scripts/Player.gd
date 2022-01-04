extends "PlayerGameMover.gd"

onready var pauseMenu = get_node("PauseMenu/MenuBox") if has_node("PauseMenu/MenuBox") else null
onready var hurtSound = get_node("Sounds/HurtSound")
onready var hurt2Sound = get_node("Sounds/HurtSound2")

onready var broom = get_node("CameraY/broom")
onready var broomSound = get_node("Sounds/BroomSound")

var grey_palette = preload("res://assets/palettes/grey_palette.png")
var red_palette = preload("res://assets/palettes/red_palette.png")
var green_palette = preload("res://assets/palettes/green_palette.png")
var black_palette = preload("res://assets/palettes/black_palette.png")
var yellow_palette = preload("res://assets/palettes/yellow_palette.png")
var white_palette = preload("res://assets/palettes/white_palette.png")

var sprite_reset_timer = 0
var sprite_reset_limit = 3
var cameraRotationCounter = 0
var glitch_death_timer = 0

func _ready():
    grav = 60
    set_process_input(true)
    set_process(true)
    set_physics_process(true)
    if pauseMenu: pauseMenu.hide()

func applyNextGlitch():
    applyGlitch(getNextGlitch())

func applyPrevGlitch():
    applyGlitch(getPrevGlitch())

func applyGlitch(glitch):
    if glitch == GlitchForm.NORMAL: normalGlitch()
    if glitch == GlitchForm.FLOOR: floorGlitch()
    if glitch == GlitchForm.FEATHER: featherGlitch()
    if glitch == GlitchForm.LADDER: ladderGlitch()
    if glitch == GlitchForm.INVISIBLE: invisibleGlitch()
    if glitch == GlitchForm.WALK_THROUGH_WALLS: walkThroughWallsGlitch()

func changeSpriteColorPalette(palette):
    var material = mySprite.material_override
    if material is ShaderMaterial:
        material.set_shader_param("target_palette", palette)
        mySprite.material_override = material

func normalGlitch():
    glitch_form = GlitchForm.NORMAL
    level.normalGlitch()
    changeSpriteColorPalette(grey_palette)
    # mySprite.setNormalClothes()

func floorGlitch():
    glitch_form = GlitchForm.FLOOR
    level.floorGlitch()
    changeSpriteColorPalette(red_palette)
    # mySprite.setBugCatcherCostume()

func featherGlitch():
    glitch_form = GlitchForm.FEATHER
    level.featherGlitch()
    changeSpriteColorPalette(green_palette)
    # mySprite.setMothCostume()

func ladderGlitch():
    glitch_form = GlitchForm.LADDER
    level.ladderGlitch()
    changeSpriteColorPalette(yellow_palette)
    # mySprite.setLuckyCatCostume()

func invisibleGlitch():
    glitch_form = GlitchForm.INVISIBLE
    level.invisibleGlitch()
    changeSpriteColorPalette(black_palette)
    # mySprite.setClericCostume()

func walkThroughWallsGlitch():
    glitch_form = GlitchForm.WALK_THROUGH_WALLS
    level.walkThroughWallsGlitch()
    changeSpriteColorPalette(white_palette)
    # mySprite.setNightgown()

func wearCostume(costume):
    global.memory["player_costume"] = costume
    
func _process(delta):
    # ._process(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500

    if physics_state == PhysicsState.GLITCH_DYING:
        global.pauseGame = true
        lv = Vector3(0, 0, 0)
        dir = Vector3(0, 0, 0)
        glitch_death_timer += (delta*22)

        var material = level.glitchScreenEffect.get_material()
        if material is ShaderMaterial:
            material.set_shader_param("shake_color_rate", 0.01 + (glitch_death_timer*.002))
        if glitch_death_timer >= 10:
            get_tree().get_root().get_node("Game/Viewport/level").tryToRespawn()
            self.physics_state = PhysicsState.NORMAL
    else:
        if glitch_death_timer != 0:
            global.pauseGame = false
            glitch_death_timer += (delta*22)
            applyGlitchDeathEffects(abs(glitch_death_timer))
            if glitch_death_timer >= 40:
                musicPlayer.changeSongPitch(1.0)
                level.glitchScreenEffect.visible = false
                glitch_death_timer = 0
                var my_material = mySprite.get_material_override()
                if my_material is ShaderMaterial:
                    my_material.set_shader_param("enable_glitch", false)
            
        if Input.is_action_just_pressed("ui_accept") and not global.pauseMoveInput:
            if not global.pauseGame:
                if pauseMenu: pauseMenu.show()
                global.pauseGame = true
            else:
                if pauseMenu: pauseMenu.hide()
                global.pauseGame = false

    if Input.is_action_just_pressed("ui_glitch_next"):
        applyNextGlitch()
    if Input.is_action_just_pressed("ui_glitch_prev"):
        applyPrevGlitch()
        
    var DEATH_MARGIN = 5
    if self.getCamera().rightmost_x > -999:
        if global_transform.origin.x > self.getCamera().rightmost_x + DEATH_MARGIN or \
        global_transform.origin.x < self.getCamera().leftmost_x - DEATH_MARGIN or \
        global_transform.origin.y > self.getCamera().topmost_y + DEATH_MARGIN or \
        global_transform.origin.y < self.getCamera().botmost_y - DEATH_MARGIN:
            #print(str(global_transform.origin.x) + ", " + str(global_transform.origin.y) + " || " + str(self.getCamera().rightmost_x) + ", " + str(self.getCamera().leftmost_x) + ", " + str(self.getCamera().topmost_y) + ", " + str(self.getCamera().botmost_y))
            self.respawn()

    doBroomLogic(delta)
    #tryRotateCamera(delta)

func applyGlitchDeathEffects(x):
    if x < 0 or x > 20:
        musicPlayer.changeSongPitch(abs(sin(x*.05)+.02))
    if x > 10:
        var my_material = mySprite.get_material_override()
        if my_material is ShaderMaterial:
            my_material.set_shader_param("enable_glitch", false)

    var material = level.glitchScreenEffect.get_material()
    if material is ShaderMaterial:
        material.set_shader_param("shake_power", -.00005*pow(x-25, 2) + .005)
        material.set_shader_param("shake_color_rate", -.0001*pow(x-25, 2) + .005)

func _physics_process(delta):
    # ._process_physics(delta) #NOTE: this super method is called automatically 
    # https://github.com/godotengine/godot/issues/6500
    pass

func tryRotateCamera(delta):
    pass

func isOnSavePoint():
    if not global.memory.has("active_save_point_x"):
        return false
        
    var origin = self.global_transform.origin
    var x = origin.x
    var y = origin.y
    var z = origin.z
    return int(round(x)) == int(round(global.memory["active_save_point_x"])) and \
           int(round(y)) == int(round(global.memory["active_save_point_y"])) and \
           int(round(z)) == int(round(global.memory["active_save_point_z"]))

# @override
func tryDieToEnemy(delta):
    if glitch_form != GlitchForm.INVISIBLE and not transitioning and \
       physics_state != PhysicsState.GLITCH_DYING and not isOnSavePoint():
        if randi() % 3 == 0:
            hurt2Sound.pitch_scale = rand_range(0.8, 1.5) 
            hurt2Sound.play()
        else:
            hurtSound.pitch_scale = rand_range(0.8, 1.5)
            hurtSound.play()
        bumpSound.play()
        global.pauseGame = true
        global.pauseMoveInput = true
        global.isRespawning = true
        level.glitchScreenEffect.visible = true
        var material = level.glitchScreenEffect.get_material()
        if material is ShaderMaterial:
            material.set_shader_param("shake_power", 0.01)
            material.set_shader_param("shake_color_rate", 0.01)
        var my_material = mySprite.get_material_override()
        if my_material is ShaderMaterial:
            my_material.set_shader_param("enable_glitch", true)

        physics_state = PhysicsState.GLITCH_DYING
        glitch_death_timer = 0

        musicPlayer.changeSongPitch(rand_range(0.8, 1.5))

func doBroomLogic(delta):
    if broom_state != 0:
        broom_timer += (delta*22)
        if broom_timer >= broom_time_limit:
            broom_timer = 0
            #var broom_mesh = broom.get_node("broom")
            var broom_sprite = broom.get_node("Sprite3D")
            if broom_state == 1:
                #broom_mesh.rotation_degrees.z = 10
                broom_sprite.updateBaseFrame(1, 0)
                broom_state = 2
            elif broom_state == 2:
                #broom_mesh.translation.x = 5
                broom_sprite.translation.x = -3
                broom_sprite.updateBaseFrame(0, 0)
                broom_state = 3
                broomSound.play()
            elif broom_state == 3:
                broom_sprite.updateBaseFrame(1, 0)
                broom_state = 4
            elif broom_state == 4:
                broom_sprite.translation.x = 0.5
                broom_state = -2
                broom.visible = false
            elif broom_state < 0:
                broom_state += 1
                if broom_state == 0:
                    can_broom = true

func tryBroom():
    if can_broom:        
        var broom_sprite = broom.get_node("Sprite3D")
        # if mySprite.isPlayerFacingDown():
        #     broom.rotation_degrees.y = 0
        #     broom_sprite.flip_h = false
        # elif mySprite.isPlayerFacingRight():
        #     broom.rotation_degrees.y = 90
        #     broom_sprite.flip_h = false
        # elif mySprite.isPlayerFacingUp():
        #     broom.rotation_degrees.y = 180
        #     broom_sprite.flip_h = true
        # elif mySprite.isPlayerFacingLeft():
        #     broom.rotation_degrees.y = 270
        #     broom_sprite.flip_h = true

        broom.visible = true
        broom_state = 1
        broom_timer = 0
        can_broom = false
        broom_sprite.updateBaseFrame(1, 1)
        broom_sprite.max_frames = 1
        broomSound.play()
        pass # on_ground = false

func faceDown():
    pass # mySprite.faceDown()
