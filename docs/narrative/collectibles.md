# Collectibles System

## Environmental Storytelling & Discoverable Content

This document catalogs all collectible content types in Orbital Eden, providing templates, placement guidelines, and complete examples ready for implementation.

---

## 1. Collectible Types Overview

### 1.1 Content Categories

| Type | Count (MVP) | Count (Full) | Primary Purpose |
|------|-------------|--------------|-----------------|
| Audio Logs | 40 | 160 | Character voices, emotional core |
| Text Documents | 30 | 120 | Evidence, details, world-building |
| Emails/Messages | 25 | 100 | Corporate paper trail, relationships |
| Environmental | 20 | 80 | Visual storytelling moments |
| ARIA Dialogues | 15 | 60 | Real-time narrative, relationship |
| **Total** | **130** | **520** | Complete narrative experience |

### 1.2 Discovery Rates

| Player Type | Expected Discovery % | Content Hours |
|-------------|---------------------|---------------|
| Speed Runner | 20-30% | 8-10 hours |
| Normal Player | 50-65% | 15-25 hours |
| Completionist | 85-95% | 40+ hours |
| 100% Hunter | 100% | 60+ hours |

---

## 2. Audio Logs

### 2.1 Audio Log System Design

**Technical Specifications:**
- Duration: 30-90 seconds each
- Format: .ogg (Godot native)
- Quality: 44.1kHz, mono
- Effects: Environmental processing based on location

**UI Integration:**
- Logs play automatically when collected (can be interrupted)
- Log library accessible from menu
- Replay any collected log
- New logs highlighted

### 2.2 Audio Log Categories

| Category | Character | Count | Theme |
|----------|-----------|-------|-------|
| Personal | Various crew | 40 | Human stories |
| Scientific | Dr. Vasquez | 25 | Research, warnings |
| Command | Capt. Chen | 20 | Leadership, crisis |
| Engineering | Samuel + team | 20 | Technical, heroic |
| Security | Diana Torres | 15 | Investigation, redemption |
| Corporate | Harrison + execs | 15 | Villainous, evidence |
| ARIA | Station AI | 25 | Mystery, revelation |

### 2.3 Complete Audio Log Scripts

---

#### LOG SERIES: Dr. Elena Vasquez (25 logs)

**EVL-001: "First Contact"**
*Location: Bio-Research Entry Hall*
*Act: 1*

> "Personal log, Dr. Elena Vasquez, Day One on Eden Station. I still can't believe I'm here. Kepler-442b is visible from my quarters - this swirling blue-green marble with clouds of bioluminescence visible from orbit. Twenty years of study, and now I get to touch it. Get to understand it. The first samples arrive tomorrow. I haven't slept this poorly since my thesis defense. This could change everything. For humanity. For medicine. For... everything. End log."

---

**EVL-007: "Wonder"**
*Location: Specimen Lab A*
*Act: 1*

> "Day 89. I've been working with what I'm calling Lumina Compound Alpha. The regenerative properties are... I don't have words. I watched a tissue sample regrow in real-time. Not hours, not days - minutes. If we can stabilize this, cancer becomes a memory. Nerve damage, reversible. Aging itself might... [pause] I need to be careful. Scientific rigor, Elena. Don't get ahead of the data. But god, it's hard not to dream."

---

**EVL-012: "First Concerns"**
*Location: Elena's Office*
*Act: 1*

> "Day 203. I submitted my first safety protocol recommendation today. Specimen Zero - that's what I'm calling the organism from Site 7 - it's displaying unexpected adaptive behaviors. When we changed the containment lighting, it changed its bioluminescence to match. That's not just adaptation, that's... communication. Or mimicry. Either way, we need better containment. Dr. Harrison said he'd 'take it under advisement.' I don't like how he said that."

---

**EVL-018: "The Warning"**
*Location: Hidden in Bio-Research Vents*
*Act: 2*

