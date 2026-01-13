extends Node
# STEP ONE : DECLARE SIGNALS AND DEFAULTS FOR THE GAME

## Options Menu
# Audio
signal audio_bus_toggled_on(toggled_on, bus_name)
signal audio_slider_changed(value, bus_name)

const SAVE_FILE_PATH = "user://options.save" # save file can be named whatever, the user file is setup in project settings app config user folder dir

## DEFAULTS
var save_data: Dictionary = {
	"audio_data": {
		"bgm_toggled_on": true,
		"bgm_slider_amount": 1.0,
		"sfx_toggled_on": true,
		"sfx_slider_amount": 1.0
	}
}


func _ready():
	# Load the document's data
	load_save_file()
	# If no data is found, the file will be created. Once an option is changed, the options file will be overwritten by the function called to change the value


func load_save_file():
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		save()
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var() 
	#get_variant : if there is a save_data variant in the file, use that to override the save_data variable
	print("Options : save_data : ", save_data)

# STEP 3 : Add the dictionary to the save data
func save(item_to_save = null):
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if item_to_save == null:
		file.store_var(save_data)
	print("\nOptions : DATA SAVED SUCCESSFULLY : ", save_data,"\n")


func emit_audio_bus_toggled_on(toggled_on, bus_name):
	match bus_name:
		"BGM":
			save_data["audio_data"]["bgm_toggled_on"] = toggled_on
		"SFX":
			save_data["audio_data"]["sfx_toggled_on"] = toggled_on
	save()
	audio_bus_toggled_on.emit(toggled_on, bus_name)


func emit_audio_slider_changed(value, bus_name):
	match bus_name:
		"BGM":
			save_data["audio_data"]["bgm_slider_amount"] = value
		"SFX":
			save_data["audio_data"]["sfx_slider_amount"] = value
	save()
	audio_slider_changed.emit(value, bus_name)
