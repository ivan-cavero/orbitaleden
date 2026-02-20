# Technology Tree

## Complete Automation Progression System

This document details the full technology tree for Orbital Eden, covering all four tiers of progression from basic survival tools to full industrial automation.

---

## 1. Technology Philosophy

### Core Design Principles

| Principle | Implementation |
|-----------|----------------|
| **Survival → Comfort** | Each tech tier reduces manual survival tasks |
| **Earned Progression** | Unlocks require exploration + resources |
| **Meaningful Choices** | Multiple paths, different playstyles |
| **Visual Satisfaction** | Factory aesthetics scale with tier |
| **Story Integration** | Technologies tied to lore discoveries |

### The Automation Journey

```
MANUAL LABOR ──────────────────────────────────────────────> FULL AUTOMATION

TIER 1          TIER 2            TIER 3              TIER 4
SURVIVAL        MECHANIZATION     AUTOMATION          INDUSTRIALIZATION
─────────────────────────────────────────────────────────────────────────>
Hand-made       First machines    Smart systems       AI-controlled
everything      assist player     work alone          self-expanding

Hours 0-8       Hours 8-16        Hours 16-28         Hours 28-40+
```

---

## 2. Tier Overview

### Tier Comparison Matrix

| Aspect | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|--------|--------|--------|--------|--------|
| **Name** | Survival | Mechanization | Automation | Industrialization |
| **Theme** | Desperation | Hope | Control | Mastery |
| **Key Resource** | Scrap Metal | Titanium | AI Modules | Quantum Crystals |
| **Power Req** | Batteries | Generators | Reactors | Fusion |
| **Transport** | Manual | Conveyors | Drones | Teleporters |
| **Crafting** | Workbench | Assembler | Manufacturer | Quantum Forge |
| **Hours** | 0-8 | 8-16 | 16-28 | 28-40+ |
| **Story Act** | Act 1 | Act 2 Early | Act 2 Mid | Act 3 |

---

## 3. Tier 1: Survival

### Unlock Requirements
- **Story:** Complete tutorial (fix atmosphere)
- **Resources:** Access to basic salvage
- **Location:** Hub Sector

### 3.1 Crafting Tree

```
                    ┌─────────────┐
                    │ WORKBENCH   │
                    │  (Starting) │
                    └──────┬──────┘
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌──────────┐    ┌──────────┐    ┌──────────┐
    │  TOOLS   │    │ SURVIVAL │    │ BUILDING │
    └────┬─────┘    └────┬─────┘    └────┬─────┘
         │               │               │
    ┌────┴────┐     ┌────┴────┐     ┌────┴────┐
    │Repair   │     │Bandage  │     │Floor    │
    │Tool     │     │         │     │Tile     │
    ├─────────┤     ├─────────┤     ├─────────┤
    │Cutting  │     │Medkit   │     │Wall     │
    │Torch    │     │         │     │Section  │
    ├─────────┤     ├─────────┤     ├─────────┤
    │Pry Bar  │     │Food     │     │Door     │
    │         │     │Processor│     │Frame    │
    ├─────────┤     ├─────────┤     ├─────────┤
    │Multitool│     │O2       │     │Standard │
    │         │     │Generator│     │Door     │
    └─────────┘     └─────────┘     └─────────┘
```

### 3.2 Technology Unlocks

| Technology | Prerequisites | Unlock Method | Function |
|------------|---------------|---------------|----------|
| **Workbench** | None | Starting | Basic hand-crafting |
| **Repair Tool** | Workbench | Auto | Fix damaged items |
| **Cutting Torch** | Workbench | Auto | Cut metal, open doors |
| **Smelter** | Workbench + 10 Iron Ore | Research | Ore → Metal plates |
| **Food Processor** | Workbench + Food Rations | Research | Basic meal creation |
| **Oxygen Generator** | Fix Station O2 | Story | Breathable air production |
| **Water Recycler** | Build first base | Story | Clean water |
| **Basic Conveyor** | 20 items smelted | Research | Item transport |
| **Battery Bank** | 5 electronics crafted | Research | Power storage |
| **Solar Panel** | Explore Hub exterior | Discovery | Passive power |

### 3.3 Tier 1 Crafting Recipes

