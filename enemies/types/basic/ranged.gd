extends RigidBody2D

@onready var stunTimer: Timer = $stunTimer
@onready var stunArea: CollisionShape2D = $StunRange/CollisionShape2D
@onready var kiteArea: CollisionShape2D = $KitingRangeStart/CollisionShape2D

var _pid = Pid2D.new(2.0, 0.1, 4.0)
var target: Node2D  # Reference to the player node

var target_dir: Vector2
var prediction_element: Vector2
var target_velocity: Vector2
var error: Vector2
var correction: Vector2
var thrust: Vector2
var impulse: Vector2

var thrustF: float = enep.thrust2
var kiteF: float = enep.kite1

enum States {NORMAL, STUNNED, KITING}
var state: States

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	stunArea.disabled = false
	state = States.NORMAL
	thrust = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not target:
		return
	target_dir = target.global_position - self.global_position
	prediction_element = (target.linear_velocity - self.linear_velocity) * delta
	
	if state == States.NORMAL:
		target_velocity = (target_dir + prediction_element) * thrustF
		error =  target_velocity - self.linear_velocity
		correction = _pid.update(error, delta) * delta
		thrust = correction
		rotation = lerp_angle(rotation, correction.angle(), 0.05)
		apply_central_force(thrust)
		print("normal")

	elif state == States.STUNNED:
		thrust = Vector2.ZERO
		print("stun")

	if state == States.KITING:
		var target_kite = -target_dir * kiteF
		var kite_error =  target_kite - self.linear_velocity
		var kite_correction = _pid.update(error, delta) * delta
		target_velocity = (target_dir + prediction_element) * thrustF
		error =  target_velocity - self.linear_velocity
		correction = _pid.update(error, delta) * delta
		thrust = correction + kite_correction
		rotation = lerp_angle(rotation, correction.angle(), 0.05)
		apply_central_force(thrust)
		print("kite")
	print(thrust)

func _on_hurt_box_area_entered(area: Area2D) -> void:
	kiteArea.disabled = true
	stunArea.disabled = true
	stunTimer.start()
	call_deferred("free")


func _on_stun_timer_timeout() -> void:
	state = States.NORMAL
	kiteArea.disabled = false
	stunArea.disabled = false


func _on_stun_range_body_entered(body: RigidBody2D) -> void:
	kiteArea.disabled = true
	stunArea.disabled = true
	stunTimer.start()
	state = States.STUNNED


func _on_kiting_range_end_area_exited(area: Area2D) -> void:
	if kiteArea.disabled == false:
		state = States.NORMAL


func _on_kiting_range_start_area_entered(area: Area2D) -> void:
	state = States.KITING
