module Second_Detector #(
    parameter CLOCK_FREQ_HZ = 50_000_000
) (
    input wire clk,
    input wire reset,
    output reg sec_pulse 
);


    localparam COUNT_MAX = CLOCK_FREQ_HZ - 1;

    localparam COUNTER_WIDTH = $clog2(COUNT_MAX + 1);

    reg [COUNTER_WIDTH-1:0] counter_reg;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter_reg <= 0;
            sec_pulse <= 0;
        end else begin
            if (counter_reg == COUNT_MAX) begin
                counter_reg <= 0;
                sec_pulse <= 1; 
            end else begin
                counter_reg <= counter_reg + 1;
                sec_pulse <= 0; 
            end
        end
    end

endmodule
