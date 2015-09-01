/***************************************************************************************************************
--Module Name:  spi_slave_transceiver
--Author     :  Jin
--Description:  
                polarity = 0  : idle state of spi clock is low level 
					 phase    = 0  : sample data at the rising edge，send data out at the falling edge
					 16 bits frame : MSB first
					                 
--History    :  2015-04-13  Created by Jin.                      

***************************************************************************************************************/

`timescale 1ns/100ps

module spi_slave_transceiver
(
  input  wire       clk  ,
  input  wire       rst_n,
  
  input  wire       spi_mosi,     //spi data input from master
  input  wire       spi_cs_n,     //spi selection ,active low
  input  wire       spi_clk ,     //spi clock
  output wire       spi_miso,     //spi data output to master 
  
  output wire       spi_clk_error,//spi clock error detection ,high level pulse active
  
  output reg        rx_data_ready,//high level pulse active
  output reg [15:0] rx_data      ,
  input  wire       tx_data_ready,//high level pulse active
  input  wire[15:0] tx_data
);
//---------------------------------------------------------------------------------------------------------------
  reg [2:0]       spi_clk_buf    ;
  reg [2:0]       spi_cs_n_buf   ;
  reg [2:0]       spi_mosi_buf   ;
  
  wire            posedge_spi_clk;
  wire            negedge_spi_clk;
  
  always @ (posedge clk or negedge rst_n)
    begin
	   if(!rst_n)
		   begin
			   spi_clk_buf  <= 3'b000;
				spi_cs_n_buf <= 3'b000;
				spi_mosi_buf <= 3'b000;
			end
		else begin
		       spi_clk_buf  <= {spi_clk_buf[1:0],spi_clk}    ;
				 spi_cs_n_buf <= {spi_cs_n_buf[1:0],spi_cs_n}  ;
				 spi_mosi_buf <= {spi_mosi_buf[1:0],spi_mosi}  ;				
			  end		
	 end
	
  assign posedge_spi_clk = spi_clk_buf[1] & (~spi_clk_buf[2]) ; //rising edge of spi clock
  assign negedge_spi_clk = spi_clk_buf[2] & (~spi_clk_buf[1]) ; //falling edge of spi clock
//---------------------------------------------------------------------------------------------------------------
              /*  spi clock error detect  */
  reg  [7:0]   clk_error_cnt  ;  
 
  always @ (posedge clk or negedge rst_n)
     begin
	     if(!rst_n)
		     clk_error_cnt <= 8'd0;
		  else if(spi_cs_n_buf[2]||spi_clk_error)
				 clk_error_cnt <= 8'd0;
		  else begin
		         if(posedge_spi_clk)
				      clk_error_cnt <= 8'd0;
			      else
				      clk_error_cnt <= clk_error_cnt + 8'd1;
				 end		  
	  end  
  assign spi_clk_error = (clk_error_cnt== 8'd240) ? 1'b1 : 1'b0;/* spi_clk_error is asserted if spi clock is lost 
                                                                 for 240 clk cycles */	
//---------------------------------------------------------------------------------------------------------------
  reg [15:0]  rx_shift_reg     ;// receiver shift register
  reg [3:0]   bit_cnt          ;// bit count of shift register 
  
  always @ (posedge clk or negedge rst_n)
     begin
	     if(!rst_n)
		     begin
		  		 rx_shift_reg  <= 16'd0;
				 bit_cnt       <= 4'd0;
			  end
		  else if(spi_cs_n_buf[2]||spi_clk_error)
		    begin
			    rx_shift_reg  <= 16'd0;
				 bit_cnt       <= 4'd0;
			 end
		  else if(posedge_spi_clk)  // shift data in at rising edge of spi clock
		     begin
			    rx_shift_reg  <= {rx_shift_reg[14:0],spi_mosi_buf[2]};
				 bit_cnt <= bit_cnt + 4'd1;
			  end
	  end  
//---------------------------------------------------------------------------------------------------------------
  wire    rx_data_ready_pre;
  assign  rx_data_ready_pre = negedge_spi_clk && (bit_cnt == 4'b0000); //data ready pulse at falling edge of last bit clock
  
   always @ (posedge clk or negedge rst_n)
     begin
	     if(!rst_n)
		     rx_data <= 16'd0;
		  else if(spi_clk_error)
				 rx_data <= 16'd0;
		  else if(rx_data_ready_pre)
				 rx_data <= rx_shift_reg;
	 end
	 
   always @ (posedge clk)       // align rx_data_ready with rx_data
     begin
	     if(!rst_n)
		     rx_data_ready <= 1'd0;
		  else if(spi_cs_n_buf[2]||spi_clk_error)
				 rx_data_ready <= 1'd0;
		  else 
				 rx_data_ready <= rx_data_ready_pre;
	 end
//---------------------------------------------------------------------------------------------------------------
  reg  [15:0]    tx_shift_reg; // transmitter shift register
  
  always @ (posedge clk or negedge rst_n)
     begin
	     if(!rst_n)
		    tx_shift_reg <= 16'd0;
		  else if(spi_clk_error)
				 tx_shift_reg <= 16'd0;
		  else if(tx_data_ready)
		       tx_shift_reg <= tx_data;
		  else if(negedge_spi_clk) //shift data out at falling edge of spi clock
				 tx_shift_reg <= {tx_shift_reg[14:0],1'b0};
	  end  
  assign spi_miso = tx_shift_reg[15];

//---------------------------------------------------------------------------------------------------------------


endmodule