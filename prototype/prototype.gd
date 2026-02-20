extends Node3D
## Prototype scene with test items and console spawn functionality.
##
## Editor-placed items are under the EditorItems node in the scene.
## Use spawn_item_at() or the console `spawn` command for dynamic spawning.

const WorldItemScene: PackedScene = preload("res://entities/world_item/world_item.tscn")


func _ready() -> void:
	Debug.info("Prototype ready - %d item types available" % ItemDatabase.get_count())


## Spawn an item at a specific position. Returns true if successful.
func spawn_item_at(item_id: String, pos: Vector3, qty: int = 1) -> bool:
	var item_def := ItemDatabase.get_item(item_id)
	if not item_def:
		Debug.warn("Unknown item ID: %s" % item_id)
		return false

	var world_item: Node = WorldItemScene.instantiate()
	add_child(world_item)
	world_item.global_position = pos
	world_item.setup(item_def, qty)
	return true


## Get list of all available item IDs for spawning.
func get_item_ids() -> Array[String]:
	return ItemDatabase.get_item_ids()
