extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0
const ACCELERATION = 200.0
const FRICTION = 500

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _ready() -> void:
	# Sets the entire game to run at 75% of normal speed.
	Engine.time_scale = 1
	
func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# --- THIS PART WAS MISSING ---
	# Get input direction (-1, 0, 1) for horizontal movement
	var direction := Input.get_axis("ui_left", "ui_right")

	# Apply horizontal movement with acceleration and friction
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	# -----------------------------

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("Jump") # Animation now plays correctly here

	# Apply movement to the character
	move_and_slide()

	# Call the function to update animations
	update_animation()

func update_animation() -> void:
	# --- Sprite Flipping ---
	# Handle which way the character is facing first.
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
		
	# --- Animation State ---
	# In the air: Let the jump animation play out.
	# We check this first to ensure it has priority.
	if not is_on_floor():
		# The "Jump" animation was already started. We do nothing here
		# to let it finish. If you had a "Fall" animation, you'd add
		# logic here to switch to it based on velocity.y.
		return

	# On the ground: Check for idle, walk, or run.
	if velocity.x == 0:
		animated_sprite_2d.play("Idle")
	else:
		# Use abs() to check speed regardless of direction.
		if abs(velocity.x) > 120:
			animated_sprite_2d.play("Run")
		else:
			animated_sprite_2d.play("Walk")
