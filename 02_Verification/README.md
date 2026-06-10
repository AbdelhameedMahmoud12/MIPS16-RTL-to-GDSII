# Verification Suite: Watch Controller FSM

This subdirectory contains the verification suite used to validate the functional correctness of the 4-digit watch controller FSM design.

---

## 1. Verification Strategy

The verification strategy uses **automated top-level simulation** combined with **unit-level module testing**:
*   **Unit Verification:** Isolated testbenches (`Alarm_set_tb.v`, `Set_time_tb.v`, `tb_stopwatch.sv`, `time_keeper_tb.v`) check corner cases for each block.
*   **System Integration Verification:** The top-level testbench (`SYS_TOP_TB.v`) runs a complete, sequential simulation protocol mimicking real user interactions (button press sequences) to verify FSM transitions and integration.

---

## 2. Testbench Architecture

The top-level testbench ([SYS_TOP_TB.v](file:///d:/5%20th%20year/repo/02_Verification/testbench/SYS_TOP_TB.v)) isolates and verifies the `SYS_TOP` wrapper.

```
+-------------------------------------------------------------+
|                         SYS_TOP_TB                          |
|                                                             |
|   +---------------------+                                   |
|   | Stimulus Generator  +----+                              |
|   | (Clock, Reset,      |    |                              |
|   |  Button sequences)  |    v                              |
|   +---------------------+  +-----------------+              |
|                            |                 |              |
|   +---------------------+  |     SYS_TOP     |              |
|   | Automated Monitors  |  |  (Device Under  |              |
|   | (Display checks,    |<--+     Test)      |              |
|   |  Sound check)       |  |                 |              |
|   +---------------------+  +-----------------+              |
+-------------------------------------------------------------+
```

*   **Stimulus Generator:** Mimics user behavior by pulsing `mode` and `set` lines at specified clock boundaries.
*   **Automated Monitors:** Continuously samples output wires (`hours_1/2`, `minute_1/2`, `sound`) and prints verification messages to the simulation console (transcript).

---

## 3. Test Scenarios

The main test sequence executes the following operations:

### Scenario 1: Initial Reset Verification
*   **Stimulus:** Assert `RST_N` low for 5 clock cycles, then de-assert.
*   **Expected Behavior:** All display outputs (`hours_1/2`, `minute_1/2`) must initialize to zero immediately.

### Scenario 2: Set Time Verification
*   **Stimulus:** Enter Time-Setting mode using the `mode` button, use `set` to increment digit values, and press both buttons (`mode_set` combinational trigger) to advance digit select. Set time to `14:35`.
*   **Expected Behavior:** The internal timekeeper updates its starting time to `14:35`.

### Scenario 3: Timekeeper Roll-over Verification
*   **Stimulus:** Run simulation past clock boundaries.
*   **Expected Behavior:** Verify rollover logic: `14:59 -> 15:00` and `23:59 -> 00:00`.

### Scenario 4: Alarm Set & Trigger Verification
*   **Stimulus:** Enter Alarm-Setting mode, configure alarm time to `15:05`, enable the alarm sound flag, and return to normal mode. Run timekeeper to `15:05`.
*   **Expected Behavior:** Output wire `sound` must assert high exactly when the timekeeper matches the alarm time (`15:05`).

### Scenario 5: Stopwatch Verification
*   **Stimulus:** Enter Stopwatch mode, trigger `start` using the set button, assert `split_req` to latch display, release split, assert `pause`, and then `reset`.
*   **Expected Behavior:** Display latches split-time while the stopwatch continues counting in the background, and pauses/resets cleanly on command.

---

## 4. Automated Checking

The testbench incorporates self-checking blocks that compare the actual design outputs with expected reference variables. 
*   If a mismatch occurs, the simulator logs an `ERROR` message.
*   Upon successful completion of all test sequences, the transcript outputs a final verification report:
    `--- ALL TEST SCENARIOS PASSED ---`

---

## 5. Simulation & Waveform Analysis

Simulations were performed using ModelSim. Transcripts for each verified module are archived in the [waveforms/](file:///d:/5%20th%20year/repo/02_Verification/waveforms) folder:
*   [Transcript_system_overall](file:///d:/5%20th%20year/repo/02_Verification/waveforms/Transcript_system_overall): Shows full execution log of the top-level FSM testbench.
*   [StopWatch_Transcript](file:///d:/5%20th%20year/repo/02_Verification/waveforms/StopWatch_Transcript): Details stopwatch counters, pause, split validation.

### How to Run Simulation

1.  Open ModelSim and navigate to [simulations/](file:///d:/5%20th%20year/repo/02_Verification/simulations).
2.  Run the command file `do_file.do` to compile all design modules and testbenches:
    ```tcl
    do do_file.do
    ```
3.  Load the wave layout configurations:
    ```tcl
    do wave.do
    ```
4.  Run simulation:
    ```tcl
    run -all
    ```

---

## 6. Team Members

*   **Abdelhamed Mahmoud** (Verification Suite & Automated Testbench Lead)

---

## 7. Advisor

### Academic Advisor
**Dr. Diaa El-Din**

This work was completed under the supervision and guidance of Dr. Diaa El-Din, whose support and technical feedback were invaluable throughout the project.

---

## 8. Acknowledgements

Special thanks to **Eng. Abdelrahman Tamer** (Teaching Assistant) for his guidance in setting up the ModelSim automation and reviewing the test scenarios.
