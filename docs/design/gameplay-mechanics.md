# Gameplay Mechanics

## The "Green Star Valley" System

The core design is a feedback loop where survival pressure drives the need for automation, and automation enables the "cozy" experience.

---

## 4.1 Biological Survival: The Body as Factory

Inspired by Green Hell, the player's body is a complex system, not just a health bar.

### Spatial Inspection System

Instead of examining limbs for leeches, the player inspects their EVA Suit and Biomonitor.

| Condition | Cause | Manual Solution | Automated Solution |
|-----------|-------|-----------------|-------------------|
| Micro-fractures | Combat, debris | Duct tape sealing | Repair drones |
| Muscle Atrophy | Low gravity | Exercise, protein supplements | Automated gym systems |
| Radiation | Dangerous zones | Decontamination showers | Shielded corridors |
| Parasites | Alien flora/fauna | Surgical removal | Bio-scanner + auto-medication |

### Alien Macro-Nutrients

| Nutrient | Sources | Effect |
|----------|---------|--------|
| Proteins | Xeno-fauna meat, processed insects | Muscle maintenance, healing |
| Carbohydrates | Hydroponic crops | Energy, stamina |
| Lipids | Machinery oils, fatty plants | Brain function, insulation |
| Hydration | Water recycling system | All biological functions |

**Water Quality System:**
- Recycled water (from urine): Maintains life but lowers "Sanity"
- Purified water: Raises morale

### Water Quality Tiers

| Tier | Source | Hydration | Sanity Effect | Sickness Risk |
|------|--------|-----------|---------------|---------------|
| Contaminated | Stagnant pools, leaks | 60% | -5/drink | 30% |
| Recycled | Basic water recycler | 80% | -2/drink | 5% |
| Filtered | Advanced recycler | 100% | 0 | 0% |
| Purified | Distillation system | 100% | +2/drink | 0% |
| Enhanced | Lumina-infused water | 120% | +5/drink | 0%* |

*Enhanced water may cause minor Lumina exposure over time.

**Water Infrastructure:**
- Each tier requires specific buildings/upgrades
- Water quality affects crop growth rates
- Contaminated water can spread disease to entire base if piped

---

## 4.1.1 Death & Respawn System

### Death Mechanics

| Cause of Death | Prevention | Respawn Penalty |
|----------------|------------|-----------------|
| Asphyxiation (O2) | Maintain atmosphere, carry tanks | Minor - body recoverable |
| Starvation | Food automation | Minor - resources lost |
| Radiation | Shielding, decontamination | Moderate - some items destroyed |
| Combat (Creatures) | Weapons, avoidance | Major - body may be in danger zone |
| Falling (Gravity) | Caution, jet pack | Minor - equipment damage |
| Environmental | Suit upgrades, awareness | Varies by cause |

### Respawn Locations

**Checkpoint System:**
- Player respawns at last activated **Restoration Pod**
- First pod is in starting Hub area
- Additional pods found/repaired throughout station
- Pods must be powered to function

**Restoration Pod Mechanics:**
```
┌──────────────────────────────────────┐
│          RESTORATION POD             │
├──────────────────────────────────────┤
│ Function: Emergency clone/restore    │
│ Power: 50kW continuous               │
│ Activation: Interact + DNA sample    │
│ Cooldown: 5 minutes between uses     │
└──────────────────────────────────────┘
```

### Death Consequences

| Difficulty | Body Recovery | Item Loss | Progress Loss |
|------------|---------------|-----------|---------------|
| Story Mode | Teleported to pod | None | None |
| Normal | At death location | 25% inventory | Quest items safe |
| Survival | At death location | 50% inventory | Some crafted items |
| Hardcore | Permanent death | All | Save deleted |

### Body Recovery

- Death location marked on map for 30 real-time minutes
- Body contains dropped inventory (percentage varies by difficulty)
- Some items may be damaged/destroyed based on death cause
- Hostile creatures may guard/consume body
- Another player can recover your items in multiplayer

### Death Prevention Alerts

