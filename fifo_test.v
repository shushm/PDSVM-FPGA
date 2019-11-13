`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:47:27 10/28/2017 
// Design Name: 
// Module Name:    fifo_test 
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
module fifo_test(

         input wr_clk,	//PLL输出12.5MHz时钟
		   input rd_clk,	//PLL输出50MHz时钟
			input rst_n,	//复位信号，低电平有效
         output clk_50,         
			
			output fifo_full,		//FIFO满标志位
			output fifo_empty,		//FIFO空标志位
			output reg fifo_rdrdy,		//FIFO读数据有效信号
			output [7:0] fifo_rddb,	//FIFO读出数据总线
			
			output reg port2_tst_sign, //==
			output reg [31:0] tst_data,//==
			output reg [31:0] sample_addr,//5120
			output reg [31:0] sample_alpha,//56960
			output reg [31:0] sample_kernel,//3239
			output reg [31:0] sample_dim,//80,4
			input  train_end_sign,
			//input fifo_rd,
			output reg ddr_end,
			
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
	input feature_full_falg,          //input
	
	output reg [31:0] data_rd_x,       //output ddr-->kernel
	output reg [31:0] data_rd_y,       //
	output reg [31:0] data_rd_z,       //
	output reg [31:0] data_rd_w,       //
	output reg [31:0] data_rd_a,       //
	
	output reg ker_cal_sign,          //output calculate start sign
   
	///////////////////////////////////////////////svm_train
	input             alpha_read_start,
	input             alpha_pard_start,
	input  [29:0]     alpha_rd_ddr,
	input  [29:0]     alpha_rdZ_ddr,
	input  [29:0]     alpha_rdN_ddr,
	input  [29:0]     alpha_rdT_ddr,
	input  [29:0]     alpha_rdH_ddr,
	
	output reg        alpha_read_end,
	output reg [31:0] alpha_two_out,
   input             alpha_wr_start,
   input  [31:0]     alpha_wr_data,
   input  [29:0]     alpha_wr_ddr,       
   output reg        alpha_wr_end,
	output reg        ddr_orgin_end,
	
	//////////////////////////////////////////////svm_forest
	input             tst_rd_sign,                //input
	input  [15:0]     ddr_tst_num,                //input reg [15:0] 
	input  [15:0]     ddr_ker_num,                //input reg [15:0] 
	input  [15:0]     ddr_alpha_num,              //input reg [15:0] 
	output reg        ker_rd_end,                 //output
	
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
	output reg                         off_on_sign,///.
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
		////////////////////////////////////port 2-3
		wire		c3_p2_cmd_clk;	//connect to user clock
      reg		c3_p2_cmd_en;
      reg [2:0]	c3_p2_cmd_instr;
      reg [5:0]	c3_p2_cmd_bl;
      reg [29:0]	c3_p2_cmd_byte_addr;
      wire		c3_p2_cmd_empty;
      wire		c3_p2_cmd_full;
		//--write block
      wire		c3_p2_wr_clk;	//connect to user clock
      reg		c3_p2_wr_en;
      reg [3:0]	c3_p2_wr_mask;//15
      reg [31:0]	c3_p2_wr_data;
      wire		c3_p2_wr_full;
      wire		c3_p2_wr_empty;
      wire [6:0]	c3_p2_wr_count;
      wire		c3_p2_wr_underrun;
      wire		c3_p2_wr_error;
		//--read block
      wire		c3_p2_rd_clk;	//connect to user clock
      reg		c3_p2_rd_en;
      wire  [31:0]	c3_p2_rd_data;
      wire		c3_p2_rd_full;
      wire		c3_p2_rd_empty;
      wire [6:0]	c3_p2_rd_count;
      wire		c3_p2_rd_overflow;
      wire		c3_p2_rd_error;
		//////////////////////////////////////////
		////////////////////////////////////port 2-3
		wire		c3_p3_cmd_clk;	//connect to user clock
      reg		c3_p3_cmd_en;
      reg [2:0]	c3_p3_cmd_instr;
      reg [5:0]	c3_p3_cmd_bl;
      reg [29:0]	c3_p3_cmd_byte_addr;
      wire		c3_p3_cmd_empty;
      wire		c3_p3_cmd_full;
		//--write block
      wire		c3_p3_wr_clk;	//connect to user clock
      reg		c3_p3_wr_en;
      reg [3:0]	c3_p3_wr_mask;//15
      reg [31:0]	c3_p3_wr_data;
      wire		c3_p3_wr_full;
      wire		c3_p3_wr_empty;
      wire [6:0]	c3_p3_wr_count;
      wire		c3_p3_wr_underrun;
      wire		c3_p3_wr_error;
		//--read block
      wire		c3_p3_rd_clk;	//connect to user clock
      reg		c3_p3_rd_en;
      wire  [31:0]	c3_p3_rd_data;
      wire		c3_p3_rd_full;
      wire		c3_p3_rd_empty;
      wire [6:0]	c3_p3_rd_count;
      wire		c3_p3_rd_overflow;
      wire		c3_p3_rd_error;
		//////////////////////////////////////////
		
		
      assign c3_sys_rst_i = ~rst_n;	//ddr2 ip,high reset;~rst_n
      assign calib_done = c3_calib_done;//if c3_calib_done=1,indicates the completion of all phases of cablibration

parameter C3_RST_ACT_LOW = 0;
//--------------------- Module instante-------------------
ddr3_test # (
    .C3_P0_MASK_SIZE(4),
    .C3_P0_DATA_PORT_SIZE(32),
    .C3_P1_MASK_SIZE(4),
    .C3_P1_DATA_PORT_SIZE(32),
    .DEBUG_EN(0),
    .C3_MEMCLK_PERIOD(3200),
    .C3_CALIB_SOFT_IP("TRUE"),
    .C3_SIMULATION("FALSE"),
    .C3_RST_ACT_LOW(0),
    .C3_INPUT_CLK_TYPE("SINGLE_ENDED"),
    .C3_MEM_ADDR_ORDER("ROW_BANK_COLUMN"),
    .C3_NUM_DQ_PINS(16),
    .C3_MEM_ADDR_WIDTH(14),
    .C3_MEM_BANKADDR_WIDTH(3)
)
u_ddr3_test (

  .c3_sys_clk             (rd_clk),
  .c3_sys_rst_i           (c3_sys_rst_i),                        

  .mcb3_dram_dq           (mcb3_dram_dq),  
  .mcb3_dram_a            (mcb3_dram_a),  
  .mcb3_dram_ba           (mcb3_dram_ba),
  .mcb3_dram_ras_n        (mcb3_dram_ras_n),                        
  .mcb3_dram_cas_n        (mcb3_dram_cas_n),                        
  .mcb3_dram_we_n         (mcb3_dram_we_n),                          
  .mcb3_dram_odt          (mcb3_dram_odt),
  .mcb3_dram_cke          (mcb3_dram_cke),                          
  .mcb3_dram_ck           (mcb3_dram_ck),                          
  .mcb3_dram_ck_n         (mcb3_dram_ck_n),       
  .mcb3_dram_dqs          (mcb3_dram_dqs),                          
  .mcb3_dram_dqs_n        (mcb3_dram_dqs_n),
  .mcb3_dram_udqs         (mcb3_dram_udqs),    // for X16 parts                        
  .mcb3_dram_udqs_n       (mcb3_dram_udqs_n),  // for X16 parts
  .mcb3_dram_udm          (mcb3_dram_udm),     // for X16 parts
  .mcb3_dram_dm           (mcb3_dram_dm),
  .mcb3_dram_reset_n      (mcb3_dram_reset_n),
  .c3_clk0		           (c3_clk0),
  .c3_rst0		           (c3_rst0),
	
  .c3_calib_done          (c3_calib_done),
  .mcb3_rzq               (mcb3_rzq),            
  .mcb3_zio               (mcb3_zio),
	
   .c3_p0_cmd_clk                          (c3_p0_cmd_clk),
   .c3_p0_cmd_en                           (c3_p0_cmd_en),
   .c3_p0_cmd_instr                        (c3_p0_cmd_instr),
   .c3_p0_cmd_bl                           (c3_p0_cmd_bl),
   .c3_p0_cmd_byte_addr                    (c3_p0_cmd_byte_addr),
   .c3_p0_cmd_empty                        (c3_p0_cmd_empty),
   .c3_p0_cmd_full                         (c3_p0_cmd_full),
   .c3_p0_wr_clk                           (c3_p0_wr_clk),
   .c3_p0_wr_en                            (c3_p0_wr_en),
   .c3_p0_wr_mask                          (c3_p0_wr_mask),
   .c3_p0_wr_data                          (c3_p0_wr_data),
   .c3_p0_wr_full                          (c3_p0_wr_full),
   .c3_p0_wr_empty                         (c3_p0_wr_empty),
   .c3_p0_wr_count                         (c3_p0_wr_count),
   .c3_p0_wr_underrun                      (c3_p0_wr_underrun),
   .c3_p0_wr_error                         (c3_p0_wr_error),
   .c3_p0_rd_clk                           (c3_p0_rd_clk),
   .c3_p0_rd_en                            (c3_p0_rd_en),
   .c3_p0_rd_data                          (c3_p0_rd_data),
   .c3_p0_rd_full                          (c3_p0_rd_full),
   .c3_p0_rd_empty                         (c3_p0_rd_empty),
   .c3_p0_rd_count                         (c3_p0_rd_count),
   .c3_p0_rd_overflow                      (c3_p0_rd_overflow),
   .c3_p0_rd_error                         (c3_p0_rd_error),
   .c3_p1_cmd_clk                          (c3_p1_cmd_clk),
   .c3_p1_cmd_en                           (c3_p1_cmd_en),
   .c3_p1_cmd_instr                        (c3_p1_cmd_instr),
   .c3_p1_cmd_bl                           (c3_p1_cmd_bl),
   .c3_p1_cmd_byte_addr                    (c3_p1_cmd_byte_addr),
   .c3_p1_cmd_empty                        (c3_p1_cmd_empty),
   .c3_p1_cmd_full                         (c3_p1_cmd_full),
   .c3_p1_wr_clk                           (c3_p1_wr_clk),
   .c3_p1_wr_en                            (c3_p1_wr_en),
   .c3_p1_wr_mask                          (c3_p1_wr_mask),
   .c3_p1_wr_data                          (c3_p1_wr_data),
   .c3_p1_wr_full                          (c3_p1_wr_full),
   .c3_p1_wr_empty                         (c3_p1_wr_empty),
   .c3_p1_wr_count                         (c3_p1_wr_count),
   .c3_p1_wr_underrun                      (c3_p1_wr_underrun),
   .c3_p1_wr_error                         (c3_p1_wr_error),
   .c3_p1_rd_clk                           (c3_p1_rd_clk),
   .c3_p1_rd_en                            (c3_p1_rd_en),
   .c3_p1_rd_data                          (c3_p1_rd_data),
   .c3_p1_rd_full                          (c3_p1_rd_full),
   .c3_p1_rd_empty                         (c3_p1_rd_empty),
   .c3_p1_rd_count                         (c3_p1_rd_count),
   .c3_p1_rd_overflow                      (c3_p1_rd_overflow),
   .c3_p1_rd_error                         (c3_p1_rd_error),
   .c3_p2_cmd_clk                          (c3_p2_cmd_clk),
   .c3_p2_cmd_en                           (c3_p2_cmd_en),
   .c3_p2_cmd_instr                        (c3_p2_cmd_instr),
   .c3_p2_cmd_bl                           (c3_p2_cmd_bl),
   .c3_p2_cmd_byte_addr                    (c3_p2_cmd_byte_addr),
   .c3_p2_cmd_empty                        (c3_p2_cmd_empty),
   .c3_p2_cmd_full                         (c3_p2_cmd_full),
   .c3_p2_wr_clk                           (c3_p2_wr_clk),
   .c3_p2_wr_en                            (c3_p2_wr_en),
   .c3_p2_wr_mask                          (c3_p2_wr_mask),
   .c3_p2_wr_data                          (c3_p2_wr_data),
   .c3_p2_wr_full                          (c3_p2_wr_full),
   .c3_p2_wr_empty                         (c3_p2_wr_empty),
   .c3_p2_wr_count                         (c3_p2_wr_count),
   .c3_p2_wr_underrun                      (c3_p2_wr_underrun),
   .c3_p2_wr_error                         (c3_p2_wr_error),
   .c3_p2_rd_clk                           (c3_p2_rd_clk),
   .c3_p2_rd_en                            (c3_p2_rd_en),
   .c3_p2_rd_data                          (c3_p2_rd_data),
   .c3_p2_rd_full                          (c3_p2_rd_full),
   .c3_p2_rd_empty                         (c3_p2_rd_empty),
   .c3_p2_rd_count                         (c3_p2_rd_count),
   .c3_p2_rd_overflow                      (c3_p2_rd_overflow),
   .c3_p2_rd_error                         (c3_p2_rd_error),
   .c3_p3_cmd_clk                          (c3_p3_cmd_clk),
   .c3_p3_cmd_en                           (c3_p3_cmd_en),
   .c3_p3_cmd_instr                        (c3_p3_cmd_instr),
   .c3_p3_cmd_bl                           (c3_p3_cmd_bl),
   .c3_p3_cmd_byte_addr                    (c3_p3_cmd_byte_addr),
   .c3_p3_cmd_empty                        (c3_p3_cmd_empty),
   .c3_p3_cmd_full                         (c3_p3_cmd_full),
   .c3_p3_wr_clk                           (c3_p3_wr_clk),
   .c3_p3_wr_en                            (c3_p3_wr_en),
   .c3_p3_wr_mask                          (c3_p3_wr_mask),
   .c3_p3_wr_data                          (c3_p3_wr_data),
   .c3_p3_wr_full                          (c3_p3_wr_full),
   .c3_p3_wr_empty                         (c3_p3_wr_empty),
   .c3_p3_wr_count                         (c3_p3_wr_count),
   .c3_p3_wr_underrun                      (c3_p3_wr_underrun),
   .c3_p3_wr_error                         (c3_p3_wr_error),
   .c3_p3_rd_clk                           (c3_p3_rd_clk),
   .c3_p3_rd_en                            (c3_p3_rd_en),
   .c3_p3_rd_data                          (c3_p3_rd_data),
   .c3_p3_rd_full                          (c3_p3_rd_full),
   .c3_p3_rd_empty                         (c3_p3_rd_empty),
   .c3_p3_rd_count                         (c3_p3_rd_count),
   .c3_p3_rd_overflow                      (c3_p3_rd_overflow),
   .c3_p3_rd_error                         (c3_p3_rd_error)
);

      wire		user_clk;
		wire		state_rst;
		reg [29:0] ddr_address;
		//==reg [29:0] ddr_tst_address;
		reg [29:0] port1_ddr_address;///.
      reg [29:0] alpha_address;	
		//==reg [29:0] errorcache_address;
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
		reg [11:0] port1_cnt;

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
		
		parameter   port2_WAITING =       9'b100110000;//==
		parameter   port2_IDLE =          9'b100110001;//==
		parameter	port2_PARRDDATA =     9'b100110010;//==
		parameter	port2_PARRDCMD =      9'b100110011;//==
		parameter	port2_PARRDCMDDONE =  9'b100110100;//==
		parameter	port2_PARRDEND  =     9'b100110101;//==
		
		parameter	port2_READIDLE  =     9'b100110110;//==
		parameter	port2_READCMD  =      9'b100110111;//==
		parameter	port2_READDATA  =     9'b100111000;//==
		parameter	port2_READDONE  =     9'b100111001;//==
		parameter	port2_READCMDDONE =   9'b100111010;//==
		
		/////////////////////////////////////////////sample-->kernel
		reg [29:0]   kernel_i;
		reg [29:0]   kernel_j;
		reg [11:0]   ij_cnt;
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
	pll instance_name
   (// Clock in ports
    .CLK_IN1(c3_clk0),      // IN
    // Clock out ports
    .CLK_OUT1(clk_12m5),     // OUT
    .CLK_OUT2(clk_25m),     // OUT
    .CLK_OUT3(clk_50m),     // OUT
    .CLK_OUT4(clk_65m),     // OUT
	.CLK_OUT5(clk_108m),     // OUT
	.CLK_OUT6(clk_130m),     // OUT
    // Status and control signals
    .RESET(c3_rst0),// IN
    .LOCKED(sys_rst_n)
	 );      // OUT	

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
//==reg ddr_end;
reg ddr_tst_end;
reg fill_edge_down;
wire fill_tst_flag;
wire ddr_tst_flag;
assign fill_tst_flag = fill_edge_down;
assign ddr_tst_flag = ddr_tst_end;

wire fill_finish_flag;
wire ddr_end_flag;
assign ddr_end_flag = ddr_end;
assign fill_finish_flag = fill_finish;
reg [11:0] test_end_cnt;

reg [7:0] kernel_cnt;
//wire svm_kernel_sign;
//assign svm_kernel_sign = square_sign;
reg [31:0] c3_rd_data [4:0];
reg [29:0] c3_rd_addr [4:0];
reg [31:0] data_rd_out [4:0];

wire svm_kernel_sign;
reg ker_wr_sign;///.
reg ker_wr_flag;
reg kernel_sign_reg;
reg port2_read_done;//--
reg [7:0] mul_cnt;
reg [15:0] sp_num;
reg [15:0] sp_dim;
reg feature_flag;//==//
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
			//==ddr_tst_address <= 57244;
			c3_p0_wr_en	<= 0;
			c3_p0_wr_mask <= 0;
			c3_p0_wr_data <= 0;
			c3_p0_rd_en <= 0;
			ddr2_test_true <= 0;//0
			number <= 32'd0;//32'd0;
			read_sign <= 1'b0;
			state_next <= WAITCALIBDONE;
			
			kernel_i <= 30'd0;//5
			kernel_j <= 30'd0;//5
			svm_ker_flag <= 1'b0;
			ker_wr_sign <= 1'b0;///.
			ker_wr_flag <= 1'b0;
			port1_ddr_address <= 0;//==30'd5356;//148,1516
			port1_read_done <= 1'b0;	
			
			//-c3_rd2_data <= 32'd0;
			c3_p1_cmd_en <= 0;
			c3_p1_cmd_instr <= 0;
			c3_p1_cmd_bl <= 0;
			c3_p1_cmd_byte_addr <= 0;
			c3_p1_wr_en	<= 0;
			c3_p1_wr_mask <= 0;
			c3_p1_wr_data <= 0;
			c3_p1_rd_en <= 0;
			c3_p2_cmd_instr <= 0;
			c3_p2_cmd_bl <= 0;
			c3_p2_cmd_byte_addr <= 0;
			c3_p2_wr_en	<= 0;
			c3_p2_wr_mask <= 0;
			c3_p2_wr_data <= 0;
			c3_p2_rd_en <= 0;
			c3_p3_cmd_en <= 0;
			c3_p3_cmd_instr <= 0;
			c3_p3_cmd_bl <= 0;
			c3_p3_cmd_byte_addr <= 0;
			c3_p3_wr_en	<= 0;
			c3_p3_wr_mask <= 0;
			c3_p3_wr_data <= 0;
			c3_p3_rd_en <= 0;
			port2_tst_sign <= 1'b0;
			tst_data <= 32'd0;
			
			c3_rd_data[0] <= 32'd0;
			c3_rd_data[1] <= 32'd0;
			c3_rd_data[2] <= 32'd0;
			c3_rd_data[3] <= 32'd0;
			c3_rd_data[4] <= 32'd0;
			c3_rd_addr[0] <= 30'd0;
			c3_rd_addr[1] <= 30'd0;
			c3_rd_addr[2] <= 30'd0;
			c3_rd_addr[3] <= 30'd0;
			c3_rd_addr[4] <= 30'd0;
			data_rd_out[0] <= 32'd0;
			data_rd_out[1] <= 32'd0;
			data_rd_out[2] <= 32'd0;
			data_rd_out[3] <= 32'd0;
			data_rd_out[4] <= 32'd0;
			
			port2_read_done <= 1'b0;
			
			ker_cal_sign <= 1'b0;
			alpha_address <= 0;//==30'd57212;//160,53372
			//==errorcache_address <= 30'd58492;//200,54668
			
			test_end_cnt <= 12'd0;
			port1_cnt <= 12'd0;
			ddr_orgin_end <= 1'b0;
			alpha_wr_end <= 1'b0;
			alpha_read_end <= 1'b0;
			alpha_two_out <= 0;
			
			off_on_sign <= 1'b1;//--
			
			mul_cnt <= 8'd0;
			ker_rd_end <= 1'b0;
			feature_flag <= 1'b0;//==//
			sample_addr <= 32'd0;
			sample_alpha <= 32'd0;
			sample_kernel <= 32'd0;
			sample_dim <= 32'd0;
			sp_num <= 16'd0;
			sp_dim <= 16'd0;
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
						ddr_address <= 252;//-DDR_STARTADDR;
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
				   c3_p0_cmd_en <= 0;
				   c3_p0_cmd_instr <= 0;
				   c3_p0_cmd_bl <= 0;
				   c3_p0_cmd_byte_addr <=0;
				   c3_p0_wr_en	<= 1;
				   c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= data_out;//number;
				   c3_p0_rd_en <= 0;
				   if(rf_cnt == 323)
					begin
					   sample_addr <= data_out;
						port1_ddr_address <= data_out + 236;//5356
					end
					if(rf_cnt == 324)
					begin
						sample_alpha <= data_out;
						alpha_address <= data_out + 252;
					end
					if(rf_cnt == 325)
					begin
					   sample_kernel <= data_out;
					end
					if(rf_cnt == 326)
					begin
						sample_dim <= data_out;
						sp_num <= (data_out[31:16]<<2);
						sp_dim <= data_out[15:0];
					end
					if (!c3_p0_wr_full)
				   begin
				      state_next <= WRITECMD;
				   end
				end
				
				WRITECMD: begin   //put DDRIP_write_fifo into externel ddr2 sdram
				   c3_p0_cmd_en <= 1;
				   c3_p0_cmd_instr <= 3'b000;//write data to port0
				   c3_p0_cmd_bl <= 6'd3;	//63,Burst length is encoded as 0 to 63, representing 1 to 64 user words
				   c3_p0_cmd_byte_addr <= ddr_address;//ddr_address
				   c3_p0_wr_en	<= 0;
				   c3_p0_wr_mask <= 0;
				   //	c3_p0_wr_data <= 0;
				   c3_p0_rd_en <= 0;
					if (c3_p0_wr_empty)
				   begin
				      state_next <= WRITECMDDONE;
					end
				end
				
				WRITECMDDONE: begin //write_fifo is empty
					c3_p0_cmd_en <= 0;
				   c3_p0_cmd_instr <= 0;
				   c3_p0_cmd_bl <= 0;
				   c3_p0_cmd_byte_addr <= 0;
				   c3_p0_wr_en	<= 0;
				   c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
				   c3_p0_rd_en <= 0;
					state_next <= READDATADONE;
				end
				
				READDATADONE: begin //read_fifo is empty
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
				   c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					number <= number;// + 1;
					if(ddr_address >= DDR_ENDADDR)
					begin
						ddr_address <= DDR_STARTADDR;
						state_next <= IDLE;//- 
					end
					else begin
						ddr_address <= ddr_address + 30'd16;//9'd256,1024
						state_next <= IDLE;//-
					end
				end
				////////////////////////////////sample-->kernel
				read_ready: begin
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;//
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;					
					ker_cal_sign <= 1'b0;
					test_end_cnt <= 0;//-
					c3_rd_addr[0] <= (kernel_i<<5);
			      c3_rd_addr[1] <= (kernel_i<<5) + 16;
			      c3_rd_addr[2] <= (kernel_j<<5);
			      c3_rd_addr[3] <= (kernel_j<<5) + 16;
					if(busy_flag == 0)
					begin
					   state_next <= read_mid;//-read_cmd;
					end
					else begin
					   state_next <= port1_IDLE;//--SVM_WRIDLE;//--
					end
				end
				read_mid: begin
				   if(mul_cnt <= 3)
					begin
					   state_next <= read_cmd;
					end
					else begin
					   state_next <= read_data_done;
						data_rd_x <= data_rd_out[0];
						data_rd_y <= data_rd_out[1];
						data_rd_z <= data_rd_out[2];
						data_rd_w <= data_rd_out[3];
					end
					test_end_cnt <= 0;//-
					c3_p0_rd_en <= 0;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;				
				end
				read_cmd: begin
				   c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b001;
					c3_p0_cmd_bl <= 6'd63;	//63,Burst length is encoded as 0 to 63, representing 1 to 64 user words				
					c3_p0_cmd_byte_addr <= c3_rd_addr[mul_cnt];//-1232;//-
					//(kernel_i<<2);//ddr_address
					//64*(32/8)=256,64深度的fifo向ddr3搬运的数据数量里最多为64个和fifo深度想通
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					///data_inx <=0;
					if (c3_p0_rd_full)//-(c3_p0_rd_full)
					begin
					   state_next <= read_cmd_done;
					end
				end
				read_cmd_done: begin
				   if (c3_p0_rd_empty)
					begin
					   state_next <= read_mid;
                  mul_cnt <= mul_cnt + 1;						
					end
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 1;//0
               data_rd_out[mul_cnt] <= c3_p0_rd_data;					
				end
				
				read_data_done: begin
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					mul_cnt <= 0;//--//
					ker_cal_sign <= 1'b1;
					state_next <= READ_CMD_1;//--read_data_done;//-
					//--port1_read_done <= 1'b1;
					//--fifo_data <= {data_inx,data_iny,alpha_two_out,c3_rd2_data};	
				end
				READ_CMD_1: begin  //read_fifo is full
					if(svm_kernel_sign == 1'b1)
					begin
						state_next <= WRITE_IDLE_1;//-
					end
					else begin
					   feature_flag <= feature_full_falg;
					   if(feature_flag && !feature_full_falg)//下降沿
						begin
						   state_next <= read_ready;//==READ_CMD_1;
							c3_rd_addr[0] <= c3_rd_addr[0] + 32;
			            c3_rd_addr[1] <= c3_rd_addr[1] + 16;
			            c3_rd_addr[2] <= c3_rd_addr[2] + 32;
			            c3_rd_addr[3] <= c3_rd_addr[3] + 16;
						end
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
						c3_p0_cmd_byte_addr <= 0;
						c3_p0_wr_en	<= 0;
						c3_p0_wr_mask <= 0;
						c3_p0_wr_data <= 0;
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
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
				   test_end_cnt <= 0;//-
					//--c3_p0_wr_data <= square_data;//32'hAABBCCDD;//
					//--c3_rd2_data <= square_data;
					port1_ddr_address <= port1_ddr_address + 16;//==//port1_ddr_address + 16;					
					if(kernel_j == kernel_i)
					begin
						kernel_i <= kernel_i + 1;
					   kernel_j <= 0;//--kernel_i - 1;
					end
					else if(kernel_j < kernel_i) 
					begin
						kernel_i <= kernel_i;
						kernel_j <= kernel_j + 1;
					end
               state_next <= WRITE_FIFO_1;//可忽略
				end
				WRITE_FIFO_1: begin //put c3_p0_wr_data[31:0]==0xaaaa_aaaa into DDRIP_write_fifo
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <=0;
					c3_p0_wr_en	<= 1;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= square_data;//number;
					c3_p0_rd_en <= 0;
					//test_end_cnt <= test_end_cnt + 1;
				   if (!c3_p0_wr_full)
					begin
					   state_next <= WRITE_CMD_START_1;//WRITE_DATA_DONE_1;
					end
				end
				WRITE_CMD_START_1: begin 
					c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b000;//write data to port0
					c3_p0_cmd_bl <= 6'd3;	//63,Burst length is encoded as 0 to 63, representing 1 to 64 user words
					c3_p0_cmd_byte_addr <= port1_ddr_address;//ddr_address
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					//--c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;	
               if (c3_p0_wr_empty)
					begin					
                  state_next <= WRITE_CMD_1;	
               end					
				end
				WRITE_CMD_1: begin
					//-state_next <= READCMD;
					state_next <= read_ready;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;//
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					test_end_cnt <= 0;//-
				end
				////////////////////////////////////////////////kernel finish			
				////////////////////////////////////////////alpha,errorcache初始化
				port1_IDLE: begin
					state_next <= port1_WRITEDATA;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
				end
				port1_WRITEDATA: begin
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <=0;
					c3_p0_wr_en	<= 1;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 32'd0;//-32'hAABBCCDD;//-
					c3_p0_rd_en <= 0;
					if (!c3_p0_wr_full)
					begin
					   state_next <= port1_WRITECMD;
					end
			   end			
				port1_WRITECMD: begin 					
					c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b000;
					c3_p0_cmd_bl <= 6'd3;
					c3_p0_cmd_byte_addr <= alpha_address;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					//c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					if (c3_p0_wr_empty)
					begin
					   state_next <= errorcache_WRDATA;//--port1_WRITECMDDONE;
				   end
				end
				errorcache_WRDATA:begin
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					state_next <= port1_WRITECMDDONE;
				end
				port1_WRITECMDDONE: begin
					if(port1_cnt <= (sp_num + 2))    //6个样本
					begin
						state_next <= port1_IDLE;//--port1_WRITEDATA;
						alpha_address <= alpha_address + 16;
						port1_cnt <= port1_cnt + 1;
					end
					else begin
						port1_cnt <= 0;
						state_next <= SVM_WRIDLE;//--READCMD;//--
					end
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
				end
            //////////////////////////////
				SVM_WRIDLE: begin
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					port1_cnt <= 0;//--//
					//--c3_rd_addr[2] <= 30'd2544;
			      //--c3_rd_addr[3] <= 30'd16;
			      //--c3_rd_addr[0] <= 30'd54400;
			      //--c3_rd_addr[1] <= 30'd54368;
					//-if(test_end_cnt <= 3)
					//-begin
					//-   test_end_cnt <= test_end_cnt + 1;
					//-end
					//-else begin
					   off_on_sign <= 1'b1;
					   ddr_orgin_end <= 1'b1;
					   test_end_cnt <= 0;
						state_next <= DDRFINISH;//--READCMD;
					//-end
				end
				DDRFINISH:begin
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					alpha_two_out <= 0;
					alpha_read_end <= 1'b0;
					alpha_wr_end <= 1'b0;
					test_end_cnt <= 0;
					state_next <= SVM_WAIT;
			   end
		      SVM_WAIT: begin
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 3'b000;
					c3_p0_cmd_bl <= 0;
				   c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;	
					alpha_two_out <= 0;
					alpha_read_end <= 1'b0;
					alpha_wr_end <= 1'b0;
               test_end_cnt <= 0;
               data_rd_x <= 0;
					data_rd_y <= 0;
					data_rd_z <= 0;
					data_rd_w <= 0;
               data_rd_out[0] <= 0;
               data_rd_out[1] <= 0;
               data_rd_out[2] <= 0;
					data_rd_out[3] <= 0;
					/*if(alpha_read_start == 1'b1)
					begin  
						state_next <= port2_PARRDDATA;//-port1_READCMD;
					end*/
					if(alpha_read_start == 1'b1 || alpha_pard_start == 1'b1)
					begin
					   state_next <= port1_READ_MID;
					end
					if(alpha_wr_start == 1'b1)
					begin
						state_next <= alpha_WRDONE;
					end
					if(alpha_read_start == 1'b0 && alpha_wr_start == 1'b0 && alpha_pard_start == 1'b0)
					begin
						state_next <= SVM_WAIT;
					end
				end
            alpha_WRDONE:begin
               if(test_end_cnt <= 13)
					begin
					   test_end_cnt <= test_end_cnt + 1;
					end
					else begin
					   test_end_cnt <= 0;
					   state_next <= alpha_WRONE;
					end
					off_on_sign <= 1'b0;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= alpha_wr_ddr;
					c3_p0_wr_mask <= 0;				
					c3_p0_rd_en <= 0;	
					c3_p0_wr_en	<= 0;
					c3_p0_wr_data <= alpha_wr_data;
            end				
				alpha_WRONE: begin
				   test_end_cnt <= 0;
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					//-c3_p0_cmd_byte_addr <= alpha_wr_ddr;
					c3_p0_wr_mask <= 0;				
					c3_p0_rd_en <= 0;	
					c3_p0_wr_en	<= 1;
				   //-c3_p0_wr_data <= alpha_wr_data;					
					if(!c3_p0_wr_full)
					begin
						state_next <= alpha_WRCMDONE;
					end
				end
				alpha_WRCMDONE: begin			    
					c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b000;
					c3_p0_cmd_bl <= 6'd3;
					//c3_p0_cmd_byte_addr <= alpha_wr_ddr;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					//c3_p0_wr_data <= alpha_wr_data;
					c3_p0_rd_en <= 0;	
					if(c3_p0_wr_empty)
					begin					
						state_next <= alpha_WAITING;
						alpha_wr_end <= 1'b1;
					end
				end
            alpha_WAITING: begin
					//--alpha_wr_end <= 1'b1;
				   //--test_end_cnt <= test_end_cnt + 1;
				   if(alpha_wr_start == 1'b0 && off_on_sign == 1'b0)
					begin
					   alpha_wr_end <= 1'b0;
					   off_on_sign <= 1'b1;	   
					end
					if(off_on_sign == 1'b1)
					begin
					   if(train_end_sign == 1'b0)
					   begin
							if(alpha_read_start == 1'b1 || alpha_wr_start == 1'b1 || alpha_pard_start == 1'b1)
							begin
								state_next <= SVM_WAIT;//-
								test_end_cnt <= 0;
							end
						end
						else begin
						   state_next <= port2_WAITING;//-
						   test_end_cnt <= 0;
						end
					end
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					//-port1_read_done <= 1'b1;
				end
				
				port1_READ_MID:begin
					//==state_next <= port2_IDLE;//==port1_READCMD;
				   if(alpha_read_start == 1'b1)
					begin
						if(test_end_cnt <= 13)
					   begin
					   test_end_cnt <= test_end_cnt + 1;
						c3_p0_cmd_byte_addr <= alpha_rd_ddr;
					   end
						else begin
						test_end_cnt <= 0;
					   state_next <= port1_READCMD;
						end
					end
				   else if(alpha_pard_start == 1'b1)
					begin
					   if(test_end_cnt <= 12)
					   begin
					   test_end_cnt <= test_end_cnt + 1;
					   c3_p0_cmd_byte_addr <= 0;
						end
						else begin
						test_end_cnt <= 0;
					   state_next <= port2_IDLE;
						end
					end
					off_on_sign <= 1'b0;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
				   c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;	
					c3_p0_rd_en <= 0;
					mul_cnt <= 0;
					c3_rd_addr[0] <= alpha_rdZ_ddr;
			      c3_rd_addr[1] <= alpha_rdN_ddr;
			      c3_rd_addr[2] <= alpha_rdT_ddr;
			      c3_rd_addr[3] <= alpha_rdH_ddr;
				end
				port2_IDLE:begin
				   c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= c3_rd_addr[mul_cnt];
				   c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;	
					c3_p0_rd_en <= 0;
					test_end_cnt <= 0;
					if(mul_cnt <= 3)//3
					begin
						state_next <= port1_READCMD;					
					end
					else begin
						mul_cnt <= 0;
						alpha_read_end <= 1'b1;
						state_next <= port1_WAITING;
						data_rd_x <= data_rd_out[0];
						data_rd_y <= data_rd_out[1];
						data_rd_z <= data_rd_out[2];
						data_rd_w <= data_rd_out[3];
					end
				end
				port1_READCMD: begin
				   c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b001;
					c3_p0_cmd_bl <= 6'd63;
					//c3_p0_cmd_byte_addr <= c3_rd_addr[mul_cnt];
					//64*(32/8)=256,64深度的fifo向ddr3搬运的数据数量里最多为64个和fifo深度想通
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
				   c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					if(c3_p0_rd_full)
					begin
						state_next <= port1_READDATA;
					end
				end
				port1_READDATA: begin
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					//-c3_p1_cmd_byte_addr <= 0;
				   c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;	
					c3_p0_rd_en <= 1;
					if(alpha_read_start == 1'b1)
					begin
					   alpha_two_out <= c3_p0_rd_data;
						if(c3_p0_rd_empty)
					   begin				   
						state_next <= port1_WAITING;
						alpha_read_end <= 1'b1;
					   end
					end
					else if(alpha_pard_start == 1'b1)
					begin
					   data_rd_out[mul_cnt] <= c3_p0_rd_data;
					   if(c3_p0_rd_empty)
					   begin				   
						state_next <= port2_IDLE;//==port1_WAITING;
						mul_cnt <= mul_cnt + 1;
						//==alpha_read_end <= 1'b1;
					   end
					end
				end
				
				port1_WAITING: begin	
					//--alpha_read_end <= 1'b1;
					//--test_end_cnt <= test_end_cnt + 1;					
				   if(alpha_read_start == 1'b0 && alpha_pard_start == 1'b0 && off_on_sign == 1'b0)
					begin
						off_on_sign <= 1'b1;
						alpha_read_end <= 1'b0;
					end
					if(off_on_sign == 1'b1)
				   begin
                  if(train_end_sign == 1'b0)
					   begin					
							if(alpha_read_start == 1'b1 || alpha_wr_start == 1'b1 || alpha_pard_start == 1'b1)
							begin
								state_next <= SVM_WAIT;//-
								test_end_cnt <= 0;
							end
						end
						else begin
						   state_next <= port2_WAITING;//-
						   test_end_cnt <= 0;
						end
					end
					c3_p0_rd_en <= 0;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					//--c3_p0_rd_en <= 0;				
					//-port1_read_done <= 1'b1;
					//-fifo_data <= {data_inx,data_iny,square_data,alpha_two_out};
				end
            
				///////////////////////////////////////////////////////ddr_tst
				port2_WAITING: begin
					c3_p0_rd_en <= 0;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					
					mul_cnt <= 0;
					//=if(test_end_cnt <= 4)
					//=begin
					//=   test_end_cnt <= test_end_cnt + 1;
					//=end
					//=else begin
						if(tst_rd_sign == 1'b1)
						begin
						   c3_rd_addr[0] <= (sample_addr>>1) + ddr_tst_num;//2560,(sp_num*sp_dim)
			            c3_rd_addr[1] <= 16 + (sample_addr>>1) + ddr_tst_num;//(sp_num*sp_dim)
			            c3_rd_addr[2] <= ddr_ker_num;
					      c3_rd_addr[3] <= 16 + ddr_ker_num;
			            c3_rd_addr[4] <= sample_alpha + ddr_alpha_num;//56960
						   ker_rd_end <= 1'b0;
						   test_end_cnt <= 0;
							state_next <= port2_READIDLE;//-port2_READCMD;
						end
					//=end
				end
				port2_READIDLE:begin
				   c3_p0_rd_en <= 0;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					if(mul_cnt <= 4)
					begin
					   state_next <= port2_READCMD;//port2_READDONE;//=
					end
					else begin
					   if(test_end_cnt <= 12)
					   begin
					   test_end_cnt <= test_end_cnt + 1;
						ker_rd_end <= 1'b1;
					   end
					   else begin
						test_end_cnt <= 0;
					   ker_rd_end <= 1'b0;
						state_next <= port2_WAITING;
                  end						
					   data_rd_x <= data_rd_out[0];
						data_rd_y <= data_rd_out[1];
						data_rd_z <= data_rd_out[2];
						data_rd_w <= data_rd_out[3];
						data_rd_a <= data_rd_out[4];
					end
				end
				/*port2_READDONE:begin
				   c3_p0_rd_en <= 0;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= c3_rd_addr[mul_cnt];
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					if(test_end_cnt <= 9)
					begin
					   test_end_cnt <= test_end_cnt + 1;
					end
					else begin
					   test_end_cnt <= 0;
						state_next <= port2_READCMD;
					end
					//==port2_tst_sign <= 1'b1;
				   //==state_next <= port2_READDONE;
				end*/
				port2_READCMD:begin
				   c3_p0_cmd_en <= 1;
					c3_p0_cmd_instr <= 3'b001;
					c3_p0_cmd_bl <= 6'd63;
				   c3_p0_cmd_byte_addr <= c3_rd_addr[mul_cnt];//==2560;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					c3_p0_rd_en <= 0;
					if (c3_p0_rd_full)
					begin
				   state_next <= port2_READDATA;
					end
				end
				port2_READDATA:begin
				   c3_p0_rd_en <= 1;
					c3_p0_cmd_en <= 0;
					c3_p0_cmd_instr <= 0;
					c3_p0_cmd_bl <= 0;
					c3_p0_cmd_byte_addr <= 0;
					c3_p0_wr_en	<= 0;
					c3_p0_wr_mask <= 0;
					c3_p0_wr_data <= 0;
					//==tst_data <= c3_p0_rd_data;
					data_rd_out[mul_cnt] <= c3_p0_rd_data;
					if (c3_p0_rd_empty)
					begin
				      state_next <= port2_READIDLE;//port2_READDONE;
					   mul_cnt <= mul_cnt + 1;
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
reg[13:0] wrcnt;	
reg[13:0] tst_wrcnt;															

//读FIFO计数周期	
reg[13:0] rdcnt;
reg[13:0] tst_rdcnt;

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
			  wrcnt <= 14'd0;
		end
		else begin
		     if(wrcnt <= 1320)//5个32位数据,27,336,656
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
			  else if(wrcnt >= 1320)//28,336
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

always @(posedge clk_12m5 or posedge c3_rst0)//clk_12m5
begin
     if(c3_rst0)
	  begin
	       rdcnt <= 14'd0;
			 fifo_rden <= 1'b0;
			 fill_finish <= 1'b0;
			 data_out <= 32'd0;
			 rf_cnt <= 16'd0;//////
			 ss_reg <= 8'd0;
			 ddr_end <= 1'b0;
			 ddr_tst_end <= 1'b0;
			 fill_edge_down <= 1'b0;
			 tst_wrcnt <= 14'd0;
			 tst_rdcnt <= 14'd0;
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
							 if(rf_cnt >= 327)//8,84,164
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
//接口
fifo  your_instance_name(
		.rst(c3_rst0), // input rst
		.wr_clk(wr_clk), // input wr_clk
		.rd_clk(clk_12m5), // input rd_clk,clk_12m5						  
		.din(fifo_wrdb), // input [7 : 0] din
		.wr_en(fifo_wren), // input wr_en
		.rd_en(fifo_rden), // input rd_en
		.dout(fifo_rddb), // output [7 : 0] dout
		.full(fifo_full), // output full
		.empty(fifo_empty) // output empty
);

endmodule
