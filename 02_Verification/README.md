# Verification Suite: Watch Controller FSM

## Goal of this Module
The goal of the **Verification Suite** is to prove the functional correctness of the Watch Controller FSM design. Using a hierarchical testing strategy, the verification suite isolates individual submodules for unit testing and integrates them into a top-level automated system testbench. The testbench simulates real-world user interactions (button press sequences) and validates display rolls, alarm triggers, and stopwatch split operations, verifying the design's reliability before physical synthesis.

---

## 1. Verification Strategy

The design is verified using a two-tier approach:
1.  **Unit-Level Verification:** Dedicated testbenches verify the boundary logic and internal states of individual submodules (`Alarm_set_tb.v`, `Set_time_tb.v`, `tb_stopwatch.sv`, `time_keeper_tb.v`).
2.  **Top-Level Integration Verification:** An automated system-level testbench (`SYS_TOP_TB.v`) instantiates the full `SYS_TOP` block. It operates at a simulation clock frequency of **2 Hz** (for wave readability) and applies a structured sequence of stimulus actions on a negative clock edge, verifying outputs at the subsequent negative edge.

---

## 2. Testbench Architecture & Automated Tasks

The system testbench leverages **reusable verification tasks** to generate clean stimuli and perform automated checks.

*   `apply_reset()`: Drives the asynchronous `RST_N` low for 5 clock cycles, releasing it to verify initial states.
*   `tick(integer n)`: Advances the clock simulation. Used to simulate real-time seconds (`n=1`) or minutes (`n=60`).
*   `pulse_mode()`, `pulse_set()`, `pulse_both()`: Simulates physical button presses. Generates a pulse that transitions `LOW -> HIGH -> LOW` over exactly one clock cycle.
*   `check_time(expected_hours, expected_minutes)`: Reads BCD outputs `hours_2`, `hours_1`, `minute_2`, `minute_1`, packs them into integers, and compares them with expected results. Logs `PASS` or `FAIL` with mismatch logs.
*   `check_alarm(expected_sound)`: Checks if the `sound` output asserts high only when the current time matches the stored alarm time and the alarm is activated.

---

## 3. Unit Test Specifications

### 3.1 Normal Timekeeping Mode (`time_keeper_tb.v`)
Validates standard timekeeping, carries, and roll-overs.

*   **Test Items (TIs):**
    *   `TI-TK-01`: Verify seconds rollover (59 $\rightarrow$ 00) increments minutes.
    *   `TI-TK-02`: Verify minutes rollover (59 $\rightarrow$ 00) increments hours.
    *   `TI-TK-03`: Verify full day rollover (`23:59:59` $\rightarrow$ `00:00:00`).
    *   `TI-TK-04`: Verify load-enable inputs propagate arbitrary valid times directly.
    *   `TI-TK-05`: Verify asynchronous reset immediately forces all outputs to zero.
*   **Test Cases (TCs):**
    *   `TC-TK-001` (Seconds Rollover): Load `00:00:59`. Allow tick. Verifies transition to `00:01:00`.
    *   `TC-TK-002` (Minutes Rollover): Load `00:59:59`. Verifies transition to `01:00:00`.
    *   `TC-TK-003` (Day Rollover): Load `23:59:59`. Verifies transition to `00:00:00`.
    *   `TC-TK-004` (Time Load): Assert `load_en` lines with `12:34`. Verifies display reads `12:34`.

### 3.2 Time Setting Mode (`Set_time_tb.v`)
Validates user adjustments of digits and limit checks.

*   **Test Items (TIs):**
    *   `TI-ST-01`: Verify reset behavior loads current clock time.
    *   `TI-ST-02`: Verify time adjustment is locked unless `En` is active.
    *   `TI-ST-03`: Verify both buttons (`mode_set` / `Both`) cycle selection through digits (`H2 -> H1 -> M2 -> M1`).
    *   `TI-ST-04`: Verify `Set` increments the selected digit and wraps at limits ($24$ for hours, $60$ for minutes).
    *   `TI-ST-07`: Verify digit load-enable indicators assert only for the active selected digit.
