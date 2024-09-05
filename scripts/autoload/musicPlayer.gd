extends Node

onready var tween_out = get_node("Tween")
export var transition_duration = 3.00
export var transition_type = 1 # TRANS_SINE

onready var windPlayer = get_node("WindPlayer")
onready var restZonePlayer = get_node("RestZonePlayer")
onready var titleThemePlayer = get_node("TitleThemePlayer")
onready var wakeupPlayer = get_node("WakeupPlayer")
onready var grannyPlayer = get_node("GrannyPlayer")
onready var longAdventureThemePlayer = get_node("LongAdventureThemePlayer")
onready var priestessPlayer = get_node("PriestessThemePlayer")
onready var dungeonThemePlayer = get_node("DungeonThemePlayer")
onready var dungeonThemePlayer2 = get_node("DungeonThemePlayer2")
onready var debugThemePlayer = get_node("DebugThemePlayer")
onready var casinoThemePlayer = get_node("CasinoThemePlayer")
onready var realizationThemePlayer = get_node("RealizationThemePlayer")
onready var suburbThemePlayer = get_node("SuburbThemePlayer")
onready var swampThemePlayer = get_node("SwampThemePlayer")
onready var poisonThemePlayer = get_node("PoisonThemePlayer")
onready var oceanThemePlayer = get_node("OceanThemePlayer")
onready var exploreThemePlayer = get_node("ExploreThemePlayer")
onready var goddessThemePlayer = get_node("GoddessThemePlayer")
onready var townThemePlayer = get_node("TownThemePlayer")
onready var bossThemePlayer = get_node("BossThemePlayer")
onready var crystalThemePlayer = get_node("CrystalThemePlayer")
onready var continueThemePlayer = get_node("ContinueThemePlayer")

onready var leavesSound = get_node("Sounds/LeavesSound")

onready var treasureJingle = get_node("TreasureJingle")

var initial_volume_dbs = {}

var currentlyPlayingTheme = null
var default_song_pitch = 1.0

func _ready():
    set_process(true)

func _process(delta):
    delta = delta * global.time_dilation_multiplier
    if did_play_treasure_jingle and not treasureJingle.is_playing():
        did_play_treasure_jingle = false
        if restartPlayingTheme != null:
            tryToPlay(restartPlayingTheme)
            currentlyPlayingTheme = restartPlayingTheme
            restartPlayingTheme = null
        
func tryToPlay(stream_player):
    if global.memory["stopAllMusic"]: return
    # if not initial_volume_dbs.has(stream_player.name):
    #     initial_volume_dbs[stream_player.name] = stream_player.volume_db
        
    if stream_player.name == null:
        return

    if stream_player.is_playing(): return
    stopAll()
    fade_in(stream_player)
        
func fade_out(stream_player):
    stream_player.stop()
    # if not stream_player.is_playing():
    #     return

    # # tween music volume down to -80
    # tween_out.interpolate_property(stream_player, "volume_db", initial_volume_dbs[stream_player.name], -80, transition_duration, transition_type, Tween.EASE_IN, 0)
    # tween_out.start()
    # # when the tween ends, the music will be stopped
    
func fade_in(stream_player):
    stream_player.play()
    
    # if currentlyPlayingTheme != null:
    #     # tween music volume up to proper volume
    #     stream_player.volume_db = -80
    #     tween_out.interpolate_property(stream_player, "volume_db", -80, initial_volume_dbs[stream_player.name], transition_duration, transition_type, Tween.EASE_IN, 0)
    #     tween_out.start()
    #     # when the tween ends, the music will be stopped
    currentlyPlayingTheme = stream_player

func _on_TweenOut_tween_completed(object, _key):
    print("tween out completed: " + str(object.name))
    # stop the music -- otherwise it continues to run at silent volume
    object.stop()
    object.pitch_scale = 1.0

