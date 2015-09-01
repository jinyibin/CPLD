/**************************************************************************
--Module Name:  pwm_gen_rsv
--Author     :  Jin
--Description:   pulse width modulation signal generator 
                1MHz PWM clk
                xxx xxx xxx xxx
--History    :  2015-07-20  Created by Jin.
                           

***************************************************************************/
`timescale 1ns/100ps
`define  WORDSIZE 15

module  pwm_gen_rsv
(
  input  wire        clk               ,  // default 24MHz
  input  wire        rst_n             , 
  input  wire        pwm_clk           ,  // 1MHz pwm capturing clock---1us resolution 
  
  input  wire [`WORDSIZE-1:0] pulse_period      ,  // pulse period of pwm signal.1 LSB = 1us .
  
  input  wire [`WORDSIZE-1:0] pulse_width_ch   ,  // pulse width of pwm signal for channel 1. 1 LSB= 1us
  
  output reg    pwm_out   

);

//-------------------------------------------------------------------------
  reg  [`WORDSIZE-1:0]  pulse_period_counter    ;
  
  reg  [`WORDSIZE-1:0]  pulse_width_channel   ;

  
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
				     pulse_width_channel<= pulse_width_ch;
				   end
			else if(pwm_clk)
			        begin
			            if(pulse_period_counter == pulse_period)
			               begin
					            pulse_width_channel<= pulse_width_ch;
		                   end							
			        end
		end 
 //-------------------------------------------------------------------------
  always @ (posedge clk or negedge rst_n)
	   begin
		   if(!rst_n)
			   pwm_out <= 1'd0 ;
			else 
			    begin
			      if(pulse_period_counter <= pulse_width_channel)
			         pwm_out <= 1'd1 ;
               else 
                  pwm_out <= 1'd0 ;					
			    end
		end  
 //-------------------------------------------------------------------------
 
 
endmodule