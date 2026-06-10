`timescale 1ns/1ps

module tb_stopwatch;

    // --- Inputs ---
    reg clk;
    reg reset; 
    reg start_pause;
    reg split_req;
    reg enable;

    // --- Outputs ---
    wire [3:0] Sec1; 
    wire [3:0] Sec2; 
    wire [3:0] Min1; 
    wire [3:0] Min2; 
    wire split_active;

    // --- Parameters ---
    localparam CLOCK_FREQ = 10; 
    localparam CLK_PERIOD = 20; 

    // --- Instantiate  ---
    stopwatch #(.CLOCK_FREQ_HZ(CLOCK_FREQ)) uut (
        .clk(clk),
        .reset(reset),
        .start_pause(start_pause),
        .split_req(split_req),
        .enable(enable),
        .Sec1(Sec1), 
        .Sec2(Sec2),
        .Min1(Min1), 
        .Min2(Min2),
        .split_active(split_active)
    );

    // --- Clock Generation ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ---  Tasks ---
    
    task press_start_pause;
        begin
            @(posedge clk);
            start_pause = 1;
            @(posedge clk);
            start_pause = 0;
            @(posedge clk);
        end
    endtask

    task press_split;
        begin
            @(posedge clk);
            split_req = 1;
            @(posedge clk);
            split_req = 0;
            @(posedge clk);
        end
    endtask

 
    task wait_seconds(input int seconds);
        begin
             repeat(seconds * CLOCK_FREQ) @(posedge clk);
        end
    endtask
    
   
    task check_time(input int expected_total_seconds);
        int exp_min_val;
        int exp_sec_val;
        int exp_min2, exp_min1, exp_sec2, exp_sec1;

        exp_min_val = expected_total_seconds / 60;
        exp_sec_val = expected_total_seconds % 60;
        
        exp_min2 = exp_min_val / 10;
        exp_min1 = exp_min_val % 10;
        exp_sec2 = exp_sec_val / 10;
        exp_sec1 = exp_sec_val % 10;

        if (Min2 === exp_min2 && Min1 === exp_min1 && Sec2 === exp_sec2 && Sec1 === exp_sec1) begin
            $display("  PASS: Display %0d%0d:%0d%0d matches expected Total: %0d", 
                     Min2, Min1, Sec2, Sec1, expected_total_seconds);
        end else begin
            $error("  FAIL: Display %0d%0d:%0d%0d does NOT match expected Total: %0d", 
                   Min2, Min1, Sec2, Sec1, expected_total_seconds);
            $error("        Expected BCD: %0d%0d:%0d%0d", exp_min2, exp_min1, exp_sec2, exp_sec1);
            $error("        Actual BCD:   %0d%0d:%0d%0d", Min2, Min1, Sec2, Sec1);
        end
    endtask

    function int get_current_total_seconds();
        int s, m;
        s = Sec2 * 10 + Sec1;
        m = Min2 * 10 + Min1;
        return (m * 60) + s;
    endfunction
    
    // --- Main Test Sequence ---
    initial begin
        // 1. Initialize Inputs
        reset = 0; 
        start_pause = 0;
        split_req = 0;
        enable = 1;


        // --- TC_01 ---
        $display("\n[TC_01] Global Reset Check");
        #100;
        if (get_current_total_seconds() === 0 && split_active === 0) 
            $display("  PASS: Reset state correct (00:00)");
        else 
            $error("  FAIL: Reset state incorrect. Time=%0d, Split=%b", get_current_total_seconds(), split_active);

        reset = 1; 
        #25;

        // --- TC_02 ---
        $display("\n[TC_02] Start & Count");
        press_start_pause(); 
        wait_seconds(2); 
        check_time(2);

        // --- TC_03 ---
        $display("\n[TC_03] Pause & Resume");
        press_start_pause(); 
        wait_seconds(2); 
        check_time(2); 

        press_start_pause(); 
        wait_seconds(2); 
        check_time(4);

        // Stop 
        press_start_pause(); 
        
        // --- TC_07 ---
        $display("\n[TC_07] Clear Functionality (Stop -> Split)");
        press_split(); 
        repeat(5) @(posedge clk);
        check_time(0);


        // --- TC_04 & TC_05 ---
        $display("\n[TC_04 & TC_05] Counting & Rollovers (Fast Forward)");
        press_start_pause(); // Start
        
        // Wait for 59 seconds to check minute rollover
        wait_seconds(59); 
        check_time(59);

        wait_seconds(1); 
        check_time(60);


        // --- TC_06: Split Mode (Freeze) ---
        $display("\n[TC_06] Split Mode (Freeze)");
        wait_seconds(5); 
        
        press_split(); 
        $display("  Action: Split Activated at 01:05");
        
        wait_seconds(5); 
        
        check_time(65);
		$display(" --------------Frazee ----------------");
        wait_seconds(5); 
        check_time(65);
		$display(" --------------Release ----------------");
        press_split(); 
        repeat(5) @(posedge clk); 
       
        if (get_current_total_seconds() >= 70) 
            $display("  PASS: Display Updated to Live Time (%0d seconds)", get_current_total_seconds());
        else 
            $error("  FAIL: Display did not update correctly. Got %0d", get_current_total_seconds());


        // --- TC_08 ---
        $display("\n[TC_08] Full Range Wrap (59:59 -> 00:00)");
        
        $display("  Waiting for counter to reach 59:59...");
        wait_seconds(3529); 
        
        // Wait until wrap
        while(get_current_total_seconds() != 3599) begin
            @(posedge clk);
            if (get_current_total_seconds() === 0) break; 
        end
        
        if (get_current_total_seconds() === 3599) begin
             $display("  INFO: Reached 59:59");
             wait_seconds(1);
        end else begin
             $display("  INFO: Wrapped to 00:00 detected immediately.");
        end
        
        check_time(0);

        $display("\n========================================");
        $display("      VERIFICATION COMPLETE             ");
        $display("========================================");
        $stop;
    end



endmodule
