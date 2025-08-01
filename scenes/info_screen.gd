class_name InfoScreen
extends Control

@export var title: String = ""
@export var filename: String = ""

var press_position: Vector2 = Vector2.ZERO
const TAP_SIZE = 10
var drag = false

var lang: String = "it"

const custom_theme = preload("res://assets/base_theme.tres")
const big_carousel = preload("res://scenes/BigCarousel.tscn")

const play_icon = preload("res://assets/ui/right.png")
const pause_icon = preload("res://assets/ui/pause.png")
const rewind_icon = preload("res://assets/ui/rewind.png")
const larger_icon = preload("res://assets/ui/larger.png")

signal dismiss

func _ready() -> void:
	lang = TranslationServer.get_locale()
	var file = FileAccess.open("res://assets/content/{filename}.json".format({"filename": filename}), FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		var data = json.data
		_configure_info_screen(data)
		GodotLogger.info("Loading screen (%s)." % [filename])
	else:
		GodotLogger.error("JSON Parse Error: (%s) in (%s) at line (%s)" % [json.get_error_message(), json_string, json.get_error_line()])

func _configure_info_screen(data: Variant):
	# Load title
	$ColorRect/MarginContainer/VBoxContainer/TitleBar/Label.text = data["title"][lang]
	
	# Clear tab bar
	var tab_container = $ColorRect/MarginContainer/VBoxContainer/TabContainer as TabContainer
	for child in tab_container.get_children():
		tab_container.remove_child(child)
		child.queue_free()

	# Load tabs
	var tabs = data["tabs"].map(func(e): return e["title"][lang])
	if tabs.size() <= 1:
		tab_container.tabs_visible = false

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
					textbox.bbcode_enabled = true
					vbox_container.add_child(textbox)
					textbox.text = content_block["content"][lang]
					textbox.theme = custom_theme
				"image":
					var image_margin_container = MarginContainer.new()
					image_margin_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					image_margin_container.size_flags_vertical = Control.SIZE_EXPAND
					image_margin_container.add_theme_constant_override("margin_left", 120)
					image_margin_container.add_theme_constant_override("margin_right", 120)
					var image = TextureRect.new()
					image.texture = load(content_block["content"])
					image.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
					image.size_flags_horizontal = Control.SIZE_FILL
					image.size_flags_vertical = Control.SIZE_EXPAND_FILL
					image_margin_container.add_child(image)
					vbox_container.add_child(image_margin_container)
					var caption = Label.new()
					caption.text = content_block["caption"][lang]
					caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					caption.size_flags_horizontal = Control.SIZE_FILL
					caption.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
					caption.add_theme_font_size_override("font_size", 32)
					caption.autowrap_mode = TextServer.AUTOWRAP_WORD
					caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
					vbox_container.add_child(caption)
				"video":
					var video_margin_container = MarginContainer.new()
					video_margin_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
					video_margin_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

					var video_poster = TextureRect.new()
					video_poster.texture = load(content_block["poster"])

					var ar = video_poster.texture.get_size().x / video_poster.texture.get_size().y
					video_poster.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
					video_poster.mouse_force_pass_scroll_events = true
					video_margin_container.add_child(video_poster)

					var controls_container = HBoxContainer.new()
					controls_container.alignment = BoxContainer.ALIGNMENT_END
					controls_container.size_flags_horizontal = Control.SIZE_SHRINK_END
					controls_container.size_flags_vertical = Control.SIZE_SHRINK_END
					controls_container.add_theme_constant_override("separation", 0)
					var play_button = Button.new()
					
					var big_play = TextureRect.new()
					big_play.texture = load("res://assets/ui/big_play.png")
					big_play.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
					big_play.size_flags_vertical = Control.SIZE_SHRINK_CENTER
					big_play.modulate = Color(1,1,1,0.666)
					big_play.mouse_filter = Control.MOUSE_FILTER_IGNORE

					var video_player = VideoStreamPlayer.new()
					video_margin_container.add_child(video_player)
					video_player.stream = load(content_block["content"])
					video_player.custom_minimum_size = Vector2(1280, 1280/ar)
					video_player.expand = true
					video_player.loop = true
					video_player.mouse_force_pass_scroll_events = true
					video_player.mouse_filter = Control.MOUSE_FILTER_PASS
					video_player.gui_input.connect(_on_video_player_pressed.bind(video_player, play_button, big_play))
					vbox_container.add_child(video_margin_container)
					
					video_margin_container.add_child(big_play)

					var stylebox = StyleBoxFlat.new()
					stylebox.bg_color = Color(0,0,0,0.8)
					play_button.icon = play_icon
					play_button.pressed.connect(_on_play_button_pressed.bind(video_player, play_button, big_play))
					play_button.add_theme_stylebox_override("normal", stylebox)
					play_button.add_theme_stylebox_override("hover", stylebox)
					var rewind_button = Button.new()
					rewind_button.icon = rewind_icon
					rewind_button.pressed.connect(_on_rewind_button_pressed.bind(video_player, play_button, big_play))
					rewind_button.add_theme_stylebox_override("normal", stylebox)
					rewind_button.add_theme_stylebox_override("hover", stylebox)

					controls_container.add_child(rewind_button)
					video_margin_container.add_child(controls_container)

					var caption = Label.new()
					caption.text = content_block["caption"][lang]
					caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					caption.size_flags_horizontal = Control.SIZE_FILL
					caption.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
					caption.add_theme_font_size_override("font_size", 32)
					caption.autowrap_mode = TextServer.AUTOWRAP_WORD
					caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
					
					vbox_container.add_child(caption)
				"carousel":
					var n = content_block["content"].size()
					var carousel_container = CenterContainer.new()
					var carousel = HBoxContainer.new()
					carousel_container.add_child(carousel)
					carousel.custom_minimum_size = Vector2(1400, 1000.0/n)
					carousel.alignment = BoxContainer.ALIGNMENT_CENTER
					carousel.set_anchors_preset(Control.PRESET_FULL_RECT)
					carousel.add_theme_constant_override("separation", 50)
					for k in range(n):
						var image = TextureRect.new()
						image.texture = load(content_block["content"][k]["thumbnail"])
						image.size_flags_horizontal = Control.SIZE_EXPAND_FILL
						image.size_flags_vertical = Control.SIZE_FILL
						image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
						image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
						image.connect("gui_input", _on_image_pressed.bind(content_block["id"], k, content_block["content"].map(func(c): return c["thumbnail"]), content_block["content"].map(func(c): return c["content"]), content_block["content"].map(func(c): return c["caption"][lang])))
						carousel.add_child(image)
						var larger = TextureRect.new()
						larger.texture = larger_icon
						image.add_child(larger)
					vbox_container.add_child(carousel_container)
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 32)
			vbox_container.add_child(spacer)

