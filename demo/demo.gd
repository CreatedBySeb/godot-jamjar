extends Node2D

## How far the laser should be from the ship when it is instantiated
const LASER_OFFSET: int = 64
## The scene for a laser instance, which we preload into memory so that we can instantiate it
## quickly
const LASER_SCENE: PackedScene = preload("res://demo/laser.tscn")
## An offset to compensate for the fact that the visual rotation does not match the node rotation
## (we could also fix this by angling the sprite 90deg to the right, but this makes it obvious)
const ROTATION_OFFSET: float = PI / 2

## How fast the lasers move across the screen, in pixels per second
@export var laser_speed: float
## How much the velocity reduces each second when not thrusting
@export var ship_friction: float
## The amount of forward velocity the ship has when 'W' is held
@export var ship_thrust: float
## How quickly the ship turns when 'A' or 'D' are held, in degrees per second
@export var ship_turning: float

## A reference to the timer which controls whether the ship can fire
@onready var reload_timer: Timer = $ReloadTimer
## A reference to the Ship node
@onready var ship: CharacterBody2D = $Ship
## The 'ship_turning' property converted into radians
@onready var turn_rad: float = ship_turning * PI / 180

## Whether the ship can fire, set by ReloadTimer via the _on_reload signal handler
var can_fire: bool = true
## An array of spawned lasers that need to be moved each frame
var lasers: Array[Area2D] = []


# Runs every physics tick, `delta` is the time since last tick
func _physics_process(delta: float) -> void:
	# Note: Normally it would be better to configure actions in the project settings, but since this
	# is a demo project and I don't want to pollute the action map, I'm using direct checks here

	# Turn if either 'A' or 'D' is pressed, but not both
	var a_pressed := Input.is_physical_key_pressed(KEY_A)
	var d_pressed := Input.is_physical_key_pressed(KEY_D)

	if a_pressed and not d_pressed:
		ship.rotate(-turn_rad * delta)
	elif d_pressed and not a_pressed:
		ship.rotate(turn_rad * delta)

	# Thrust if 'W' is pressed, otherwise apply ship_friction
	if Input.is_physical_key_pressed(KEY_W):
		ship.velocity = Vector2.from_angle(ship.rotation - ROTATION_OFFSET) * ship_thrust
		AudioSystem.play_continuous("Thruster")
	elif ship.velocity != Vector2.ZERO:
		AudioSystem.stop_continuous("Thruster")

		var friction_vec := ship.velocity.normalized() * ship_friction

		if friction_vec.abs() > ship.velocity.abs():
			ship.velocity = Vector2.ZERO
		else:
			ship.velocity -= friction_vec * delta

	# Actually move the ship and process collisions
	ship.move_and_slide()

	# Fire a laser if 'Space' is pressed
	if Input.is_physical_key_pressed(KEY_SPACE) and can_fire:
		can_fire = false
		var laser: Area2D = LASER_SCENE.instantiate()

		# Copy the ship's orientation, then offset by 64px in that direction
		laser.rotation = ship.rotation - ROTATION_OFFSET
		laser.position = ship.position + Vector2.from_angle(laser.rotation) * LASER_OFFSET

		# Since the script is on the root node, we can add the child directly. If this script was on
		# the ship (as it usually would be), then we would want to add it to the ship's parent
		add_child(laser)
		lasers.append(laser)
		AudioSystem.play_with_variance("Laser")
		reload_timer.start()

	# Move each laser forward (this could be on a laser script instead, attached to the laser, but
	# I am trying to limit the number of scripts in the demo project)
	for laser in lasers:
		laser.position += Vector2.from_angle(laser.rotation) * laser_speed * delta


## This handler is called by the ReloadTimer's timeout signal, which triggers whenever the timer
## completes
func _on_reload() -> void:
	can_fire = true
