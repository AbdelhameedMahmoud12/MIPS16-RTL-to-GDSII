`timescale 1ns/1ps

module Alarm_set_tb();

    reg         clk_tb;
    reg         rst_tb;
    reg         En_tb;
    reg         Both_tb;
    reg         Set_tb;

    reg  [3:0]  no_hours_1_tb, no_hours_2_tb;
    reg  [3:0]  no_minute_1_tb, no_minute_2_tb;

    wire [3:0]  Hd1_tb, Hd2_tb;
    wire [3:0]  Md1_tb, Md2_tb;

    wire        sound_tb;

    wire        load_en_min_1_tb, load_en_min_2_tb;
    wire        load_en_hr_1_tb,  load_en_hr_2_tb;

    Alarm_set uut (
        .clk           (clk_tb),
        .rst           (rst_tb),
        .En            (En_tb),
        .Both          (Both_tb),
        .Set           (Set_tb),
        .no_hours_1    (no_hours_1_tb),
        .no_hours_2    (no_hours_2_tb),
        .no_minute_1   (no_minute_1_tb),
        .no_minute_2   (no_minute_2_tb),
        .Hd1           (Hd1_tb),
        .Hd2           (Hd2_tb),
        .Md1           (Md1_tb),
        .Md2           (Md2_tb),
        .sound         (sound_tb),
        .load_en_min_1 (load_en_min_1_tb),
        .load_en_min_2 (load_en_min_2_tb),
        .load_en_hr_1  (load_en_hr_1_tb),
        .load_en_hr_2  (load_en_hr_2_tb)
    );

    parameter CLOCK_PERIOD = 10;
    always #(CLOCK_PERIOD/2) clk_tb = ~clk_tb;

    localparam           Ideal        = 3'b000;
    localparam           Alarm_act    = 3'b001;
    localparam           H2           = 3'b011;
    localparam           H1           = 3'b010;
    localparam           M2           = 3'b110;
    localparam           M1           = 3'b111;


    task initialize;
        begin
            clk_tb        = 0;
            rst_tb        = 1;
            En_tb         = 0;
            Both_tb       = 0;
            Set_tb        = 0;

            // DUT BCD digit inputs
            no_hours_1_tb  = 4'd0;
            no_hours_2_tb  = 4'd0;
            no_minute_1_tb = 4'd0;
            no_minute_2_tb = 4'd0;
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
/*
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

            @(posedge clk_tb);
            if (calc)

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
*/
task Operation (
    input integer case_num,
    input [15:0] normal_time,     // time to compare against alarm (no_* inputs)
    input [15:0] expected_alarm,   // expected stored alarm digits (Hd2 Hd1 Md2 Md1)
    input EN,
    input integer N_Both,
    input integer N_Set,
    input expected_sound
);

    reg [15:0] calc_alarm;
    integer i;
    reg calc_sound;

    begin
        no_hours_2_tb   = normal_time[15:12];
        no_hours_1_tb   = normal_time[11:8];
        no_minute_2_tb  = normal_time[7:4];
        no_minute_1_tb  = normal_time[3:0];

        En_tb   = EN;
        Both_tb = 1'b0;
        Set_tb  = 1'b0;

        @(posedge clk_tb);

        for (i = 0; i < N_Both; i = i + 1) begin
            Both_tb = 1'b1; @(posedge clk_tb);
            Both_tb = 1'b0; @(posedge clk_tb);
        end

        for (i = 0; i < N_Set; i = i + 1) begin
            Set_tb = 1'b1; @(posedge clk_tb);
            Set_tb = 1'b0; @(posedge clk_tb);
        end

        @(posedge clk_tb);

        calc_alarm[15:12] = Hd2_tb;
        calc_alarm[11:8]  = Hd1_tb;
        calc_alarm[7:4]   = Md2_tb;
        calc_alarm[3:0]   = Md1_tb;

        calc_sound = sound_tb;

        if ((calc_alarm == expected_alarm) && (calc_sound === expected_sound)) begin
            $display("Case %0d : Alarm=%h sound=%b => PASSED", case_num, calc_alarm, calc_sound);
            $display("-------------------------------------------------------------\n");
        end else begin
            $display("Case %0d : Alarm=%h sound=%b => FAILED", case_num, calc_alarm, calc_sound);
            $display("         Expected Alarm=%h sound=%b", expected_alarm, expected_sound);
            $display("         normal_time=%h En=%b N_Both=%0d N_Set=%0d", normal_time, EN, N_Both, N_Set);
            $display("-------------------------------------------------------------\n");
        end
    end
endtask



initial begin
    initialize();
    #(CLOCK_PERIOD);
    apply_reset();

    // Case 1: En=0, time changes, alarm should stay 00:00, sound=0
    Operation(1, 16'h1234, 16'h0000, 1'b0, 3, 5, 1'b0);

    // Case 2: En=1, time=00:00 equals alarm=00:00 BUT sound not active yet => sound=0
    Operation(2, 16'h0000, 16'h0000, 1'b1, 0, 0, 1'b0);

    // Case 3: Toggle sound ON (Ideal + Set), time matches => sound=1
    Operation(3, 16'h0000, 16'h0000, 1'b1, 0, 1, 1'b1);

    // Case 4: Sound ON but time != alarm => sound=0
    Operation(4, 16'h0001, 16'h0000, 1'b1, 0, 0, 1'b0);

    // Set alarm to 23:59 (Hd2=tens, Hd1=ones, Md2=tens, Md1=ones)
    // Case 5: Go to H2 and set Hd2: 0->2
    Operation(5, 16'h0001, 16'h2000, 1'b1, 1, 2, 1'b0);

    // Case 6: Go to H1 and set Hd1: 0->3
    Operation(6, 16'h0001, 16'h2300, 1'b1, 1, 3, 1'b0);

    // Case 7: Go to M2 and set Md2: 0->5
    Operation(7, 16'h0001, 16'h2350, 1'b1, 1, 5, 1'b0);

    // Case 8: Go to M1 and set Md1: 0->9
    Operation(8, 16'h0001, 16'h2359, 1'b1, 1, 9, 1'b0);

    // Case 9: Time equals alarm (23:59) and sound is ON => sound=1
    Operation(9, 16'h2359, 16'h2359, 1'b1, 0, 0, 1'b1);

    // Case 10 (requested): Time equals alarm but sound is turned OFF => sound=0
    // From M1: Both -> Ideal, then Set toggles sound off
    Operation(10, 16'h2359, 16'h2359, 1'b1, 1, 1, 1'b0);

    // Case 11: Still matching time, sound still OFF => sound=0
    Operation(11, 16'h2359, 16'h2359, 1'b1, 0, 0, 1'b0);

    // Case 12: Toggle sound ON again (Ideal + Set) => sound=1
    Operation(12, 16'h2359, 16'h2359, 1'b1, 0, 1, 1'b1);

    // Wrap tests (still chained)
    // Case 13: Go to M1 and increment Md1 once: 9->0, alarm becomes 23:50
    // From Ideal: 4 Both to reach M1 (Ideal->H2->H1->M2->M1), then Set once
    Operation(13, 16'h0000, 16'h2350, 1'b1, 4, 1, 1'b0);

    // Case 14: Time equals alarm 23:50 and sound ON => sound=1
    Operation(14, 16'h2350, 16'h2350, 1'b1, 0, 0, 1'b1);

    // Case 15: Wrap Md2 once: 5->0, alarm becomes 23:00
    // From M1: 4 Both to reach M2 (M1->Ideal->H2->H1->M2), then Set once
    Operation(15, 16'h0000, 16'h2300, 1'b1, 4, 1, 1'b0);

    // Case 16: Time equals alarm 23:00 and sound ON => sound=1
    Operation(16, 16'h2300, 16'h2300, 1'b1, 0, 0, 1'b1);

    // Case 17: Wrap Hd1 when Hd2=2: 3->0, alarm becomes 20:00
    // From M2: 4 Both to reach H1 (M2->M1->Ideal->H2->H1), then Set once
    Operation(17, 16'h0000, 16'h2000, 1'b1, 4, 1, 1'b0);

    // Case 18: Time equals alarm 20:00 and sound ON => sound=1
    Operation(18, 16'h2000, 16'h2000, 1'b1, 0, 0, 1'b1);

    // Case 19: Wrap Hd2: 2->0, alarm becomes 00:00
    // From H1: 4 Both to reach H2 (H1->M2->M1->Ideal->H2), then Set once
    Operation(19, 16'h0000, 16'h0000, 1'b1, 4, 1, 1'b1);

    // Case 20: Time matches 00:00 but toggle sound OFF => sound=0
    // From H2: 4 Both to reach Ideal (H2->H1->M2->M1->Ideal), then Set once
    Operation(20, 16'h0000, 16'h0000, 1'b1, 4, 1, 1'b0);

    #(2*CLOCK_PERIOD);
    $stop;
end


endmodule