func stopAll():
    fade_out(longAdventureThemePlayer)
    fade_out(windPlayer)
    fade_out(restZonePlayer)
    fade_out(grannyPlayer)
    fade_out(priestessPlayer)
    fade_out(wakeupPlayer)
    fade_out(titleThemePlayer)
    fade_out(dungeonThemePlayer)
    fade_out(dungeonThemePlayer2)
    fade_out(debugThemePlayer)
    fade_out(casinoThemePlayer)
    fade_out(realizationThemePlayer)
    fade_out(poisonThemePlayer)
    fade_out(suburbThemePlayer)
    fade_out(swampThemePlayer)
    fade_out(oceanThemePlayer)
    fade_out(exploreThemePlayer)
    fade_out(goddessThemePlayer)
    fade_out(townThemePlayer)
    fade_out(bossThemePlayer)
    fade_out(crystalThemePlayer)
    fade_out(continueThemePlayer)
    if currentlyPlayingTheme != null and currentlyPlayingTheme.is_playing():
        fade_out(currentlyPlayingTheme)
    currentlyPlayingTheme = null

var did_play_treasure_jingle = false
var restartPlayingTheme = null
func playTreasureJingle(volume_db):
    restartPlayingTheme = currentlyPlayingTheme
    stopAll()
    did_play_treasure_jingle = true
    treasureJingle.volume_db = volume_db
    treasureJingle.play()


func conductFromScenePath(path):
    if global.memory["stopAllMusic"] or path.find("000Intro") > 0:
        stopAll()
        return
    changeSongPitch(1.0)
    if path.find("RestZone") > 0 or path.find("TowerHub") > 0:
        tryToPlay(restZonePlayer)
    elif path.find("preBossRoom") > 0:
        tryToPlay(windPlayer)
    elif path.find("HighPriestessRoom") > 0:
        tryToPlay(crystalThemePlayer) # bossThemePlayer)
    elif path.find("gd1CrystalTower") > 0:
        tryToPlay(debugThemePlayer)
    elif path.find("MainMenu") > 0 or path.find("Pastoral") > 0:
        if global.memory["clean_crystals"] > 0 or global.memory.has("spellbookPage"):
            tryToPlay(titleThemePlayer)
        else:
            tryToPlay(grannyPlayer)
            # changeSongPitch(0.9)
            # default_song_pitch = 0.9
            return
    elif path.find("gd1GrandmaVillage") > 0:
        tryToPlay(grannyPlayer)
    elif path.find("StoryHook") > 0 or path.find("NullificationPurgatory") > 0:
        tryToPlay(poisonThemePlayer)
        changeSongPitch(1.0)
        default_song_pitch = 1.0
    elif path.find("Haven2") > 0:
        tryToPlay(dungeonThemePlayer)
        changeSongPitch(0.5)
        default_song_pitch = 0.5
        return
    elif path.find("Haven") > 0:
        tryToPlay(crystalThemePlayer)
    elif path.find("000IntroCutscene") > 0:
        tryToPlay(priestessPlayer)
        changeSongPitch(0.63)
        default_song_pitch = 0.63
        return
    elif path.find("Goddess") > 0 or path.find("Psychic") > 0 or path.find("002PathToSacredDoors") > 0 or path.find("003SacredDoorsHubWorld") > 0:
        tryToPlay(goddessThemePlayer)
    elif path.find("001CozyHome") > 0:
        tryToPlay(wakeupPlayer)
    elif path.find("Casino") > 0 or path.find("Medievel") > 0 or path.find("Piranesi") > 0 or path.find("Grimoire") > 0:
        tryToPlay(casinoThemePlayer)
    elif path.find("Suburb") > 0 or path.find("Poison") > 0 or path.find("Toxic") > 0:
        tryToPlay(suburbThemePlayer)
    elif path.find("Ocean") > 0:
        tryToPlay(oceanThemePlayer)
    elif path.find("Desert") > 0 or path.find("ShiftingSand") > 0:
        tryToPlay(exploreThemePlayer)
    elif path.find("Swamp") > 0 or path.find("Village") > 0:
        tryToPlay(swampThemePlayer)
    elif path.find("EndOfDemo") > 0:
        tryToPlay(titleThemePlayer)
    elif path.find("005DebugTown") > 0:
        tryToPlay(dungeonThemePlayer)
    elif path.find("001Your") > 0  or path.find("gd1"):
        tryToPlay(dungeonThemePlayer2)
    else:
        self.stopAll()
    changeSongPitch(1.0)
    default_song_pitch = 1.0

    if path.find("__introCutscene") > 0:
        changeSongPitch(2.0)

func changeSongPitch(new_pitch):
    # TODO(jaketrower): reset pitches when you play them
    if currentlyPlayingTheme:
        currentlyPlayingTheme.pitch_scale = new_pitch
    
