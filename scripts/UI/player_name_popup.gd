extends Control

signal name_entered(name)


@onready var input_line = $Panel/VBoxContainer/NameLineEdit
@onready var confirm_button = $Panel/ConfirmButton

func _ready():
	# (Focus)
	input_line.grab_focus()

func _on_confirm_button_pressed():
	var player_name_input = input_line.text.strip_edges() # delete space
	
	if player_name_input.length() > 4: # mini char 5
		name_entered.emit(player_name_input) # send name to Home.gd
		queue_free() #delete the window
	else:
		print("Please enter a name with at least 3 characters.")
		# Label


#  text_submitted to _on_confirm_button_pressed
func _on_name_line_edit_text_submitted(_new_text):
	_on_confirm_button_pressed()
