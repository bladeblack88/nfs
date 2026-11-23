extends Node3D

const ROAD_LENGTH := 620.0
const ROAD_WIDTH := 18.0
const ACCELERATION := 34.0
const MAX_SPEED := 58.0
const BRAKE_POWER := 65.0
const TURN_RATE := 1.75

var car: CharacterBody3D
var speed := 0.0
var steer_input := 0.0
var throttle_input := 0.0
var brake_input := false
var camera: Camera3D
var speed_label: Label
var heat_label: Label
var mission_label: Label
var traffic_cars: Array[Node3D] = []
var police_cars: Array[Node3D] = []
var heat_seconds := 0.0
var wanted_level := 0
var mission_finished := false
var car_paint: StandardMaterial3D

func _ready() -> void:
    _build_world()
    _build_car()
    _build_camera()
    _build_hud()
    _build_traffic()
    _build_police()

func _physics_process(delta: float) -> void:
    if car == null:
        return
    if throttle_input > 0.0:
        speed = move_toward(speed, MAX_SPEED, ACCELERATION * delta)
    elif throttle_input < 0.0:
        speed = move_toward(speed, -MAX_SPEED * 0.35, ACCELERATION * delta)
    else:
        speed = move_toward(speed, 0.0, 8.0 * delta)
    if brake_input:
        speed = move_toward(speed, 0.0, BRAKE_POWER * delta)

    var steering_scale: float = clampf(absf(speed) / 12.0, 0.18, 1.0)
    car.rotation.y += -steer_input * TURN_RATE * steering_scale * delta * signf(speed if speed != 0.0 else 1.0)
    var forward := -car.global_transform.basis.z
    car.velocity.x = forward.x * speed
    car.velocity.z = forward.z * speed
    car.velocity.y -= 22.0 * delta
    car.move_and_slide()
    _update_traffic(delta)
    _update_police(delta)
    _update_heat_and_mission(delta)

    if speed_label:
        speed_label.text = "%03d KM/H" % int(round(absf(speed) * 3.6))

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.55, 0.59, 0.68)
    environment.ambient_light_energy = 0.7
    env.environment = environment
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -28, 0)
    sun.light_energy = 1.35
    add_child(sun)

    _add_box("Asphalt", Vector3(0, -0.25, -ROAD_LENGTH * 0.5 + 20.0),
        Vector3(ROAD_WIDTH, 0.5, ROAD_LENGTH), Color(0.075, 0.085, 0.10), true)
    _add_box("Left guardrail", Vector3(-ROAD_WIDTH * 0.5 - 0.7, 0.65, -ROAD_LENGTH * 0.5 + 20.0),
        Vector3(0.65, 1.3, ROAD_LENGTH), Color(0.48, 0.52, 0.56), true)
    _add_box("Right guardrail", Vector3(ROAD_WIDTH * 0.5 + 0.7, 0.65, -ROAD_LENGTH * 0.5 + 20.0),
        Vector3(0.65, 1.3, ROAD_LENGTH), Color(0.48, 0.52, 0.56), true)
    _add_box("Ground", Vector3(0, -0.65, -ROAD_LENGTH * 0.5), Vector3(260, 0.3, ROAD_LENGTH + 100), Color(0.12, 0.22, 0.15), true)

    for z in range(-int(ROAD_LENGTH) + 20, 10, 12):
        _add_box("Center dash", Vector3(0, 0.015, z), Vector3(0.18, 0.035, 5.5), Color(0.95, 0.82, 0.38), false)
    for z in range(-int(ROAD_LENGTH) + 30, 0, 35):
        for side: float in [-1.0, 1.0]:
            var x: float = side * randf_range(17.0, 32.0)
            var h := randf_range(7.0, 22.0)
            _add_box("City block", Vector3(x, h * 0.5 - 0.2, z + randf_range(-8.0, 8.0)),
                Vector3(randf_range(7.0, 13.0), h, randf_range(8.0, 15.0)),
                Color(randf_range(0.16, 0.32), randf_range(0.18, 0.3), randf_range(0.23, 0.4)), false)