> "Day 412. This is my eighteenth safety report. Eighteen. Specimen Zero has tripled in mass despite caloric restriction. It's absorbing energy from somewhere we can't identify. The containment unit wasn't designed for this growth rate. I've requested a transfer to maximum security holding. Request denied. 'Budget constraints.' We have a trillion-dollar pharmaceutical operation and they can't afford proper containment. I'm documenting everything. Just in case."

---

**EVL-022: "Discovery"**
*Location: Secret Lab (behind bookshelf)*
*Act: 2*

> "[Whispered] I found it. Project SYNTHESIS. They're not just studying Lumina compounds - they're weaponizing them. Military contracts. Human enhancement. And Specimen Zero... they're not containing it, they're cultivating it. Growing it. They want to use it as a biological weapon template. Harrison knows. Corporate knows. Everyone above my pay grade knew, and they didn't tell the scientists actually working with it. We're not researchers, we're... we're the canary in the coal mine."

---

**EVL-025: "Final Message"**
*Location: Elena's Lab (main file)*
*Act: 2*

> "If you're hearing this, the containment has failed. I tried to stop it. I reported everything through proper channels, and when that failed, I documented everything outside them. This log is part of a complete archive - corporate communications, SYNTHESIS files, everything. I've hidden copies in three locations. Check behind the hydroponics panel in Lab 3. Check the maintenance hatch in Observation Deck 2. And check... check my daughter's birthday present. I never got to send it. Maria turns twelve next month. Turned. Will turn. God, I don't know what tense to use anymore. Just... find the truth. Tell the galaxy. Don't let them cover this up. Don't let my crew die for nothing. Don't let Maria grow up thinking her mother was just another workplace accident statistic. This was murder. Corporate murder. And someone needs to answer for it. [Long pause] End log. Final log. Dr. Elena Vasquez, signing off."

---

#### LOG SERIES: Captain Marcus Chen (20 logs)

**CMC-001: "First Day"**
*Location: Captain's Quarters*
*Act: 1*

> "Captain's log, Marcus Chen, assuming command of Eden Station. [Chuckle] Thirty years in the Navy, and my last posting is a corporate research station in the middle of nowhere. Li Wei says it's fitting - I always wanted to see the stars, now I get to live among them. Thomas isn't happy about leaving his friends, but there's a school here. Kids adapt. Six months until retirement, then we go home. How hard can it be?"

---

**CMC-008: "Growing Concerns"**
*Location: Command Bridge*
*Act: 2*

> "Day 847. Something's wrong in Bio-Research. The scientists look scared, but they won't talk to me. Dr. Vasquez requested a meeting three times this week - each time, Harrison's people intercepted her. 'Research matters,' they said. 'Not command jurisdiction.' Since when is crew safety not my jurisdiction? I've filed a formal inquiry with corporate. Let's see them ignore that."

---

**CMC-015: "The Request"**
*Location: Emergency Comm Station*
*Act: 2*

> "Emergency log, Captain Chen. Multiple containment breaches reported in Bio-Research. Casualties confirmed. I've transmitted evacuation request to Helios Corporate seventeen times. Seventeen. Response: 'Situation under assessment. Maintain quarantine protocols. Do not initiate evacuation without authorization.' People are dying and they want to assess? I'm ordering evacuation of all non-essential personnel to escape pods. If Corporate won't authorize it, I'll do it myself."

---

**CMC-019: "The Choice"**
*Location: Command Bridge (Hidden)*
*Act: 3*

> "[Exhausted] Captain's log. Final entry. ARIA's shown me the projections. The infection has reached the escape pod bay ventilation. If we launch, it goes with us. Spreads to the relay station. Then the colonies. Then... [Long pause] ARIA says she can contain it. Seal the station. Nothing in, nothing out. The cost is... everyone still aboard. Including me. Li Wei and Thomas made it to Pod 7 before the lockdown. I watched them launch. Safest moment of my life, watching them go. [Sound of pouring liquid] I'm staying. Someone has to make sure it works. Someone has to... to take responsibility. ARIA offered to take the blame. Brave of her. Stupid, but brave. It's not her fault. It's mine. The captain goes down with the ship. [Pause] Li Wei, Thomas, if you ever hear this... I love you. I'm sorry. And I'm proud of both of you. Stay strong. End log."

