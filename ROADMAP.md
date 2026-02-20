# Orbital Eden - Development Roadmap

## Philosophy

- **Create files only when needed** - No empty folders or placeholder files
- **Create assets when needed** - Generate models/textures as each feature requires them
- **Prototype first, integrate later** - Test mechanics in isolation before adding to main game
- **Incremental development** - Each task builds on the previous one
- **Always playable** - After each milestone, the game should run and be testable
- **Debug tools always available** - Console and performance overlay for testing

---

## Project Structure (Grows Organically)

```
orbital_eden/
├── project.godot
├── prototype/                 # Testing sandbox (always keep)
│   └── prototype.tscn        # Test scene for new mechanics
├── game/                      # Main game (build incrementally)
│   └── main.tscn             # Entry point
└── (other folders created as needed per phase)
```

---

## Early Access Scope

| Aspect | Target |
|--------|--------|
| Playtime | 8-12 hours |
| Map | 2 sectors (Hub + Engineering) |
| Multiplayer | 2 players co-op |
| Automation | Tiers 1-3 |
| Story | Act 1 + Act 2 start, cliffhanger ending |
| Price | $19.99 |

---

## Phase 1: Foundation & Debug Tools ✅

**Goal:** Project setup with robust debugging tools for all future development.

### 1.1 Project Setup ✅
- [x] Create Godot 4.6 project with default settings
- [x] Create `prototype/prototype.tscn`:
  - Large flat floor (100x100m, grid texture)
  - Basic lighting (DirectionalLight3D + WorldEnvironment)
  - Spawn point marker
- [x] Create `game/main.tscn` - entry point loading prototype
- [x] Setup `.gitignore` for Godot

