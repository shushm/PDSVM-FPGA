`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:16:08 01/08/2018 
// Design Name: 
// Module Name:    ddr_verilog 
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
module ddr_verilog(
         input wr_clk,	//PLL输出12.5MHz时钟
		   input rd_clk,	//PLL输出50MHz时钟
			input rst_n,	//复位信号，低电平有效
         output clk_50,         
			
			output fifo_full,		//FIFO满标志位
			output fifo_empty,		//FIFO空标志位
			output reg fifo_rdrdy,		//FIFO读数据有效信号
			output [7:0] fifo_rddb,	//FIFO读出数据总线
			//input fifo_rd,
			
			input rdsig,
			input [7:0] rxdata,
			
			output reg rd_start_flag,
			output reg fill_finish,

			output reg read_sign,
         output reg [127:0] fifo_data,  
	///////////////////////////////////////核函数传值
	input square_sign,                //input 1 bit
	input [31:0] square_data,         //input 32 bit
	input [15:0] square_cnt,          //input 16 bit
	output reg port1_read_done,
	input busy_flag,
	
	output reg [31:0] data_inx,       //output ddr-->kernel
	output reg [31:0] data_iny,       //
	output reg ker_cal_sign,          //output calculate start sign

	///////////////////////////////////////////////svm_train
	///input             alpha_read_start,
	input  [29:0]     alpha_rd_ddr,
	output reg        alpha_read_end,
	output reg [31:0] alpha_two_out,
   ///input             alpha_wr_start,
   input  [31:0]     alpha_wr_data,
   input  [29:0]     alpha_wr_ddr,       
   output reg        alpha_wr_end,
	output reg        ddr_orgin_end,
	
	/////////////////////////////////////////////////////ddr
	inout  [15:0]                      mcb3_dram_dq,
   output [13:0]                      mcb3_dram_a,
   output [2:0]                       mcb3_dram_ba,
   output                             mcb3_dram_ras_n,
   output                             mcb3_dram_cas_n,
	
   output                             mcb3_dram_we_n,
   output                             mcb3_dram_odt,
  
   output                             mcb3_dram_reset_n,////////////////
   output                             mcb3_dram_dm,
	output                             mcb3_dram_udm,
   inout                              mcb3_dram_udqs,
   inout                              mcb3_dram_udqs_n,
   inout                              mcb3_dram_dqs,
   inout                              mcb3_dram_dqs_n,
	
	output                             clk12m5,
	output                             rst_svm,
	output reg                         test_end,///.
	//input                              c3_sys_clk,
   //input                              rst_n,
	output                             mcb3_dram_cke,
   output                             mcb3_dram_ck,
   output                             mcb3_dram_ck_n,	
	inout                              mcb3_rzq,
   inout                              mcb3_zio,
	
	output calib_done,
	output ddr2_test_true,//led2
	output led3,
	output led4
			
		 
    );
	   reg alpha_read_start;
		reg alpha_wr_start;
////////////////////////////////////////////////ddr
      
      reg ddr2_test_true;
//------------------------ Regs/Wires ---------------------
		wire		c3_clk0;			//used as the user clock
		wire		c3_rst0;			//user clock reset signal
		wire		c3_calib_done;	//soft calibration done flag
		wire     c3_sys_rst_i;
		
		//--cmd block 
      wire		c3_p0_cmd_clk;	//connect to user clock
      reg		c3_p0_cmd_en;
      reg [2:0]	c3_p0_cmd_instr;
      reg [5:0]	c3_p0_cmd_bl;
      reg [29:0]	c3_p0_cmd_byte_addr;
      wire		c3_p0_cmd_empty;
      wire		c3_p0_cmd_full;
		//--write block
      wire		c3_p0_wr_clk;	//connect to user clock
      reg		c3_p0_wr_en;
      reg [3:0]	c3_p0_wr_mask;//15
      reg [31:0]	c3_p0_wr_data;
      wire		c3_p0_wr_full;
      wire		c3_p0_wr_empty;
      wire [6:0]	c3_p0_wr_count;
      wire		c3_p0_wr_underrun;
      wire		c3_p0_wr_error;
		//--read block
      wire		c3_p0_rd_clk;	//connect to user clock
      reg		c3_p0_rd_en;
      wire  [31:0]	c3_p0_rd_data;
      wire		c3_p0_rd_full;
      wire		c3_p0_rd_empty;
      wire [6:0]	c3_p0_rd_count;
      wire		c3_p0_rd_overflow;
      wire		c3_p0_rd_error;
		
		////////////////////////////////////port 2-3
		wire		c3_p1_cmd_clk;	//connect to user clock
      reg		c3_p1_cmd_en;
      reg [2:0]	c3_p1_cmd_instr;
      reg [5:0]	c3_p1_cmd_bl;
      reg [29:0]	c3_p1_cmd_byte_addr;
      wire		c3_p1_cmd_empty;
      wire		c3_p1_cmd_full;
		//--write block
      wire		c3_p1_wr_clk;	//connect to user clock
      reg		c3_p1_wr_en;
      reg [3:0]	c3_p1_wr_mask;//15
      reg [31:0]	c3_p1_wr_data;
      wire		c3_p1_wr_full;
      wire		c3_p1_wr_empty;
      wire [6:0]	c3_p1_wr_count;
      wire		c3_p1_wr_underrun;
      wire		c3_p1_wr_error;
		//--read block
      wire		c3_p1_rd_clk;	//connect to user clock
      reg		c3_p1_rd_en;
      wire  [31:0]	c3_p1_rd_data;
      wire		c3_p1_rd_full;
      wire		c3_p1_rd_empty;
      wire [6:0]	c3_p1_rd_count;
      wire		c3_p1_rd_overflow;
      wire		c3_p1_rd_error;
		//////////////////////////////////////////
		
      assign c3_sys_rst_i = ~rst_n;	//ddr2 ip,high reset;~rst_n
      assign calib_done = c3_calib_done;//if c3_calib_done=1,indicates the completion of all phases of cablibration

parameter C3_RST_ACT_LOW = 0;
//--------------------- Module instante-------------------


      wire		user_clk;
		wire		state_rst;
		reg [29:0] ddr_address;
		reg [29:0] port1_ddr_address;///.
      reg [29:0] alpha_address;	
		reg [29:0] errorcache_address;
		///////////////////////////////////////////port0
		//user control logic -- state machine
		reg	[9:0]		state;	//state machine
		reg   [9:0]    state_next;
		parameter	WAITCALIBDONE =	9'b000000000;
		parameter	IDLE =				9'b000000001;
		parameter	WRITEDATA	= 		9'b000000010;
		parameter	WRITEDATADONE = 	9'b000000100;
		parameter	WRITECMD	= 			9'b000001000;
		parameter   WRITECMDDONE =		9'b000010000;
		parameter	READCMD =			9'b000100000;
		parameter	READCMDDONE	=		9'b001000000;
		parameter	READDATA	=			9'b010000000;
		parameter	READDATADONE =		9'b100000000;
		parameter   DDRFINISH =       9'b100000001;
		/////////////////////////////////////////////port1
		reg [9:0] port1_state;
		reg [9:0] port1_state_next;
		reg [7:0] port1_cnt;

		parameter	port1_IDLE =		    9'b100010101;
		parameter	port1_WRITEDATA =     9'b100010110;
		parameter	port1_WRITEDATADONE = 9'b100010111;
		parameter	port1_WRITECMD	= 		 9'b100011000;
		parameter   port1_WRITECMDDONE =	 9'b100011001;
		parameter	port1_READCMD =		 9'b100011010;
		parameter	port1_READCMDDONE	=	 9'b100011011;
		parameter	port1_READDATA	=		 9'b100011100;
		parameter	port1_READDATADONE =	 9'b100011101;
		
		parameter	port1_WRITEDATATWO =	 9'b100011110;///.
		parameter	port1_READCMD_TWO =	 9'b100011111;
		parameter	port1_READDATA_TWO =	 9'b100100000;
		
		parameter   port1_READ_MID =      9'b100101010;//--//
		parameter   alpha_WR_MID =        9'b100101011;//--//
		parameter   SVM_WAIT =            9'b100101100;//--//
		parameter   port1_WAITING =       9'b100101101;//--//
      parameter   alpha_WAITING =       9'b100101110;//--//
		parameter   errorcache_WAITING =  9'b100101111;//--//
		
		parameter   errorcache_WRDATA =   9'b100100001;
		parameter   errorcache_WRCMD =    9'b100100010;
		parameter   errorcache_WRDONE =   9'b100100011;
		parameter   alpha_WRONE =         9'b100100100;
		parameter   alpha_WRCMDONE =      9'b100100101;
		parameter   alpha_WRTWO =         9'b100100110;
		parameter   alpha_WRCMDTWO =      9'b100100111;
		parameter   alpha_WRDONE =        9'b100101000;
		parameter   SVM_WRIDLE =          9'b100101001;///.
		
		/////////////////////////////////////////////sample-->kernel
		reg [7:0]   kernel_i;
		reg [7:0]   kernel_j;
		reg [7:0]   ij_cnt;
		reg         svm_ker_flag;
		parameter   read_cmd =        9'b100001110;
		parameter   read_cmd_done =   9'b100001111;
		parameter   read_data =       9'b100010000;
		parameter   read_data_done =  9'b100010001;
		parameter   read_ready =      9'b100010010;////.
		parameter   read_cmd_two =    9'b100010011;
		parameter   read_mid =        9'b100010100;
		
		////////////////////////////////////////////内积和
		parameter   WRITE_IDLE_1 =      9'b100000010;//3'b000;
		parameter   WRITE_FIFO_1 =      9'b100000011;//3'b001;
		parameter   WRITE_DATA_DONE_1 = 9'b100000100;//3'b010;
		parameter   WRITE_CMD_START_1 = 9'b100000101;//3'b011;
		parameter   WRITE_CMD_1 =       9'b100000110;//3'b100;
		parameter   WRITE_DONE_1 =      9'b100000111;//3'b101;

		parameter READ_IDLE_1 =       9'b100001000;//3'b000;
		parameter READ_CMD_START_1 =  9'b100001001;//3'b001;
		parameter READ_CMD_1 =        9'b100001010;//3'b010;
		parameter READ_WAIT_1 =       9'b100001011;//3'b011;
		parameter READ_DATA_1 =       9'b100001100;//3'b100;
		parameter READ_DONE_1 =       9'b100001101;//3'b101;
		
		/////////////////////////////////////////
		parameter DDR_STARTADDR = 26'h0000000;
		parameter DDR_ENDADDR = 26'h1000000;
		
//---------------------user logic interface---------------------
		assign	user_clk = c3_clk0;
		assign	c3_p0_cmd_clk	= c3_clk0;//user_clk;
		assign	c3_p0_wr_clk	= c3_clk0;//user_clk;
		assign	c3_p0_rd_clk	= c3_clk0;//user_clk;
		assign	state_rst		= c3_rst0; 


	   wire clk_12m5;	//PLL输出12.5MHz时钟
		wire clk_25m;	//PLL输出25MHz时钟
		wire clk_50m;	//PLL输出50MHz时钟
		wire clk_65m;	//PLL输出65MHz时钟
		wire clk_108m;	//PLL输出108MHz时钟
		wire clk_130m;	//PLL输出130MHz时钟
		wire sys_rst_n;	//PLL输出的locked信号，作为FPGA内部的复位信号，低电平复位，高电平正常工作
		assign clk_50 = clk_50m;
		//assign fifo_data = c3_p0_rd_data;
	

assign clk12m5 = c3_clk0;//clk_12m5;///.
assign rst_svm = sys_rst_n;//c3_rst0; ///.
reg led4;
reg [27:0] count;
assign led3 = count[23];

always @(posedge user_clk or posedge state_rst)//posedge
begin
	if(state_rst) 
	begin//state_rst
		led4 <= 1;
		count <= 0;
	end
	else begin
		  count <= count + 1;
		  led4 <= ~led4;
		//led3 <= ~led3;
	end
			
end

reg [31:0] number;	
reg [15:0] rf_cnt;

wire fill_finish_flag;
reg ddr_end;
wire ddr_end_flag;
assign ddr_end_flag = ddr_end;
assign fill_finish_flag = fill_finish;
reg [7:0] test_end_cnt;

reg [7:0] kernel_cnt;
//wire svm_kernel_sign;
//assign svm_kernel_sign = square_sign;
reg [31:0] c3_rd1_data;
reg [31:0] c3_rd2_data;
reg [31:0] c3_rd3_data;

wire svm_kernel_sign;
reg ker_wr_sign;///.
reg ker_wr_flag;
reg kernel_sign_reg;
assign svm_kernel_sign = square_sign;

//------------------FSM three segment--------------

	always @ (posedge user_clk or posedge state_rst) //posedge
	begin
		if (state_rst) begin//state_rst
			c3_p0_cmd_en <= 0;
			c3_p0_cmd_instr <= 0;
			c3_p0_cmd_bl <= 0;
			c3_p0_cmd_byte_addr <= 0;
			ddr_address <= DDR_STARTADDR;//DDR_STARTADDR
			c3_p0_wr_en	<= 0;
			c3_p0_wr_mask <= 0;
			c3_p0_wr_data <= 0;
			c3_p0_rd_en <= 0;
			ddr2_test_true <= 0;//0
			number <= 32'd0;//32'd0;
			read_sign <= 1'b0;
			state_next <= WAITCALIBDONE;
			
			kernel_i <= 8'd79;//5
			kernel_j <= 8'd79;//5
			svm_ker_flag <= 1'b0;
			ker_wr_sign <= 1'b0;///.
			ker_wr_flag <= 1'b0;
			port1_ddr_address <= 30'd13320;//148
			port1_read_done <= 1'b0;
			c3_rd1_data <= 32'd0;
			c3_rd2_data <= 32'd0;
			c3_rd3_data <= 32'd0;
			ker_cal_sign <= 1'b0;
			errorcache_address <= 30'd13720;//200
			alpha_address <= 30'd13360;//160
			
			test_end_cnt <= 8'd0;
			port1_cnt <= 8'd0;
			
			alpha_wr_end <= 1'b0;
			alpha_read_end <= 1'b0;
			alpha_read_start <= 1'b0;//--
		   alpha_wr_start <= 1'b0;//--
		end
		else begin
			case(state_next)
				WAITCALIBDONE: begin
				   if (c3_calib_done)
					begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						ddr_address <= DDR_STARTADDR;//DDR_STARTADDR
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						ddr2_test_true <= 0;
						number <= 32'hAABBCCDD;//32'd0;data_out;//
						state_next <= IDLE;//-
					end
				end
				
				IDLE: begin
				  if(ddr_end_flag == 1'b0)
				  begin
					 if(fill_finish_flag == 1'b1)
					 begin
						if (c3_p0_cmd_empty)
						begin
						   state_next <= WRITEDATA;
						end
					end
				  end
				  else begin
					   if (c3_p0_cmd_empty)
						begin						  
						   state_next <= read_ready;//--READCMD;//--
						end
				  end
				  c3_p0_cmd_en <= 0;
				  c3_p0_cmd_instr <= 0;
				  c3_p0_cmd_bl <= 0;
				  //	c3_p0_cmd_byte_addr <= 0;
				  c3_p0_wr_en	<= 0;
				  c3_p0_wr_mask <= 0;
				  //	c3_p0_wr_data <= 0;
				  c3_p0_rd_en <= 0;
				  test_end_cnt <= 0;//-
				end
				
				WRITEDATA: begin //put c3_p0_wr_data[31:0]==0xaaaa_aaaa into DDRIP_write_fifo
				  if (!c3_p0_wr_full)
				  begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
					//	c3_p0_cmd_byte_addr <=0;
						c3_p0_wr_en	<= 1;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= data_out;//number;
						c3_p0_rd_en <= 0;
						state_next <= WRITEDATADONE;
				  end
				end
				
				WRITEDATADONE: begin //DDRIP_write_fifo is full
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
				//	c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				//	c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					state_next <= WRITECMD;
				end
				
				WRITECMD: begin   //put DDRIP_write_fifo into externel ddr2 sdram
					if (!c3_p0_cmd_full)                         //如果命令FIFO不满
				   begin
						c3_p0_cmd_en <= 1;
						c3_p0_cmd_instr <= 3'b000;//write data to port0
						c3_p0_cmd_bl <= 6'd0;	//63,Burst length is encoded as 0 to 63, representing 1 to 64 user words
						c3_p0_cmd_byte_addr <= ddr_address;//ddr_address
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
					//	c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= WRITECMDDONE;
					end
				end
				
				WRITECMDDONE: begin //write_fifo is empty
					if (c3_p0_wr_empty)
					begin	
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
					//	c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
					//	c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= READDATADONE;
					end
				end
				
				READDATADONE: begin //read_fifo is empty
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
				//	c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				//	c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					number <= number;// + 1;
					if(ddr_address >= DDR_ENDADDR)
					begin
						ddr_address <= DDR_STARTADDR;
						state_next <= IDLE;//- 
					end
					else begin
						ddr_address <= ddr_address + 30'd4;//9'd256,1024
						state_next <= IDLE;//-
					end
				end
				////////////////////////////////port0
				////////////////////////////////sample-->kernel
				read_ready: begin
					if(busy_flag == 0)
					begin
				      c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;//
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;					
						//--ker_wr_sign <= 1'b0;
						ker_cal_sign <= 1'b0;
						state_next <= read_cmd;
						test_end_cnt <= 0;//-
				   end
					else begin
						state_next <= port1_IDLE;//READCMD;
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;//
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;					
						//--ker_wr_sign <= 1'b0;
						ker_cal_sign <= 1'b0;
						test_end_cnt <= 0;//-
					end
				end
				read_cmd: begin
				   c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b001;
					c3_p0_cmd_bl <= 6'd0;	//63,Burst length is encoded as 0 to 63, representing 1 to 64 user words				
					c3_p0_cmd_byte_addr <= (kernel_i<<2);
					//(kernel_i<<2);//ddr_address
					//64*(32/8)=256,64深度的fifo向ddr3搬运的数据数量里最多为64个和fifo深度想通
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				//	c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					///data_inx <=0;
					state_next <= read_cmd_done;
					test_end_cnt <= test_end_cnt + 1;
				end
				read_cmd_done: begin
					if (!c3_p0_rd_full)
					begin
					   if(test_end_cnt <= 8)
					   begin
					      state_next <= read_cmd;//read_cmd_two;
							c3_p0_cmd_en <= 0;
							c3_p0_cmd_instr <= 0;
							c3_p0_cmd_bl <= 0;
						//	c3_p0_cmd_byte_addr <= 0;
							c3_p0_wr_en	<= 0;
							c3_p0_wr_mask <= 0;
						//	c3_p0_wr_data <= 0;
							c3_p0_rd_en <= 1;//0
							data_inx <= c3_p0_rd_data;
					   end
						else begin
					      state_next <= read_mid;//read_cmd_two;
							c3_p0_cmd_en <= 0;
							c3_p0_cmd_instr <= 0;
							c3_p0_cmd_bl <= 0;
						//	c3_p0_cmd_byte_addr <= 0;
							c3_p0_wr_en	<= 0;
							c3_p0_wr_mask <= 0;
						//	c3_p0_wr_data <= 0;
							c3_p0_rd_en <= 1;//0
							data_inx <= c3_p0_rd_data;
					   end
					end				
				end
				read_mid: begin
					if (c3_p0_rd_empty)
					begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						//	c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= read_cmd_two;
						test_end_cnt <= 0;//-
						///data_inx <= data_inx;
					end					
				end
				read_cmd_two: begin
				   c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b001;
					c3_p0_cmd_bl <= 6'd0;
					c3_p0_cmd_byte_addr <= (kernel_j<<2);
					//(kernel_j<<2);//ddr_address
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				//	c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					///data_iny <=0;
					state_next <= read_data;
					test_end_cnt <= test_end_cnt + 1;
				end
				read_data: begin
               if (!c3_p0_rd_full)
					begin
					   if(test_end_cnt <= 6)
					   begin
						   c3_p0_cmd_en <= 0;
							c3_p0_cmd_instr <= 0;
							c3_p0_cmd_bl <= 0;
						//	c3_p0_cmd_byte_addr <= 0;
							c3_p0_wr_en	<= 0;
							c3_p0_wr_mask <= 0;
						//	c3_p0_wr_data <= 0;
							c3_p0_rd_en <= 1;
							data_iny <= c3_p0_rd_data;
							state_next <= read_cmd_two;
				      end
						else begin
						   c3_p0_cmd_en <= 0;
							c3_p0_cmd_instr <= 0;
							c3_p0_cmd_bl <= 0;
						//	c3_p0_cmd_byte_addr <= 0;
							c3_p0_wr_en	<= 0;
							c3_p0_wr_mask <= 0;
						//	c3_p0_wr_data <= 0;
							c3_p0_rd_en <= 1;
							data_iny <= c3_p0_rd_data;
							state_next <= read_data_done;
				      end
					end
				end
				read_data_done: begin
				   if (c3_p0_rd_empty)
					begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						//	c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						//	c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						ker_cal_sign <= 1'b1;
						state_next <= READ_CMD_1;
						test_end_cnt <= 0;//-
					end
				end
				READ_CMD_1: begin  //read_fifo is full
					if(svm_kernel_sign == 1'b1)
					begin
						state_next <= WRITE_IDLE_1;//-
					end
					else begin
						state_next <= READ_CMD_1;
					end
               c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
			   	c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					ker_cal_sign <= 1'b1;					
				end
				/////////////////////////////////////ddr-->kernel
				/////////////////////////////////////port1
				WRITE_IDLE_1: begin 					//command fifo is empty
				   if(svm_kernel_sign == 1'b0)
					begin
						state_next <= WRITE_DATA_DONE_1;//WRITE_FIFO_1;
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						//	c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						//	c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						ker_cal_sign <= 1'b0;
						///c3_p0_wr_data <= square_data;
						//port1_ddr_address <= port1_ddr_address + 4;//64 + (square_cnt<<2);
					end
				end
				WRITE_DATA_DONE_1: begin //DDRIP_write_fifo is full
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;//
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				//	c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
				   test_end_cnt <= 0;//-
					c3_p0_wr_data <= square_data;//32'hAABBCCDD;//
					c3_rd2_data <= square_data;
					port1_ddr_address <= port1_ddr_address - 4;					
					if(kernel_j == 0)
					begin
						kernel_i <= kernel_i - 1;
					   kernel_j <= kernel_i - 1;
					end
					else if(kernel_j > 0) 
					begin
						kernel_i <= kernel_i;
						kernel_j <= kernel_j - 1;
					end
               state_next <= WRITE_FIFO_1;//可忽略
				end
				WRITE_FIFO_1: begin //put c3_p0_wr_data[31:0]==0xaaaa_aaaa into DDRIP_write_fifo
					if (!c3_p0_wr_full)
					begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
					   //c3_p0_cmd_byte_addr <=0;
						c3_p0_wr_en	<= 1;
						c3_p0_wr_mask <= 0;
						//c3_p0_wr_data <= square_data;//number;
						c3_p0_rd_en <= 0;
						//test_end_cnt <= test_end_cnt + 1;
					   state_next <= WRITE_CMD_START_1;//WRITE_DATA_DONE_1;
					end
				end
				WRITE_CMD_START_1: begin
               if (!c3_p0_cmd_full)                         //如果命令FIFO不满
				   begin   
                  state_next <= WRITE_CMD_1;
						c3_p0_cmd_en <= 1;
						c3_p0_cmd_instr <= 3'b000;//write data to port0
						c3_p0_cmd_bl <= 6'd0;	//63,Burst length is encoded as 0 to 63, representing 1 to 64 user words
						c3_p0_cmd_byte_addr <= port1_ddr_address;//ddr_address
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						//	c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;					
               end
				end
				WRITE_CMD_1: begin
				   if (c3_p0_wr_empty)
					begin
						state_next <= read_ready;//read_data_done;
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;//
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
					//	c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						test_end_cnt <= 0;//-
					end
				end
				////////////////////////////////////////////////kernel finish
				////////////////////////////////////////////alpha,errorcache初始化
				port1_IDLE: begin
				   if (c3_p0_cmd_empty)
				   begin
					   if(port1_cnt < 80)     //6个样本
					   begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= port1_WRITEDATA;
						end
					   else begin
						state_next <= SVM_WRIDLE;//READCMD;
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						end
					end
				end
				port1_WRITEDATA: begin
					if (!c3_p0_wr_full)
					begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						//c3_p0_cmd_byte_addr <=0;
						c3_p0_wr_en	<= 1;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 32'd0;//32'hAABBCCDD;
						c3_p0_rd_en <= 0;
						state_next <= port1_WRITECMD;
					end
			   end		
				port1_WRITECMD: begin
					if (!c3_p0_cmd_full)                         //如果命令FIFO不满
				   begin 
						c3_p0_cmd_en <= 1;
						c3_p0_cmd_instr <= 3'b000;
						c3_p0_cmd_bl <= 6'd0;
						c3_p0_cmd_byte_addr <= alpha_address;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
					 //c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= port1_WRITECMDDONE;
				   end
				end
				port1_WRITECMDDONE: begin
					if (c3_p0_wr_empty)
				   begin
					   if(port1_cnt <= 80)//6个样本
						begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
					  //c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
					  //c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= port1_WRITEDATA;
						alpha_address <= alpha_address + 4;
						port1_cnt <= port1_cnt + 1;
						end
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
					   c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
					   c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						port1_cnt <= 0;
						state_next <= port1_WRITEDATADONE;
					end
				end
				port1_WRITEDATADONE: begin
					if (!c3_p0_wr_full)
					begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
					  //c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 1;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 32'd0;//32'hEE8899FF;
						c3_p0_rd_en <= 0;
						state_next <= port1_WRITEDATATWO;
					end
				end
				port1_WRITEDATATWO: begin
					if (!c3_p0_cmd_full)                         //如果命令FIFO不满
				   begin 
						c3_p0_cmd_en <= 1;
						c3_p0_cmd_instr <= 3'b000;
						c3_p0_cmd_bl <= 6'd0;
						c3_p0_cmd_byte_addr <= errorcache_address;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
					 //c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= port1_READDATADONE;
					end
            end				
				port1_READDATADONE: begin					     
					if (c3_p0_wr_empty)
					begin
					   if(port1_cnt <= 80)//6个样本
						begin
						state_next <= port1_WRITEDATADONE;
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;	
						port1_cnt <= port1_cnt + 1;
						errorcache_address <= errorcache_address + 4;
						end
						else begin
						state_next <= port1_IDLE;
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						end
               end					
				end
				////////////////////////////////////////////alpha,errorcache初始化finish
				SVM_WRIDLE: begin
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
				   c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
               state_next <= SVM_WAIT;
					alpha_wr_start <= 1'b1;
            end
				SVM_WAIT: begin
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
				   c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					port1_cnt <= 0;   //--//
					test_end_cnt <= 0;///---///
					ddr_orgin_end <= 1'b1;
					alpha_read_end <= 1'b0;
					//errorcache_wr_end <= 1'b0;
					alpha_wr_end <= 1'b0;
					if(alpha_read_start == 1'b1 && alpha_wr_start == 1'b0)
					begin
						state_next <= port1_READCMD;
					end
					else if(alpha_read_start == 1'b0 && alpha_wr_start == 1'b1)
					begin
						state_next <= alpha_WRONE;
					end
					else if(alpha_read_start == 1'b0 && alpha_wr_start == 1'b0)
					begin
						state_next <= SVM_WAIT;
					end
				end		
				alpha_WRONE: begin
				   if (!c3_p0_wr_full)
				   begin
				      c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						//c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 1;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 32'hFEDCBABA;//alpha_wr_one;//
						c3_p0_rd_en <= 0;
						state_next <= alpha_WRCMDONE;
				   end
				end
				alpha_WRCMDONE: begin
				   if (c3_p0_wr_empty)
				   begin
					   c3_p0_cmd_en <= 1;
						c3_p0_cmd_instr <= 3'b000;//write data to port0
						c3_p0_cmd_bl <= 6'd0;	//63,Burst length is encoded as 0 to 63, representing 1 to 64 user words
						c3_p0_cmd_byte_addr <= 364;//alpha_wrddr_one;//172
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
					 //c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= alpha_WR_MID;
					end
				end
				alpha_WR_MID: begin
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
				   c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					test_end_cnt <= 0;
					alpha_wr_end <= 1'b1;
					state_next <= alpha_WAITING;
				end
            alpha_WAITING: begin
				   if(test_end_cnt <= 5)//10
					begin
					   c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						test_end_cnt <= test_end_cnt + 1;
						state_next <= alpha_WAITING;
					end
					else begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						state_next <= SVM_WAIT;
						alpha_read_start <= 1'b1;//--
						alpha_wr_start <= 1'b0;//--
					end
				end
				////////////////////////////////////////////
				port1_READCMD: begin
				   c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b001;
					c3_p0_cmd_bl <= 6'd0;//-0
					c3_p0_cmd_byte_addr <= 360;//alpha_rd_ddr;//
					//64*(32/8)=256,64深度的fifo向ddr3搬运的数据数量里最多为64个和fifo深度想通
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0; //-1 
					state_next <= DDRFINISH;
					test_end_cnt <= test_end_cnt + 1;
				end
				DDRFINISH:begin
				   c3_p0_cmd_en <= 0;//-1
					c3_p0_cmd_instr <= 0;//-3'b001
					c3_p0_cmd_bl <= 0;//-6'd63
					c3_p0_cmd_byte_addr <= 360;//-360
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
               state_next <= port1_READDATA;
				   c3_p0_rd_en <= 0;					
				end
				port1_READDATA: begin
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;//-3'b001
					c3_p0_cmd_bl <= 0;//-6'd63
					c3_p0_cmd_byte_addr <= 0;//-360
				   c3_p0_wr_en	<= 0;
				   c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					if(test_end_cnt <= 8)
					begin
					   state_next <= port1_READCMD;
						c3_p0_rd_en <= 1;//0
					end
					else begin
					   state_next <= port1_READ_MID;
					   alpha_two_out <= c3_p0_rd_data;
						c3_p0_rd_en <= 1;//1
					end
				end
				port1_READ_MID: begin	
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;//
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					test_end_cnt <= 0;
					alpha_read_end <= 1'b1;
					state_next <= port1_WAITING;
				end
				port1_WAITING: begin
				   if(test_end_cnt <= 5)
					begin
						c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
						test_end_cnt <= test_end_cnt + 1; 
						state_next <= port1_WAITING;		
					end
					else begin
					   c3_p0_cmd_en <= 0;
						c3_p0_cmd_instr <= 0;
						c3_p0_cmd_bl <= 0;
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
						c3_p0_rd_en <= 0;
					   state_next <= SVM_WAIT;
						alpha_read_start <= 1'b0;//--
						port1_read_done <= 1'b1;
					   fifo_data <= {data_inx,data_iny,alpha_two_out,c3_rd2_data};
					end
				end
				
			endcase
		end //else:if(state_rst)
	end //always

/*****************************************************************************/
//ddr命令信号读写选择
/*****************************************************************************/
/*
always @(*)
begin
	if(!ddr_end_flag) begin          //如果图像未存入ddr中		
			c3_p0_cmd_en<=c3_p0_cmd_en_w;
			c3_p0_cmd_instr<=c3_p0_cmd_instr_w;
			c3_p0_cmd_bl<=c3_p0_cmd_bl_w;
			c3_p0_cmd_byte_addr<=c3_p0_cmd_byte_addr_w;
	end
	else begin
			c3_p0_cmd_en<=c3_p0_cmd_en_r;
			c3_p0_cmd_instr<=c3_p0_cmd_instr_r;
			c3_p0_cmd_bl<=c3_p0_cmd_bl_r;
			c3_p0_cmd_byte_addr<=c3_p0_cmd_byte_addr_r;
	end
end
*/
///////////////////////////////////////////////ddr
//-----------------------------------------------------------
//定时产生32个FIFO数据写入和读出操作												
reg[7:0] fifo_wrdb;	//FIFO写入数据													
reg fifo_wren;		//FIFO写使能信号															
reg fifo_rden;		//FIFO读使能信号	

//写FIFO计数周期
reg[11:0] wrcnt;																

//读FIFO计数周期	
reg[11:0] rdcnt;

///////////////////////////////////////////////////fifo start
////////////////fifo 写入
reg rd_sel_flag;
reg wr_end_flag;
always @(posedge wr_clk or posedge c3_rst0)
begin							
		if(c3_rst0)
		begin
		     rd_sel_flag <= 1'b0;
			  wr_end_flag <= 1'b0;
			  fifo_wren <= 1'b0;
			  fifo_wrdb <= 8'b0;
			  wrcnt <= 12'd0;
			  
		end
		else begin
		     if(wrcnt <= 324)//5个32位数据,27
			  begin
			        //fifo_wren <= 1'b1;
					  rd_sel_flag <= rdsig;
					  if(rd_sel_flag && !rdsig)//上升沿检测
					  begin
					       fifo_wren <= 1'b1;
							 fifo_wrdb <= rxdata;
							 wrcnt <= wrcnt+1'b1;
					  end
					  else begin
					       fifo_wren <= 1'b0;
					  end
			  end
			  else if(wrcnt >= 325)//28
			  begin
			       fifo_wren <= 1'b0;
					 fifo_wrdb <= 8'b0;
					 wr_end_flag <= 1'b1;
			  end
		end

end		

///////////////////////////////////fifo读出
reg wr_up_det;
//reg rd_start_flag;
wire rd_start_sign;
assign rd_start_sign = rd_start_flag;
always @(posedge wr_clk or posedge c3_rst0)
begin
     if(c3_rst0)
	  begin
	       wr_up_det <= 1'b0;
			 rd_start_flag <= 1'b0;
	  end
	  else begin
	       wr_up_det <= wr_end_flag;
			 if(!wr_up_det && wr_end_flag)//上升沿检测
			 begin
			      rd_start_flag <= 1'b1;
			 end
	  end
end
	

reg [7:0] ss [3:0];
reg [31:0] data_out;
//reg [15:0] rf_cnt;
reg [7:0] ss_reg;///
reg fill_edge_down;
always @(posedge clk_12m5 or posedge c3_rst0)//clk_12m5
begin
     if(c3_rst0)
	  begin
	       rdcnt <= 12'd0;
			 fifo_rden <= 1'b0;
			 fill_finish <= 1'b0;
			 data_out <= 32'd0;
			 rf_cnt <= 16'd0;//////
			 ss_reg <= 8'd0;
			 ddr_end <= 1'b0;
			 fill_edge_down <= 1'b0;
	  end
	  else begin
	       if(rd_start_sign == 1'b1)
			 begin
			      
					if(rf_cnt < 2)
					begin
						  fifo_rden <= 1'b1;
						  rf_cnt <= rf_cnt + 1;
					end
					else 
					begin
					     //fill_edge_down <= fill_finish;
						  //if(fill_edge_down && !fill_finish)//下降沿检测
						  //begin
						  //    rf_cnt <= rf_cnt + 1;
						  //end
						  if(rdcnt <= 3)
						  begin
								fifo_rden <= 1'b1;
								fill_finish <= 1'b0;
								if(rdcnt == 0)
								begin
								   ss_reg <= fifo_rddb;
									rdcnt <= rdcnt + 1;
								end
								else begin
								   ss[0] <= ss_reg;
									ss[rdcnt] <= fifo_rddb;
									rdcnt <= rdcnt + 1;
								end
						  end
						  else if(rdcnt > 3)
						  begin
							 rf_cnt <= rf_cnt + 1;
							 if(rf_cnt >= 82)//8
							 begin
							      ddr_end <= 1'b1;
									fifo_rden <= 1'b0;
								   rdcnt <= 4;//1
								   data_out <= {ss[0],ss[1],ss[2],ss[3]};
								   fill_finish <= 1'b1;
							 end
							 else begin
								   fifo_rden <= 1'b1;
								   rdcnt <= 1;//1
									ss_reg <= fifo_rddb;
								   data_out <= {ss[0],ss[1],ss[2],ss[3]};
								   fill_finish <= 1'b1;
							 end
						  end
					end
					
			end
	  end
end
///////////////////////////////////////////////////////fifo end
		
//FIFO读数据有效标志位
always @(posedge clk_12m5 or posedge c3_rst0)//clk_12m5
	if(c3_rst0) fifo_rdrdy <= 1'b0;
	else fifo_rdrdy <= fifo_rden;


///////////////////////////////////////////////////////////////////////////////////////////
      always @(posedge train_clk or negedge rst_n)
	   begin
		    if(!rst_n)
			 begin
			     /////////////////////		
			     start_A <= 1'b0;
				  start_B <= 1'b0;
				  start_C <= 1'b0;
				  A_one <= 32'd0;
				  A_two <= 32'd0;
				  B_one <= 17'd0;
				  B_two <= 17'd0;
				  C_one <= 17'd0;
				  C_two <= 17'd0;
				  //train_start <= 1'b0;
					
				  start_svm <= 1'b0;
				  begin_svm <= 1'b0;
				  r_two <= 32'd0;
				  i_one <= 12'd0;//32
				  i_two <= 12'd0;//32
				  qq <= 12'd0;//32
				  flag_svm <= 1'b0;
				  
				  alpha_one <= 32'd0;
				  alpha_two <= 32'd0;
				  y_one <= 1'b0;//32
				  y_two <= 1'b0;//32
				  E_one <= 32'd0;
				  E_two <= 32'd0;
				  a_one <= 32'd0;
				  a_two <= 32'd0;
				  s <= 1'b0;//32
				  L <= 32'd0;
				  H <= 32'd0;
				  L_H <= 32'd0;
				  a_L <= 32'd0;
				  a_H <= 32'd0;
				  aa_c <= 32'd0;
				  a_a <= 32'd0;
				  a_two_alpha <= 32'd0;
				  
				  eta <= 32'd0;
				  bNew <= 32'd0;
				  deltaB <= 32'd0;
				  b_add_b <= 32'd0;
				  b_two <= 32'd0;
				  b_one <= 32'd0;
				  t_one <= 32'd0;
				  t_two <= 32'd0;
				  k_one_one <= 32'd0;
				  k_one_two <= 32'd0;
				  k_two_two <= 32'd0;
				  
				  sub_ee <= 32'd0;
				  KK_train <= 32'd0;
				  sub_e <= 32'd0;
				  KK_tri <= 32'd0;
		        div_sign <= 1'b0;			  
				  
				  svm_b <= 32'd0;
				  status <= s_idle;///
				  s_state_reg <= s_idle;///
				  
				  busy_a_two <= 1'b0;
				  busy_TK_one <= 1'b0;
				  busy_YN <= 1'b1;
				  busy_btwo <= 1'b0;
				  busy_bone <= 1'b0;
				  busy_bthree <= 1'b0;
				  busy_sumone <= 1'b0;
				  busy_sumtwo <= 1'b0;
				  busy_sumthree <= 1'b0;
				  
				  /////////////////////////////////////////////////////
			     c <= 32'h00028000;//C = 1,0.5,0.25,修改C，偏离置信
			     iterCounter <= 0;
			     numChanged <= 0;
			     examineall <= 1'b1;//初始置1
			  
			     eps <= 32'b00000000000000000000000001000010;//0.00100708,0.00098
			     tolerance <= 32'b00000000000000000000000001000010;//0.00100708
				  
				  test_end_sign <= 1'b0;
				  ss_out <= 128'd0;
				  alpha_rd_flag <= 1'b0;
				  alpha_wr_flag <= 1'b0;
				  errorcache_wr_flag <= 1'b0;
				  alpha_read_start <= 1'b0;//
				  alpha_rd_ddr <= 30'd0;//
				  alpha_wr_start <= 1'b0;//
				  alpha_wr_data <= 32'd0;//
				  alpha_wr_ddr <= 30'd0;//
				  svc_reg <= 32'd0;
				  smo_reg <= 32'd0;
				  e_cnt <= 12'd0;
				  error_cnt <= 12'd0;
				  sum_one <= 32'd0;
				  sum_two <= 32'd0;
				  sum_three <= 32'd0;
				  
				  test_ddr <= 1'b0;
				  delay_count <= 8'd0;
				  address_reg <= 30'd0;
				  alpha_er <= 32'd0;
				  RT <= 32'd0;///
				  s_out <= 80'd0;//-
				  ///////////////////////////////////////
				  adds_reg[0] <= 1280;
				  adds_reg[1] <= 1296;
				  adds_reg[2] <= 1328;
				  adds_reg[3] <= 1376;
				  adds_reg[4] <= 1440;
				  adds_reg[5] <= 1520;
				  adds_reg[6] <= 1616;
				  adds_reg[7] <= 1728;
				  adds_reg[8] <= 1856;
				  adds_reg[9] <= 2000;
				  adds_reg[10] <= 2160;
				  adds_reg[11] <= 2336;
				  adds_reg[12] <= 2528;
				  adds_reg[13] <= 2736;
				  adds_reg[14] <= 2960;
				  adds_reg[15] <= 3200;
				  adds_reg[16] <= 3456;
				  adds_reg[17] <= 3728;
				  adds_reg[18] <= 4016;
				  adds_reg[19] <= 4320;
				  adds_reg[20] <= 4640;
				  adds_reg[21] <= 4976;
				  adds_reg[22] <= 5328;
				  adds_reg[23] <= 5696;
				  adds_reg[24] <= 6080;
				  adds_reg[25] <= 6480;
				  adds_reg[26] <= 8416;
				  adds_reg[27] <= 7328;
				  adds_reg[28] <= 7776;
				  adds_reg[29] <= 8240;
				  adds_reg[30] <= 8720;
				  adds_reg[31] <= 9216;
				  adds_reg[32] <= 9728;
				  adds_reg[33] <= 10256;
				  adds_reg[34] <= 10800;
				  adds_reg[35] <= 11360;
				  adds_reg[36] <= 11936;
				  adds_reg[37] <= 12528;
				  adds_reg[38] <= 13136;
				  adds_reg[39] <= 13760;
				  adds_reg[40] <= 14400;
				  adds_reg[41] <= 15056;
				  adds_reg[42] <= 15728;
				  adds_reg[43] <= 16416;
				  adds_reg[44] <= 17120;
				  adds_reg[45] <= 17840;
				  adds_reg[46] <= 18576;
				  adds_reg[47] <= 19328;
				  adds_reg[48] <= 20096;
				  adds_reg[49] <= 20880;
				  adds_reg[50] <= 21680;
				  adds_reg[51] <= 22496;
				  adds_reg[52] <= 23328;
				  adds_reg[53] <= 24176;
				  adds_reg[54] <= 25040;
				  adds_reg[55] <= 25920;
				  adds_reg[56] <= 26816;
				  adds_reg[57] <= 27728;
				  adds_reg[58] <= 28656;
				  adds_reg[59] <= 29600;
				  adds_reg[60] <= 30560;
				  adds_reg[61] <= 31536;
				  adds_reg[62] <= 32528;
				  adds_reg[63] <= 33536;
				  adds_reg[64] <= 34560;
				  adds_reg[65] <= 35600;
				  adds_reg[66] <= 36656;
				  adds_reg[67] <= 37728;
				  adds_reg[68] <= 38816;
				  adds_reg[69] <= 39920;
				  adds_reg[70] <= 41040;
				  adds_reg[71] <= 42176;
				  adds_reg[72] <= 43328;
				  adds_reg[73] <= 44496;
				  adds_reg[74] <= 45680;
				  adds_reg[75] <= 46880;
				  adds_reg[76] <= 48096;
				  adds_reg[77] <= 49328;
				  adds_reg[78] <= 50576;
				  adds_reg[79] <= 51840;
				  
			 end
			 else begin
				          //////////////////////////////////////////////////////svm训练过程
							 case (status)
							 s_waiting: 
							       begin
									    status <= s_waiting;
										 test_end_sign <= 1'b1;///
										 ss_out <= {svm_b,E_one,svc_reg,eta};//-ss_out;//-
									 end
							 s_idle:                                            //s_idle:等待,0
									 begin
											if(svm_train_enable == 1'b1)
											begin
												  if((numChanged > 0)||(examineall == 1'b1))//(numChanged > 0)||
												  begin
														 i_two <= 0;
														 numChanged <= 0;
														 status <= s_while_ori;//开始循环
												  end
												  else begin
														 //train_start <= 1'b0;
														 status <= s_waiting;//？？
														 //--test_end_sign <= 1'b1;
														 svm_b <= svm_b;
														 ss_out <= {4'd0,iterCounter[11:0],s_out,svm_b[31:0]};
												  end
											end
											else begin
												  status <= s_idle;//？？
											end
									 end
							 s_while_ori://1
									  begin
											 if(i_two <= (sample-1))
											 begin
													 flag_svm <= 1'b0;/////
													 start_svm <= 1'b0;
													 begin_svm <= 1'b0;
												    alpha_rd_ddr <= 53120 + (i_two<<4);     //alpha2,160
												    delay_count <= 0;//--
												    alpha_read_start <= 1'b1;
                                        s_state_reg <= s_s_b;///--s_wr_errorcache;///
                                        status <= s_rd_ddr;													 
											 end
											 else if(i_two >= sample)
											 begin
													 examineall <= 1'b0;
													 iterCounter <= iterCounter + 1;
													 status <= s_idle;//开始下一轮循环
											 end
											 
									  end
							 s_rd_ddr:
							       begin
									     alpha_rd_flag <= alpha_read_end;
										  if(!alpha_rd_flag && alpha_read_end)//上升沿检测
										  begin
												alpha_read_start <= 1'b0;               //read信号
												svc_reg <= alpha_data_in;          //alpha(i2)										
										  end
										  if(alpha_rd_flag && !alpha_read_end)//下降沿检测
										  //-if(alpha_read_end == 1'b0 && alpha_read_start == 1'b0)
										  begin
											   status <= s_state_reg;//--s_waiting;//
										  	   alpha_rd_flag <= 1'b0; 
										  end
									 end
							 s_s_b://2
									 begin
											if(examineall == 1'b1)
											begin
												  start_svm <= 1'b1;
												  status <= s_three;
											end
											else begin
												  if((svc_reg != 0)&&(svc_reg != c))
												  begin
														 start_svm <= 1'b0;
														 begin_svm <= 1'b1;
														 status <= s_three;
												  end
												  else begin
														 start_svm <= 1'b0;
														 begin_svm <= 1'b0;
														 status <= s_three;
												  end
											end
									 
									 end
							 s_three://3
									  begin
											 if((start_svm == 1'b1)||(begin_svm == 1'b1))
											 begin
													y_two <= (i_two <= 39)? 0 : 1;//6个样本<=2,0正1负
													alpha_two <= svc_reg;
													E_two <= 32'd0;
													e_cnt <= 12'd0;
													sum_one <= 32'd0;
													status <= s_four;
											 end
											 else begin
											      y_two <= (i_two <= 39)? 0 : 1;//6个样本<=2,0正1负
													alpha_two <= svc_reg;
													E_two <= 32'd0;
													e_cnt <= 12'd0;
											      sum_one <= 32'd0;
													status <= s_flag;/////问题修改
											 end
									  end
							 s_four://4
									 begin
											if((alpha_two[31] == 0)&&(alpha_two > 0)&&(alpha_two < c))
											begin
												  delay_count <= 0;
												  s_state_reg <= s_r_two;
												  status <= s_rd_ddr;
												  alpha_read_start <= 1'b1;
												  alpha_rd_ddr <= 54400 + (i_two<<4);//200
											end
											else begin
												  if(e_cnt <= (sample-1))
												  begin
													  if(busy_YN == 1'b1)
										           begin
													     start_B <= 1'b1;
														  busy_YN <= 1'b0;
														  s_state_reg <= s_rd_errorcache;//s_four;	
														  if(e_cnt >= i_two)
														  begin
															  B_one <= e_cnt;
															  B_two <= e_cnt + 1;
															  i_or_e <= i_two;
														  end
														  else begin
															  B_one <= i_two;
															  B_two <= i_two + 1;
															  i_or_e <= e_cnt;
														  end
											       end													 
												  end
												  else begin
														 E_two <= (y_two == 0)?(sum_one + svm_b - 32'h00010000):(sum_one + svm_b + 32'h00010000);
														 status <= s_five;//-s_test;//-
														 e_cnt <= 0;
														 r_two <= (y_two == 0)?(sum_one + svm_b - 32'h00010000):(0 - sum_one - svm_b - 32'h00010000);//(~(sum_one) + 1)
												  end
												  busy_sumtwo <= busy_two;
											     if(busy_sumtwo && !busy_two)//下降沿检测
											     begin
													    start_B <= 0;
													    alpha_rd_ddr <= 53120 + (e_cnt<<4);//160
														 address_reg <= 1280 + (data_two<<3) + (i_or_e<<4);//64
													    alpha_read_start <= 1'b1;												 
													    status <= s_rd_ddr;
														 delay_count <= 0;//--
											     end 
											end
									 end
                      s_rd_errorcache:begin
									  s_state_mul <= s_four;
									  A_one <= svc_reg;
									  alpha_rd_ddr <= address_reg;//64
									  alpha_read_start <= 1'b1;	
									  delay_count <= 0;
									  status <= s_rd_mul;
                      end		 
							 s_r_two:begin
							       E_two <= svc_reg;
							       status <= s_five;//-s_test;//-
                            r_two <= (y_two == 0)?(svc_reg):(0 - svc_reg);
                      end	
                      s_rd_mul:
							       begin
									    alpha_rd_flag <= alpha_read_end;
										 if(!alpha_rd_flag && alpha_read_end)//上升沿检测
										 begin
												alpha_read_start <= 1'b0;               //read信号
												A_one <= A_one;
												A_two <= alpha_data_in;
										 end
										 if(alpha_rd_flag && !alpha_read_end)//下降沿检测
										 begin
										    if(A_one == 0 || A_two == 0)
											 begin
										 	    start_A <= 1'b0;
										 	    alpha_rd_flag <= 1'b0;
												 status <= s_state_mul;
												 e_cnt <= e_cnt + 1;
												 busy_YN <= 1'b1;
											 end
											 else begin
											    start_A <= 1'b1;
										 	    alpha_rd_flag <= 1'b0;
												 e_cnt <= e_cnt + 1;
											 end
										 end
										 busy_sumone <= busy_one;
										 if(busy_sumone && !busy_one)//下降沿检测
										 begin
												start_A <= 0;
												busy_YN <= 1'b1;
												sum_one <= ((e_cnt-1) <= 39)?(sum_one + data_one):(sum_one - data_one);//2
												status <= s_state_mul;
                                    alpha_rd_flag <= 1'b0;												
										 end
									 end										 
							 s_five://6
									begin 
										if(((r_two[31] == 1)&&((0 - r_two)> tolerance)&&(alpha_two < c)))
										begin
											i_one <= 12'd0;
											qq <= 12'd0;
											status <= s_nine;
											sum_one <= 32'd0;
										end
										else if(((r_two[31] == 0)&&(r_two > tolerance)&&(alpha_two > 0)))
										begin
										   i_one <= 12'd0;
											qq <= 12'd0;
											status <= s_nine;
											sum_one <= 32'd0;
										end
										else begin
										   sum_one <= 32'd0;
											status <= s_flag;//判断numChanged是否加1
										end
									end
							s_nine://7
									begin
										  if(qq <= (sample - 1)) 
										  begin
												 if(qq == (sample - 1))
												 begin
														i_one <= 0;
														status <= s_ten;
												 end
												 else begin
														i_one <= qq + 1;
														status <= s_ten;
												 end
										  end
										  else begin
										       qq <= 0;///
												 status <= s_flag;//判断numChanged是否加1
										  end
										  
									end
							
							s_ten://8
									begin
										  if(i_one == i_two)
										  begin
												 qq <= qq + 1;
												 flag_svm <= 0;
												 status <= s_nine;
										  end
										  else begin
										       alpha_read_start <= 1'b1;
												 alpha_rd_ddr <= 53120 + (i_one<<4);//alpha_one,160
												 address_reg <= 53120 + (i_two<<4);//160
												 s_state_reg <= s_update_Alpha;
												 //alpha_one <= alpha[i_one];
												 //alpha_two <= alpha[i_two];
												 y_one <= (i_one <= 39)?0:1;//6个样本,2
												 y_two <= (i_two <= 39)?0:1;//6个样本,2
												 E_one <= 32'd0;
												 E_two <= 32'd0;
												 a_one <= 32'd0;
												 a_two <= 32'd0;
												 //s <= ((Y[i_one]+Y[i_two]) == 1)?(1'b1):(1'b0);//6个样本
												 L <= 32'd0;
												 H <= 32'd0;
												 L_H <= 32'd0;
												 a_L <= 32'd0;
												 a_H <= 32'd0;
												 aa_c <= 32'd0;
												 a_a <= 32'd0;
												 a_two_alpha <= 32'd0;
												 sum_one <= 32'd0;
												 sum_two <= 32'd0;
												 sum_three <= 32'd0;
												 status <= s_rd_ddr;//s_twelve;

												 delay_count <= 0;//--
										  end
									end
							s_update_Alpha:begin
										alpha_one <= svc_reg;
										alpha_rd_ddr <= address_reg;//64
										s_state_reg <= s_update_Error;									
									   alpha_read_start <= 1'b1;	
										delay_count <= 0;
										status <= s_rd_ddr;
                     end							
							s_update_Error:
							      begin 											 								
										alpha_two <= svc_reg;	
										s <= ((y_one+y_two) == 1)?(1'b1):(1'b0);
										alpha_rd_ddr <= 54400 + (i_one<<4);//E1,200 
									   delay_count <= 0;//--
										alpha_read_start <= 1'b1;
										s_state_reg <= s_twelve;
										status <= s_rd_ddr;											
									end
							s_twelve://9
									 begin
											if((alpha_one[31] == 0)&&(alpha_one > 0)&&(alpha_one < c))
											begin
												  E_one <= svc_reg;
												  status <= s_E_two;
											end
											else begin
												  if(e_cnt <= (sample-1))
												  begin
												     if(busy_YN == 1'b1)
										           begin
													     start_B <= 1'b1;
														  busy_YN <= 1'b0;
														  s_state_reg <= s_rd_kernum;
														  if(e_cnt >= i_one)
														  begin
																B_one <= e_cnt;
																B_two <= e_cnt + 1;
																i_or_e <= i_one;
														  end
														  else begin
																B_one <= i_one;
																B_two <= i_one + 1;
																i_or_e <= e_cnt;
															end
													  end 
												  end
												  else begin
														 E_one <= (y_one == 0)?(sum_one + svm_b - 32'h00010000):(sum_one + svm_b + 32'h00010000);
														 status <= s_E_two;
														 e_cnt <= 0;
												  end
												  busy_sumtwo <= busy_two;
											     if(busy_sumtwo && !busy_two)//下降沿检测
											     begin
												       delay_count <= 0;//--
													    start_B <= 0;
													    alpha_rd_ddr <= 53120 + (e_cnt<<4);   //alpha(jj),160
													    address_reg <= 1280 + (data_two<<3) + (i_or_e<<4);//kernel(jj,i1),64
													    alpha_read_start <= 1'b1;												 
													    status <= s_rd_ddr;
											     end
											end
									 end
							s_rd_kernum:begin
										A_one <= svc_reg;
										alpha_rd_ddr <= address_reg;									
									   delay_count <= 0;//--
										alpha_read_start <= 1'b1;
										s_state_mul <= s_twelve;
										status <= s_rd_mul;											
							end
							s_E_two:begin
										sum_one <= 0;
										alpha_rd_ddr <= 54400 + (i_two<<4);//E2,200								
										delay_count <= 0;//--
										alpha_read_start <= 1'b1;
										s_state_reg <= s_test;//--s_thirteen;
										status <= s_rd_ddr;										
							end
							s_test:begin
							      if(i_two == 2 && iterCounter == 0)
									begin
									   status <= s_rd_ddr;
										alpha_rd_ddr <= 53136;     //alpha2,160
										alpha_read_start <= 1'b1;
										s_state_reg <= s_waiting;
									   //-status <= s_waiting;//？？
									   //-ss_out <= {eta,b_two,alpha_two,{20'd0,qq}};//-{eta,b_two,t_two,{20'd0,qq}};
									end
								   else begin
									   status <= s_thirteen;
									end
							end
							s_thirteen://11
									 begin
											if((alpha_two[31] == 0)&&(alpha_two > 0)&&(alpha_two < c))
											begin
												  E_two <= svc_reg;//E_two;
												  aa_c <= alpha_one + alpha_two - c;
												  a_a <= alpha_two - alpha_one;
												  status <= s_fourteen;
											end
											else begin
													if(e_cnt <= (sample - 1))
													begin
													  if(busy_YN == 1'b1)
										           begin
														   start_B <= 1'b1;
															busy_YN <= 1'b0;
															s_state_reg <= s_rd_kerdata;
															if(e_cnt >= i_two)
															 begin
																  B_one <= e_cnt;
																  B_two <= e_cnt + 1;
																  i_or_e <= i_two;
															 end
															 else begin
																  B_one <= i_two;
																  B_two <= i_two + 1;
																  i_or_e <= e_cnt;
															 end
														    
											        end														  
													end
													else begin
														  E_two <= (y_two == 0)?(sum_one + svm_b - 32'h00010000):(sum_one + svm_b + 32'h00010000);
														  aa_c <= alpha_one + alpha_two - c;
														  a_a <= alpha_two - alpha_one;
														  status <= s_fourteen;
														  e_cnt <= 0;
													end
													busy_sumtwo <= busy_two;
											      if(busy_sumtwo && !busy_two)//下降沿检测
											      begin
													    delay_count <= 0;//--
													    start_B <= 0;
													    alpha_rd_ddr <= 53120 + (e_cnt<<4);       //alpha(ss),160
													    address_reg <= 1280 + (data_two<<3) + (i_or_e<<4);//kernel(ss,i2),64
													    alpha_read_start <= 1'b1;												 
													    status <= s_rd_ddr;
											      end
											end
									 end
							s_rd_kerdata:begin
							       A_one <= svc_reg;////////-------//////////-------///////////
									 alpha_rd_ddr <= address_reg;
									 delay_count <= 0;//--
									 alpha_read_start <= 1'b1;
									 s_state_mul <= s_thirteen;
									 status <= s_rd_mul;										
							end
							
							s_fourteen://13
									 begin
											if(y_one == y_two)
											begin
											     sum_one <= 0;
												  if((aa_c[31] == 0)&&(aa_c > 0))
												  begin
														 L <= aa_c;
														 H <= c;
														 L_H <= aa_c - c;
														 status <= s_fifteen;
												  end
												  else begin
														 L <= 0;
														 H <= aa_c + c;
														 L_H <= 0 - aa_c - c;
														 status <= s_fifteen;
												  end
											end
											else if(y_one != y_two)
											begin
											     sum_one <= 0;
												  if((a_a[31] == 0)&&(a_a > 0))
												  begin
														 L <= a_a;
														 H <= c;
														 L_H <= a_a - c;
														 status <= s_fifteen;
												  end
												  else begin
														 L <= 0;
														 H <= c + a_a;
														 L_H <= 0 - c - a_a;
														 status <= s_fifteen;
												  end
											end
									 end
							s_fifteen://14
									 begin							   
											if(L_H[31] == 0)
											begin
												  qq <= qq + 1;
												  flag_svm <= 0;
												  status <= s_nine;
											end
											else begin   
												if(busy_YN == 1'b1)
										      begin
												  start_B <= 1'b1;
												  busy_YN <= 1'b0;
												  if(i_one >= i_two)
												  begin
                                         B_one <= i_one;
													  B_two <= i_one + 1;
													  i_or_e <= i_two;
                                      end
                                      else begin
                                         B_one <= i_two;
													  B_two <= i_two + 1;
													  i_or_e <= i_one;
                                      end	
                                    end
                                    s_state_reg <= s_rd_kernel;												
												busy_sumtwo <= busy_two;
											   if(busy_sumtwo && !busy_two)//下降沿检测
											   begin
												     start_B <= 0;
												     alpha_read_start <= 1'b1;
												     alpha_rd_ddr <= 1280+(data_two<<3)+(i_or_e<<4);//kernel(i1,i2),64
												     status <= s_rd_ddr;
											   end
											end
									 end							
							s_rd_kernel: 
							       begin
									     busy_YN <= 1'b1;
										  status <= s_eta;
										  k_one_one <= 32'h00010000;          //k11
										  k_two_two <= 32'h00010000;//errorcache_two_in;//k22
										  sub_e <= E_one - E_two;
										  k_one_two <= svc_reg;          //k12
										  KK_tri <= 32'h00020000 - (svc_reg<<1);//i_one*sample + i_two
										  eta <= 32'h00020000 - (svc_reg<<1);//i_one*sample + i_two										  
									 end
							s_eta://15
									begin
										if(KK_tri == 0)
										begin
											  status <= s_eta_end;  
										end
										else if(KK_tri != 0 && sub_e == 0)
										begin
										     status <= s_eta_end;
											  a_two <= alpha_two;
											  a_L <= alpha_two - L;
											  a_H <= alpha_two - H;
										end
										else if(KK_tri != 0 && sub_e != 0)
										begin
										  if((sub_e[31] == 1)&&(KK_tri[31] == 1))
										  begin
												 sub_ee <= 0 - sub_e;
												 KK_train <= 0 - KK_tri;
												 div_sign <= 1'b1;
										  end
										  else if((sub_e[31] == 1)&&(KK_tri[31] == 0))
										  begin
												 sub_ee <= 0 - sub_e;
												 KK_train <= KK_tri;
												 div_sign <= 1'b1;
										  end
										  else if((sub_e[31] == 0)&&(KK_tri[31] == 1))
										  begin
												 sub_ee <= sub_e;
												 KK_train <= 0 - KK_tri;
												 div_sign <= 1'b1;
										  end
										  else if((sub_e[31] == 0)&&(KK_tri[31] == 0))
										  begin
												 sub_ee <= sub_e;
												 KK_train <= KK_tri;
												 div_sign <= 1'b1;
										  end
										  busy_a_two <= div_busy;
										  if(busy_a_two && !div_busy)//下降沿检测
										  begin
												 if(((sub_e[31]) ^ (KK_tri[31])) == 1)
												 begin
														a_two <= (y_two == 0)?(alpha_two - div_out):(alpha_two + div_out);
														a_L <= (y_two == 0)?(alpha_two - div_out - L):(alpha_two + div_out - L);
														a_H <= (y_two == 0)?(alpha_two - div_out - H):(alpha_two + div_out - H);
														div_sign <= 0;
														status <= s_eta_end;
												 end
												 else if(((sub_e[31]) ^ (KK_tri[31])) == 0)
												 begin
														a_two <= (y_two == 0)?(alpha_two + div_out):(alpha_two - div_out);
														a_L <= (y_two == 0)?(alpha_two + div_out - L):(alpha_two - div_out - L);
														a_H <= (y_two == 0)?(alpha_two + div_out - H):(alpha_two - div_out - H);
														div_sign <= 0;
														status <= s_eta_end;
												 end
										  end
										end
									end						
							s_eta_end://16
									begin
										  if((eta[31] == 0)&&(eta > 0))
										  begin
												 if((a_L[31] == 0)&&((a_H == 0)||(a_H[31] == 1)))
												 begin
														a_two <= a_two;
														a_two_alpha <= a_two - alpha_two;
														status <= s_sixteen;
												 end
												 else if(a_L[31] == 1)
												 begin
														a_two <= L;
														a_two_alpha <= L - alpha_two;
														status <= s_sixteen;
												 end
												 else if((a_H[31] == 0)&&(a_H > 0))
												 begin
														a_two <= H;
														a_two_alpha <= H - alpha_two;
														status <= s_sixteen;
												 end
										  end
										  else begin
												 a_two <= alpha_two;
												 a_two_alpha <= alpha_two - alpha_two;////a_two
												 status <= s_sixteen;
										  end
									end									
							s_sixteen://17
									begin
										  if((a_two_alpha[31] == 0)&&(a_two_alpha < ((a_two+alpha_two+eps)>>9)))//<=
										  begin
												 qq <= qq + 1;
												 flag_svm <= 0;
												 status <= s_nine;
										  end
										  else if((a_two_alpha[31] == 1)&&((0 - a_two_alpha) < ((a_two+alpha_two+eps)>>9))) //<=
										  begin
												 qq <= qq + 1;
												 flag_svm <= 0;
												 status <= s_nine;
										  end
										  else begin
												 a_one <= (s == 0)?(alpha_one - a_two_alpha):(alpha_one + a_two_alpha);
												 status <= s_update;
										  end
									end
							s_update://18
									begin
											if(a_one[31] == 1)
											begin
												  a_two <= (s == 0)?(a_two + a_one):(a_two - a_one);
												  a_one <= 0;
												  status <= s_bnew;
											end
											else if((a_one[31] == 0)&&(a_one > c))
											begin
												  a_two <= (s == 0)?(a_two + a_one - c):(a_two + c - a_one);
												  a_one <= c;
												  status <= s_bnew;
											end
											else begin
												  a_one <= a_one;
												  status <= s_bnew;
											end
									end
							s_bnew://19
									begin
									  if(busy_YN == 1'b1)
									  begin
										  A_one <= (y_two == 0)?(a_two - alpha_two):(alpha_two - a_two);
										  A_two <= k_one_two;
										  start_A <= 1'b1;
										  busy_YN <= 1'b0;
									  end
									  busy_bone <= busy_one;
									  if(busy_bone && !busy_one)//下降沿检测
									  begin
										  b_one <= (y_one == 0)?(alpha_one - a_one - data_one):(a_one - alpha_one - data_one);
										  start_A <= 0;
										  status <= s_b_one;
									  end	
									end
							s_b_one://20
									begin
									     busy_YN <= 1'b1;
										  status <= s_b_two;
										  b_one <= svm_b - E_one + b_one;
									end
							s_b_two://21
									begin
									  if(busy_YN == 1'b1)
									  begin
										  A_one <= (y_one == 0)?(a_one - alpha_one):(alpha_one - a_one);
										  A_two <= k_one_two;
										  start_A <= 1'b1;
										  busy_YN <= 1'b0;
									  end	  
									  bNew <= 32'b0;
									  deltaB <= 32'b0;
									  b_add_b <= 32'b0;
									  busy_bone <= busy_one;
									  if(busy_bone && !busy_one)//下降沿检测
									  begin
										  b_two <= (y_two == 0)?(svm_b - E_two - data_one - a_two + alpha_two):(svm_b - E_two - data_one + a_two - alpha_two);
										  start_A <= 0;
										  status <= s_bot;
									  end
									end
							
							s_bot://23
									begin
									     busy_YN <= 1'b1;
										  b_add_b <= b_one + b_two;
										  status <= s_deltaB;
										  t_one <= (y_one == 0)?(a_one - alpha_one):(alpha_one - a_one);
										  t_two <= (y_two == 0)?(a_two - alpha_two):(alpha_two - a_two);
									end
							s_deltaB://24
									begin
										  if((a_one[31] == 0)&&(a_one > 0) && (a_one < c))
										  begin
												 bNew <= b_one;
												 deltaB <= b_one - svm_b;
												 svm_b <= b_one;
												 status <= s_error;
										  end
										  else if((a_two[31] == 0)&&(a_two > 0)&&(a_two < c))
										  begin
												 bNew <= b_two;
												 deltaB <= b_two - svm_b;
												 svm_b <= b_two;
												 status <= s_error;
										  end
										  else begin
												 bNew <= (b_add_b[31] == 0)?(b_add_b>>1):((b_add_b>>1) + 32'h80000000);
												 deltaB <= (b_add_b[31] == 0)?((b_add_b>>1)-svm_b):((b_add_b>>1) + 32'h80000000 - svm_b);
												 svm_b <= (b_add_b[31] == 0)?(b_add_b>>1):((b_add_b>>1) + 32'h80000000);
												 status <= s_error;
										  end
									end
							s_error://25
									begin
										  if(error_cnt <= (sample-1))
										  begin
												 alpha_rd_ddr <= 53120 + (error_cnt<<4);//alpha(i),160
											    delay_count <= 0;//--
										       s_state_reg <= s_rd_Errordata;
												 alpha_read_start <= 1'b1;
												 status <= s_rd_ddr;
										  end
										  else begin
												 error_cnt <= 0;
												 status <= s_wr_alpha; 
										  end
									end
							s_rd_Errordata:begin
										alpha_er <= svc_reg;
										alpha_rd_ddr <= 54400 + (error_cnt<<4);//errorcache(i),200
										delay_count <= 0;//--
										s_state_reg <= s_rd_ker;
										alpha_read_start <= 1'b1;
										status <= s_rd_ddr;
							end
							s_rd_ker:
							      begin
									    if((alpha_er[31] == 0)&&(alpha_er > 0)&&(alpha_er < c))
										 begin
										    if(busy_YN == 1'b1)
										    begin
											    start_B <= 1'b1;
												 busy_YN <= 1'b0;
												 if(i_one >= error_cnt)
												 begin
													 B_one <= i_one;
													 B_two <= i_one + 1;
													 i_or_e <= error_cnt;
												 end
												 else begin
													 B_one <= error_cnt;
													 B_two <= error_cnt + 1;
													 i_or_e <= i_one;
												 end
										    end
											 alpha_wr_data <= svc_reg;
											 busy_btwo <= busy_two;
										    if(busy_btwo && !busy_two)//下降沿检测
										    begin
											    start_B <= 0;
												 busy_YN <= 1'b1;
												 alpha_rd_ddr <= 1280 + (data_two<<3)+(i_or_e<<4);//64
											    status <= s_rd_kerone;//--s_rd_kertwo;
											 end
									    end
										 else begin
											 status <= s_wr_errorcache;
											 alpha_wr_data <= svc_reg;
										 end
									end
							s_rd_kerone:begin
										alpha_rd_ddr <= alpha_rd_ddr;
										delay_count <= 0;//--
										s_state_reg <= s_rd_kertwo;
										alpha_read_start <= 1'b1;
										status <= s_rd_ddr;
							end
							s_rd_kertwo:
							      begin
									    if(busy_YN == 1'b1)
										 begin
										    start_C <= 1'b1;
											 busy_YN <= 1'b0;
											 if(i_two >= error_cnt)
											 begin
												 C_one <= i_two;
												 C_two <= i_two + 1;
												 i_or_e <= error_cnt;											 
											 end
											 else begin
												 C_one <= error_cnt;
												 C_two <= error_cnt + 1;
												 i_or_e <= i_two;
											 end
										 end
										 A_one <= svc_reg;
										 busy_bthree <= busy_three;
										 if(busy_bthree && !busy_three)//下降沿检测
										 begin
											 start_C <= 0;
											 busy_YN <= 1'b1;
											 alpha_rd_ddr <= 1280 + (data_three<<3)+(i_or_e<<4);//kernel(i2,i),64									 
											 alpha_read_start <= 1'b1;
											 status <= s_rd_ddr;
											 s_state_reg <= s_error_one;
										 end
									end
							s_error_one://26
									begin
									   if(busy_YN == 1'b1)
										begin
									     start_A <= 1'b1;
										  A_one <= A_one;
										  A_two <= t_one;
										  busy_YN <= 1'b0;
										end
										busy_TK_one <= busy_one;
										if(busy_TK_one && !busy_one)//下降沿检测
										begin
										   start_A <= 0;
										   status <= s_error_onend;
											alpha_wr_data <= alpha_wr_data + data_one;
		 						      end
									end
							s_error_onend:
							      begin
									     A_one <= svc_reg;
									     busy_YN <= 1'b1;
									     status <= s_add_error;
										  alpha_wr_data <= alpha_wr_data - deltaB;
									end
							s_add_error:
							      begin
									  if(busy_YN == 1'b1)
									  begin
									    start_A <= 1'b1;
										 A_one <= A_one;
										 A_two <= t_two;
										 busy_YN <= 1'b0;
									  end
										 busy_TK_one <= busy_one;
										 if(busy_TK_one && !busy_one)//下降沿检测
										 begin
												start_A <= 0;
												status <= s_wr_errorcache;
												alpha_wr_data <= alpha_wr_data + data_one;
												busy_YN <= 1'b1;
										 end
									end
							s_wr_errorcache:
							      begin
									   if((error_cnt == i_one) || (error_cnt == i_two))
										begin
										   alpha_wr_data <= 32'd0;//32'hAAFFBBDD;//--
											alpha_wr_ddr <= 54652 + (error_cnt<<4);
											alpha_wr_start <= 1'b1;
											status <= s_wr_ddr;
											s_state_reg <= s_error;//s_rd_ddr;//--
										end
										else begin
										   alpha_wr_data <= alpha_wr_data;//32'hAAFFBBDD;//--
											alpha_wr_ddr <= 54652 + (error_cnt<<4);
											alpha_wr_start <= 1'b1;
											status <= s_wr_ddr;
											s_state_reg <= s_error;//s_rd_ddr;//--
										end
									end
							s_wr_ddr:
							      begin
									   alpha_wr_flag <= alpha_wr_end;
										if(!alpha_wr_flag && alpha_wr_end)//上升沿检测
										begin
										   alpha_wr_start <= 1'b0;
											error_cnt <= error_cnt + 1;
										end
										if(alpha_wr_flag && !alpha_wr_end)//下降沿检测
										//-if(alpha_wr_end == 1'b0 && alpha_wr_start == 1'b0)
										begin
										   status <= s_state_reg;
											alpha_wr_flag <= 1'b0;
											//test_ddr <= 1'b1;//--
											//alpha_read_start <= 1'b1;//--
											//alpha_rd_ddr <= alpha_wr_ddr;										
											//status <= s_state_reg;//--
										end
										/*if(test_ddr == 1 && delay_count <= 5)
										begin
										   delay_count <= delay_count + 1;
										end
										else if(delay_count > 5)
										begin
										   alpha_read_start <= 1'b1;//--
											alpha_rd_ddr <= 200;//alpha_wr_ddr;										
											status <= s_state_reg;//--
											delay_count <= 0;//--
										end*/
									end
							s_wr_alpha:
                           begin
										alpha_wr_ddr <= 53372 + (i_one<<4);//160
										delay_count <= 0;//--
									   alpha_wr_start <= 1'b1;
                              alpha_wr_data <= a_one;
										status <= s_wr_ddr;
									   s_state_reg <= s_wr_alphatwo;
										s_out[i_one] <= a_one[17]^a_one[16];
                           end
                     s_wr_alphatwo:begin
									   alpha_wr_ddr <= 53372 + (i_two<<4);//160
										delay_count <= 0;//--
									   alpha_wr_start <= 1'b1;
										alpha_wr_data <= a_two;
										status <= s_wr_ddr;
										s_state_reg <= s_error_two;//-s_test;//-
										s_out[i_two] <= a_two[17]^a_two[16];
                     end
                     /*s_test:begin
							      if(i_two == 2 && iterCounter == 0)
									begin
									   status <= s_rd_ddr;
										alpha_rd_ddr <= 53152;     //alpha2,160
										alpha_read_start <= 1'b1;
										s_state_reg <= s_waiting;
									   //-status <= s_waiting;//？？
									   //-ss_out <= {eta,b_two,alpha_two,{20'd0,qq}};//-{eta,b_two,t_two,{20'd0,qq}};
									end
								   else begin
									   status <= s_error_two;
									end
							end*/				
							s_error_two://27
									begin	
										alpha_read_start <= 0;
										alpha_wr_start <= 0;										
									   error_cnt <= 0;
										status <= s_finish;
										delay_count <= 0;
									end						
							s_finish://29
									begin
										flag_svm <= 1'b1;
										qq <= sample;
										status <= s_flag;
									end					
							s_flag://30
									 begin
											if(flag_svm == 1'b0)
											begin
												  i_two <= i_two + 1;
												  status <= s_while_ori;
											end
											else begin
												  numChanged <= numChanged + 1;
												  i_two <= i_two + 1;
												  status <= s_while_ori;
											end
									 end
							 
							 default:  
										 begin  
											  status <= s_idle;  
										 end  
							 endcase
			 end
		end

endmodule