extends Node
## Manages background music and sound effects

const WRONG_BUS_ERR: String = "AudioStreamPlayer '%s' has wrong bus '%s', expected '%s'"

## AudioStreamPlayer node responsible for background music
@onready var bgm: AudioStreamPlayer = $BGM

## Whether sounds are currently muted
var muted: bool = false
## Dictionary of AudioStreamPlayer nodes for different sound effects, auto-initialised on start as
## the children of the SFX node
var sfx: Dictionary[String, AudioStreamPlayer] = {}


# Runs when the scene is loaded (since this scene is auto-loaded, that is when the game starts)
func _ready() -> void:
	# Ensure the BGM is set to the correct bus during development
	assert(bgm.bus == "BGM", WRONG_BUS_ERR % [bgm.name, bgm.bus, "BGM"])

	# Automatically load all the AudioStreamPlayer children of 'SFX' into a dictionary, with the key
	# being the name of the node
	for node in $SFX.get_children():
		if not node is AudioStreamPlayer:
			continue

		# Cast is required for typing even after type guard
		var player: AudioStreamPlayer = node
		assert(player.bus == "SFX", WRONG_BUS_ERR % [player.name, player.bus, "SFX"])
		sfx[player.name] = player


## Controls whether sound should be muted. When muted, audio will be muted, the background music
## will be stopped, and sound effects will not play (to save CPU resources). Un-muting will re-start
## the background music.
func mute(enable: bool) -> void:
	AudioServer.set_bus_mute(0, enable)

	if enable:
		bgm.stop()
	else:
		bgm.play()


## Plays a sound continuously, only starting it if it wasn't playing already
func play_continuous(effect: String) -> void:
	if muted:
		return

	var player: AudioStreamPlayer = sfx.get(effect)

	if not player.playing:
		player.play()


## Play a sound effect with some variance in pitch (default ±0.2), returns a coroutine that yields
## when the sound effect finishes playing
func play_with_variance(effect: String, variance: float = 0.2) -> void:
	if muted:
		return

	var player: AudioStreamPlayer = sfx.get(effect)
	assert(player, "Tried to play invalid sound '%s'" % effect)

	player.pitch_scale = randf_range(1 - variance, 1 + variance)
	player.play()
	await player.finished


## Stops a continuously playing sound, only calling 'stop' it if it was playing
func stop_continuous(effect: String) -> void:
	if muted:
		return

	var player: AudioStreamPlayer = sfx.get(effect)

	if player.playing:
		player.stop()
