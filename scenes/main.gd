extends Node3D

enum RattleStates { IDLE, INTERACTING }

var rattle_state: RattleStates = RattleStates.IDLE
var input_handling = true
var labels = []

var menu_visible = true
var interactable = true

var info_screen_scene = preload("res://scenes/InfoScreen.tscn")
var current_info_screen

func _ready() -> void:
	TranslationServer.set_locale("it")
	labels = [
		$MainMenu/Labels/History,
		$MainMenu/Labels/Analysis,
		$MainMenu/Labels/Technology,
	]
	$MainMenu/Labels.modulate = Color(1.0, 1.0, 1.0, 1.0)

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


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and not event.is_pressed() and menu_visible and interactable:
		var closest = labels.reduce(func(_min, label): return label if is_distance_shorter(label, event, _min) else _min)
		var i = labels.find(closest)
		load_info_screen(labels[i].filename)
	if (event is InputEventKey) and (event.keycode == KEY_ENTER) and event.is_pressed():
		if menu_visible:
			create_tween().tween_property($MainMenu/Labels, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.5)
			menu_visible = false
			interactable = false
		else:
			create_tween().tween_property($MainMenu/Labels, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
			menu_visible = true
			interactable = true


func _on_info_screen_dismiss():
	var tween = create_tween()
	tween.tween_property(current_info_screen, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.25)
	tween.tween_callback(func ():
		current_info_screen.queue_free()
		interactable = true
	)


func _on_credits_button_pressed() -> void:
	load_info_screen("credits")
