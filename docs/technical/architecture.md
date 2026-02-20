# System Architecture

## Overview

Complete technical architecture for Orbital Eden, covering all systems from infrastructure to game client.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ORBITAL EDEN ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────────────────────┐   │
│   │   PLAYER    │────▶│   STEAM     │────▶│      BACKEND SERVICES       │   │
│   │   CLIENT    │◀────│   NETWORK   │◀────│   (Analytics/Telemetry)     │   │
│   │  (Godot 4)  │     │    (P2P)    │     │                             │   │
│   └─────────────┘     └─────────────┘     └─────────────────────────────┘   │
│         │                                               │                    │
│         │         ┌─────────────────────┐               │                    │
│         └────────▶│   EXTERNAL SERVICES │◀──────────────┘                    │
│                   │  (AI Asset Gen, etc)│                                    │
│                   └─────────────────────┘                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Infrastructure

### 1.1 Distribution Platform

| Component | Service | Purpose |
|-----------|---------|---------|
| Store | Steam | Distribution, payments, regional pricing |
| Authentication | Steam Auth | Player identity, anti-piracy |
| Cloud Saves | Steam Cloud | Save game synchronization |
| Multiplayer | Steam P2P | Peer-to-peer networking |
| Achievements | Steam Stats | Player progression tracking |
| Community | Steam Workshop | Future mod support |

### 1.2 Backend Services (Minimal)

Self-hosted lightweight services for analytics and bug tracking.

