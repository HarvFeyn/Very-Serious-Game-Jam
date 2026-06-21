extends Node

const BUS_MASTER: String = "Master"
const BUS_MUSIC: String = "Music"
const BUS_SFX: String = "SFX"

var _sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _interactive_stream: AudioStreamInteractive = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_sfx_player.bus = BUS_SFX
	add_child(_sfx_player)

	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)

	_apply_settings()


func play_interactive_music(stream: AudioStreamInteractive) -> void:
	if stream == null:
		return
	_interactive_stream = stream
	_music_player.stream = stream
	_music_player.play()


func set_music_state(state: MusicEnums.MusicState) -> void:
	if _interactive_stream == null:
		push_error("AudioManager: aucun AudioStreamInteractive chargé !")
		return
	var playback: AudioStreamPlaybackInteractive = \
		_music_player.get_stream_playback() as AudioStreamPlaybackInteractive
	if playback == null:
		return
	playback.switch_to_clip(state)


func stop_music() -> void:
	_music_player.stop()
	_interactive_stream = null


func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	_sfx_player.stream = stream
	_sfx_player.play()


func set_volume(bus_name: String, value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_error("AudioManager: bus '%s' introuvable !" % bus_name)
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	SettingsManager.set_setting("audio", bus_name.to_lower(), value)


func get_volume(bus_name: String) -> float:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_error("AudioManager: bus '%s' introuvable !" % bus_name)
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))


func _apply_settings() -> void:
	set_volume(BUS_MASTER, SettingsManager.get_setting("audio", "master"))
	set_volume(BUS_MUSIC, SettingsManager.get_setting("audio", "music"))
	set_volume(BUS_SFX, SettingsManager.get_setting("audio", "sfx"))
