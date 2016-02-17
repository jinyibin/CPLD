/***************************************************************************************************************
--Module Name:  rc_en_process
--Author     :  Jin
--Description:  generate switching rc_en_out signal from pwm rc_en_in
                
--History    :  2015-12-28  Created by Jin.                          

***************************************************************************************************************/
`timescale 1ns/100ps

module rc_en_process
(  input  wire       clk  ,
   input  wire       rst_n,
	input  wire       pwm_clk,        // 1MHz clock to sample pwm pulse
	
	input  wire       rc_en_in,       // pwm signal,14ms period,pulse width 1.1ms---1.9ms
	output reg        rc_en_out       // high level active

);
//-------------------------------------------------------------------------------------------------------------
  reg           rc_in_buf;
  reg  [15:0]   sample_cnt  ;
  wire          negedge_rc_in;
//-------------------------------------------------------------------------------------------------------------
  always @ (posedge clk or negedge rst_n)
    if(!rst_n)
	    rc_in_buf <= 1'b0;
	 else
	    rc_in_buf <= rc_en_in;
			
  assign negedge_rc_in = (~rc_en_in)&rc_in_buf;
//-------------------------------------------------------------------------------------------------------------  
    /* sampling  pwm pulse at 1us resolution */
	 
  always @ (posedge clk or negedge rst_n)
    if(!rst_n )
	    sample_cnt <= 16'd0;
	 else if(pwm_clk)  
	    begin
	      if(rc_in_buf)
	        sample_cnt <= sample_cnt + 16'd1;
			else
			  sample_cnt <= 16'd0;
		 end
//------------------------------------------------------------------------------------------------------------- 
	always @ (posedge clk or negedge rst_n)
	  if(!rst_n)
	     rc_en_out <= 1'd0;
	  else if(negedge_rc_in)  //load pwm pulse width at falling edge
	     begin
		    if(sample_cnt>1400)
	          rc_en_out <= 1'b1;
			 else
			    rc_en_out <= 1'b0;
		  end
//-------------------------------------------------------------------------------------------------------------


endmodule