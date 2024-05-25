extends Node2D

@onready var level_completed_display = $CanvasLayer/LevelCompleted


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)

	Events.level_completed.connect(show_level_completed)


func show_level_completed():
	level_completed_display.visible = true
	get_tree().paused = true
