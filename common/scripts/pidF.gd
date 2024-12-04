extends RefCounted
class_name PidF

var _p: float
var _i: float
var _d: float

var _error_integral: float
var _prev_error: float

func _init(p: float, i: float, d:float) -> void:
	_p = p
	_d = d
	_i = i

func update(target: float, current: float, delta:float) -> float:
	var error = target - current
	_error_integral += error * delta
	var error_derivative = (error - _prev_error)/delta
	_prev_error = error
	return _p * error + _i * _error_integral + _d * error_derivative 
