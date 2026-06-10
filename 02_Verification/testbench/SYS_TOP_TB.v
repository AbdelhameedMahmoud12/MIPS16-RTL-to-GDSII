module SYS_TOP_TB();

/////// Parameters ///////
parameter CLK_period = 500_000_000 ; 
parameter integer CLOCK_FREQ_HZ_TB = 2; // match DUT CLOCK_FREQ_HZ

////////// DUT Signals /////////
reg        CLK_tb, RST_N_tb, mode_tb, set_tb;
wire [3:0] hours_1_tb,hours_2_tb,minute_1_tb,minute_2_tb;
wire       Split_ind_tb;
wire       sound_tb;
wire       load_en_min_1_tb, 
           load_en_min_2_tb,
           load_en_hr_1_tb,
           load_en_hr_2_tb;

////////// test Signals /////////

integer TEST_NUM,temp_min,temp_hour;

reg     alarm_ind;

// Design Instantiation

SYS_TOP dut(
    .CLK      (CLK_tb),
    .RST_N    (RST_N_tb),
    .mode     (mode_tb),
    .set      (set_tb),
    .hours_1  (hours_1_tb),
    .hours_2  (hours_2_tb),
    .minute_1 (minute_1_tb),
    .minute_2 (minute_2_tb),
    .Split_ind(Split_ind_tb),
    .sound    (sound_tb),
    .load_en_min_1(load_en_min_1_tb),
    .load_en_min_2(load_en_min_2_tb),
    .load_en_hr_1(load_en_hr_1_tb),
    .load_en_hr_2(load_en_hr_2_tb)
);


////////// Counter Variables //////////

reg [30:0] passed_cases, failed_cases;

reg [30:0] passed_cases_ind, failed_cases_ind;

////////// initial block ////////// 

initial 
begin
    // Initialization
    initialize();
    // Reset the design 
    reset();

////////// Normal and time setting testing  ////////// 

    // run normal-mode check for 11 minutes to check the transition of the left minute
    run_normal_mode(11,temp_hour,temp_min,0);//minutes,load_min,load_hour,load signal

    // go to time setting mode
    pulse_mode();
    pulse_mode();
    pulse_mode();

    // run Time checking-mode check setting time to 00:55
    run_setting_mode(0,0,4,4);// H2+ H1+:M2+ M1+

    // return to normal mode
    pulse_mode();

    // run normal-mode check for 6 minutes to check the transition of the right hour exp: 01:01
    run_normal_mode(6,temp_hour,temp_min,1);//minutes,load_min,load_hour,load signal

    // go to time setting mode
    pulse_mode();
    pulse_mode();
    pulse_mode();

    // run Time checking-mode check setting time to 09:55
    run_setting_mode(0,8,5,4);// H2+ H1+:M2+ M1+

    // return to normal mode
    pulse_mode();

    // run normal-mode check for 6 minutes to check the transtion of the left hour exp: 10:01
    run_normal_mode(6,temp_hour,temp_min,1);//minutes,load_min,load_hour,load signal

    // go to time setting mode
    pulse_mode();
    pulse_mode();
    pulse_mode();

    // run Time checking-mode check setting time to 23:55
    run_setting_mode(1,3,5,4);// H2+ H1+:M2+ M1+

    // return to normal mode
    pulse_mode();

    // run normal-mode check for 6 minutes to check the transtion of the left hour exp: 00:01
    run_normal_mode(6,temp_hour,temp_min-1,1);//latency in time setting