### 1.2 Debug Console (Toggle with ` key) ✅
- [x] `ui/debug/debug_console.tscn` - CanvasLayer (layer=100) with:
  - Semi-transparent dark background panel (no border)
  - ScrollContainer with output log (RichTextLabel, BBCode)
  - LineEdit for command input (flat, borderless)
  - Toggle with ` key — intercepts via `_input()` before LineEdit receives it
  - Escape also closes
- [x] Command system:
  - Command parser (split by spaces, first word = command)
  - Command registry Dictionary
  - Tab autocomplete
  - Command history Up/Down (last 50)
- [x] Output formatting:
  - White: normal output
  - Yellow: warnings
  - Red: errors
  - Green: success
- [x] Built-in commands:
  - `help [cmd]` - list all commands or details for one
  - `clear` - clear output
  - `quit` - exit game
  - `fps` - print current FPS
  - `wireframe` - toggle wireframe rendering
  - `timescale [0.1-10]` - get/set game speed
  - `pause` - toggle pause

### 1.3 Performance Overlay (Toggle with F3) ✅
- [x] `ui/debug/debug_overlay.tscn` - CanvasLayer, top-left corner
- [x] Toggle with F3 key (Input Map action `toggle_debug_overlay`)
- [x] Shows immediately on open (no delay)
- [x] Updates every 0.25s
- [x] Metrics shown:
  - FPS + frame time (color-coded: green ≥60, amber ≥30, red <30)
  - Render objects + draw calls
  - Static memory + node count
- [x] `process_mode = ALWAYS` — works when game is paused

### 1.4 Cheat Commands ⚠️ (partial — stubs for future systems)
- [x] `wireframe` - toggle wireframe rendering
- [x] `collision` - toggle collision shape visibility
- [x] `overlay` - toggle debug overlay from console
- [x] `timescale` - game speed (works now)
- [x] `pause` - toggle pause (works now)
- [ ] Movement cheats (`noclip`, `fly`, `speed`, `tp`) — needs Phase 2 player
- [ ] Stat cheats (`god`, `heal`, `damage`, etc.) — needs Phase 4 stats
- [ ] Inventory cheats (`give`, `giveall`, etc.) — needs Phase 3 inventory
- [ ] Entity cheats (`spawn`, `killall`, etc.) — needs Phase 9 enemies

### 1.5 Debug Autoload ✅
- [x] `autoload/debug.gd` singleton registered as `Debug`
- [x] Instantiates and owns console + overlay
- [x] Global logging API: `Debug.info()`, `Debug.warn()`, `Debug.error()`, `Debug.ok()`
- [x] `process_mode = ALWAYS`

**Milestone 1 Complete ✅**
- [x] Debug console functional with toggle, history, autocomplete
- [x] F3 overlay shows live metrics
- [x] Foundation ready for all future development

---

## Phase 2: Player Controller ✅

**Goal:** First-person player that moves and looks around.

### 2.1 Player Scene ✅
- [x] Create `entities/player/player.tscn`:
  - CharacterBody3D (root)
  - CollisionShape3D (capsule, 0.5m radius, 1.8m height)
  - Node3D "Head" at eye level (Y = 1.6m)
  - Camera3D under Head
  - RayCast3D for interaction (3m range)
- [x] **Test asset:** CapsuleMesh for player body
- [x] Test: Player scene loads without errors

### 2.2 Basic Movement ✅
- [x] `entities/player/player_controller.gd` script:
  - Mouse look (capture mouse, rotate head pitch, rotate body yaw)
  - WASD movement relative to facing direction
  - Configurable mouse sensitivity (default 0.3)
  - Configurable move speed (default 5 m/s)
- [x] Gravity and ground detection
- [x] Test: Move around prototype scene, look around smoothly

### 2.3 Advanced Movement ✅
- [x] Sprint: Hold Shift, 1.5x speed
- [x] Crouch: Hold Ctrl, 0.5x speed, smooth eye height transition
- [x] Jump: Space, 5 m/s upward velocity
- [x] Smooth acceleration/deceleration
- [x] Head bob while walking (subtle, toggleable)
- [ ] Footstep sounds placeholder — needs Phase 14 audio
- [x] Test: All movement feels responsive and smooth

### 2.4 Noclip/Fly Integration ✅
- [x] `noclip` command: disable gravity + collision, move in look direction
- [x] `fly` command: disable gravity, keep collision
- [x] `speed` multiplier affects all movement
- [x] `ui/hud/cheat_indicator.tscn` — yellow text overlay for active cheats
- [x] Test: Toggle noclip/fly via console

### 2.5 Player Spawn System ✅
- [x] Player spawns at prototype's Marker3D "SpawnPoint" on scene load
- [x] `respawn` command teleports to spawn
- [x] `tp <x> <y> <z>` command for free teleport
- [x] `game/main.gd` manages spawn, registers movement cheat commands
- [x] Test: Player appears at SpawnPoint on launch

**Milestone 2 Complete ✅**
- [x] Player moves smoothly in first person
- [x] All movement types work (walk, sprint, crouch, jump)
- [x] Noclip/fly cheats work with on-screen indicator
- [x] Player spawns at designated point

---

## Phase 3: Interaction & Items

**Goal:** Player can interact with objects and manage inventory.

### 3.1 Interaction System ✅
- [x] RayCast3D detects objects in "interactable" group
- [x] Highlight system:
  - Emission tint on hover (configurable color, toggleable per object)
  - "Press E to interact" prompt on screen (updates in real-time)
- [x] `Interactable` base class:
  - `interact(player)` virtual method
  - `get_interaction_text()` for custom prompts
  - `interaction_type`: SIMPLE, ACTIVATE, TOGGLE
  - `single_use`, `show_highlight`, `use_state_colors` all configurable from editor
  - Signals: `interacted`, `activated`, `deactivated`, `state_changed`
- [x] E key triggers interaction
- [x] Test: Look at object, see highlight and prompt, press E

### 3.2 Item System Resources ✅
- [x] `ItemDefinition` resource (`resources/items/item_definition.gd`):
  ```
  id: String (unique)
  display_name: String
  description: String
  icon: Texture2D
  mesh: PackedScene (for world/hand display)
  stack_size: int (1-999)
  weight: float (kg)
  tier: int (1-4)
  categories: Array[String]
  usable: bool
  equippable: bool
  ```
- [x] `ItemStack` resource:
  ```
  item: ItemDefinition
  quantity: int
  ```
- [x] Create test items (placeholder cube meshes, colored):
  - `scrap_metal` (gray cube) - stack 100
  - `wire_bundle` (orange cube) - stack 100
  - `circuit_board` (green cube) - stack 50
  - `oxygen_canister` (blue cylinder) - stack 10, usable
  - `food_ration` (brown cube) - stack 20, usable
  - `water_bottle` (clear cube) - stack 20, usable
  - `medkit` (white cube with red cross) - stack 5, usable
- [x] **Test assets:** Generated placeholder meshes as PackedScenes (CSGBox/CSGCylinder)
- [x] Test: Items load from resources correctly (7/7 passed)

### 3.3 World Items (Pickups) ✅
- [x] `WorldItem.tscn` - RigidBody3D with:
  - MeshInstance3D (colored box based on ItemDefinition.color)
  - CollisionShape3D (box matching mesh)
  - In "interactable" group via Interactable component
  - Shows item name on hover ("Pick up Scrap Metal (x5)")
- [x] Interaction picks up item → emits signal (inventory in 3.4)
- [x] Physics: items fall with gravity, can be pushed by player
- [x] Configurable properties from editor:
  - `pushable` (bool) - toggle physics interaction
  - `mass_override` - custom mass (0 = auto from item weight)
  - `linear_damping_value` / `angular_damping_value` - control sliding/spinning
  - `mesh_scale` - visual size adjustment
- [x] Push physics tuned: velocity cap, force-based (not impulse), damping
- [x] Editor workflow: WorldItems placed in scene, visible and editable
- [x] Console commands: `spawn <item_id> [qty]`, `items`
- [x] Test items in prototype scene (EditorItems node)
- [x] Test: Walk to items, push them, see highlight and prompt, press E to pickup

### 3.4 Inventory Data
- [ ] `InventoryData` resource:
  ```
  slots: Array[ItemStack] (fixed size, e.g., 30)
  max_slots: int
  ```
- [ ] Functions:
  - `add_item(item, quantity)` → returns overflow
  - `remove_item(item, quantity)` → returns success
  - `has_item(item, quantity)` → bool
  - `get_item_count(item)` → int
  - `find_slot(item)` → slot index or -1
- [ ] Signal: `inventory_changed`
- [ ] Test: Add/remove items programmatically

### 3.5 Inventory UI
- [ ] `InventoryUI.tscn` - CanvasLayer:
  - Grid of slot buttons (6 columns x 5 rows = 30 slots)
  - Each slot shows: item icon, quantity, tooltip on hover
  - Drag and drop between slots
  - Right-click to split stack
  - Close button or press Tab/Escape
- [ ] Toggle with Tab key
- [ ] Mouse visible when inventory open
- [ ] Test: Open inventory, see items, drag between slots

### 3.6 Hotbar
- [ ] 8-slot hotbar at bottom center of screen
- [ ] Always visible during gameplay
- [ ] Number keys 1-8 to select slot
- [ ] Selected slot highlighted
- [ ] Drag items from inventory to hotbar
- [ ] Right-click or F to use item in selected slot
- [ ] Test: Equip item to hotbar, select with number key

### 3.7 Item Usage
- [ ] Items with `usable = true` can be consumed
- [ ] `use(player)` method on ItemDefinition
- [ ] For now: just remove from inventory and print message
- [ ] Effects implemented in Phase 4 (stats)
- [ ] Test: Use food ration, it disappears from inventory

### 3.8 Console Item Commands
- [ ] `give` command now works with real items
- [ ] `list_items` shows all registered items
- [ ] `giveall` gives one of each item
- [ ] Test: Give items via console, they appear in inventory

**Milestone 3 Complete:**
- [ ] Can interact with objects in world
- [ ] Items exist as resources with properties
- [ ] Can pick up and drop items
- [ ] Inventory UI works with drag/drop
- [ ] Hotbar for quick access

---

## Phase 4: Survival Systems

**Goal:** Player has needs that must be managed to survive.

### 4.1 Player Stats Resource
- [ ] `PlayerStats` resource:
  ```
  health: float (0-100)
  health_max: float
  oxygen: float (0-100)
  oxygen_max: float
  hunger: float (0-100, 100 = full)
  hunger_max: float
  thirst: float (0-100, 100 = full)
  thirst_max: float
  sanity: float (0-100)
  sanity_max: float
  stamina: float (0-100)
  stamina_max: float
  ```
- [ ] Signals: `stat_changed(stat_name, old_value, new_value)`, `stat_depleted(stat_name)`
- [ ] Test: Create stats, modify values, signals fire

### 4.2 Stats Drain System
- [ ] `SurvivalManager` handles stat drain:
  - Oxygen: -2/second (50 seconds to empty)
  - Hunger: -0.5/second (200 seconds to empty)
  - Thirst: -0.8/second (125 seconds to empty)
  - Sanity: context-dependent (darkness, isolation, enemies)
  - Stamina: drains while sprinting, regenerates while still
- [ ] Drain rates configurable (for balancing)
- [ ] Console commands update real stats now
- [ ] Test: Watch stats drain in F3 overlay

### 4.3 Stat Effects
- [ ] **Low oxygen (< 30%):** Screen desaturates, breathing sounds, vision narrows
- [ ] **No oxygen (0%):** Rapid health drain (10/second), death in 10s
- [ ] **Low hunger (< 30%):** Stamina regeneration halved
- [ ] **No hunger (0%):** Slow health drain (1/second)
- [ ] **Low thirst (< 30%):** Movement speed reduced 20%
- [ ] **No thirst (0%):** Health drain (2/second)
- [ ] **Low sanity (< 30%):** Visual distortions, audio hallucinations
- [ ] **No sanity (0%):** Severe hallucinations, random damage
- [ ] Test: Let each stat drain, observe effects

### 4.4 Stats HUD
- [ ] `StatsHUD.tscn` - CanvasLayer, bottom-left corner:
  - Health bar (red)
  - Oxygen bar (blue)
  - Hunger bar (orange)
  - Thirst bar (cyan)
  - Sanity bar (purple)
  - Stamina bar (yellow) - only shows when sprinting
- [ ] Bars flash when critical (< 20%)
- [ ] Numeric values optional (toggle in settings)
- [ ] Test: HUD reflects actual stat values

### 4.5 Item Effects
- [ ] Implement `use()` for consumables:
  - `oxygen_canister`: +50 oxygen
  - `food_ration`: +40 hunger
  - `water_bottle`: +40 thirst
  - `medkit`: +50 health
- [ ] Visual/audio feedback on use
- [ ] Console: `drain oxygen 50` then use canister to restore
- [ ] Test: Each consumable restores correct stat

### 4.6 Damage System
- [ ] `take_damage(amount, type)` on player:
  - Types: physical, fire, electric, toxic, suffocation
  - Reduces health
  - Screen flash (red for physical, etc.)
  - Damage numbers optional
- [ ] Invincibility frames (0.5s after damage)
- [ ] `god` cheat prevents all damage
- [ ] Test: Use `damage 25` command, see health drop

### 4.7 Death & Respawn
- [ ] Death triggers when health ≤ 0
- [ ] `DeathScreen.tscn`:
  - Fade to black
  - "You Died" text
  - Cause of death shown
  - "Respawn" button
- [ ] On death:
  - Drop all inventory as WorldItems
  - Record death location
- [ ] On respawn:
  - Teleport to spawn point
  - Reset all stats to max
  - Empty inventory (items still at death location)
- [ ] Test: Die from damage, respawn, find dropped items

### 4.8 Hazard Zones (for testing)
- [ ] Create `HazardZone.tscn` - Area3D:
  - Configurable damage type and DPS
  - Visual indicator (colored box)
- [ ] Place in prototype scene:
  - Red zone: physical damage
  - Orange zone: fire damage
  - Yellow zone: electric damage
  - Green zone: toxic damage
- [ ] Test: Walk into hazard, take damage, leave to stop

**Milestone 4 Complete:**
- [ ] All survival stats drain over time
- [ ] Low stats cause effects
- [ ] Items restore stats
- [ ] Can die and respawn
- [ ] Hazard zones deal damage

---

## Phase 5: Building System

**Goal:** Player can construct structures.

### 5.1 Building Resources
- [ ] `BuildingDefinition` resource:
  ```
  id: String
  display_name: String
  description: String
  category: String (structure, machine, furniture, automation)
  mesh: PackedScene
  ghost_mesh: PackedScene (transparent preview)
  collision_shape: Shape3D
  grid_size: Vector3i (e.g., 2x1x2 for 2x2 floor)
  snap_to_grid: bool
  can_rotate: bool
  resource_cost: Array[ItemStack]
  build_time: float (seconds)
  health: float
  tier: int
  ```
- [ ] **Test assets - generate simple building meshes:**
  - Floor tile (2x2m, flat gray box)
  - Wall section (2x3m, gray box)
  - Door frame (2x3m, gray box with hole)
  - Door (fits in frame, brown box)
- [ ] Test: Building definitions load correctly

### 5.2 Grid System
- [ ] World grid: 1m or 2m cells (configurable)
- [ ] `BuildingManager` singleton:
  - Tracks all placed buildings
  - Grid occupancy map
  - Building lookup by position
- [ ] Test: Grid calculations work correctly

### 5.3 Ghost Preview
- [ ] Enter build mode: B key or from build menu
- [ ] Ghost mesh follows cursor:
  - Raycast from camera to find placement point
  - Snap to grid
  - Rotate with R key (90° increments)
- [ ] Color coding:
  - Green + semi-transparent: valid placement
  - Red + semi-transparent: invalid placement
- [ ] Invalid conditions:
  - Overlaps existing building
  - Inside collision geometry
  - Not on valid surface
  - Missing resources (if not in free build mode)
- [ ] Test: Enter build mode, see ghost, move around, rotate

### 5.4 Placement
- [ ] Left-click to place (when valid):
  - Check resources (or skip if `build_free` cheat)
  - Consume resources from inventory
  - Spawn building at ghost position
  - Play placement sound
  - Register in BuildingManager
- [ ] Right-click or Escape to cancel
- [ ] Test: Place floor tiles, they snap together correctly

### 5.5 Basic Structures
- [ ] Implement and test each:
  - **Floor tile:** Foundation, can place other buildings on it
  - **Wall section:** Vertical barrier, snaps to floor edges
  - **Door frame:** Wall with opening
  - **Door:** Interactive, opens/closes on E key
- [ ] Test: Build enclosed room with working door

### 5.6 Deconstruction
- [ ] Look at building + hold X (2 seconds)
- [ ] Progress bar while holding
- [ ] On complete:
  - Return 50% of resources (configurable)
  - Remove building
  - Play deconstruction sound
  - Update grid occupancy
- [ ] Test: Build wall, deconstruct, get resources back

### 5.7 Build Menu
- [ ] `BuildMenu.tscn` - press B to open:
  - Categories as tabs (Structures, Machines, etc.)
  - Grid of building options with icons
  - Hover shows: name, description, resource cost
  - Click to select and enter placement mode
  - Shows "Can Build" / "Missing: X" status
- [ ] Test: Open menu, browse categories, select building

### 5.8 Building Cheats
- [ ] `build_free` - no resource cost
- [ ] `build_instant` - no build time
- [ ] `destroy_all_buildings` - clear everything
- [ ] Test: Toggle cheats, build freely

**Milestone 5 Complete:**
- [ ] Grid-based building placement
- [ ] Ghost preview with validation
- [ ] Can build floors, walls, doors
- [ ] Can deconstruct buildings
- [ ] Build menu for selection

---

## Phase 6: Resource Gathering & Crafting

**Goal:** Player can harvest resources and craft items.

### 6.1 Resource Nodes
- [ ] `ResourceNode.tscn`:
  - StaticBody3D with mesh and collision
  - In "interactable" group
  - Properties: resource_item, yield_min, yield_max, harvests_remaining, respawn_time
  - Interaction shows "Harvest [E]"
- [ ] Harvesting:
  - Progress bar (2 seconds default)
  - On complete: add random yield to inventory
  - Decrement harvests_remaining
  - When depleted: change visual, disable interaction
  - Respawn after time
- [ ] **Test assets - simple node meshes:**
  - Scrap pile (gray rubble)
  - Wire cabinet (orange box)
  - Component shelf (green shelf)
  - Ore deposit (brown rock)
- [ ] Test: Harvest node, get items, node depletes, respawns

### 6.2 Recipe System
- [ ] `Recipe` resource:
  ```
  id: String
  display_name: String
  inputs: Array[ItemStack]
  output: ItemStack
  craft_time: float
  required_station: String (empty = hand crafting)
  tier_required: int
  unlocked_by_default: bool
  ```
- [ ] Define test recipes:
  - Hand: 3 Scrap Metal → 1 Metal Plate
  - Hand: 2 Wire Bundle → 1 Wire Coil
  - Hand: 1 Metal Plate + 1 Wire Coil → 1 Circuit Board
  - Workbench: 1 Metal Plate + 1 Circuit Board → 1 Oxygen Canister
  - Workbench: 2 Scrap Metal + 1 Wire Coil → 1 Medkit
- [ ] **Test assets:** Create placeholder items for new resources
- [ ] Test: Recipes load and validate correctly

### 6.3 Crafting UI
- [ ] `CraftingMenu.tscn` - open with C key:
  - Left panel: list of available recipes
  - Right panel: selected recipe details
    - Input items with quantities (green if have, red if missing)
    - Output item
    - Craft time
    - "Craft" button (disabled if can't craft)
  - Filter: All / Craftable / Favorites
  - Search bar
- [ ] Crafting process:
  - Click Craft → progress bar
  - On complete: consume inputs, add output
  - Can queue multiple crafts
- [ ] Test: Gather materials, open crafting, craft item

### 6.4 Workbench Building
- [ ] Add Workbench to building definitions:
  - 2x2 building
  - Interact to open workbench crafting
  - Additional recipes available
- [ ] Workbench crafting UI same as hand but more recipes
- [ ] Test: Build workbench, craft workbench-only recipe

### 6.5 Recipe Unlock System
- [ ] Some recipes locked by default
- [ ] Unlock via:
  - Story progression
  - Finding blueprint items
  - Reaching certain areas
- [ ] For now: console command `unlock_recipe <id>`
- [ ] Test: Locked recipe not shown, unlock it, now available

**Milestone 6 Complete:**
- [ ] Can harvest resources from nodes
- [ ] Hand crafting works
- [ ] Workbench enables advanced crafting
- [ ] Complete resource → craft → use loop

---

## Phase 7: Automation - Belts & Inserters

**Goal:** Items move automatically on conveyor belts.

### 7.1 Conveyor Belt
- [ ] `ConveyorBelt` building:
  - 1m segment
  - Direction (arrow indicator)
  - Speed: items/second
  - Visual: animated texture or moving items
- [ ] **Test asset:** Simple belt mesh with arrow texture
- [ ] Belt logic:
  - Items on belt move in direction
  - Items rendered with MultiMesh for performance
  - Belt connects to adjacent belts automatically
- [ ] Test: Place item on belt, watch it move

### 7.2 Belt Placement
- [ ] Special placement rules:
  - Auto-detect adjacent belts
  - Match direction (or create corner)
  - Show connection preview
- [ ] Upgrade/downgrade belt in place
- [ ] Test: Build belt line, items flow end-to-end

### 7.3 Storage Container
- [ ] `StorageContainer` building:
  - Has inventory (20 slots)
  - Interact to open container UI
  - Can be target for inserters
- [ ] **Test asset:** Box mesh
- [ ] Test: Build container, store items manually

### 7.4 Inserter
- [ ] `Inserter` building:
  - Has facing direction
  - Takes from behind, places in front
  - Animation: arm rotates to pick up and place
  - Works with: belts, containers, machines
  - Speed: items/second
- [ ] **Test asset:** Small arm/pivot mesh
- [ ] Logic:
  - Detect item source (belt/container) behind
  - Detect item destination (belt/container) in front
  - Transfer items automatically
- [ ] Test: Belt → Inserter → Container works

### 7.5 Belt Performance
- [ ] Items simulated as data, not physics objects
- [ ] Render with MultiMeshInstance3D
- [ ] Target: 500+ items on belts at 60 FPS
- [ ] Console: `spawn_belt_items <count>` for testing
- [ ] Test: Spawn 500 items, check performance in F3 overlay

**Milestone 7 Complete:**
- [ ] Belts transport items
- [ ] Inserters move items between buildings
- [ ] Storage containers hold items
- [ ] Performance acceptable with many items

---

## Phase 8: Automation - Machines & Power

**Goal:** Machines process items and require power.

### 8.1 Machine Base
- [ ] `Machine` base class:
  - Input slots, output slots
  - Recipe list (what it can process)
  - Processing time
  - Power requirement (watts)
  - States: Idle, Working, NoPower, NoInput, OutputFull
- [ ] Machine UI when interacted:
  - Input/output slot display
  - Current recipe (if any)
  - Progress bar
  - Power status

### 8.2 Smelter Machine
- [ ] First machine: Smelter
  - Converts raw ore to plates
  - Recipes: Iron Ore → Iron Plate, Copper Ore → Copper Plate
  - 100W power draw
- [ ] **Test asset:** Furnace-like mesh
- [ ] Test: Insert ore, machine processes (if powered)

### 8.3 Power System
- [ ] `PowerNetwork` manager:
  - Tracks all power producers and consumers
  - Calculates total production vs consumption
  - Distributes power to machines
- [ ] Machine behavior when unpowered:
  - Shows "No Power" indicator
  - Stops processing
  - Inserters stop

### 8.4 Generator Building
- [ ] `Generator` building:
  - Burns fuel (coal, fuel cells) for power
  - Output: 200W
  - Fuel slot
  - On/Off toggle
- [ ] **Test asset:** Generator mesh with smoke particle
- [ ] Test: Build generator, add fuel, produces power

### 8.5 Power Connections
- [ ] Buildings auto-connect within range (10m)
- [ ] Or explicit power cable building
- [ ] Visual: Power lines between connected buildings
- [ ] Power pole for extending range
- [ ] Test: Generator → Power Pole → Machine network

### 8.6 Power HUD
- [ ] When near powered network:
  - Show total production
  - Show total consumption
  - Warning if consumption > production
- [ ] Test: Build network, see power stats

**Milestone 8 Complete:**
- [ ] Smelter processes ores
- [ ] Generator produces power
- [ ] Machines require power to work
- [ ] Power distribution works

---

## Phase 9: Combat & Enemies

**Goal:** Dangerous creatures threaten the player.

### 9.1 Combat System
- [ ] `Damageable` component:
  - health, max_health
  - take_damage(amount, type, source)
  - die()
  - Signals: damaged, died
- [ ] `DamageDealer` component:
  - damage_amount, damage_type
  - Can be: hitbox (melee), projectile, area

### 9.2 Melee Combat
- [ ] Melee weapon item: Wrench
- [ ] Left-click to swing:
  - Animation (or simple rotation)
  - Hitbox active during swing
  - Hit detection via Area3D
  - Apply damage to Damageable objects
- [ ] **Test asset:** Wrench model (or elongated cube)
- [ ] Test: Swing wrench, hit object, see damage

### 9.3 Enemy Base
- [ ] `Enemy` base scene:
  - CharacterBody3D
  - Damageable component
  - AI state machine (Idle, Patrol, Chase, Attack, Dead)
  - Navigation agent for pathfinding
  - Detection area (sight range)
  - Attack area (melee range)
- [ ] Loot table: drops items on death
- [ ] Test: Enemy spawns, has health, can be killed

### 9.4 Enemy AI
- [ ] State machine behaviors:
  - **Idle:** Stand still, occasionally look around
  - **Patrol:** Walk between patrol points
  - **Chase:** Move toward player, navigate obstacles
  - **Attack:** Stop, play attack animation, deal damage
  - **Dead:** Play death animation, spawn loot
- [ ] Transitions:
  - Idle/Patrol → Chase: player in detection range
  - Chase → Attack: player in attack range
  - Chase → Patrol: player lost for X seconds
  - Any → Dead: health ≤ 0
- [ ] Test: Enemy patrols, sees player, chases, attacks

### 9.5 First Enemy: Maintenance Drone
- [ ] Flying enemy, mechanical
- [ ] Stats: 30 health, 5 damage, fast movement
- [ ] Behavior: patrols, shoots small projectile
- [ ] Drops: Electronic Scrap, Wire Bundle
- [ ] **Test asset:** Floating sphere with antenna
- [ ] Test: Fight drone, avoid shots, kill it, get loot

### 9.6 Second Enemy: Stalker
- [ ] Ground enemy, biological
- [ ] Stats: 80 health, 15 damage, medium speed
- [ ] Behavior: stalks player, ambushes, melee attack
- [ ] Drops: Stalker Hide, Stalker Fangs, Meat
- [ ] **Test asset:** Quadruped creature (or scary box with legs)
- [ ] Test: Get hunted by stalker, fight back, survive

### 9.7 Enemy Spawning
- [ ] `SpawnPoint` scene for enemies:
  - Enemy type to spawn
  - Respawn time
  - Max active (don't spawn if already at max)
  - Spawn conditions (player distance, etc.)
- [ ] Console: `spawn <enemy_id>` works with enemies
- [ ] Test: Spawn points populate prototype with enemies

**Milestone 9 Complete:**
- [ ] Melee combat works
- [ ] Two enemy types implemented
- [ ] AI patrols, chases, attacks
- [ ] Enemies drop loot

---

## Phase 10: First Game Level - Hub Sector

**Goal:** Move from prototype to real game environment.

### 10.1 Hub Layout Design
- [ ] Plan Hub sector on paper/whiteboard:
  - Spawn room (Cryo Bay)
  - Connecting corridors
  - Central atrium
  - Side rooms (storage, medical, quarters)
  - Exit to Engineering (locked initially)
- [ ] Estimated traversal: 5-10 minutes
- [ ] Mark locations for: resources, enemies, story items

### 10.2 Hub Blockout
- [ ] Create `sectors/hub/hub.tscn`
- [ ] Build layout with CSGBox (gray-box):
  - Floors, walls, ceilings
  - Doorways and transitions
  - No detail, just spaces
- [ ] Basic lighting: dim, emergency feel
- [ ] Test: Walk through entire Hub, spaces feel right

### 10.3 Hub Assets
- [ ] Generate/create Hub-specific assets:
  - Corridor wall segments
  - Floor tiles (metal grating)
  - Doors (automatic, manual)
  - Light fixtures (functional)
  - Debris and damage
- [ ] Replace CSG with proper meshes
- [ ] Test: Hub looks like a space station

### 10.4 Hub Population
- [ ] Place resource nodes throughout
- [ ] Place enemy spawn points
- [ ] Place loot containers
- [ ] Place story items (audio logs, documents)
- [ ] Balance: early game difficulty
- [ ] Test: Explore Hub, gather resources, fight enemies

### 10.5 Main Game Integration
- [ ] `game/main.tscn` loads Hub as starting level
- [ ] Player spawns in Cryo Bay
- [ ] All systems connected (survival, building, combat)
- [ ] Test: New game starts in Hub, all systems work

**Milestone 10 Complete:**
- [ ] Hub sector fully built and populated
- [ ] Can play entire game loop in Hub
- [ ] 2-3 hours of content

---

## Phase 11: Save/Load System

**Goal:** Progress persists between sessions.

### 11.1 Save Data Structure
- [ ] `SaveData` resource containing:
  - Player: position, rotation, stats, inventory
  - World: all placed buildings (position, rotation, type, state)
  - Containers: contents of each container
  - Enemies: spawner states, killed permanent enemies
  - Story: flags, collected items, unlocks
  - Meta: playtime, save date, game version

### 11.2 Serialization
- [ ] Save function gathers all data:
  - Query player state
  - Query BuildingManager for all buildings
  - Query all containers
  - Query story state
- [ ] Write to `user://saves/slot_X.tres`
- [ ] Test: Play game, save, check file exists

