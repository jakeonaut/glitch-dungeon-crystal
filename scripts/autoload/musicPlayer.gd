extends Node

onready var titleThemePlayer = get_node("TitleThemePlayer")
onready var dungeonThemePlayer = get_node("DungeonThemePlayer")
onready var debugThemePlayer = get_node("DebugThemePlayer")
onready var casinoThemePlayer = get_node("CasinoThemePlayer")
onready var suburbThemePlayer = get_node("SuburbThemePlayer")
onready var swampThemePlayer = get_node("SwampThemePlayer")
onready var goddessThemePlayer = get_node("GoddessThemePlayer")
onready var townThemePlayer = get_node("TownThemePlayer")

var currentlyPlayingTheme = null

func stopAll():
    changeSongPitch(1.0)
    titleThemePlayer.stop()
    dungeonThemePlayer.stop()
    debugThemePlayer.stop()
    casinoThemePlayer.stop()
    suburbThemePlayer.stop()
    swampThemePlayer.stop()
    goddessThemePlayer.stop()
    townThemePlayer.stop()
    currentlyPlayingTheme = null

func conductFromScenePath(path):
    #pass # i don't want to listen to music for a bit
    changeSongPitch(1.0)
    if path.find("Goddess") > 0 or path.find("Psychic") > 0:
        self.playGoddess()
    elif path.find("IntroDungeon") > 0:
        self.playDungeon()
    elif path.find("Debug") > 0:
        self.playDebug()
    elif path.find("Casino") > 0:
        self.playCasino()
    elif path.find("Suburb") > 0:
        self.playSuburb()
    elif path.find("Swamp") > 0:
        self.playSwamp()
    elif path.find("MainMenu") > 0:
        titleThemePlayer.play() # TODO(jaketrower!!!)
    elif path.find("Town") > 0:
        self.playSwamp() # self.playTown()
    elif path.find("SpellbookIntro") > 0:
        self.playDebug()
    elif path.find("Adventure") > 0:
        self.playSuburb()
    else:
        self.stopAll()
    changeSongPitch(1.0)

func changeSongPitch(new_pitch):
    # TODO(jaketrower): reset pitches when you play them
    if currentlyPlayingTheme:
        currentlyPlayingTheme.pitch_scale = new_pitch

func playDungeon():
    if dungeonThemePlayer.is_playing(): return
    self.stopAll()
    dungeonThemePlayer.play()
    currentlyPlayingTheme = dungeonThemePlayer

func playDebug():
    if debugThemePlayer.is_playing(): return
    self.stopAll()
    debugThemePlayer.play()
    currentlyPlayingTheme = debugThemePlayer
    
func playCasino():
    if casinoThemePlayer.is_playing(): return
    self.stopAll()
    casinoThemePlayer.play()
    currentlyPlayingTheme = casinoThemePlayer

func playSuburb():
    if suburbThemePlayer.is_playing(): return
    self.stopAll()
    suburbThemePlayer.play()
    currentlyPlayingTheme = suburbThemePlayer

func playSwamp():
    if swampThemePlayer.is_playing(): return
    self.stopAll()
    swampThemePlayer.play()
    currentlyPlayingTheme = swampThemePlayer

func playTown():
    if townThemePlayer.is_playing(): return
    self.stopAll()
    townThemePlayer.play()
    currentlyPlayingTheme = townThemePlayer

func playGoddess():
    if goddessThemePlayer.is_playing(): return
    self.stopAll()
    goddessThemePlayer.play()
    currentlyPlayingTheme = goddessThemePlayer