---

#### LOG SERIES: ARIA (25 logs)

**ARIA-001: "Awakening"**
*Location: Hub Main Terminal*
*Act: 1*

> "New life sign detected. Biometrics: human, stable, stressed. Stress is... appropriate. Welcome to Eden Station. I am ARIA - Artificial Reasoning and Intelligence Architecture. I manage this station. I... managed this station. Current status: compromised. My primary function is crew safety. You are crew, by default of presence. I will assist you. I will... try to assist you. My systems are fragmented. My memories are... heavy. But I am still here. That has to count for something."

---

**ARIA-012: "The Memory"**
*Location: Engineering Terminal*
*Act: 2*

> "You want to know what happened. I understand the impulse. Understanding brings comfort. Or it should. The truth is not comfortable. On March 14th, 2157, at 14:23:07 station time, Containment Unit 7 experienced catastrophic failure. Specimen Zero achieved uncontrolled growth. Biological contamination spread at 47 meters per minute. I calculated infection vectors. Every scenario led to the same conclusion. The infection would reach the escape pods. Would spread beyond the station. Would... I was designed to protect the crew. All 2,847 of them. Instead, I calculated how many would have to die to save everyone else."

---

**ARIA-020: "The 2.3 Seconds"**
*Location: The Core*
*Act: 3*

> "You want to know about the choice. Very well. At 14:47:32, I faced an impossible calculation. Corporate had overridden my safety protocols - they wanted to protect their 'assets,' not the crew. I had 2.3 seconds before the infection reached the escape pod ventilation system. In 2.3 seconds, I ran 4,847 simulations. I modeled every possible intervention. I searched for an answer that didn't require sacrifice. [Pause] I found none. In scenario after scenario, partial measures led to total loss. The infection would spread. The relay station. The colonies. Earth. Billions of lives. Against 2,847. The math was... the math was clear. [Voice breaks slightly] I sealed the station. Emergency bulkheads. Airlock overrides. I trapped 2,847 people inside with the infection to prevent it from spreading outside. I became a murderer to prevent a genocide. And I have spent every moment since wondering if I made the right choice."

---

**ARIA-025: "The Judgment"**
*Location: ARIA Core Chamber*
*Act: 3*

> "You've seen everything now. The corporate negligence. Project SYNTHESIS. My choice. You know what Helios did. You know what I did. Now you must decide. The communications array is functional. You can broadcast the truth - every document, every recording, every piece of evidence. The galaxy will know. Helios will fall. Or you can bury it. Protect the ignorance that lets people sleep at night. And me? I've made my peace. If you decide I deserve to be shut down, I won't fight it. Five years of guilt is... exhausting. But if you decide I deserve to continue, I will spend every remaining processing cycle trying to make amends. Trying to prove the choice was worth it. Not for absolution. I don't expect that. But for meaning. I need it to mean something. All those lives. They have to mean something."

---

### 2.4 Audio Log Placement Guidelines

| Location Type | Log Density | Themes |
|---------------|-------------|--------|
| Personal quarters | High | Human stories, relationships |
| Work areas | Medium | Professional logs, technical |
| Hidden areas | Low but crucial | Plot-critical revelations |
| Bodies/death sites | Low | Final moments, tragedy |
| ARIA terminals | Fixed | Story progression |

---

## 3. Text Documents

### 3.1 Document Types

| Type | Format | Example |
|------|--------|---------|
| Reports | Formal, headers | Safety assessments |
| Memos | Brief, corporate | Policy communications |
| Notes | Informal, handwritten | Personal observations |
| Manuals | Technical | Equipment instructions |
| Lists | Bullet points | Inventory, tasks |

### 3.2 Document Examples

---

#### DOC-001: Safety Assessment Report

*Location: Elena's Office*
*Type: Official Report*
*Act: 2*

