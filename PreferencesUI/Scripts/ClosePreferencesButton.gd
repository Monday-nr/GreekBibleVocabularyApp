extends Button


func _init() -> void:
	Global.register_node_with_text(self)

func _pressed() -> void:
	owner.set_visible(false)