| Output | Input | Time | Station |
|--------|-------|------|---------|
| Repair Tool | 2x Scrap + 1x Wire | 5s | Workbench |
| Cutting Torch | 3x Scrap + 1x Fuel | 8s | Workbench |
| Iron Plate | 2x Iron Ore | 10s | Smelter |
| Steel Plate | 2x Iron Plate + 1x Carbon | 15s | Smelter |
| Basic Circuit | 2x Copper Wire + 1x Silicon | 12s | Workbench |
| Conveyor Belt | 2x Steel + 1x Rubber | 8s | Workbench |
| Wall Section | 1x Wall Panel + 1x Metal Frame | 10s | Workbench |

### 3.4 Power System (Tier 1)

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│ SOLAR PANEL  │────▶│ BATTERY BANK │────▶│   MACHINES   │
│   10 kW      │     │  100 kW cap  │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
                            │
┌──────────────┐            │
│  GENERATOR   │────────────┘
│   25 kW      │
│  (fuel req)  │
└──────────────┘
```

**Power Consumption (Tier 1):**
| Machine | Power Draw |
|---------|------------|
| Workbench | 0 kW (manual) |
| Smelter | 15 kW |
| Food Processor | 10 kW |
| O2 Generator | 20 kW |
| Water Recycler | 15 kW |
| Conveyor (per 10m) | 2 kW |

---

## 4. Tier 2: Mechanization

### Unlock Requirements
- **Story:** Access Engineering OR Bio-Research sector
- **Resources:** Titanium Ore, Processing Units
- **Research:** 10 Tier 1 technologies

### 4.1 Crafting Tree

```
                         ┌──────────────┐
                         │  ASSEMBLER   │
                         │  (Tier 2)    │
                         └──────┬───────┘
          ┌─────────────────────┼─────────────────────┐
          ▼                     ▼                     ▼
   ┌─────────────┐      ┌─────────────┐       ┌─────────────┐
   │ ENGINEERING │      │   BIOLOGY   │       │   COMBAT    │
   └──────┬──────┘      └──────┬──────┘       └──────┬──────┘
          │                    │                     │
   ┌──────┴──────┐      ┌──────┴──────┐       ┌──────┴──────┐
   │Fast Conveyor│      │Hydroponic   │       │Plasma       │
   │             │      │Tray         │       │Cutter       │
   ├─────────────┤      ├─────────────┤       ├─────────────┤
   │Smart        │      │Bio-Processor│       │Engineering  │
   │Splitter     │      │             │       │Suit         │
   ├─────────────┤      ├─────────────┤       ├─────────────┤
   │Fuel Cell    │      │Chemical Lab │       │Combat       │
   │Reactor      │      │             │       │Stim         │
   ├─────────────┤      ├─────────────┤       ├─────────────┤
   │Fast         │      │Protein      │       │Bio-         │
   │Inserter     │      │Synthesizer  │       │Containment  │
   └─────────────┘      └─────────────┘       └─────────────┘
```

### 4.2 Technology Unlocks

| Technology | Prerequisites | Unlock Method | Function |
|------------|---------------|---------------|----------|
| **Assembler** | Complete Tier 1 + Enter new sector | Story | Automated crafting |
| **Fast Conveyor** | 50 items transported | Research | 2x belt speed |
| **Smart Splitter** | Assembler built | Research | Filtered routing |
| **Fast Inserter** | 100 items inserted | Research | 2x insert speed |
| **Fuel Cell Reactor** | Find reactor room | Discovery | 50 kW power |
| **Refinery** | Process 100 ore | Research | Liquid handling |
| **Chemical Lab** | Refinery built | Research | Compound creation |
| **Hydroponic Tray** | Find Bio-Research | Discovery | Food growing |
| **Bio-Processor** | Harvest 50 alien samples | Research | Xeno processing |
| **Scanner** | Explore 40% of sector | Discovery | Enemy detection |
| **Engineering Suit** | Complete engineer story | Story | Heat resistance |

### 4.3 Tier 2 Crafting Recipes

| Output | Input | Time | Station |
|--------|-------|------|---------|
| Processing Unit | 2x Adv Circuit + 1x Chip | 20s | Assembler |
| Titanium Plate | 3x Titanium Ore | 18s | Smelter |
| Reinforced Plate | 2x Steel + 1x Titanium | 25s | Assembler |
| Stabilized Spores | 3x Spore Sac + 1x Glass | 30s | Chemical Lab |
| Lumina Extract | 10x Lumina Moss | 15s | Bio-Processor |
| Synthetic Fiber | 4x Tendril + 2x Cloth | 20s | Assembler |
| Sensor Package | 1x Circuit + 1x Sensor | 22s | Assembler |

### 4.4 Power System (Tier 2)

```
┌───────────────────────────────────────────────────────────┐
│                    POWER GRID (Tier 2)                    │
└───────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ FUEL CELL    │    │ SOLAR ARRAY  │    │ GENERATORS   │
│ REACTOR      │    │ (4x Panels)  │    │  (Multiple)  │
│   50 kW      │    │   40 kW      │    │   75 kW      │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           ▼
                   ┌──────────────┐
                   │ TRANSFORMER  │
                   │  (Balances)  │
                   └──────┬───────┘
                          ▼
              ┌───────────────────────┐
              │    MACHINE NETWORK    │
              │  Assemblers, Labs,    │
              │  Life Support, etc.   │
              └───────────────────────┘
