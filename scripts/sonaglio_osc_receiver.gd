extends OSCReceiver

func _custom_control(address: String, vals: Array, time):
	if vals != []:
		var Q = Quaternion(vals[0], vals[1], vals[2], vals[3])
		get_parent().quaternion = Q
