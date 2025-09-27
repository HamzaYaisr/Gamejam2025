extends CharacterBody2D

@export var speed: float = 40.0
@export var gravity: float = 500.0
@export var hp: int = 1   # dies in one slash

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var left_check: RayCast2D = $LeftCheck
@onready var right_check: RayCast2D = $RightCheck

var direction: int = -1   # start moving left

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Patrol movement
	velocity.x = direction * speed
	move_and_slide()

	# Flip when colliding or at edge
	if not left_check.is_colliding() and direction == -1:
		flip()
	elif not right_check.is_colliding() and direction == 1:
		flip()

	# Flip sprite visually
	sprite.flip_h = direction > 0

	# Play walk animation
	if sprite.animation != "walk":
		sprite.play("walk")

# --- Damage System ---
func take_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		die()

func die() -> void:
	# optional: play animation/sound before removing
	queue_free()

# Helper: change direction
func flip() -> void:
	direction *= -1