```

**Power Consumption (Tier 2):**
| Machine | Power Draw |
|---------|------------|
| Assembler | 30 kW |
| Refinery | 45 kW |
| Chemical Lab | 40 kW |
| Bio-Processor | 35 kW |
| Fast Conveyor (per 10m) | 5 kW |
| Hydroponic Tray | 15 kW |

---

## 5. Tier 3: Automation

### Unlock Requirements
- **Story:** Complete both Engineering AND Bio-Research sectors
- **Resources:** AI Core Fragments, Superconductors
- **Research:** 20 Tier 2 technologies + ARIA cooperation

### 5.1 Crafting Tree

```
                         ┌───────────────┐
                         │ MANUFACTURER  │
                         │   (Tier 3)    │
                         └───────┬───────┘
          ┌──────────────────────┼──────────────────────┐
          ▼                      ▼                      ▼
   ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
   │  LOGISTICS  │       │    LIFE     │       │   COMBAT    │
   └──────┬──────┘       └──────┬──────┘       └──────┬──────┘
          │                     │                     │
   ┌──────┴──────┐       ┌──────┴──────┐       ┌──────┴──────┐
   │Express      │       │Automated    │       │Kinetic      │
   │Conveyor     │       │Farm         │       │Rifle        │
   ├─────────────┤       ├─────────────┤       ├─────────────┤
   │Logistic     │       │Life Pod     │       │Lumina       │
   │Drone        │       │             │       │Blade        │
   ├─────────────┤       ├─────────────┤       ├─────────────┤
   │Stack        │       │Gravity      │       │Exo-Frame    │
   │Inserter     │       │Plate        │       │             │
   ├─────────────┤       ├─────────────┤       ├─────────────┤
   │Sorting Hub  │       │Neural       │       │Mutation     │
   │             │       │Processor    │       │Stabilizer   │
   ├─────────────┤       ├─────────────┤       ├─────────────┤
   │Request Node │       │ARIA         │       │Combat       │
   │             │       │Companion    │       │Armor        │
   └─────────────┘       └─────────────┘       └─────────────┘
```

### 5.2 Technology Unlocks

| Technology | Prerequisites | Unlock Method | Function |
|------------|---------------|---------------|----------|
| **Manufacturer** | Both sectors + ARIA trust | Story | Complex recipes |
| **AI Module** | Find AI Core Fragment | Discovery | Smart automation |
| **Logistic Drone** | Manufacturer + 500 items transported | Research | Wireless transport |
| **Stack Inserter** | 1000 insertions | Research | Bulk movement |
| **Sorting Hub** | 4 smart splitters built | Research | Multi-route sorting |
| **RTG Unit** | Find Uranium source | Discovery | Long-term power |
| **Automated Farm** | 100 crops harvested | Research | Food automation |
| **Life Pod** | All Tier 2 life support | Research | Complete survival |
| **Gravity Plate** | Engineering mastery | Research | Local gravity |
| **Neural Processor** | 10 Neural Clusters processed | Research | Advanced bio-tech |
| **ARIA Companion** | Max ARIA trust | Story | AI helper |
| **Exo-Frame** | Combat Armor + 50 enemies defeated | Research | Enhanced mobility |

### 5.3 Tier 3 Crafting Recipes

| Output | Input | Time | Station |
|--------|-------|------|---------|
| AI Module | 1x Processing Unit + 1x AI Fragment | 45s | Manufacturer |
| Superconductor | 1x Gold Wire + 1x Platinum Dust | 40s | Manufacturer |
| Purified Lumina | 5x Lumina Extract + 1x Filter | 35s | Lumina Refinery |
| Regenerative Gel | 1x Purified Lumina + 1x Med Supplies | 50s | Manufacturer |
| Neural Compound | 2x Neural Cluster + 1x Lumina Extract | 60s | Neural Processor |
| Logistic Drone | 4x Titanium + 2x AI Module | 90s | Manufacturer |
| RTG Unit | 2x Uranium + 4x Reinforced Plate | 120s | Manufacturer |

### 5.4 Power System (Tier 3)

```
┌───────────────────────────────────────────────────────────────────────┐
│                      AUTOMATED POWER GRID                             │
└───────────────────────────────────────────────────────────────────────┘

┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   RTG UNIT   │    │  FUEL CELL   │    │ SOLAR ARRAY  │
│    75 kW     │    │   ARRAY      │    │  (Enhanced)  │
│  (permanent) │    │   150 kW     │    │    80 kW     │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           ▼
                   ┌──────────────────┐
                   │  POWER CONTROL   │
                   │    AI MODULE     │
                   │ (Auto-balancing) │
                   └────────┬─────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  PRODUCTION  │    │ LIFE SUPPORT │    │   DEFENSE    │
│   MACHINES   │    │   SYSTEMS    │    │   SYSTEMS    │
└──────────────┘    └──────────────┘    └──────────────┘
```

**Power Consumption (Tier 3):**
| Machine | Power Draw |
|---------|------------|
| Manufacturer | 75 kW |
| Neural Processor | 60 kW |
| Lumina Refinery | 55 kW |
| Logistic Drone Hub | 40 kW |
| Gravity Plate | 50 kW |
| Automated Farm | 45 kW |
| Express Conveyor (per 10m) | 10 kW |

### 5.5 Drone Logistics System

```
                    ┌─────────────────┐
                    │  DRONE HUB      │
                    │  (Controller)   │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  REQUEST NODE   │ │  REQUEST NODE   │ │  REQUEST NODE   │
│  (Storage A)    │ │  (Production)   │ │  (Storage B)    │
└─────────────────┘ └─────────────────┘ └─────────────────┘
         ▲                   ▲                   ▲
         │                   │                   │
         └───────────────────┴───────────────────┘
                    DRONE ROUTES
                (Automated delivery)
```

**Drone Specifications:**
| Stat | Value |
|------|-------|
| Carry Capacity | 1 stack (100 items typical) |
| Speed | 10 m/s |
| Range | 200m from hub |
| Power per Drone | 5 kW |
| Drones per Hub | 8 max |

---

## 6. Tier 4: Industrialization

### Unlock Requirements
- **Story:** Enter The Core, learn ARIA's truth
- **Resources:** Quantum Crystals, Dark Matter Residue
- **Research:** 25 Tier 3 technologies + Shepherd defeated

### 6.1 Crafting Tree

```
                         ┌─────────────────┐
                         │ QUANTUM FORGE   │
                         │    (Tier 4)     │
                         └────────┬────────┘
          ┌──────────────────────┼──────────────────────┐
          ▼                      ▼                      ▼
   ┌─────────────┐       ┌─────────────┐       ┌─────────────┐
   │  QUANTUM    │       │   MASTERY   │       │   LEGACY    │
   └──────┬──────┘       └──────┬──────┘       └──────┬──────┘
          │                     │                     │
   ┌──────┴──────┐       ┌──────┴──────┐       ┌──────┴──────┐
   │Quantum      │       │Fusion       │       │Distress     │
   │Conveyor     │       │Reactor      │       │Beacon       │
   ├─────────────┤       ├─────────────┤       ├─────────────┤
   │Teleporter   │       │Quantum      │       │Evidence     │
   │Pad          │       │Storage      │       │Compiler     │
   ├─────────────┤       ├─────────────┤       ├─────────────┤
   │Central      │       │Bio-         │       │ARIA         │
   │Logistics AI │       │Restoration  │       │Core Backup  │
   ├─────────────┤       ├─────────────┤       ├─────────────┤
   │Replication  │       │Quantum      │       │Memory       │
   │Node         │       │Shield       │       │Recreation   │
   ├─────────────┤       ├─────────────┤       ├─────────────┤
   │Particle     │       │Pulse        │       │Station      │
   │Accelerator  │       │Cannon       │       │Control      │
   └─────────────┘       └─────────────┘       └─────────────┘
