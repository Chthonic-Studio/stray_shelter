# **Stray Shelter**

## **1\. Executive Summary & Core Pillars**

*Stray Shelter* is a top-down, pixel-art management simulator where players assume the role of a shelter manager running a rundown animal sanctuary. Players must balance the books, manage staff, grow fresh ingredients, craft enrichment items, and medically rehabilitate traumatized or sick animals to match them with their forever homes.

### **The Core Tonal Challenge**

The game pairs cozy aesthetics (gardening, crafting, pet interaction) with high emotional stakes (illness, potential pet death, return of pets, financial ruin). Rather than ignoring this friction, the design embraces it. The cozy loops (gardening and crafting) serve as **active gameplay mitigators** to the stressful management loops.

### **Core Design Pillars**

1. **Earned Cozy (Contrast):** Joy is earned through the friction of rehabilitation. The quiet moments of brushing a healed dog in the garden feel rewarding because of the effort it took to cure them.  
2. **Systemic Empathy:** Pets are not static items with stats; they are active agents. Their behaviors, driven by a hybrid State-Machine/Utility AI, must feel organic, flawed, and expressive.  
3. **Accountability:** Every decision has a human and animal cost. Choosing cheap food leads to illness; rushing an interview leads to an adoption return.

## **2\. Core Gameplay Loop**

  \[Intake of Rescue/Surrender\]  
              │  
              ▼  
    \[Medical & Psychological Audit\]  
              │  
              ├──► \[Veterinary Clinic / Treatment / Care\]  
              └──► \[Daily Shelter Maintenance & Staffing\]  
              │  
              ▼  
    \[Rehabilitation & Enrichment\] ◄─── \[Gardening & Crafting Minigames\]  
              │  
              ▼  
    \[Adoption Process: Screening & Matches\]  
              │  
              ▼  
    \[Post-Adoption Follow-ups & Retention Check\] ──(Potential Return)──┐  
              │                                                        │  
              ▼                                                        ▼  
    \[Shelter Renown / Debt Paid Off\] ◄─────────────────────────────────┘

## **3\. Architecture & Godot 4.6 Implementation Strategy**

To keep the project clean, scalable, and modular, we use a component-based architecture leveraging Godot 4.6’s strength with Node composition and Resource structures.

### **Data Architecture: Custom Resources (Resource)**

Using Godot’s native Custom Resources is vital for performance and data management. It allows us to save, load, and duplicate pet templates instantly.

* **PetData.gd (Custom Resource):** Holds unique static parameters (Race, Age, History, Dietary Needs, Personality Vectors) and dynamic variables (Hunger, Affection, Boredom, Health status).  
* **StaffData.gd (Custom Resource):** Holds Worker stats (Personality, Base Salary, Efficiency, Role, Burnout).

## **4\. The Pet System (Attributes & Behaviors)**

### **Pet Attributes**

Each pet is instantiated with a unique configuration of variables:

| Attribute Group | Variables | Impact on Gameplay |
| :---- | :---- | :---- |
| **Identity** | Breed, Age, History | Dictates aesthetic, lifespan, and recurring medical history. |
| **Physical Needs** | Hunger, Energy, Hygiene, Health | Drives basic survival actions; neglected stats lead to sickness. |
| **Mental Needs** | Affection, Boredom, Stress | Drives social behaviors, destructiveness, and adoption success. |
| **Personality** | Playful-Lethargic, Brave-Fearful | Modulates the weight of Utility AI calculations. |

### **Sickness, Aging, and Death**

To handle death without alienating players, we implement the **Dignity Rule**:

* **Old Age:** Pets have a clear "Senior" status. When their maximum age limit is reached, they pass away peacefully in their sleep if stress is low, rewarding the player with a "Legacy Star" representing a life well-managed.  
* **Sickness & Surgical Failures:** Pets do not die instantly of sickness. Sickness stages are clearly signposted (Visual cues, icons). If a pet passes away due to medical neglect or surgical failure, it represents a breakdown in player system-management.

## **5\. Systemic AI: State-Machine Driven Utility AI**

To achieve life-like, believable behavior without tanking performance, we implement a **Finite State Machine (FSM) \+ Utility AI** hybrid model.

       ┌────────────────────────┐  
       │     High-Level FSM     │ (Controls overall context/animation states)  
       └───────────┬────────────┘  
                   │ Updates & Filters  
                   ▼  
       ┌────────────────────────┐  
       │   Utility AI Engine    │ (Evaluates score of all possible actions)  
       └───────────┬────────────┘  
                   │ Chooses highest score  
                   ▼  
       ┌────────────────────────┐  
       │  Action Execution Node  │ (Moves path, plays animation, alters stats)  
       └────────────────────────┘

### **1\. High-Level FSM (Finite State Machine)**

The FSM dictates the macro-behavior of the pet. This prevents the Utility AI from running expensive calculations every frame.

