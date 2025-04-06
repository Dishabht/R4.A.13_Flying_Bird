extends CanvasLayer

signal restart
signal scored

func _on_restart_button_pressed():
	restart.emit()
