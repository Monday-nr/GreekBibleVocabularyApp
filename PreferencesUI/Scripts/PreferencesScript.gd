extends PanelContainer

@onready var color_picker: VBoxContainer = %ColorPicker
@onready var settings_container: VBoxContainer = $MarginContainer/VBoxContainer

func _ready() -> void:
	color_picker.visibility_changed.connect(_sl_color_picker_visibility_changed)
	visibility_changed.connect(_sl_visibility_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("back"):
		get_viewport().set_input_as_handled()
		if color_picker.is_visible():
			color_picker.close()
		else:
			set_visible(false)

func _sl_color_picker_visibility_changed() -> void:
	var set_to_visible: bool = not color_picker.is_visible()
	for child: Node in settings_container.get_children():
		if child != color_picker:
			child.set_visible(set_to_visible)

func _sl_visibility_changed() -> void:
	Controls.enable(not is_visible())
