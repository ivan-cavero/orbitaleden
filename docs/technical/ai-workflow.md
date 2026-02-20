# AI Asset Workflow

## Overview

This document provides style guides and prompts for maintaining visual and narrative consistency across all AI-generated content in Orbital Eden.

---

## 1. Visual Style Bible

### 1.1 Core Aesthetic Pillars

**Orbital Eden's visual identity blends three distinct aesthetics:**

| Pillar | Reference | Application |
|--------|-----------|-------------|
| 90s Industrial Sci-Fi | Alien, Dead Space, Event Horizon | Station architecture, machinery, corridors |
| Bioluminescent Alien | Avatar, Annihilation, Subnautica | Flora, infected areas, Lumina effects |
| Cozy Sanctuary | Stardew Valley, Firewatch | Player base, farming areas, lighting |

### 1.2 Master Color Palette

```
PRIMARY PALETTE:
├── Station Metal Gray      #3D4550  (base hull color)
├── Industrial Orange       #D4762C  (warning signs, hazard markings)
├── Emergency Red           #B33A3A  (alerts, danger zones)
├── Terminal Green          #4ADE80  (functional systems, healthy plants)
└── Ambient Blue            #1E3A5F  (corridors, general lighting)

ALIEN/LUMINA PALETTE:
├── Bioluminescent Cyan     #00FFD4  (Lumina glow, alien flora)
├── Deep Violet             #6B21A8  (infected areas, corruption)
├── Ethereal Pink           #FF6B9D  (rare Lumina variants)
├── Organic Green           #22C55E  (healthy alien vegetation)
└── Spore Yellow            #FBBF24  (Specimen Zero influence)

ATMOSPHERE:
├── Shadow Black            #0F1419  (deep shadows, vents)
├── Fog Blue                #1E293B  (atmospheric haze)
└── Light Bloom             #FEF3C7  (warm sanctuary lighting)
```

### 1.3 Mood Progression

| Game Phase | Dominant Colors | Lighting | Atmosphere |
|------------|-----------------|----------|------------|
| Early (Survival) | Grays, Emergency Red, Shadow | Harsh, flickering | Tense, isolated |
| Mid (Discovery) | Blues, Cyans, Violets | Mixed, bioluminescent | Mysterious, wonder |
| Late (Mastery) | Warm ambers, Greens, Soft white | Warm, stable | Cozy, hopeful |

---

## 2. Art Style Reference

### 2.1 Station Architecture Style

**Keywords for ALL station-related prompts:**
```
industrial sci-fi, 1990s retro-futurism, heavy machinery, 
exposed pipes and conduits, modular construction, 
weathered metal surfaces, utilitarian design, 
hazard striping, corporate signage, emergency lighting,
riveted panels, grated floors, bulkhead doors,
steam vents, cable management, industrial catwalks
```

**Visual References:**
- Nostromo (Alien, 1979)
- Ishimura (Dead Space)
- Sevastopol Station (Alien: Isolation)
- Talos I (Prey 2017)

### 2.2 Alien Flora Style

**Keywords for ALL alien vegetation prompts:**
```
bioluminescent, alien vegetation, organic curves,
translucent membranes, glowing veins, ethereal,
otherworldly, phosphorescent, bio-organic,
flowing tendrils, spore pods, luminescent fungi,
crystalline structures, pulsing light, living geometry
```

**Visual References:**
- Pandora Flora (Avatar)
- The Shimmer (Annihilation)
- Alien Containment (Subnautica)
- Blackreach (Skyrim)

### 2.3 Character Design Style

**Keywords for characters:**
```
realistic proportions, space station crew,
utilitarian clothing, worn equipment,
practical accessories, visible tool belts,
environmental suits, layered clothing,
badges and ID cards, personal touches,
weathered appearance, working class aesthetic
```

---

## 3. 3D Model Prompts

### 3.1 Tool Selection Guide

| Tool | Best For | Avoid For |
|------|----------|-----------|
| Meshy | Hard-surface industrial props | Organic shapes |
| Rodin Gen-1 | Complex machinery | Simple objects |
| Tripo3D | Alien flora, organic | Mechanical precision |
| CSM | Rock formations, terrain | Manufactured items |

