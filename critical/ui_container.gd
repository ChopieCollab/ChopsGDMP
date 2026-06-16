extends Node

# Grab your fixed layers
@onready var background_layer: CanvasLayer = $BackgroundLayer
@onready var hud_layer: CanvasLayer = $HUDLayer
@onready var menu_layer: CanvasLayer = $MenuLayer
@onready var overlay_layer: CanvasLayer = $OverlayLayer

@onready var layers = {
	UIBase.LayerType.BACKGROUND: background_layer,
	UIBase.LayerType.HUD: hud_layer,
	UIBase.LayerType.MENU: menu_layer,
	UIBase.LayerType.OVERLAY: overlay_layer
}

var menu_stack: Array[UIBase] = []

func open_ui(ui_scene: PackedScene):
	var ui_instance = ui_scene.instantiate() as UIBase
	if ui_instance == null:
		push_error("Extend your UI off of UIBase or I will in fact kill you.")
		return
	
	var target = ui_instance.target_layer
	layers[target].add_child(ui_instance)
	
	# Custom menu layer logic
	if target == UIBase.LayerType.MENU:
		# Can be changed here, but by default it will hide the old "top" menu when adding a new one. So if I open menu A and then open B, A will be hidden since B just got opened.
		if menu_stack.size() > 0:
			menu_stack.back().hide()
		menu_stack.push_back(ui_instance)
	
	ui_instance.on_open() # Basically the on ready lol
	return ui_instance

func close_top_menu() -> void:
	if menu_stack.size() == 0:
		return
	
	# should remove the top menu from the array, then we go delete it 
	var top_menu = menu_stack.pop_back()
	top_menu.on_close() # most will have queue_free() in their on_close... hopefully..
	
	# if there is another menu underneath, reveal it
	if menu_stack.size() > 0:
		menu_stack.back().show()
		menu_stack.back().on_reveal()

func close_ui(ui_instance: UIBase) -> void:
	if ui_instance == null:
		push_error("You tried to close a UI that doesn't exist goober. Who are you fighting?")
		return

	if ui_instance.target_layer == UIBase.LayerType.MENU:
		if menu_stack.has(ui_instance):
			if menu_stack.back() == ui_instance:
				close_top_menu()
				return 
			else:
				menu_stack.erase(ui_instance)
	# if its NOT a menu type, it'll just do the normal on close.
	ui_instance.on_close()
