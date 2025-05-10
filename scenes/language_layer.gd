extends CanvasLayer

func _ready() -> void:
	print(TranslationServer.get_locale_name(TranslationServer.get_locale()))
