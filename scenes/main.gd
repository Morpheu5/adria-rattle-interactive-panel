extends Node3D

enum RattleStates { IDLE, INTERACTING }
enum Languages { ITALIAN, ENGLISH }

var rattle_state: RattleStates = RattleStates.IDLE
var input_handling = true
var labels = []

var menu_visible = true
var interactable = false
var info_screen_open = false
var picked_up = false

var Q = Quaternion(0.0, 0.0, 0.0, 1.0)

var info_screen_scene = preload("res://scenes/InfoScreen.tscn")
var current_info_screen
var theme = preload("res://assets/base_theme.tres")

var prev_quaternion_vals = [0.0, 0.0, 0.0, 1.0]

@onready var it_button = $MainMenu/Labels/HBoxContainer/ITButton
@onready var en_button = $MainMenu/Labels/HBoxContainer/ENButton

func _ready() -> void:
	TranslationServer.set_locale("it")
	labels = [
		$MainMenu/Labels/VBoxContainer/History,
		$MainMenu/Labels/VBoxContainer/Analysis,
		$MainMenu/Labels/VBoxContainer/Technology,
	]
	$MainMenu/Labels/VBoxContainer.modulate = Color(1.0, 1.0, 1.0, 1.0)
	menu_visible = true
	interactable = false
	$SceneRoot/Camera3D.position = Vector3(-1.2, 0.5, 6)
	
	it_button.modulate = Color(1,1,1,1)
	en_button.modulate = Color(1,1,1,0.5)
	
	Q = Quaternion(0.0, 0.0, 0.0, 1.0)
	
	GodotLogger.info("Ready.")

func is_distance_shorter(label, event, _min):
	return label.get_screen_position().distance_to(event.position) < _min.get_screen_position().distance_to(event.position)


func load_info_screen(filename: String) -> void:
	current_info_screen = info_screen_scene.instantiate()
	current_info_screen.dismiss.connect(_on_info_screen_dismiss)
	current_info_screen.modulate = Color(1.0, 1.0, 1.0, 0.0)
	current_info_screen.filename = filename
	$MainMenu.add_child(current_info_screen)
	create_tween().tween_property(current_info_screen, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
	interactable = false
	info_screen_open = true
	GodotLogger.info("Load info screen: %s" % [filename])


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and !menu_visible:
		rattle_put_down()

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventKey) and (event.keycode == KEY_I) and event.is_pressed():
		if menu_visible:
			rattle_pick_up()
		else:
			rattle_put_down()


func rattle_pick_up():
	var menu_tween = create_tween()
	menu_tween.tween_property($MainMenu/Labels, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	menu_tween.tween_callback(func (): $MainMenu/Labels.visible = false)
	create_tween().tween_property($SceneRoot/Camera3D, "position", Vector3(0, 0.5, 5), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property($SceneRoot/Sonaglio, "quaternion", Q, 0.5)
	menu_visible = false
	interactable = true
	picked_up = true
	GodotLogger.info("Rattle up.")


func rattle_put_down():
	$MainMenu/Labels.visible = true
	create_tween().tween_property($MainMenu/Labels, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
	create_tween().tween_property($SceneRoot/Camera3D, "position", Vector3(-1.2, 0.5, 6), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	create_tween().tween_property($SceneRoot/Sonaglio, "quaternion", Quaternion(0, 0, 0, 1), 0.5)
	menu_visible = true
	interactable = false
	picked_up = false
	GodotLogger.info("Rattle down.")


func _on_info_screen_dismiss():
	var tween = create_tween()
	tween.tween_property(current_info_screen, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	tween.tween_callback(func ():
		current_info_screen.queue_free()
		interactable = false
		info_screen_open = false
	)


func _on_credits_button_pressed() -> void:
	load_info_screen("credits")


func _on_history_button_pressed() -> void:
	load_info_screen("history")


func _on_analysis_button_pressed() -> void:
	load_info_screen("analysis")


func _on_technology_button_pressed() -> void:
	load_info_screen("technology")


func _on_sonaglio_animation_timer_timeout() -> void:
	if !interactable and !info_screen_open:
		$SceneRoot/SonaglioAnimationPlayer.play("shake")
	var time = 10 + (randi() % 6)
	$SceneRoot/SonaglioAnimationTimer.start(time)


### Ugly as heck but until Godot's ButtonGroups won't make sense, this is the easiest
func _on_it_button_pressed() -> void:
	GodotLogger.info("Language changed from (%s) to (it)" % [TranslationServer.get_locale()])
	TranslationServer.set_locale("it")
	it_button.modulate = Color(1,1,1,1)
	en_button.modulate = Color(1,1,1,0.5)
func _on_en_button_pressed() -> void:
	GodotLogger.info("Language changed from (%s) to (en)" % [TranslationServer.get_locale()])
	TranslationServer.set_locale("en")
	it_button.modulate = Color(1,1,1,0.5)
	en_button.modulate = Color(1,1,1,1)


func _on_osc_server_message_received(address: Variant, vals: Variant, time: Variant) -> void:
	match address:
		"/data/quaternion":
			if vals != [] and picked_up:
				handle_quaternion(vals)
		"/data/gyroscope":
			if vals != [] and picked_up:
				handle_gyroscope(vals)
		"/data/accelerometer":
			if vals != [] and picked_up:
				handle_accelerometer(vals)
		"/message/picked_up":
			rattle_pick_up()
		"/message/put_down":
			rattle_put_down()
		"/message/alarm":
			if picked_up:
				handle_alarm(vals)

func handle_quaternion(params):
	Q = Quaternion(params[0], params[1], params[2], params[3])
	$SceneRoot/Sonaglio.quaternion = Q
	GodotLogger.info("Quaternion: (%f, %f, %f, %f)" % params)

func handle_gyroscope(params):
	GodotLogger.info("Gyroscope: (%f, %f, %f)" % params)

func handle_accelerometer(params):
	GodotLogger.info("Accelerometer: (%f, %f, %f)" % params)

func handle_alarm(play):
	if play:
		$AlarmPlayer.play()
	else:
		$AlarmPlayer.stop()


func _on_interaction_toggle_button_pressed() -> void:
	rattle_pick_up()
