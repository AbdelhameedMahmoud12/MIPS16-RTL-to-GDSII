module mod_counter_sw #(
    parameter N          = 60,  
    parameter DATA_WIDTH = $clog2(N)
) (
    input wire clk,
    input wire reset,
    input wire enable,      
    input wire load, 
    input wire clear,       
    input wire [DATA_WIDTH-1:0] load_val, 
    output wire  [DATA_WIDTH-1:0] count_out,
    output wire roll_over_flag 
);
    reg [DATA_WIDTH-1:0] count;

    assign roll_over_flag= (enable && (count_out == N - 1 ));// Assert roll-over flag
    assign count_out=count;

    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            count <= 0;
        end 
        else if (clear) begin
            count <= 0;
        end
        else if (load) begin
            count <= load_val;
        end
         else if (enable) begin
            if (count == N - 1) begin
                count <= 0;
            end else begin
                count <= count + 1;
            end
        end 
    end

endmodule