### 3.2 Station Architecture Prompts

**Corridor Sections:**
```
PROMPT: Industrial sci-fi corridor segment, modular design,
exposed ceiling pipes and cables, grated metal floor,
wall-mounted junction boxes, emergency lighting strips,
1990s retro-futuristic aesthetic, weathered metal surfaces,
Alien movie inspired, game-ready 3D model

NEGATIVE: cartoon, stylized, clean, pristine, futuristic chrome,
smooth surfaces, minimalist
```

**Bulkhead Doors:**
```
PROMPT: Heavy industrial bulkhead door, sci-fi space station,
hydraulic mechanisms visible, warning striping yellow/black,
control panel beside frame, thick reinforced frame,
Dead Space aesthetic, circular or hexagonal shape,
pressure seals visible, game asset

NEGATIVE: sliding glass, automatic modern, clean futuristic
```

**Machinery - Life Support:**
```
PROMPT: Industrial life support unit, space station equipment,
large cylindrical tanks, exposed pipes and valves,
control gauges and dials, warning labels,
heavy duty construction, ceiling-mounted variant,
1990s sci-fi movie prop style, weathered paint

NEGATIVE: sleek, minimalist, Apple aesthetic, smooth
```

### 3.3 Alien Flora Prompts

**Lumina Flowers:**
```
PROMPT: Bioluminescent alien flower, glowing cyan petals,
translucent membrane texture, organic flowing shape,
ethereal glow emanating from center, curved stem,
Avatar Pandora inspired, game asset 3D model,
fantasy vegetation, otherworldly beauty

NEGATIVE: Earth flower, realistic rose, daisy, sunflower,
normal plant, non-glowing
```

**Alien Trees:**
```
PROMPT: Alien tree with bioluminescent bark, twisted organic form,
glowing veins running through trunk, luminescent leaves,
otherworldly vegetation, purple and cyan color scheme,
Subnautica flora inspired, medium height game asset,
fantasy alien forest, crystalline elements

NEGATIVE: oak tree, pine tree, palm tree, Earth vegetation,
realistic forest, non-glowing
```

**Infected Vegetation (Specimen Zero Influence):**
```
PROMPT: Corrupted alien plant, infected bioluminescent flora,
sickly yellow-green glow, organic pustules and growths,
spreading tendrils, spore pods attached,
body horror plant, Annihilation shimmer inspired,
disturbing organic growth, game asset

NEGATIVE: healthy plant, beautiful flower, pretty, peaceful
```

### 3.4 Props and Items

**Hand Tools:**
```
PROMPT: Futuristic repair tool, industrial hand tool,
heavy duty construction, ergonomic grip,
multiple function heads, battery pack visible,
space mechanic equipment, worn metal finish,
sci-fi wrench or multitool, game item asset

NEGATIVE: modern power tool, brand name, clean new
```

**Containers and Crates:**
```
PROMPT: Industrial cargo container, space station supply crate,
reinforced corners, stacking ridges, warning labels,
corporate logo space (Helios), heavy latches,
weathered metal or plastic, modular design,
sci-fi storage container, game prop

NEGATIVE: cardboard box, wooden crate, modern shipping container
```

**Data Terminals:**
```
PROMPT: Retro-futuristic computer terminal, CRT-style monitor,
thick keyboard with heavy keys, wall-mounted variant,
green or amber monochrome display, exposed wiring,
1990s sci-fi aesthetic, space station equipment,
Alien movie computer style, game prop

NEGATIVE: modern laptop, tablet, touchscreen, Apple, sleek
```

---

## 4. Texture and Material Prompts

### 4.1 PBR Material Generation

**Base Metal - Hull Plating:**
```
PROMPT: Seamless tileable texture, industrial metal hull plating,
scratched and weathered surface, subtle rivets pattern,
grey steel with orange rust spots, sci-fi paneling,
PBR material, 2048x2048, photorealistic

Generate maps: Albedo, Normal, Roughness, Metallic, AO
```

