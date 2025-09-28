extends Node

@onready var level_exit = $LevelExit

var can_exit: bool = false

func _ready() -> void:
	level_exit.player_reached_exit.connect(_on_player_reached_exit)

func _on_player_reached_exit() -> void:
	can_exit = true

func _unhandled_input(event: InputEvent) -> void:
	if can_exit and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			get_tree().change_scene_to_file("res://Scenes/level2.tscn")
