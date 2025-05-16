extends Control
class_name BigCarousel

var image_idx: int
var image_name: String
var thumbs: Array

func _ready() -> void:
	var image: TextureRect = $BackgroundPanel/VBoxContainer/GalleryContainer/Image
	var thumbs_container: HBoxContainer = $BackgroundPanel/VBoxContainer/ThumbsScroller/ThumbsContainer
	
	image.texture = load(image_name)
	image.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	for k in range(thumbs.size()):
		var thumb = load(thumbs[k])
		var thumb_rect = TextureRect.new()
		thumb_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		thumb_rect.texture = thumb
		thumbs_container.add_child(thumb_rect)


func _on_close_button_pressed() -> void:
	queue_free()
