# Multiplayer Implementation

## The Technical Challenge

The biggest technical challenge is synchronizing a factory with thousands of moving items in a multiplayer environment without server collapse.

---

## 6.1 Hybrid Network Architecture

Godot 4 offers a high-level API (MultiplayerSynchronizer), excellent for players, but inefficient for massive conveyor belt systems.

### Player Synchronization (High-Level)

| Component | Implementation |
|-----------|----------------|
| Characters | MultiplayerSynchronizer + MultiplayerSpawner |
| Projectiles | MultiplayerSpawner |
| Vehicles | MultiplayerSynchronizer |
| Interpolation | Automatic via API |

**Authority Model:** Server is authoritative. Clients send inputs; server validates and returns state.

### Factory Synchronization (Low-Level / Data Simulation)

**Critical Rule:** Do NOT use physical nodes (RigidBody) for each item on conveyor belts. This would kill network performance.

### The Illusion Strategy

A conveyor belt is, logically, a data Array.

| Component | Server | Client |
|-----------|--------|--------|
| Item position | Calculated only on enter/exit | Local interpolation |
| Belt movement | Speed calculation | Visual animation |
| Item count | Integer tracking | Visual mesh instances |

### Implementation

```
Server Logic:
"Item X entered belt A at time T. Belt speed = V. 
Will exit at T + (Length/V)"
→ No position updates per frame

Client Logic:
Receives RPC event: item_entered_belt(item_id, belt_id)
→ Instantiates visual mesh
→ Moves locally based on belt speed
→ Removes on exit event
```

**Result:** Minimum network traffic. Data sent only when items enter/exit machines or belts, not during transit.

---

## 6.2 Network Protocol Design

### Event-Based Communication

| Event | Direction | Data |
|-------|-----------|------|
| Item spawn | Server → Clients | item_id, type, position |
| Item enter belt | Server → Clients | item_id, belt_id, entry_time |
| Item exit belt | Server → Clients | item_id, belt_id, exit_position |
| Machine process | Server → Clients | machine_id, input_items, output_items |
| Building placed | Client → Server | building_type, position, rotation |
| Building removed | Client → Server | building_id |

### Bandwidth Estimates

| Activity | Bandwidth per Event |
|----------|---------------------|
| Player movement | 32 bytes @ 20 Hz |
| Belt item event | 24 bytes (on enter/exit only) |
| Machine process | 48 bytes (on completion) |
| Building placement | 64 bytes (one-time) |

### Example: 100-item Belt System

| Approach | Network Load |
|----------|--------------|
| Naive (sync all positions) | 3200 bytes × 60 fps = 192 KB/s |
| Event-based (enter/exit only) | ~200 bytes per item lifecycle |

**Optimization:** ~1000x bandwidth reduction.

---

## 6.3 Rendering Optimization (Thousands of Objects)

### MultiMeshInstance3D

For rendering thousands of minerals or belt items, Godot allows using MultiMesh. This draws thousands of instances of a model in a single GPU draw call.

| Scenario | Traditional | MultiMesh |
|----------|-------------|-----------|
| 1000 items | 1000 draw calls | 1 draw call |
| FPS impact | Significant | Negligible |

### Implementation Approach

```gdscript
# belts/belt_visual_manager.gd
class_name BeltVisualManager
extends Node3D

@export var item_mesh: Mesh
var multimesh: MultiMeshInstance3D

func _ready() -> void:
    multimesh = MultiMeshInstance3D.new()
    multimesh.multimesh = MultiMesh.new()
    multimesh.multimesh.mesh = item_mesh
    add_child(multimesh)

func update_item_positions(items: Array[BeltItem]) -> void:
    multimesh.multimesh.instance_count = items.size()
    for i in items.size():
        var transform := Transform3D()
        transform.origin = items[i].visual_position
        multimesh.multimesh.set_instance_transform(i, transform)
```

### Godot Server APIs

For factory logic, consider using Godot's Server APIs or writing simulation logic in C# or GDExtension (C++) for maximum performance if GDScript is insufficient for pure mathematical calculations.

