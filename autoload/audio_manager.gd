extends Node

const BUS_MASTER: String = "Master"
const BUS_MUSIC: String = "Music"
const BUS_SFX: String = "SFX"

var _music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _interactive_stream: AudioStreamInteractive = null
var music_playing: MusicEnums.MusicState = MusicEnums.MusicState.NONE

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)
	_apply_settings()

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	player.bus = BUS_SFX
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.play()

	player.finished.connect(player.queue_free)

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
	music_playing = state

func stop_music() -> void:
	_music_player.stop()
	_interactive_stream = null
	music_playing = MusicEnums.MusicState.NONE
	
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
