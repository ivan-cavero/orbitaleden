# Level Design

## The Spatial Metroidvania

Based on the success of Abiotic Factor, the world should not be an infinite procedural plane, but a hand-designed interconnected mega-structure (with AI assistance for detail).

---

## 5.1 Station Structure: "Eden" Station

The map is a ruined space station or colony ship, divided into thematic Sectors interconnected by a transit system (trains or vacuum tubes) that the player must repair.

### The Hub (Residential Sector)

| Aspect | Description |
|--------|-------------|
| Role | Starting point, safe zone |
| Resources | Limited basic supplies |
| Atmosphere | Intact but empty, echoes of past life |
| Purpose | Establish the "cozy" base |

**Key Locations:**
- Crew quarters (potential player housing)
- Mess hall (cooking/crafting hub)
- Medical bay (basic healing)
- Control center (story progression)

### Engineering Sector (Industrial)

| Aspect | Description |
|--------|-------------|
| Atmosphere | Dark corridors, broken pipes, high temperature |
| Resources | Rich in metals and machinery diagrams |
| Hazards | Steam vents, electrical hazards, structural collapse |
| Purpose | Automation technology acquisition |

**Key Locations:**
- Reactor rooms
- Manufacturing bays
- Conveyor system remnants
- Power distribution centers

### Bio-Research Sector (The Jungle)

| Aspect | Description |
|--------|-------------|
| Atmosphere | Experimental flora has taken over |
| Resources | Unique food and medicine sources |
| Hazards | Aggressive flora, toxic spores, alien fauna |
| Style | "Green Hell in space" |

**Key Locations:**
- Containment cells (breached)
- Hydroponics bays
- Specimen storage
- Research laboratories

### The Core (High Level)

| Aspect | Description |
|--------|-------------|
| Atmosphere | High radiation, robotic security |
| Resources | Advanced technology, story conclusions |
| Hazards | AI defenses, environmental extremes |
| Purpose | Endgame challenges and resolution |

**Key Locations:**
- AI core room
- Bridge/command center
- Escape vehicle bay
| Station archives |

---

## 5.2 Progression & Gating

Progression is based not just on keys, but on survival capabilities (Metroidvania Design).

### Environmental Gating

| Obstacle | Required Capability |
|----------|---------------------|
| Neurotoxic gas corridor | Advanced suit filters (automated production) |
| Radiation zone | Shielded suit components |
| Vacuum breach | EVA suit upgrade |
| Extreme cold | Thermal regulation system |

**Design Philosophy:** "This corridor is filled with neurotoxic gas." The player doesn't need a blue key; they need to research and automate production of advanced air filters for their suit.

### Power Gating

| Obstacle | Requirement |
|----------|-------------|
| Sector 3 door | 200kW power + Power Routing Component |
| Transit system | Multi-sector power distribution |
| Life support | Continuous power supply |

**Design Goal:** Force optimization of factory to generate surplus energy.

### Shortcut System

Similar to Dark Souls or Abiotic Factor, deep exploration unlocks:
- Elevators connecting advanced zones to initial Hub
- Maintenance tunnels for faster travel
- Emergency airlocks for logistics shortcuts

---

## 5.3 Environmental Narrative (Lore)

The 40-hour story is told through "Archaeology of the Immediate Present."

### Rupture Events

Inspired by Star Rupture, the station suffers cyclical events:

| Event | Hazard | Narrative Revelation |
|-------|--------|---------------------|
| Solar storms | Radiation spikes | Communications log reveals evacuation attempt |
| Gravity failures | Movement chaos | Hidden areas become accessible |
| Power surges | System malfunctions | Sealed doors open temporarily |
| Hull breaches | Vacuum exposure | New areas revealed |

### The Central AI

An emergent narrative where the station's AI (antagonist or ally) reacts to player automation:

| Player Action | AI Response |
|--------------|-------------|
| Reactor repair | "I see you've repaired the reactor. Proceeding to unfreeze defenses." |
| Sector connection | "New territory connected. Scanning for biological contaminants." |
| Automation expansion | "Your efficiency is... noted. Revisiting threat assessment." |

---

## 5.4 Sector Interconnection Map

```
                    ┌─────────────┐
                    │   THE CORE  │
                    │  (Endgame)  │
                    └──────┬──────┘
                           │
                    [Power Gate: 200kW + Component]
                           │
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────┴──────┐ ┌──────┴──────┐ ┌──────┴──────┐
    │ ENGINEERING │ │  BIO-RESEARCH│ │   TRANSIT   │
    │   SECTOR    │ │    SECTOR    │ │    HUB      │
    └──────┬──────┘ └──────┬──────┘ └──────┬──────┘
           │               │               │
    [Filter Gate]   [Suit Upgrade]        │
           │               │               │
           └───────────────┼───────────────┘
                           │
                    ┌──────┴──────┐
                    │    THE HUB  │
                    │  (Starting) │
                    └─────────────┘
```

---

## 5.5 Room Templates

### Industrial Rooms

| Type | Purpose | Automation Potential |
|------|---------|---------------------|
| Generator Room | Power production | Fuel automation |
| Manufacturing Bay | Item production | Assembly lines |
| Storage Depot | Resource holding | Sorting systems |
| Maintenance Tunnel | Transit/logistics | Conveyor routes |

### Biological Rooms

| Type | Purpose | Hazards |
|------|---------|---------|
| Greenhouse | Crop cultivation | Spore outbreaks |
| Specimen Lab | Research | Escaped experiments |
| Medical Bay | Healing | Contamination |
| Hydroponics | Water/food | System failures |

### Residential Rooms

| Type | Purpose | Cozy Potential |
|------|---------|----------------|
| Quarters | Player housing | Full decoration |
| Mess Hall | Cooking/serving | Community space |
| Recreation | Sanity recovery | Game tables, screens |
| Observation | View, calm | Window to space |

---

## 5.6 Verticality & 3D Navigation

| Element | Gameplay Purpose |
|---------|-----------------|
| Ladders | Quick vertical access |
| Elevators | Heavy transport, shortcut unlocks |
| Vents | Stealth, alternate routes |
| Catwalks | Overlook, conveyor routing |
| Cranes | Heavy object movement |

---

## 5.7 Biome-Specific Mechanics

| Sector | Unique Mechanic |
|--------|----------------|
| Hub | Sanity recovery bonus |
| Engineering | Heat management (cooling systems) |
| Bio-Research | Spore infection (requires decontamination) |
| Core | Radiation accumulation (shielding required) |

---

[← Previous: Gameplay Mechanics](gameplay-mechanics.md) | [Back to Index](../../README.md) | [Next: Technical Architecture →](../technical/architecture.md)