```
┌─────────────────────────────────────────────────────────────┐
│                    BACKEND INFRASTRUCTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌──────────────────┐    ┌──────────────────────────────┐  │
│   │  Analytics API   │    │      Database (SQLite)       │  │
│   │   (Hono/Bun)     │───▶│  - Telemetry events          │  │
│   │   Port: 3000     │    │  - Crash reports             │  │
│   └────────┬─────────┘    │  - Play session data         │  │
│            │              └──────────────────────────────┘  │
│            │                                                 │
│   ┌────────▼─────────┐    ┌──────────────────────────────┐  │
│   │   VPS Server     │    │      Monitoring              │  │
│   │  (Hetzner/DO)    │    │  - Uptime: BetterStack       │  │
│   │  $5-10/month     │    │  - Logs: Local files         │  │
│   └──────────────────┘    └──────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Why minimal backend?**
- Steam handles heavy lifting (auth, saves, multiplayer)
- Reduces operational complexity for solo dev
- Analytics still captured for informed decisions
- Can scale up post-EA if needed

### 1.3 Analytics Data Collected

| Event | Data | Purpose |
|-------|------|---------|
| `session_start` | Platform, version, hardware specs | Compatibility tracking |
| `session_end` | Playtime, quit reason | Retention analysis |
| `player_death` | Cause, location, hour played | Balance tuning |
| `milestone_reached` | Milestone ID, time to reach | Progression pacing |
| `crash_report` | Stack trace, system info | Bug fixing priority |
| `performance_sample` | FPS, memory, entity count | Optimization targets |

### 1.4 External Services

| Service | Provider | Purpose | Cost |
|---------|----------|---------|------|
| 3D Models | Meshy, Tripo3D | AI asset generation | Pay-per-use |
| Textures | Stable Diffusion | Material generation | Local/free |
| Voice | ElevenLabs | Character voice lines | ~$22/month |
| Sound FX | ElevenLabs Sound | Audio effects | Included |
| Music | Suno AI | Soundtrack generation | ~$10/month |
| Hosting | Hetzner | Analytics backend | ~$5/month |

---

## 2. Game Client Architecture

### 2.1 High-Level Systems

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           GODOT 4 CLIENT                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         AUTOLOAD SINGLETONS                          │    │
│  ├─────────────┬─────────────┬─────────────┬─────────────┬─────────────┤    │
│  │  SignalBus  │  GameState  │  Network    │  Audio      │  Analytics  │    │
│  │  (Events)   │  (Save/Load)│  Manager    │  Manager    │  Manager    │    │
│  └─────────────┴─────────────┴─────────────┴─────────────┴─────────────┘    │
│                                    │                                         │
│  ┌─────────────────────────────────┼─────────────────────────────────────┐  │
│  │                          CORE SYSTEMS                                 │  │
│  ├───────────────┬───────────────┬─┴─────────────┬───────────────────────┤  │
│  │   Survival    │   Building    │   Automation  │      Combat           │  │
│  │   System      │   System      │   System      │      System           │  │
│  │ - Oxygen      │ - Grid        │ - Belts       │ - Melee               │  │
│  │ - Hunger      │ - Placement   │ - Machines    │ - Ranged              │  │
│  │ - Sanity      │ - Structures  │ - Power       │ - AI                  │  │
│  └───────────────┴───────────────┴───────────────┴───────────────────────┘  │
│                                    │                                         │
│  ┌─────────────────────────────────┼─────────────────────────────────────┐  │
│  │                           GAME WORLD                                  │  │
│  ├───────────────┬───────────────┬─┴─────────────┬───────────────────────┤  │
│  │    Player     │   Entities    │    World      │       UI              │  │
│  │  Controller   │  (Enemies,    │   (Chunks,    │   (HUD, Menus,        │  │
│  │               │   Items)      │    Props)     │    Inventory)         │  │
│  └───────────────┴───────────────┴───────────────┴───────────────────────┘  │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Project Structure

```
orbital_eden/
├── project.godot
│
├── autoload/                      # Global singletons
│   ├── signal_bus.gd             # Event system
│   ├── game_state.gd             # Save/load, game progression
│   ├── network_manager.gd        # Steam P2P, multiplayer
│   ├── audio_manager.gd          # Sound/music control
│   └── analytics_manager.gd      # Telemetry events
│
├── systems/                       # Core game systems
│   ├── survival/
│   │   ├── survival_manager.gd
│   │   ├── oxygen_system.gd
│   │   ├── hunger_system.gd
│   │   └── sanity_system.gd
│   ├── building/
│   │   ├── building_manager.gd
│   │   ├── grid_system.gd
│   │   └── structure_database.gd
│   ├── automation/
│   │   ├── belt_manager.gd
│   │   ├── machine_manager.gd
│   │   └── power_grid.gd
│   └── combat/
│       ├── combat_manager.gd
│       ├── damage_system.gd
│       └── ai_director.gd
│
├── entities/                      # Game objects
│   ├── player/
│   │   ├── player.tscn
│   │   ├── player_controller.gd
│   │   ├── player_inventory.gd
│   │   └── player_stats.gd
│   ├── enemies/
│   │   ├── base_enemy.tscn
│   │   ├── stalker/
│   │   ├── drone/
│   │   └── crawler/
│   ├── items/
│   │   ├── base_item.tscn
│   │   └── item_database.gd
│   └── buildings/
│       ├── base_building.tscn
│       ├── machines/
│       └── structures/
│
├── world/                         # Level and world management
│   ├── chunk_manager.gd
│   ├── sector_loader.gd
│   ├── sectors/
│   │   ├── hub/
│   │   ├── engineering/
│   │   └── bio_research/
│   └── props/
│
├── ui/                            # User interface
│   ├── hud/
│   │   ├── hud.tscn
│   │   ├── health_bar.gd
│   │   └── oxygen_indicator.gd
│   ├── menus/
│   │   ├── main_menu.tscn
│   │   ├── pause_menu.tscn
│   │   └── settings_menu.tscn
│   ├── inventory/
│   │   ├── inventory_ui.tscn
│   │   └── slot.gd
│   └── building/
│       └── build_menu.tscn
│
├── resources/                     # Data definitions
│   ├── items/                    # Item resources (.tres)
│   ├── recipes/                  # Crafting recipes
│   ├── buildings/                # Building definitions
│   ├── enemies/                  # Enemy configurations
│   └── dialogue/                 # ARIA dialogue trees
│
├── assets/                        # Art, audio, etc.
│   ├── models/
│   ├── textures/
│   ├── audio/
│   │   ├── sfx/
│   │   ├── music/
│   │   └── voice/
│   ├── fonts/
│   └── shaders/
│
└── addons/                        # Third-party plugins
    ├── godotsteam/               # Steam SDK integration
    └── gut/                      # Unit testing (dev only)
