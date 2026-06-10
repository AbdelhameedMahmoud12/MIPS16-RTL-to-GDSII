module time_keeper #(
    parameter CLOCK_FREQ_HZ = 50000000
)(
    input wire clk,
    input wire reset,    
	
    //signals from Set Time Block " To set a new time"
    input wire load_en_min_1,load_en_min_2,
    input wire [3:0] load_val_min_1,load_val_min_2,
    input wire load_en_hr_1,load_en_hr_2,
    input wire [3:0] load_val_hr_1,load_val_hr_2,
    output wire [3:0] o_min_1,o_min_2,o_hr_1,o_hr_2
);

    wire sec_rollover, min_rollover_1,min_rollover_2;
	wire sec_pulse;

    // Internal wires for correct width matching on Minutes
    wire [2:0] min_tens_internal;
	
	Second_Detector #(.CLOCK_FREQ_HZ(CLOCK_FREQ_HZ)) inst_sec_det (
	.clk(clk),
	.reset(reset),
	.sec_pulse(sec_pulse)
	);

    // Seconds Counter (Mod 60, generic)
    mod_counter #( .N(60)) U0_cnt_sec (
        .clk(clk), .reset(reset),
        .enable(sec_pulse),
        .load(1'b0), .load_val(6'b0), // Explicit 0 load
        .count_out(), .roll_over_flag(sec_rollover)
    );
	
	// Minute Ones (Mod 10)
    mod_counter #( .N(10)) U1_cnt_min (
        .clk(clk), .reset(reset),
        .enable(sec_rollover),
        .load(load_en_min_1), .load_val(load_val_min_1),
        .count_out(o_min_1), .roll_over_flag(min_rollover_1)
    );

    // Minute Tens (Mod 6)
    mod_counter #( .N(6)) U2_cnt_min (
        .clk(clk), .reset(reset),
        .enable(min_rollover_1),
        .load(load_en_min_2), .load_val(load_val_min_2[2:0]), // Slice to 3 bits
        .count_out(min_tens_internal), .roll_over_flag(min_rollover_2)
    );
    assign o_min_2 = {1'b0, min_tens_internal}; // Pad to 4 bits

    // Hours (Custom 00-23 Counter)
    counter_hours U_cnt_hr (
        .clk(clk),
        .reset(reset),
        .enable(min_rollover_2),
        
        .load_en_ones(load_en_hr_1),
        .load_val_ones(load_val_hr_1),
        .load_en_tens(load_en_hr_2),
        .load_val_tens(load_val_hr_2),
        
        .count_ones(o_hr_1),
        .count_tens(o_hr_2)
    );

endmodule
