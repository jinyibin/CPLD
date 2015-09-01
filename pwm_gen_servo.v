/**************************************************************************
--Module Name:  pwm_gen_servo
--Author     :  Jin
--Description:  6 channels pulse width modulation signal generator for servo
                1MHz PWM clk
                xxx xxx xxx xxx
--History    :  2015-04-10  Created by Jin.
                           

***************************************************************************/
`timescale 1ns/100ps
`define  WORDSIZE 15

module  pwm_gen_servo 
(
  input  wire        clk               ,  // default 24MHz
  input  wire        rst_n             , 
  input  wire        pwm_clk           ,  // 1MHz pwm capturing clock---1us resolution 
  
  input  wire [`WORDSIZE-1:0] pulse_period      ,  // pulse period of pwm signal.1 LSB = 1us .20000us for Futaba ,JR,Hiltec servo
  
  input  wire [`WORDSIZE-1:0] pulse_width_ch1   ,  // pulse width of pwm signal for channel 1. 1 LSB= 1us
  input  wire [`WORDSIZE-1:0] pulse_width_ch2   ,
  input  wire [`WORDSIZE-1:0] pulse_width_ch3   ,
  input  wire [`WORDSIZE-1:0] pulse_width_ch4   ,
  input  wire [`WORDSIZE-1:0] pulse_width_ch5   ,
  input  wire [`WORDSIZE-1:0] pulse_width_ch6   ,
  
  input  wire        data_update_flag , // high level pulse means all 6 new pulse width data have been arrived
  
  output reg  [5:0]  pwm_out   

);

//-------------------------------------------------------------------------
  reg  [`WORDSIZE-1:0]  pulse_period_counter    ;
  
  reg  [`WORDSIZE-1:0]  pulse_width_channel1    ;
  reg  [`WORDSIZE-1:0]  pulse_width_channel2    ;
  reg  [`WORDSIZE-1:0]  pulse_width_channel3    ;
  reg  [`WORDSIZE-1:0]  pulse_width_channel4    ;
  reg  [`WORDSIZE-1:0]  pulse_width_channel5    ;
  reg  [`WORDSIZE-1:0]  pulse_width_channel6    ;
  
  reg  data_ready;
  reg  data_ready_clear;
  
 //-------------------------------------------------------------------------
     /* if 6 pwm width datas arrive acrossing the pulse_period ,
	   * then some channel will be updated 20ms later ,so we have to
		* make sure all 6 channels to be updated at the same time
		*/
 	   always @ (posedge clk or negedge rst_n)
        if(!rst_n)
		     data_ready <= 1'b0;
		  else if(data_ready_clear)
		     data_ready <= 1'b0;
		  else if(data_update_flag)
		     data_ready <= 1'b1;
 //-------------------------------------------------------------------------
                     /* pulse period Timer */
	   always @ (posedge clk or negedge rst_n)
        if(!rst_n)
		     pulse_period_counter <= `WORDSIZE'd1;
		  else begin
		         if( pwm_clk )
					   begin
			           if(pulse_period_counter == pulse_period )
				           pulse_period_counter <= `WORDSIZE'd1;
				        else 
					        pulse_period_counter <= pulse_period_counter + `WORDSIZE'd1;					  
			         end
              end
 //-------------------------------------------------------------------------
           /* pulse width load at the end of every period of pulse */
    always @ (posedge clk or negedge rst_n)
	   begin
		   if(!rst_n)
			      begin
				     pulse_width_channel1 <= pulse_width_ch1;
					  pulse_width_channel2 <= pulse_width_ch2;
					  pulse_width_channel3 <= pulse_width_ch3;
				     pulse_width_channel4 <= pulse_width_ch4;
					  pulse_width_channel5 <= pulse_width_ch5;
					  pulse_width_channel6 <= pulse_width_ch6;
					  data_ready_clear <= 1'b0;
				   end
			else if(pwm_clk)
			        begin
			            if((pulse_period_counter == pulse_period) && (data_ready == 1'b1)) // make sure all 6 channel updated at the same time
			               begin
					            pulse_width_channel1 <= pulse_width_ch1;
						         pulse_width_channel2 <= pulse_width_ch2;
						         pulse_width_channel3 <= pulse_width_ch3;
						         pulse_width_channel4 <= pulse_width_ch4;
						         pulse_width_channel5 <= pulse_width_ch5;
						         pulse_width_channel6 <= pulse_width_ch6;	
									data_ready_clear <= 1'b1;
		                   end	
			            else
	                    data_ready_clear <= 0;						
			        end
		end 
 //-------------------------------------------------------------------------
  always @ (posedge clk or negedge rst_n)
	   begin
		   if(!rst_n)
			   pwm_out[0] <= 1'd0 ;
			else 
			    begin
			      if(pulse_period_counter <= pulse_width_channel1)
			         pwm_out[0] <= 1'd1 ;
               else 
                  pwm_out[0] <= 1'd0 ;					
			    end
		end  
 //-------------------------------------------------------------------------
 always @ (posedge clk or negedge rst_n)
	   begin
		   if(!rst_n)
			   pwm_out[1] <= 1'd0 ;
			else 
			    begin
			      if(pulse_period_counter <= pulse_width_channel2)
			         pwm_out[1] <= 1'd1 ;
               else 
                  pwm_out[1] <= 1'd0 ;					
			    end
		end  
 //-------------------------------------------------------------------------
  always @ (posedge clk or negedge rst_n)
	   begin
		   if(!rst_n)
			   pwm_out[2] <= 1'd0 ;
			else 
			    begin
			      if(pulse_period_counter <= pulse_width_channel3)
			         pwm_out[2] <= 1'd1 ;
               else 
                  pwm_out[2] <= 1'd0 ;					
			    end
		end  
 //-------------------------------------------------------------------------
  always @ (posedge clk or negedge rst_n)
	   begin
		   if(!rst_n)
			   pwm_out[3] <= 1'd0 ;
			else 
			    begin
			      if(pulse_period_counter <= pulse_width_channel4)
			         pwm_out[3] <= 1'd1 ;
               else 
                  pwm_out[3] <= 1'd0 ;					
			    end
		end  
 //-------------------------------------------------------------------------
  always @ (posedge clk or negedge rst_n)
	   begin
		   if(!rst_n)
			   pwm_out[4] <= 1'd0 ;
			else 
			    begin
			      if(pulse_period_counter <= pulse_width_channel5)
			         pwm_out[4] <= 1'd1 ;
               else 
                  pwm_out[4] <= 1'd0 ;					
			    end
		end  
 //-------------------------------------------------------------------------
  always @ (posedge clk or negedge rst_n)
	   begin
		   if(!rst_n)
			   pwm_out[5] <= 1'd0 ;
			else 
			    begin
			      if(pulse_period_counter <= pulse_width_channel6)
			         pwm_out[5] <= 1'd1 ;
               else 
                  pwm_out[5] <= 1'd0 ;					
			    end
		end  
 //-------------------------------------------------------------------------
 
endmodule