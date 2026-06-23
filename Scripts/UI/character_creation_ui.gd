# Scripts/UI/character_creator_ui.gd
extends Control

@onready var name_input: LineEdit = $MainLayout/LeftPanel/NameSection/NameInput
@onready var pronoun_options: OptionButton = $MainLayout/LeftPanel/PronounSection/PronounOptions
@onready var color_picker: ColorPickerButton = $MainLayout/LeftPanel/ColorSection/ColorPickerButton
@onready var trait_options: OptionButton = $MainLayout/LeftPanel/TraitSection/TraitOptions
@onready var trait_description: Label = $MainLayout/LeftPanel/TraitSection/TraitDescription
@onready var preview_char: TextureRect = $MainLayout/RightPanel/PreviewCharacter

const MAIN_SCENE_PATH = "res://Scenes/main.tscn"
const TRAITS = ["Green Thumb", "Negotiator", "Vet Apprentice", "Hardworker"]
const PRONOUNS = ["They/Them", "He/Him", "She/Her"]

func _ready() -> void:
	pronoun_options.clear()
	for p in PRONOUNS: pronoun_options.add_item(p)
	trait_options.clear()
	for t in TRAITS: trait_options.add_item(t)
	
	trait_options.item_selected.connect(_on_trait_selected)
	color_picker.color_changed.connect(_on_color_changed)
	$MainLayout/LeftPanel/StartButton.pressed.connect(_on_start_pressed)
	
	_on_trait_selected(0)
	_on_color_changed(color_picker.color)

func _on_trait_selected(index: int) -> void:
	var chosen_trait = TRAITS[index]
	var temp_res = PlayerData.new()
	temp_res.manager_trait = chosen_trait
	trait_description.text = temp_res.get_trait_description()

func _on_color_changed(color: Color) -> void:
	preview_char.self_modulate = color

func _on_start_pressed() -> void:
	var player_name = name_input.text.strip_edges()
	if player_name == "": player_name = "Alex"
	
	var player_data = PlayerData.new()
	player_data.player_name = player_name
	player_data.pronouns = PRONOUNS[pronoun_options.selected]
	player_data.clothing_color = color_picker.color
	player_data.manager_trait = TRAITS[trait_options.selected]
	
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").set("active_player_data", player_data)
		
	ResourceSaver.save(player_data, "user://player_profile.tres")
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