////////// Normal,Alarm,time testing  ////////// 
    
    // Reset the design 
    reset();
    // go to time setting mode
    pulse_mode();
    pulse_mode();
    pulse_mode();
    
    // run Time checking-mode check setting time to 23:55
    run_setting_mode(2,3,5,5);// H2+ H1+:M2+ M1+

    // go to alarm mode
    pulse_mode();
    pulse_mode();

    // settimg the alarm at 23:59 and activating it
    run_alarm_mode(2,3,5,9,1);// H2 H1:M2 M1 on/off

    // return to normal mode
    pulse_mode();
    pulse_mode();
    pulse_mode();

    // wait 5 minutes to see if the alarm will activate
    $display("=== ALARM CHECK FUNCTIONALITY TEST ===");
    repeat(5)begin
        tick_1hz(60);
        check_alarm(2,3,5,9,1);
    end

    // go to alarm mode
    pulse_mode();

    // settimg the alarm at 01:59 from the previous 23:59 
    run_alarm_mode(1,8,0,0,0);// H2 H1:M2 M1 on/off

    // go to time setting mode
    pulse_mode();
    pulse_mode();

    // run Time checking-mode check setting time to 01:59 to see if i set the time at the time of the alarm
    run_setting_mode(0,1,5,8);// H2+ H1+:M2+ M1+

    // wait 1 minute1 to see if the alarm will activate
    $display("=== ALARM CHECK FUNCTIONALITY TEST ===");        
    check_alarm(0,1,5,9,1);
    

    // return to normal mode
    pulse_mode();

    // go to alarm mode
    pulse_mode();

    // deactivate the alarm at 01:59 
    run_alarm_mode(0,0,0,0,1);// H2 H1:M2 M1 on/off

    // waiting 5 minutes in the alarm mode to test if the normal mode works in the background
    tick_1hz(60*5);

    // return to normal mode
    pulse_mode();
    pulse_mode();
    pulse_mode();

    // run normal-mode check for 5 minutes to check the if it's working in the background
    run_normal_mode(5,temp_hour,temp_min,1);//minutes,load_min,load_hour,load signal

    // go to time setting mode
    pulse_mode();
    pulse_mode();
    pulse_mode();

    // run Time checking-mode check setting time to 01:55 to see if it will sound while i deactivated the alarm
    run_setting_mode(0,9,5,6);// H2+ H1+:M2+ M1+ 

    // return to normal mode
    pulse_mode();

    // wait 5 minutes to see if the alarm will activate
    $display("=== ALARM CHECK FUNCTIONALITY TEST ===");
    repeat(5)begin
        tick_1hz(60);
        check_alarm(0,1,5,9,0);
    end


 ////////// Normal stopwatch testing  //////////

    // Reset the design 
    reset();

    // go to stop wtach setting mode
    pulse_mode();
    pulse_mode();

    // run stopwatch checking-mode run 01:05
    pulse_set();//start
    run_stopwatch_mode(65,temp_hour,temp_min,0);//seconds,load_min,load_sec,load signal

    // stop stopwatch checking-mode at 01:05
    pulse_set();//stop
    stop_stopwatch_mode();

    //continue for 10 seconds
    pulse_set();// re-start
    run_stopwatch_mode(10,temp_hour,temp_min,1);//seconds,load_min,load_sec,load signal

    // stop stopwatch checking-mode at 
    pulse_set();//stop
    stop_stopwatch_mode();

    //clear 
    pulse_both();
    // for testing
    @(negedge CLK_tb);
    @(negedge CLK_tb);

    //continue for 10 seconds after the clear
    pulse_set();//start
    run_stopwatch_mode(10,temp_hour,temp_min,1);//seconds,load_min,load_secr,load signal

    //split 
    pulse_both();

    // checking the split and if it will work after it
    split_stopwatch_mode();

    // stop stopwatch checking-mode
    pulse_set();//stop
    stop_stopwatch_mode();

    //continue for 10 seconds
    pulse_set();// re-start
    run_stopwatch_mode(10,temp_hour,temp_min,1);//seconds,load_min,load_sec,load signal

    reset();

    // go to STOPWATCH
    pulse_mode();
    pulse_mode();

    // run stopwatch checking-mode for 1 hour and 10 seconds
    pulse_set();

    // run for 50 minutes first
    run_stopwatch_mode(3000,temp_hour,temp_min,0);//seconds,load_min,load_secr,load signal

    // go to normal mode to check if it will work in the background
    pulse_mode();// 1 second
    pulse_mode();// 1 second

    //run normal mode for minutes 
    repeat(5)
    tick_1hz(60);

    // go to stopwatch mode to check if it will work in the background
    pulse_mode();// 1 second
    pulse_mode();// 1 second

    // run for 5 minutes to check expected time at the stopwatch is 55:04
    run_stopwatch_mode(300,55,4,1);//check that it goes from 59:59--->00:00
    
    $display("Number of succeeded Test Cases= %0d ", passed_cases);
    $display("Number of failed Test Cases= %0d ", failed_cases); 
    $display("Number of succeeded Digit Indicators= %0d ", passed_cases_ind);
    $display("Number of failed Digit Indicators= %0d ", failed_cases_ind); 
    repeat (2)
    @(negedge CLK_tb);
    $stop; 
