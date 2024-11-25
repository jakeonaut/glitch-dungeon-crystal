extends Spatial

onready var glitchHermitCrab = weakref(get_node("GlitchHermitCrab"))
onready var hermitCrabShell = weakref(get_node("HermitCrabShell"))
var glitchHermitCrabRes = preload("res://sceneObjects/Enemies/GlitchHermitCrab.tscn")
var hermitShellRes = preload("res://sceneObjects/Enemies/HermitCrabShell.tscn")
var spawn_origin = null

func _ready():
  set_process(true)

func _process(_delta):
  if spawn_origin == null:
    spawn_origin = self.global_transform.origin

  tryRespawnMyBabies()

func dieOffscreen():
  if glitchHermitCrab.get_ref() != null:
    glitchHermitCrab.get_ref().queue_free()
  glitchHermitCrab = null
  if hermitCrabShell.get_ref() != null:
    hermitCrabShell.get_ref().queue_free()
  hermitCrabShell = null

func tryRespawnMyBabies():
  if glitchHermitCrab == null or glitchHermitCrab.get_ref() == null:
    var newGlitchHermitCrab = glitchHermitCrabRes.instance()
    self.add_child(newGlitchHermitCrab)
    newGlitchHermitCrab.global_transform.origin = self.global_transform.origin
    glitchHermitCrab = weakref(newGlitchHermitCrab)

  if hermitCrabShell == null or hermitCrabShell.get_ref() == null:
    var newHermitCrabShell = hermitShellRes.instance()
    self.add_child(newHermitCrabShell)
    newHermitCrabShell.global_transform.origin = self.global_transform.origin
    hermitCrabShell = weakref(newHermitCrabShell)
    hermitCrabShell.get_ref().visible = not glitchHermitCrab.get_ref().visible
