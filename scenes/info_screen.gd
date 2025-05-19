class_name InfoScreen
extends Control

@export var title: String = ""
@export var filename: String = ""

var lang: String = "it"

const custom_theme = preload("res://assets/base_theme.tres")
const big_carousel = preload("res://scenes/BigCarousel.tscn")

signal dismiss

func _ready() -> void:
	var file = FileAccess.open("res://assets/content/{filename}.json".format({"filename": filename}), FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data = json.data
		_configure_info_screen(data)
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())

func _configure_info_screen(data: Variant):
	# Load title
	$ColorRect/MarginContainer/VBoxContainer/TitleBar/Label.text = data["title"][lang]
	
	# Clear tab bar
	var tab_container = $ColorRect/MarginContainer/VBoxContainer/TabContainer as TabContainer
	#tab_container.add_theme_font_size_override("font_size", 32)
	tab_container.theme = custom_theme
	tab_container.tab_alignment = TabBar.ALIGNMENT_CENTER
	for child in tab_container.get_children():
		tab_container.remove_child(child)
		child.queue_free()
	# Load tabs
	var tabs = data["tabs"].map(func(e): return e["title"][lang])
	for i in range(tabs.size()):
		var tab = tabs[i]
		var tab_data = data["tabs"][i]
		var scroll_container = ScrollContainer.new()
		tab_container.add_child(scroll_container)
		tab_container.set_tab_title(i, tab)
		scroll_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		var margin_container = MarginContainer.new()
		margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		margin_container.theme = custom_theme
		scroll_container.add_child(margin_container)
		var vbox_container = VBoxContainer.new()
		vbox_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		margin_container.add_child(vbox_container)
		
		for j in range(tab_data["content"].size()):
			var content_block = tab_data["content"][j]
			match content_block["type"]:
				"richtext":
					var textbox = RichTextLabel.new()
					textbox.fit_content = true
					textbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					textbox.size_flags_vertical = Control.SIZE_FILL
					textbox.mouse_filter = Control.MOUSE_FILTER_PASS
					vbox_container.add_child(textbox)
					textbox.text = content_block["content"][lang]
					textbox.theme = custom_theme
				"carousel":
					var carousel = HBoxContainer.new()
					carousel.alignment = BoxContainer.ALIGNMENT_CENTER
					carousel.add_theme_constant_override("separation", 50)
					carousel.set_size(Vector2(1, 100))
					vbox_container.add_child(carousel)
					for k in range(content_block["content"].size()):
						var image = TextureRect.new()
						image.texture = load(content_block["content"][k]["thumbnail"])
						image.connect("gui_input", _on_image_pressed.bind(k, content_block["content"].map(func(c): return c["thumbnail"]), content_block["content"].map(func(c): return c["content"])))
						carousel.add_child(image)
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 32)
			vbox_container.add_child(spacer)

func _on_back_button_pressed() -> void:
	emit_signal("dismiss")

func _on_image_pressed(event: InputEvent, image_idx: int, thumbs: Array, images: Array) -> void:
	if (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_released()) or (event is InputEventScreenTouch and event.is_released()):
		var c = big_carousel.instantiate()
		c.image_idx = image_idx
		c.thumbs = thumbs
		c.images = images
		add_child(c)
