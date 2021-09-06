extends InterpolatedCamera

var initial_z
onready var actual_target = get_node(target) 
onready var initial_target = get_node(target)

func _ready():
    initial_z = global_transform.origin.z

func _process(delta):
    global_transform.origin.z = initial_z
    # d=√((x_2-x_1)²+(y_2-y_1)²)
    var distance = global_transform.origin.distance_to(actual_target.global_transform.origin)

    if distance > 19.7:
        set_interpolation_enabled(true)
        set_speed(5)
    elif distance > 19.6:
        set_interpolation_enabled(true)
        set_speed(4)
    elif distance > 19.5:
        set_interpolation_enabled(true)
        set_speed(3)
    elif distance > 19.4:
        set_interpolation_enabled(true)
        set_speed(2)
    elif distance > 19.33:
        set_interpolation_enabled(true)
        set_speed(1)
    elif distance < 19.26 and global.activeInteractor == null:
        set_interpolation_enabled(false)

    if global.activeInteractor != null:
        actual_target = global.activeInteractor.get_node("../..")
        set_target(actual_target)
        # interpolation = A + (B - A) * t
        self.size = self.size + (12 - self.size) * (delta*5)
        set_speed(4)
        set_interpolation_enabled(true)
    else:
        actual_target = initial_target
        set_target(actual_target)
        self.size = self.size + (15 - self.size) * (delta*5)