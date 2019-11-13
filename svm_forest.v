`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:46:56 03/26/2018 
// Design Name: 
// Module Name:    svm_forest 
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
module svm_forest(

       input clk_svm,                  //input,clk_50
       input rst_n,                    //input,rst_svm
		 input [31:0] svm_b,             //input,svm_b
		 input [79:0] s_out,             //input,s_out
		 input [79:0] sv_out,            //input,s_out
       output reg tst_rd_sign,
		 output reg [15:0] ddr_tst_num,
		 output reg [15:0] ddr_ker_num,
		 output reg [15:0] ddr_alpha_num,
		 input ker_rd_end,
		 output reg [79:0] sam_flag,
		 output reg svm_tst_finish,
		 
		 input        ddr_end,
		 input [15:0] num_sample,
		 input train_end_sign,
		 input [31:0] data_rd_x,         //input
		 input [31:0] data_rd_y,         //input
		 input [31:0] data_rd_z,         //input
		 input [31:0] data_rd_w,         //input
		 input [31:0] data_rd_a          //input

    );
    
	 //parameter sam_num = 79;
	 reg [7:0] tst_cnt;
	 reg [7:0] ker_num;
	 reg [7:0] a_cnt;
	 reg tst_add_sign;
	 reg ker_cal_sign;
	 reg ker_rd_flag;
	 /////////////////////////mul
	 reg [31:0] A_one;
	 reg [31:0] A_two;
	 reg [31:0] B_one;
	 reg [31:0] B_two;
	 reg [31:0] C_one;
	 reg [31:0] C_two;
	 reg [31:0] D_one;
	 reg [31:0] D_two;
	 reg [31:0] E_one;
	 reg [31:0] E_two;
		
	 reg start_A;
	 reg start_B;
	 reg start_C;
	 reg start_D;
	 reg start_E;
	 
	 reg svm_five_enable;
	 reg svm_tst_enable;
	 reg exp_enable;
	 reg exp_on_enable;
	 ////////////////////////³Ë·¨Æ÷ĞÅºÅ
    wire [31:0] data_one;
	 wire busy_one;
	 wire [31:0] data_two;
	 wire busy_two;
	 wire [31:0] data_three;
	 wire busy_three;
	 wire [31:0] data_four;
	 wire busy_four;
	 wire [31:0] data_five;
	 wire busy_five;
    reg [31:0] x_reg;	 
	 wire busy_e;
	 wire [31:0] out_k;
	 reg [31:0] sum_exp_one;
    reg [31:0] sum_exp_two;	 
	  
	 reg [31:0] sumtest;
	 reg sum_Y_N;
	 //==reg [79:0] sam_flag;
	 reg busy_mul_flag;
	 reg busy_five_flag;
	 reg busy_exp_flag;
	 reg tst_add_on;
	 reg cool_sign;
	 
	 reg [15:0] sp_num;
	 always @(posedge clk_svm or negedge rst_n)
	 begin
	    if(!rst_n)
		 begin
		    tst_cnt <= 8'd0;
			 ker_num <= 8'd0;
			 a_cnt <= 8'd0;
			 tst_rd_sign <= 1'b0;
			 ddr_tst_num <= 16'd0;
			 ddr_ker_num <= 16'd0;
			 ddr_alpha_num <= 16'd0;
			 tst_add_sign <= 1'b0;
			 ker_cal_sign <= 1'b0;
          ker_rd_flag <= 1'b0;
			 
			 svm_tst_enable <= 1'b0;
			 svm_five_enable <= 1'b0;
          sum_Y_N <= 1'b0;
			 sam_flag <= 80'd0;
			 busy_mul_flag <= 1'b0;
			 busy_five_flag <= 1'b0;
			 busy_exp_flag <= 1'b0;
			 
			 exp_on_enable <= 1'b0;
			 exp_enable <= 1'b0;
			 sumtest <= 32'd0;
			 svm_tst_finish <= 1'b0;
			 
			 start_A <= 1'b0;
			 start_B <= 1'b0;
          start_C <= 1'b0;
          start_D <= 1'b0;
			 start_E <= 1'b0;
			 A_one <= 32'b0;
			 A_two <= 32'b0;
			 B_one <= 32'b0;
			 B_two <= 32'b0;
			 C_one <= 32'b0;
			 C_two <= 32'b0;
			 D_one <= 32'b0;
			 D_two <= 32'b0;
			 E_one <= 32'b0;
			 E_two <= 32'b0;
			 sum_exp_one <= 32'd0;
			 sum_exp_two <= 32'd0;
			 tst_add_on <= 1'b1;
			 cool_sign <= 1'b0;
			 sp_num <= 16'd0;
		 end
		 else begin
		  if(ddr_end == 1'b1)
		  begin
		  sp_num <= num_sample;////40		  
		  if(train_end_sign == 1'b1)
		  begin
		    /////////////////////001
			 if(tst_add_sign == 1'b1)
			 begin
			    tst_add_sign <= 1'b0;
				 a_cnt <= 0;
				 sumtest <= sumtest + svm_b;
				 sum_Y_N <= 1'b1;
				 
			 end
			 /////////////////////001
		    if(sum_Y_N == 1'b1)
			 begin
				   if(sumtest[31] == 0)
					begin
					   //=sam_flag[tst_cnt-1] <= (tst_cnt <= 40)?0:1;
						if(tst_cnt < sp_num)//39
						begin
						   sam_flag[tst_cnt] <= 0;
							cool_sign <= 1'b1;
						end
						else begin
						   sam_flag[tst_cnt] <= 1;
							cool_sign <= 1'b1;
						end
					end
					else if(sumtest[31] == 1)
					begin
					   //=sam_flag[tst_cnt-1] <= (tst_cnt <= 40)?1:0;
						if(tst_cnt < sp_num)//39
						begin
						   sam_flag[tst_cnt] <= 1;
							cool_sign <= 1'b1;
						end
						else begin
						   sam_flag[tst_cnt] <= 0;
							cool_sign <= 1'b1;
						end
					end
			 end
			 if(cool_sign == 1'b1)
			 begin
			    sumtest <= 0;
				 sum_Y_N <= 1'b0;
				 tst_add_on <= 1'b1;
				 cool_sign <= 1'b0;
				 tst_cnt <= tst_cnt + 1;
			 end
		    if(tst_add_on == 1'b1)
			 begin		    	    
				 //if(tst_rd_sign == 1'b0 && ker_cal_sign == 1'b0 && tst_add_sign == 1'b0)/////////////////////1
				 if(tst_cnt < (sp_num<<1))//sam_num
				 begin
					 if(a_cnt < (sp_num<<1))////////01,sam_num
					 begin
						 if(s_out[a_cnt] == 1)/////////////////////2
						 begin
							 tst_rd_sign <= 1'b1;
							 tst_add_on <= 1'b0;
							 ddr_ker_num <= (a_cnt<<5);
							 ddr_tst_num <= (tst_cnt<<5);
							 ddr_alpha_num <= (a_cnt<<4);
						 end
						 else begin
							 a_cnt <= a_cnt + 1;
						 end//////////////////////////////////////2
					 end
					 else begin
						 tst_add_sign <= 1'b1;
						 tst_add_on <= 1'b0;
					 end////////////////////////01
				 end//////////////////////////////////////////////////////////////////////////////////1
				 else begin
			    svm_tst_finish <= 1'b1;
				 sam_flag <= sam_flag;
			    end
			 ////////////////////////////////002
			 end
			 
				 ker_rd_flag <= ker_rd_end;
				 if(!ker_rd_flag && ker_rd_end)     //ÏÂ½µÑØ¼ì²â
				 begin
				    tst_rd_sign <= 1'b0;
					 ker_cal_sign <= 1'b1;
					 svm_tst_enable <= 1'b1;
                //--a_cnt <= a_cnt + 1;
					 A_one <= {16'd0,data_rd_x[31:16]} - {16'd0,data_rd_z[31:16]};//{16'd0,data_inx[31:16]};//
					 A_two <= {16'd0,data_rd_x[31:16]} - {16'd0,data_rd_z[31:16]};//{16'd0,data_iny[31:16]};//
					 B_one <= {16'd0,data_rd_x[15:0]} - {16'd0,data_rd_z[15:0]};//{16'd0,data_inx[15:0]};//
					 B_two <= {16'd0,data_rd_x[15:0]} - {16'd0,data_rd_z[15:0]};//{16'd0,data_iny[15:0]};//
					 C_one <= {16'd0,data_rd_y[31:16]} - {16'd0,data_rd_w[31:16]};
					 C_two <= {16'd0,data_rd_y[31:16]} - {16'd0,data_rd_w[31:16]};
					 D_one <= {16'd0,data_rd_y[15:0]} - {16'd0,data_rd_w[15:0]};
					 D_two <= {16'd0,data_rd_y[15:0]} - {16'd0,data_rd_w[15:0]};
				 end
             if(svm_tst_enable == 1'b1)
             begin
                start_A <= 1'b1;
					 start_B <= 1'b1;
                start_C <= 1'b1;
                start_D <= 1'b1;
             end				 
				 ///////////////////////////////002
				 ///////////////////////////////003
				 busy_mul_flag <= busy_one;
				 if(busy_mul_flag && !busy_one)//(busy == 1'b1)£¬ÏÂ½µÑØ¼ì²â
				 begin
				    start_A <= 1'b0;
					 start_B <= 1'b0;
					 start_C <= 1'b0;
                start_D <= 1'b0;
					 svm_tst_enable <= 1'b0;
					 sum_exp_one <= data_one + data_two;
					 sum_exp_two <= data_three + data_four;
					 exp_on_enable <= 1'b1;
				 end
				 if(exp_on_enable == 1'b1)
				 begin
				    exp_enable <= 1'b1;
					 exp_on_enable <= 1'b0;
					 x_reg <= ((sum_exp_one + sum_exp_two)>>1);//³ËÒÔg
				 end
				 //////////////////////////////004
				 busy_exp_flag <= busy_e;
				 if(busy_exp_flag && !busy_e)    //ÏÂ½µÑØ¼ì²â
				 begin
				    exp_enable <= 1'b0;
					 svm_five_enable <= 1'b1;
					 a_cnt <= a_cnt + 1;
				 end
				 //////////////////////////////004
				 if(svm_five_enable == 1'b1)
				 begin
					 if(sv_out[a_cnt-1] == 1)
					 begin
					 sumtest <= (a_cnt <= sp_num)?(sumtest + (out_k<<1) + (out_k>>1)):(sumtest - (out_k<<1) - (out_k>>1));
				    svm_five_enable <= 1'b0;
					 ker_cal_sign <= 1'b0;
					 tst_add_on <= 1'b1;
					 end
					 else begin
					 start_E <= 1'b1;
					 E_one <= out_k;
					 E_two <= data_rd_a;
					 end
				 end
				 busy_five_flag <= busy_five;
				 if(busy_five_flag && !busy_five)//(busy == 1'b1)£¬ÏÂ½µÑØ¼ì²â
				 begin
				    svm_five_enable <= 1'b0;
					 start_E <= 1'b0;
					 ker_cal_sign <= 1'b0;
					 sumtest <= (a_cnt <= sp_num)?(sumtest + data_five):(sumtest - data_five);
					 tst_add_on <= 1'b1;
				 end
				 //////////////////////////////003
		 end
		 end
	   end
    end
    
   /////////////////////////////////////////////////////exp,mul
   exp_top exp_K(
		  
		  .clk(clk_svm),
		  .rst_n(rst_n),
		  .sum_a(x_reg),//input
		  .enable(exp_enable),//input
		  .svm_enable(1'b1),//svm_enable
		  .out_b(out_k),//output
		  .busy_e(busy_e)//output
		  
		);
	
	mul_one mul_one_data(
	     
		  .clk(clk_svm),
		  .rst_n(rst_n),
	     .mul_a(A_one),
		  .mul_b(A_two),
		  .start(start_A),// start sign
		  .svm_enable(svm_tst_enable),
		  .busy_one(busy_one),//output mul_one state
	     .data_one(data_one)//output result one
	 
	    );
   mul_two mul_two_data(
	     
		  .clk(clk_svm),
		  .rst_n(rst_n),
	     .mul_a(B_one),
		  .mul_b(B_two),//input mul_one result
		  .start(start_B),//input mul_one state
		  .svm_enable(svm_tst_enable),
		  .busy_two(busy_two),//output mul_two state
	     .data_two(data_two)//output SUM one
	 
	   );
		
   mul_three mul_three_data(
	     
		  .clk(clk_svm),
		  .rst_n(rst_n),
	     .mul_a(C_one),
		  .mul_b(C_two),
		  .start(start_C),// start sign
		  .svm_enable(svm_tst_enable),
		  .busy_three(busy_three),//output mul_three state
	     .data_three(data_three)//output result three
	 
	   );

   mul_four mul_four_data(
	     
		  .clk(clk_svm),
		  .rst_n(rst_n),
	     .mul_a(D_one),
		  .mul_b(D_two),
		  .start(start_D),// start sign
		  .svm_enable(svm_tst_enable),
		  .busy_four(busy_four),//output mul_three state
	     .data_four(data_four)//output result three
	 
	   );	 
		
	mul_five mul_five_data(
	     
		  .clk(clk_svm),
		  .rst_n(rst_n),
	     .mul_a(E_one),
		  .mul_b(E_two),
		  .start(start_E),// start sign
		  .svm_enable(svm_five_enable),
		  .busy_five(busy_five),//output mul_three state
	     .data_five(data_five)//output result three
	 
	   );

endmodule
