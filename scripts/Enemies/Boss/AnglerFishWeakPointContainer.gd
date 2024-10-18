extends "../GlitchEnemy.gd"

var vulnerable = false
func _ready():
  pass

func isActive(_debug=false):
  return true

# @override
func glitchSetSpritesAndCollision():
  return false