### 11.3 Loading
- [ ] Load function restores state:
  - Clear current world
  - Load player state
  - Rebuild all buildings
  - Restore container contents
  - Restore story state
- [ ] Test: Save, quit, load, everything restored

### 11.4 Save UI
- [ ] 3 save slots
- [ ] Save slot display: screenshot, playtime, date
- [ ] New Game: create new save
- [ ] Continue: load most recent
- [ ] Load: choose slot
- [ ] Save: from pause menu
- [ ] Delete: with confirmation
- [ ] Test: Multiple saves work independently

### 11.5 Autosave
- [ ] Autosave every 5 minutes
- [ ] Autosave on sector transition
- [ ] Autosave indicator on screen
- [ ] Keep last 3 autosaves (rotating)
- [ ] Test: Play for 5 minutes, autosave occurs

**Milestone 11 Complete:**
- [ ] Manual save and load works
- [ ] Autosave works
- [ ] Multiple save slots
- [ ] All game state persisted

---

## Phase 12: Multiplayer

**Goal:** Two players can play together online.

### 12.1 Steam Integration
- [ ] Add GodotSteam addon
- [ ] Initialize Steam on startup
- [ ] Handle Steam not running (offline mode)
- [ ] Test: Game launches with Steam overlay available

### 12.2 Lobby System
- [ ] Host Game:
  - Create Steam lobby
  - Set lobby data (game name, player count)
  - Wait for players