```

### 2.3 Autoload Singletons

| Singleton | Responsibility |
|-----------|---------------|
| `SignalBus` | Global event system, decoupled communication |
| `GameState` | Save/load, game progression, world state |
| `NetworkManager` | Steam P2P, player sync, RPC handling |
| `AudioManager` | Music, SFX, voice line playback |
| `AnalyticsManager` | Telemetry events to backend |

### 2.4 Core Systems

| System | Responsibility | Update Rate |
|--------|---------------|-------------|
| **Survival** | Player stats (O2, hunger, sanity, health) | 60 FPS |
| **Building** | Grid placement, structure management | On demand |
| **Automation** | Belt simulation, machine processing, power | 30 FPS (visible) / 1 FPS (background) |
| **Combat** | Damage calculation, AI behavior, spawning | 60 FPS |
| **World** | Chunk loading, sector management | On demand |

---

## 3. Network Architecture

### 3.1 Steam P2P Model

```
┌─────────────────────────────────────────────────────────────┐
│                     MULTIPLAYER MODEL                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│      HOST (Player 1)                CLIENT (Player 2)        │
│   ┌─────────────────┐            ┌─────────────────┐        │
│   │   Full Game     │◀──Steam───▶│   Full Game     │        │
│   │   Simulation    │    P2P     │   Simulation    │        │
│   │                 │            │                 │        │
│   │  ┌───────────┐  │            │  ┌───────────┐  │        │
│   │  │ Authority │  │            │  │ Predicted │  │        │
│   │  │ (Server)  │  │───────────▶│  │  (Client) │  │        │
│   │  └───────────┘  │  State     │  └───────────┘  │        │
│   │                 │  Sync      │                 │        │
│   │  ┌───────────┐  │            │  ┌───────────┐  │        │
│   │  │  World    │  │◀───────────│  │  Inputs   │  │        │
│   │  │  State    │  │  Input     │  │  Only     │  │        │
│   │  └───────────┘  │  Events    │  └───────────┘  │        │
│   └─────────────────┘            └─────────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Authority Model

| Data | Authority | Sync Method |
|------|-----------|-------------|
| Player position | Host validates | 20 Hz state sync |
| Inventory | Host authoritative | Event-based |
| Building placement | Host validates | Event-based |
| Belt items | Host only | Enter/exit events |
| Enemy AI | Host runs | State snapshots |
| World state | Host | On change |

### 3.3 Bandwidth Optimization

| System | Naive Approach | Optimized Approach |
|--------|----------------|-------------------|
| Belt items (1000) | 192 KB/s (position sync) | ~0.2 KB/s (events only) |
| Player sync | 60 Hz full state | 20 Hz + interpolation |
| Buildings | Continuous sync | Event on place/remove |

---

## 4. Data Architecture

### 4.1 Save System

```
┌─────────────────────────────────────────────────────────────┐
│                      SAVE DATA STRUCTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   SaveData.tres (Godot Resource)                            │
│   ├── player_data                                           │
│   │   ├── position: Vector3                                 │
│   │   ├── rotation: Vector3                                 │
│   │   ├── stats: { oxygen, hunger, sanity, health }        │
│   │   └── inventory: Array[ItemStack]                       │
│   │                                                          │
│   ├── world_data                                            │
│   │   ├── buildings: Array[BuildingSaveData]                │
│   │   ├── belt_contents: Array[BeltItemData]                │
│   │   ├── machine_states: Dictionary                        │
│   │   └── discovered_areas: Array[String]                   │
│   │                                                          │
│   ├── story_data                                            │
│   │   ├── current_act: int                                  │
│   │   ├── completed_objectives: Array[String]               │
│   │   ├── collected_logs: Array[String]                     │
│   │   └── aria_trust_level: float                           │
│   │                                                          │
│   └── meta_data                                             │
│       ├── save_version: String                              │
│       ├── playtime_seconds: int                             │
│       └── timestamp: int                                    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Save Locations

| Type | Location | Backup |
|------|----------|--------|
| Local saves | `user://saves/` | 3 rotating backups |
| Cloud saves | Steam Cloud | Automatic |
| Settings | `user://settings.cfg` | None needed |

