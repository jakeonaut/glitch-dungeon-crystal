extends Node

onready var tween_out = get_node("Tween")
export var transition_duration = 3.00
export var transition_type = 1 # TRANS_SINE

onready var windPlayer = get_node("WindPlayer")
onready var restZonePlayer = get_node("RestZonePlayer")
onready var weirdRestZonePlayer = get_node("WeirdRestZonePlayer")
onready var titleThemePlayer = get_node("TitleThemePlayer")
onready var wakeupPlayer = get_node("WakeupPlayer")
onready var grannyPlayer = get_node("GrannyPlayer")
onready var croneThemePlayer = get_node("CroneThemePlayer")
onready var mainMenuPlayer = get_node("MainMenuPlayer")
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
onready var forestMarchThemePlayer = get_node("ForestMarchThemePlayer")
onready var oceanThemePlayer = get_node("OceanThemePlayer")
onready var exploreThemePlayer = get_node("ExploreThemePlayer")
onready var goddessThemePlayer = get_node("GoddessThemePlayer")
onready var dreamCityThemePlayer = get_node("DreamCityThemePlayer")
onready var primordialOozeThemePlayer = get_node("PrimordialOozeThemePlayer")
onready var townThemePlayer = get_node("TownThemePlayer")
onready var bossThemePlayer = get_node("BossThemePlayer")
onready var boss2ThemePlayer = get_node("Boss2ThemePlayer")
onready var crystalThemePlayer = get_node("CrystalThemePlayer")
onready var continueThemePlayer = get_node("ContinueThemePlayer")
onready var catacombThemePlayer = get_node("CatacombThemePlayer")

onready var leavesSound = get_node("Sounds/LeavesSound")

onready var treasureJingle = get_node("TreasureJingle")
onready var defeatBossJingle = get_node("DefeatBossJingle")

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
    if did_play_defeat_boss_jingle and not defeatBossJingle.is_playing():
        did_play_defeat_boss_jingle = false
        if restartPlayingTheme != null:
            tryToPlay(restartPlayingTheme)
            currentlyPlayingTheme = restartPlayingTheme
            restartPlayingTheme = null
            
        
func tryToPlay(stream_player):
    if global.userSettings["stopAllMusic"]: return
    # if not initial_volume_dbs.has(stream_player.name):
    #     initial_volume_dbs[stream_player.name] = stream_player.volume_db
        
    if stream_player.name == null:
        return

    if stream_player.is_playing(): return
    if did_play_treasure_jingle or did_play_defeat_boss_jingle:
        restartPlayingTheme = stream_player
        return
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
    fade_out(weirdRestZonePlayer)
    fade_out(grannyPlayer)
    fade_out(croneThemePlayer)
    fade_out(mainMenuPlayer)
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
    fade_out(boss2ThemePlayer)
    fade_out(crystalThemePlayer)
    fade_out(continueThemePlayer)
    fade_out(catacombThemePlayer)
    if currentlyPlayingTheme != null and currentlyPlayingTheme.is_playing():
        fade_out(currentlyPlayingTheme)
    currentlyPlayingTheme = null

var did_play_treasure_jingle = false
var restartPlayingTheme = null
func playTreasureJingle(volume_db):
    if global.userSettings["stopAllSfx"]:
        return
    restartPlayingTheme = currentlyPlayingTheme
    stopAll()
    did_play_treasure_jingle = true
    treasureJingle.volume_db = volume_db
    treasureJingle.play()

var did_play_defeat_boss_jingle = false
func playDefeatBossJingle():
    if global.userSettings["stopAllSfx"]:
        return
    # print("defeat boss jingle")
    restartPlayingTheme = currentlyPlayingTheme
    stopAll()
    did_play_defeat_boss_jingle = true
    defeatBossJingle.play()


