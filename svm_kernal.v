`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:43:06 12/04/2017 
// Design Name: 
// Module Name:    svm_kernal 
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
module svm_kernal(
         input clk_svm,
		 input rst_n,
		 input ddr_test_end,             
		 output reg square_sign,         
		 output reg [31:0] square_data,  
		 output reg [15:0] square_cnt,   
		 output reg busy_reverse,        
		 output busy_flag,               
		 output reg feature_full_falg,		 
		 input        ddr_end,
		 input [31:0] sample_kernel,
		 input [15:0] num_dim,
		 input [31:0] data_rd_x,
		 input [31:0] data_rd_y,
		 input [31:0] data_rd_z,
		 input [31:0] data_rd_w,
		 input ker_cal_sign               //calculate start sign
		 
    );
    
	   parameter IN_WIDTH = 32;
	   parameter OUT_WIDTH = 32;       
		reg [15:0]  features_num;
       reg [31:0] A_one;
	   reg [31:0] A_two;
		reg [31:0] B_one;
		reg [31:0] B_two;
		reg [31:0] C_one;
		reg [31:0] C_two;
		reg [31:0] D_one;
		reg [31:0] D_two;		
		reg start_A;
		reg start_B;
		reg start_C;
		reg start_D;
		
      reg [31:0] x [0:1];
		reg [31:0] y [0:1];

      reg [7:0] i;
		reg [7:0] j;
		reg [31:0] sum_reg;
		reg busy_flag1;
		//reg busy_reverse;
		reg sum_flag;//
		reg [31:0] sum_cnt;
		////////////////////////exp
		reg on_enable;
		reg [31:0] x_one_reg;
		reg [31:0] x_two_reg;
		reg [31:0] x_reg;
		reg enable;
		reg e_busy_reverse;
		reg busy_e_flag;
		wire busy_e;
		wire [31:0] out_k;
		////////////////////////
		wire [31:0] data_one;
	   wire busy_one;
		wire [31:0] data_two;
	   wire busy_two;
		wire [31:0] data_three;
	   wire busy_three;
		wire [31:0] data_four;
	   wire busy_four;		
		reg svm_en;
		wire svm_enable;
		assign svm_enable = svm_en;//busy_reverse;//ddr_test_end;
		
		//wire busy_flag;
		assign busy_flag = sum_flag;
		
		reg [3:0] busy_reverse_cnt;
		reg ker_cal_falg;
		//ddr-->x,y,z		
		/////////////////////////////////////////////
		always @(posedge clk_svm or negedge rst_n)
	   begin
	       if(!rst_n)
			 begin
			      i <= 8'd0;
				   j <= 8'd1;//0
					sum_reg <= 32'd0;
					sum_flag <= 1'b0;
					sum_cnt <= 32'd0;//
					features_num <= 16'd4;
					///////////////////
					start_A <= 1'b0;
					start_B <= 1'b0;
				   start_C <= 1'b0;
					start_D <= 1'b0;
					A_one <= 32'b0;
				   A_two <= 32'b0;
					B_one <= 32'b0;
					B_two <= 32'b0;
					C_one <= 32'b0;
					C_two <= 32'b0;
					D_one <= 32'b0;
					D_two <= 32'b0;
					//////////////////
					busy_flag1 <= 1'b1;//0
					busy_reverse <= 1'b0;//1
					busy_reverse_cnt <= 4'd0;					
					busy_e_flag <= 1'b0;
					on_enable <= 1'b0;
					enable <= 1'b0;
					e_busy_reverse <= 1'b1;
					x_reg <= 32'd0;
					x_one_reg <= 32'd0;
					x_two_reg <= 32'd0;					
					ker_cal_falg <= 1'b0;
					svm_en <= 1'b0;
					//////////////////output
					square_sign <= 1'b0;
					square_data <= 32'd0;
					square_cnt <= 16'd0;					
					feature_full_falg <= 1'b0;

					
			 end
			 else begin
			      if(ddr_end == 1'b1)
					begin
							//--ker_cal_falg <= ker_cal_sign;
					      if(sum_cnt <= sample_kernel)//20,3239
                     begin							
									//if(busy_reverse == 1'b1 && ker_cal_sign == 1'b1)
									ker_cal_falg <= ker_cal_sign;
									if(!ker_cal_falg && ker_cal_sign)//
									//if(svm_en == 1'b1)
									begin
											A_one <= {16'd0,data_rd_x[31:16]} - {16'd0,data_rd_z[31:16]};//{16'd0,data_inx[31:16]};//
											A_two <= {16'd0,data_rd_x[31:16]} - {16'd0,data_rd_z[31:16]};//{16'd0,data_iny[31:16]};//
											B_one <= {16'd0,data_rd_x[15:0]} - {16'd0,data_rd_z[15:0]};//{16'd0,data_inx[15:0]};//
											B_two <= {16'd0,data_rd_x[15:0]} - {16'd0,data_rd_z[15:0]};//{16'd0,data_iny[15:0]};//
											C_one <= {16'd0,data_rd_y[31:16]} - {16'd0,data_rd_w[31:16]};
											C_two <= {16'd0,data_rd_y[31:16]} - {16'd0,data_rd_w[31:16]};
											D_one <= {16'd0,data_rd_y[15:0]} - {16'd0,data_rd_w[15:0]};
											D_two <= {16'd0,data_rd_y[15:0]} - {16'd0,data_rd_w[15:0]};
											busy_reverse <= 1'b1;
											busy_reverse_cnt <= 0;
											svm_en <= 1'b1;											
									end				
									
						   end
							else begin
								sum_flag <= 1'b1;					  
								busy_reverse <= 1'b0;								   
							end
							if(busy_reverse == 1'b1)
							begin
								start_A <= 1'b1;
								start_B <= 1'b1;
								start_C <= 1'b1;
								start_D <= 1'b1;								
							end
							if(square_sign == 1'b1)
							begin
								if(busy_reverse_cnt <= 9)
								begin
									busy_reverse_cnt <= busy_reverse_cnt + 1;
								end
								else begin
									square_sign <= 1'b0;
								end											
							end
							busy_flag1 <= busy_one;
							if(busy_flag1 && !busy_one)
							begin
									sum_cnt <= sum_cnt + 1;//
									start_A <= 1'b0;
									start_B <= 1'b0;
									start_C <= 1'b0;
									start_D <= 1'b0;
									on_enable <= 1'b1;////
									busy_reverse <= 1'b0;
									svm_en <= 1'b0;
									feature_full_falg <= (features_num == num_dim)?0:1;//features_num+4 == 4
									x_one_reg <= data_one + data_two;//*0.5
									x_two_reg <= data_three + data_four;//*0.5
							end
							if(on_enable == 1'b1)
							begin
							   if(feature_full_falg == 0)
								begin
							   enable <= 1'b1;
								on_enable <= 1'b0;
								x_reg <= x_reg + ((x_one_reg + x_two_reg)>>1);
								end
								else begin
								on_enable <= 1'b0;
								features_num <= features_num + 4;
								feature_full_falg <= 1'b0; 
                        x_reg <= x_reg + ((x_one_reg + x_two_reg)>>1);								
								end
							end
							busy_e_flag <= busy_e;
							if(busy_e_flag && !busy_e)//
							begin
							   x_reg <= 0;
							   enable <= 1'b0;
								square_data <= out_k;///.
								square_cnt <= sum_cnt;///.
								square_sign <= 1'b1;///.
                           
							end
				 end
			 end
      end//always
/////////////////////////////////////////////////////div,mul
   exp_top exp_K(
		  
		  .clk(clk_svm),
		  .rst_n(rst_n),
		  .sum_a(x_reg),//input
		  .enable(enable),//input
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
		  .svm_enable(svm_enable),
		  .busy_one(busy_one),//output mul_one state
	     .data_one(data_one)//output result one
	 
	    );
   mul_two mul_two_data(
	     
		  .clk(clk_svm),
		  .rst_n(rst_n),
	     .mul_a(B_one),
		  .mul_b(B_two),//input mul_one result
		  .start(start_B),//input mul_one state
		  .svm_enable(svm_enable),
		  .busy_two(busy_two),//output mul_two state
	     .data_two(data_two)//output SUM one
	 
	   );
		
   mul_three mul_three_data(
	     
		  .clk(clk_svm),
		  .rst_n(rst_n),
	     .mul_a(C_one),
		  .mul_b(C_two),
		  .start(start_C),// start sign
		  .svm_enable(svm_enable),
		  .busy_three(busy_three),//output mul_three state
	     .data_three(data_three)//output result three
	 
	   );

   mul_four mul_four_data(
	     
		  .clk(clk_svm),
		  .rst_n(rst_n),
	     .mul_a(D_one),
		  .mul_b(D_two),
		  .start(start_D),// start sign
		  .svm_enable(svm_enable),
		  .busy_four(busy_four),//output mul_three state
	     .data_four(data_four)//output result three
	 
	   );

endmodule
