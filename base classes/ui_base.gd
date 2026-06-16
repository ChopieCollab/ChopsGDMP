class_name UIBase
extends Control

@export_category("UI Settings")
enum LayerType {BACKGROUND, HUD, MENU, OVERLAY}
@export var target_layer: LayerType = LayerType.MENU
## The background layer is by default -1. This means that if you have cameras hidden or you aren't drawing anything in the viewport you can have this layer rendered.
## The HUD layer is at 1 by default, which is just above the actual world. Think of all HUD elements in video games. You could also choose to render first person hands here.
## Menus would be on layer 5 by default, which is above the HUD. think pause menus and scoreboards. There is some custom functionality for this layer, shown in ui_container.gd
## The overlay layer is drawn on 10 by default. This would be something that goes over EVERYTHING else... which might be a little rare. Imagine FPS counter, or possibly alerts and maybe even version of the game.


func on_open() -> void:
	pass #override this func with your on opening of the menu behavior

func on_close() -> void:
	queue_free() # override this with your own logic if you wish, but this is mainly for the menu logic

func on_reveal() -> void:
	pass #override this func with your on re-opening of menu behavior. So like if you closed it, and then reshowed it.
## NOTICE: Could be expanded upon! I encourage it!
