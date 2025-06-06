extends OSCReceiver

signal picked_up
signal put_down

func _custom_control(address: String, vals: Array, time):
	if address == "/pickedup":
		emit_signal("picked_up")
	elif address == "/putdown":
		emit_signal("put_down")
	elif address == "/gyroscope":
		GodotLogger.info("Gyroscope: (%f, %f, %f)" % vals)
	elif address == "/accelerometer":
		GodotLogger.info("Accelerometer: (%f, %f, %f, %f)" % vals)
