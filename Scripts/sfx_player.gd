extends Node

const audio_bus : StringName = "SFXBus"
const max_buffer_size : int = 20
var buffer : Array[AudioStreamPlayer3D]
var buffer_index : int = 0
var sfx_root : Node3D

var audio_buffer : Dictionary[String,AudioStreamOggVorbis]


func _ready() -> void:
	create_buffer_audio_streams()

func create_buffer_audio_streams() -> void:
	sfx_root = Node3D.new()
	sfx_root.name = "SfxRoot"
	add_child(sfx_root)
	
	buffer.resize(max_buffer_size)
	
	for i in range(max_buffer_size):
		var stream_3d : AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		stream_3d.bus = audio_bus
		sfx_root.add_child(stream_3d)
		buffer[i] = stream_3d

func play_sfx(sound_effect : String, play_position : Vector3) -> void:
	if not audio_buffer.has(sound_effect):
		print("Sound effect not found! (%s)" % sound_effect)
		return
	
	var audio_stream : AudioStreamPlayer3D = buffer[buffer_index]
	audio_stream.stream = audio_buffer[sound_effect]
	
	audio_stream.global_position = play_position
