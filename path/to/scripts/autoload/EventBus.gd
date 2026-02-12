[gd_scene load_steps=4 format=2]

[node name="EditorMode" type="Node"]

[node name="Camera" parent="." type="Camera3D"]
transform/translation = Vector3( 0, 10, -10 )
transform/basis = Basis( 0.7071067811865476, 0, 0.7071067811865476, 0, 1, 0, -0.7071067811865476, 0, 0.7071067811865476 )
current = true

[node name="FreeFlyCamera" parent="." type="CharacterBody3D"]
transform/translation = Vector3( 0, 10, -10 )
collision_shape/shapes/0/extents = Vector3( 0.5, 0.5, 0.5 )

[node name="GridSnapping" parent="FreeFlyCamera" type="Node"]
