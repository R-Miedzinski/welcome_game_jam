extends Node

@onready var level_scene: Node3D = %Level
@onready var grid_controller: GridController = level_scene.get_node("%Grid")
@onready var enemies_controller: EnemiesController = level_scene.get_node("%Enemies")
@onready var tower_controller: TowerController = level_scene.get_node("%Tower")
@onready var camera: Camera3D = level_scene.get_node("%MainCamera")

var last_highlighted_tile: Vector2i = Vector2i(-1, -1)

@onready var game_viewport: SubViewportContainer = %GameViewport
@onready var brewing_viewport: SubViewportContainer = %BrewingViewport

var debug_sphere: MeshInstance3D = null

func _process(delta: float) -> void:
  if Input.is_action_just_pressed("ui_select"):
    self.level_scene.get_node("%Spawners").spawn_enemy_at_random()

  var mouse_pos: Vector2 = self.get_viewport().get_mouse_position()
  if mouse_pos.y > self.game_viewport.get_node("SubViewport").size.y:
    self.handle_mouse_in_brewing_viewport(mouse_pos)
  else:
    self.handle_mouse_in_game_viewport(mouse_pos)

func handle_mouse_in_game_viewport(mouse_pos: Vector2) -> void:
  var tile_coords: Vector2i = self.get_tile_under_mouse(mouse_pos)
  if tile_coords != self.last_highlighted_tile:
    if self.last_highlighted_tile.x != -1 and self.last_highlighted_tile.y != -1:
      self.grid_controller.unhighlight_tile(self.last_highlighted_tile)
    self.last_highlighted_tile = tile_coords

  if tile_coords.x != -1 and tile_coords.y != -1:
    self.grid_controller.highlight_tile(tile_coords)

  if Input.is_action_just_pressed("grid_interact"):
    # print("Interacted with tile at coordinates: %s" % tile_coords)
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

    if self.debug_sphere == null:
      self.debug_sphere = MeshInstance3D.new()
      self.debug_sphere.mesh = SphereMesh.new()
      self.debug_sphere.mesh.radius = 0.3
      var mat = StandardMaterial3D.new()
      mat.albedo_color = Color(1, 0, 0, 0.5)
      self.debug_sphere.mesh.material = mat

      self.debug_sphere.position = intersection
      self.level_scene.add_child(self.debug_sphere)
    else:
      self.debug_sphere.position = intersection
      
    return coordinates

func handle_mouse_in_brewing_viewport(mouse_pos: Vector2) -> void:
  # print("Mouse in brewing viewport at position: %s" % mouse_pos)
  pass