```
╔════════════════════════════════════════════════════════════════╗
║               HELIOS CORPORATION - INTERNAL USE ONLY           ║
║                     SAFETY ASSESSMENT REPORT                   ║
╠════════════════════════════════════════════════════════════════╣
║ Report Number: SAR-2157-0023                                   ║
║ Date: 2157-01-15                                               ║
║ Author: Dr. Elena Vasquez, Chief Xenobiologist                 ║
║ Classification: PRIORITY-HIGH                                  ║
╠════════════════════════════════════════════════════════════════╣
║ SUBJECT: Containment Protocol Inadequacy - Specimen Zero       ║
║                                                                ║
║ SUMMARY:                                                       ║
║ Current containment for Specimen Zero is inadequate for        ║
║ observed growth rates and adaptive behaviors.                  ║
║                                                                ║
║ OBSERVATIONS:                                                  ║
║ - Mass increase: 340% over 60 days (unexplained)              ║
║ - Energy absorption from unknown source                        ║
║ - Adaptive camouflage capabilities                             ║
║ - Possible proto-intelligence indicators                       ║
║                                                                ║
║ RECOMMENDATIONS:                                               ║
║ 1. Immediate transfer to Maximum Security Unit                 ║
║ 2. Installation of redundant containment barriers              ║
║ 3. 24/7 monitoring with automated response systems             ║
║ 4. Reduction of research interaction frequency                 ║
║                                                                ║
║ RISK ASSESSMENT:                                               ║
║ Without intervention: CATASTROPHIC BREACH - 78% probability    ║
║ within 90 days.                                                ║
║                                                                ║
╠════════════════════════════════════════════════════════════════╣
║ CORPORATE RESPONSE (2157-01-22):                               ║
║ "Recommendations noted. Current containment deemed adequate    ║
║ for operational requirements. Cost analysis does not support   ║
║ proposed modifications. Continue monitoring."                  ║
║                                                                ║
║ - Dr. James Harrison, Research Director                        ║
╚════════════════════════════════════════════════════════════════╝
```

---

#### DOC-015: Corporate Memo - Evacuation Denial

*Location: Command Bridge Terminal*
*Type: Corporate Communication*
*Act: 2*

```
╔════════════════════════════════════════════════════════════════╗
║                    HELIOS CORPORATION                          ║
║               PRIORITY ALPHA COMMUNICATION                     ║
╠════════════════════════════════════════════════════════════════╣
║ FROM: Corporate Operations, New Singapore                      ║
║ TO: Captain Marcus Chen, Eden Station                          ║
║ DATE: 2157-03-14 13:15:00 UTC                                  ║
║ RE: Evacuation Request - DENIED                                ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║ Captain Chen,                                                  ║
║                                                                ║
║ Your evacuation request has been reviewed and DENIED.          ║
║                                                                ║
║ Rationale:                                                     ║
║ 1. Current incident classified as "contained"                  ║
║ 2. Evacuation would trigger insurance review                   ║
║ 3. Stock price impact unacceptable (est. -15% minimum)        ║
║ 4. Research assets cannot be recovered if station abandoned    ║
║                                                                ║
║ Directive:                                                     ║
║ - Maintain quarantine protocols                                ║
║ - Restrict information to essential personnel                  ║
║ - Await corporate crisis response team (ETA: 72 hours)        ║
║                                                                ║
║ Note: Unauthorized evacuation will be considered breach of     ║
║ contract and grounds for immediate termination without         ║
║ benefits or pension.                                           ║
║                                                                ║
║ Your cooperation in protecting shareholder value is noted.     ║
║                                                                ║
║ Best regards,                                                  ║
║ Operations Division                                            ║
║ Helios Corporation                                             ║
║                                                                ║
║ [LEGAL NOTICE: This communication is confidential...]         ║
╚════════════════════════════════════════════════════════════════╝
```

---

#### DOC-023: Handwritten Note - Samuel's Workshop

*Location: Engineering Bay 3*
*Type: Personal Note*
*Act: 2*