- [ ] Join Game:
  - Show friends' lobbies
  - Show public lobbies (optional)
  - Join selected lobby
- [ ] Invite via Steam friends list
- [ ] Test: Create lobby, friend can see and join

### 12.3 Network Manager
- [ ] Host becomes authoritative server
- [ ] Client connects as remote player
- [ ] `NetworkManager` autoload:
  - Connection state
  - Player list
  - RPC helpers
- [ ] Test: Two instances connect successfully

### 12.4 Player Synchronization
- [ ] Each player has unique network ID
- [ ] Sync at 20Hz: position, rotation, animation state
- [ ] Interpolation for smooth remote player movement
- [ ] Local player has full control, others are puppets
- [ ] Test: Both players see each other move smoothly

### 12.5 World Synchronization
- [ ] Buildings: host authoritative
  - Client requests build → host validates → all clients spawn
- [ ] Items: host authoritative
  - Pickup removes for all
  - Drop spawns for all
- [ ] Enemies: host runs AI
  - Clients see synced positions
  - Damage dealt on host, synced to clients
- [ ] Test: Player 1 builds, Player 2 sees it immediately

### 12.6 Multiplayer Polish
- [ ] Player names above heads
- [ ] Voice chat (Steam Voice) or text chat
- [ ] Pause for host only
- [ ] Save is host-only
- [ ] Client disconnect handling
- [ ] Host migration (optional, complex)
- [ ] Test: Full multiplayer session without issues

