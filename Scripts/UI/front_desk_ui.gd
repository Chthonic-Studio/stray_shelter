# Scripts/UI/front_desk_ui.gd
extends Control

@onready var close_button: Button = $PanelContainer/MainLayout/Header/CloseButton
@onready var name_label: Label = $PanelContainer/MainLayout/ContentLayout/LeftPanel_Adopter/NameLabel
@onready var housing_label: Label = $PanelContainer/MainLayout/ContentLayout/LeftPanel_Adopter/HousingLabel
@onready var child_label: Label = $PanelContainer/MainLayout/ContentLayout/LeftPanel_Adopter/ChildLabel
@onready var income_label: Label = $PanelContainer/MainLayout/ContentLayout/LeftPanel_Adopter/IncomeLabel
@onready var breed_pref: Label = $PanelContainer/MainLayout/ContentLayout/LeftPanel_Adopter/BreedPreference
@onready var bio_text: RichTextLabel = $PanelContainer/MainLayout/ContentLayout/LeftPanel_Adopter/BioText

@onready var pet_list_container: VBoxContainer = $PanelContainer/MainLayout/ContentLayout/RightPanel_PetList/PetScroll/PetListContainer
@onready var selected_pet_label: Label = $PanelContainer/MainLayout/ContentLayout/RightPanel_PetList/SelectionDetails/SelectedPetName
@onready var compatibility_meter: ProgressBar = $PanelContainer/MainLayout/ContentLayout/RightPanel_PetList/SelectionDetails/CompatibilityMeter
@onready var compatibility_text: Label = $PanelContainer/MainLayout/ContentLayout/RightPanel_PetList/SelectionDetails/CompatibilityText

@onready var deny_button: Button = $PanelContainer/MainLayout/Footer/DenyButton
@onready var approve_button: Button = $PanelContainer/MainLayout/Footer/ApproveButton

var current_adopter: AdopterProfile = null
var current_selected_pet: PetData = null
var pets_list: Array[PetData] = []

func _ready() -> void:
	# Connect static UI buttons
	close_button.pressed.connect(_on_close_pressed)
	deny_button.pressed.connect(_on_deny_pressed)
	approve_button.pressed.connect(_on_approve_pressed)
	
	approve_button.disabled = true
	
	UIManager.register_modular_menu("front_desk", self)
		
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if visible:
		generate_random_adopter()
		load_shelter_pets()
		reset_pet_selection()

func generate_random_adopter() -> void:
	# Instantiates a random adopter profile for matching
	current_adopter = AdopterProfile.new()
	current_adopter.adopter_name = ["Jane Miller", "Bob Vance", "Clara Oswald", "David Tennant", "Elena Gilbert"].pick_random()
	current_adopter.housing_type = ["Apartment", "House", "Fenced_Yard"].pick_random()
	current_adopter.is_child_friendly = [true, false].pick_random()
	current_adopter.monthly_income = randf_range(1800.0, 4200.0)
	current_adopter.preferred_species = randi_range(0, 1) # DOG or CAT
	current_adopter.preferred_temperament = randi_range(0, 4) # Match Temperament enum
	current_adopter.willing_to_treat_sick = [true, false].pick_random()
	
	# Display details
	name_label.text = "Name: " + current_adopter.adopter_name
	housing_label.text = "Housing: " + current_adopter.housing_type
	child_label.text = "Has Kids/Noisy Home: " + ("Yes" if current_adopter.is_child_friendly else "No")
	income_label.text = "Monthly Income: $%d" % current_adopter.monthly_income
	
	var species_str = "Dog" if current_adopter.preferred_species == 0 else "Cat"
	breed_pref.text = "Looking for: " + species_str
	
	bio_text.text = "Hi! I am searching for a suitable companion for my home. I hope to find a pet that matches my environment."