**Grated Floor:**
```
PROMPT: Seamless tileable texture, industrial metal grating,
diamond pattern anti-slip surface, heavy duty construction,
worn paint in walkway areas, sci-fi floor material,
dark metal with edge wear, PBR ready

Generate maps: Albedo, Normal, Roughness, Metallic, Height
```

**Organic Alien Surface:**
```
PROMPT: Seamless tileable texture, alien organic surface,
bioluminescent veins pattern, translucent membrane areas,
purple and cyan color scheme, otherworldly biology,
living tissue appearance, PBR material

Generate maps: Albedo, Normal, Roughness, Subsurface, Emission
```

### 4.2 Decal Textures

**Warning Signs:**
```
PROMPT: Industrial warning sign decal, "DANGER HIGH VOLTAGE",
yellow and black color scheme, weathered and scratched,
space station safety signage, retro-futuristic font,
transparent background PNG, game decal asset

Variants needed:
- BIOHAZARD
- RADIATION
- NO ENTRY
- EMERGENCY EXIT
- OXYGEN LOW
- PRESSURE DOOR
```

**Corporate Branding:**
```
PROMPT: Helios Corporation logo decal, corporate sci-fi branding,
sun/helix hybrid symbol, gold on dark background,
weathered and partially scraped off, space station signage,
1990s corporate aesthetic, PNG transparent background

Variants:
- Clean version (for flashback sequences)
- Vandalized version (post-breach areas)
- Faded version (abandoned sections)
```

---

## 5. Audio Generation

### 5.1 Voice Profiles (ElevenLabs)

**ARIA (Station AI):**
```
Voice Settings:
- Stability: 0.75 (consistent, mechanical)
- Clarity: 0.85 (clear enunciation)
- Style: 0.20 (minimal emotion)

Character Direction:
"Calm, professional female voice. Slight artificial quality.
Speaks in measured, precise sentences. Hints of suppressed
emotion when discussing the crew. Becomes warmer over time."

Sample Line: "Good morning, Survivor. Current station status:
Life support nominal. Hydroponics efficiency at 34 percent.
I... recommend prioritizing water filtration today."
```

**Dr. Elena Vasquez (Audio Logs):**
```
Voice Settings:
- Stability: 0.50 (emotional variation)
- Clarity: 0.70 (slightly muffled for logs)
- Style: 0.60 (expressive)

Character Direction:
"Intelligent, passionate scientist. Spanish accent subtle.
Excited when discussing discoveries, worried about ethics.
Later logs show increasing fear and determination."

Sample Line: "Research log, day 247. The cellular regeneration
rates are... impossible. We're not just growing plants anymore.
We're witnessing something that shouldn't exist."
```

**Commander Harrison (Audio Logs):**
```
Voice Settings:
- Stability: 0.65 (professional but stressed)
- Clarity: 0.75
- Style: 0.40

Character Direction:
"Military background, authoritative but weary. Hiding personal
tragedy (dying daughter). Makes increasingly desperate decisions.
Final logs reveal his true motivations."

Sample Line: "Security override, Harrison-Alpha-Seven. I'm sealing
Sector 4. God forgive me... but she's running out of time, and
this is the only way. The only way."
```

**Marcus Chen (Ghost/Memories):**
```
Voice Settings:
- Stability: 0.70
- Clarity: 0.60 (ethereal, slightly echoed)
- Style: 0.55

Character Direction:
"Wise, grandfatherly presence. Former station commander.
Speaks with regret about what happened but hope for redemption.
Occasional moments of sharp clarity about dangers."

Post-processing: Add reverb, slight pitch shift down, ethereal quality
```

### 5.2 Sound Effect Prompts

**Ambient Loops:**
```
Station Ambient - Safe Zones:
PROMPT: Space station ambient soundscape, gentle humming machinery,
distant ventilation system, occasional electronic beeps,
safe and cozy atmosphere, 60-second seamless loop

Station Ambient - Danger Zones:
PROMPT: Horror space station ambient, creaking metal stress,
distant unexplained sounds, dripping water,
electrical buzzing and flickering, tense atmosphere,
60-second seamless loop

Alien Bio-Zone Ambient:
PROMPT: Alien forest ambient soundscape, bioluminescent vegetation,
organic pulsing sounds, ethereal wind through alien plants,
subtle creature sounds in distance, 60-second seamless loop
```

