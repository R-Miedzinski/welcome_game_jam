extends Node

@onready var ui_scene: CanvasLayer = %UI
@onready var menu_scene: CanvasLayer = %Menu
@onready var main_menu: Control = self.menu_scene.get_node("%MainMenu")
@onready var pause_menu: Control = self.menu_scene.get_node("%PauseMenu")
var is_game_active: bool = true

@onready var level_scene: Node3D = %Level
@onready var grid_controller: GridController = self.level_scene.get_node("%Grid")
@onready var enemies_controller: EnemiesController = self.level_scene.get_node("%Enemies")
@onready var tower_controller: TowerController = self.level_scene.get_node("%Tower")
@onready var camera: Camera3D = self.level_scene.get_node("%MainCamera")
@onready var spawner_timer_label: Label = %SpawnTimer
@onready var score_label: Label = %Score

var last_highlighted_tile: Vector2i = Vector2i(-1, -1)
var last_highlight_range: int = 1

@onready var game_viewport: SubViewportContainer = %GameViewport
@onready var brewing_viewport: SubViewportContainer = %BrewingViewport

@onready var sfx: Node = %SFX

var aim_marker: Node3D = null

func _process(delta: float) -> void:
  if Input.is_action_just_pressed("pause"):
    if self.is_game_active:
      if self.get_tree().paused:
        self._on_unpause_clicked()
      else:
        self._on_pause_clicked()

  if self.get_tree().paused:
    return

  self.score_label.text = Constants.SCORE_LABEL_TEXT + self.grid_controller.get_survival_time()

  var mouse_pos: Vector2 = self.get_viewport().get_mouse_position()
  if mouse_pos.y <= self.game_viewport.get_node("SubViewport").size.y:
    self.handle_mouse_in_game_viewport(mouse_pos)
  # else:
  #   self.handle_mouse_in_brewing_viewport(mouse_pos)

func handle_mouse_in_game_viewport(mouse_pos: Vector2) -> void:
  var tile_coords: Vector2i = self.get_tile_under_mouse(mouse_pos)
  if tile_coords != self.last_highlighted_tile:
    if self.last_highlighted_tile.x != -1 and self.last_highlighted_tile.y != -1:
      self.grid_controller.unhighlight_tile(self.last_highlighted_tile, last_highlight_range)
    self.last_highlighted_tile = tile_coords
    self.last_highlight_range = self.tower_controller.selected_potion.size if self.tower_controller.selected_potion != null else 1

  if tile_coords.x != -1 and tile_coords.y != -1:
    self.grid_controller.highlight_tile(tile_coords, self.last_highlight_range)
  elif self.aim_marker != null:
    self.aim_marker.queue_free()
    self.aim_marker = null

  if Input.is_action_just_pressed("grid_interact"):
    if tile_coords.x != -1 and tile_coords.y != -1:
      self.tower_controller.shoot(tile_coords)

func get_tile_under_mouse(mouse_pos: Vector2) -> Vector2i:
    var ray_origin: Vector3 = self.camera.project_ray_origin(mouse_pos)
    var ray_direction: Vector3 = self.camera.project_ray_normal(mouse_pos)

    var plane_y = 0.0
    if ray_direction.y == 0:
      return Vector2i(-1, -1) # Ray is parallel to the plane
    var t = (plane_y - ray_origin.y) / ray_direction.y
    if t < 0:
        return Vector2i(-1, -1) # Ray does not intersect the plane

    var intersection = ray_origin + ray_direction * t
    var coordinates = self.grid_controller.position_to_coordinates(intersection)
    if coordinates.x < 0 or coordinates.x >= self.grid_controller.grid_size.x \
    or coordinates.y < 0 or coordinates.y >= self.grid_controller.grid_size.y:
        return Vector2i(-1, -1)

    if self.aim_marker == null:
      self.aim_marker = Preloads.TARGET.instantiate() as Node3D
      self.aim_marker.position = intersection
      self.level_scene.add_child(self.aim_marker)
    else:
      self.aim_marker.position = intersection
      
    return coordinates