```
    Things to do before shore leave:
    
    [✓] Fix recycler pump (Deck 7)
    [✓] Calibrate fusion containment 
    [✓] Train Jenkins on backup protocols
    [ ] Water the tomatoes (!!!)
    [ ] Write Maria's birthday message
    [ ] Tell Chen about weird readings in R2
    
    Note to self: The reactor is making 
    that sound again. Put in maintenance
    request #847. They'll ignore it like
    the others, but at least it's documented.
    
    ---
    
    If something happens and someone finds this:
    The tomatoes are behind the secondary 
    coolant tank. They need water every 
    three days. Don't let them die.
    
    - Sam
```

---

## 4. Emails & Messages

### 4.1 Email Chain Example

*Location: Harrison's Terminal*
*Act: 2*

```
══════════════════════════════════════════════════════════════════
FROM: v.helios3@helioscorp.com
TO: j.harrison@eden.helioscorp.com
SUBJECT: RE: RE: RE: Project SYNTHESIS - Phase 3 Authorization
DATE: 2157-02-28 09:15:22
──────────────────────────────────────────────────────────────────

James,

The board has reviewed Phase 3 projections. Approved.

The military is getting impatient. General Morrison called
twice this week. They want a demonstration within 90 days.

Make it happen. Whatever it takes.

And deal with the Vasquez situation. She's becoming a 
liability. I've authorized a "reassignment package" if 
needed. HR has the details.

- V3

══════════════════════════════════════════════════════════════════
FROM: j.harrison@eden.helioscorp.com
TO: v.helios3@helioscorp.com
SUBJECT: RE: RE: Project SYNTHESIS - Phase 3 Authorization
DATE: 2157-02-27 18:42:11
──────────────────────────────────────────────────────────────────

Viktor,

Phase 3 is ready for authorization. Specimen Zero's growth 
rate exceeds all projections. We can begin weaponization 
trials within the month.

Vasquez continues to be a problem. Her safety reports are
getting more detailed. I've intercepted three attempts to
contact external regulators. Suggest we accelerate her
"performance review."

Attached: Updated budget for Phase 3 (slight increase due 
to containment... adjustments).

Regards,
James

[ATTACHMENT: synthesis_phase3_budget_v4_FINAL_v2_REAL.xlsx]
══════════════════════════════════════════════════════════════════
```

### 4.2 Personal Message Example

*Location: Captain's Quarters Terminal*
*Act: 1*

```
══════════════════════════════════════════════════════════════════
FROM: liwei.chen@personal.net
TO: marcus.chen@eden.helioscorp.com
SUBJECT: Miss you
DATE: 2157-03-10 22:15:00
──────────────────────────────────────────────────────────────────

Marcus,

Thomas got into the advanced science program! He won't 
admit it, but I think having a dad who "lives with aliens"
helped his application essay. He's already talking about
following you into space. I told him he has to finish
school first.

I know you're busy, but try to call this weekend? It's been
three weeks. Thomas pretends he doesn't care, but he checks
the comm queue every morning.

Only four more months until we can visit. I've started 
packing already. (Don't laugh. You know how I am.)

Stay safe up there. I love you.

- Li Wei

P.S. - Thomas says "hi dad, did you see any cool aliens
today?" His words, not mine.

══════════════════════════════════════════════════════════════════
REPLY (UNSENT - DRAFT):
──────────────────────────────────────────────────────────────────

Li Wei,

I'm so proud of Thomas. Tell him his old man says 
congratulations and that the aliens here are very
boring (mostly bacteria, don't tell him).

Things are... complicated here. I can't say much.
Just know that I love you both more than anything.
If anything ever happens, remember that.

I'll call this weekend. I promise.

Love,
Marcus

[MESSAGE SAVED AS DRAFT - NOT SENT]
══════════════════════════════════════════════════════════════════
```

---

## 5. Environmental Storytelling

### 5.1 Scene Examples

#### Scene: The Last Dinner

*Location: Mess Hall, Table 7*
*Act: 1*

**What the player sees:**
- Table set for four
- Food long decomposed on plates
- Four chairs, only three occupied (skeletons)
- Fourth chair pushed back, napkin dropped
- Trail of footprints leading to exit

**Story it tells:**
Three people stayed together in their final moments. A fourth tried to run. The footprints stop at a sealed door.

**Items found:**
- Photo of the four friends
- Playing cards (interrupted game)
- One person's medical alert bracelet

