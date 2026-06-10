`timescale 1ns / 1ps

module time_keeper_tb;

    // ==============================================
    // Parameters
    // ==============================================
    localparam CLOCK_FREQ_HZ = 10; // Speed up simulation 
    localparam CLK_PERIOD    = 20; // 50 MHz clock (20ns)

    // ==============================================
    // Signals
    // ==============================================
    reg clk;
    reg reset;

    // Load Controls 
    reg load_en_min_1, load_en_min_2;
    reg [3:0] load_val_min_1, load_val_min_2;
    reg load_en_hr_1, load_en_hr_2;
    reg [3:0] load_val_hr_1, load_val_hr_2;

    // Outputs 
    wire [3:0] o_min_1, o_min_2;
    wire [3:0] o_hr_1, o_hr_2;

    // White-box testing for seconds 
    wire [5:0] current_sec;
    assign current_sec = dut.U0_cnt_sec.count;

    //  Integer Outputs 
    wire [5:0] min_int;
    wire [4:0] hr_int;
    assign min_int = (o_min_2 * 10) + o_min_1;
    assign hr_int  = (o_hr_2 * 10) + o_hr_1;

    // Variable for timing check
    integer cycles;

    // ==============================================
    // DUT Instantiation
    // ==============================================
    time_keeper #(
        .CLOCK_FREQ_HZ(CLOCK_FREQ_HZ)
    ) dut (
        .clk(clk),
        .reset(reset),
        .load_en_min_1(load_en_min_1),
        .load_en_min_2(load_en_min_2),
        .load_val_min_1(load_val_min_1),
        .load_val_min_2(load_val_min_2),
        .load_en_hr_1(load_en_hr_1),
        .load_en_hr_2(load_en_hr_2),
        .load_val_hr_1(load_val_hr_1),
        .load_val_hr_2(load_val_hr_2),
        .o_min_1(o_min_1),
        .o_min_2(o_min_2),
        .o_hr_1(o_hr_1),
        .o_hr_2(o_hr_2)
    );

    // ==============================================
    // Clock Generation
    // ==============================================
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ==============================================
    //  Assertions
    // ==============================================
    always @(posedge clk) begin
        // Assertion 1: Range Checks
        if (current_sec >= 60) $error("[ASSERT FAIL] Seconds out of range! Value: %d", current_sec);
        if (min_int >= 60)     $error("[ASSERT FAIL] Minutes out of range! Value: %d", min_int);
        if (hr_int >= 24)      $error("[ASSERT FAIL] Hours out of range! Value: %d", hr_int);
        
        // Assertion 2: Unknown/Floating State Checks (X/Z)
        if (reset == 1) begin
             if (^o_min_1 === 1'bx || ^o_min_2 === 1'bx) $error("[ASSERT FAIL] Minutes output contains X or Z!");
             if (^o_hr_1 === 1'bx || ^o_hr_2 === 1'bx)   $error("[ASSERT FAIL] Hours output contains X or Z!");
        end
    end

    // ==============================================
    // Test Tasks
    // ==============================================
    
    task apply_reset;
        begin
            reset = 0; // Active low reset
            repeat(2) @(negedge clk); 
            reset = 1; // Release reset
            @(negedge clk);
        end
    endtask

    task load_time;
        input [4:0] h;
        input [5:0] m;
        begin
            @(negedge clk); // Sync to negedge
            // Split Hour
            load_en_hr_1 = 1; load_val_hr_1 = h % 10;
            load_en_hr_2 = 1; load_val_hr_2 = h / 10;
            // Split Minute
            load_en_min_1 = 1; load_val_min_1 = m % 10;
            load_en_min_2 = 1; load_val_min_2 = m / 10;
            
            @(negedge clk); // Hold for one clock cycle
            load_en_hr_1 = 0; load_en_hr_2 = 0;
            load_en_min_1 = 0; load_en_min_2 = 0; 
        end
    endtask

    task wait_seconds;
        input integer seconds;
        begin
            // Wait CLOCK_FREQ_HZ * seconds cycles
            repeat(seconds * CLOCK_FREQ_HZ) @(posedge clk);
			#(1);
        end

    endtask

	task check_time;
		input [4:0] exp_h;
		input [5:0] exp_m;
		input [5:0] exp_s;
		begin
			if ((hr_int !== exp_h) ||
				(min_int !== exp_m) ||
				(current_sec !== exp_s)) begin
				$error("Time mismatch detected. Expected %0d:%0d:%0d, Observed %0d:%0d:%0d",
					   exp_h, exp_m, exp_s,hr_int, min_int, current_sec);
			end
			else begin
				$display("Time check PASSED. \n Expected time = %0d:%0d:%0d,\n Current time  = %0d:%0d:%0d",
						exp_h, exp_m, exp_s,hr_int, min_int, current_sec);
			end
		end
	endtask

    // ==============================================
    // Main Test Sequence
    // ==============================================
    initial begin
        // Initialize Inputs
        reset = 0; 
        load_en_min_1  = 0;   load_en_min_2  = 0;
        load_val_min_1 = 0;   load_val_min_2 = 0;
        load_en_hr_1   = 0;   load_en_hr_2   = 0;
        load_val_hr_1  = 0;   load_val_hr_2  = 0;

        $display("___________________________________________________");
        $display("~~~~~~~~~Starting Time_Keeper Verification~~~~~~~~~");
        $display("___________________________________________________");

        // Release Reset
        #(CLK_PERIOD*2);
        reset = 1;

        // TC-TK-005: Global Reset
        $display("\n~~~~~~~~~~~~~~~~~~Test Case 1~~~~~~~~~~~~~~~~~~");
        apply_reset();
        check_time(0, 0, 0);

        // TC-TK-001: Basic Counting & Seconds Cascading
        $display("\n~~~~~~~~~~~~~~~~~~Test Case 2~~~~~~~~~~~~~~~~~~");
        wait_seconds(1);
        check_time(0, 0, 1);
        
        apply_reset(); 
        load_time(0, 0); 
        wait_seconds(59); 
        check_time(0, 0, 59);
        wait_seconds(1);
        check_time(0, 1, 0);

        // TC-TK-002: Minute Cascading
        $display("\n~~~~~~~~~~~~~~~~~~Test Case 3~~~~~~~~~~~~~~~~~~");
        apply_reset(); 
        load_time(0, 59); 
        wait_seconds(59); 

        check_time(0, 59, 59);
        wait_seconds(1);
        check_time(1, 0, 0);

        // TC-TK-003: Day Rollover
        $display("\n~~~~~~~~~~~~~~~~~~Test Case 4~~~~~~~~~~~~~~~~~~");
        apply_reset(); 
        load_time(23, 59);
        wait_seconds(59);

        check_time(23, 59, 59);
        wait_seconds(1);
        check_time(0, 0, 0); 

        // TC-TK-004: Global Load
        $display("\n~~~~~~~~~~~~~~~~~~Test Case 5~~~~~~~~~~~~~~~~~~");
        apply_reset();
        load_time(12, 30);

        check_time(12, 30, 0);
        
        // TC-TK-006: Wiring Check (High bits)
        $display("\n~~~~~~~~~~~~~~~~~~Test Case 6~~~~~~~~~~~~~~~~~~");
        load_time(18, 48);
        #(1);
        check_time(18, 48, 0);

        // TC: Timing Precision
        $display("\n~~~~~~~~~~~~~~~~~~Test Case 7~~~~~~~~~~~~~~~~~~");
        apply_reset();
        load_time(0,0);
        begin
            cycles = 0;
         
            wait(current_sec == 1);
            @(posedge clk); 
            while(current_sec == 1) begin
                cycles = cycles + 1;
                @(posedge clk);
            end
            if (cycles == CLOCK_FREQ_HZ) 
                $display("[PASS] Exact timing: %0d cycles per second", cycles);
            else 
                $error("[FAIL] Timing mismatch: %0d cycles (Expected %0d)", cycles, CLOCK_FREQ_HZ);
        end

        $display("---------------------------------------");
        $display("~~~~~~~~~Verification Complete~~~~~~~~~");
        $display("---------------------------------------");
        $finish;
    end

endmodule