end  

// so the task can simulate the normal mode in the background alwyas 
always@(*)  
begin 
    temp_min=minute_1_tb+(minute_2_tb*10);
    temp_hour=hours_1_tb+(hours_2_tb*10);
end   


////////// Clock Generator //////////
         
always #(CLK_period/2) CLK_tb = ~CLK_tb;                                                                                     


////////// TASKS //////////

////////// Signals Initialization //////////

task initialize;
begin
    CLK_tb       = 1'b0;
    RST_N_tb     = 1'b0;
    mode_tb      = 1'b0;
    set_tb       = 1'b0;
    passed_cases = 30'd0;
    failed_cases = 30'd0;
    passed_cases_ind= 30'd0;
    failed_cases_ind= 30'd0;
    TEST_NUM     = 0;
    temp_min     = 0;
    temp_hour    = 0;
    alarm_ind    = 0;
end
endtask


////////// RESET //////////

task reset;
begin
    @(negedge CLK_tb);
    RST_N_tb = 1'b0;           // rst is activated
    @(negedge CLK_tb);
    RST_N_tb = 1'b1;
    @(negedge CLK_tb);
end
endtask

task tick_1hz(input integer const);//const is to use it wethier second or minutes 
  integer k;
  begin
    for (k = 0; k < CLOCK_FREQ_HZ_TB*const; k = k + 1) begin
      @(negedge  CLK_tb);
    end
  end
endtask

task pulse_set();
  begin
    @(negedge CLK_tb);
    set_tb = 1'b1;
    @(negedge CLK_tb);
    set_tb = 1'b0;
  end
endtask

task pulse_mode();
  begin
    @(negedge CLK_tb);
    mode_tb = 1'b1;
    @(negedge CLK_tb);
    mode_tb = 1'b0;
  end
endtask

task pulse_both();
  begin
    @(negedge CLK_tb);
    mode_tb = 1'b1;
    set_tb = 1'b1;
    @(negedge CLK_tb);
    mode_tb = 1'b0;
    set_tb = 1'b0;
  end
endtask


// Wait for a minute/hour increment and check expected value (HH:MM as BCD digits)
task check(
    input [5:0] prev_hr,   
    input [5:0] prev_min,
    input  integer consant  
);
    reg [3:0] exp_h1, exp_h2, exp_m1, exp_m2; // ones/tens digits
