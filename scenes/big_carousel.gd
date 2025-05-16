extends Control
class_name BigCarousel

var image_idx: int
var image_name: String
var thumbs: Array

var image: TextureRect

func _ready() -> void:
	image = $BackgroundPanel/VBoxContainer/GalleryContainer/Image
	image.texture = load(image_name)
	image.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pass


func _on_close_button_pressed() -> void:
	queue_free()
