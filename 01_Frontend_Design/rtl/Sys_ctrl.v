module Sys_ctrl (
                no_hours_1,no_hours_2,
                no_minute_1,no_minute_2,
                st_hours_1,st_hours_2,
                st_minute_1,st_minute_2,
                ala_hours_1,ala_hours_2,
                ala_minute_1,ala_minute_2,
                sw_hours_1,sw_hours_2,
                sw_minute_1,sw_minute_2,
                load_en_min_1_ala,load_en_min_2_ala,
                load_en_hr_1_ala,load_en_hr_2_ala,
                load_en_min_1_st,load_en_min_2_st,
                load_en_hr_1_st,load_en_hr_2_st,
                load_en_min_1, load_en_min_2,
                load_en_hr_1,load_en_hr_2,
                Split_ind_sw,mode,set,clk,rst,en_sw,en_st,en_ala,
                hours_1,hours_2,minute_1,minute_2,
                Split_ind
                );

//////input signals//////

input [3:0] st_minute_1,st_minute_2,st_hours_1,st_hours_2,
            ala_minute_1,ala_minute_2,ala_hours_1,ala_hours_2,
            no_hours_1,no_hours_2,no_minute_1,no_minute_2,
            sw_hours_1,sw_minute_1;


input [2:0] sw_hours_2,sw_minute_2;



input mode,set,Split_ind_sw;

input clk,rst;

input           load_en_min_1_ala,load_en_min_2_ala,
                load_en_hr_1_ala,load_en_hr_2_ala,
                load_en_min_1_st,load_en_min_2_st,
                load_en_hr_1_st,load_en_hr_2_st;

//////output signals//////
output reg [3:0] hours_1,hours_2,minute_1,minute_2;

output reg en_sw,en_st,en_ala,Split_ind;// enable signal for each block 

output reg      load_en_min_1, load_en_min_2,
                load_en_hr_1,load_en_hr_2;

///// current and next stage ///

reg [1:0] current_state,next_state;

///// Encoding using gray code /////

localparam [1:0] normal =     2'b00;//0
localparam [1:0] set_alarm=   2'b01;//1
localparam [1:0] stop_watch=  2'b11;//3
localparam [1:0] set_time=    2'b10;//2

//////  state transition//////

always @(posedge clk or negedge rst) begin

  if (~rst) // reset
  begin

    current_state<=normal;

  end

  else 
  begin

    current_state<=next_state;
    
  end
end

/// next_state logic ///

always @(*) begin
  
  case(current_state)

      normal : begin 

            if (mode && ~set)

               next_state=set_alarm;

            else

               next_state=normal;
        
            end


      set_alarm : begin 

            if (mode && ~set)

               next_state=stop_watch;

            else

               next_state=set_alarm;
        
            end
      stop_watch : begin 

            if (mode && ~set)

               next_state=set_time;

            else

               next_state=stop_watch;
        
            end
       set_time : begin 

            if (mode && ~set)

               next_state=normal;

            else

               next_state=set_time;
        
            end

      default : next_state=normal;

  endcase

end


/// moore output logic ///  

always @(*) begin
  
  case(current_state)

      normal : begin 
           hours_1=     no_hours_1;
           hours_2=     no_hours_2;
           minute_1=    no_minute_1;
           minute_2=    no_minute_2;
           en_sw=       1'b0;
           en_st=       1'b0;
           en_ala=      1'b0;
           Split_ind=   1'b0;
           load_en_hr_2 = 1'b0;
           load_en_hr_1 = 1'b0;
           load_en_min_2= 1'b0;
           load_en_min_1= 1'b0;
        
            end

      set_alarm : begin 

           hours_1=     ala_hours_1;
           hours_2=     ala_hours_2;
           minute_1=    ala_minute_1;
           minute_2=    ala_minute_2;
           en_sw=       1'b0;
           en_st=       1'b0;
           en_ala=      1'b1;
           Split_ind=   1'b0;
           Split_ind=     1'b0;
           load_en_hr_2 = load_en_hr_2_ala;
           load_en_hr_1 = load_en_hr_1_ala;
           load_en_min_2= load_en_min_2_ala;
           load_en_min_1= load_en_min_1_ala;
        
            end

      stop_watch : begin 

           hours_1=     sw_hours_1;
           minute_1=    sw_minute_1;
           hours_2=     {1'b0,sw_hours_2};
           minute_2=    {1'b0,sw_minute_2};
           en_sw=       1'b1;
           en_st=       1'b0;
           en_ala=      1'b0;
           Split_ind=   Split_ind_sw;
           load_en_hr_2 = 1'b0;
           load_en_hr_1 = 1'b0;
           load_en_min_2= 1'b0;
           load_en_min_1= 1'b0;
        
            end
      set_time : begin 

           hours_1=     st_hours_1;
           hours_2=     st_hours_2;
           minute_1=    st_minute_1;
           minute_2=    st_minute_2;
           en_sw=       1'b0;
           en_st=       1'b1;
           en_ala=      1'b0;
           Split_ind=   1'b0;
           load_en_hr_2 = load_en_hr_2_st;
           load_en_hr_1 = load_en_hr_1_st;
           load_en_min_2= load_en_min_2_st;
           load_en_min_1= load_en_min_1_st;


            end


    default : begin

           hours_1=     no_hours_1;
           hours_2=     no_hours_2;
           minute_1=    no_minute_1;
           minute_2=    no_minute_2;
           en_sw=       1'b0;
           en_st=       1'b0;
           en_ala=      1'b0;
           Split_ind=   1'b0;
            
            end

  endcase

end

endmodule