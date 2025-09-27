extends Node2D
@onready var player: CharacterBody2D = $Player

func _ready():
	$AnimationPlayer.play("intro")

func _on_cutscene_finished():
	# Switch to your level or enable player controls
	get_tree().change_scene_to_file("res://game.tscn")
