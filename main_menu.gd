extends Control

## The text to show on the mute button if the sound is unmuted
const MUTE_STRING = "Mute Sound"
## An array of platforms where quitting is not available or doesn't make sense
const NO_QUIT_PLATFORMS: Array[String] = ["Android", "iOS", "Web"]
## The text to show on the mute button if the sound is muted
const UNMUTE_STRING = "Unmute Sound"

@export_file("*.tscn") var game_scene: String

@onready var help_pop_up: MarginContainer = $HelpPopUp
@onready var muted: bool = SaveSystem.get_global("muted", false)
@onready var mute_button: Button = %MuteButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	assert(game_scene, "No game scene set, Play button will not work")

	if OS.get_name() in NO_QUIT_PLATFORMS:
		quit_button.visible = false

	if muted:
		AudioSystem.mute(muted)
		mute_button.text = UNMUTE_STRING if muted else MUTE_STRING


## Toggle the help text
func _on_help() -> void:
	# By making this a toggle, we can use it for both the 'Help' and 'Close' buttons
	help_pop_up.visible = not help_pop_up.visible


## Toggle whether audio playback is muted
func _on_mute() -> void:
	muted = not muted
	SaveSystem.save_global("muted", muted)
	AudioSystem.mute(muted)
	mute_button.text = UNMUTE_STRING if muted else MUTE_STRING


## Transition to the main scene of the game
func _on_play() -> void:
	get_tree().change_scene_to_file(game_scene)


## Quit the game
func _on_quit() -> void:
	assert(
		OS.get_name() not in NO_QUIT_PLATFORMS,
		"Platform should not quit, but quit was triggered"
	)

	get_tree().quit()
