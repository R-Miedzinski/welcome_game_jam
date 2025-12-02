extends Node

@onready var level_scene: Node3D = %Level
@onready var grid_controller: GridController = level_scene.get_node("%Grid")
@onready var enemies_controller: EnemiesController = level_scene.get_node("%Enemies")
@onready var tower_controller: TowerController = level_scene.get_node("%Tower")
@onready var camera: Camera3D = level_scene.get_node("%MainCamera")

var last_highlighted_tile: Vector2i = Vector2i(-1, -1)

var debug_sphere: MeshInstance3D = null

func _process(delta: float) -> void:
  if Input.is_action_just_pressed("ui_select"):
    level_scene.get_node("%Spawners").spawn_enemy_at_random()

  var mouse_pos: Vector2 = self.get_viewport().get_mouse_position()
  var tile_coords: Vector2i = self.get_tile_under_mouse(mouse_pos)
  if tile_coords != last_highlighted_tile:
    if last_highlighted_tile.x != -1 and last_highlighted_tile.y != -1:
      grid_controller.unhighlight_tile(last_highlighted_tile)
    last_highlighted_tile = tile_coords

  if tile_coords.x != -1 and tile_coords.y != -1:
    grid_controller.highlight_tile(tile_coords)

  if Input.is_action_just_pressed("grid_interact"):
    print("Interacted with tile at coordinates: %s" % tile_coords)
    if tile_coords.x != -1 and tile_coords.y != -1:
      tower_controller.shoot(tile_coords)

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
    var coordinates = grid_controller.position_to_coordinates(intersection)
    if coordinates.x < 0 or coordinates.x >= grid_controller.grid_size.x \
    or coordinates.y < 0 or coordinates.y >= grid_controller.grid_size.y:
        return Vector2i(-1, -1)

    if debug_sphere == null:
      debug_sphere = MeshInstance3D.new()
      debug_sphere.mesh = SphereMesh.new()
      debug_sphere.mesh.radius = 0.3
      var mat = StandardMaterial3D.new()
      mat.albedo_color = Color(1, 0, 0, 0.5)
      debug_sphere.mesh.material = mat

      debug_sphere.position = intersection
      level_scene.add_child(debug_sphere)
    else:
      debug_sphere.position = intersection
    return coordinates
