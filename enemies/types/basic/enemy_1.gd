extends CharacterBody2D
enum States {IDLE, CHASE, ATTACK}
var state: States  = States.IDLE
var attack_range: bool = false
var chase_range: bool = false

var home_pos = Vector2.ZERO 
var target = null
var target_pos = Vector2.ZERO

@onready var attack_timer: Timer = $attackTimer
@export var nav_agent: NavigationAgent2D

func _ready():
	home_pos = self.global_position
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4

func _physics_process(delta):
	move()
	
	if state == States.IDLE:
		target_pos = home_pos
		show()
	elif state == States.ATTACK:
		hide()
	elif state == States.CHASE:
		show()
		target_pos = target.global_position


func move():
	if nav_agent.is_navigation_finished():
		return
	var axis = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * enep.speed1
	move_and_slide()

func recalc_path():
	nav_agent.target_position = target_pos
	

func _on_attack_timer_timeout():
	if attack_range == true:
		state = States.ATTACK
	elif attack_range== false and chase_range == true:
		state = States.CHASE
	else:
		state = States.IDLE


func _on_basic_melee_enemy_attack_body_entered(body):
	if body.is_in_group("player"):
		attack_range = true
		state = States.ATTACK
		attack_timer.start()
func _on_basic_melee_enemy_attack_body_exited(body):
	if body.is_in_group("player"):
		attack_range = false


func _on_hitbox_enemy_basic_area_entered(area):
	if area.is_in_group("player_proj"):
		queue_free()


func _on_chase_basic_area_entered(area):
	if area.is_in_group("player"):
		chase_range = true
		state = States.CHASE
		target = area.owner


func _on_chase_basic_area_exited(area):
	if area.is_in_group("player"):
		chase_range = false
		state = States.IDLE


func _on_recalc_timer_timeout():
	recalc_path()