*   **Test Cases (TCs):**
    *   `TC-ST-001` (Reset): Apply reset in Set Time mode. Stored values load normal clock time.
    *   `TC-ST-002` (En Lock): Try to set time when `En = 0`. Display values must not change.
    *   `TC-ST-003` (Chained Digit Increment): Select H2, press set (increments $0 \rightarrow 1$), select H1, press set, select M2, press set, select M1, press set. Verify outputs match the edited time.

### 3.3 Stopwatch Mode (`tb_stopwatch.sv`)
Validates split-time freezing, counting, and clearing logic.

*   **Test Items (TIs):**
    *   `TI-SW-01`: Verify reset clears stopwatch to `00:00`.
    *   `TI-SW-02`: Verify stopwatch increments only when running is active.
    *   `TI-SW-03`: Verify `start_pause` toggles running and halts/resumes count cleanly.
    *   `TI-SW-04`: Verify `split_req` freezes displayed values while internal counters run in the background.
    *   `TI-SW-05`: Verify stopwatch clears to `00:00` only when paused and split is pressed.
*   **Test Cases (TCs):**
    *   `TC-SW-001` (Reset): Initial reset check. Stopwatch reads `00:00`.
    *   `TC-SW-003` (Pause & Resume): Run stopwatch, pause at `00:02`, wait, resume. Check if timer continues from `00:02`.
    *   `TC-SW-006` (Split Freeze): Start timer. Activate split at `01:05`. Wait 5 seconds. Display remains frozen at `01:05`. De-activate split. Display immediately catches up to `01:10`.

### 3.4 Alarm Mode (`Alarm_set_tb.v`)
Validates alarm time configuration, enabling/disabling, and sound output assertions.

*   **Test Items (TIs):**
    *   `TI-AS-01`: Verify reset clears alarm time and disables activation status.
    *   `TI-AS-02`: Verify pressing `Set` toggles alarm activation state (ON/OFF).
    *   `TI-AS-05`: Verify `sound` asserts high when current time matches alarm time and alarm is enabled.
    *   `TI-AS-06`: Verify `sound` remains low when current time matches alarm time but alarm is disabled.
*   **Test Cases (TCs):**
    *   `TC-AS-005` (Alarm Trigger): Set alarm to `15:05`. Enable alarm. Advance timekeeper to `15:05`. Verify `sound` transitions `0 -> 1`.
    *   `TC-AS-006` (Disabled Match): Match timekeeper with alarm time `15:05` when alarm is disabled. Verify `sound` remains `0`.

---

## 4. How to Run Simulation

The verification scripts are configured for **ModelSim**.

1.  Open ModelSim and change directory to the simulation folder:
    ```tcl
    cd 02_Verification/simulations/
    ```
2.  Compile the design library and load the source files by running the ModelSim macro:
    ```tcl
    do do_file.do
    ```
3.  Configure the wave layout formatting:
    ```tcl
    do wave.do
    ```
4.  Run the testbench:
    ```tcl
    run -all
    ```
5.  Check the transcript window for self-checking verification status reports:
    `--- ALL TEST SCENARIOS PASSED ---`

---

## 5. Team & Mentorship Acknowledgements

### Team Members
* **Abdelhameed Mahmoud Sayed**  — [Linked In](https://www.linkedin.com/in/abdelhameed-mahmoud-25097623b/)
* **Mark Maher Eweida**  — [E-mail](mailto:21P0355@eng.asu.edu.eg)
* **Abdullah Ahmed Youssef**  — [Linked In](https://www.linkedin.com/in/abdullah-shaheen-491300266/)

### Academic Advisor
**Dr. Diaa El-Din**
This work was completed under the supervision and guidance of Dr. Diaa El-Din, whose support and technical feedback were invaluable throughout the project.

### Teaching Assistant
**Eng. Abdelrahman Tamer**
Special thanks to Eng. Abdelrahman Tamer for his continuous assistance, technical guidance, and support during the implementation and evaluation phases of the project.