ARIA provides warnings before critical failures:
- "Oxygen critical. Seek atmosphere immediately."
- "Radiation exposure exceeding safe limits."
- "Biological contamination detected. Find decontamination."
- "Hostile lifeform detected. Exercise caution."

---

## 4.1.2 Inventory System

### Inventory Structure

```
┌─────────────────────────────────────────────────────────────┐
│                      INVENTORY                               │
├─────────────────────────────────────────────────────────────┤
│  HOTBAR (8 slots)                                           │
│  ┌───┬───┬───┬───┬───┬───┬───┬───┐                         │
│  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │ 8 │  Quick access items     │
│  └───┴───┴───┴───┴───┴───┴───┴───┘                         │
│                                                              │
│  MAIN INVENTORY (30 slots)                                  │
│  ┌───┬───┬───┬───┬───┬───┐                                  │
│  │   │   │   │   │   │   │  6 columns x 5 rows              │
│  ├───┼───┼───┼───┼───┼───┤                                  │
│  │   │   │   │   │   │   │                                  │
│  ├───┼───┼───┼───┼───┼───┤                                  │
│  │   │   │   │   │   │   │                                  │
│  ├───┼───┼───┼───┼───┼───┤                                  │
│  │   │   │   │   │   │   │                                  │
│  ├───┼───┼───┼───┼───┼───┤                                  │
│  │   │   │   │   │   │   │                                  │
│  └───┴───┴───┴───┴───┴───┘                                  │
│                                                              │
│  EQUIPMENT (6 slots)                                        │
│  ┌─────────┬─────────┬─────────┐                            │
│  │  HEAD   │  CHEST  │  LEGS   │                            │
│  ├─────────┼─────────┼─────────┤                            │
│  │  TOOL   │ UTILITY │ BACKPCK │                            │
│  └─────────┴─────────┴─────────┘                            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Inventory Slots Breakdown

| Category | Slots | Purpose |
|----------|-------|---------|
| Hotbar | 8 | Quick-switch items (1-8 keys) |
| Main | 30 | General storage |
| Equipment | 6 | Worn/equipped items |
| **Total** | **44** | Base carrying capacity |

### Equipment Slots

| Slot | Items | Effects |
|------|-------|---------|
| Head | Helmets, visors, respirators | Vision, O2, protection |
| Chest | Suits, armor, vests | Protection, storage |
| Legs | Pants, boots, exo-legs | Speed, jump, protection |
| Tool | Primary tool/weapon | Active use item |
| Utility | Secondary gadget | Scanner, light, grapple |
| Backpack | Storage upgrade | +10/20/30 slots |

### Backpack Upgrades

| Tier | Name | Extra Slots | Found In |
|------|------|-------------|----------|
| 1 | Maintenance Satchel | +10 | Starting area |
| 2 | Engineering Pack | +20 | Engineering sector |
| 3 | Explorer's Rig | +30 | Deep exploration |
| 4 | Industrial Harness | +40 | Late game crafting |

### Stack Sizes

| Item Type | Stack Size | Examples |
|-----------|------------|----------|
| Raw Materials | 100 | Metal ore, biomass, ice |
| Processed Materials | 50 | Metal plates, circuits |
| Components | 25 | Gears, pipes, wires |
| Consumables | 20 | Food, medicine, filters |
| Tools | 1 | Non-stackable |
| Equipment | 1 | Non-stackable |

### Quick Transfer Controls

| Action | Key | Function |
|--------|-----|----------|
| Quick transfer | Shift+Click | Move to/from container |
| Split stack | Ctrl+Click | Split stack in half |
| Transfer all | Shift+T | Move all matching items |
| Sort | R | Auto-organize inventory |
| Quick equip | Double-click | Equip/use item |

---

## 4.2 Automation: From Survival to Industry

Automation is not optional; it's the only way to scale survival for 40+ hours.

### Tier 1: Manual - The Struggle

| Activity | Experience |
|----------|------------|
| Ice mining | Manual pickaxe work |
| CO2 filter crafting | Workbench assembly |
| Resource gathering | High tension, personal risk |

**Design Goal:** Create genuine relief when automation arrives.

### Tier 2: Mechanization - The Relief

| System | Benefit | Trade-off |
|--------|---------|-----------|
| Atmospheric Extractor | No manual filter crafting | Requires biomass energy |
| Water Recycler | Automatic hydration | Lower water quality |
| Basic Conveyor | Reduced manual transport | Power consumption |

**Milestone:** Player can leave base briefly without immediate death.

### Tier 3: Automation - The Dominion

| System | Description |
|--------|-------------|
| Biomass Conveyors | Automatic fuel delivery to generators |
| Pipe Networks | Water distribution to crops |
| Auto-farms | Reduced player attention required |

**Freedom:** Player can explore far from base; basic needs covered automatically.

### Tier 4: Industrialization - The Scale

| Purpose | Systems |
|---------|---------|
| Ship repair | Massive production lines |
| Space elevator | Logistics networks |
| Station restoration | Multi-sector coordination |

**Endgame:** Satisfactory-scale complexity with survival stakes.

---

## 4.3 Cozy Elements: The Sanctuary in the Void

To integrate Stardew Valley, the base must be a home, not just a factory.

### Xenobotany

| Aspect | Implementation |
|--------|----------------|
| Depth | Plants have cycles, specific light requirements |
| Beauty | Bioluminescent greenhouse as visual refuge |
| Function | Alien crops provide medical compounds |

**Visual Design:** A bioluminescent greenhouse in the darkness of space serves as emotional and visual refuge.

### Functional Decoration

| Item | Mechanical Benefit |
|------|-------------------|
| Quality Bed | Faster "Energy" recovery |
| Carpet | Noise reduction (stress reduction) |
| Plants | Air quality improvement |
| Lighting | Sanity preservation |

### Passive Social Interaction (Multiplayer)

| Feature | Description |
|---------|-------------|
| Automated Trading | Specialization between players |
| Community Fridge | Conveyor-accessible from kitchen to quarters |
| Shared Projects | Multi-player base construction |

---

## 4.4 Core Game Loop

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   SURVIVAL PRESSURE                                     │
│   (Hunger, Oxygen, Sanity, Radiation)                   │
│            │                                            │
│            ▼                                            │
│   MANUAL GATHERING                                      │
│   (High tension, limited resources)                     │
│            │                                            │
│            ▼                                            │
│   FIRST AUTOMATION                                      │
│   (Relief moment - machine sounds = safety)             │
│            │                                            │
│            ▼                                            │
│   EXPANDED CAPACITY                                     │
│   (Time for exploration, decoration, farming)           │
│            │                                            │
│            ▼                                            │
│   NEW CHALLENGES                                        │
│   (Deeper zones, higher stakes, larger projects)        │
│            │                                            │
│            └────────────────────────────────────────────┘
│                        (Loop continues)
└─────────────────────────────────────────────────────────┘
```

---

## 4.5 Sanity System

A unique mechanic connecting survival and cozy elements.

| Factor | Effect on Sanity |
|--------|------------------|
| Isolation | Gradual decline |
| Base comfort | Recovery rate |
| Death of crew (found bodies) | Significant trauma |
| Drinking recycled water | Minor decline |
| Beautiful decorations | Recovery |
| Successful automation | Boost |

**Sanity Thresholds:**
- 75-100%: Normal function
- 50-74%: Minor hallucinations, reduced efficiency
- 25-49%: Major hallucinations, task errors
- 0-24%: Critical - involuntary actions, possible death

---

## 4.6 Progression Hooks

| Hook | Purpose |
|------|---------|
| Technology Trees | Unlock automation tiers |
| Biological Research | Discover new crops, medicines |
| Station Restoration | Unlock new sectors |
| Lore Discovery | Uncover station history |
| Base Beautification | Cozy progression |

---

[← Previous: Market Analysis](market-analysis.md) | [Back to Index](../../README.md) | [Next: Level Design →](level-design.md)