# func handle_mouse_in_brewing_viewport(mouse_pos: Vector2) -> void:
#   # print("Mouse in brewing viewport at position: %s" % mouse_pos)
#   pass

func _ready() -> void:
  self.sfx.get_node("MuzykaDoMordowaniaGnomów").play()
  self.sfx.get_node("MuzykaDoMordowaniaGnomów").connect("finished", self._on_soundtrack_finished)
  
  # Setup UI and Menu screens
  self.ui_scene.process_mode = Node.ProcessMode.PROCESS_MODE_PAUSABLE
  self.menu_scene.process_mode = Node.ProcessMode.PROCESS_MODE_WHEN_PAUSED
  self._first_menu_load()

  self.tower_controller.connect("tower_destroyed", self._on_tower_destroyed)

func _on_soundtrack_finished() -> void:
  self.sfx.get_node("MuzykaDoMordowaniaGnomów").play()

func _on_spawner_timer_update(time_left: float) -> void:
  self.spawner_timer_label.text = "Next Spawn In: %.1f s" % time_left

func _first_menu_load() -> void:
  var menu_button_box = self.main_menu.get_node("ButtonBox")
  menu_button_box.get_node("Label").text = Constants.MAIN_MENU_TITLE
  menu_button_box.get_node("Play").text = Constants.MAIN_MENU_START_BUTTON
  menu_button_box.get_node("Quit").text = Constants.MAIN_MENU_EXIT_BUTTON

  var pause_button_box = self.pause_menu.get_node("ButtonBox")
  pause_button_box.get_node("Label").text = Constants.PAUSE_MENU_TITLE
  pause_button_box.get_node("Unpause").text = Constants.PAUSE_MENU_RESUME_BUTTON
  pause_button_box.get_node("Menu").text = Constants.PAUSE_MENU_MAIN_MENU_BUTTON
  pause_button_box.get_node("Quit").text = Constants.PAUSE_MENU_EXIT_BUTTON

  self.is_game_active = false
  self.main_menu.visible = true
  self.pause_menu.visible = false
  self.get_tree().paused = true

func _open_main_menu() -> void:
  self.is_game_active = false
  self.main_menu.visible = true
  self.pause_menu.visible = false
  self.get_tree().paused = true
  self.get_tree().reload_current_scene()

func _pause_game() -> void:
  self.is_game_active = false
  self.main_menu.visible = false
  self.pause_menu.visible = true
  self.get_tree().paused = true

func _unpause_game() -> void:
  self.is_game_active = true
  self.main_menu.visible = false
  self.pause_menu.visible = false
  self.get_tree().paused = false

func _start_game() -> void:
  self.is_game_active = true
  self.main_menu.visible = false
  self.pause_menu.visible = false
  self.get_tree().paused = false

func _game_over() -> void:
  var pause_button_box = self.pause_menu.get_node("ButtonBox")
  pause_button_box.get_node("Label").text = Constants.GAME_OVER_TITLE
  pause_button_box.get_node("Unpause").visible = false
  pause_button_box.get_node("Score").text = Constants.FINAL_SCORE_TEXT + self.grid_controller.get_survival_time()
  pause_button_box.get_node("Score").visible = true

  self.is_game_active = false
  self.pause_menu.visible = true
  self.main_menu.visible = false
  self.get_tree().paused = true

func _on_tower_destroyed() -> void:
  print("Game Over! The tower has been destroyed.")
  self._game_over()

func _on_pause_clicked() -> void:
  self.sfx.get_node("MenuClick").play()
  self._pause_game()

func _on_unpause_clicked() -> void:
  self.sfx.get_node("MenuClick").play()
  self._unpause_game()

func _on_main_menu_clicked() -> void:
  self.sfx.get_node("MenuClick").play()
  self._open_main_menu()
  
func _on_play_clicked() -> void:
  self.sfx.get_node("MenuClick").play()
  self._start_game()

func _on_quit_clicked() -> void:
  self.sfx.get_node("MenuClick").play()
  self.sfx.get_node("MenuClick").finished.connect(self.get_tree().quit)