begin

    // advance 1 "minute" based on frequency
    tick_1hz(consant);

    // expected BCD digits from integer hour/min
    exp_h1 = prev_hr % 10;   // hours ones
    exp_h2 = prev_hr / 10;   // hours tens
    exp_m1 = prev_min % 10;  // minutes ones
    exp_m2 = prev_min / 10;  // minutes tens

    if ( (hours_1_tb  != exp_h1) ||
         (hours_2_tb  != exp_h2) ||
         (minute_1_tb != exp_m1) ||
         (minute_2_tb != exp_m2) ) begin
        failed_cases = failed_cases + 1;
        $display("TIME CHECK FAIL: exp %0d%0d:%0d%0d got %0d%0d:%0d%0d",
                 exp_h2, exp_h1, exp_m2, exp_m1,
                 hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
    end
    else begin
        passed_cases = passed_cases + 1;
        $display("TIME CHECK PASS: %0d%0d:%0d%0d",
                 hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
    end
end
endtask

task check_alarm(input reg  [3:0] exp_h2, exp_h1, exp_m2,exp_m1,input reg load);
    begin
        if (( (hours_1_tb == exp_h1) &&
             (hours_2_tb  == exp_h2) &&
             (minute_1_tb == exp_m1) &&
             (minute_2_tb == exp_m2))) 
        begin
            if ( load && ~sound_tb ) begin
                failed_cases = failed_cases + 1;
                $display("Alarm Activate CHECK FAIL: exp %0d%0d:%0d%0d got %0d%0d:%0d%0d",
                         exp_h2, exp_h1, exp_m2, exp_m1,
                         hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
            end
            else if ( ~load && sound_tb ) begin
                failed_cases = failed_cases + 1;
                $display("Alarm Deactivate CHECK FAIL: exp %0d%0d:%0d%0d got %0d%0d:%0d%0d",
                         exp_h2, exp_h1, exp_m2, exp_m1,
                         hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
            end
            else begin
                passed_cases = passed_cases + 1;
                $display("Alarm CHECK PASS: %0d%0d:%0d%0d",
                         hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
            end
        end
        
    end

endtask

    
task run_normal_mode(input integer minutes,load_hour,load_min ,input reg load);
    integer i;
    reg [5:0] cur_hr;
    reg [5:0] cur_min;
begin

    mode_tb = 1'b0;
    set_tb  = 1'b0;
    
    $display("=== NORMAL MODE FUNCTIONALITY TEST ===");

    // for time setting 
    if(load)begin
        cur_min=load_min;
        cur_hr=load_hour;
    end

    else begin
        cur_hr  = 6'd0;
        cur_min = 6'd0;
        
    end
    // check next minutes increments
    for (i = 0; i < minutes; i = i + 1) begin
        $display("=== TEST %0d : NORMAL MODE ===", TEST_NUM);
         if ((cur_hr==23)&&(cur_min==59))begin
            cur_hr  = 6'd0;
            cur_min = 6'd0; 
            tick_1hz(60); 
        end
        // compute next expected time
        cur_min = cur_min + 1;
        cur_hr  = cur_hr;
        TEST_NUM = TEST_NUM + 1;
        if (cur_min == 60) begin
            cur_min = 0;
            cur_hr  = cur_hr + 1;
        end
        check(cur_hr, cur_min,60);
    end
end
endtask

task run_setting_mode(input integer H2,H1,M2,M1);// how much to increase on the normal mode

    begin

    $display("=== TIME SETTING FUNCTIONALITY TEST ===");
    // Changing the left  Hour digit
    set_tb  = 1'b0;
    mode_tb = 1'b0;
    repeat(H2)begin
        pulse_set();
        if (load_en_hr_2_tb) begin
           $display("=== Time SETTING Indicator H2 Passed ===");
           passed_cases_ind=passed_cases_ind+1;
        end

        else begin
            $display("=== Time SETTING Indicator H2 Faild ===");
            failed_cases_ind=failed_cases_ind+1;
        end
    end
    // Changing the right  Hour digit
    pulse_both();

    repeat(H1)begin
        pulse_set();
        if (load_en_hr_1_tb) begin
           $display("=== Time SETTING Indicator H1 Passed ===");
           passed_cases_ind=passed_cases_ind+1;
        end

        else begin
            $display("=== Time SETTING Indicator H1 Faild ===");
            failed_cases_ind=failed_cases_ind+1;
        end
    end

    // Changing the left  minute digit
    pulse_both();

    repeat(M2)begin
        pulse_set();
        if (load_en_min_2_tb) begin
           $display("=== Time SETTING Indicator M2 Passed ===");
           passed_cases_ind=passed_cases_ind+1;
        end

        else begin
            $display("=== Time SETTING Indicator M2 Faild ===");
            failed_cases_ind=failed_cases_ind+1;
        end
    end

    // Changing the right  minute digit
    pulse_both();

    repeat(M1)begin
        pulse_set();
        if (load_en_min_1_tb) begin
           $display("=== Time SETTING Indicator M1 Passed ===");
           passed_cases_ind=passed_cases_ind+1;
        end

        else begin
            $display("=== Time SETTING Indicator M1 Faild ===");
            failed_cases_ind=failed_cases_ind+1;
        end
    end

end

endtask

task run_alarm_mode(input integer H2,H1,M2,M1, input reg on);

    begin

    $display("=== Alarm FUNCTIONALITY TEST ===");
    // Changing the left  Hour digit
    set_tb  = 1'b0;
    mode_tb = 1'b0;
    pulse_both();
    repeat(H2)begin
        pulse_set();
        if (load_en_hr_2_tb) begin
           $display("=== Time ALARM Indicator H2 Passed ===");
           passed_cases_ind=passed_cases_ind+1;
        end

        else begin
            $display("=== Time ALARM Indicator H2 Faild ===");
            failed_cases_ind=failed_cases_ind+1;
        end
    end

    // Changing the right  Hour digit
    pulse_both();

    repeat(H1)begin
        pulse_set();
        if (load_en_hr_1_tb) begin
           $display("=== Time ALARM Indicator H1 Passed ===");
           passed_cases_ind=passed_cases_ind+1;
        end

        else begin
            $display("=== Time ALARM Indicator H1 Faild ===");
            failed_cases_ind=failed_cases_ind+1;
        end
    end

    // Changing the left  minute digit
    pulse_both();

    repeat(M2)begin
        pulse_set();
        if (load_en_min_2_tb) begin
           $display("=== Time ALARM Indicator M2 Passed ===");
           passed_cases_ind=passed_cases_ind+1;
        end

        else begin
            $display("=== Time ALARM Indicator M2 Faild ===");
            failed_cases_ind=failed_cases_ind+1;
        end

    end

    // Changing the right  minute digit
    pulse_both();

    repeat(M1)begin
        pulse_set();
        if (load_en_min_1_tb) begin
           $display("=== Time ALARM Indicator M1 Passed ===");
           passed_cases_ind=passed_cases_ind+1;
        end

        else begin
            $display("=== Time ALARM Indicator M1 Faild ===");
            failed_cases_ind=failed_cases_ind+1;
        end
    end

    // returning to ideal
    pulse_both();

    // turning on or of the alarm 
    if (on) begin
        pulse_set();
        alarm_ind=~alarm_ind;
    end
end

endtask

task run_stopwatch_mode(input integer seconds,load_hour,load_min ,input reg load);
    integer i;
    reg [5:0] cur_hr;
    reg [5:0] cur_min;
begin

    mode_tb = 1'b0;
    set_tb  = 1'b0;
    $display("=== STOPWATCH Start MODE FUNCTIONALITY TEST ===");

    if(load)begin
        cur_min=load_min;
        cur_hr=load_hour;
    end
    else begin
        cur_hr  = 6'd0;
        cur_min = 6'd0;
    end
        
    // check next seconds increments
    for (i = 0; i < seconds; i = i + 1) begin
        $display("=== TEST %0d : STOP WATCH  start MODE ===", TEST_NUM);
         if ((cur_hr==59)&&(cur_min==59))begin
            cur_hr  = 6'd0;
            cur_min = 6'd0; 
            tick_1hz(1); 
        end
        // compute next expected time
        cur_min = cur_min + 1;
        cur_hr  = cur_hr;
        TEST_NUM = TEST_NUM + 1;
        if (cur_min == 60) begin
            cur_min = 0;
            cur_hr  = cur_hr + 1;
        end
        check(cur_hr, cur_min,1);
    end
end
endtask

task stop_stopwatch_mode();

    reg [3:0] hours_1_test,hours_2_test,minute_1_test,minute_2_test;
    begin
    mode_tb = 1'b0;
    set_tb  = 1'b0;
    
    $display("=== STOP WATCH Stop MODE FUNCTIONALITY TEST ===");

    //saving current results 
    hours_1_test=hours_1_tb;
    hours_2_test=hours_2_tb;
    minute_1_test=minute_1_tb;
    minute_2_test=minute_2_tb;

    repeat(5)/// wait five seconds to check if it will not change
        tick_1hz(1);

    TEST_NUM = TEST_NUM + 1;

    $display("=== TEST %0d : STOP WATCH  stop MODE ===", TEST_NUM);

    if ( (hours_1_tb   != hours_1_test) ||
         (hours_2_tb   != hours_2_test) ||
         (minute_1_tb  != minute_1_test) ||
         (minute_2_tb  != minute_2_test) ) begin
        failed_cases = failed_cases + 1;
        $display("TIME CHECK FAIL: exp %0d%0d:%0d%0d got %0d%0d:%0d%0d",
                 hours_2_test, hours_1_test, minute_2_test, minute_1_test,
                 hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
    end
    else begin
        passed_cases = passed_cases + 1;
        $display("TIME CHECK PASS: %0d%0d:%0d%0d",
                 hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
    end

    end
    
endtask

task split_stopwatch_mode();

    reg [3:0] hours_1_test,hours_2_test,minute_1_test,minute_2_test;
    integer temp_min_sw,temp_hour_sw;
    begin
    mode_tb = 1'b0;
    set_tb  = 1'b0;
    
    $display("=== STOP WATCH Stop MODE FUNCTIONALITY TEST ===");

    //saving current results 
    hours_1_test=hours_1_tb;
    hours_2_test=hours_2_tb;
    minute_1_test=minute_1_tb;
    minute_2_test=minute_2_tb;

    // to give it to the task of the stopwatch
    temp_min_sw=minute_1_test+(minute_2_test*10);
    temp_hour_sw=hours_1_test+(hours_2_test*10);

    repeat(20) begin/// wait 21 seconds to check if it will not change

        tick_1hz(1);
        TEST_NUM = TEST_NUM + 1;
        temp_min_sw=temp_min_sw+1;
        if (temp_min_sw==59) begin
            temp_min_sw=0;
            temp_hour_sw=temp_hour_sw+1;
        end

        if (temp_min_sw==59 && temp_hour_sw==59) begin
            temp_min_sw=0;
            temp_hour_sw=0;
        end

        $display("=== TEST %0d : STOP WATCH  split MODE ===", TEST_NUM);
        if ( (hours_1_tb   != hours_1_test) ||
             (hours_2_tb   != hours_2_test) ||
             (minute_1_tb  != minute_1_test) ||
             (minute_2_tb  != minute_2_test) ) begin
            failed_cases = failed_cases + 1;
            $display("TIME CHECK FAIL: exp %0d%0d:%0d%0d got %0d%0d:%0d%0d",
                     hours_2_test, hours_1_test, minute_2_test, minute_1_test,
                     hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
        end
        else begin
            passed_cases = passed_cases + 1;
            $display("TIME CHECK PASS: %0d%0d:%0d%0d",
                     hours_2_tb, hours_1_tb, minute_2_tb, minute_1_tb);
        end

    end

    // split release
    pulse_both();
    // run and check the time after the split and split release
    run_stopwatch_mode(10,temp_hour_sw,temp_min_sw+1,1);//loading seconds//+1 due to latency in pushing the button

    end
    
endtask


endmodule
