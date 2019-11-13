`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:44:09 10/28/2017 
// Design Name: 
// Module Name:    uart_test 
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
module uart_test(
       clk50, 
		 rx, 
		 tx, 
		 reset, 
		 fifo_full, 
		 fifo_empty, 
		 fifo_rdrdy, 
		 fifo_rddb,
		 //led2
		 
	 mcb3_dram_dq,
    mcb3_dram_a,
    mcb3_dram_ba,
    mcb3_dram_ras_n,
    mcb3_dram_cas_n,
	
    mcb3_dram_we_n,
    mcb3_dram_odt,
  
    mcb3_dram_reset_n,
    mcb3_dram_dm,
	 mcb3_dram_udm,
    mcb3_dram_udqs,
    mcb3_dram_udqs_n,
    mcb3_dram_dqs,
    mcb3_dram_dqs_n,
	 
	 mcb3_dram_cke,
    mcb3_dram_ck,
    mcb3_dram_ck_n,	
	 mcb3_rzq,
    mcb3_zio,
	 
	 calib_done,
	 led2,//ddr2_test_true,
	 led3,
	 led4
	 
);
input clk50;
//input reset;
input rx;
output tx;

input reset;	//
output fifo_full;		//
output fifo_empty;		//		
output fifo_rdrdy;		
output[7:0] fifo_rddb;	

///////////////////////////////ddr
   inout  [15:0]                      mcb3_dram_dq;
   output [13:0]                      mcb3_dram_a;
   output [2:0]                       mcb3_dram_ba;
   output                             mcb3_dram_ras_n;
   output                             mcb3_dram_cas_n;
	
   output                             mcb3_dram_we_n;
   output                             mcb3_dram_odt;
  
   output                             mcb3_dram_reset_n;////////
   output                             mcb3_dram_dm;
	output                             mcb3_dram_udm;
   inout                              mcb3_dram_udqs;
   inout                              mcb3_dram_udqs_n;
   inout                              mcb3_dram_dqs;
   inout                              mcb3_dram_dqs_n;
	
	//input                              c3_sys_clk;
   //input                              rst_n;
	output                             mcb3_dram_cke;
   output                             mcb3_dram_ck;
   output                             mcb3_dram_ck_n;	
	inout                              mcb3_rzq;
   inout                              mcb3_zio;

   output calib_done;
	wire  ddr2_test_true;//led2
	output led3;
	output led4;
//////////////////////////////ddr
wire clk_50;

wire clk;       //clock for 9600 uart port
wire [7:0] txdata,rxdata;
wire idle;
wire dataerror;
wire frameerror;

wire fifo_rd;

wire fill_finish;
wire read_sign;
wire [127:0] fifo_data;


//wire c3_clk0;
//wire c3_rst0;
wire clk_12m5;///.
////////////////////////////ºËº¯Êı
wire square_sign;
wire [31:0] square_data;
wire [15:0] square_cnt;
wire port1_read_done;
wire rst_svm;
wire test_end;//////.
wire busy_reverse;
wire busy_flag;

wire [31:0] data_rd_x;//
wire [31:0] data_rd_y;//
wire [31:0] data_rd_z;//
wire [31:0] data_rd_w;//
wire [31:0] data_rd_a;//ddr-->kernel
wire ker_cal_sign;
wire feature_full_falg;//==//

wire rd_start_flag;
////////////////////////////////
wire         train_end_sign;
wire [207:0] ss_out;//128
wire         alpha_read_start;//input
wire         alpha_pard_start;
wire [29:0]  alpha_rd_ddr;      //input  [29:0]

wire [29:0]  alpha_rdZ_ddr;
wire [29:0]  alpha_rdN_ddr;
wire [29:0]  alpha_rdT_ddr;
wire [29:0]  alpha_rdH_ddr;

wire         alpha_read_end;    //output reg
wire [31:0]  alpha_two_out;     //output reg [31:0]
wire         alpha_wr_start;    //input
wire [31:0]  alpha_wr_data;     //input  [31:0]
wire [29:0]  alpha_wr_ddr;      //input  [29:0] 
wire         alpha_wr_end;      //output reg
wire         ddr_orgin_end;     //output reg
wire         off_on_sign;
////////////////////////////////
wire [31:0]  tst_data;
wire port2_tst_sign;
wire [287:0] ss_tst_data;
wire train_tst_sign;
wire [31:0] sample_addr;
wire [31:0] sample_alpha;
wire [31:0] sample_kernel;
wire [31:0] sample_dim;
wire ddr_end;
assign ss_tst_data = {sam_flag,ss_out[127:80]};//===tst_data,,,data_rd_x,sample_addr,sample_alpha,sample_kernel,sample_dim
assign train_tst_sign = (train_end_sign && svm_tst_finish);//==port2_tst_sign);
//////////////////////////////svm_forest
wire [31:0] svm_b;
wire [79:0] s_out;
wire [79:0] sv_out;
wire tst_rd_sign;
wire [15:0] ddr_tst_num;
wire [15:0] ddr_ker_num;
wire [15:0] ddr_alpha_num;
wire ker_rd_end;
wire [79:0] sam_flag;
wire svm_tst_finish;

output led2;
assign led2 = train_tst_sign;//rd_start_flag;ddr2_test_true//--train_end_sign;//port1_read_done

clkdiv u0 (
		.clk50                   (clk_50),
      .reset                   (reset),		
		.clkout                  (clk)                    
 );

uartrx u1 (
		.clk                     (clk), 
      .reset                   (reset),		
      .rx	                   (rx),  	
		.dataout                 (rxdata),                       
      .rdsig                   (rdsig),
		.dataerror               (dataerror),
		.frameerror              (frameerror),
		.fifo_rd                 (fifo_rd)
);

uarttx u2 (
		.clk                     (clk),  
      .reset                   (reset),		
		.datain                  (txdata),
      .wrsig                   (wrsig), 
      .idle                    (idle), 	
	   .tx                      (tx)	
 );

uartctrl u3 (
		.clk                     (clk),
      .reset                   (reset),		
		.rdsig                   (rdsig),
      .rxdata                  (rxdata), 		
      .wrsig                   (wrsig), 
      .dataout                 (txdata),
		
		.fill_finish             (train_tst_sign),//fill_finish,ddr2_test_true//port1_read_done,train_end_sign
		.fifo_data               (ss_tst_data),//ss_out,fifo_data
		
      .tx_idle                 (idle)		
	
 );
 
fifo_test uut_fifo_test(
					.wr_clk(clk),	
					.rd_clk(clk50),	
					.rst_n(reset),	
               .clk_50(clk_50),
 					
					.fifo_full(fifo_full),	
					.fifo_empty(fifo_empty),
					.fifo_rdrdy(fifo_rdrdy),
					.fifo_rddb(fifo_rddb),	

               .tst_data(tst_data),	
               .port2_tst_sign(port2_tst_sign),	
               .train_end_sign(train_end_sign),      //input					
					//.fifo_rd(fifo_rd),
					.ddr_end(ddr_end),
					
					.rdsig(rdsig),
					.rxdata(rxdata),
					
					.rd_start_flag(rd_start_flag),
					.fill_finish(fill_finish),

					.read_sign(read_sign),
					.fifo_data(fifo_data),
			
         .sample_addr(sample_addr),	
         .sample_alpha(sample_alpha),
         .sample_kernel(sample_kernel),
         .sample_dim(sample_dim),			
			///////////////////////////////////////
			.square_sign(square_sign),        //input 1 bit
			.square_data(square_data),        //input 32 bit
			.square_cnt(square_cnt),          //input 16 bit
			.test_end(test_end),  ////
			.port1_read_done(port1_read_done),//output
			.busy_flag(busy_flag),            //input,
			.feature_full_falg(feature_full_falg),//input
			
			.data_rd_x(data_rd_x),              //output,ddr-->kernel
			.data_rd_y(data_rd_y),              //output
			.data_rd_z(data_rd_z),              //output
			.data_rd_w(data_rd_w),              //output
			.data_rd_a(data_rd_a),
			.ker_cal_sign(ker_cal_sign),      //output
			///////////////////////////////////////svm
			///////////////////////////////////////svm_train		
			.alpha_read_start(alpha_read_start),//input
			.alpha_pard_start(alpha_pard_start),//input
	      .alpha_rd_ddr(alpha_rd_ddr),      //input  [29:0]
			.alpha_rdZ_ddr(alpha_rdZ_ddr),               //input reg [29:0]
			.alpha_rdN_ddr(alpha_rdN_ddr),               //input reg [29:0]
			.alpha_rdT_ddr(alpha_rdT_ddr),               //input reg [29:0]
			.alpha_rdH_ddr(alpha_rdH_ddr),               //input reg [29:0]
			
	      .alpha_read_end(alpha_read_end),  //output reg
	      .alpha_two_out(alpha_two_out),    //output reg [31:0]
         .alpha_wr_start(alpha_wr_start),//input
         .alpha_wr_data(alpha_wr_data),    //input  [31:0]
         .alpha_wr_ddr(alpha_wr_ddr),      //input  [29:0] 
         .alpha_wr_end(alpha_wr_end),      //output reg
	      .ddr_orgin_end(ddr_orgin_end),    //output reg
         .off_on_sign(off_on_sign),
			
			///////////////////////////////////////
			.tst_rd_sign(tst_rd_sign),                //input
		   .ddr_tst_num(ddr_tst_num),                //input reg [15:0] 
		   .ddr_ker_num(ddr_ker_num),                //input reg [15:0] 
		   .ddr_alpha_num(ddr_alpha_num),            //input reg [15:0] 
		   .ker_rd_end(ker_rd_end),                  //output
			
			//////////////////////////////////////////ddr
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
		  .mcb3_dram_dm           (mcb3_dram_dm),//
		  .mcb3_dram_reset_n      (mcb3_dram_reset_n),
		  //.c3_clk0		        (c3_clk0),
		  //.c3_rst0		        (c3_rst0),
		  .clk12m5                (clk_12m5),//78.125
		  .rst_svm                (rst_svm),
		  .calib_done             (calib_done),
		  
		  .mcb3_rzq               (mcb3_rzq),            
		  .mcb3_zio               (mcb3_zio),
		  
		  .ddr2_test_true         (ddr2_test_true),
		  .led3                   (led3),
		  .led4                   (led4)
  
);
				

svm_kernal uut_svm_test(

             .clk_svm(clk_12m5),        //input,clk_50
             .rst_n(rst_svm),           //input,rst_svm
				 .ddr_test_end(test_end),   //input,svm_enable
				 .square_sign(square_sign), //output
				 .square_data(square_data), //output
				 .square_cnt(square_cnt),   //output
				 .busy_reverse(busy_reverse),
				 .busy_flag(busy_flag),
				 .feature_full_falg(feature_full_falg),
				 
				 .ddr_end(ddr_end),         //input
				 .sample_kernel(sample_kernel),//input
				 .num_dim(sample_dim[15:0]),   //input
				 .data_rd_x(data_rd_x),       //input
				 .data_rd_y(data_rd_y),       //input
				 .data_rd_z(data_rd_z),       //input
				 .data_rd_w(data_rd_w),       //input
				 .ker_cal_sign(ker_cal_sign)//input
				 
);

///////////////////////////////////////////////////
svm_train uut_svm_train(
          
			 .train_clk(clk_12m5),                      //input,78.5MHz,clk_12m5
          .rst_n(rst_svm),                           //input,rst_svm
			 .svm_train_enable(ddr_orgin_end),          //input,port1_read_done
			 .test_end_sign(train_end_sign),            //output,train finish
			 .ss_out(ss_out),                           //output result
			 .s_out(s_out),
			 .sv_out(sv_out),
			 .svm_b(svm_b),                             //output svm_b
			 
			 
			 .ddr_end(ddr_end),
			 .num_sample(sample_dim[31:16]),
			 .sample_addr(sample_addr),
			 .sample_alpha(sample_alpha),
			 .alpha_read_start(alpha_read_start),       //output reg      
			 .alpha_pard_start(alpha_pard_start),       //output reg      
		    .alpha_rd_ddr(alpha_rd_ddr),               //output reg [29:0] 
			 
			 .alpha_rdZ_ddr(alpha_rdZ_ddr),               //output reg [29:0]
			 .alpha_rdN_ddr(alpha_rdN_ddr),               //output reg [29:0]
			 .alpha_rdT_ddr(alpha_rdT_ddr),               //output reg [29:0]
			 .alpha_rdH_ddr(alpha_rdH_ddr),               //output reg [29:0]
			 
			 .data_rd_x(data_rd_x),              //output,ddr-->kernel
			 .data_rd_y(data_rd_y),              //output
			 .data_rd_z(data_rd_z),              //output
			 .data_rd_w(data_rd_w),              //output
			 
			 .alpha_read_end(alpha_read_end),           //input             
			 .alpha_data_in(alpha_two_out),             //input      [31:0] 
			 .alpha_wr_data(alpha_wr_data),             //output reg [31:0] 
			 .alpha_wr_start(alpha_wr_start),           //output reg        
			 .alpha_wr_ddr(alpha_wr_ddr),               //output reg [29:0] 
			 .alpha_wr_end(alpha_wr_end),                //input            
          .off_on_sign(off_on_sign)
			
);
///////////////////////////////////////////////////
svm_forest uut_svm_forest(

          .clk_svm(clk_12m5),                       //input,clk_50
          .rst_n(rst_svm),                          //input,rst_svm
			 .svm_b(svm_b),                            //input,svm_b,[31:0]
			 .s_out(s_out),                            //input,s_out,[79:0]
			 .sv_out(sv_out),                          //input,sv_out,[79:0]
			 .tst_rd_sign(tst_rd_sign),
		    .ddr_tst_num(ddr_tst_num),                //output reg [15:0] 
		    .ddr_ker_num(ddr_ker_num),                //output reg [15:0] 
		    .ddr_alpha_num(ddr_alpha_num),            //output reg [15:0] 
		    .ker_rd_end(ker_rd_end),                  //input
			 
			 .ddr_end(ddr_end),
			 .num_sample(sample_dim[31:16]),
			 .train_end_sign(train_end_sign),//input
			 .data_rd_x(data_rd_x),       //input
			 .data_rd_y(data_rd_y),       //input
			 .data_rd_z(data_rd_z),       //input
			 .data_rd_w(data_rd_w),       //input
			 .data_rd_a(data_rd_a),       //input
			 .sam_flag,                   //output reg [79:0] 
		    .svm_tst_finish              //output reg
			 
);

endmodule