**Mechanical Sounds:**
```
Bulkhead Door Open:
PROMPT: Heavy industrial door opening, hydraulic hiss,
mechanical locks disengaging, metal sliding on metal,
sci-fi space station door, 3-4 seconds duration

Generator Hum:
PROMPT: Large power generator humming, electrical transformer buzz,
industrial machinery loop, constant low frequency,
sci-fi power plant, 30-second seamless loop
```

### 5.3 Music Themes

**Main Theme:**
```
PROMPT: Space exploration theme, melancholic but hopeful,
piano lead with electronic ambient layers,
strings building to emotional crescendo,
isolated loneliness transitioning to determination,
90-second composition, suitable for title screen
```

**Sanctuary/Base Music:**
```
PROMPT: Cozy ambient music, warm and safe feeling,
gentle acoustic elements with soft synths,
Stardew Valley meets space station,
peaceful farming atmosphere, 4-minute seamless loop
```

---

## 6. Asset Naming Conventions

| Asset Type | Format | Example |
|------------|--------|---------|
| 3D Model | `mdl_{category}_{name}_{variant}` | `mdl_prop_crate_large` |
| Texture Albedo | `tex_{name}_albedo` | `tex_hull_metal_albedo` |
| Texture Normal | `tex_{name}_normal` | `tex_hull_metal_normal` |
| Material | `mat_{category}_{name}` | `mat_station_floor_grate` |
| Audio SFX | `sfx_{category}_{name}` | `sfx_door_bulkhead_open` |
| Audio Ambient | `amb_{location}_{mood}` | `amb_corridor_tense` |
| Audio Music | `mus_{context}_{mood}` | `mus_exploration_mysterious` |
| Voice Line | `vox_{character}_{id}` | `vox_aria_greeting_001` |
| UI Element | `ui_{category}_{name}` | `ui_hud_health_frame` |

---

## 7. Folder Structure

```
res://
├── assets/
│   ├── models/
│   │   ├── station/          # Corridors, doors, architecture
│   │   ├── props/            # Interactable objects
│   │   ├── flora/            # Plants, alien vegetation
│   │   ├── creatures/        # Enemies, NPCs
│   │   └── characters/       # Player, key NPCs
│   │
│   ├── textures/
│   │   ├── station/          # Metal, floors, walls
│   │   ├── organic/          # Alien materials
│   │   ├── decals/           # Signs, logos, damage
│   │   └── ui/               # Interface textures
│   │
│   ├── materials/
│   │   ├── station/          # Pre-built station materials
│   │   ├── organic/          # Alien/bio materials
│   │   └── effects/          # Special effect materials
│   │
│   └── audio/
│       ├── sfx/
│       │   ├── doors/
│       │   ├── machines/
│       │   ├── creatures/
│       │   └── environment/
│       ├── ambient/
│       ├── music/
│       └── voice/
│           ├── aria/
│           ├── vasquez/
│           ├── harrison/
│           └── logs/
│
└── reference/                # Style guides, mood boards
    ├── style_guide/
    └── color_palettes/
```

---

## 8. Quality Checklist

### 3D Models
- [ ] Polygon count within budget (props <1K, buildings <5K)
- [ ] Clean topology (no overlapping faces, proper normals)
- [ ] Correct scale (1 unit = 1 meter)
- [ ] UV unwrapped efficiently
- [ ] Style matches reference sheet

### Textures
- [ ] Power of 2 resolution (512, 1024, 2048)
- [ ] Seamless/tileable where required
- [ ] All PBR maps present and consistent
- [ ] Color palette matches style guide

### Audio
- [ ] Correct format (.ogg for music/ambient, .wav for SFX)
- [ ] Appropriate length for use case
- [ ] No clipping or distortion
- [ ] Proper loop points for ambient/music
- [ ] Voice lines match script and character

---

[Previous: Multiplayer Implementation](multiplayer.md) | [Back to Index](../../README.md)
