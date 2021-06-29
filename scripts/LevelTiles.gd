extends GridMap

# resources is loaded at compile time with preload
var grey_tiles = preload("res://sceneObjects/tiles/grey_tiles.tres") 
var red_tiles = preload("res://sceneObjects/tiles/red_tiles.tres")
var green_tiles = preload("res://sceneObjects/tiles/green_tiles.tres")
var yellow_tiles = preload("res://sceneObjects/tiles/yellow_tiles.tres")

func noGlitch():
    set_mesh_library(grey_tiles)

func floorGlitch():
    set_mesh_library(red_tiles)

func featherGlitch():
    set_mesh_library(green_tiles)

func ladderGlitch():
    set_mesh_library(yellow_tiles)