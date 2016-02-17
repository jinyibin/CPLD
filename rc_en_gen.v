/***************************************************************************************************************
--Module Name:  sonar_ctrl
--Author     :  Jin
--Description:  enable sonar ranging when necessary
                read sonar ranging data(PWM pulse)
--History    :  2015-04-18  Created by Jin.                          

***************************************************************************************************************/
`timescale 1ns/100ps

module sonar_ctrl
(  input  wire       clk  ,
   input  wire       rst_n,
	input  wire       pwm_clk,        // 1MHz clock to sample pwm pulse
	
	input  wire [1:0] sonar_ctrl_reg, // sonar mode selection
	output reg  [15:0]sonar_data   ,  // sonar PWM pulse width(us)
	
	output  wire      sonar_out ,     // sonar enable:low level stop sonar ranging
	input wire        sonar_in        // sonar PWM pulse output
);
//-------------------------------------------------------------------------------------------------------------
  reg  [2:0]    sonar_in_buf;
  reg  [15:0]   sample_cnt  ;
  wire          negedge_sonar_in;
//-------------------------------------------------------------------------------------------------------------
  always @ (posedge clk or negedge rst_n)
    if(!rst_n)
	    sonar_in_buf <= 3'b000;
	 else
	    sonar_in_buf <= {sonar_in_buf[1:0],~sonar_in};//pwm signal from sonar is inverted by a mosfet
			
  assign negedge_sonar_in = (~sonar_in_buf[1])&sonar_in_buf[2];
//-------------------------------------------------------------------------------------------------------------  
    /* sampling sonar pwm pulse at 1us resolution */
	 
  always @ (posedge clk or negedge rst_n)
    if(!rst_n )
	    sample_cnt <= 16'd0;
	 else if (sonar_ctrl_reg[0])
	    sample_cnt <= 16'd0;
	 else if(pwm_clk)  
	    begin
	      if(sonar_in_buf[2])
	        sample_cnt <= sample_cnt + 16'd1;
			else
			  sample_cnt <= 16'd0;
		 end
//------------------------------------------------------------------------------------------------------------- 
	always @ (posedge clk or negedge rst_n)
	  if(!rst_n)
	     sonar_data <= 16'd0;
	  else if(negedge_sonar_in)  //load pwm pulse width at falling edge
	     sonar_data <= sample_cnt;
//-------------------------------------------------------------------------------------------------------------
  assign sonar_out = sonar_ctrl_reg[0];

endmodule