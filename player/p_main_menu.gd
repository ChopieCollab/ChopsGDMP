extends Pawn

const MAIN_MENU = preload("uid://btr8vxyrwuyfj")
var MainMenu

func _ready() -> void:
	MainMenu = GameManager.Main_Root.ui_container.open_ui(MAIN_MENU)
	print("HEYYYYYYYYYYYY")

func _exit_tree():
	GameManager.Main_Root.ui_container.close_ui(MainMenu)
	print("BYYYY")
