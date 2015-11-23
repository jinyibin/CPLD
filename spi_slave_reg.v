/***************************************************************************************************************
--Module Name:  spi_slave_reg
--Author     :  Jin
--Description:  
                polarity = 0     : idle state of spi clock is low level 
					 phase    = 0     : sample data at the rising edge，send data out at the falling edge
					 16 bits frame    : MSB first
					 data frame format: 2 * 16bits frame-- {address[15:14], address[13:0], data[15:0]}
					                    address[15:14]: 2'b00   write
										                     2'b11   read
             
--History    :  2015-04-13  Created by Jin.                      

***************************************************************************************************************/

`timescale 1ns/100ps
`define  ADDR_NUM 8

module spi_slave_reg
(
  input  wire       clk  ,
  input  wire       rst_n,
  
  input  wire        rx_data_ready,
  input  wire[15:0]  rx_data, 
  output wire        tx_data_ready,
  output reg [15:0]  tx_data,
  
  input  wire[3:0]   board_id,
  
  output reg [3:0]   reg_cpu_mode, // CPU mode indication 
  
  input  wire[15:0]  reg_rc_period    ,//Remote controller Pulse period 
  input  wire[15:0]  reg_rc_pwidth_ch1,// Remote controller pulse width 
  input  wire[15:0]  reg_rc_pwidth_ch2,// Remote controller pulse width  
  input  wire[15:0]  reg_rc_pwidth_ch3,// Remote controller pulse width 
  input  wire[15:0]  reg_rc_pwidth_ch4,// Remote controller pulse width
  input  wire[15:0]  reg_rc_pwidth_ch5,// Remote controller pulse width 
  input  wire[15:0]  reg_rc_pwidth_ch6,// Remote controller pulse width 
				  
  output reg [15:0]  reg_pwm_period   ,// servo PWM signal period
  output reg [15:0]  reg_pwm_width_ch1,// servo PWM signal pulse width for channel1
  output reg [15:0]  reg_pwm_width_ch2,// servo PWM signal pulse width for channel2
  output reg [15:0]  reg_pwm_width_ch3,// servo PWM signal pulse width for channel3
  output reg [15:0]  reg_pwm_width_ch4,// servo PWM signal pulse width for channel4
  output reg [15:0]  reg_pwm_width_ch5,// servo PWM signal pulse width for channel5
  output reg [15:0]  reg_pwm_width_ch6,// servo PWM signal pulse width for channel6
  
  output reg [15:0]  reg_pwm_period7,  //
  output reg [15:0]  reg_pwm_width_ch7,
  output reg [15:0]  reg_pwm_period8,
  output reg [15:0]  reg_pwm_width_ch8,
  
  input  wire        spi_clk_error,
				  
  output reg [1:0]   reg_sonar_control,// Sonar enable or stop,default enable
  input  wire[15:0]  reg_sonar_data   ,// Sonar data 
  output reg         frame_lost_error ,// data frame lost indication,high level pulse
  output wire        watch_dog_pulse  ,// master watch dog
  output reg [15:0]  reg_control      ,// reg to control cpld
  input  wire[31:0]  version           // version of this project

);
//---------------------------------------------------------------------------------------------------------------
  parameter   IDLE   =   2'b00 ,
              READ   =   2'b01 ,
				  WRITE  =   2'b10 ;
//--------------------------------------------------------------------------------------------------------------- 
  parameter   READ_FRAME   =   2'b11 ,
				  WRITE_FRAME  =   2'b00 ,
				  FRAME_LOST_TIME = 12'd2400 ; 
