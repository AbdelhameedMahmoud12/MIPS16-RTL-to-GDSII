# Physical Design: MIPS16 Processor Flow

This subdirectory contains the logic synthesis and physical design implementation flow of a **16-bit MIPS Processor Core** using Synopsys tools and the Nangate 45nm standard cell library.

---

## 1. Design Constraints

The timing, area, and environmental constraints were defined in [cons.tcl](file:///d:/5%20th%20year/repo/03_Physical_Design/scripts/cons.tcl):
*   **Operating Corner:** Worst-case (SS, 0.95V, 125°C).
*   **Clock Period:** Target of **2.50 ns** (corresponding to **400 MHz**).
*   **Input/Output Delays:** Configured at 0.2 ns external delay.
*   **Clock Uncertainty:** Set to 0.1 ns to account for clock skew and jitter.
*   **Max Transition/Capacitance:** Governed by cell library defaults.

---

## 2. Logic Synthesis

Logic synthesis was executed using **Synopsys Design Compiler** ([syn.tcl](file:///d:/5%20th%20year/repo/03_Physical_Design/scripts/syn.tcl)):
*   **Methodology:** Read RTL, applied constraints, compiled with high area/map effort, and generated structural gate-level netlists.
*   **Outputs:** Netlist ([mips_16.v](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16.v)) and constraint settings ([mips_16.sdc](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16.sdc)).

---

## 3. Floorplanning

Floorplanning defines the boundary parameters of the chip core and pad placement:
*   **Total Chip Footprint Area:** **95,308 $\mu m^2$** (satisfies the spec constraint of $\le 100,000 \mu m^2$).
*   **Core Utilization Target:** 50% non-fixed utilization for initial placement.
*   **Row Configuration:** Configured standard cell rows matching PDK height rules.

---

## 4. Power Planning

Power planning establishes the power distribution network (PDN) supplying power ($V_{DD}$) and ground ($V_{SS}$) to all logic cells:
*   **Structure:** Standard cell power rails, ring structures around the core, and vertical/horizontal PG straps.
*   **Snapshots:** Layout of virtual power and ground pads is illustrated below:

![Power Grid Network Layout](file:///d:/5%20th%20year/repo/03_Physical_Design/screenshots/virtual%20PG%20pads.png)

---

## 5. Cell Placement

Placement assigns coordinates to standard cell instances:
*   **Instance Count:** **72,330 placed cell instances** (70,280 logical + physical padding).
*   **Optimization:** Logic optimization was conducted under placement congestion checks to ensure routing legality.

---

## 6. Clock Tree Synthesis (CTS)

CTS builds the clock tree buffer network to distribute the clock signal synchronously with low skew:
*   **Clock Trees Built:** Multi-stage buffer tree routed on upper metal layers to minimize RC delays.
*   **Results:** Verified clock skew and balanced latency across all register endpoints.

---

## 7. Routing

Routing executes physical wiring using IC Compiler’s Zroute tool:
*   **Metal Layers Used:** Routed on Metal 1 through Metal 6 (Nangate 45nm stack).
*   **Optimizations:** Standard cell filler cells (without metal) were inserted post-route to maintain well continuity.
*   **Snaps:** Below is the final placed and routed layout plot of the core:

![Design Layout Plot](file:///d:/5%20th%20year/repo/03_Physical_Design/screenshots/chip.png)

---

## 8. Timing Closure

Setup and hold timing checks were validated post-route using parasitic extraction (.SPEF annotation):
*   **Setup Timing (Max Delay):** Fully closed at **400 MHz**.
    *   **Required Time:** 2.54 ns | **Arrival Time:** 0.74 ns | **Setup Slack (MET):** **1.80 ns** (detailed in [setup.rpt](file:///d:/5%20th%20year/repo/03_Physical_Design/reports/setup.rpt)).
*   **Hold Timing (Min Delay):** Fully closed.
    *   **Hold Slack (MET):** **0.00 ns** after automated eco buffer insertion (detailed in [hold.rpt](file:///d:/5%20th%20year/repo/03_Physical_Design/reports/hold.rpt)).

---

## 9. Design Rule Check (DRC) Verification

Physical sign-off checks verify that the layout complies with silicon foundry design rules:
*   **DRC Violations:** **0 DRC violations** detected.
*   **Routing Status:** **0 open nets** and zero shorts (detailed in [DRC.rpt](file:///d:/5%20th%20year/repo/03_Physical_Design/reports/DRC.rpt)).

---

## 10. Final Results

The physical layout flow successfully output the silicon-ready stream files:
*   **GDSII File:** [mips_16.gds](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16.gds) (31.5 MB binary layout).
*   **Structural Netlist:** [mips_16_icc.v](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16_icc.v) (netlist containing PG supply lines).

---

## 11. Team Members

*   **Abdelhamed Mahmoud** (Physical Design and ASIC Flow Implementation Lead)

---

## 12. Advisor

### Academic Advisor
**Dr. Diaa El-Din**

This work was completed under the supervision and guidance of Dr. Diaa El-Din, whose support and technical feedback were invaluable throughout the project.

---

## 13. Acknowledgements

Special thanks to **Eng. Abdelrahman Tamer** (Teaching Assistant) for his guidance, standard cell PDK support, and timing closure reviews during the IC Compiler physical implementation phases.
