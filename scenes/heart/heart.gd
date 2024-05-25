extends Area2D


func _on_body_entered(_body):
	queue_free()
	var remaining_hearts = get_tree().get_nodes_in_group("hearts")
	if len(remaining_hearts) == 1:
		Events.level_completed.emit()