```

### 6.2 Technology Unlocks

| Technology | Prerequisites | Unlock Method | Function |
|------------|---------------|---------------|----------|
| **Quantum Forge** | Enter Core + ARIA revelation | Story | Exotic crafting |
| **Quantum Alloy** | 5 Quantum Crystals processed | Research | Ultimate material |
| **Quantum Conveyor** | 10,000 items transported | Research | Ultimate belt |
| **Teleporter Pad** | Quantum Forge + Quantum Alloy | Research | Instant transport |
| **Central Logistics AI** | Full drone network | Research | Total automation |
| **Fusion Reactor** | Core reactor examined | Discovery | 500 kW power |
| **Quantum Storage** | 5000 items stored | Research | Massive storage |
| **Replication Node** | Shepherd defeated | Boss | Item duplication |
| **Bio-Restoration Kit** | All medical tech | Research | Full healing |
| **Quantum Shield** | Full combat tech | Research | Ultimate defense |
| **Pulse Cannon** | Quantum Shield built | Research | Ultimate weapon |
| **Station Control** | All endings available | Story | Station master |

### 6.3 Tier 4 Crafting Recipes

| Output | Input | Time | Station |
|--------|-------|------|---------|
| Quantum Alloy | 2x Titanium Plate + 1x Quantum Crystal | 90s | Quantum Forge |
| Quantum Processor | 1x AI Module + 1x Quantum Crystal | 120s | Quantum Forge |
| Dark Matter Core | 3x Dark Matter Residue + 1x Quantum Alloy | 180s | Particle Accelerator |
| Teleporter Pad | 4x Quantum Crystal + 2x AI Module | 150s | Quantum Forge |
| Fusion Reactor | 4x Quantum Alloy + 2x AI Module | 240s | Quantum Forge |
| Replication Matrix | 1x Quantum Processor + 1x Shepherd Fragment | 300s | Particle Accelerator |
| Station Control Key | All evidence + ARIA blessing | Story | N/A |

### 6.4 Power System (Tier 4)

```
┌───────────────────────────────────────────────────────────────────────┐
│                     QUANTUM POWER NETWORK                             │
└───────────────────────────────────────────────────────────────────────┘

                    ┌─────────────────────┐
                    │   FUSION REACTOR    │
                    │      500 kW         │
                    │   (Near-infinite)   │
                    └──────────┬──────────┘
                               │
                    ┌──────────┴──────────┐
                    │  QUANTUM GRID       │
                    │  (Lossless power)   │
                    └──────────┬──────────┘
                               │
    ┌──────────────────────────┼──────────────────────────┐
    ▼                          ▼                          ▼
┌──────────┐           ┌──────────────┐           ┌──────────┐
│ QUANTUM  │           │   CENTRAL    │           │ DEFENSE  │
│ FORGES   │           │ LOGISTICS AI │           │ GRID     │
│ & LABS   │           │              │           │          │
└──────────┘           └──────────────┘           └──────────┘

TOTAL CAPACITY: 500 kW base + RTGs + Solar = ~700 kW
ALL AUTOMATION: ~300 kW consumption
SURPLUS: Player comfort & expansion
```

### 6.5 Teleporter Network

```
                    ┌─────────────────────┐
                    │  CENTRAL TELEPORTER │
                    │       (HUB)         │
                    └──────────┬──────────┘
                               │
     ┌─────────────┬───────────┼───────────┬─────────────┐
     ▼             ▼           ▼           ▼             ▼
