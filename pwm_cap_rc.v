/***************************************************************************************************************
--Module Name:  pwm_cap_rc
--Author     :  Jin
--Description:  6 channels pulse capture for RC (remote control )receiver.
                1MHz PWM capturing clk.
					 pulse width couting number updated at the falling edge of each pulse 
                xxx xxx xxx xxx
--History    :  20`WORDSIZE-1-04-10  Created by Jin.
                           

***************************************************************************************************************/
`timescale 1ns/100ps
`define  WORDSIZE 15

module pwm_cap_rc
(
  input  wire        clk               ,  // default 24MHz
  input  wire        rst_n             ,  
  input  wire        pwm_clk           ,  // 1MHz pwm capturing clock
  
  input  wire        rc_en_in          ,  // Remote control enable.High level enables PWM capturing
  
  output reg  [`WORDSIZE-1:0] pulse_width_ch1   ,  // pulse width of pwm signal for channel 1. 1 LSB= 1us
  output reg  [`WORDSIZE-1:0] pulse_width_ch2   ,
  output reg  [`WORDSIZE-1:0] pulse_width_ch3   ,
  output reg  [`WORDSIZE-1:0] pulse_width_ch4   ,
  output reg  [`WORDSIZE-1:0] pulse_width_ch5   ,
  output reg  [`WORDSIZE-1:0] pulse_width_ch6   ,
  output reg  [`WORDSIZE-1:0] pulse_period      ,  // pulse period of rc pwm signal;1 LSB = 1us
  
  input  wire [5:0]  pwm_in   

);
//----------------------------------------------------------------------------------------------------

	           
//-----------------------------------------------------------------------------------------------------
           /* 1MHz sampling of pwm_in  */
	 reg [5:0]    pwm_in_buf1;
    reg [5:0]    pwm_in_buf2;
	 reg [5:0]    pwm_in_buf3;
	 
	 always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
			  begin
			   pwm_in_buf1 <= 6'd0;
				pwm_in_buf2 <= 6'd0;
				pwm_in_buf3 <= 6'd0;
			  end
			else if(pwm_clk)
			        begin
			          pwm_in_buf1 <= pwm_in      ;
						 pwm_in_buf2 <= pwm_in_buf1 ;
						 pwm_in_buf3 <= pwm_in_buf2 ;
					  end
		end
 //---------------------------------------------------------------------------------------------------
         /*  pulse width counting of channel 1  */
    reg[`WORDSIZE-1:0]  pulse_width_counter1;
	 wire       negedge_pwm_in1;
	 
	 assign negedge_pwm_in1 = pwm_in_buf3[0]&(~pwm_in_buf2[0]);
 
	 
	 always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
			  pulse_width_counter1 <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
					    if(pwm_in_buf2[0]==1'd1)  // counting at high level
						    pulse_width_counter1 <= pulse_width_counter1 + `WORDSIZE'd1;
						 else 
							 pulse_width_counter1 <= `WORDSIZE'd0; 
					  end
		end
		
	always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
				pulse_width_ch1      <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
						if (negedge_pwm_in1) // latch counting number at falling edge and reset counter
						    begin
							   pulse_width_ch1      <= pulse_width_counter1;
							 end						   
					  end
		end
//------------------------------------------------------------------------------------------------------ 
         /*  pulse width counting of channel 2  */
    reg[`WORDSIZE-1:0]  pulse_width_counter2;
	 wire       negedge_pwm_in2;
	 
	 assign negedge_pwm_in2 = pwm_in_buf3[1]&(~pwm_in_buf2[1]);
 
	 
	 always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
			  pulse_width_counter2 <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
					    if(pwm_in_buf2[1]==1'd1)  // counting at high level
						    pulse_width_counter2 <= pulse_width_counter2 + `WORDSIZE'd1;
						 else 
							 pulse_width_counter2 <= `WORDSIZE'd0; 
					  end
		end
		
	always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
				pulse_width_ch2      <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
						if (negedge_pwm_in2) // latch counting number at falling edge and reset counter
						    begin
							   pulse_width_ch2      <= pulse_width_counter2;
							 end						   
					  end
		end
//-------------------------------------------------------------------------------------------------------- 
         /*  pulse width counting of channel 3  */
    reg[`WORDSIZE-1:0]  pulse_width_counter3;
	 wire       negedge_pwm_in3;
	 
	 assign negedge_pwm_in3 = pwm_in_buf3[2]&(~pwm_in_buf2[2]);
 
	 
	 always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
			  pulse_width_counter3 <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
					    if(pwm_in_buf2[2]==1'd1)  // counting at high level
						    pulse_width_counter3 <= pulse_width_counter3 + `WORDSIZE'd1;
						 else 
							 pulse_width_counter3 <= `WORDSIZE'd0; 
					  end
		end
		
	always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
				pulse_width_ch3      <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
						if (negedge_pwm_in3) // latch counting number at falling edge and reset counter
						    begin
							   pulse_width_ch3      <= pulse_width_counter3;
							 end						   
					  end
		end
//-------------------------------------------------------------------------------------------------------- 
         /*  pulse width counting of channel 4  */
    reg[`WORDSIZE-1:0]  pulse_width_counter4;
	 wire       negedge_pwm_in4;
	 
	 assign negedge_pwm_in4 = pwm_in_buf3[3]&(~pwm_in_buf2[3]);
 
	 
	 always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
			  pulse_width_counter4 <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
					    if(pwm_in_buf2[3]==1'd1)  // counting at high level
						    pulse_width_counter4 <= pulse_width_counter4 + `WORDSIZE'd1;
						 else 
							 pulse_width_counter4 <= `WORDSIZE'd0; 
					  end
		end
		
	always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
				pulse_width_ch4      <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
						if (negedge_pwm_in4) // latch counting number at falling edge and reset counter
						    begin
							   pulse_width_ch4      <= pulse_width_counter4;
							 end						   
					  end
		end
//---------------------------------------------------------------------------------------------------- 
         /*  pulse width counting of channel 5  */
    reg[`WORDSIZE-1:0]  pulse_width_counter5;
	 wire       negedge_pwm_in5;
	 
	 assign negedge_pwm_in5 = pwm_in_buf3[4]&(~pwm_in_buf2[4]);
 
	 
	 always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
			  pulse_width_counter5 <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
					    if(pwm_in_buf2[4]==1'd1)  // counting at high level
						    pulse_width_counter5 <= pulse_width_counter5 + `WORDSIZE'd1;
						 else 
							 pulse_width_counter5 <= `WORDSIZE'd0; 
					  end
		end
		
	always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
				pulse_width_ch5      <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
						if (negedge_pwm_in5) // latch counting number at falling edge and reset counter
						    begin
							   pulse_width_ch5      <= pulse_width_counter5;
							 end						   
					  end
		end
//------------------------------------------------------------------------------------------------------ 
         /*  pulse width counting of channel 6 */
    reg[`WORDSIZE-1:0]  pulse_width_counter6;
	 wire       negedge_pwm_in6;
	 
	 assign negedge_pwm_in6 = pwm_in_buf3[5]&(~pwm_in_buf2[5]);
 
	 
	 always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
			  pulse_width_counter6 <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
					    if(pwm_in_buf2[5]==1'd1)  // counting at high level
						    pulse_width_counter6 <= pulse_width_counter6 + `WORDSIZE'd1;
						 else 
							 pulse_width_counter6 <= `WORDSIZE'd0; 
					  end
		end
		
	always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
				pulse_width_ch6      <= `WORDSIZE'd0;
			else if(pwm_clk)
			        begin
						if (negedge_pwm_in6) // latch counting number at falling edge and reset counter
						    begin
							   pulse_width_ch6      <= pulse_width_counter6;
							 end						   
					  end
		end
//---------------------------------------------------------------------------- -------------------------
      /* pulse period counting  */
  reg [`WORDSIZE-1:0]   pulse_period_counter;
  wire         posedge_pwm_in1;
  
  assign posedge_pwm_in1 = pwm_in_buf2[0]&(~pwm_in_buf3[0]);
  
  	 always @ (posedge clk or negedge rst_n)
	   begin
		   //if((!rst_n)||(!rc_en_in))
			if(!rst_n)
			   begin
			     pulse_period_counter <= `WORDSIZE'd0;
				  pulse_period         <= `WORDSIZE'd0;
				end
			else if(pwm_clk)
			        begin
					    if(!posedge_pwm_in1)  // counting at low level
						    pulse_period_counter <= pulse_period_counter + `WORDSIZE'd1;
						 else if (posedge_pwm_in1) // latch counting number at rising edge and reset counter
						    begin
							   pulse_period         <= pulse_period_counter + `WORDSIZE'd1;
							   pulse_period_counter <= `WORDSIZE'd0; 
							 end						   
					  end
		end
//---------------------------------------------------------------------------- -------------------------  

endmodule