func conductFromScenePath(path):
    if global.userSettings["stopAllMusic"] or path.find("000Intro") > 0 or path.find("IntroVideo") > 0:
        stopAll()
        return
    changeSongPitch(1.0)
    if path.find("0_0") > 0 and not global.okay_really_really_started_game and not path.find("Nullify") > 0:
        stopAll()
        return
    elif path.find("MainMenu") > 0:
        if global.has_ever_seen_intro:
            tryToPlay(titleThemePlayer)
            changeSongPitch(0.9)
            default_song_pitch = 0.9
            return
        else:
            tryToPlay(primordialOozeThemePlayer)
    elif path.find("preBossRoom") > 0 or \
       (path.find("HighPriestessRoom") > 0 and global.memory["priestess"] >= 2) or \
       path.find("MiniRestZone") > 0 or \
       path.find("LongGlitchyHallway") > 0 or \
       path.find("EggRoom") > 0:
        tryToPlay(windPlayer)
    elif path.find("HighPriestessRoom") > 0 and global.memory["priestess"] <= 2:
        if global.memory["priestess"] == 0:
            tryToPlay(crystalThemePlayer)
        elif global.memory["priestess"] == 1:
            tryToPlay(boss2ThemePlayer)
        elif global.memory["priestess"] == 2:
            tryToPlay(windPlayer)
    elif path.find("BossRoom") > 0:
        tryToPlay(bossThemePlayer)
    elif path.find("gd1Remix") > 0:
        tryToPlay(debugThemePlayer)
    elif path.find("TheDoorBefore") > 0:
        tryToPlay(crystalThemePlayer)
    elif path.find("StoryHook") > 0 or path.find("NullificationPurgatory") > 0 or path.find("NullifyIntro") > 0 or path.find("LadderIntro") > 0 or path.find("GhostIntro") > 0:
        tryToPlay(dungeonThemePlayer)
        changeSongPitch(1.0)
        default_song_pitch = 1.0
    elif path.find("0_1Haven") > 0:
        if global.memory["clean_crystals"] >= 4:
            tryToPlay(windPlayer)
        else:
            tryToPlay(croneThemePlayer)
    elif path.find("gd1ToxicJungle") > 0:
        tryToPlay(suburbThemePlayer)
    elif path.find("gd1ShiftingSandLand") > 0:
        tryToPlay(exploreThemePlayer)
    elif path.find("gd1FishingVillage") > 0:
        tryToPlay(swampThemePlayer)
    elif path.find("gd1PrimordialOoze") > 0:
        tryToPlay(primordialOozeThemePlayer)
    elif path.find("PrimordialOoze") > 0:
        tryToPlay(weirdRestZonePlayer)
        changeSongPitch(0.3)
        default_song_pitch = 0.3
        return
    elif path.find("gd1DreamMemories") > 0:
        tryToPlay(dreamCityThemePlayer)
    elif path.find("gd1CrystalTower") > 0 or path.find("entrance_to_tower") > 0:
        tryToPlay(goddessThemePlayer)
    elif path.find("gd1GrandmaVillage") > 0:
        tryToPlay(dungeonThemePlayer)
    elif path.find("gd1BubblegloopSwamp") > 0:
        tryToPlay(debugThemePlayer)
        if global.memory["priestess"] >= 2:
            changeSongPitch(0.9)
            default_song_pitch = 0.9
            return
    elif path.find("gd1TombSouls") > 0:
        tryToPlay(catacombThemePlayer)
        if global.memory["priestess"] >= 2:
            changeSongPitch(0.9)
            default_song_pitch = 0.9
            return
    elif path.find("gd1AbstractSuburb") > 0:
        tryToPlay(suburbThemePlayer)
        if global.memory["priestess"] >= 2:
            changeSongPitch(0.9)
            default_song_pitch = 0.9
            return
    elif path.find("000IntroCutscene") > 0:
        tryToPlay(priestessPlayer)
        changeSongPitch(0.63)
        default_song_pitch = 0.63
        return
    # elif path.find("Goddess") > 0 or path.find("Psychic") > 0 or path.find("002PathToSacredDoors") > 0 or path.find("003SacredDoorsHubWorld") > 0:
    #     tryToPlay(goddessThemePlayer)
    elif path.find("001CozyHome") > 0:
        tryToPlay(wakeupPlayer)
    elif path.find("Casino") > 0 or path.find("Medievel") > 0 or path.find("Piranesi") > 0 or path.find("Grimoire") > 0:
        tryToPlay(casinoThemePlayer)
    elif path.find("Ocean") > 0:
        tryToPlay(oceanThemePlayer)
    elif path.find("EndOfDemo") > 0:
        tryToPlay(titleThemePlayer)
    elif path.find("EndCredits") > 0:
        tryToPlay(realizationThemePlayer)
    elif path.find("005DebugTown") > 0:
        tryToPlay(dungeonThemePlayer)
    elif path.find("001Your") > 0  or path.find("gd1"):
        tryToPlay(croneThemePlayer)
    else:
        self.stopAll()
    # if global.memory["priestess"] >= 2:
    #     changeSongPitch(0.4)
    #     default_song_pitch = 0.4
    # else:
    changeSongPitch(1.0)
    default_song_pitch = 1.0

    if path.find("__introCutscene") > 0:
        changeSongPitch(2.0)

func changeSongPitch(new_pitch):
    # TODO(jaketrower): reset pitches when you play them
    if currentlyPlayingTheme:
        currentlyPlayingTheme.pitch_scale = new_pitch
    