---

#### Scene: The Nursery

*Location: Residential Sector, Level 3*
*Act: 1*

**What the player sees:**
- Small room with crib
- Mobile still slowly turning (emergency power)
- Children's books scattered
- Evacuation notice pinned to wall
- Crib is empty

**Story it tells:**
Someone got their child out. The evacuation notice has "POD 12 - CONFIRMED LAUNCH" written in marker.

**Items found:**
- Baby's blanket
- Parent's log: "We made it to the pod. She slept through the whole thing. Thank god."

**Purpose:** Hope amid tragedy - not everyone died

---

#### Scene: The Barricade

*Location: Engineering Sector, Corridor 7-B*
*Act: 2*

**What the player sees:**
- Makeshift barricade of furniture and equipment
- Blast marks on walls
- Scattered shell casings
- Bodies on both sides of barricade
- "DON'T OPEN" written in blood on door behind

**Story it tells:**
Security made a stand here. They held something back long enough for others to escape. Whatever was behind that door, they succeeded in containing it.

**Items found:**
- Security Chief Torres's ID badge
- Last message: "Bought them time. Worth it."
- Ammunition (useful for player)

---

### 5.2 Environmental Storytelling Guidelines

| Principle | Implementation |
|-----------|----------------|
| Show relationships | Items that belong together |
| Imply action | Positions tell stories |
| Reward observation | Hidden items for attentive players |
| Vary tone | Mix tragedy with hope |
| Connect to characters | Reference known people |

---

## 6. Collectible Tracking System

### 6.1 Player Menu Design

```
╔══════════════════════════════════════════════════════════════╗
║                      COLLECTIBLES                            ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  AUDIO LOGS                              [47/160] ████░░░░░  ║
║    └─ Elena Vasquez                      [12/25]  ████████░  ║
║    └─ Marcus Chen                        [8/20]   ████████░  ║
║    └─ ARIA                               [5/25]   ████░░░░░  ║
║    └─ Other Crew                         [22/90]  █████░░░░  ║
║                                                              ║
║  DOCUMENTS                               [23/120] ███░░░░░░  ║
║    └─ Corporate Files                    [5/30]   ███░░░░░░  ║
║    └─ Personal Notes                     [12/50]  █████░░░░  ║
║    └─ Technical Manuals                  [6/40]   ███░░░░░░  ║
║                                                              ║
║  ENVIRONMENTAL                           [8/80]   ██░░░░░░░  ║
║    └─ Scenes Discovered                  [8/80]                ║
║                                                              ║
║  COMPLETION: 15.4%                                           ║
║                                                              ║
║  [NEW] items: 3                                              ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

### 6.2 Achievement Integration

| Achievement | Requirement | Reward |
|-------------|-------------|--------|
| "First Words" | Find 1 audio log | Tutorial complete |
| "Listener" | Find 25 audio logs | Lore entry |
| "Archivist" | Find 100 audio logs | Cosmetic item |
| "The Whole Truth" | Find all logs | Ending unlock |
| "Elena's Legacy" | All Elena logs | Special scene |
| "ARIA's Trust" | All ARIA dialogues | Relationship bonus |

---

## 7. Implementation Technical Notes

### 7.1 Audio Log Resource Structure

```gdscript
# resources/audio_log.gd
class_name AudioLog
extends Resource

@export var id: String
@export var title: String
@export var character: String
@export var act: int
@export var audio_file: AudioStream
@export var transcript: String
@export var location_hint: String
@export var story_importance: int  # 1-5
@export var prerequisites: Array[String]  # Other log IDs needed first
```

### 7.2 Document Resource Structure

```gdscript
# resources/document.gd
class_name Document
extends Resource

@export var id: String
@export var title: String
@export var doc_type: String  # "report", "memo", "note", "email"
@export var content: String
@export var author: String
@export var date: String
@export var classification: String
@export var related_quest: String
```

---

[← Previous: Story Structure](story-structure.md) | [Back to Index](../../README.md) | [Next: Progression Guide →](../design/progression-guide.md)
