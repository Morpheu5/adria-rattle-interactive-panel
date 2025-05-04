extends Node3D

enum RattleStates { IDLE, INTERACTING }

var rattle_state: RattleStates = RattleStates.IDLE
var input_handling = true
var labels = []

func _ready() -> void:
	labels = [
		$MainMenu/Labels/HistoryLabel,
		$MainMenu/Labels/AnalysisLabel,
		$MainMenu/Labels/TechnologyLabel,
	]
	print(labels)

func is_distance_shorter(label, event, min):
	return label.get_screen_position().distance_to(event.position) < min.get_screen_position().distance_to(event.position)

func _input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and not event.is_pressed() and input_handling:
		#var distances = labels.map(func (l): return Vector2(l.get_screen_position()).distance_to(event.position))
		var closest = labels.reduce(func(min, label): return label if is_distance_shorter(label, event, min) else min)
		print(closest)