* **States:** Idle, SatisfyingNeeds, Interacting, Anxious/Stressed, Sleeping, InMedicalTreatment.

### **2\. Utility AI Engine (The Brain)**

While inside a state (e.g., SatisfyingNeeds), the Utility AI decides *which* need to satisfy based on **Curves** (Utility Functions).

* **The Math:** Each potential action (Eat, Drink, Play, Seek Human) has an utility score calculated as:  
  ![][image1]  
* **Godot implementation:**  
  * We build an Action node pattern. Each Action evaluates its own desirability.  
  * *Example:* If Hunger is at ![][image2], the EatAction score shoots up exponentially. If the pet is "Timid" (Personality), the InteractWithStranger action score is heavily penalized.

## **6\. Shelter Operations & Management Systems**

### **1\. Human Resources (HR)**

Workers are not passive stat-boosts; they are human agents with dynamic states.

* **Roles:** Caregiver (feeding/cleaning), Medic (treating/surgery assist), Socializer (training/playing).  
* **Burnout System:** Workers have an energy and stress bar. If they work long hours with low pay or bad performance reviews, their efficiency drops, and they may quit, leaving animals neglected.

### **2\. Veterinary Clinic & Surgery Minigame**

Rather than a passive menu, the clinic acts as an upgraded zone.

* **Medical Supplies Management:** Players must purchase and track medicines, bandages, and surgical tools.  
* **Diagnostic Loop:** Analyze pet history (e.g., recurring heart murmurs) to choose the right treatment.  
* **Surgical Procedure Loop:** A tense, rhythm/timing-based minigame where players must maintain stability. Failure results in higher pet stress or critical medical failure (death risk).

## **7\. Cozy Mitigators: Gardening & Crafting**

To break up the emotional fatigue of running a cash-strapped, high-stakes shelter, the game features two cozy loops that directly tie into core rehabilitation.

### **Backyard Gardening (The Farm)**

Players maintain a backyard garden plot. This is not just a secondary economic engine; it is deeply integrated into pet care.

* **Growable Resources:** Special herbs (for medical poultices), organic vegetables (for specialized diets), and calming catnip/lavender.  
* **Synergy:** Active gardening lowers player-character stress and provides cost-free high-grade ingredients that would otherwise break the shelter’s budget.

### **Crafting Toy Station**

An interactive workbench where players construct items.

* **Recipe-Based Crafting:** Combine junk materials (cardboard, old fabric, plastic bottles) with organic garden materials (catnip) to craft toys.  
* **Minigame Action:** Simple, satisfying assembly mechanics (e.g., balancing tension meters or connecting nodes).  
* **Enrichment Values:** High-quality crafted items significantly reduce pet stress and accelerate behavioral rehabilitation.

## **8\. Adoption & Post-Adoption Systems**

Adoption is the ultimate goal, but a bad match is worse than no match.

                  \[Adopter Profile Appears\]  
                             │  
                             ▼  
                \[Player Screens Adopter Resume\]  
                             │  
                             ▼  
              \[Live Interview: Dynamic Dialogue\]  
              (Choose questions matching pet traits)  
                             │  
                             ▼  
                    \[Adoption Approved?\]  
                   /                    \\  
                 YES                     NO (Adopter departs; Renown hit)  
                 /  
                ▼  
      \[Post-Adoption Phase: Check-ins\]  
      (Text messages, photo updates, visits)  
           /                      \\  
      GOOD MATCH               BAD MATCH (High Stress)  
          │                        │  
          ▼                        ▼  
  \[Renown Boost / Cash\]     \[Animal Returned / Trauma Stat Buff\]

### **The Return Penalty**

If an animal is returned:

* The animal gains the **"Trauma: Abandoned"** trait, making future Utility AI interactions highly anxious (increased difficulty to rehabilitate).  
* The shelter suffers a **Renown Penalty**, lowering the quality of future incoming adopters.

## **9\. Git Repository Structure & File Layout**

shelter-and-soul/  
├── .github/  
│   └── workflows/              \# CI/CD for auto-build exports  
├── assets/  
│   ├── audio/                  \# SFX and Cozy Lofi sound tracks  
│   ├── env/                    \# Tilesets for shelter, garden, clinic  
│   └── sprites/                \# Animated sheets for Pets (FSM directed)  
├── src/  
│   ├── autoload/               \# Singletons (GameManager, SaveManager)  
│   ├── core/                   \# Game architecture classes  
│   │   ├── AI/                 \# Utility AI & State Machine components  
│   │   └── Systems/            \# Economy, Time, Day/Night systems  
│   ├── entities/               \# Base scenes (Player, Pet, Worker)  
│   ├── minigames/              \# Gardening & Crafting subscenes  
│   ├── resources/              \# Custom Resource definitions (.gd & .tres)  
│   └── ui/                     \# Dialogues, Interview UI, HUD  
├── project.godot               \# Godot 4.6 Project File  
└── README.md                   \# This Document  


