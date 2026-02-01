extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var slide_friction = 0.4  # Very low friction for sliding
@export var stand_friction = 1.5
@export var air_friction = 0.075
@export var slide_speed_factor = 10
@export var max_speed : float = 100.0

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_sliding: bool = false

func _ready():
	var floor_normal = get_floor_normal()
	#$AnimatedSprite2D.rotation = atan2(floor_normal.y, floor_normal.x)
	print(floor_normal)
	print(atan2(floor_normal.x, floor_normal.y))
func _physics_process(delta: float) -> void:
	handle_inputs()
	handle_gravity(delta)
	handle_movement(delta)
	move_and_slide()
	handle_sprite(delta)

func handle_sprite(delta):
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.frame = 1 if is_sliding else 0
	if is_on_floor():
		var floor_normal = get_floor_normal()
		$AnimatedSprite2D.rotation = lerp_angle($AnimatedSprite2D.rotation, floor_normal.angle() + PI/2, 10*delta)



func handle_inputs():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_sliding = false
	if Input.is_action_just_pressed("toggle_slide"):
		is_sliding = !is_sliding
		
func handle_gravity(delta : float):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
func handle_sliding_movement(delta: float):
		floor_constant_speed = false
		floor_snap_length = 9.0

		# 1. Get the angle of the ground
		var floor_normal = get_floor_normal()
		# 2. Add 'downhill' force based on the floor's slant
		# floor_normal.x is positive if sloping right, negative if left
		velocity.x += floor_normal.x * slide_speed_factor
		
		# 3. Apply very little friction (sliding feels slippery)
		velocity.x = lerp(velocity.x, 0.0, slide_friction * delta)
		apply_floor_snap() 

func handle_standing_movement(delta: float):
	floor_constant_speed = true
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x += direction * SPEED* delta * stand_friction
	else:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, stand_friction * delta)
		else: 
			velocity.x = lerp(velocity.x, 0.0, air_friction * delta)
	velocity.x = max_speed * sign(velocity.x) if abs(velocity.x) > max_speed else velocity.x
	if abs(velocity.x) < 10.0: 
		velocity.x = 0
	#print("Velocity x: {velocity_x} y: {d}".format({"velocity_x": "%.1f" % velocity.x, "velocity_y": "%.1f" % velocity.y}))

func handle_movement(delta : float):
	if is_sliding:
		handle_sliding_movement(delta)
	else:
		handle_standing_movement(delta)
	
