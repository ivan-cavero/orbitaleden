class_name PlaceholderTextureCache
extends RefCounted
## Static cache for generated placeholder textures.
##
## Both InventorySlot and HotbarUI need colored placeholder textures
## when an item has no icon. This shared cache avoids duplicating the
## creation logic and ensures textures are reused across all UI elements.

# ─────────────────────────────────────────────────────────────────────────────
# Constants
# ─────────────────────────────────────────────────────────────────────────────

const PLACEHOLDER_SIZE := 48
const PLACEHOLDER_ALPHA := 0.6
const DEFAULT_COLOR := Color(0.5, 0.5, 0.5, 0.6)

# ─────────────────────────────────────────────────────────────────────────────
# Cache
# ─────────────────────────────────────────────────────────────────────────────

## Keyed by Color — one texture per unique color.
static var _cache: Dictionary = {}

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

## Returns a cached placeholder texture tinted to the item's color.
## Pass null for a default grey placeholder.
static func get_for_item(item: ItemDefinition) -> Texture2D:
	var color := DEFAULT_COLOR
	if item:
		color = item.color
		color.a = PLACEHOLDER_ALPHA

	if _cache.has(color):
		return _cache[color]

	var image := Image.create(PLACEHOLDER_SIZE, PLACEHOLDER_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture := ImageTexture.create_from_image(image)
	_cache[color] = texture
	return texture