┌─────────┐  ┌─────────┐ ┌─────────┐ ┌─────────┐  ┌─────────┐
│ENGINEER │  │   BIO   │ │  CORE   │ │ PLAYER  │  │ CUSTOM  │
│ SECTOR  │  │RESEARCH │ │         │ │  BASE   │  │  NODES  │
└─────────┘  └─────────┘ └─────────┘ └─────────┘  └─────────┘
```

**Teleporter Specifications:**
| Stat | Value |
|------|-------|
| Transfer Rate | Instant (items) |
| Player Teleport | 5 second charge |
| Power Cost | 50 kW per use |
| Range | Station-wide |
| Nodes Supported | Unlimited |

---

## 7. Research System

### 7.1 Research Point Types

| Type | Source | Used For |
|------|--------|----------|
| **Engineering** | Crafting machines, fixing systems | Automation tech |
| **Biology** | Harvesting aliens, processing samples | Bio-tech |
| **Discovery** | Exploring new areas, finding logs | Unlocking sectors |
| **Combat** | Defeating enemies | Weapons/armor |
| **ARIA Trust** | Story choices, helping ARIA | Advanced AI tech |

### 7.2 Research Unlock Requirements

| Tier | Eng Points | Bio Points | Discovery | Combat | ARIA |
|------|------------|------------|-----------|--------|------|
| 1 | 0 | 0 | 0 | 0 | 0 |
| 2 | 100 | 50 | 25 | 25 | 10 |
| 3 | 300 | 200 | 100 | 100 | 50 |
| 4 | 600 | 400 | 200 | 200 | 100 |

### 7.3 Research Tree Visualization

```
TIER 1 ─────────────────────────────────────────────────────────────────
│
├── Workbench (start)
├── Smelter (10 Eng)
├── Food Processor (10 Bio)
├── O2 Generator (Story)
├── Water Recycler (Story)
├── Basic Conveyor (20 Eng)
├── Battery Bank (15 Eng)
└── Solar Panel (15 Discovery)

TIER 2 ─────────────────────────────────────────────────────────────────
│
├── Assembler (Story + 50 Eng)
├── Fast Conveyor (75 Eng)
├── Smart Splitter (100 Eng)
├── Refinery (80 Eng)
├── Chemical Lab (60 Bio)
├── Hydroponic Tray (40 Bio)
├── Bio-Processor (70 Bio)
├── Scanner (50 Discovery)
├── Engineering Suit (Story)
└── Fuel Cell Reactor (100 Discovery)

TIER 3 ─────────────────────────────────────────────────────────────────
│
├── Manufacturer (Story + 200 Eng)
├── AI Module (150 Eng + 30 ARIA)
├── Logistic Drone (250 Eng)
├── Stack Inserter (200 Eng)
├── RTG Unit (200 Discovery)
├── Automated Farm (150 Bio)
├── Neural Processor (200 Bio)
├── Gravity Plate (300 Eng)
├── ARIA Companion (100 ARIA)
└── Combat Armor (150 Combat)

TIER 4 ─────────────────────────────────────────────────────────────────
│
├── Quantum Forge (Story + 400 Eng)
├── Quantum Alloy (500 Eng)
├── Quantum Conveyor (600 Eng)
├── Teleporter Pad (400 Eng + 100 Discovery)
├── Central Logistics AI (500 Eng + 80 ARIA)
├── Fusion Reactor (400 Discovery)
├── Replication Node (Boss + 300 Bio)
├── Quantum Shield (200 Combat + 300 Eng)
└── Station Control (Story)
```

---

## 8. Progression Milestones

### 8.1 Player Journey Checkpoints

| Hour | Milestone | Tech Unlocked | Player Feeling |
|------|-----------|---------------|----------------|
| 2 | First system fixed | O2 Generator | Relief |
| 4 | Base established | Water Recycler | Security |
| 6 | First automation | Basic Conveyor | Hope |
| 8 | Self-sustaining | Smelter automation | Pride |
| 12 | New sector opened | Assembler | Excitement |
| 16 | Smart factory | Smart Splitter | Satisfaction |
| 20 | ARIA cooperation | AI Module | Connection |
| 24 | Full automation | Logistic Drone | Mastery |
| 28 | Core access | Manufacturer | Anticipation |
| 32 | Truth revealed | Quantum Forge | Complex emotions |
| 36 | Choice time | All Tier 4 | Agency |
| 40 | Ending | Station Control | Catharsis |

### 8.2 Factory Evolution Examples

**Hour 2: Survival Setup**
```
[Manual Mining] → [Workbench] → [Survival items]
```

**Hour 8: First Automation**
```
[Mining Drill] → [Conveyor] → [Smelter] → [Storage]
```

**Hour 16: Intermediate Factory**
```
[Mining] → [Smelter] ─┬→ [Assembler A] → [Components]
                      └→ [Assembler B] → [Building Materials]
