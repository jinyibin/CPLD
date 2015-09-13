`timescale 1ns/100ps



module top
(
    input  wire          clk_in,
    input  wire          rst_n,

    output wire          cpu1_rst_n,
    input  wire          cpu1_a5_wtdog,
    input  wire          cpu1_m4_wtdog,
    input  wire  [9:0]   cpu1_pwm,
    output wire          cpu1_rc_en,
    input  wire          cpu1_pwm_cap_en,

    input  wire  [1:0]   cpu1_spi_cs,
    input  wire          cpu1_spi_sck,
    input  wire          cpu1_spi_out,
    output wire          cpu1_spi_in,
       
    input  wire  [7:0]   cpu1_gpio,

    input  wire          cpu1_uart1_tx,
    output wire          cpu1_uart1_rx,
    input  wire          cpu1_uart2_tx,
    output wire          cpu1_uart2_rx,
    input  wire          cpu1_uart3_tx,
    output wire          cpu1_uart3_rx,
    input  wire          cpu1_uart4_tx,
    output wire          cpu1_uart4_rx,
		 
    output wire          cpu1_can_rx,
    input  wire          cpu1_can_tx,

    output wire          cpu2_rst_n,
    input  wire          cpu2_a5_wtdog,
    input  wire          cpu2_m4_wtdog,
    input wire  [9:0]    cpu2_pwm,
    output wire          cpu2_rc_en,
    input  wire          cpu2_pwm_cap_en,

    input  wire  [1:0]   cpu2_spi_cs,
    input  wire          cpu2_spi_sck,
    input  wire          cpu2_spi_out,
    output wire          cpu2_spi_in,
       
    input  wire  [7:0]   cpu2_gpio,

    input  wire          cpu2_uart1_tx,
    output wire          cpu2_uart1_rx,
    input  wire          cpu2_uart2_tx,
    output wire          cpu2_uart2_rx,
    input  wire          cpu2_uart3_tx,
    output wire          cpu2_uart3_rx,
    input  wire          cpu2_uart4_tx,
    output wire          cpu2_uart4_rx,
		 
    output wire          cpu2_can_rx,
    input  wire          cpu2_can_tx,
   
    input  wire  [1:0]   hall_in,
    input  wire          rc_en_in,
    input  wire  [5:0]   rc_pwm_in,
    output wire  [9:0]   pwm_out,

    output wire          uart1_tx,
    input  wire          uart1_rx,
    output wire          uart2_tx,
    input  wire          uart2_rx,
    output wire          uart3_tx,
    input  wire          uart3_rx,
    output wire          uart4_tx,
    input  wire          uart4_rx,
		 
    input  wire          cpld_can_rx,
    output wire          cpld_can_tx,
		 
    output wire          cpld_i2c_scl,
    inout  wire          cpld_i2c_sda,
		 
    output wire          imu_uart1_tx,
    input  wire          imu_uart1_rx,
		 
    output wire          imu_uart2_tx,
    input  wire          imu_uart2_rx,
		 
    input  wire          sonar_in,
    output wire          sonar_out,
		 
    output wire          led,
    output wire          led_yellow,
    output wire          led_green,
	 
	 input  wire  [3:0]   board_id,
	 
    input  wire  [3:0]   gpio,
	 inout  wire  [7:0]   rsv_io

	);
	

	
	wire [15:0]   cpu1_pwm_width_ch1;
	wire [15:0]   cpu1_pwm_width_ch2;
	wire [15:0]   cpu1_pwm_width_ch3;
	wire [15:0]   cpu1_pwm_width_ch4;
	wire [15:0]   cpu1_pwm_width_ch5;
	wire [15:0]   cpu1_pwm_width_ch6;
	wire [15:0]   cpu1_pwm_width_ch7;
	wire [15:0]   cpu1_pwm_width_ch8;
	
	wire [15:0]   cpu1_pwm_period;
	wire [15:0]   cpu1_pwm_period7;	
	wire [15:0]   cpu1_pwm_period8;
	
	wire [15:0]   cpu1_tx_data;
	wire [15:0]   cpu1_rx_data;
	wire          cpu1_tx_data_ready;
	wire          cpu1_rx_data_ready;
	
	wire          cpu1_spi_frame_lost_error;	
	wire          cpu1_spi_clk_error;
	
	wire [1:0]    cpu1_sonar_control;
 
	wire          cpu1_watch_dog_pulse;
	wire [3:0]    cpu1_reg_cpu_mode;
	
	wire [15:0]   cpu1_reg_ctrl;
 //-------------------------------------------------------------------------------------------------------------	
	wire [15:0]   cpu2_pwm_width_ch1;
	wire [15:0]   cpu2_pwm_width_ch2;
	wire [15:0]   cpu2_pwm_width_ch3;
	wire [15:0]   cpu2_pwm_width_ch4;
	wire [15:0]   cpu2_pwm_width_ch5;
	wire [15:0]   cpu2_pwm_width_ch6;
	wire [15:0]   cpu2_pwm_width_ch7;
	wire [15:0]   cpu2_pwm_width_ch8;
	wire [15:0]   cpu2_pwm_period;
	wire [15:0]   cpu2_pwm_period7;	
	wire [15:0]   cpu2_pwm_period8;	
	
	wire [15:0]   cpu2_tx_data;
	wire [15:0]   cpu2_rx_data;
	wire          cpu2_tx_data_ready;
	wire          cpu2_rx_data_ready;
	
	wire          cpu2_spi_frame_lost_error;	
	wire          cpu2_spi_clk_error;
	
	wire [1:0]    cpu2_sonar_control;
  
	
	wire [3:0]    cpu2_reg_cpu_mode;
	wire          cpu2_watch_dog_pulse;
	
	wire [15:0]   cpu2_reg_ctrl;
 //-------------------------------------------------------------------------------------------------------------	
	wire [3:0]    reg_cpu_mode;
	
   wire [1:0]    sonar_control;
   wire [15:0]   sonar_data;
	
	wire [14:0]   rc_pulse_width_ch1;
	wire [14:0]   rc_pulse_width_ch2;
	wire [14:0]   rc_pulse_width_ch3;
	wire [14:0]   rc_pulse_width_ch4;
	wire [14:0]   rc_pulse_width_ch5;
	wire [14:0]   rc_pulse_width_ch6;
	wire [14:0]   rc_pulse_period;
   
	wire [5:0]    pwm_out_auto;
	wire          pwm_update_pulse;
	
 //-------------------------------------------------------------------------------------------------------------
   wire [31:0]   version;//
 //-------------------------------------------------------------------------------------------------------------
   parameter             DOG_HUNGRY_TIME = 7'd70  ;      // time(ms) that watch_dog_pulse did not show up
	parameter             FRE_DIV         = 8'd24  ;      // PWM CLK = clk/fre_div; 1MHz default)
 //-------------------------------------------------------------------------------------------------------------
   reg [1:0]   rst_n_buf;
	always @ (posedge clk_in)
	  rst_n_buf <= {rst_n_buf[0],rst_n};
 //-------------------------------------------------------------------------------------------------------------
                     /*  generate 1MHz  PWM sampling Clock  */
  reg          pwm_clk      ;
  reg  [1:0]   pwm_clk_delay; 
  reg  [7:0]   fre_divider  ;
  
  always @ (posedge clk_in or negedge rst_n_buf[1]) 
   begin
        if(!rst_n_buf[1])
		     fre_divider <= 8'd0;
		  else begin
		        if(fre_divider == 8'd0)
				     begin
			          fre_divider <= FRE_DIV - 8'd1;
			        end
			     else begin
			            fre_divider <= fre_divider - 8'd1;
			          end
		       end  
   end
	/* pwm_clk is used as reference time for CPU Failure switch */
	always @(posedge clk_in or negedge rst_n_buf[1])
	  begin
	       if(!rst_n_buf[1])
			     pwm_clk       <= 1'd0;
			 else 
			     begin
			       if(fre_divider == FRE_DIV - 8'd1)
			         pwm_clk <= 1'd1;
					 else 
					   pwm_clk <= 1'd0;
					end						
	  end 
    /* 2 clk_in cycle delay of pwm_clk,used to sample PWM signal,
	     and update servo PWM width  ,so that PWM width is updated right after CPU Failure switch */ 
 	always @(posedge clk_in)
	       if(!rst_n_buf[1])
			     pwm_clk_delay <= 2'd0;
			 else 
			     pwm_clk_delay <= {pwm_clk_delay[0],pwm_clk};					
 //-------------------------------------------------------------------------------------------------------------
                      /*  1ms global referenc time  */
  reg  [9:0]   timer_1ms;
  wire         ref_clk_1ms;
  
  always @ (posedge clk_in or negedge rst_n_buf[1]) 
   begin
        if(!rst_n_buf[1])
		     timer_1ms <= 10'd999;
		  else begin
		        if((pwm_clk) && (timer_1ms == 10'd0))
                 timer_1ms <= 10'd999;
			     else if(pwm_clk)
			            timer_1ms <= timer_1ms - 8'd1;
		       end  
   end
   assign  ref_clk_1ms = pwm_clk && (timer_1ms == 10'd0);
 //-------------------------------------------------------------------------------------------------------------
           /* 1MHz sampling of rc_en_in  */
	 reg[1:0]     rc_en_buf;
    always @ (posedge clk_in or negedge rst_n_buf[1])
	   begin
		   if(!rst_n_buf[1])
			   rc_en_buf[0] <= 1'b0;
         else
			   rc_en_buf[0] <= rc_en_in;
		end
 
	 always @ (posedge clk_in or negedge rst_n_buf[1])
	   begin
		   if(!rst_n_buf[1])
			  begin
			   rc_en_buf[1] <= 1'b0;
			  end
			else if(pwm_clk_delay[1])
			        begin
			          rc_en_buf[1] <= rc_en_buf[0]  ;
					  end
		end
		
		assign cpu1_rc_en = rc_en_buf[1];
		assign cpu2_rc_en = rc_en_buf[1];
//---------------------------------------------------------------------------------------------------------------
reg [1:0] cpu1_pwm_update;
reg [1:0] cpu2_pwm_update;

   always @ (posedge clk_in or negedge rst_n_buf[1])
	   if(!rst_n_buf[1])
		   begin
			   cpu1_pwm_update <= 2'b0;
				cpu2_pwm_update <= 2'b0;
		   end
		else
			begin
			// everytime after cpu1 and cpu2 writes pwm data to the FPGA
			// a high pulse is sent out to the cpu1_pwm[0] and cpu2_pwm[0]
			// so this pulse can be used as watch dog moniter pulse
			   cpu1_pwm_update <= {cpu1_pwm_update[0],cpu1_pwm[0]};
				cpu2_pwm_update <= {cpu2_pwm_update[0],cpu2_pwm[0]};
		   end	   
//---------------------------------------------------------------------------------------------------------------
    /* CPU1 failure detection */
	reg [6:0] cpu1_dog_hungry_cnt;
	reg       cpu1_failure;
	
   always @ (posedge clk_in or negedge rst_n_buf[1])
	   if(!rst_n_buf[1])
		   cpu1_dog_hungry_cnt <= 7'd0;
		else if(cpu1_watch_dog_pulse || (cpu1_reg_cpu_mode == 4'd0))
		   cpu1_dog_hungry_cnt <= 7'd0;
		else if(ref_clk_1ms) 
		   begin
			  if(cpu1_dog_hungry_cnt == DOG_HUNGRY_TIME + 7'd1)
		       cpu1_dog_hungry_cnt <= cpu1_dog_hungry_cnt ;
		    else 
		       cpu1_dog_hungry_cnt <= cpu1_dog_hungry_cnt + 7'd1;
		   end
			
   always @ (posedge clk_in or negedge rst_n_buf[1])
	   if(!rst_n_buf[1])
		  cpu1_failure <= 1'b0;
		else if(cpu1_dog_hungry_cnt >= DOG_HUNGRY_TIME)//never use cpu1 once it fails
		  cpu1_failure <= 1'b1;
 
	//assign cpu1_rst_n = (cpu1_dog_hungry_cnt == DOG_HUNGRY_TIME) ? 1'b0 : 1'b1;  // 1ms reset time of cpu1	
	  assign cpu1_rst_n = 1'b1;
//---------------------------------------------------------------------------------------------------------------
    /* CPU2 failure detection */
	reg [6:0] cpu2_dog_hungry_cnt;
	reg       cpu2_failure;
	
   always @ (posedge clk_in or negedge rst_n_buf[1])
	   if(!rst_n_buf[1])
		  cpu2_dog_hungry_cnt <= 7'd0;
		else if(cpu2_watch_dog_pulse || (cpu2_reg_cpu_mode == 4'd0))
		  cpu2_dog_hungry_cnt <= 7'd0;
		else if(ref_clk_1ms) 
		   begin
			  if(cpu2_dog_hungry_cnt == DOG_HUNGRY_TIME + 7'd1)
		       cpu2_dog_hungry_cnt <= cpu2_dog_hungry_cnt ;
		    else 
		       cpu2_dog_hungry_cnt <= cpu2_dog_hungry_cnt + 7'd1;
		   end

   always @ (posedge clk_in or negedge rst_n_buf[1])
	   if(!rst_n_buf[1])
		  cpu2_failure <= 1'b0;
		else if(cpu2_dog_hungry_cnt >= DOG_HUNGRY_TIME)
		  cpu2_failure <= 1'b1;
		else
	     cpu2_failure <= 1'b0;	
	
	
	assign cpu2_rst_n = (cpu2_dog_hungry_cnt == DOG_HUNGRY_TIME) ? 1'b0 : 1'b1; // 1ms reset time of cpu2
	  //assign cpu2_rst_n = 1'b1;
//---------------------------------------------------------------------------------------------------------------
   /* manual operation switch */
	assign pwm_out[5:0] = (rc_en_buf[1]|cpu1_reg_ctrl[0])? rc_pwm_in : pwm_out_auto;
//---------------------------------------------------------------------------------------------------------------
   /* CPU Failure switch */
   reg [14:0]   pwm_width_ch1;
	reg [14:0]   pwm_width_ch2;
	reg [14:0]   pwm_width_ch3;
	reg [14:0]   pwm_width_ch4;
	reg [14:0]   pwm_width_ch5;
	reg [14:0]   pwm_width_ch6;
	reg [14:0]   pwm_period;
	
	reg [14:0]   pwm_period7;
	reg [14:0]   pwm_period8;
	
   reg [14:0]   pwm_width_ch7;
	reg [14:0]   pwm_width_ch8;
	
	always @ (posedge clk_in)
	  if(!cpu1_failure)
	    begin
		   pwm_width_ch1 <= cpu1_pwm_width_ch1[14:0];
			pwm_width_ch2 <= cpu1_pwm_width_ch2[14:0];
			pwm_width_ch3 <= cpu1_pwm_width_ch3[14:0];
			pwm_width_ch4 <= cpu1_pwm_width_ch4[14:0];
			pwm_width_ch5 <= cpu1_pwm_width_ch5[14:0];
			pwm_width_ch6 <= cpu1_pwm_width_ch6[14:0];
			pwm_period    <= cpu1_pwm_period[14:0];
			pwm_width_ch7 <= cpu1_pwm_width_ch7[14:0];
			pwm_period7   <= cpu1_pwm_period7[14:0];
			pwm_width_ch8 <= cpu1_pwm_width_ch8[14:0];
			pwm_period8   <= cpu1_pwm_period8[14:0];
		 end
	  else if(cpu1_failure)
	    begin
		   pwm_width_ch1 <= cpu2_pwm_width_ch1[14:0];
			pwm_width_ch2 <= cpu2_pwm_width_ch2[14:0];
			pwm_width_ch3 <= cpu2_pwm_width_ch3[14:0];
			pwm_width_ch4 <= cpu2_pwm_width_ch4[14:0];
			pwm_width_ch5 <= cpu2_pwm_width_ch5[14:0];
			pwm_width_ch6 <= cpu2_pwm_width_ch6[14:0];
			pwm_period    <= cpu2_pwm_period[14:0];
			pwm_width_ch7 <= cpu2_pwm_width_ch7[14:0];
			pwm_period7   <= cpu2_pwm_period7[14:0];
			pwm_width_ch8 <= cpu2_pwm_width_ch8[14:0];
			pwm_period8   <= cpu2_pwm_period8[14:0];
		 end

	
	assign sonar_control = (cpu1_failure == 1'b0)? cpu1_sonar_control : cpu2_sonar_control;
	//assign pwm_update_pulse = (cpu1_failure == 1'b0) ? cpu1_pwm_update[1] : cpu2_pwm_update[1];
	assign pwm_update_pulse = (cpu1_failure == 1'b0) ? cpu1_watch_dog_pulse : cpu2_watch_dog_pulse;
	
	assign uart1_tx      = (cpu1_failure == 1'b0)? cpu1_uart1_tx      : cpu2_uart1_tx     ;
	//assign uart1_tx      = (cpu1_failure == 1'b0)? cpu1_pwm[4]         : cpu2_pwm[4]     ;
   assign uart2_tx      = (cpu1_failure == 1'b0)? cpu1_uart2_tx      : cpu2_uart2_tx     ;
	assign uart3_tx      = ((cpu1_reg_ctrl[15]==1'b0)||(cpu1_failure == 1'b0))? cpu1_uart3_tx      : cpu2_uart3_tx     ;
	//assign uart4_tx      = (cpu1_failure == 1'b0)? cpu1_uart4_tx      : cpu2_uart4_tx     ;
   assign imu_uart1_tx  = (cpu1_failure == 1'b0)? cpu1_uart4_tx      : cpu2_uart4_tx     ;  
	assign cpld_can_tx   = (cpu1_failure == 1'b0)? cpu1_can_tx        : cpu2_can_tx       ;
	
	
	assign cpu1_uart1_rx = uart1_rx;
	assign cpu2_uart1_rx = uart1_rx;
	//assign cpu1_pwm[5]   = uart1_rx;
	//assign cpu2_pwm[5]   = uart1_rx;
	
	assign cpu1_uart2_rx = uart2_rx;
	assign cpu2_uart2_rx = uart2_rx;
	
	assign cpu1_uart3_rx = uart3_rx;
	assign cpu2_uart3_rx = uart3_rx;
	
	//assign cpu1_uart4_rx = uart4_rx;
	//assign cpu2_uart4_rx = uart4_rx;
	assign cpu1_uart4_rx = imu_uart1_rx;
	assign cpu2_uart4_rx = imu_uart1_rx;
	
	assign cpu1_can_rx   = cpld_can_rx;
	assign cpu2_can_rx   = cpld_can_rx;
	

//-----------------------------for debug ------------------------------------------------------------------------------	
	assign rsv_io[0] = cpu1_spi_cs;
	assign rsv_io[1] = cpu1_spi_sck;
	assign rsv_io[2] = cpu1_spi_in;
	assign rsv_io[3] = cpu1_spi_out;	
	assign rsv_io[4] = cpu1_pwm[1];
//---------------------------------------------------------------------------------------------------------------
   /* cpld local time */
	reg  [15:0] cpld_local_time ;
	
	always @ (posedge clk_in or negedge rst_n_buf[1])
	  if(!rst_n_buf[1])
	    cpld_local_time <= 16'd0;
	  else if(ref_clk_1ms)
	    cpld_local_time <= cpld_local_time + 16'd1;
//---------------------------------------------------------------------------------------------------------------
   /*   LED  indication   */
	assign led_yellow = cpu1_failure ;
	assign led_green  = cpu2_failure ;
	assign led        = (cpld_local_time[9:0] < 10'd127) ? 1'b1 : 1'b0;


//---------------------------------------------------------------------------------------------------------------
    /* CPU1 register read/write */
 spi_slave_reg  spi_reg_cpu1(
                                   .clk  (clk_in),
                                   .rst_n(rst_n_buf[1]),
  
                                   .rx_data_ready(cpu1_rx_data_ready),
                                   .rx_data      (cpu1_rx_data), 
                                   .tx_data_ready(cpu1_tx_data_ready),
                                   .tx_data      (cpu1_tx_data),
											  
                                   .board_id(board_id),
											  .reg_control(cpu1_reg_ctrl),

                                   .reg_cpu_mode(cpu1_reg_cpu_mode), // CPU mode indication 
  
                                   .reg_rc_period({1'b0,rc_pulse_period})       ,//Remote controller Pulse period 
                                   .reg_rc_pwidth_ch1({1'b0,rc_pulse_width_ch1}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch2({1'b0,rc_pulse_width_ch2}),// Remote controller pulse width  
                                   .reg_rc_pwidth_ch3({1'b0,rc_pulse_width_ch3}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch4({1'b0,rc_pulse_width_ch4}),// Remote controller pulse width
                                   .reg_rc_pwidth_ch5({1'b0,rc_pulse_width_ch5}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch6({1'b0,rc_pulse_width_ch6}),// Remote controller pulse width 
				  
                                   .reg_pwm_period   (cpu1_pwm_period)   ,// servo PWM signal period
                                   .reg_pwm_width_ch1(cpu1_pwm_width_ch1),// servo PWM signal pulse width for channel1
                                   .reg_pwm_width_ch2(cpu1_pwm_width_ch2),// servo PWM signal pulse width for channel2
                                   .reg_pwm_width_ch3(cpu1_pwm_width_ch3),// servo PWM signal pulse width for channel3
                                   .reg_pwm_width_ch4(cpu1_pwm_width_ch4),// servo PWM signal pulse width for channel4
                                   .reg_pwm_width_ch5(cpu1_pwm_width_ch5),// servo PWM signal pulse width for channel5
                                   .reg_pwm_width_ch6(cpu1_pwm_width_ch6),// servo PWM signal pulse width for channel6
				  
                                   .reg_sonar_control(cpu1_sonar_control),// Sonar enable or stop,default enable
                                   .reg_sonar_data   (sonar_data   )   ,// Sonar data 
                                   .frame_lost_error (cpu1_spi_frame_lost_error),// data frame lost,high level pulse
											  .watch_dog_pulse(cpu1_watch_dog_pulse),
											  
											  .reg_pwm_period7(cpu1_pwm_period7),
											  .reg_pwm_width_ch7(cpu1_pwm_width_ch7),
											  .reg_pwm_period8(cpu1_pwm_period8),
											  .reg_pwm_width_ch8(cpu1_pwm_width_ch8),
											  .version(version)
                                  );
//---------------------------------------------------------------------------------------------------------------	 
      /* CPU1 register read/write */
 spi_slave_reg   spi_reg_cpu2(
                                   .clk  (clk_in),
                                   .rst_n(rst_n_buf[1]),
  
                                   .rx_data_ready(cpu2_rx_data_ready),
                                   .rx_data      (cpu2_rx_data), 
                                   .tx_data_ready(cpu2_tx_data_ready),
                                   .tx_data      (cpu2_tx_data),
											  
                                   .board_id(board_id),
                                   .reg_control(cpu2_reg_ctrl),
                                   .reg_cpu_mode(cpu2_reg_cpu_mode), // CPU mode indication 
  
                                   .reg_rc_period({1'b0,rc_pulse_period})       ,//Remote controller Pulse period 
                                   .reg_rc_pwidth_ch1({1'b0,rc_pulse_width_ch1}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch2({1'b0,rc_pulse_width_ch2}),// Remote controller pulse width  
                                   .reg_rc_pwidth_ch3({1'b0,rc_pulse_width_ch3}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch4({1'b0,rc_pulse_width_ch4}),// Remote controller pulse width
                                   .reg_rc_pwidth_ch5({1'b0,rc_pulse_width_ch5}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch6({1'b0,rc_pulse_width_ch6}),// Remote controller pulse width 
				  
                                   .reg_pwm_period   (cpu2_pwm_period)   ,// servo PWM signal period
                                   .reg_pwm_width_ch1(cpu2_pwm_width_ch1),// servo PWM signal pulse width for channel1
                                   .reg_pwm_width_ch2(cpu2_pwm_width_ch2),// servo PWM signal pulse width for channel2
                                   .reg_pwm_width_ch3(cpu2_pwm_width_ch3),// servo PWM signal pulse width for channel3
                                   .reg_pwm_width_ch4(cpu2_pwm_width_ch4),// servo PWM signal pulse width for channel4
                                   .reg_pwm_width_ch5(cpu2_pwm_width_ch5),// servo PWM signal pulse width for channel5
                                   .reg_pwm_width_ch6(cpu2_pwm_width_ch6),// servo PWM signal pulse width for channel6
				  
                                   .reg_sonar_control(cpu2_sonar_control),// Sonar enable or stop,default enable
                                   .reg_sonar_data   (sonar_data)   ,// Sonar data 
                                   .frame_lost_error (cpu2_spi_frame_lost_error),// data frame lost,high level pulse
											  .watch_dog_pulse(cpu2_watch_dog_pulse),
											  
											  .reg_pwm_period7(cpu2_pwm_period7),
											  .reg_pwm_width_ch7(cpu2_pwm_width_ch7),
											  .reg_pwm_period8(cpu2_pwm_period8),
											  .reg_pwm_width_ch8(cpu2_pwm_width_ch8),	
											  
											  .version(version)
                                  );
//---------------------------------------------------------------------------------------------------------------	 
     /* CPU1 SPI transceiver slave  */
  spi_slave_transceiver  spi_xver1(
                                  .clk           (clk_in   ),
                                  .rst_n         (rst_n_buf[1]   ),
										    .spi_mosi      (cpu1_spi_out),     
                                  .spi_cs_n      (cpu1_spi_cs),     
                                  .spi_clk       (cpu1_spi_sck ),     
                                  .spi_miso      (cpu1_spi_in),     
                                  .spi_clk_error (cpu1_spi_clk_error),
                                  .rx_data_ready (cpu1_rx_data_ready),
                                  .rx_data       (cpu1_rx_data),
                                  .tx_data_ready (cpu1_tx_data_ready),
                                  .tx_data       (cpu1_tx_data)
                                  );  
  

//--------------------------------------------------------------------------------------------------------------- 
    /* CPU2 SPI transceiver slave  */
  spi_slave_transceiver  spi_xver2(
                                  .clk           (clk_in   ),
                                  .rst_n         (rst_n_buf[1]  ),
										    .spi_mosi      (cpu2_spi_out),     
                                  .spi_cs_n      (cpu2_spi_cs),     
                                  .spi_clk       (cpu2_spi_sck ),     
                                  .spi_miso      (cpu2_spi_in),     
                                  .spi_clk_error (cpu2_spi_clk_error),
                                  .rx_data_ready (cpu2_rx_data_ready),
                                  .rx_data       (cpu2_rx_data),
                                  .tx_data_ready (cpu2_tx_data_ready),
                                  .tx_data       (cpu2_tx_data)
                                  ); 	
//--------------------------------------------------------------------------------------------------------------- 
	/* generate servo pwm pulse  */
	pwm_gen_servo pwm_gen_cpu(
                         .clk(clk_in)                 ,  
                         .rst_n(rst_n_buf[1])                , 
								 .pwm_clk(pwm_clk_delay[1])   ,
                         .pulse_period(pwm_period)         ,  
                         .pulse_width_ch1(pwm_width_ch1)   ,  
                         .pulse_width_ch2(pwm_width_ch2)   ,
                         .pulse_width_ch3(pwm_width_ch3)   ,
                         .pulse_width_ch4(pwm_width_ch4)   ,
                         .pulse_width_ch5(pwm_width_ch5)   ,
                         .pulse_width_ch6(pwm_width_ch6)   , 
								 .data_update_flag(pwm_update_pulse),
                         .pwm_out        (pwm_out_auto)   
                        );

//---------------------------------------------------------------------------------------------------------------									
   /* caputre pwm width of remote controller */
	pwm_cap_rc pwm_cap(
                         .clk(clk_in)                 ,  
                         .rst_n(rst_n_buf[1])                , 
								 .pwm_clk(pwm_clk_delay[1])   ,
                         .rc_en_in(rc_en_buf)         ,  
                         .pulse_width_ch1(rc_pulse_width_ch1)   ,  
                         .pulse_width_ch2(rc_pulse_width_ch2)   ,
                         .pulse_width_ch3(rc_pulse_width_ch3)   ,
                         .pulse_width_ch4(rc_pulse_width_ch4)   ,
                         .pulse_width_ch5(rc_pulse_width_ch5)   ,
                         .pulse_width_ch6(rc_pulse_width_ch6)   ,
								 .pulse_period   (rc_pulse_period)      , 
                         .pwm_in         (rc_pwm_in)   
                        );
//---------------------------------------------------------------------------------------------------------------	
	/* generate pwm pulse  */
	pwm_gen_rsv pwm_gen_rsv1(
                         .clk(clk_in)                 ,  
                         .rst_n(rst_n_buf[1])                , 
								 .pwm_clk(pwm_clk_delay[1])   ,
                         .pulse_period(pwm_period7)         ,  
                         .pulse_width_ch(pwm_width_ch7)   ,  
                         .pwm_out        (pwm_out[6])   
                        );
								
   pwm_gen_rsv pwm_gen_rsv2(
                         .clk(clk_in)                 ,  
                         .rst_n(rst_n_buf[1])                , 
								 .pwm_clk(pwm_clk_delay[1])   ,
                         .pulse_period(pwm_period8)         ,  
                         .pulse_width_ch(pwm_width_ch8)   ,  
                         .pwm_out        (pwm_out[7])   
                        );

//---------------------------------------------------------------------------------------------------------------	
sonar_ctrl  sonar(  
                   .clk  (clk_in),
                   .rst_n(rst_n_buf[1]),
                   .pwm_clk       (pwm_clk_delay[1] ),// 1MHz clock to sample pwm pulse
                   .sonar_ctrl_reg(sonar_control    ),// sonar mode selection
                   .sonar_data    (sonar_data       ),// sonar PWM pulse width(us)
                   .sonar_out     (sonar_out        ),// sonar enable:low level stop sonar ranging
                   .sonar_in      (sonar_in         ) // sonar PWM pulse output
);
//---------------------------------------------------------------------------------------------------------------	
version_reg ver(
                    .clock(clk_in),
						  .reset(rst_n_buf[1]),
						  .data_out(version)
						  );
					
endmodule