func _build_car() -> void:
    car = CharacterBody3D.new()
    car.name = "PlayerCar"
    car.position = Vector3(0, 0.9, -2)
    add_child(car)

    var body_mesh := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(2.0, 0.65, 4.1)
    body_mesh.mesh = mesh
    body_mesh.position.y = 0.35
    car_paint = StandardMaterial3D.new()
    car_paint.albedo_color = Color(0.035, 0.22, 0.68)
    car_paint.metallic = 0.72
    car_paint.roughness = 0.24
    body_mesh.material_override = car_paint
    car.add_child(body_mesh)

    var cabin := MeshInstance3D.new()
    var cabin_mesh := BoxMesh.new()
    cabin_mesh.size = Vector3(1.55, 0.72, 1.9)
    cabin.mesh = cabin_mesh
    cabin.position = Vector3(0, 0.95, -0.15)
    var glass := StandardMaterial3D.new()
    glass.albedo_color = Color(0.035, 0.07, 0.10)
    glass.metallic = 0.35
    cabin.material_override = glass
    car.add_child(cabin)

    for x in [-0.92, 0.92]:
        for z in [-1.35, 1.35]:
            var wheel := MeshInstance3D.new()
            var wheel_mesh := CylinderMesh.new()
            wheel_mesh.top_radius = 0.43
            wheel_mesh.bottom_radius = 0.43
            wheel_mesh.height = 0.28
            wheel.mesh = wheel_mesh
            wheel.rotation_degrees.z = 90
            wheel.position = Vector3(x, -0.02, z)
            var rubber := StandardMaterial3D.new()
            rubber.albedo_color = Color(0.018, 0.02, 0.023)
            wheel.material_override = rubber
            car.add_child(wheel)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(2.0, 1.25, 4.1)
    collision.shape = shape
    collision.position.y = 0.35
    car.add_child(collision)

func _build_camera() -> void:
    camera = Camera3D.new()
    camera.position = Vector3(0, 4.2, 8.5)
    camera.current = true
    add_child(camera)
    camera.look_at(car.global_position + Vector3(0, 0.8, 0), Vector3.UP)

func _process(delta: float) -> void:
    if camera and car:
        var desired := car.global_position + car.global_transform.basis.z * 8.5 + Vector3.UP * 4.0
        camera.global_position = camera.global_position.lerp(desired, 1.0 - exp(-5.0 * delta))
        camera.look_at(car.global_position + Vector3.UP * 0.8, Vector3.UP)

func _build_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layer.add_child(root)

    speed_label = Label.new()
    speed_label.text = "000 KM/H"
    speed_label.add_theme_font_size_override("font_size", 30)
    speed_label.add_theme_color_override("font_color", Color.WHITE)
    speed_label.position = Vector2(24, 22)
    root.add_child(speed_label)

    heat_label = Label.new()
    heat_label.text = "POLICE HEAT: 0"
    heat_label.add_theme_font_size_override("font_size", 22)
    heat_label.add_theme_color_override("font_color", Color(1.0, 0.35, 0.25))
    heat_label.position = Vector2(24, 62)
    root.add_child(heat_label)

    mission_label = Label.new()
    mission_label.text = "SPRINT: REACH THE FINISH"
    mission_label.add_theme_font_size_override("font_size", 20)
    mission_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.55))
    mission_label.position = Vector2(24, 96)
    root.add_child(mission_label)

    _make_button(root, "◀", Vector2(24, -116), Vector2(104, 92), Vector2(0, 1), "left")
    _make_button(root, "▶", Vector2(140, -116), Vector2(104, 92), Vector2(0, 1), "right")
    _make_button(root, "GAS", Vector2(-132, -116), Vector2(108, 92), Vector2(1, 1), "gas")
    _make_button(root, "BRAKE", Vector2(-252, -116), Vector2(108, 92), Vector2(1, 1), "brake")
    _make_button(root, "PAINT", Vector2(-132, -222), Vector2(108, 72), Vector2(1, 1), "paint")

func _make_button(parent: Control, caption: String, offset: Vector2, size: Vector2,
        anchor: Vector2, action: String) -> void:
    var button := Button.new()
    button.text = caption
    button.set_anchors_preset(Control.PRESET_TOP_LEFT)
    button.anchor_left = anchor.x
    button.anchor_right = anchor.x
    button.anchor_top = anchor.y
    button.anchor_bottom = anchor.y
    button.offset_left = offset.x
    button.offset_top = offset.y
    button.offset_right = offset.x + size.x
    button.offset_bottom = offset.y + size.y
    button.add_theme_font_size_override("font_size", 22)
    button.modulate = Color(1, 1, 1, 0.88)
    parent.add_child(button)
    button.button_down.connect(_on_control_down.bind(action))
    button.button_up.connect(_on_control_up.bind(action))

func _on_control_down(action: String) -> void:
    match action:
        "gas": throttle_input = 1.0
        "left": steer_input = 1.0
        "right": steer_input = -1.0
        "brake": brake_input = true
        "paint": _change_car_paint()

func _on_control_up(action: String) -> void:
    match action:
        "gas": throttle_input = 0.0
        "left", "right": steer_input = 0.0
        "brake": brake_input = false


