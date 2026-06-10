module stopwatch #(
    parameter CLOCK_FREQ_HZ = 50_000_000
)
(
    input wire clk,
    input wire reset,
    // Control
    input wire start_pause, 
    input wire split_req,   
    input wire enable,      
    output reg  [3:0] Sec1,
    output reg  [2:0] Sec2,
    output reg  [3:0] Min1,
    output reg  [2:0] Min2,
	output reg 		  split_active
);
    
    wire sec_pulse;

    
    Second_Detector #(.CLOCK_FREQ_HZ(CLOCK_FREQ_HZ)) inst_sec_det (
        .clk(clk),
        .reset(reset),
        .sec_pulse(sec_pulse)
    );
    
    reg running;
	
    // M2 M1:S2 S1
    wire [3:0] S1, M1;
	wire [2:0] S2, M2; 
	wire S1_roll_over_flag,S2_roll_over_flag,M1_roll_over_flag,M2_roll_over_flag;
    reg clear_counters;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            running <= 0;
            split_active <= 0;
            clear_counters <= 1;
        end else begin
            clear_counters <= 0; 

        if (enable) begin
				//Start --> Stop --> Start --> Stop --> Clear
                if (start_pause && ~split_req) begin
                    running <= ~running;
                end
				//Start --> Split --> Release --> Stop --> Clear 
                if (split_req) begin
                    if (running) begin
                        split_active <= ~split_active; 
                    end else begin
                        clear_counters <= 1;
                        split_active <= 0;
                    end
                end
            end
        end
    end


    mod_counter_sw #( .N(10) ) U0_cnt_sec (
        .clk(clk), .reset(reset),
        .enable(sec_pulse & running),.clear(clear_counters | M2_roll_over_flag),
        .load(1'b0), .load_val(4'd0),
        .count_out(S1), .roll_over_flag(S1_roll_over_flag)
    );
	
    mod_counter_sw #( .N(6) ) U1_cnt_min (
        .clk(clk), .reset(reset),
        .enable(S1_roll_over_flag),.clear(clear_counters | M2_roll_over_flag),
        .load(1'b0), .load_val(3'd0),
        .count_out(S2), .roll_over_flag(S2_roll_over_flag)
    );

    mod_counter_sw #( .N(10) ) U2_cnt_min (
        .clk(clk), .reset(reset),
        .enable(S2_roll_over_flag),.clear(clear_counters | M2_roll_over_flag),
        .load(1'b0), .load_val(4'd0),
        .count_out(M1), .roll_over_flag(M1_roll_over_flag)
    );

    mod_counter_sw #( .N(6) ) U3_cnt_hr (
        .clk(clk), .reset(reset),
        .enable(M1_roll_over_flag),.clear(clear_counters),
        .load(1'b0), .load_val(3'd0),
        .count_out(M2), .roll_over_flag(M2_roll_over_flag)
    );



    // Output Logic
    reg  [3:0] Sec1_latch;
    reg  [2:0] Sec2_latch;
    reg  [3:0] Min1_latch;
    reg  [2:0] Min2_latch;
	
    always @(posedge clk) begin
		
        if (!split_active) begin
            Sec1_latch <= S1;
            Sec2_latch <= S2;
			Min1_latch <= M1;
			Min2_latch <= M2;
        end
    end


    always @(*) begin
		//Freeze
        if (split_active) begin
            Sec1 = Sec1_latch;
            Sec2 = Sec2_latch;
			Min1 = Min1_latch;
			Min2 = Min2_latch;
        end 
		//Release 
		else begin
            Sec1 = S1;
            Sec2 = S2;
			Min1 = M1;
			Min2 = M2;
        end
    end


endmodule