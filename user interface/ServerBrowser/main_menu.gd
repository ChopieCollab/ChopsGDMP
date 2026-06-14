extends UIBase

@onready var server_browser: Control = $ServerBrowser

func _ready() -> void:
	server_browser.sb_join.connect(CloseMyself)
	server_browser.sb_host.connect(CloseMyself)
	server_browser.sb_join_lan_debug.connect(CloseMyselfDebug)
	server_browser.sb_host_lan_debug.connect(CloseMyselfDebug)

func CloseMyself(a, b, c) -> void:
	## Just showing off the menu closing array thing.
	GameManager.Main_Root.ui_container.close_top_menu()
	## You could also just queue free this by going:
	#self.on_close()
	# or
	#self.queue_free()

func CloseMyselfDebug() -> void:
	## Just showing off the menu closing array thing.
	GameManager.Main_Root.ui_container.close_top_menu()
	## You could also just queue free this by going:
	#self.on_close()
	# or
	#self.queue_free()
