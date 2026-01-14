extends Resource
class_name Combo

enum valid_inputs {Left,Right,Forward,Backward,Attack,Special,Block}
@export var combo_type : String
@export var sequence : Array[valid_inputs] = []