func _on_back_button_pressed() -> void:
	GodotLogger.info("Info screen (%s) dismissed." % [filename])
	emit_signal("dismiss")

func _on_image_pressed(event: InputEvent, carousel_id: String, image_idx: int, thumbs: Array, images: Array, captions: Array) -> void:
	if (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_released() and !drag):
		GodotLogger.info("Info screen (%s), carousel id (%s), image pressed (%d)" % [filename, images[image_idx]])
		var c = big_carousel.instantiate()
		c.carousel_id = carousel_id
		c.image_idx = image_idx
		c.thumbs = thumbs
		c.images = images
		c.captions = captions
		add_child(c)

func _on_play_button_pressed(video_player: VideoStreamPlayer, play_button: Button, big_play: TextureRect):
	if video_player.is_paused() or !video_player.is_playing():
		play_button.icon = pause_icon
		video_player.set_paused(false)
		if video_player.stream_position == 0.0:
			video_player.play()
		big_play.visible = false
		GodotLogger.info("Info screen (%s), play video (%s)" % [filename, video_player.stream.file])
	else:
		play_button.icon = play_icon
		video_player.set_paused(true)
		big_play.visible = true
		GodotLogger.info("Info screen (%s), pause video (%s)" % [filename, video_player.stream.file])

func _on_video_player_pressed(event: InputEvent, video_player: VideoStreamPlayer, play_button: Button, big_play: TextureRect):
	if event is InputEventMouseButton and event.is_released() and !event.is_canceled() and !drag:
		if video_player.is_paused() or !video_player.is_playing():
			play_button.icon = pause_icon
			video_player.set_paused(false)
			if video_player.stream_position == 0.0:
				video_player.play()
			big_play.visible = false
			GodotLogger.info("Info screen (%s), play video (%s)" % [filename, video_player.stream.file])
		else:
			play_button.icon = play_icon
			video_player.set_paused(true)
			big_play.visible = true
			GodotLogger.info("Info screen (%s), pause video (%s)" % [filename, video_player.stream.file])

func _on_rewind_button_pressed(video_player: VideoStreamPlayer, play_button: Button, big_play: TextureRect):
	video_player.stop()
	video_player.stream_position = 0.0
	play_button.icon = play_icon
	big_play.visible = true
	GodotLogger.info("Info screen (%s), rewind video (%s)" % [filename, video_player.stream.file])
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		press_position = event.position
		drag = false
	elif event is InputEventMouseButton and event.is_released():
		var dist = event.position.distance_to(press_position)
		if dist <= TAP_SIZE:
			drag = false
		else:
			drag = true
		press_position = Vector2.ZERO
