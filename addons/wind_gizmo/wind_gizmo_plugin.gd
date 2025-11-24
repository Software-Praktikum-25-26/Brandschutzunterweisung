@tool
extends EditorNode3DGizmoPlugin

const WindGizmo = preload("res://wind_gizmo.gd")  # Update this path to where your wind gizmo script is

func _init():
	create_material("main", Color.CYAN, false, true, false)
	create_material("main_hover", Color.YELLOW, false, true, false)
	create_handle_material("handles", false)

func _get_gizmo_name() -> String:
	return "WindGizmo"

func _has_gizmo(node: Node3D) -> bool:
	return node.get_script() == WindGizmo

func _redraw(gizmo: EditorNode3DGizmo):
	gizmo.clear()
	
	var node = gizmo.get_node_3d()
	if not node:
		return
	
	var wind_dir = node.wind_direction
	var force = node.wind_force
	
	# Scale arrow by force
	var arrow_len = node.arrow_length * (force / 10.0)
	
	# Create arrow shaft
	var lines = PackedVector3Array()
	lines.append(Vector3.ZERO)
	lines.append(wind_dir * arrow_len)
	
	# Arrow head
	var perp1 = wind_dir.cross(Vector3.UP if abs(wind_dir.dot(Vector3.UP)) < 0.9 else Vector3.RIGHT).normalized()
	var perp2 = wind_dir.cross(perp1).normalized()
	
	var head_pos = wind_dir * arrow_len
	var head_size = 0.3
	
	lines.append(head_pos)
	lines.append(head_pos - wind_dir * head_size + perp1 * head_size * 0.5)
	
	lines.append(head_pos)
	lines.append(head_pos - wind_dir * head_size - perp1 * head_size * 0.5)
	
	lines.append(head_pos)
	lines.append(head_pos - wind_dir * head_size + perp2 * head_size * 0.5)
	
	lines.append(head_pos)
	lines.append(head_pos - wind_dir * head_size - perp2 * head_size * 0.5)
	
	gizmo.add_lines(lines, get_material("main", gizmo), false)
	
	# Add handle at arrow tip for dragging
	var handles = PackedVector3Array()
	handles.append(head_pos)
	gizmo.add_handles(handles, get_material("handles", gizmo), [0])

func _get_handle_name(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool) -> String:
	return "Wind Direction"

func _get_handle_value(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool):
	var node = gizmo.get_node_3d()
	return [node.wind_direction, node.wind_force]

func _set_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	var node = gizmo.get_node_3d()
	if not node:
		return
	
	var ray_from = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)
	
	# Create a plane perpendicular to camera
	var plane = Plane(camera.global_transform.basis.z, node.global_position)
	var intersection = plane.intersects_ray(ray_from, ray_dir)
	
	if intersection:
		var local_pos = node.global_transform.affine_inverse() * intersection
		if local_pos.length() > 0.1:
			node.wind_direction = local_pos.normalized()
			node.wind_force = clamp(local_pos.length() * 5.0, 0.1, 100.0)

func _commit_handle(gizmo: EditorNode3DGizmo, handle_id: int, secondary: bool, restore, cancel: bool) -> void:
	var node = gizmo.get_node_3d()
	if not node:
		return
	
	if cancel:
		node.wind_direction = restore[0]
		node.wind_force = restore[1]
		return
	
	# Properties are automatically saved/undone by the editor
	# Just make sure the changes are applied
	node.notify_property_list_changed()
