`timescale 1ns/1ps

module test_top;

  reg clk;
  reg rst_n;
  
  wire [9:0] pwm_out;
  
  reg [15:0] pulse_period      ; 
  
  reg [15:0] pulse_width_ch1   ;
  reg [15:0] pulse_width_ch2   ;
  reg [15:0] pulse_width_ch3   ;
  reg [15:0] pulse_width_ch4   ;
  reg [15:0] pulse_width_ch5   ;
  reg [15:0] pulse_width_ch6 ;
  
  wire  [15:0]  pulse_period_rc;
  
  wire          cpu1_rst_n;
  reg           cpu1_a5_wtdog;
  reg           cpu1_m4_wtdog;
  wire   [9:0]   cpu1_pwm;
  wire          cpu1_rc_en;
  reg           cpu1_pwm_cap_en;

  reg   [1:0]   cpu1_spi_cs;
  reg           cpu1_spi_sck;
  reg           cpu1_spi_out;
  wire          cpu1_spi_in;
       
  wire  [7:0]   cpu1_gpio;

  wire          cpu1_uart1_tx;
  wire          cpu1_uart1_rx;
  wire          cpu1_uart2_tx;
  wire          cpu1_uart2_rx;
  wire          cpu1_uart3_tx;
  wire          cpu1_uart3_rx;
  wire          cpu1_uart4_tx;
  wire          cpu1_uart4_rx;
		 
  wire          cpu1_can_rx;
  wire          cpu1_can_tx;

  wire          cpu2_rst_n;
  wire          cpu2_a5_wtdog;
  wire          cpu2_m4_wtdog;
  wire  [9:0]   cpu2_pwm;
  wire          cpu2_rc_en;
  wire          cpu2_pwm_cap_en;

  wire  [1:0]   cpu2_spi_cs;
  wire          cpu2_spi_sck;
  wire          cpu2_spi_out;
  wire          cpu2_spi_in;
       
  wire  [7:0]   cpu2_gpio;

  wire          cpu2_uart1_tx;
  wire          cpu2_uart1_rx;
  wire          cpu2_uart2_tx;
  wire          cpu2_uart2_rx;
  wire          cpu2_uart3_tx;
  wire          cpu2_uart3_rx;
  wire          cpu2_uart4_tx;
  wire          cpu2_uart4_rx;
		 
  wire          cpu2_can_rx;
  wire          cpu2_can_tx;
   
  wire  [1:0]   hall_in;
  reg           rc_en_in;
  wire  [5:0]   rc_pwm_in;


  wire          uart1_tx;
  wire          uart1_rx;
  wire          uart2_tx;
  wire          uart2_rx;
  wire          uart3_tx;
  wire          uart3_rx;
  wire          uart4_tx;
  wire          uart4_rx;
		 
  wire          cpld_can_rx;
  wire          cpld_can_tx;
		 
  wire          cpld_i2c_scl;
  wire          cpld_i2c_sda;
		 
  wire          imu_uart1_tx;
  wire          imu_uart1_rx;
		 
  wire          imu_uart2_tx;
  wire          imu_uart2_rx;
		 
  reg           sonar_in;
  wire          sonar_out;
		 
  wire          led;
  wire          led_yellow;
  wire          led_green;
	 
	wire  [3:0]   board_id;
	 
  wire  [3:0]   gpio;
	wire  [7:0]   rsv_io;
        
  
  wire         spi1_miso;
  reg          spi1_mosi;
  reg          spi1_cs_n;
  reg          spi1_clk ; 
  
  wire         spi2_miso;
  reg          spi2_mosi;
  reg          spi2_cs_n;
  reg          spi2_clk ; 
  
  wire         spi_clk_error;
  wire         rx_data_ready;
  wire  [15:0]  rx_data;
  reg          tx_data_ready;
  reg   [15:0]  tx_data;
  
  reg [3:0] spi1_cnt;
  reg [3:0] spi2_cnt;
//-------------------------------------------------------------------------------
  
  parameter  SPI_HALF_PERIOD = 125;
  parameter  CLK_HALF_PERIOD = 20.833;

	  
//----------------------------------------------------------------------- 
  initial
    begin
     clk=0;
     rst_n=0;
     spi1_cnt=15;
     spi2_cnt=15;
     sonar_in=0;
     
     #10000 rst_n= 16'd1;
      $display1("read BOARD_ID");
	    write_spi1(16'hc001);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi1(16'h0000);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read PWM_PERIOD");
	    write_spi1(16'hc010);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi1(16'h0000);	
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH1");
	    write_spi1(16'h0011);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1500);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read PWM_WIDTH_CH1");
	    write_spi1(16'hc011);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write cpu mode");
	    write_spi1(16'h0005);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1);
	    # (2*SPI_HALF_PERIOD);	    
	    	    
	    $display("read cpu mode");
	    write_spi1(16'hc005);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
    
 	    $display("write PWM_WIDTH_CH2");
	    write_spi1(16'h0012);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1520);
	    # (2*SPI_HALF_PERIOD);	    
	    	    
	    $display("read PWM_WIDTH_CH2");
	    write_spi1(16'hc012);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH3");
	    write_spi1(16'h0013);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1590);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("read PWM_WIDTH_CH3");
	    write_spi1(16'hc013);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH4");
	    write_spi1(16'h0014);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1700);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("read PWM_WIDTH_CH4");
	    write_spi1(16'hc014);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH5");
	    write_spi1(16'h0015);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1200);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("read PWM_WIDTH_CH5");
	    write_spi1(16'hc015);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH6");
	    write_spi1(16'h0fff);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1400);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("read PWM_WIDTH_CH6");
	    write_spi1(16'hc016);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    

	    
	    $display("cpu2 write PWM_WIDTH_CH1");
	    write_spi2(16'h0011);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1150);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 read PWM_WIDTH_CH1");
	    write_spi2(16'hc011);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
    
 	    $display("cpu2 write PWM_WIDTH_CH2");
	    write_spi2(16'h0012);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1260);
	    # (2*SPI_HALF_PERIOD);	    
	    	    
	    $display("cpu2 read PWM_WIDTH_CH2");
	    write_spi2(16'hc012);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write PWM_WIDTH_CH3");
	    write_spi2(16'h0013);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1315);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("cpu2 read PWM_WIDTH_CH3");
	    write_spi2(16'hc013);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write PWM_WIDTH_CH4");
	    write_spi2(16'h0014);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1330);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("cpu2 read PWM_WIDTH_CH4");
	    write_spi2(16'hc014);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write PWM_WIDTH_CH5");
	    write_spi2(16'h0015);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1250);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("cpu2 read PWM_WIDTH_CH5");
	    write_spi2(16'hc015);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);

	    $display("cpu2 write PWM_WIDTH_CH6");
	    write_spi2(16'h0016);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1450);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("cpu2 read PWM_WIDTH_CH6");
	    write_spi2(16'hc016);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    

	    
	   #50000200 
	    sonar_in = 1;
	    #444000
	    sonar_in = 0;
	    
	    $display("read RC_PWM_period");
	    write_spi1(16'hc009);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH1");
	    write_spi1(16'hc00a);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH2");
	    write_spi1(16'hc00b);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH3");
	    write_spi1(16'hc00c);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH4");
	    write_spi1(16'hc00d);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH5");
	    write_spi1(16'hc00e);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH6");
	    write_spi1(16'hc00f);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    
	    $display("write PWM_WIDTH_CH1");
	    write_spi1(16'h0fff);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1300);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read sonar");
	    write_spi1(16'hc01b);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1000);
	    # (2*SPI_HALF_PERIOD);
	    
	    #100000000 
	    $display("cpu2 read BOARD_ID");
	    write_spi2(16'hc001);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi2(16'h0000);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 read PWM_PERIOD");
	    write_spi2(16'hc010);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi2(16'h0000);	
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write PWM_WIDTH_CH1");
	    write_spi2(16'h0011);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1100);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 read PWM_WIDTH_CH1");
	    write_spi2(16'hc011);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write cpu mode");
	    write_spi2(16'h0005);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1);
	    # (2*SPI_HALF_PERIOD);	    
	    	    
	    $display("cpu2 read cpu mode");
	    write_spi2(16'hc005);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
    
 	    $display("cpu2 write PWM_WIDTH_CH2");
	    write_spi2(16'h0012);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1200);
	    # (2*SPI_HALF_PERIOD);	    
	    	    
	    $display("cpu2 read PWM_WIDTH_CH2");
	    write_spi2(16'hc012);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write PWM_WIDTH_CH3");
	    write_spi2(16'h0013);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1310);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("cpu2 read PWM_WIDTH_CH3");
	    write_spi2(16'hc013);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write PWM_WIDTH_CH4");
	    write_spi2(16'h0014);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1420);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("cpu2 read PWM_WIDTH_CH4");
	    write_spi2(16'hc014);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write PWM_WIDTH_CH5");
	    write_spi2(16'h0015);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1220);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("cpu2 read PWM_WIDTH_CH5");
	    write_spi2(16'hc015);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu2 write PWM_WIDTH_CH6");
	    write_spi2(16'h0016);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'd1405);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("cpu2 read PWM_WIDTH_CH6");
	    write_spi2(16'hc016);
	    # (2*SPI_HALF_PERIOD);
	    write_spi2(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu1 write PWM_WIDTH_CH6");
	    write_spi1(16'h0016);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1530);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu1 read PWM_WIDTH_CH6");
	    write_spi1(16'hc016);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
   
	   
	    
     #100000000 $stop;

end    
  always #CLK_HALF_PERIOD clk=~clk;


//------------------------------------------------------------------------------- 
 /*   read spi  */

reg [15:0] spi1_data;

always@(posedge spi1_clk)
	if(!rst_n) 
		spi1_cnt <= 4'd15;
  else if(!spi1_cs_n) 
		spi1_cnt <= spi1_cnt - 1;		
	
	
always@(posedge spi1_clk)
	if(!spi1_cs_n) begin
		if(spi1_cnt == 0) begin
			$display("%t, read spi1: data = %d", $time, {spi1_data[15:1], spi1_miso});
			spi1_data[spi1_cnt] <= spi1_miso;			
		end else begin
			spi1_data[spi1_cnt] <= spi1_miso;
		end
	end  
//------------------------------------------------------------------------------- 
task write_spi1;
	input [15:0] data;
	integer i;
	
	begin
		i = 15;            
		spi1_clk = 0;  
		spi1_cs_n = 0; 
		spi1_mosi = data[15];         

		#1000
    repeat(16) 
		   begin
			   spi1_clk = 1;
			   #SPI_HALF_PERIOD spi1_clk = 0;
			   i = i - 1;
			   if(i==-1) 
			      spi1_mosi = 1;
			   else
			   			spi1_mosi = data[i];  
         #SPI_HALF_PERIOD;			
		   end
		 spi1_cs_n = 1; 
	end	 
endtask
 
//-------------------------------------------------------------------------	  
task write_spi1_error;
	input [15:0] data;
	integer i;
	
	begin
		i = 15;            
		spi1_clk = 0;  
		spi1_cs_n = 0; 
		spi1_mosi = data[15];         

		#1000		
    repeat(14) 
		   begin
			   spi1_clk = 1;
			   #SPI_HALF_PERIOD spi1_clk = 0;
			   i = i - 1;
			   if(i==-1) 
			      spi1_mosi = 1;
			   else
			   			spi1_mosi = data[i];
         #SPI_HALF_PERIOD;			
		   end
		 spi1_cs_n = 0; 
  end	 
endtask
//------------------------------------------------------------------------------- 
 /*   read spi2  */

reg [15:0] spi2_data;

always@(posedge spi2_clk)
	if(!rst_n) 
		spi2_cnt <= 4'd15;
  else if(!spi2_cs_n) 
		spi2_cnt <= spi2_cnt - 1;		
	
	
always@(posedge spi2_clk)
	if(!spi2_cs_n) begin
		if(spi2_cnt == 0) begin
			$display("%t, read spi2: data = %d", $time, {spi2_data[15:1], spi2_miso});
			spi2_data[spi2_cnt] <= spi2_miso;			
		end else begin
			spi2_data[spi2_cnt] <= spi2_miso;
		end
	end  
//------------------------------------------------------------------------------- 
task write_spi2;
	input [15:0] data;
	integer i;
	
	begin
		i = 15;            
		spi2_clk = 0;  
		spi2_cs_n = 0; 
		spi2_mosi = data[15];         

		#1000
    repeat(16) 
		   begin
			   spi2_clk = 1;
			   #SPI_HALF_PERIOD spi2_clk = 0;
			   i = i - 1;
			   if(i==-1) 
			      spi2_mosi = 1;
			   else
			   			spi2_mosi = data[i];  
         #SPI_HALF_PERIOD;			
		   end
		 spi2_cs_n = 1; 
	end	 
endtask
 
//-------------------------------------------------------------------------
  /* spi_slave_transceiver  spi_xver(
                                  .clk           (clk     ),
                                  .rst_n         (rst_n   ),
										              .spi_mosi      (spi_mosi),     
                                  .spi_cs_n      (spi_cs_n),     
                                  .spi_clk       (spi_clk ),     
                                  .spi_miso      (spi_miso),     
                                  .spi_clk_error (spi_clk_error),
                                  .rx_data_ready (rx_data_ready),
                                  .rx_data       (rx_data),
                                  .tx_data_ready (tx_data_ready),
                                  .tx_data       (tx_data)
                                  );
                                  */
  /*
  pwm_gen_servo pwm_gen(
                         .clk(clk)               ,  
                         .rst_n(rst_n)             ,  
                         .pwm_clk(pwm_clk)            ,
                         .pulse_period(pulse_period)      ,  
                         .pulse_width_ch1(pulse_width_ch1)   ,  
                         .pulse_width_ch2(pulse_width_ch2)   ,
                         .pulse_width_ch3(pulse_width_ch3)   ,
                         .pulse_width_ch4(pulse_width_ch4)   ,
                         .pulse_width_ch5(pulse_width_ch5)   ,
                         .pulse_width_ch6(pulse_width_ch6)   , 
                         .pwm_out(pwm_out[5:0])   
                        );
   pwm_cap_rc pwm_cap(
                         .clk(clk)                 ,  
                         .rst_n(rst_n)                , 
								         .pwm_clk(pwm_clk)            ,
                         .rc_en_in(rc_en_in)         ,  
                         .pulse_width_ch1(rc_pulse_width_ch1)   ,  
                         .pulse_width_ch2(rc_pulse_width_ch2)   ,
                         .pulse_width_ch3(rc_pulse_width_ch3)   ,
                         .pulse_width_ch4(rc_pulse_width_ch4)   ,
                         .pulse_width_ch5(rc_pulse_width_ch5)   ,
                         .pulse_width_ch6(rc_pulse_width_ch6)   , 
                         .pwm_in(pwm_out[5:0]) ,
                         .pulse_period(pulse_period_rc)  
                        );
                        */

top  test(
	.clk_in(clk),
	.rst_n(rst_n),
	.cpu1_rst_n(cpu1_rst_n),
	.cpu1_a5_wtdog(cpu1_a5_wtdog),
	.cpu1_m4_wtdog(cpu1_m4_wtdog),
	.cpu1_pwm(cpu1_pwm),
	.cpu1_rc_en(cpu1_rc_en),
	.cpu1_pwm_cap_en(cpu1_pwm_cap_en),
	.cpu1_spi_cs(spi1_cs_n),
	.cpu1_spi_sck(spi1_clk),
	.cpu1_spi_out(spi1_mosi),
	.cpu1_spi_in(spi1_miso),
	.cpu1_gpio(cpu1_gpio),
	.cpu1_uart1_tx(cpu1_uart1_tx),
	.cpu1_uart1_rx(cpu1_uart1_rx),
	.cpu1_uart2_tx(cpu1_uart2_tx),
	.cpu1_uart2_rx(cpu1_uart2_rx),
	.cpu1_uart3_tx(cpu1_uart3_tx),
	.cpu1_uart3_rx(cpu1_uart3_rx),
	.cpu1_uart4_tx(cpu1_uart4_tx),
	.cpu1_uart4_rx(cpu1_uart4_rx),
	.cpu1_can_rx(cpu1_can_rx),
	.cpu1_can_tx(cpu1_can_tx),
	.cpu2_rst_n(cpu2_rst_n),
	.cpu2_a5_wtdog(cpu2_a5_wtdog),
	.cpu2_m4_wtdog(cpu2_m4_wtdog),
	.cpu2_pwm(cpu2_pwm),
	.cpu2_rc_en(cpu2_rc_en),
	.cpu2_pwm_cap_en(cpu2_pwm_cap_en),
	.cpu2_spi_cs(spi2_cs_n),
	.cpu2_spi_sck(spi2_clk),
	.cpu2_spi_out(spi2_mosi),
	.cpu2_spi_in(spi2_miso),
	.cpu2_gpio(cpu2_gpio),
	.cpu2_uart1_tx(cpu2_uart1_tx),
	.cpu2_uart1_rx(cpu2_uart1_rx),
	.cpu2_uart2_tx(cpu2_uart2_tx),
	.cpu2_uart2_rx(cpu2_uart2_rx),
	.cpu2_uart3_tx(cpu2_uart3_tx),
	.cpu2_uart3_rx(cpu2_uart3_rx),
	.cpu2_uart4_tx(cpu2_uart4_tx),
	.cpu2_uart4_rx(cpu2_uart4_rx),
	.cpu2_can_rx(cpu2_can_rx),
	.cpu2_can_tx(cpu2_can_tx),
	.hall_in(hall_in),
	.rc_en_in(1'b0),
	.rc_pwm_in(pwm_out[5:0]),
	.pwm_out(pwm_out),
	.uart1_tx(uart1_tx),
	.uart1_rx(uart1_rx),
	.uart2_tx(uart2_tx),
	.uart2_rx(uart2_rx),
	.uart3_tx(uart3_tx),
	.uart3_rx(uart3_rx),
	.uart4_tx(uart4_tx),
	.uart4_rx(uart4_rx),
	.cpld_can_rx(cpld_can_rx),
	.cpld_can_tx(cpld_can_tx),
	.cpld_i2c_scl(cpld_i2c_scl),
	.cpld_i2c_sda(cpld_i2c_sda),
	.imu_uart1_tx(imu_uart1_tx),
	.imu_uart1_rx(imu_uart1_rx),
	.imu_uart2_tx(imu_uart2_tx),
	.imu_uart2_rx(imu_uart2_rx),
	.sonar_in(sonar_in),
	.sonar_out(sonar_out),
	.led(led),
	.led_yellow(led_yellow),
	.led_green(led_green),
	.board_id(4'b0001),
	.gpio(gpio),
	.rsv_io(rsv_io)
	);
	
	endmodule