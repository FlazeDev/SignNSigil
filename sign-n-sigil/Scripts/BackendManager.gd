class_name BackendManager
extends Node

var tracker_pid: int = -1

func _ready() -> void:
	start_python_backend()

func start_python_backend() -> void:
	var tracker_path: String = ProjectSettings.globalize_path("res://Main_Tracker.exe")
	
	print("Launching backend process tracking engine at: ", tracker_path)
	
	# Launching the executable directly allows Windows to cleanly map the 
	# parent-child process relationship so the Python auto-close logic works!
	tracker_pid = OS.create_process(tracker_path, [])
	
	if tracker_pid != -1:
		print("Tracker launched successfully! Process ID: ", tracker_pid)
	else:
		print("CRITICAL: Failed to launch Main_Tracker.exe from res://")

func _notification(what: int) -> void:
	# Double insurance: Still try to kill it manually if closed normally
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if tracker_pid != -1:
			print("Terminating background process safely...")
			OS.kill(tracker_pid)
		get_tree().quit()