| System | GDScript | C# / C++ |
|--------|----------|----------|
| Player logic | Good | Better |
| Belt simulation | Acceptable | Recommended |
| Network handling | Good | Better |
| Physics (if needed) | Good | Better |

---

## 6.4 Persistence & Saving

### Custom Resources

Use Godot's Resource class for saving world state. Resources can be saved to and loaded from disk very quickly in binary format.

### Chunking (Fragmentation)

Divide the station into "Save Cells." If no players are in Bio Sector, that scene unloads visually, but a lightweight "Simulation Manager" continues calculating its production (input/output) in background.

### Implementation

```gdscript
# systems/world_simulator.gd
class_name WorldSimulator
extends Node

var active_sectors: Dictionary = {}
var background_simulations: Dictionary = {}

func simulate_sector(sector_id: String, delta: float) -> void:
    if sector_id in active_sectors:
        # Full simulation with visuals
        active_sectors[sector_id].simulate_full(delta)
    else:
        # Background math only
        var sim: SectorSimulation = background_simulations.get(sector_id)
        if sim:
            sim.simulate_numbers_only(delta)

func register_sector(sector_id: String, scene: Node) -> void:
    active_sectors[sector_id] = scene
    background_simulations.erase(sector_id)

func unregister_sector(sector_id: String, simulation: SectorSimulation) -> void:
    active_sectors.erase(sector_id)
    background_simulations[sector_id] = simulation
```

---

## 6.5 Network Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         SERVER                               │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Player    │  │   Factory   │  │   World Simulator   │  │
│  │  Authority  │  │   Logic     │  │   (Background)      │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                │                    │              │
│         └────────────────┼────────────────────┘              │
│                          │                                   │
│                   ┌──────┴──────┐                            │
│                   │ Event Queue │                            │
│                   └──────┬──────┘                            │
└──────────────────────────┼──────────────────────────────────┘
                           │
                    RPC Events (Enter/Exit only)
                           │
┌──────────────────────────┼──────────────────────────────────┐
│                     CLIENTS                                  │
├──────────────────────────┼──────────────────────────────────┤
│  ┌─────────────┐  ┌──────┴──────┐  ┌─────────────────────┐  │
│  │   Player    │  │   Visual    │  │   Local Interp.     │  │
│  │  Predictor  │  │   Renderer  │  │   (Belts, Items)    │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 6.6 Anti-Cheat Considerations

| Threat | Mitigation |
|--------|------------|
| Speed hacking | Server-side movement validation |
| Item duplication | Server-authoritative inventory |
| Map hacking | Fog of war server-side |
| Building exploits | Server validates placement rules |

### Validation Pattern

```gdscript
# All building placement goes through server validation
func _on_building_placement_requested(player_id: int, building: BuildingData, pos: Vector3) -> void:
    if not _validate_placement(player_id, building, pos):
        rpc_id(player_id, "placement_rejected", building.id)
        return
    
    var cost_valid := _validate_resources(player_id, building.cost)
    if not cost_valid:
        rpc_id(player_id, "insufficient_resources")
        return
    
    # Server authoritatively creates building
    _create_building(building, pos)
    rpc("building_created", building.id, pos)
```

---

## 6.7 Connection Handling

### Steam Integration

| Feature | Implementation |
|---------|---------------|
| Lobby creation | SteamMatchmaking |
| P2P networking | SteamNetworking |
| Voice chat | SteamVoice |
| Achievements | SteamUserStats |

### Fallback: ENet

For non-Steam builds or dedicated servers:

```gdscript
# network/network_manager.gd
class_name NetworkManager
extends Node

var peer: ENetMultiplayerPeer

func create_server(port: int, max_players: int) -> Error:
    peer = ENetMultiplayerPeer.new()
    var err := peer.create_server(port, max_players)
    if err == OK:
        multiplayer.multiplayer_peer = peer
    return err

func join_server(address: String, port: int) -> Error:
    peer = ENetMultiplayerPeer.new()
    var err := peer.create_client(address, port)
    if err == OK:
        multiplayer.multiplayer_peer = peer
    return err
```

---

[← Previous: Technical Architecture](architecture.md) | [Back to Index](../../README.md) | [Next: AI Workflow →](ai-workflow.md)
