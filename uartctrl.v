`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:46:49 10/28/2017 
// Design Name: 
// Module Name:    uartctrl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:43:27 06/25/2017 
// Design Name: 
// Module Name:    uartctrl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module uartctrl(
      input                   clk,
		input                   rdsig,
		input      [7:0]        rxdata,
	   output                  wrsig,
		output     [7:0]        dataout,
		input                   tx_idle,//// 发送是否空闲  1：不空闲 0：空闲
      input                   fill_finish,//fifo
      input      [287:0]      fifo_data,//fifo_data,128		
		//input      [15:0]       fifo_rddb,
		//input      [31:0]       ss_data,
		//input                   fifo_rd_finish,	
		input                   reset
    );
      reg [17:0] uart_wait;
		reg [15:0] uart_cnt;
		reg rx_data_valid;
		reg [7:0] store [35:0];                        //存储发送字符,16
		reg [2:0] uart_stat;
		reg [8:0] k;
		reg [7:0] dataout_reg;
		reg data_sel;
		reg wrsig_reg;
		reg[11:0] rdcnt;			//reg	
		  
		assign dataout = data_sel ?  dataout_reg : rxdata ;
		assign wrsig = data_sel ?  wrsig_reg : rdsig;
      ///////////////////////////////////////////////////
		wire fill_flag;
		assign fill_flag = fill_finish;
      //存储要发送的数据
		always @(posedge clk)
		begin     //定义发送的字符
		     
			  if(fill_flag == 1'b1)//if(fill_finish == 1'b1)
			  begin		 
						 store[0] <= fifo_data>>280;
						 store[1] <= fifo_data>>272;
						 store[2] <= fifo_data>>264;
						 store[3] <= fifo_data>>256;
						 store[4] <= fifo_data>>248;
						 store[5] <= fifo_data>>240;
						 store[6] <= fifo_data>>232;
						 store[7] <= fifo_data>>224;
						 store[8] <= fifo_data>>216;
						 store[9] <= fifo_data>>208;
						 store[10]<= fifo_data>>200;//8'hFF;//fifo_rddb;                           //存储字符H
						 store[11]<= fifo_data>>192;//8'hFF;//fifo_rddb>>8;
						 store[12]<= fifo_data>>184;//8'hFF;
						 store[13]<= fifo_data>>176;//8'hFF;
						 store[14]<= fifo_data>>168;
						 store[15]<= fifo_data>>160;
						 store[16]<= fifo_data>>152;
						 store[17]<= fifo_data>>144;
						 store[18]<= fifo_data>>136;
						 store[19]<= fifo_data>>128;
						 store[20]<= fifo_data>>120;
						 store[21]<= fifo_data>>112;
                   store[22]<= fifo_data>>104;
						 store[23]<= fifo_data>>96;
						 store[24]<= fifo_data>>88;
						 store[25]<= fifo_data>>80;
						 store[26]<= fifo_data>>72;
						 store[27]<= fifo_data>>64;
						 store[28]<= fifo_data>>56;
						 store[29]<= fifo_data>>48;
						 store[30]<= fifo_data>>40;
						 store[31]<= fifo_data>>32;
						 store[32]<= fifo_data>>24;
						 store[33]<= fifo_data>>16;
						 store[34]<= fifo_data>>8;
						 store[35]<= fifo_data;
			  end
		end
		  
		  //串口发送字符串	
		always @(posedge clk)
		begin
		  if(rdsig == 1'b1) begin   
				uart_cnt <= 0;
				uart_stat <= 3'b000; 
				data_sel<=1'b0;      //收到字符
				k<=0;
		  end
		  else begin
			 case(uart_stat)
			 3'b000: begin               
				 if (rx_data_valid == 1'b1) begin
					 uart_stat <= 3'b001; 
					 data_sel<=1'b1;
				 end
			 end	
			 3'b001: begin                      //发送19个字符   
					if (k == 35 ) begin  //3        		 
						 if(uart_cnt ==0) begin
							dataout_reg <= store[35]; //3
							uart_cnt <= uart_cnt + 1'b1;
							wrsig_reg <= 1'b1;                			
						 end	
						 else if(uart_cnt ==254) begin
							uart_cnt <= 0;
							wrsig_reg <= 1'b0;/////////////0 				
							uart_stat <= 3'b010;//010 
							k <= 0;//0
						 end
						 else	begin			
							 uart_cnt <= uart_cnt + 1'b1;
							 wrsig_reg <= 1'b0;  
						 end
				  end
				  else begin
						 if(uart_cnt ==0) begin      
							dataout_reg <= store[k]; 
							uart_cnt <= uart_cnt + 1'b1;
							wrsig_reg <= 1'b1;                			
						 end	
						 else if(uart_cnt ==254) begin
							uart_cnt <= 0;
							wrsig_reg <= 1'b0; 
							k <= k + 1'b1;				
						 end
						 else	begin			
							 uart_cnt <= uart_cnt + 1'b1;
							 wrsig_reg <= 1'b0;  
						 end
				 end	 
			 end
			 3'b011: begin       //发送finish	 
					uart_stat <= 3'b010;
					data_sel<=1'b0;			
			 end
			 3'b010: begin       //发送finish	 
					uart_stat <= 3'b010;
					data_sel<=1'b0;			
			 end
			 default:uart_stat <= 3'b010;//000
			 endcase 
		  end
		end

		  //串口发送控制  
		always @(negedge clk)
		begin
		  if((rdsig == 1'b1) || (uart_stat == 3'b010)) begin   
				uart_wait <= 0;
				rx_data_valid <=1'b0;
		  end
		  else begin
			 if (uart_wait ==18'h3ffff) begin
				uart_wait <= 0;
				rx_data_valid <=1'b1;	
			 end		
			 else begin
				uart_wait <= uart_wait+1'b1;
				rx_data_valid <=1'b0;
			 end
		  end
		end

endmodule