func _build_traffic() -> void:
    var colors: Array[Color] = [Color(0.72, 0.16, 0.12), Color(0.78, 0.78, 0.74), Color(0.12, 0.48, 0.28), Color(0.82, 0.55, 0.12)]
    for i in range(8):
        var traffic := _create_ai_car("Traffic %d" % i, colors[i % colors.size()], false)
        traffic.position = Vector3([-4.5, 4.5, -1.5, 1.5][i % 4], 0.55, -45.0 - float(i) * 58.0)
        traffic_cars.append(traffic)

func _build_police() -> void:
    for i in range(2):
        var cop := _create_ai_car("Patrol %d" % i, Color(0.025, 0.045, 0.09), true)
        cop.position = Vector3(-3.5 if i == 0 else 3.5, 0.55, 18.0 + float(i) * 9.0)
        police_cars.append(cop)

func _create_ai_car(label: String, color: Color, police: bool) -> Node3D:
    var root := Node3D.new()
    root.name = label
    add_child(root)
    var body := MeshInstance3D.new()
    var body_box := BoxMesh.new()
    body_box.size = Vector3(1.9, 0.65, 3.8)
    body.mesh = body_box
    body.position.y = 0.32
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = 0.45
    body.material_override = material
    root.add_child(body)
    var roof := MeshInstance3D.new()
    var roof_box := BoxMesh.new()
    roof_box.size = Vector3(1.45, 0.58, 1.7)
    roof.mesh = roof_box
    roof.position = Vector3(0, 0.88, -0.1)
    var glass := StandardMaterial3D.new()
    glass.albedo_color = Color(0.035, 0.07, 0.11)
    roof.material_override = glass
    root.add_child(roof)
    if police:
        var lightbar := MeshInstance3D.new()
        var light_mesh := BoxMesh.new()
        light_mesh.size = Vector3(0.85, 0.16, 0.28)
        lightbar.mesh = light_mesh
        lightbar.position = Vector3(0, 1.22, -0.1)
        var lights := StandardMaterial3D.new()
        lights.albedo_color = Color(0.9, 0.04, 0.04)
        lights.emission_enabled = true
        lights.emission = Color(0.9, 0.02, 0.02)
        lightbar.material_override = lights
        root.add_child(lightbar)
    return root

func _update_traffic(delta: float) -> void:
    for traffic in traffic_cars:
        traffic.position.z -= 12.0 * delta
        if traffic.position.z > car.position.z + 35.0:
            traffic.position.z = car.position.z - randf_range(180.0, 420.0)
            traffic.position.x = [-4.5, 4.5, -1.5, 1.5][randi() % 4]

func _update_police(delta: float) -> void:
    for cop in police_cars:
        if wanted_level <= 0:
            cop.position = car.position + Vector3(0, 0, 24.0 + float(police_cars.find(cop)) * 8.0)
            cop.rotation.y = car.rotation.y
            continue
        var target := car.global_position + car.global_transform.basis.z * 5.0
        var direction := (target - cop.global_position).normalized()
        cop.global_position += direction * (15.0 + float(wanted_level) * 2.0) * delta
        cop.look_at(Vector3(car.global_position.x, cop.global_position.y, car.global_position.z), Vector3.UP)
        if cop.global_position.distance_to(car.global_position) < 3.4:
            speed = move_toward(speed, 0.0, 22.0 * delta)

func _update_heat_and_mission(delta: float) -> void:
    if absf(speed) > 34.0:
        heat_seconds += delta
        wanted_level = mini(5, 1 + int(heat_seconds / 7.0))
    else:
        heat_seconds = maxf(0.0, heat_seconds - delta * 0.6)
        if heat_seconds < 1.0:
            wanted_level = 0
    if heat_label:
        var stars := ""
        for i in range(5):
            stars += "★" if i < wanted_level else "☆"
        heat_label.text = "POLICE HEAT: " + stars
    if not mission_finished and car.position.z < -560.0:
        mission_finished = true
        mission_label.text = "SPRINT COMPLETE!  WELL DONE"
        speed = 0.0
        throttle_input = 0.0

func _change_car_paint() -> void:
    if car_paint == null:
        return
    var paints: Array[Color] = [Color(0.035, 0.22, 0.68), Color(0.72, 0.035, 0.025), Color(0.04, 0.04, 0.045), Color(0.82, 0.72, 0.12), Color(0.72, 0.72, 0.74)]
    var current := paints.find(car_paint.albedo_color)
    car_paint.albedo_color = paints[(current + 1) % paints.size()]

func _add_box(object_name: String, pos: Vector3, dimensions: Vector3,
        color: Color, solid: bool) -> void:
    var holder: Node3D
    if solid:
        holder = StaticBody3D.new()
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = dimensions
        collision.shape = shape
        holder.add_child(collision)
    else:
        holder = Node3D.new()
    holder.name = object_name
    holder.position = pos
    add_child(holder)

    var visual := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = dimensions
    visual.mesh = box
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    visual.material_override = material
    holder.add_child(visual)
