extends Control

signal name_entered(name)

# 🔗 قم بربط LineEdit (مكان إدخال الاسم) وزر التأكيد
@onready var input_line = $Panel/VBoxContainer/NameLineEdit
@onready var confirm_button = $Panel/ConfirmButton

func _ready():
	# 💡 نحطو التركيز (Focus) على مكان الإدخال عند الظهور
	input_line.grab_focus()

func _on_confirm_button_pressed():
	var player_name_input = input_line.text.strip_edges() # حذف الفراغات
	
	if player_name_input.length() > 4: # ⬅️ يجب أن يكون الاسم 5 أحرف على الأقل
		name_entered.emit(player_name_input) # إرسال الاسم إلى Home.gd
		queue_free() # حذف النافذة
	else:
		print("Please enter a name with at least 3 characters.")
		# يمكنك إضافة Label لإظهار رسالة الخطأ للاعب


# 💡 ربط إشارة text_submitted بـ _on_confirm_button_pressed
func _on_name_line_edit_text_submitted(_new_text):
	_on_confirm_button_pressed()