### 4.3 Resource Definitions

All game data defined as Godot Resources for easy editing and AI generation:

```gdscript
# resources/items/item_definition.gd
class_name ItemDefinition
extends Resource

@export var id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var mesh: PackedScene
@export var stack_size: int = 100
@export var tier: int = 1
@export var categories: Array[String]
```

---

## 5. Performance Architecture

### 5.1 Target Specifications

| Spec | Minimum | Recommended |
|------|---------|-------------|
| OS | Windows 10 | Windows 10/11 |
| CPU | Intel i5-6600 / Ryzen 3 1200 | Intel i5-10400 / Ryzen 5 3600 |
| RAM | 8 GB | 16 GB |
| GPU | GTX 1060 / RX 580 | GTX 1660 / RX 5600 |
| Storage | 10 GB SSD | 10 GB SSD |
| Target FPS | 30 | 60 |

### 5.2 Optimization Strategies

| System | Strategy |
|--------|----------|
| **Rendering** | MultiMesh for repeated objects (belt items, props) |
| **World** | Chunk-based loading, 3x3 active chunks |
| **Automation** | Background simulation for unseen areas |
| **LOD** | 4-level LOD system (20m/50m/100m/cull) |
| **Physics** | Simplified colliders, sleep inactive bodies |
| **Audio** | Pooled audio players, distance culling |

### 5.3 Chunk System

```
┌─────────┬─────────┬─────────┐
│ Unload  │  Load   │ Unload  │
│         │ (Queue) │         │
├─────────┼─────────┼─────────┤
│  Load   │ ACTIVE  │  Load   │
│ (Queue) │(Player) │ (Queue) │
├─────────┼─────────┼─────────┤
│ Unload  │  Load   │ Unload  │
│         │ (Queue) │         │
└─────────┴─────────┴─────────┘

Active: Full simulation + rendering
Load Queue: Load in background
Unload: Keep in memory, no simulation
```

---

## 6. Development Pipeline

### 6.1 Tools

| Tool | Purpose |
|------|---------|
| Godot 4.3+ | Game engine |
| VS Code + Godot Tools | Code editing |
| Git + GitHub | Version control |
| GUT | Unit testing |
| OpenCode + MCP | AI-assisted development |

### 6.2 Build Pipeline

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Develop   │────▶│    Test     │────▶│   Release   │
│  (Local)    │     │  (Playtest) │     │   (Steam)   │
└─────────────┘     └─────────────┘     └─────────────┘
      │                   │                   │
      ▼                   ▼                   ▼
  Debug build        Beta build         Release build
  All logging        Some logging       Minimal logging
  Dev tools on       Dev tools off      Dev tools off
```

### 6.3 Branching Strategy

```
main ─────────────────────────────────────────────▶
       │                    │
       └── feature/xxx ─────┘ (merge via PR)
       │
       └── release/x.x ──────▶ Steam deploy
```

---

## 7. Security

### 7.1 Anti-Cheat (Host Authority)

| Threat | Mitigation |
|--------|------------|
| Speed hacking | Host validates movement deltas |
| Item duplication | Host-authoritative inventory |
| Resource hacking | Server-side resource validation |
| Wall hacking | Fog of war calculated on host |

### 7.2 Data Protection

| Data | Protection |
|------|------------|
| Save files | Local encryption (optional) |
| Steam auth | Steam SDK handles |
| Analytics | HTTPS only, no PII |

---

## 8. Monitoring & Operations

### 8.1 Analytics Dashboard

Key metrics to track post-launch:

| Metric | Alert Threshold |
|--------|-----------------|
| Crash rate | > 2% sessions |
| Avg session length | < 30 minutes |
| Day 1 retention | < 40% |
| Refund rate | > 15% |

### 8.2 Update Strategy

| Update Type | Frequency | Content |
|-------------|-----------|---------|
| Hotfix | As needed | Critical bugs only |
| Patch | Weekly (first month) | Bug fixes, balance |
| Update | Monthly | New content, features |

---

[Previous: Level Design](../design/level-design.md) | [Back to Index](../../README.md) | [Next: Multiplayer Implementation](multiplayer.md)
