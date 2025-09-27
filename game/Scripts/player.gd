extends CharacterBody2D

# Physics Constants (Adjust GRAVITY based on your Project Settings)
const SPEED: float = 150.0
const JUMP_VELOCITY: float = -250.0
const ACCELERATION: float = 200.0
const FRICTION: float = 500.0
const GRAVITY: float = 980.0 # Standard Godot 4 default gravity

# Node References
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var attack_timer: Timer = $AttackTimer
@onready var cooldown_timer: Timer = $CooldownTimer

# Attack Properties
@export var attack_damage: int = 12
@export var attack_duration: float = 0.18
@export var attack_cooldown: float = 0.35
@export var attack_offset_x: float = 18.0

# State Variables
var is_attacking: bool = false
var hit_enemies: Array[Node] = [] # Use typed array for clarity

func _ready() -> void:
	Engine.time_scale = 1
	
	# Setup Attack Area & connect signal (Modern Godot 4 syntax)
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)

	# Setup Timers & connect signals
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_duration
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = attack_cooldown
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func _physics_process(delta: float) -> void:
	# --- 1. Gravity (THE FIX) ---
	if not is_on_floor():
		velocity.y += GRAVITY * delta # Use the constant GRAVITY

	# --- 2. Input Handling & Movement ---
	var direction: float = Input.get_axis("ui_left", "ui_right")

	# Horizontal Movement (Acceleration/Friction)
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
		# Animation is handled in update_animation()

	# Attack
	if Input.is_action_just_pressed("attack"):
		try_attack()

	# --- 3. Final Movement & Animation ---
	move_and_slide()
	update_animation()


## ⚔️ Combat Functions

func _is_on_cooldown() -> bool:
	return cooldown_timer.time_left > 0.0


func try_attack() -> void:
	if is_attacking or _is_on_cooldown():
		return
		
	is_attacking = true
	hit_enemies.clear()

	# DECLARATION AND CALCULATION MUST BE HERE
	var facing_dir: float = -1.0 if animated_sprite_2d.flip_h else 1.0
	
	# Use the calculated variable to set position
	attack_area.position.x = abs(attack_offset_x) * facing_dir
	attack_area.monitoring = true

	# Start timers
	attack_timer.start()
	cooldown_timer.start()

	# Play animation immediately
	animated_sprite_2d.play("Attack")

## ⚙️ Signal Handlers

func _on_attack_area_body_entered(body: Node) -> void:
	# Check if we've already hit this enemy during the current attack
	if body in hit_enemies:
		return
	
	# Check for the required method
	if body.has_method("take_damage"):
		hit_enemies.append(body)
		
		# Apply Damage
		body.take_damage(attack_damage)
		
		# Apply Knockback
		if body.has_method("apply_knockback"):
			# Calculate direction vector from player to enemy
			var dir: Vector2 = (body.global_position - global_position).normalized()
			body.apply_knockback(dir * 300.0)


func _on_attack_timer_timeout() -> void:
	# End the attack window
	attack_area.monitoring = false
	is_attacking = false
	# The animation will transition out in _physics_process on the next frame


func _on_cooldown_timer_timeout() -> void:
	# This timer is just a pause before the next attack can start
	pass

## 🖼️ Animation

func update_animation() -> void:
	# Skip movement animations if attacking
	if is_attacking:
		animated_sprite_2d.play("Attack")
		# Face direction must be updated outside of this block for a smooth attack swing
	else:
		# Air Animation
		if not is_on_floor():
			# Note: We rely on the Jump animation being played on jump
			# If you have a separate "Fall" animation, you could add logic here:
			# if velocity.y > 0: animated_sprite_2d.play("Fall")
			return

		# Ground Animations
		if velocity.x == 0:
			animated_sprite_2d.play("Idle")
		elif abs(velocity.x) > 120:
			animated_sprite_2d.play("Run")
		else:
			animated_sprite_2d.play("Walk")

	# Update Sprite Flipping based on movement (or facing direction during attack)
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
