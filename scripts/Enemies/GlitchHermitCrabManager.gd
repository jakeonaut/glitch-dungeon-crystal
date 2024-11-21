extends Spatial

onready var glitchHermitCrab = weakref(get_node("GlitchHermitCrab"))
onready var hermitCrabShell = weakref(get_node("HermitCrabShell"))
var glitchHermitCrabRes = preload("res://sceneObjects/Enemies/GlitchHermitCrab.tscn")
var hermitShellRes = preload("res://sceneObjects/Enemies/HermitCrabShell.tscn")

func _ready():
  set_process(true)

func _process(_delta):
  if glitchHermitCrab.get_ref() == null:
    var newGlitchHermitCrab = glitchHermitCrabRes.instance()
    self.add_child(newGlitchHermitCrab)
    newGlitchHermitCrab.global_transform.origin = self.global_transform.origin
    glitchHermitCrab = weakref(newGlitchHermitCrab)

  if hermitCrabShell.get_ref() == null:
    var newHermitCrabShell = hermitShellRes.instance()
    self.add_child(newHermitCrabShell)
    newHermitCrabShell.global_transform.origin = self.global_transform.origin
    hermitCrabShell = weakref(newHermitCrabShell)