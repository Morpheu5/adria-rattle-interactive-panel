extends Control
class_name BigCarousel

var image_idx: int
var image_name: String
var thumbs: Array
var images: Array

func _ready() -> void:
	var thumbs_container: HBoxContainer = $BackgroundPanel/VBoxContainer/ThumbsScroller/ThumbsContainer
	image_name = images[image_idx]
	load_big_picture(image_name)
	for k in range(thumbs.size()):
		var thumb = load(thumbs[k])
		var thumb_rect = TextureRect.new()
		thumb_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		thumb_rect.texture = thumb
		thumb_rect.connect("gui_input", _on_thumb_pressed.bind(k))
		thumbs_container.add_child(thumb_rect)


func _on_thumb_pressed(event, k):
	if (event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_released()) or (event is InputEventScreenTouch and event.is_released()):
		image_idx = k
		image_name = images[k]
		load_big_picture(image_name)


func load_big_picture(image_name: String):
	var image: TextureRect = $BackgroundPanel/VBoxContainer/GalleryContainer/Image
	image.texture = load(image_name)
	image.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func _on_close_button_pressed() -> void:
	queue_free()


func _on_right_button_pressed() -> void:
	image_idx = (image_idx + 1) % thumbs.size()
	image_name = thumbs[image_idx]
	load_big_picture(image_name)


func _on_left_button_pressed() -> void:
	image_idx = (image_idx - 1) % thumbs.size()
	image_name = thumbs[image_idx]
	load_big_picture(image_name)
