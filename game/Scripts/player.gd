extends CharacterBody2D

# Physics Constants
const SPEED: float = 150.0
const JUMP_VELOCITY: float = -300.0
const ACCELERATION: float = 200.0
const FRICTION: float = 1000.0
const GRAVITY: float = 980.0 # Standard Godot 4 default gravity

# Node References
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	Engine.time_scale = 1

func _physics_process(delta: float) -> void:
	# --- Gravity ---
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# --- Input Handling & Movement ---
	var direction: float = Input.get_axis("ui_left", "ui_right")

	# Horizontal Movement (Acceleration/Friction)
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Final Movement & Animation ---
	move_and_slide()
	update_animation()

## 🖼️ Animation
func update_animation() -> void:
	# Air Animation
	if not is_on_floor():
		# If you have a "Jump" and "Fall", add logic here
		animated_sprite_2d.play("Jump")
	else:
		# Ground Animations
		if velocity.x == 0:
			animated_sprite_2d.play("Idle")
		elif abs(velocity.x) > 120:
			animated_sprite_2d.play("Run")
		else:
			animated_sprite_2d.play("Walk")

	# Update Sprite Flipping
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