func load_shelter_pets() -> void:
	# Clear previous list
	for child in pet_list_container.get_children():
		child.queue_free()
		
	pets_list.clear()
	
	# Fetch pets from PetManager list (Simulated or actual registry)
	# In a real game, PetManager keeps an array of active PetData. Let's populate some mock ones for UI display if empty.
	# Let's populate a default list of shelter pets
	var p1 = PetData.new()
	p1.pet_name = "Rusty"
	p1.species = PetData.Species.DOG
	p1.temperament = PetData.Temperament.PLAYFUL
	p1.energy = 90.0
	p1.is_sick = false
	pets_list.append(p1)
	
	var p2 = PetData.new()
	p2.pet_name = "Luna"
	p2.species = PetData.Species.CAT
	p2.temperament = PetData.Temperament.CALM
	p2.energy = 30.0
	p2.is_sick = false
	pets_list.append(p2)
	
	var p3 = PetData.new()
	p3.pet_name = "Bella"
	p3.species = PetData.Species.DOG
	p3.temperament = PetData.Temperament.ANXIOUS
	p3.energy = 65.0
	p3.is_sick = true
	p3.disease_name = "Minor Cold"
	pets_list.append(p3)
	
	# Instantiate buttons
	for pet in pets_list:
		var btn = Button.new()
		var species_icon = "🐶 " if pet.species == PetData.Species.DOG else "🐱 "
		btn.text = species_icon + pet.pet_name + " (%s)" % get_temperament_name(pet.temperament)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _on_pet_selected(pet))
		pet_list_container.add_child(btn)

func reset_pet_selection() -> void:
	current_selected_pet = null
	selected_pet_label.text = "No Pet Selected"
	compatibility_meter.value = 0
	compatibility_text.text = "Select an animal to see compliance rating"
	approve_button.disabled = true

func _on_pet_selected(pet: PetData) -> void:
	current_selected_pet = pet
	selected_pet_label.text = "Selected Pet: " + pet.pet_name
	
	# Calculate score
	if has_node("/root/AdoptionManager") and current_adopter:
		var score = get_node("/root/AdoptionManager").calculate_compatibility_compatibility(pet, current_adopter)
		compatibility_meter.value = score
		
		var evaluation = get_node("/root/AdoptionManager").process_placement_decision(pet, current_adopter)
		compatibility_text.text = evaluation["notes"]
		approve_button.disabled = false
	else:
		# Fallback simulation score
		compatibility_meter.value = 75
		compatibility_text.text = "Compatibility checks passed!"
		approve_button.disabled = false

func _on_approve_pressed() -> void:
	if not current_selected_pet or not current_adopter: return
	
	# Complete matching transactions
	if has_node("/root/AdoptionManager"):
		var score = get_node("/root/AdoptionManager").calculate_compatibility_compatibility(current_selected_pet, current_adopter)
		
		# Base fee is $250. Adds negotiator modifiers
		var base_fee = 250.0
		if has_node("/root/GameManager") and get_node("/root/GameManager").active_player_data:
			if get_node("/root/GameManager").active_player_data.manager_trait == "Negotiator":
				base_fee *= 1.15
				
		if score >= 50.0:
			# Success! Payout
			if has_node("/root/EconomyManager"):
				get_node("/root/EconomyManager").add_funds(base_fee, "Adoption Fee: " + current_selected_pet.pet_name, "Adoption")
				get_node("/root/EconomyManager").increase_renown(5.0)
				
			# Emit placement
			get_node("/root/AdoptionManager").adoption_finalized.emit(current_selected_pet, current_adopter)
		else:
			# Failed match return penalty
			if has_node("/root/EconomyManager"):
				get_node("/root/EconomyManager").decrease_renown(8.0)
				
			get_node("/root/AdoptionManager").adoption_returned.emit(current_selected_pet, "Adopter returned pet: incompatibility")
			
	_on_close_pressed()

func _on_deny_pressed() -> void:
	# Decline adopter politely, renown takes a tiny hit but avoids returns
	if has_node("/root/EconomyManager"):
		get_node("/root/EconomyManager").decrease_renown(1.5)
	_on_close_pressed()

func _on_close_pressed() -> void:
	# Dismiss UI window cleanly
	if has_node("/root/UIManager"):
		get_node("/root/UIManager").toggle_menu_window("front_desk")
	else:
		visible = false

func get_temperament_name(temp: int) -> String:
	match temp:
		0: return "Anxious"
		1: return "Playful"
		2: return "Gluttonous"
		3: return "Independent"
		4: return "Calm"
		_: return "Friendly"
