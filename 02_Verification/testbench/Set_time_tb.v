`timescale 1ns/1ps

module Set_time_tb();

    reg         clk_tb;
    reg         rst_tb;
    reg         En_tb;
    reg         Both_tb;
    reg         Set_tb;
    reg  [3:0]  no_hours_1_tb,no_hours_2_tb,no_minute_1_tb,no_minute_2_tb;
    wire [3:0]  Hd1_tb,Hd2_tb,Md1_tb,Md2_tb;
    wire        load_en_min_1_tb,load_en_min_2_tb,load_en_hr_1_tb,load_en_hr_2_tb;

    Set_time uut (
        .clk          (clk_tb),
        .rst          (rst_tb),
        .En           (En_tb),
        .Both         (Both_tb),
        .Set          (Set_tb),

        .no_hours_1   (no_hours_1_tb),
        .no_hours_2   (no_hours_2_tb),
        .no_minute_1  (no_minute_1_tb),
        .no_minute_2  (no_minute_2_tb),

        .Hd1          (Hd1_tb),
        .Hd2          (Hd2_tb),
        .Md1          (Md1_tb),
        .Md2          (Md2_tb),

        .load_en_min_1(load_en_min_1_tb),
        .load_en_min_2(load_en_min_2_tb),
        .load_en_hr_1 (load_en_hr_1_tb),
        .load_en_hr_2 (load_en_hr_2_tb)
    );

    parameter CLOCK_PERIOD = 10;

    always #(CLOCK_PERIOD/2) clk_tb = ~clk_tb;

    localparam           Ideal = 3'b000;
    localparam           H2    = 3'b001;
    localparam           H1    = 3'b011;
    localparam           M2    = 3'b010;
    localparam           M1    = 3'b110;

    task initialize;
        begin
            clk_tb  = 0;
            rst_tb  = 1;
            En_tb   = 0;
            Both_tb = 0;
            Set_tb  = 0;

            no_hours_1_tb   = 0;
            no_hours_2_tb   = 0;
            no_minute_1_tb  = 0;
            no_minute_2_tb  = 0;
        end
    endtask

    task apply_reset;
        begin
            rst_tb = 0;
            @(posedge clk_tb);
            @(posedge clk_tb);
            rst_tb = 1;
            @(posedge clk_tb);
        end
    endtask




    task Operation (
        input integer case_num,
        input [15:0] normal_time,
        input [15:0] expected_time,
        input EN,
        input integer N_Both,
        input integer N_Set
        );

        reg [15:0] calc_time;
        integer i;
        begin
            no_hours_2_tb   = normal_time [15:12];
            no_hours_1_tb   = normal_time [11:8];
            no_minute_2_tb  = normal_time [7:4];
            no_minute_1_tb  = normal_time [3:0];

            En_tb = EN;

            Both_tb = 1'b0;
            Set_tb    = 1'b0;

            @(posedge clk_tb);

            for (i = 0; i < N_Both; i = i + 1) 
                begin
                    Both_tb = 1'b1; @(posedge clk_tb);
                    Both_tb = 1'b0; @(posedge clk_tb);
                end

            for (i = 0; i < N_Set; i = i + 1) 
                begin
                    Set_tb = 1'b1; @(posedge clk_tb);
                    Set_tb = 1'b0; @(posedge clk_tb);
                end

            @(posedge clk_tb); 
            calc_time [15:12]   = Hd2_tb;
            calc_time [11:8]    = Hd1_tb;
            calc_time [7:4]     = Md2_tb;
            calc_time [3:0]     = Md1_tb;
            if (calc_time == expected_time ) 
                begin
                    $display("Case %0d : Received = %h => PASSED", case_num, calc_time);
                    $display("-------------------------------------------------------------\n");
                end
            else
                begin
                    $display("Case %0d : Received = %h (Expected %h) => FAILED", case_num, calc_time, expected_time);
                    $display("-------------------------------------------------------------\n");            
                end
        end
    endtask

    initial 
        begin
            initialize();
            #(CLOCK_PERIOD);
            apply_reset();

            // Case 1,2: En=0 => nothing changes (independent)
            Operation(1, 16'h1234, 16'h1234, 1'b0, 3, 5);
            Operation(2, 16'h0000, 16'h0000, 1'b0, 10, 10);

            // Now do chained operations with En=1
            // Start from 00:00
            Operation(3, 16'h0000, 16'h1000, 1'b1, 0, 1);   // H2 +1 => 10:00

            // Next case normal_time = previous expected_time
            Operation(4, 16'h1000, 16'h1100, 1'b1, 1, 1);   // Both->H1, Set => 11:00
            Operation(5, 16'h1100, 16'h1110, 1'b1, 1, 1);   // Both->M2, Set => 11:10
            Operation(6, 16'h1110, 16'h1111, 1'b1, 1, 1);   // Both->M1, Set => 11:11

            // Example: stay in same digit and wrap tests (still chained)
            // Move back to H2 (from M1 do Both once -> H2 in your FSM)
            Operation(7, 16'h1111, 16'h2111, 1'b1, 1, 1);   // Both->H2, Set => hour tens 1->2 => 21:11
            Operation(8, 16'h2111, 16'h1111, 1'b1, 0, 2);   // H2: 2->0->1 (two Sets) => 01:11
            Operation(9, 16'h1111, 16'h2111, 1'b1, 0, 1);   // H2: 1->2 => 21? (depends on your H2 range) adjust if needed

            //Extreme cases
            Operation(10, 16'h2111, 16'h2101, 1'b1, 2, 5);
            Operation(11, 16'h2101, 16'h1101, 1'b1, 2, 2);
            Operation(12, 16'h1101, 16'h1001, 1'b1, 1, 9);
            Operation(13, 16'h1001, 16'h1501, 1'b1, 0, 5);
            //passed
            Operation(14, 16'h1501, 16'h2001, 1'b1, 3, 1);
            Operation(15, 16'h2001, 16'h2001, 1'b1, 0, 3);
            Operation(16, 16'h2001, 16'h2001, 1'b1, 1, 4);
            Operation(17, 16'h2001, 16'h2000, 1'b1, 2, 9);
            Operation(18, 16'h2000, 16'h0000, 1'b1, 1, 1);
            //minutes fail
            Operation(19, 16'h0000, 16'h0009, 1'b1, 3, 9);
            Operation(20, 16'h0009, 16'h0019, 1'b1, 3, 7);


            #(2*CLOCK_PERIOD);
            $stop;
        end


endmodule