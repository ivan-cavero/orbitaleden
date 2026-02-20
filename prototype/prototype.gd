extends Node3D
## Prototype scene with test items and console spawn functionality.
##
## Editor-placed items are under the EditorItems node in the scene.
## Use spawn_item_at() or the console `spawn` command for dynamic spawning.

const WorldItemScene: PackedScene = preload("res://entities/world_item/world_item.tscn")

## Available item definition paths for spawning
const ITEM_PATHS: Dictionary = {
	"scrap_metal": "res://resources/items/definitions/scrap_metal.tres",
	"wire_bundle": "res://resources/items/definitions/wire_bundle.tres",
	"circuit_board": "res://resources/items/definitions/circuit_board.tres",
	"oxygen_canister": "res://resources/items/definitions/oxygen_canister.tres",
	"food_ration": "res://resources/items/definitions/food_ration.tres",
	"water_bottle": "res://resources/items/definitions/water_bottle.tres",
	"medkit": "res://resources/items/definitions/medkit.tres",
}

var _item_cache: Dictionary = {}


func _ready() -> void:
	_cache_items()
	Debug.info("Prototype ready - %d item types available" % _item_cache.size())


func _cache_items() -> void:
	for id: String in ITEM_PATHS:
		var item: Resource = load(ITEM_PATHS[id])
		if item:
			_item_cache[id] = item
		else:
			Debug.warn("Failed to load item: %s" % id)


## Spawn an item at a specific position. Returns true if successful.
func spawn_item_at(item_id: String, pos: Vector3, qty: int = 1) -> bool:
	if not _item_cache.has(item_id):
		Debug.warn("Unknown item ID: %s" % item_id)
		return false
	
	var world_item: Node = WorldItemScene.instantiate()
	add_child(world_item)
	world_item.global_position = pos
	world_item.setup(_item_cache[item_id], qty)
	return true


## Get list of all available item IDs for spawning.
func get_item_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_item_cache.keys())
	return ids
