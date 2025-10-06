# Blockchain Demonstrator Beer Game - Gamemaster Guide

A digital serious game demonstrating supply chain dynamics, the bullwhip effect, and blockchain solutions through hands-on experiential learning.

---

## Table of Contents
1. [What is the Beer Game?](#what-is-the-beer-game)
2. [What Makes This Version Unique?](#what-makes-this-version-unique)
3. [Learning Objectives](#learning-objectives)
4. [How to Run a Session](#how-to-run-a-session)
5. [Facilitating the Debrief](#facilitating-the-debrief)
6. [Tips for Success](#tips-for-success)
7. [Common Mistakes to Avoid](#common-mistakes-to-avoid)
8. [Technical Setup](#technical-setup)

---

## What is the Beer Game?

### Background
The Beer Game is a legendary business simulation created by **Jay Wright Forrester** at MIT Sloan School of Management in **1960**. It's one of the most powerful experiential learning tools for understanding:
- Supply chain coordination problems
- System dynamics and feedback loops
- How well-intentioned individuals create unintended systemic chaos

### The Core Insight
The game demonstrates that **intelligent people making rational local decisions can create outcomes nobody expected or wanted** when they lack visibility into the larger system.

### The Setup
Players manage a **beer supply chain** with four connected roles:
- **Retailer** → sells beer to customers
- **Manufacturer** → produces beer packs from barley
- **Processor** → processes barley from seeds
- **Farmer** → grows barley seeds

Each player can only see their own inventory and orders. They must order from their supplier and deliver to their customer, but **cannot communicate** with other players. This information isolation creates the famous **bullwhip effect**.

---

## What Makes This Version Unique?

### 🌾 Beer Production Supply Chain
Unlike the traditional version (Retailer → Wholesaler → Distributor → Factory), this game models an **agricultural supply chain**:

| Role | Product Handled | Supplies To | Orders From |
|------|----------------|-------------|-------------|
| **Retailer** | Beer (final product) | Customers | Manufacturer |
| **Manufacturer** | Beer Packs | Retailer | Processor |
| **Processor** | Barley | Manufacturer | Farmer |
| **Farmer** | Seeds | Processor | (unlimited supply) |

### 🔗 Blockchain Technology Options
This version's **key innovation** is that players can choose different **information-sharing technologies**:

| Option | Description | Cost Structure | Learning Focus |
|--------|-------------|----------------|----------------|
| **Basic** | Traditional isolated operations | Medium fixed, no tech cost | Experience the classic bullwhip effect |
| **YouProvide** | Manual information sharing | High fixed, low tech cost | Self-managed transparency challenges |
| **YouProvideWithHelp** | Assisted information sharing | Low fixed, medium tech cost | Value of expert support systems |
| **TrustedParty** | Third-party coordination platform | Variable fixed, high tech cost | Centralized trust models |
| **DLT (Blockchain)** | Distributed ledger transparency | Varies by role, highest tech cost | Decentralized trust, immutable records |

Each option has different:
- **Fixed costs** (per round regardless of activity)
- **Tech costs** (technology maintenance/operation)
- **Variable costs** (per unit of inventory/backorders)

### 🎮 Digital Platform Features
- **Real-time web interface** - no physical cards or tokens needed
- **GameMaster dashboard** - centralized control and monitoring
- **Live visualization** - instant feedback on supply chain performance
- **SignalR real-time updates** - synchronized multi-player experience
- **Blockchain transparency** (when DLT option selected) - all players see shared ledger

---

## Learning Objectives

### Primary Learning Outcomes

#### 1. **The Bullwhip Effect** 🌊
- Small changes in customer demand create massive oscillations upstream
- Each player amplifies order variability trying to manage their local inventory
- Lead times and delays cause over-ordering and then over-correction
- **Key insight**: Structure of the system creates the problem, not individual incompetence

#### 2. **Systems Thinking** 🧠
- Individual optimization ≠ system optimization
- Feedback loops and delays destabilize well-intentioned decisions
- Local actions have distant consequences
- **Key insight**: "Pushing harder" on symptoms often makes things worse

#### 3. **Information Asymmetry** 👁️
- Lack of visibility creates fear and defensive behavior
- Players assume problems are caused by unreliable suppliers/customers
- Demand information degrades as it travels upstream
- **Key insight**: Transparency reduces panic and overreaction

#### 4. **Blockchain & Supply Chain Solutions** ⛓️
- Distributed ledger provides single source of truth
- Smart contracts can automate agreements and reduce delays
- Trade-offs between transparency, cost, and competitive advantage
- **Key insight**: Technology alone doesn't solve coordination problems without aligned incentives

#### 5. **Human Decision-Making Under Pressure** 🎯
- Cognitive limitations prevent grasping complex dynamics
- Emotional reactions (panic, frustration, blame) cloud judgment
- Tendency to ignore "supply line" (orders already in transit)
- **Key insight**: Better mental models + system design prevent crises

---

## How to Run a Session

### ⏱️ Time Required
**Minimum 2 hours total:**
- Setup & briefing: 15-20 minutes
- Gameplay: 30-45 minutes (12-20 rounds)
- **Debrief: 45-60 minutes** *(most important part!)*

### 👥 Players Required
- **4 players minimum** (one per role)
- Can run **multiple teams simultaneously** (4 players = 1 team)
- Ideal: 8-16 players (2-4 teams competing)

---

### 📋 Pre-Session Setup

#### Technical Checklist
- [ ] GameMaster account created (6-digit code)
- [ ] Game session created through admin panel
- [ ] All 4 role slots available
- [ ] Database connected, app running in Production mode
- [ ] Projection/screen ready for system visualization
- [ ] Player devices tested (tablets/laptops with browsers)

#### Materials Preparation
- [ ] Role instruction sheets printed
- [ ] Game access codes/QR codes ready
- [ ] Debrief discussion questions prepared
- [ ] Flip chart/whiteboard for capturing insights
- [ ] Timer/clock visible to all players

---

### 📢 Briefing Players (15-20 minutes)

#### 1. **Set the Context**
> "You're managing a beer supply chain from farm to retail store. Your goal is to **minimize costs** while meeting demand. You'll face inventory holding costs and backorder penalties."

#### 2. **Explain the Roles** (without revealing full system initially)
- **Retailer**: You sell beer to customers. Order from the Manufacturer.
- **Manufacturer**: You produce beer. Order barley from the Processor.
- **Processor**: You process barley. Order seeds from the Farmer.
- **Farmer**: You grow seeds. Order from unlimited natural supply.

#### 3. **Explain the Technology Options**
Show the 5 options (Basic, YouProvide, YouProvideWithHelp, TrustedParty, DLT):

> "You'll choose how to share information in the supply chain. Some options give more visibility but cost more. Consider the trade-offs between transparency, cost, and competitive advantage."

**For first-time players**: Start everyone on **Basic** to experience the classic bullwhip effect, then discuss blockchain solutions in debrief.

**For advanced sessions**: Let each player choose their own option to see how mixed strategies perform.

#### 4. **The Rules** ⚠️
Each round, you will:
1. **Receive deliveries** from your supplier
2. **Check incoming orders** from your customer
3. **Deliver products** to fulfill orders (if you have inventory)
4. **Place new orders** to your supplier

**CRITICAL RULES:**
- ❌ **NO COMMUNICATION** between players during the game
- ⏰ Lead times exist (orders take time to arrive)
- 💰 Costs: Holding inventory costs money, backorders cost even more
- 📊 You can ONLY see your own information (unless using blockchain/transparency options)

#### 5. **Practice Rounds** (Recommended)
- Run 2-3 **trial rounds** with guidance
- Walk through each step slowly: deliveries → orders → deliver → place order
- Answer questions before starting the "real" game
- Ensure players understand the interface

---

### 🎮 During Gameplay (30-45 minutes)

#### Facilitator Actions

**📣 Call Out Each Step Clearly:**
> "Everyone: **Check your deliveries**... Now **check your incoming orders**... Now **deliver to your customer**... Now **place your order** to your supplier."

**⏳ Pacing:**
- Start **SLOW** (2-3 minutes per round) for first 3-4 rounds
- Let system reach equilibrium before introducing demand changes
- Speed up slightly once players are comfortable (1-2 min/round)

**👀 Observe & Take Notes:**
- Watch for panic ordering when backorders appear
- Notice emotional reactions (frustration, blame, confusion)
- Track when players start over-ordering or hoarding inventory
- Note interesting moments to reference during debrief

**🚫 What NOT to Do:**
- ❌ Don't give hints or advice
- ❌ Don't rescue players from chaos
- ❌ Don't explain what's happening (let them discover)
- ❌ Don't allow communication between players
- ❌ **Don't skip the chaos** - it's the learning opportunity!

#### What to Watch For

🔴 **Classic Symptoms of Bullwhip Effect:**
- Retailer gets small backorder → orders much more than usual
- Manufacturer sees spike in orders → over-orders from Processor
- Processor panics → massively over-orders from Farmer
- Farmer produces huge amounts → then everyone has excess inventory
- Cycle repeats with everyone swinging from shortage to surplus

📈 **Player Behaviors:**
- Adding backorder quantity to new orders (double-counting demand)
- Not tracking "supply line" (orders already placed but not arrived)
- Blaming suppliers: "My supplier is unreliable!"
- Frustration: "This is impossible!"
- Late realization: "Wait, WE all created this problem..."

---

## Facilitating the Debrief

### 🎯 **This is the Most Important Part!**
> **Without proper debrief, the game is just a frustrating experience. The debrief is where learning happens.**

### The Debrief Structure (45-60 minutes)

---

#### **Phase 1: Emotional Decompression (5-10 min)**

Let players vent and share their experience:
- *"How are you feeling right now?"*
- *"What was that like for you?"*
- *"Who wants to share what happened from their perspective?"*

**Goal**: Release frustration, build psychological safety, prepare for learning.

---

#### **Phase 2: Individual Reflection (10 min)**

Ask each role:
- *"What was your strategy?"*
- *"When did you first notice problems?"*
- *"How did you respond to backorders? To excess inventory?"*
- *"What information did you wish you had?"*

**Retailer**: Often feels pressure from customer demand, starts the oscillation.
**Manufacturer/Processor**: Caught in the middle, amplifies variability.
**Farmer**: Sees wildly erratic orders, produces huge swings in output.

---

#### **Phase 3: System Analysis (15-20 min)**

**📊 Show the Data:**
- Display supply chain graphs from GameMaster dashboard
- Show inventory levels over time (all 4 players)
- Show order patterns (highlight the bullwhip amplification)
- Show total costs

**Key Questions:**
- *"Notice the pattern: small demand change → huge oscillations upstream. What created this?"*
- *"Why did orders increase as we go upstream in the supply chain?"*
- *"How did lead times affect your decision-making?"*
- *"What role did the 'no communication' rule play?"*

**Root Cause Analysis:**
- Players over-order when they see backorders (panic response)
- Don't track supply line (orders in transit but not yet received)
- Add backlog to base demand (double-counting)
- Each player amplifies the signal → bullwhip effect

**The Big Reveal:**
> "The structure of the system created this problem. Intelligent people making rational local decisions produced irrational system-wide chaos. This is a **system dynamics** issue, not a people problem."

---

#### **Phase 4: Blockchain & Technology Discussion (10-15 min)**

**For Basic Option Players:**
- *"What if everyone could see the same demand information?"*
- *"How might blockchain transparency have helped?"*
- *"What information would you want on a shared ledger?"*

**For Players Who Used DLT/Blockchain:**
- *"How did transparency change your decisions?"*
- *"What were the trade-offs of the DLT option?"*
- *"Did it eliminate the bullwhip effect? Why or why not?"*

**Key Insights:**
- 🔗 **Blockchain provides**: Single source of truth, immutable transaction history, real-time visibility
- 💡 **But doesn't solve**: Human judgment, incentive misalignment, interpretation of data
- 💰 **Trade-offs**: Technology costs vs. information value, transparency vs. competitive advantage

**Discuss the 5 Options:**
| Option | When to Use | Pros | Cons |
|--------|-------------|------|------|
| **Basic** | Small, simple supply chains | Cheapest, no tech dependency | No visibility, high bullwhip risk |
| **YouProvide** | DIY tech-savvy organizations | Control, customization | High setup cost, maintenance burden |
| **YouProvideWithHelp** | Medium-sized businesses | Expert support, moderate cost | Ongoing dependency on consultants |
| **TrustedParty** | Industries with established platforms | Proven solutions, vendor support | Vendor lock-in, trust dependency |
| **DLT** | High-value, multi-party supply chains | Trust-minimized, transparent, auditable | High tech cost, complexity, requires coordination |

---

#### **Phase 5: Real-World Transfer (10-15 min)**

Connect to participant experiences:
- *"Where have you seen similar dynamics in your own work?"*
- *"What parallels exist in your industry's supply chain?"*
- *"How could you apply these insights to your organization?"*
- *"If we could redesign this supply chain, what would you change?"*

**Real-World Examples:**
- 🧻 **COVID-19 toilet paper shortages** (panic buying → over-ordering → empty shelves → hoarding)
- 📱 **Electronics supply chains** (chip shortages, bullwhip in semiconductor industry)
- 🍫 **Food & beverage** (seasonal demand spikes amplified through distribution)
- 🚗 **Automotive** (just-in-time inventory failures during disruptions)

---

#### **Phase 6: Key Takeaways & Action Items (5 min)**

**Capture insights on flip chart:**
- Top 3 lessons learned
- How to recognize bullwhip effect in real work
- Strategies for reducing oscillations (smooth ordering, share information, reduce lead times)
- When blockchain/DLT adds value vs. traditional coordination

**Action Items:**
- What will you do differently in your supply chain?
- How will you share this learning with your team?
- What system structures should you question?

---

## Tips for Success

### 🎯 Engagement Strategies

1. **Create Competitive Energy**
   - Frame as challenge: "Can your supply chain outperform the others?"
   - Use team names (e.g., "Supply Chain Alpha" vs. "Supply Chain Beta")
   - Show cost leaderboard at the end

2. **Use Narrative Framing**
   - Give context: "You're managing a local craft brewery's farm-to-tap supply chain"
   - Make it vivid: "Retailer, angry customers are waiting for their beer!"
   - Build tension: "Costs are climbing... who will stabilize first?"

3. **Strategic Silence**
   - Resist urge to explain during chaos
   - Let uncomfortable moments breathe
   - The struggle creates the "aha!" moment later

### 📚 Educational Enhancements

4. **Run Multiple Rounds with Variations**

   **Round 1**: All players use **Basic** (experience bullwhip)

   **Round 2**: All players use **DLT** (experience blockchain transparency)

   **Compare**: How did transparency change behavior and costs?

5. **Mixed Technology Scenarios**
   - Retailer + Manufacturer use DLT, Processor + Farmer use Basic
   - Discuss: "Where are the coordination breakdowns now?"

6. **Introduce Mid-Game Disruptions** (Advanced)
   - Announce to Retailer only: "Demand will spike next week!"
   - Tell Farmer only: "Crop failure - you can only deliver 50% this round"
   - Observe how information asymmetry creates panic

7. **Role Rotation**
   - In second game, players switch roles
   - Builds empathy, reduces blame ("Now I understand what Farmer was facing!")

### 🎨 Make it Visual

8. **Use the GameMaster Dashboard Effectively**
   - Project real-time supply chain state during debrief
   - Show graphs of inventory, orders, costs over time
   - Visual data makes patterns undeniable

9. **Draw System Diagrams**
   - Map the supply chain on whiteboard during debrief
   - Show feedback loops and delays
   - Illustrate how one player's order becomes another's demand signal

### 🧑‍🏫 Facilitation Techniques

10. **Ask, Don't Tell**
    - Use Socratic questioning: "Why did you order 20 units when demand was 4?"
    - Let players discover insights: "What pattern do you notice in the orders upstream?"
    - Facilitate peer learning: "Farmer, explain to Retailer what you experienced."

11. **Normalize the Struggle**
    - "This happens to executives at Fortune 500 companies too."
    - "MIT students get the same results you just got."
    - Frame as universal system design problem, not personal failure

12. **Connect to Theory (After Experience)**
    - Introduce **Systems Thinking** concepts (feedback loops, delays, non-linearity)
    - Explain **Forrester's work** on system dynamics at MIT
    - Reference **Supply Chain Management** research on bullwhip mitigation

---

## Common Mistakes to Avoid

### ❌ Before the Game

1. **Not allocating enough time** - Especially for debrief (most important part!)
2. **Skipping practice rounds** - Players confused about mechanics won't learn concepts
3. **Not testing technology** - Technical issues destroy learning flow
4. **Explaining the bullwhip effect upfront** - Ruins the discovery experience

### ❌ During the Game

5. **Giving hints or advice** - Destroys experiential learning
6. **Allowing communication** - Defeats the purpose of experiencing information silos
7. **Rushing through rounds** - Early rounds need slow pace for understanding
8. **Intervening when chaos emerges** - The chaos IS the learning!
9. **Not observing player behavior** - Miss valuable teaching moments for debrief

### ❌ After the Game

10. **Skipping or rushing debrief** - Without reflection, it's just frustrating
11. **Blaming players** - Misses the point that structure creates behavior
12. **Not showing system-wide data** - Players need to see full supply chain
13. **Lecturing instead of facilitating** - Let players discover, don't tell
14. **Not connecting to real world** - Learning without application is wasted

### ❌ Facilitation Errors

15. **Revealing optimal strategy too early** - Let them struggle and learn from mistakes
16. **Not creating psychological safety** - Players won't share honestly if judged
17. **Focusing only on technology** - Blockchain is a tool, not a magic solution
18. **Ignoring the human element** - Panic, blame, and emotion are core to the learning

---

## Technical Setup

### For Gamemasters - Getting Started

#### Create Your GameMaster Account
1. Navigate to the application login page
2. Click "Login" → Create new admin account (first time only)
3. Generate your 6-digit GameMaster code
4. Save this code securely - you'll use it to manage all games

#### Create a Game Session
1. Login as GameMaster
2. Click "Create Game"
3. Configure settings:
   - **Starting inventory**: 12 units (recommended)
   - **Initial orders**: 4 units
   - **Lead time**: 3 weeks (rounds)
   - **Costs**: $0.50/unit holding, $1.00/unit backorder penalty
4. Share game code with players

#### Assign Roles
Players join via the game code and select their role:
- Retailer
- Manufacturer
- Processor
- Farmer

Each player chooses their technology option (Basic, YouProvide, YouProvideWithHelp, TrustedParty, or DLT).

#### Monitor & Control
- View real-time supply chain state
- See all player inventories, orders, costs
- Control round progression
- End game when learning objectives achieved (typically 12-20 rounds)

### System Requirements
- Modern web browser (Chrome, Firefox, Safari, Edge)
- Internet connection for SignalR real-time updates
- Tablets or laptops for players
- Projector/screen for facilitator dashboard (recommended)

### For IT Administrators
See [README-DEPLOYMENT.md](README-DEPLOYMENT.md) for server deployment instructions.

---

## Quick Reference Cards

### 🎮 Game Flow (Each Round)
1. **Receive** deliveries from supplier
2. **Check** incoming orders from customer
3. **Deliver** products (reduce inventory, clear backorders)
4. **Order** new products from supplier

### 💰 Cost Structure
- **Holding cost**: $0.50 per unit in inventory per round
- **Backorder penalty**: $1.00 per unit of unmet demand per round
- **Technology costs**: Vary by option selected (see Options table)

### 🎯 Winning Strategies (Reveal Only in Debrief!)
- Order to **replace what you sold**, not to eliminate backlog
- **Track supply line** (orders placed but not yet received)
- **Smooth ordering patterns** (avoid erratic spikes)
- **Share demand information** if technology allows
- Focus on **system-wide cost**, not just individual metrics

### 🔑 Key Discussion Points
- What created the bullwhip effect?
- Why did players over-order?
- How did lead times affect decisions?
- What role did communication restrictions play?
- How does blockchain transparency help/hurt?
- What are trade-offs of different technology options?
- How does this relate to your real supply chain?

---

## Additional Resources

### Recommended Reading
- **Forrester, J.W.** (1961). *Industrial Dynamics*. MIT Press.
- **Sterman, J.D.** (1989). "Modeling Managerial Behavior: Misperceptions of Feedback in a Dynamic Decision Making Experiment." *Management Science*.
- **Lee, H.L., Padmanabhan, V., & Whang, S.** (1997). "The Bullwhip Effect in Supply Chains." *Sloan Management Review*.

### Blockchain & Supply Chain
- **Kshetri, N.** (2018). "Blockchain's roles in meeting key supply chain management objectives." *International Journal of Information Management*.
- **Saberi, S., et al.** (2019). "Blockchain technology and its relationships to sustainable supply chain management." *International Journal of Production Research*.

### Videos & Simulations
- Search YouTube for "MIT Beer Game" for classic demonstrations
- Explore system dynamics simulations at MIT Sloan's System Dynamics Group

---

## Support & Contribution

### For Technical Issues
- Check application logs for errors
- Verify all services are running (see deployment guide)
- Ensure database connectivity

### For Pedagogical Questions
- Refer to classic Beer Game literature
- Connect with system dynamics community
- Experiment with different facilitation approaches

### Repository Information
- **GitHub**: [blockchain-demonstrator-serious-game](https://github.com/Hogeschool-Windesheim/blockchain-demonstrator-serious-game)
- **Deployment Guide**: [README-DEPLOYMENT.md](README-DEPLOYMENT.md)
- **License**: Check repository for license details

---

## Final Facilitator Reminder

> **The game is not about winning. It's about learning.**
>
> The most valuable outcomes are:
> - Understanding system structure creates behavior
> - Recognizing information asymmetry drives dysfunction
> - Seeing how blockchain enables trust-minimized coordination
> - Applying systems thinking to real-world supply chains
>
> **Your role as gamemaster**: Create a safe space for players to struggle, fail, reflect, and discover insights they'll carry into their professional lives.

**Good luck, and enjoy facilitating this powerful learning experience!** 🍺📊⛓️
