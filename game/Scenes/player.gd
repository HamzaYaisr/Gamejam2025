extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -250.0
const ACCELERATION = 200.0
const FRICTION = 500

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get input direction (-1, 0, 1)
	var direction := Input.get_axis("ui_left", "ui_right")

	# Progressive horizontal movement
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Apply movement
	move_and_slide()

	# Animations
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("Run")
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("Run")
	else:
		animated_sprite_2d.play("Idle")
