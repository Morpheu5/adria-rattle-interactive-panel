class_name InfoScreen
extends Control

@export var title: String = ""

signal dismiss

func _ready() -> void:
	$ColorRect/MarginContainer/VBoxContainer/TitleBar/Label.text = title


func _on_back_button_pressed() -> void:
	emit_signal("dismiss")
	
