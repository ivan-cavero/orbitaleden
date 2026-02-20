extends Node
## Centralized item registry that auto-loads all ItemDefinition resources.
##
## Scans res://resources/items/definitions/ on startup and registers every
## .tres file it finds.  Adding or removing items is as simple as creating
## or deleting a .tres file in that folder — no code changes needed.
##
## Access via the global autoload:
##   ItemDatabase.get_item("scrap_metal")
##   ItemDatabase.get_all_items()
##   ItemDatabase.get_items_by_category(ItemDefinition.Category.CONSUMABLE)

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

## Directory scanned for .tres item definitions.
const DEFINITIONS_DIR := "res://resources/items/definitions/"

# ─────────────────────────────────────────────────────────────────────────────
# Internal Data
# ─────────────────────────────────────────────────────────────────────────────

## All registered items keyed by their id string.
var _items: Dictionary = {}  # String → ItemDefinition

# ─────────────────────────────────────────────────────────────────────────────
# Lifecycle
# ─────────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_scan_definitions()
	Debug.info("ItemDatabase: %d items registered" % _items.size())

# ─────────────────────────────────────────────────────────────────────────────
# Public API — Queries
# ─────────────────────────────────────────────────────────────────────────────

## Returns the ItemDefinition for the given id, or null if not found.
func get_item(item_id: String) -> ItemDefinition:
	return _items.get(item_id) as ItemDefinition


## Returns true if an item with the given id is registered.
func has_item(item_id: String) -> bool:
	return _items.has(item_id)


## Returns all registered item ids (sorted alphabetically).
func get_item_ids() -> Array[String]:
	var ids: Array[String] = []
	ids.assign(_items.keys())
	ids.sort()
	return ids


## Returns all registered ItemDefinition resources.
func get_all_items() -> Array[ItemDefinition]:
	var items: Array[ItemDefinition] = []
	for item: ItemDefinition in _items.values():
		items.append(item)
	return items


## Returns all items matching a specific category.
func get_items_by_category(cat: ItemDefinition.Category) -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	for item: ItemDefinition in _items.values():
		if item.category == cat:
			result.append(item)
	return result


## Returns the total count of registered items.
func get_count() -> int:
	return _items.size()

# ─────────────────────────────────────────────────────────────────────────────
# Private — Scanning
# ─────────────────────────────────────────────────────────────────────────────

func _scan_definitions() -> void:
	var dir := DirAccess.open(DEFINITIONS_DIR)
	if not dir:
		Debug.warn("ItemDatabase: cannot open %s" % DEFINITIONS_DIR)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			_load_definition(DEFINITIONS_DIR + file_name)
		file_name = dir.get_next()

	dir.list_dir_end()


func _load_definition(path: String) -> void:
	var res := load(path)
	if res == null:
		Debug.warn("ItemDatabase: failed to load %s" % path)
		return

	if not res is ItemDefinition:
		Debug.warn("ItemDatabase: %s is not an ItemDefinition" % path)
		return

	var item := res as ItemDefinition
	if not item.is_valid():
		Debug.warn("ItemDatabase: %s has invalid data (missing id or display_name)" % path)
		return

	if _items.has(item.id):
		Debug.warn("ItemDatabase: duplicate id '%s' in %s (overwriting)" % [item.id, path])

	_items[item.id] = item