//--------------------------------------------------------------------------------------------------------------- 
               /*   register table   */
  parameter   BOARD_ID_ADDR      =   'h0001 , //Board ID 4'bxxxx ,read only
              CONTROL_ADDR       =   'h0003 , //reg to control cpld
  
    			  CPU_MODE_ADDR      =   'h0005 , // CPU mode indication  4'b0000->self test
				                                  //                      4'b0011->take off
				                                  //                      4'b1100->landing
															 //                      4'b1111->cruise
				  RC_PERIOD_ADDR     =   'h0009 , // Remote controller Pulse period ,read only
				  RC_PWIDTH_CH1_ADDR =   'h000A , // Remote controller pulse width  ,read only
				  RC_PWIDTH_CH2_ADDR =   'h000B , // Remote controller pulse width  ,read only
				  RC_PWIDTH_CH3_ADDR =   'h000C , // Remote controller pulse width  ,read only
				  RC_PWIDTH_CH4_ADDR =   'h000D , // Remote controller pulse width  ,read only
				  RC_PWIDTH_CH5_ADDR =   'h000E , // Remote controller pulse width  ,read only
				  RC_PWIDTH_CH6_ADDR =   'h000F , // Remote controller pulse width  ,read only				  
				  
				  PWM_PERIOD_ADDR    =   'h0010 , // servo PWM signal period
				  PWM_WIDTH_CH1_ADDR =   'h0011 , // servo PWM signal pulse width for channel1
				  PWM_WIDTH_CH2_ADDR =   'h0012 , // servo PWM signal pulse width for channel2 
				  PWM_WIDTH_CH3_ADDR =   'h0013 , // servo PWM signal pulse width for channel3
				  PWM_WIDTH_CH4_ADDR =   'h0014 , // servo PWM signal pulse width for channel4
				  PWM_WIDTH_CH5_ADDR =   'h0015 , // servo PWM signal pulse width for channel5
				  PWM_WIDTH_CH6_ADDR =   'h0016 , // servo PWM signal pulse width for channel6
				  PWM_DATA_LOAD_ADDR =   'h00FF , // write any data to this address will load the PWM width data to the PWM counter
				  
				  SONAR_CONTROL_ADDR =   'h001A , // Sonar enable or stop,default enable
				  SONAR_DATA_ADDR    =   'h001B , // Sonar data ,read only
				  VERSION_LOW_ADDR   =   'h001D , // Version Reg lower 16bits
				  VERSION_HIGH_ADDR  =   'h001E , // version reg higher 16bits
				  
				  FPGA_STATUS_ADDR   =   'h001F , 
				  
				  PWM_PERIOD7_ADDR   =   'h0020 , // PWM signal period
				  PWM_WIDTH_CH7_ADDR =   'h0021 , // PWM signal pulse width for channel7				  
				  PWM_PERIOD8_ADDR   =   'h0022 , // PWM signal period
				  PWM_WIDTH_CH8_ADDR =   'h0023 ; // PWM signal pulse width for channel7
//---------------------------------------------------------------------------------------------------------------
  reg [1:0]   state     ;
  reg [1:0]   next_state;
  always @ (posedge clk or negedge rst_n)
     begin
	    if(!rst_n)
		   state <= IDLE;
		 else
		   state <= next_state; 
	  end
//---------------------------------------------------------------------------------------------------------------	
     /* count the time between address frame and data frame  */
  reg [11:0]  frame_interval_counter;
  always @ (posedge clk or negedge rst_n)
     if(!rst_n )
	    frame_interval_counter <= 12'd0;
	  else if(state == IDLE)
	    frame_interval_counter <= 12'd0;
	  else if(state == READ)
	    frame_interval_counter <= frame_interval_counter + 12'd1;
	  else if(state == WRITE)
	    frame_interval_counter <= frame_interval_counter + 12'd1;
//--------------------------------------------------------------------------------------------------------------- 

  always@(*)
    begin
    next_state = IDLE;
    case(state)
	      IDLE   : if(rx_data_ready && (rx_data[15:14]==WRITE_FRAME))
			           next_state = WRITE ;
						else if(rx_data_ready && (rx_data[15:14]==READ_FRAME))
						  next_state = READ;	
						else
				        next_state = IDLE;		
			READ   : if(rx_data_ready || (frame_interval_counter == FRAME_LOST_TIME))
			           next_state = IDLE ;
						else 
		              next_state = READ;
			WRITE  : if(rx_data_ready || (frame_interval_counter == FRAME_LOST_TIME))
			           next_state = IDLE ;
						else 
		              next_state = WRITE;
			default: next_state = IDLE;
	 endcase
	 end
//--------------------------------------------------------------------------------------------------------------- 
    /*  signify an error if data frame did not show up FRAME_LOST_TIME after address frame  */
	always @ (posedge clk or negedge rst_n)
	  if(!rst_n)
	    frame_lost_error <= 1'b0;
	  else if(frame_interval_counter == FRAME_LOST_TIME)
	    frame_lost_error <= 1'b1;
	  else
	    frame_lost_error <= 1'b0;

