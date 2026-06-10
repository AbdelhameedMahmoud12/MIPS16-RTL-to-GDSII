# Front-End Design: Watch Controller FSM

## Goal of this Module
The goal of the **Front-End Design** module is to implement the complete digital logic design and Register-Transfer Level (RTL) modeling for a **hh:mm 4-digit 24-hour format digital watch controller**. Designed from scratch in behavioral Verilog, this block implements mode switching, clock time-keeping, user alarm configuration, stopwatch timing (with lap freezing), and user setting configurations using a highly optimized, resource-constrained two-button interface.

---

## 1. User Interface & Problem Analysis

Digital watch architectures traditionally utilize three or more physical buttons for control. However, the constraints of this design require implementing all operations using **exactly two push-buttons**: `mode` and `set`.

### 1.1 Multi-Cycle Button Glitches & Edge Detection
When a user presses a physical button, the voltage level remains HIGH for thousands of system clock cycles. To prevent unintended multiple counts in counters or rapid FSM transitions:
*   **Solution:** A **Pulse Generator** (`PULSE_GEN.v`) detects the rising edge of each button press (`lvl_sig` transitions `LOW -> HIGH`) and generates a clean active-high pulse (`pulse_sig`) that is exactly **one clock cycle wide**, regardless of how long the button is held down.

### 1.2 Two-Button Combined Command Interface (`mode_set`)
To implement digit selection, split timing, and reset capabilities with only two buttons, the design features a virtual third input, `mode_set` (internally referred to as `Both` or `mode_set`):
*   **Logic:** Created by passing the pulsed outputs of the two buttons through a combinational AND block (`AND.v`).
*   **Behavior:** Triggered when the user presses both buttons simultaneously. It is used to advance between digits during setting modes, activate stopwatch lap freezing, and clear the stopwatch.

### 1.3 Measuring a Real Second (`Second_Detector.v`)
To measure accurate time relative to the system clock:
*   **Logic:** A frequency divider / second detector counts clock cycles up to `CLOCK_FREQ_HZ - 1` and asserts a single-cycle tick (`sec_pulse`) exactly once per second. For example, with a system clock of 50 Hz, the counter counts 50 cycles to yield a 1-second reference tick.

### 1.4 Digit Select Indicators (`load_en_min_1`, etc.)
To give the user visual feedback on which digit is currently selected for adjustment:
*   **Logic:** Active-high outputs `load_en_min_1`, `load_en_min_2`, `load_en_hr_1`, and `load_en_hr_2` are routed from the active setting block to drive display indicators (e.g., a cursor, underline, or flashing digit) under the digit currently being changed.

---

## 2. Finite State Machine (FSM) Architectures

The front-end design is controlled by three distinct, cascading Finite State Machines. To prevent clock domain crossing hazards and transition glitching, all FSM state registers use **Gray Code encoding**.

### 2.1 Main System Controller FSM (`Sys_ctrl.v`)
The central system FSM manages the overall watch operating modes.
*   **State Encodings:**
    *   `normal` (`2'b00`): Standard time display mode.
    *   `set_alarm` (`2'b01`): Alarm programming and activation mode.
    *   `set_time` (`2'b10`): Clock time adjustment mode.
    *   `stop_watch` (`2'b11`): Stopwatch tracking mode.
*   **State Transitions:**
    *   Transitions occur sequentially on `mode_pulse` (provided `set` is not pressed to avoid button combination collision).
    *   Depending on the active state, `Sys_ctrl` generates block-level enables (`en_sw`, `en_st`, `en_ala`) and multiplexes the selected mode values to the final display pins.

```mermaid
stateDiagram-v2
    [*] --> normal : Reset (RST_N = 0)
    normal --> set_alarm : mode_pulse & ~set
    set_alarm --> stop_watch : mode_pulse & ~set
    stop_watch --> set_time : mode_pulse & ~set
    set_time --> normal : mode_pulse & ~set

    state normal {
        Note right of normal: Display time_keeper values\nAll adjust modules disabled
    }
    state set_alarm {
        Note right of set_alarm: Enable Alarm_set block\nAssert en_ala
    }
    state stop_watch {
        Note right of stop_watch: Enable stopwatch block\nAssert en_sw
    }
    state set_time {
        Note right of set_time: Enable Set_time block\nAssert en_st
    }
```

### 2.2 Time-Setting FSM (`Set_time.v`)
Governs which digit is active for user incrementing when `en_st` is asserted by the main FSM.
*   **State Encodings (Gray Code):**
    *   `Ideal` (`3'b000`): Display normal time, waiting for input.
    *   `H2` (`3'b001`): Adjusting Hours Tens digit ($0 \rightarrow 2$).
    *   `H1` (`3'b011`): Adjusting Hours Ones digit ($0 \rightarrow 9$, or $0 \rightarrow 3$ if H2 is 2).
    *   `M2` (`3'b010`): Adjusting Minutes Tens digit ($0 \rightarrow 5$).
    *   `M1` (`3'b110`): Adjusting Minutes Ones digit ($0 \rightarrow 9$).