**Milestone 12 Complete:**
- [ ] Can host and join via Steam
- [ ] Two players see each other
- [ ] World synced between players
- [ ] Stable multiplayer session

---

## Phase 13: Engineering Sector

**Goal:** Second area with advanced content.

### 13.1 Engineering Layout
- [ ] Plan Engineering sector:
  - Larger than Hub
  - Industrial theme: reactors, machinery, pipes
  - Hazards: steam, electricity, radiation
  - Connection to Hub (requires key/progress)
  - Future connection to Core (locked)

### 13.2 Engineering Blockout & Build
- [ ] Create `sectors/engineering/engineering.tscn`
- [ ] Gray-box layout
- [ ] Generate industrial assets
- [ ] Replace with proper meshes
- [ ] Industrial lighting and atmosphere

### 13.3 Engineering Content
- [ ] Advanced resource nodes
- [ ] New enemies or tougher variants
- [ ] Tier 2-3 recipes/blueprints found here
- [ ] Story elements (logs, SYNTHESIS hints)

### 13.4 Advanced Automation
- [ ] Assembler machine: complex recipes
- [ ] Advanced Smelter: faster, more efficient
- [ ] Tier 2 inserters and belts
- [ ] More complex production chains

### 13.5 Sector Transition
- [ ] Door/airlock between Hub and Engineering
- [ ] Requires key item or story progress
- [ ] Loading handled (streaming or loading screen)
- [ ] Test: Travel between sectors

