module counter_hours (
    input wire clk,
    input wire reset,
    input wire enable, 
    
    //  load controls
    input wire load_en_tens,
    input wire [3:0] load_val_tens,
    input wire load_en_ones,
    input wire [3:0] load_val_ones,
    
    output reg [3:0] count_tens,
    output reg [3:0] count_ones
);

    always @(posedge clk or negedge reset) begin
        if (~reset) begin
            count_tens <= 0;
            count_ones <= 0;
        end else begin
            if (load_en_tens) count_tens <= load_val_tens;
            if (load_en_ones) count_ones <= load_val_ones;


            if (!load_en_tens && !load_en_ones && enable) begin
                if (count_tens == 2 && count_ones == 3) begin
				
                     count_tens <= 0;
                     count_ones <= 0;
                end else if (count_ones == 9) begin

                     count_ones <= 0;
                     count_tens <= count_tens + 1;
                end else begin

                     count_ones <= count_ones + 1;
                end
            end
        end
    end

endmodule
