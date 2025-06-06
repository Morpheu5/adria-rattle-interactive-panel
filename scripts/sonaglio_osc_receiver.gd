extends OSCReceiver

@export var picked_up = false

func _custom_control(address: String, vals: Array, time):
	if vals != [] and picked_up:
		var Q = Quaternion(vals[0], vals[1], vals[2], vals[3])
		get_parent().quaternion = Q
		GodotLogger.info("Quaternion: (%f, %f, %f, %f)" % vals)
