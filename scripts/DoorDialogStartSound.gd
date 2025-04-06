extends AudioStreamPlayer

onready var textBox = get_node("..")
onready var textBoxContainer = get_node("../..")
onready var door = get_node("../../../..")
onready var npc = get_node("../../..")

func _ready():
  set_process(true)
        
func preActivateScript(): #DEFUNCT FOR START AND DIALOG SOUND, ONLY FOR ABORT SOUND
    # OVERRIDE ME
    pass
    
func activateScript():
  if door.key_type == null:
    door.key_type = global.KeyItem.NORMAL

  if door.is_locked:
    if door.locked_to_monsters or door.locked_to_weakeye:
      npc.textBoxContainer.bbText = tr("NPC.Door.2") % tr("NPC.Crystal.NULL")
    elif door.key_type == global.KeyItem.NORMAL:
      # var num_keys = global.memory["key"] if global.memory.has("key") else null
      if door.is_locked:
        npc.textBoxContainer.bbText = tr("NPC.Door.1") % str(door.num_keys_unlock)
        # if num_keys == null or num_keys == 0:
          
        #   if door.num_keys_unlock == 1:
        #     npc.textBoxContainer.bbText = "•locked,\nneeds a key"
        #   else:
        #     npc.textBoxContainer.bbText = "•locked,\nneeds " + str(door.num_keys_unlock) + " keys"
        # elif num_keys != null and num_keys < door.num_keys_unlock:
        #   npc.textBoxContainer.bbText = "•locked,\nneeds " + str(door.num_keys_unlock - num_keys) + " [wave]more[/wave] keys\n(" + str(door.num_keys_unlock) +" total)"
        # else:
        #   npc.textBoxContainer.bbText = "•"
    else:
      var x_more_crystals = door.num_keys_unlock - global.memory["clean_crystals"]
      var key_name = door.getKeyName(x_more_crystals)
      if door.key_type == global.KeyItem.CRYSTAL or door.key_type == global.KeyItem.ZONE_CRYSTAL:
        npc.textBoxContainer.bbText = tr("NPC.Door.2") % str(key_name)
      else:
        npc.textBoxContainer.bbText = "•locked,\nneeds [wave]" + key_name + "[/wave]"
      npc.textBox.can_camera_zoom = false
    npc.textBoxContainer.setVars()
        
func isActive(_debug=false):
  # OVERRIDE ME... if you dare
  return true
