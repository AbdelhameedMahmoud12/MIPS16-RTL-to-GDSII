# Physical Design: MIPS16 Processor Flow

## Goal of this Module
The goal of the **Physical Design** module is to implement the complete back-end physical implementation (synthesis and Place-and-Route) for a **16-bit MIPS Processor Core**. Starting from behavioral RTL, this block applies standard ASIC flow stages using Synopsys Design Compiler and IC Compiler to synthesize, floorplan, place, route, and sign off a silicon-ready **Nangate 45nm standard cell layout**. The final design meets strict fabrication constraints, achieving zero DRC violations and closing timing at **400 MHz** within a strict area budget.

---

## 1. Timing & Design Constraints

The timing and physical environments are configured in the Design Constraints file ([cons.tcl](file:///d:/5%20th%20year/repo/03_Physical_Design/scripts/cons.tcl)):
*   **Operating Corner:** NangateOpenCellLibrary worst-case SS corner ($V_{DD} = 0.95\text{V}$, Temperature = $125^\circ\text{C}$).
*   **Clock Target:** Clock period of **2.50 ns** (Target Frequency: **400 MHz**).
*   **Interface Delays:** Input and Output delays capped at a maximum of **0.2 ns** relative to the clock.
*   **Clock Uncertainty:** Configured to **0.1 ns** to provide guardband for clock tree skew and clock jitter.
*   **Boundary Conditions:** Boundary hold checks are disabled (`set_false_path -hold`) to prevent the optimizer from inserting unrealistic delay buffers on input/output ports, focusing hold closure entirely on internal sequential paths.

---

## 2. ASIC Physical Design Implementation Flow

### 2.1 Logic Synthesis (`syn.tcl` & `cons.tcl`)
RTL synthesis translates Verilog descriptions into a gate-level structural netlist.
*   **Tool:** Synopsys Design Compiler.
*   **Optimization Effort:** Executed via `compile -area_effort high -map_effort high` to map RTL to standard cells. The high effort parameters enable deep technology mapping search trees to minimize design area and optimize slack.
*   **Sign-Off Outputs:** The structural gate-level netlist ([mips_16.v](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16.v)) and Synopsys Design Constraints ([mips_16.sdc](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16.sdc)).

### 2.2 Design Setup & TLU+ Parasitics (`open_stage.tcl`)
*   **Database:** A Milkyway design library is created utilizing the technology file `FreePDK45_10m.tf` and standard cell reference libraries.
*   **Parasitic Modeling:** Loaded TLU+ max (`FreePDK45_10m_Cmax.tlup`) and min (`FreePDK45_10m_Cmin.tlup`) lookup tables with the mapping file `FreePDK45_10m.map` to enable accurate parasitic RC extraction and interconnect delay estimation during Place & Route.

### 2.3 Floorplanning
*   **Core Utilization:** Set to **45%** (0.45) to provide a balance between packing cells tightly (reducing routing wire lengths) and leaving enough whitespace to prevent routing congestion.
*   **Alternate Row Flipping:** Alternating cell rows are flipped (`-flip_first_row`) to share power and ground rails between adjacent cell rows, saving layout area.
*   **I/O to Core Boundary Spacing:** Spaced at **12.4 $\mu m$** on all sides to reserve wiring channels for the power distribution rings and routing access.
*   **Routing Layers:** Restricted routing to a maximum layer of **Metal 6** (`metal6`) to reserve upper thick metals (Metal 7 - Metal 10) for low-resistance power distribution.

### 2.4 Power Planning & Power Grid Synthesis (PDN)
*   **Logical Connections:** Connections are derived via `derive_pg_connection` for $V_{DD}$ and $V_{SS}$ nets.
*   **Power Ring:** Created concentric power rings on `metal7`/`metal9` (horizontal) and `metal8`/`metal10` (vertical) with a width of **5 $\mu m$** and spacing of **0.8 $\mu m$**.
*   **Power Mesh Straps:** Multi-layer grid straps added vertically and horizontally on layers `metal6` through `metal10` to distribute current evenly.
*   **Uniform Virtual PG Pads:** To prevent IR-drop hotspots and uneven current entry, virtual power and ground pads were distributed uniformly around the chip boundary (top, bottom, left, right). The PDN was synthesized under a **2% maximum voltage drop** target (budget: 500 mW, supply: 1.1V).
*   **Well Biasing:** Inserted stagger-pattern Tap Cells (`TAP`) every **30 $\mu m$** along the cell rows to tie N-wells to $V_{DD}$ and P-substrates to $V_{SS}$, preventing latch-up.

### 2.5 Cell Placement & Optimization
*   **Optimization:** Conducted via `place_opt -area_recovery` followed by incremental physical synthesis `psynopt` to legalization cells and recover whitespace area.
*   **Tie Cells:** Instantiated tie-low (`LOGIC0_X1`) and tie-high (`LOGIC1_X1`) cells to connect constant logic pins (1'b0 and 1'b1), protecting transistor gates from electrostatic discharge (ESD).

### 2.6 Clock Tree Synthesis (CTS)
*   **CTS Driving Cell:** Bounded using a high-drive buffer (`BUF_X16`) at the clock root.
*   **CTS Constraints:** Skew target set to **0.5 ns**, transition target set to **0.3 ns**, max fanout limited to **10**, and max capacitance limited to **300 fF**.
*   **Non-Default Routing Rules (NDR):** Configured a custom routing rule (`my_route_rule`) utilizing **double width and double spacing** on layers `metal3`, `metal4`, and `metal5` (`widths {metal3 0.14 metal4 0.28 metal5 0.28} spacings {metal3 0.14 metal4 0.28 metal5 0.28}`) to isolate clock nets from crosstalk noise and decrease clock latency.
*   **Clock Tree Buffering:** Clock nets were routed using dedicated low-skew clock buffers (`CLKBUF_*`).

### 2.7 Routing & Post-Route ECO Timing Fixes
*   **Routing Engine:** Performed timing-driven global and detailed routing using Zroute.
*   **Signal Integrity:** Enabled crosstalk prevention (`-route_xtalk_prevention true`) and delta delay computation to eliminate SI delays.
*   **Hold Violations Fixing:** Fixed clock hold violations incrementally by inserting small buffers (`BUF_X1`, `BUF_X2`) in short paths.
*   **Engineering Change Order (ECO) DRC Fix:** Post-routing verification detected a single DRC violation where a signal wire cut through a power rail sheet. 
    *   *Solution:* The violating wire segment was removed and cleaned using open-net-driven eco routing: `route_zrt_eco -open_net_driven true`.

### 2.8 Design Finishing & Sign-Off
*   **Filler Cells:** Inserted standard filler cells (`FILLCELL_X32`, `FILLCELL_X16`, etc.) to establish well continuity and meet PDK density rules.
*   **Redundant Vias:** Inserted redundant vias to increase via reliability and manufacturing yield, achieving a **95.47% redundant via conversion rate** (172,163 out of 180,323 vias).
*   **Layout Sign-Off:** Exported the final layout stream GDSII ([mips_16.gds](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16.gds)), parasitic SPEF files ([mips_16.spef.max](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16.spef.max)), and structural Verilog netlists ([mips_16_icc.v](file:///d:/5%20th%20year/repo/03_Physical_Design/layouts/mips_16_icc.v) with PG rails).

---

## 3. Floorplan Optimization Trials (Iterative Area Reduction)

To satisfy the area constraint of $\le 100,000 \mu m^2$, multiple design iterations were conducted:

1.  **Trial 1 (Timing-Focused):** Standard floorplan focused strictly on closing timing. Frequency met (400 MHz), but chip area reached **166,000 $\mu m^2$** (Failed area constraint).
2.  **Trial 2 (Low Utilization):** Tried constraining utilization to **25%** with a smaller core boundary. Did not converge to a legal layout under the area limit.
3.  **Trial 3 (Medium Utilization):** Utilization increased to **36%**. Noticeable area reduction achieved, but still exceeded the limit.
4.  **Trial 4 (Final Core Re-dimensioning):** Set core utilization to **45%** and adjusted the I/O-to-core boundary to 12.4 $\mu m$. This successfully shrank the total chip area to **95,308 $\mu m^2$** while maintaining timing closure.

---

## 4. Final Sign-Off Physical Metrics

The final results from synthesis and Place-and-Route reports are summarized below:

| Requirement / Spec | Target Constraint | Achieved PNR Metric | Status |
| :--- | :---: | :---: | :---: |
| **Chip Footprint Area** | $\le 100,000 \mu m^2$ | **95,308.04 $\mu m^2$** | **PASS** |
| **Clock Frequency** | $\ge 400 \text{ MHz}$ | **400 MHz** (Clock Period = 2.50 ns) | **PASS** |
| **Setup Slack (Max Delay)** | Clean ($\ge 0$) | **+1.80 ns** (MET) | **PASS** |
| **Hold Slack (Min Delay)** | Clean ($\ge 0$) | **+0.00 ns** (MET) | **PASS** |
| **DRC Violations** | 0 | **0 violations** (Clean routing) | **PASS** |
| **LVS Net Connectivity** | Clean | **0 open nets, 0 shorts** | **PASS** |
| **Area-Delay Product** | Minimize | **238.27 $\mu m^2$/MHz** | **PASS** |
| **Total Wire Length** | - | **363,743 $\mu m$** | - |
| **Total Vias / Contacts**| - | **180,323** (95.47% redundant via rate) | - |

### Timing Analysis:
*   **Setup Slack (+1.80 ns):** The large setup margin demonstrates that the MIPS16 core has significant timing headroom and could be clocked at higher frequencies (up to ~600 MHz theoretically).
*   **Hold Slack (+0.00 ns):** Reflects a zero-margin timing pass. This is typical for highly optimized designs where delay buffers are inserted incrementally to satisfy hold timing without increasing area.

---

## 5. Team & Mentorship Acknowledgements

### Team Members
*   **Mark Maher Eweida** (ID: 21P0355) — [21P0355@eng.asu.edu.eg](mailto:21P0355@eng.asu.edu.eg)
*   **Abdelhameed Mahmoud Sayed** (ID: 21P0171) — [21P0171@eng.asu.edu.eg](mailto:21P0171@eng.asu.edu.eg)
*   **Abdullah Ahmed Youssef** (ID: 2100369) — [2100369@eng.asu.edu.eg](mailto:2100369@eng.asu.edu.eg)

### Academic Advisor
**Dr. Diaa El-Din**
This work was completed under the supervision and guidance of Dr. Diaa El-Din, whose support and technical feedback were invaluable throughout the project.

### Teaching Assistant
**Eng. Abdelrahman Tamer**
Special thanks to Eng. Abdelrahman Tamer for his continuous assistance, technical guidance, and support during the implementation and evaluation phases of the project.