**Milestone 13 Complete:**
- [ ] Engineering fully playable
- [ ] 8-12 hours total content
- [ ] Tier 2-3 automation available

---

## Phase 14: Story & Audio

**Goal:** Narrative and atmosphere.

### 14.1 Audio Log System
- [ ] `AudioLog` item type
- [ ] Collect to add to library
- [ ] Plays audio on collection
- [ ] Journal menu to replay
- [ ] Write/generate log scripts
- [ ] Generate placeholder voice (TTS)

### 14.2 ARIA Integration
- [ ] ARIA speaks at key moments
- [ ] Dialogue UI for conversations
- [ ] Voice lines (TTS placeholder OK)
- [ ] Tutorial guidance
- [ ] Story revelations

### 14.3 Environmental Storytelling
- [ ] Bodies and death scenes
- [ ] Readable documents
- [ ] Visual storytelling details
- [ ] Cliffhanger ending setup

### 14.4 Sound Design
- [ ] Ambient soundscapes
- [ ] Music (calm, tense, combat states)
- [ ] All actions have sound effects
- [ ] Generate/source audio assets

**Milestone 14 Complete:**
- [ ] Story delivered through logs and ARIA
- [ ] Full audio design
- [ ] Atmospheric experience

---

## Phase 15: Polish & Launch

