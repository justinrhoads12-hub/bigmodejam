extends CharacterBody2D

@export var roam_timer : float = 10

const SPEED = 20.0
var dir = 1

var is_jumping = false # TODO: when the player jumps over enemy it will try and jump and attack the player

var is_diving = false #TODO: add a function that the enemy will lunge and dive in that direction 

func _ready() -> void:
	$RoamingTimer.wait_time= roam_timer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	handle_enemy_movement()

	move_and_slide()


func handle_enemy_movement():
	velocity.x = SPEED * dir	


func _on_roaming_timer_timeout() -> void:
	dir = -1 * dir
