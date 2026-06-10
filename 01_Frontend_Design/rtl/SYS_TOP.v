module SYS_TOP #(
    parameter CLOCK_FREQ_HZ = 2
)

(
 input   wire                          RST_N,
 input   wire                          CLK,
 input   wire                          mode,
 input   wire                          set,
 output  wire       [3:0]              hours_1,hours_2,
 output  wire       [3:0]              minute_1,minute_2,
 output  wire                          Split_ind,
 output  wire                          sound,
                                       load_en_min_1, 
                                       load_en_min_2,
                                       load_en_hr_1,
                                       load_en_hr_2

);

////////////////// Push button /////////////////////
wire                                   mode_pulse,
                                       set_pulse,
                                       mode_set;// third button generated from the and of the 2 buttons 
									   
////////////////// System Control  /////////////////////  

wire       			[3:0]              no_hours_1,
                                       no_hours_2,
                                       no_minute_1,
                                       no_minute_2,
									   st_hours_1,
                                       st_hours_2,
                                       st_minute_1,
                                       st_minute_2,
									   ala_hours_1,
									   ala_hours_2,
                                       ala_minute_1,
                                       ala_minute_2,
                                       sw_hours_1,
                                       sw_minute_1;
                                       

wire                [2:0]              sw_hours_2,
                                       sw_minute_2;                                       

wire                                   en_sw,
									   en_st,
									   en_ala;

////////////////// Time setting and keeping  /////////////////////
                                       
wire                                   load_en_min_1_st, 
                                       load_en_min_2_st,
                                       load_en_hr_1_st,
                                       load_en_hr_2_st;

////////////////// Stopwatch  /////////////////////
    								   
wire                                    split_active;

////////////////// Alarm  /////////////////////

wire                                   load_en_min_1_ala, 
                                       load_en_min_2_ala,
                                       load_en_hr_1_ala,
                                       load_en_hr_2_ala;	   


///********************************************************///////////
////////////////// Pulse Generator For the mode /////////////////////
///********************************************************/////////

PULSE_GEN U0_PULSE_GEN (
.clk(CLK),
.rst(RST_N),
.lvl_sig(mode),
.pulse_sig(mode_pulse)
);

///********************************************************///////////
////////////////// Pulse Generator For the set //////////////////////
///********************************************************/////////

PULSE_GEN U1_PULSE_GEN (
.clk(CLK),
.rst(RST_N),
.lvl_sig(set),
.pulse_sig(set_pulse)
);


///********************************************************///
//////////////////////// Time Keeper /////////////////////////
///********************************************************///

time_keeper #(.CLOCK_FREQ_HZ(CLOCK_FREQ_HZ)) U0_time_keeper(
    .clk(CLK),
    .reset(RST_N), 
    .load_en_min_1(load_en_min_1_st),
    .load_en_min_2(load_en_min_2_st),
    .load_val_min_1(st_minute_1),
    .load_val_min_2(st_minute_2),
    .load_en_hr_1(load_en_hr_1_st),
    .load_en_hr_2(load_en_hr_2_st),
    .load_val_hr_1(st_hours_1),
    .load_val_hr_2(st_hours_2),
    .o_min_1(no_minute_1),
    .o_min_2(no_minute_2),
    .o_hr_1(no_hours_1),
    .o_hr_2(no_hours_2)
);

///********************************************************///
//////////////////////// Time Set /////////////////////////
///********************************************************///

Set_time  U0_time_set(
    .clk(CLK),
    .rst(RST_N), 
    .En(en_st), 
    .Set(set_pulse), 
    .Both(mode_set),   
    .load_en_min_1(load_en_min_1_st),
    .load_en_min_2(load_en_min_2_st),
    .load_en_hr_1(load_en_hr_1_st),
    .load_en_hr_2(load_en_hr_2_st),
    .no_hours_1(no_hours_1),
    .no_hours_2(no_hours_2),
    .no_minute_1(no_minute_1),
    .no_minute_2(no_minute_2),
    .Md1(st_minute_1),
    .Md2(st_minute_2),
    .Hd1(st_hours_1),
    .Hd2(st_hours_2)
);

///********************************************************///
//////////////////////// Stopwatch ///////////////////////////
///********************************************************///

stopwatch #(.CLOCK_FREQ_HZ(CLOCK_FREQ_HZ)) U0_stopwatch(
    .clk(CLK),
    .reset(RST_N),    
    .start_pause(set_pulse),
    .split_req(mode_set),
    .enable(en_sw),
    .Min2(sw_hours_2),
    .Min1(sw_hours_1),
    .Sec2(sw_minute_2),
    .Sec1(sw_minute_1),
    .split_active(split_active)
);


///********************************************************///
//////////////////////// Alarm ///////////////////////////////
///********************************************************///

Alarm_set  U0_Alarm_set(
    .clk(CLK),
    .rst(RST_N), 
    .En(en_ala), 
    .Set(set_pulse), 
    .Both(mode_set),   
    .no_hours_1(no_hours_1),
    .no_hours_2(no_hours_2),
    .no_minute_1(no_minute_1),
    .no_minute_2(no_minute_2),
    .Md1(ala_minute_1),
    .Md2(ala_minute_2),
    .Hd1(ala_hours_1),
    .Hd2(ala_hours_2),
    .sound(sound),
    .load_en_min_1(load_en_min_1_ala),
    .load_en_min_2(load_en_min_2_ala),
    .load_en_hr_1(load_en_hr_1_ala),
    .load_en_hr_2(load_en_hr_2_ala)
);


///********************************************************///
//////////////////// System Controller ///////////////////////
///********************************************************///

Sys_ctrl U0_SYS_CTRL (
.clk(CLK),
.rst(RST_N),
.mode(mode_pulse),
.set(set_pulse),
.no_hours_1(no_hours_1),
.no_hours_2(no_hours_2),
.no_minute_1(no_minute_1),
.no_minute_2(no_minute_2),
.st_hours_1(st_hours_1),
.st_hours_2(st_hours_2),
.st_minute_1(st_minute_1),
.st_minute_2(st_minute_2),
.ala_hours_1(ala_hours_1),
.ala_hours_2(ala_hours_2),
.ala_minute_1(ala_minute_1), 
.ala_minute_2(ala_minute_2), 
.sw_hours_1(sw_hours_1),
.sw_hours_2(sw_hours_2),
.sw_minute_1(sw_minute_1),
.sw_minute_2(sw_minute_2),
.Split_ind_sw(split_active),
.load_en_min_1_ala(load_en_min_1_ala),
.load_en_min_2_ala(load_en_min_2_ala),
.load_en_hr_1_ala(load_en_hr_1_ala),
.load_en_hr_2_ala(load_en_hr_2_ala),
.load_en_min_1_st(load_en_min_1_st),
.load_en_min_2_st(load_en_min_2_st),
.load_en_hr_1_st(load_en_hr_1_st),
.load_en_hr_2_st(load_en_hr_2_st),
.en_sw(en_sw),
.en_st(en_st),
.en_ala(en_ala),
.hours_1(hours_1),
.hours_2(hours_2),
.minute_1(minute_1),
.minute_2(minute_2),
.Split_ind(Split_ind),
.load_en_min_1(load_en_min_1),
.load_en_min_2(load_en_min_2),
.load_en_hr_1(load_en_hr_1),
.load_en_hr_2(load_en_hr_2)
);

///********************************************************///
/////////////////// ANDing both buttons //////////////////////
///********************************************************///
 
AND U0_AND (
.a(set_pulse),
.b(mode_pulse),
.y(mode_set)
);



endmodule
 