*   **Transition Condition:** Pressing both buttons (`Both` / `mode_set`) cycles the state to the next digit. If `En` goes low (user exits mode), the FSM immediately returns to `Ideal`.

### 2.3 Alarm-Setting FSM (`Alarm_set.v`)
Controls alarm programming and activation/deactivation.
*   **State Encodings (Gray Code):**
    *   `Ideal` (`3'b000`): Waiting state.
    *   `Alarm_act` (`3'b001`): Alarm status toggle state (press `Set` to activate/deactivate sound flag).
    *   `H2` (`3'b011`): Adjusting Alarm Hours Tens digit.
    *   `H1` (`3'b010`): Adjusting Alarm Hours Ones digit.
    *   `M2` (`3'b110`): Adjusting Alarm Minutes Tens digit.
    *   `M1` (`3'b111`): Adjusting Alarm Minutes Ones digit.
*   **Transition Condition:** If `En && Set && ~Both`, transitions to `Alarm_act` to toggle alarm status. If `En && Both`, cycles through digit adjustment states (`H2 -> H1 -> M2 -> M1`).

---

## 3. RTL Module Architecture

The top-level schematic [SYS_TOP.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/SYS_TOP.v) instantiates the following submodules:

*   **[PULSE_GEN.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/PULSE_GEN.v):** Rising-edge level detectors using a D-flip flop pipeline and combinational gate logic: `assign pulse_sig = rcv_flop && !pls_flop`.
*   **[AND.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/AND.v):** Generates `mode_set` signal from pulsed inputs.
*   **[Sys_ctrl.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/Sys_ctrl.v):** The primary system FSM router and multiplexer.
*   **[time_keeper.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/time_keeper.v):** Integrates the `Second_Detector` and cascading generic `mod_counter` blocks to keep current time. Contains load-enable lines allowing new time data to overwrite current registers.
*   **[Set_time.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/Set_time.v):** Implements the time adjustment FSM, validating that time values remain within correct boundaries (`00` to `23` for hours, `00` to `59` for minutes).
*   **[Alarm_set.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/Alarm_set.v):** Implements the alarm configuration FSM, stores alarm BCD parameters, and generates `sound` signal when:
    `assign sound = (Hd2==no_hours_2) && (Hd1==no_hours_1) && (Md2==no_minute_2) && (Md1==no_minute_1) && sound_flag_2`
*   **[stopwatch.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/stopwatch.v):** Implements stopwatch tracking in MM:SS format. Uses latched output registers (`Sec1_latch`, etc.) to implement split (lap) display freezing while count counters continue running in the background.
*   **[mod_counter.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/mod_counter.v) & [mod_counter_sw.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/mod_counter_sw.v):** Generic counters used for building frequency dividers and BCD digits.
*   **[counter_hours.v](file:///d:/5%20th%20year/repo/01_Frontend_Design/rtl/counter_hours.v):** Handles custom base-24 counting for hours.

---

## 4. Top-Level Ports & Signal Descriptions

| Port | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| **CLK** | Input | 1 | Master clock signal. |
| **RST_N** | Input | 1 | Asynchronous active-low reset. |
| **mode** | Input | 1 | Level input from physical mode select button. |
| **set** | Input | 1 | Level input from physical value adjust button. |
| **hours_2** | Output | 4 | Display Hours Tens digit (BCD). |
| **hours_1** | Output | 4 | Display Hours Ones digit (BCD). |
| **minute_2** | Output | 4 | Display Minutes Tens digit (BCD). |
| **minute_1** | Output | 4 | Display Minutes Ones digit (BCD). |
| **Split_ind**| Output | 1 | Active when stopwatch split/lap mode is display-frozen. |
| **sound** | Output | 1 | Alarm sound output (asserts when alarm matches time keeper). |
| **load_en_hr_2** | Output | 1 | Digit selector indicator for Hours Tens digit. |
| **load_en_hr_1** | Output | 1 | Digit selector indicator for Hours Ones digit. |
| **load_en_min_2**| Output | 1 | Digit selector indicator for Minutes Tens digit. |
| **load_en_min_1**| Output | 1 | Digit selector indicator for Minutes Ones digit. |

---

## 5. Front-End RTL Verification Results

*   **Compilation:** Fully validated under ModelSim compiler. No design compilation warnings or register-latch inferences.
*   **Rollover Correctness:** Cascaded counters transition correctly (e.g. `23:59 -> 00:00` rollover takes exactly one clock cycle with zero delay skew).
*   **Glitch Avoidance:** Gray-coded FSM state transitions demonstrate clean state decoding in behavioral simulations.

---

## 6. Team & Mentorship Acknowledgements

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
