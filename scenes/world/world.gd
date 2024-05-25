extends Node2D

@onready var polygon_2d = $StaticBody2D/CollisionPolygon2D/Polygon2D
@onready var collision_polygon_2d = $StaticBody2D/CollisionPolygon2D
@onready var level_completed_display = $CanvasLayer/LevelCompleted


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	Events.level_completed.connect(show_level_completed)
	polygon_2d.polygon = collision_polygon_2d.polygon


func show_level_completed():
	level_completed_display.visible = true
	get_tree().paused = true