```

**Hour 24: Advanced Network**
```
┌─[Mining A]─┐     ┌─[Assembler A]─┐     ┌─[Manufacturer]─┐
│            │     │               │     │                │
│ [Mining B]─┼─────┼─[Assembler B]─┼─────┼─[AI Processing]│
│            │     │               │     │                │
└─[Mining C]─┘     └─[Assembler C]─┘     └─[Final Output]─┘
     │                    │                      │
     └────────────────────┴──────────────────────┘
                    [Sorting Hub]
                    [Drone Network]
```

**Hour 36: Endgame Megastructure**
```
         ┌────────────[CENTRAL LOGISTICS AI]────────────┐
         │                                              │
    ┌────┴────┐    ┌─────────┐    ┌─────────┐    ┌─────┴────┐
    │TELEPORT │    │ QUANTUM │    │ FUSION  │    │ TELEPORT │
    │  HUB    │    │  FORGE  │    │ REACTOR │    │  HUB B   │
    └────┬────┘    └────┬────┘    └────┬────┘    └────┬─────┘
         │              │              │              │
    ┌────┴────┐    ┌────┴────┐    ┌────┴────┐    ┌────┴─────┐
    │REPLICATE│    │ QUANTUM │    │PARTICLE │    │ QUANTUM  │
    │  NODE   │    │ STORAGE │    │  ACCEL  │    │ STORAGE  │
    └─────────┘    └─────────┘    └─────────┘    └──────────┘
```

---

## 9. Special Technologies

### 9.1 ARIA-Linked Technologies

| Technology | ARIA Trust Required | Special Function |
|------------|---------------------|------------------|
| AI Module | 30 | Basic automation |
| ARIA Companion | 100 | Personal AI assistant |
| Central Logistics AI | 80 | Station-wide automation |
| Memory Recreation | 100 | Story scenes playback |
| Station Control | Max | Control station fate |

### 9.2 Boss-Locked Technologies

| Technology | Boss Required | Special Function |
|------------|---------------|------------------|
| Replication Node | The Shepherd | Duplicate items |
| Dark Matter Core | The Shepherd | Ultimate power source |
| Overgrowth Control | The Shepherd | Tame alien flora |

### 9.3 Story-Locked Technologies

| Technology | Story Trigger | Function |
|------------|---------------|----------|
| Distress Beacon | Core access | Call for rescue |
| Evidence Compiler | Truth discovered | Organize proof |
| Station Override | Captain's code | Control all systems |

---

## 10. Balance Notes

### 10.1 Automation Efficiency Curve

| Tier | Manual Efficiency | Automated Efficiency | Net Gain |
|------|-------------------|---------------------|----------|
| 1 | 100% | 120% | +20% |
| 2 | 60% | 200% | +140% |
| 3 | 30% | 400% | +370% |
| 4 | 10% | 1000% | +990% |

**Design Intent:** Each tier makes manual labor less viable, pushing automation.

### 10.2 Resource Progression

| Hour | Primary Resources | Scarcity Level |
|------|-------------------|----------------|
| 0-4 | Scrap, Basic Ore | High (survival pressure) |
| 4-8 | Iron, Copper | Medium (push automation) |
| 8-16 | Titanium, Silicon | Medium (reward exploration) |
| 16-28 | AI Fragments, Uranium | Low (focus on building) |
| 28-40 | Quantum, Dark Matter | Very Low (goal is story) |

### 10.3 Power Scaling

| Tier | Total Generation | Total Consumption | Margin |
|------|------------------|-------------------|--------|
| 1 | 35 kW | 50 kW | -15 kW (battery drain) |
| 2 | 165 kW | 150 kW | +15 kW (stable) |
| 3 | 305 kW | 250 kW | +55 kW (comfortable) |
| 4 | 700 kW | 400 kW | +300 kW (abundant) |

---

[← Previous: Items Database](items-database.md) | [Back to Index](../../README.md) | [Next: Creatures & Flora →](creatures-flora.md)