**Goal:** Ready for Early Access.

### 15.1 UI Polish
- [ ] Main menu (New, Continue, Load, Settings, Quit)
- [ ] Pause menu
- [ ] All settings functional
- [ ] Loading screens
- [ ] Credits

### 15.2 Performance Optimization
- [ ] Profile bottlenecks
- [ ] LOD system
- [ ] Occlusion culling
- [ ] Graphics options
- [ ] Target: 60 FPS on recommended specs

### 15.3 Bug Fixing
- [ ] Full playthrough testing
- [ ] Fix critical bugs
- [ ] Document known issues

### 15.4 Steam Release
- [ ] Store page complete
- [ ] Achievements (10-15)
- [ ] Steam Cloud saves
- [ ] Trading cards (optional)
- [ ] Build uploaded to Steam

### 15.5 Launch
- [ ] Release date announcement
- [ ] Launch day monitoring
- [ ] Hotfix readiness

**Milestone 15 Complete:**
- [ ] Early Access launched on Steam

---

## Post-EA Roadmap

- [ ] Bio-Research sector
- [ ] Core sector
- [ ] 4-player multiplayer
- [ ] Boss: The Shepherd
- [ ] Full story + multiple endings
- [ ] Tier 4 automation
- [ ] Mod support

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Day 1 Sales | 1,000+ |
| Month 1 Sales | 5,000+ |
| Review Score | 70%+ positive |
| Avg Playtime | 6+ hours |
| Crash Rate | <1% |

---

*Last Updated: February 2026*
