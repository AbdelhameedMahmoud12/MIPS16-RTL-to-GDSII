module Set_time (
    input  wire         clk,
    input  wire         rst,
    input  wire         En,
    input  wire         Both,
    input  wire         Set,
    input  wire  [3:0]  no_hours_1,no_hours_2,
                        no_minute_1,no_minute_2,
    output reg   [3:0]  Hd1,
                        Hd2,
                        Md1,
                        Md2,
 ///////indicators of the digit while changing and to change the normal mode////////
                       
    output  reg         load_en_min_1, 
                        load_en_min_2,
                        load_en_hr_1,
                        load_en_hr_2
);


    reg [2:0] current_state, next_state;
    reg [3:0] H1_n,H2_n,M1_n,M2_n;

    ///// Encoding using gray code /////

    localparam           Ideal = 3'b000;//0
    localparam           H2    = 3'b001;//1
    localparam           H1    = 3'b011;//3
    localparam           M2    = 3'b010;//2
     localparam          M1    = 3'b110;//6

    always @(posedge clk or negedge rst) begin
        if (~rst)
            current_state <= Ideal;
        else
            current_state <= next_state;
    end

    always @(*) begin
         
            case (current_state)
                Ideal: begin
                    if (En)
                        next_state = H2;
                    else
                       next_state= Ideal;
                end
                H2: begin
                    if (En && Both)
                        next_state = H1;

                    else if (En)
                        next_state = H2;
                    else
                       next_state= Ideal;
               end
                H1: begin
                    if (En && Both)
                        next_state = M2;
                    else if (En)
                        next_state = H1;
                    else
                       next_state= Ideal;
                 end
                M2: begin
                    if (En && Both)
                        next_state = M1;
                    else if (En)
                        next_state = M2;
                    else
                       next_state= Ideal;
               end
                M1: begin
                    if (En && Both)
                        next_state = H2;
                    else if (En)
                        next_state = M1;
                    else
                       next_state= Ideal;
               end
                default: 
                    next_state = Ideal;
            endcase
        
    end

    always @(*) begin
        
            case (current_state)

                Ideal: begin
                    H2_n=no_hours_2;
                    H1_n=no_hours_1;
                    M2_n=no_minute_2;
                    M1_n=no_minute_1;
                    load_en_min_1=1'd0;
                    load_en_min_2=1'd0;
                    load_en_hr_1=1'd0;
                    load_en_hr_2=1'd0;
                end
                H2: begin
                    if (En && Set && (Hd2 != 2) && ~Both)begin
                        H2_n=Hd2+1;
                        H1_n=Hd1;
                        M1_n=Md1;
                        M2_n=Md2;
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd1;  
                    end
                        
                    else if(En && Set && (Hd2 == 2)&& ~Both)begin
                        H2_n=4'd0;
                        H1_n=Hd1;
                        M1_n=Md1;
                        M2_n=Md2;
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd1; 
                    end
                    else 
                    begin
                        H1_n=Hd1;
                        H2_n=Hd2;
                        M1_n=Md1;
                        M2_n=Md2; 
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd1; 
                    end
                    
                end
                H1: begin
                    if (En && Set && (Hd2 == 2) && (Hd1 !=3)&& ~Both)begin
                        H1_n=Hd1+1;
                        H2_n=Hd2;
                        M1_n=Md1;
                        M2_n=Md2;
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd1;
                        load_en_hr_2=1'd0;  
                    end
                        
                    else if(En && Set && (Hd2 == 2) && (Hd1 ==3)&&~Both)begin
                        H1_n=4'd0;
                        H2_n=Hd2;
                        M1_n=Md1;
                        M2_n=Md2;
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd1;
                        load_en_hr_2=1'd0; 
                    end
                    else if(En && Set && (Hd2 != 2) && (Hd1 !=9)&& ~Both)begin
                        H1_n=Hd1+1;
                        H2_n=Hd2;
                        M1_n=Md1;
                        M2_n=Md2;
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd1;
                        load_en_hr_2=1'd0; 
                    end
                    else if(En && Set && (Hd2 != 2) && (Hd1 ==9)&& ~Both)begin
                        H1_n=4'd0;
                        H2_n=Hd2;
                        M1_n=Md1;
                        M2_n=Md2; 
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd1;
                        load_en_hr_2=1'd0;
                    end
                    else 
                    begin
                        H1_n=Hd1;
                        H2_n=Hd2;
                        M1_n=Md1;
                        M2_n=Md2; 
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd1;
                        load_en_hr_2=1'd0; 
                    end
                end
                M2: begin
                    if (En && Set && (Md2 != 5)&& ~Both)begin
                        H2_n=Hd2;
                        H1_n=Hd1;
                        M1_n=Md1;
                        M2_n=Md2+1;
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd1;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd0;  
                    end
                        
                    else if(En && Set && (Md2 == 5)&& ~Both)begin
                        H2_n=Hd2;
                        H1_n=Hd1;
                        M1_n=Md1;
                        M2_n=4'd0;
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd1;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd0; 
                    end
                    else 
                    begin
                        H1_n=Hd1;
                        H2_n=Hd2;
                        M1_n=Md1;
                        M2_n=Md2; 
                        load_en_min_1=1'd0;
                        load_en_min_2=1'd1;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd0; 
                    end
                end
                M1: begin
                    if (En && Set && (Md1 != 9)&& ~Both)begin
                        H2_n=Hd2;
                        H1_n=Hd1;
                        M1_n=Md1+1;
                        M2_n=Md2;
                        load_en_min_1=1'd1;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd0;  
                    end
                        
                    else if(En && Set && (Md1 == 9)&& ~Both)begin
                        H2_n=Hd2;
                        H1_n=Hd1;
                        M1_n=4'd0;
                        M2_n=Md2;
                        load_en_min_1=1'd1;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd0; 
                    end
                    else 
                    begin
                        H1_n=Hd1;
                        H2_n=Hd2;
                        M1_n=Md1;
                        M2_n=Md2;
                        load_en_min_1=1'd1;
                        load_en_min_2=1'd0;
                        load_en_hr_1=1'd0;
                        load_en_hr_2=1'd0;  
                    end
                end
                default: begin
                    H2_n=no_hours_2;
                    H1_n=no_hours_1;
                    M2_n=no_minute_2;
                    M1_n=no_minute_1;
                    load_en_min_1=1'd0;
                    load_en_min_2=1'd0;
                    load_en_hr_1=1'd0;
                    load_en_hr_2=1'd0; 
                end
            endcase
    end

    /// Final output ////

    always @(posedge clk or negedge rst) begin
        if (~rst)begin
            Hd1<=no_hours_1;
            Hd2<=no_hours_2;
            Md1<=no_minute_1;
            Md2<=no_minute_2;
        end
        else begin
            Hd1<=H1_n;
            Hd2<=H2_n;
            Md1<=M1_n;
            Md2<=M2_n;
        end
    end

endmodule
