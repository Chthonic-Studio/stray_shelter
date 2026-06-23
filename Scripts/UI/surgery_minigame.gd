# Scripts/UI/surgery_minigame.gd
extends Control

@onready var track_bg: Panel = $PanelContainer/MainLayout/TimingBarContainer/TrackBackground
@onready var target_zone: ColorRect = $PanelContainer/MainLayout/TimingBarContainer/TrackBackground/TargetZone
@onready var slider_tick: ColorRect = $PanelContainer/MainLayout/TimingBarContainer/TrackBackground/SliderTick
@onready var severity_bar: ProgressBar = $PanelContainer/MainLayout/PatientDetails/SeverityProgress
@onready var console_logs: Label = $PanelContainer/MainLayout/ConsoleLogs

var slider_position: float = 0.0
var slider_direction: int = 1
var slider_speed: float = 1.3
var target_start: float = 0.4
var target_end: float = 0.6
var current_patient: PetData = null

func _process(delta: float) -> void:
	slider_position += slider_speed * delta * slider_direction
	if slider_position >= 1.0:
		slider_position = 1.0
		slider_direction = -1
	elif slider_position <= 0.0:
		slider_position = 0.0
		slider_direction = 1
	if track_bg:
		slider_tick.position.x = slider_position * track_bg.size.x
