extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $VBoxContainer/Label

signal scene_loaded(scene: PackedScene)

func start_loading(scene_path: String) -> void:
	visible = true
	progress_bar.value = 0
	label.text = "Loading..."

	await get_tree().process_frame
	var err = ResourceLoader.load_threaded_request(scene_path)
	if err != OK:
		label.text = "Failed to start loading: %s" % err
		return

	var progress_arr := []
	await update_progress(scene_path, progress_arr)


func update_progress(scene_path: String, progress_arr: Array) -> void:
	while true:
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress_arr)

		if progress_arr.size() > 0:
			progress_bar.value = progress_arr[0] * 100.0
		else:
			progress_bar.value = min(progress_bar.value + 0.5, 95)

		if status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			progress_bar.value = 100
			break
		elif status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			label.text = "Loading failed!"
			return

		await get_tree().process_frame

	var res = ResourceLoader.load_threaded_get(scene_path)
	if res:
		emit_signal("scene_loaded", res)
	else:
		label.text = "Loaded but resource is null"