//---------------------------------------------------------------------------------------------------------------
     /*  tx_data_ready ,active for one clk cycle   */
  reg [1:0]  tx_data_ready_d;
  always @ (posedge clk or negedge rst_n)
     if(!rst_n)
	    tx_data_ready_d <= 2'b00;
	  else begin
	         if(state == READ)
				  begin
	              tx_data_ready_d[0] <= 1'b1;
					  tx_data_ready_d[1] <= tx_data_ready_d[0];
				  end
	         else 
				  begin
	              tx_data_ready_d[0] <= 1'b0;
					  tx_data_ready_d[1] <= 1'b0;
				  end
			 end
	assign tx_data_ready = tx_data_ready_d[0] &(~tx_data_ready_d[1]);
//---------------------------------------------------------------------------------------------------------------	
       /*  latch R/W address  */
	reg [`ADDR_NUM-1:0]    reg_address;
	
	always @ (posedge clk or negedge rst_n)
	  begin
	    if(!rst_n)
		   reg_address <= `ADDR_NUM'd0;
		 else if(state == IDLE)
		   begin 
    		  if(rx_data_ready)
		        reg_address <= rx_data[`ADDR_NUM-1:0];
			  else
			     reg_address <= `ADDR_NUM'd0;
		   end
		 else
		  reg_address <= reg_address;	
	  end 
//---------------------------------------------------------------------------------------------------------------	  
reg [7:0]  error1;
reg [7:0]  error2;
reg        spi_clk_error_buf;
wire       spi_clk_error_edge;
always @ (posedge clk or negedge rst_n)
     if(!rst_n)
	    spi_clk_error_buf <= 1'b0;
	  else begin
	         spi_clk_error_buf <= spi_clk_error;
			 end	
assign spi_clk_error_edge=spi_clk_error & (~spi_clk_error_buf);

always @ (posedge clk or negedge rst_n)
     if(!rst_n)
	    error1 <= 8'd0;
	  else if(spi_clk_error_edge)
	    error1 <= error1 + 1'b1;


always @ (posedge clk or negedge rst_n)
     if(!rst_n)
	    error2 <= 8'd0;
	  else if(frame_lost_error)
	    error2 <= error2 + 1'b1;
			 
//---------------------------------------------------------------------------------------------------------------	
       /*  write register  */
  always @ (posedge clk or negedge rst_n)
    begin
		 if(!rst_n)
		     begin
					reg_cpu_mode      <= 4'd0;		
		         reg_control       <= 16'd0;			
               reg_pwm_period    <= 16'd20000;// default servo pwm period,20ms
		         reg_pwm_width_ch1 <= 16'd1500;
		         reg_pwm_width_ch2 <= 16'd1500;
		         reg_pwm_width_ch3 <= 16'd1500;
		         reg_pwm_width_ch4 <= 16'd1500;
		         reg_pwm_width_ch5 <= 16'd1500;
		         reg_pwm_width_ch6 <= 16'd1500;		 
		         reg_sonar_control <= 2'b00;   // default sonar enable
               reg_pwm_period7   <= 16'd0;
		         reg_pwm_width_ch7 <= 16'd0;	
	            reg_pwm_period8   <= 16'd0;
		         reg_pwm_width_ch8 <= 16'd0;				
		      end
		 else if((state == WRITE) && rx_data_ready)
		      begin
		          if(reg_address==CPU_MODE_ADDR       )        reg_cpu_mode      <= rx_data[3:0]; 
					 else if(reg_address==CONTROL_ADDR     )      reg_control       <= rx_data;
		          else if(reg_address==PWM_PERIOD_ADDR     )   reg_pwm_period    <= rx_data;
		          else if(reg_address==PWM_WIDTH_CH1_ADDR  )   reg_pwm_width_ch1 <= rx_data;
		          else if(reg_address==PWM_WIDTH_CH2_ADDR  )   reg_pwm_width_ch2 <= rx_data;
		          else if(reg_address==PWM_WIDTH_CH3_ADDR  )   reg_pwm_width_ch3 <= rx_data;
		          else if(reg_address==PWM_WIDTH_CH4_ADDR  )   reg_pwm_width_ch4 <= rx_data;
		          else if(reg_address==PWM_WIDTH_CH5_ADDR  )   reg_pwm_width_ch5 <= rx_data;
		          else if(reg_address==PWM_WIDTH_CH6_ADDR  )   reg_pwm_width_ch6 <= rx_data;		 
		          else if(reg_address==SONAR_CONTROL_ADDR  )   reg_sonar_control <= rx_data[1:0] ;
		          else if(reg_address==PWM_PERIOD7_ADDR     )  reg_pwm_period7   <= rx_data;
		          else if(reg_address==PWM_WIDTH_CH7_ADDR  )   reg_pwm_width_ch7 <= rx_data;
					 else if(reg_address==PWM_PERIOD8_ADDR     )  reg_pwm_period8   <= rx_data;
		          else if(reg_address==PWM_WIDTH_CH8_ADDR  )   reg_pwm_width_ch8 <= rx_data;
				end

	 end
//---------------------------------------------------------------------------------------------------------------	
       /*  read register  */
  always @ (posedge clk)
    begin
	    if(state == READ)
		   begin
           if     (reg_address==BOARD_ID_ADDR      )           tx_data <= {12'd0,board_id};
			  else if(reg_address==CONTROL_ADDR       )           tx_data <= reg_control;
		 
		     else if(reg_address==CPU_MODE_ADDR       )           tx_data <= {12'd0,reg_cpu_mode };
		 
		     else if(reg_address==RC_PERIOD_ADDR      )           tx_data <= reg_rc_period     ;
		     else if(reg_address==RC_PWIDTH_CH1_ADDR  )           tx_data <= reg_rc_pwidth_ch1 ;
		     else if(reg_address==RC_PWIDTH_CH2_ADDR  )           tx_data <= reg_rc_pwidth_ch2 ;
		     else if(reg_address==RC_PWIDTH_CH3_ADDR  )           tx_data <= reg_rc_pwidth_ch3 ;
		     else if(reg_address==RC_PWIDTH_CH4_ADDR  )           tx_data <= reg_rc_pwidth_ch4 ;
		     else if(reg_address==RC_PWIDTH_CH5_ADDR  )           tx_data <= reg_rc_pwidth_ch5 ;
		     else if(reg_address==RC_PWIDTH_CH6_ADDR  )           tx_data <= reg_rc_pwidth_ch6 ;
		 
		     else if(reg_address==PWM_PERIOD_ADDR     )           tx_data <= reg_pwm_period    ;
		     else if(reg_address==PWM_WIDTH_CH1_ADDR  )           tx_data <= reg_pwm_width_ch1 ;
		     else if(reg_address==PWM_WIDTH_CH2_ADDR  )           tx_data <= reg_pwm_width_ch2 ;
		     else if(reg_address==PWM_WIDTH_CH3_ADDR  )           tx_data <= reg_pwm_width_ch3 ;
		     else if(reg_address==PWM_WIDTH_CH4_ADDR  )           tx_data <= reg_pwm_width_ch4 ;
		     else if(reg_address==PWM_WIDTH_CH5_ADDR  )           tx_data <= reg_pwm_width_ch5 ;
		     else if(reg_address==PWM_WIDTH_CH6_ADDR  )           tx_data <= reg_pwm_width_ch6 ;
			  		 
		     else if(reg_address==SONAR_CONTROL_ADDR  )           tx_data <= {14'd0,reg_sonar_control} ;
		     else if(reg_address==SONAR_DATA_ADDR     )           tx_data <= reg_sonar_data            ;
			  else if(reg_address==VERSION_LOW_ADDR    )           tx_data <= version[15:0]            ;
			  else if(reg_address==VERSION_HIGH_ADDR   )           tx_data <= version[31:16]            ;
			  
			  else if(reg_address==PWM_PERIOD7_ADDR     )          tx_data <= reg_pwm_period7    ;
		     else if(reg_address==PWM_WIDTH_CH7_ADDR  )           tx_data <= reg_pwm_width_ch7 ;
			  else if(reg_address==PWM_PERIOD8_ADDR     )          tx_data <= reg_pwm_period8    ;
		     else if(reg_address==PWM_WIDTH_CH8_ADDR  )           tx_data <= reg_pwm_width_ch8 ;
			  else if(reg_address==FPGA_STATUS_ADDR  )             tx_data <= {error2,error1} ;
			end
		 else tx_data <= 16'd0;
	 end
  
//---------------------------------------------------------------------------------------------------------------
     /* every time all pwm_width_ch is updated(suppose ch6 is the last to updated) ,generate watch_dog_pulse */
  assign watch_dog_pulse = (state == WRITE) & rx_data_ready & (reg_address==PWM_DATA_LOAD_ADDR);

endmodule