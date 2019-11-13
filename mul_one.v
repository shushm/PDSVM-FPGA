`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:44:53 12/04/2017 
// Design Name: 
// Module Name:    mul_one 
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
module mul_one(
       
		 clk,
		 rst_n,
		 mul_a,
		 mul_b,
		 start,
	    svm_enable,
		 busy_one,
		 data_one

    );

       input clk;
		 input rst_n;
		// input [31:0] in_x;
		// input [31:0] in_y;
		 input start;
		 input svm_enable;
		 output reg busy_one;
		 output reg [31:0] data_one;
		 
      
		parameter   MUL_WIDTH  = 32;
      parameter   MUL_RESULT = 64;//33
		
		input [MUL_WIDTH-1:0]   mul_a;   
      input [MUL_WIDTH-1:0]   mul_b; 
     
      
      reg busy;///////////////////////////////////////
		
		reg [MUL_WIDTH-1:0]   mul_32_out;///////////////////
      //output [MUL_RESULT-1:0]   mul_out;
		//reg [MUL_WIDTH-1:0]   mul_32_out;
		
      reg [MUL_RESULT-1:0]   mul_out; 
		reg [MUL_RESULT-1:0]   mul_out_reg;  
		reg                    msb; 
		reg                    msb_reg_0; 
		reg                     msb_reg_1; 
		reg                    msb_reg_2; 
		reg                    msb_reg_3; 
		reg [MUL_WIDTH-1:0]   mul_a_reg;
		reg [MUL_WIDTH-1:0]   mul_b_reg;

      reg [MUL_RESULT-2:0]   stored0;
		reg [MUL_RESULT-2:0]   stored1; 
		 reg [MUL_RESULT-2:0]   stored2; 
		 reg [MUL_RESULT-2:0]   stored3; 
		 reg [MUL_RESULT-2:0]   stored4; 
		 reg [MUL_RESULT-2:0]   stored5; 
		 reg [MUL_RESULT-2:0]   stored6; 
		 reg [MUL_RESULT-2:0]   stored7;
		 reg [MUL_RESULT-2:0]   stored8; 
		 reg [MUL_RESULT-2:0]   stored9;
		 reg [MUL_RESULT-2:0]   stored10; 
		 reg [MUL_RESULT-2:0]   stored11; 
		 reg [MUL_RESULT-2:0]   stored12; 
		 reg [MUL_RESULT-2:0]   stored13; 
		 reg [MUL_RESULT-2:0]   stored14; 
		 reg [MUL_RESULT-2:0]   stored15;
       reg [MUL_RESULT-2:0]   stored16;
		 reg [MUL_RESULT-2:0]   stored17;
		 reg [MUL_RESULT-2:0]   stored18;
		 reg [MUL_RESULT-2:0]   stored19;
		 reg [MUL_RESULT-2:0]   stored20;
		 reg [MUL_RESULT-2:0]   stored21;
		 reg [MUL_RESULT-2:0]   stored22;
		 reg [MUL_RESULT-2:0]   stored23;
		 reg [MUL_RESULT-2:0]   stored24;
		 reg [MUL_RESULT-2:0]   stored25;
		 reg [MUL_RESULT-2:0]   stored26;
		 reg [MUL_RESULT-2:0]   stored27;
		 reg [MUL_RESULT-2:0]   stored28;
		 reg [MUL_RESULT-2:0]   stored29;
       reg [MUL_RESULT-2:0]   stored30;
		 reg [MUL_RESULT-2:0]   stored31;

       reg [MUL_RESULT-2:0]   add0_0; 
		 reg [MUL_RESULT-2:0]   add0_1; 
		reg [MUL_RESULT-2:0]   add0_2; 
		 reg [MUL_RESULT-2:0]   add0_3; 
		 reg [MUL_RESULT-2:0]   add0_4; 
		 reg [MUL_RESULT-2:0]   add0_5; 
		 reg [MUL_RESULT-2:0]   add0_6; 
		reg [MUL_RESULT-2:0]   add0_7;
       reg [MUL_RESULT-2:0]   add0_8;
       reg [MUL_RESULT-2:0]   add0_9;
       reg [MUL_RESULT-2:0]   add0_10;
       reg [MUL_RESULT-2:0]   add0_11;
       reg [MUL_RESULT-2:0]   add0_12;
		 reg [MUL_RESULT-2:0]   add0_13;
		 reg [MUL_RESULT-2:0]   add0_14;
		 reg [MUL_RESULT-2:0]   add0_15;
		 	
		 reg [MUL_RESULT-2:0]   add1_0; 
		 reg [MUL_RESULT-2:0]   add1_1; 
		reg [MUL_RESULT-2:0]   add1_2; 
		reg [MUL_RESULT-2:0]   add1_3;
      reg [MUL_RESULT-2:0]   add1_4;
      reg [MUL_RESULT-2:0]   add1_5;
      reg [MUL_RESULT-2:0]   add1_6;
      reg [MUL_RESULT-2:0]   add1_7;
		
		 reg [MUL_RESULT-2:0]   add2_0; 
		 reg [MUL_RESULT-2:0]   add2_1;
		 reg [MUL_RESULT-2:0]   add2_2;	 
		 reg [MUL_RESULT-2:0]   add2_3;
		 
		 reg [MUL_RESULT-1:0]   add3_0;
		 reg [MUL_RESULT-1:0]   add3_1;
		
		reg [MUL_RESULT-1:0]   add4_0;
		
		reg [MUL_WIDTH-1:0] mul_sub;///////////////////
	
	
	always @ ( posedge clk or negedge rst_n ) 
      begin 
      if ( !rst_n ) 
       begin 
         mul_a_reg <= 32'b0;
         mul_b_reg <= 32'b0;
		 
		   stored0 <= 63'b0; 
			stored1 <= 63'b0; 
			stored2 <= 63'b0;    
			stored3 <= 63'b0; 
			stored4 <= 63'b0; 
			stored5 <= 63'b0;
			stored6 <= 63'b0; 
			stored7 <= 63'b0;
			stored8 <= 63'b0; 
			stored9 <= 63'b0; 
			stored10 <= 63'b0; 
			stored11 <= 63'b0; 
			stored12 <= 63'b0;  
			stored13 <= 63'b0;     
			stored14 <= 63'b0;  
			stored15 <= 63'b0;
		   stored16 <= 63'b0;
			stored17 <= 63'b0;
			stored18 <= 63'b0;
			stored19 <= 63'b0;
			stored20 <= 63'b0;
			stored21 <= 63'b0;
			stored22 <= 63'b0;
			stored23 <= 63'b0;
			stored24 <= 63'b0;
			stored25 <= 63'b0;
			stored26 <= 63'b0;
			stored27 <= 63'b0;
			stored28 <= 63'b0;
			stored29 <= 63'b0;
			stored30 <= 63'b0;
			stored31 <= 63'b0;
				
		add0_0 <= 63'b0;  
		add0_1 <= 63'b0;    
		add0_2 <= 63'b0;    
		add0_3 <= 63'b0;
		add0_4 <= 63'b0; 
		add0_5 <= 63'b0;     
		add0_6 <= 63'b0;     
		add0_7 <= 63'b0;
      add0_8 <= 63'b0;
		add0_9 <= 63'b0;
		add0_10 <= 63'b0;
		add0_11 <= 63'b0;
		add0_12 <= 63'b0;
		add0_13 <= 63'b0;
      add0_14 <= 63'b0;
		add0_15 <= 63'b0;
      		
		add1_0 <= 63'b0; 
		add1_1 <= 63'b0;
		add1_2 <= 63'b0;
		add1_3 <= 63'b0; 
		add1_4 <= 63'b0;
		add1_5 <= 63'b0;
		add1_6<= 63'b0;
		add1_7 <= 63'b0;
		
		add2_0 <= 63'b0; 
		add2_1 <= 63'b0;
      add2_2 <= 63'b0;
		add2_3 <= 63'b0;
      		
		add3_0 <= 63'b0;
		add3_1 <= 63'b0;
		
		add4_0 <= 63'b0;
		
		msb <= 1'b0; 
		msb_reg_0 <= 1'b0;
		msb_reg_1 <= 1'b0;
		msb_reg_2 <= 1'b0; 
		msb_reg_3 <= 1'b0; 
		mul_out_reg <= 64'b0;
		mul_out <= 64'b0;
      mul_32_out <= 32'b0;	
      data_one <= 32'b0;///////////////////////
		mul_sub <= 32'b0;
		busy_one <= 1'b1;
      busy <= 1'b1;		
    end
	 else //if(svm_enable == 1'b1)
	 begin
		if(start == 1'b1)
		begin   
      
		busy_one <= 1'b1;
      busy <= 1'b1;	
      mul_sub <= mul_sub + 1;/////////////////////////////////////////////			
		mul_a_reg <= (mul_a[31]==0)?  mul_a : {1'b0,~mul_a[30:0]+1'b1};          
		mul_b_reg <= (mul_b[31]==0)?  mul_b : {1'b0,~mul_b[30:0]+1'b1};
      //mul_a_reg <= (mul_a[31]==0)?  mul_a : {mul_a[31],mul_a[30:0]};
		//mul_b_reg <= (mul_b[31]==0)?  mul_b : {mul_b[31],mul_b[30:0]};
		
		msb_reg_0 <= mul_a[31] ^ mul_b[31];
		msb_reg_1 <= msb_reg_0;         
		msb_reg_2 <= msb_reg_1;          
		msb_reg_3 <= msb_reg_2;         
		msb <= msb_reg_3;          
		stored0 <= mul_b_reg[0] ? {32'b0,mul_a_reg[30:0]}       : 63'b0;         
		stored1 <= mul_b_reg[1] ? {31'b0,mul_a_reg[30:0],1'b0}  : 63'b0;          
		stored2 <= mul_b_reg[2] ? {30'b0,mul_a_reg[30:0],2'b0}  : 63'b0;          
		stored3 <= mul_b_reg[3] ? {29'b0,mul_a_reg[30:0],3'b0}  : 63'b0;          
		stored4 <= mul_b_reg[4] ? {28'b0,mul_a_reg[30:0],4'b0}  : 63'b0;          
		stored5 <= mul_b_reg[5] ? {27'b0,mul_a_reg[30:0],5'b0}  : 63'b0;         
		stored6 <= mul_b_reg[6] ? {26'b0,mul_a_reg[30:0],6'b0}  : 63'b0;         
		stored7 <= mul_b_reg[7] ? {25'b0,mul_a_reg[30:0],7'b0}  : 63'b0;          
		stored8 <= mul_b_reg[8] ? {24'b0,mul_a_reg[30:0],8'b0}  : 63'b0;          
		stored9 <= mul_b_reg[9] ? {23'b0,mul_a_reg[30:0],9'b0}  : 63'b0;          
		stored10 <= mul_b_reg[10] ? {22'b0,mul_a_reg[30:0],10'b0}  : 63'b0;          
		stored11 <= mul_b_reg[11] ? {21'b0,mul_a_reg[30:0],11'b0}  : 63'b0;          
		stored12 <= mul_b_reg[12] ? {20'b0,mul_a_reg[30:0],12'b0}  : 63'b0;          
		stored13 <= mul_b_reg[13] ? {19'b0,mul_a_reg[30:0],13'b0}  : 63'b0;          
		stored14 <= mul_b_reg[14] ? {18'b0,mul_a_reg[30:0],14'b0}  : 63'b0;         
		stored15 <= mul_b_reg[15] ? {17'b0,mul_a_reg[30:0],15'b0}  : 63'b0; 
		stored16 <= mul_b_reg[16] ? {16'b0,mul_a_reg[30:0],16'b0}  : 63'b0; 
		stored17 <= mul_b_reg[17] ? {15'b0,mul_a_reg[30:0],17'b0}  : 63'b0;
		stored18 <= mul_b_reg[18] ? {14'b0,mul_a_reg[30:0],18'b0}  : 63'b0;
		stored19 <= mul_b_reg[19] ? {13'b0,mul_a_reg[30:0],19'b0}  : 63'b0;
		stored20 <= mul_b_reg[20] ? {12'b0,mul_a_reg[30:0],20'b0}  : 63'b0;
		stored21 <= mul_b_reg[21] ? {11'b0,mul_a_reg[30:0],21'b0}  : 63'b0;
		stored22 <= mul_b_reg[22] ? {10'b0,mul_a_reg[30:0],22'b0}  : 63'b0;
		stored23 <= mul_b_reg[23] ? {9'b0,mul_a_reg[30:0],23'b0}  : 63'b0;
		stored24 <= mul_b_reg[24] ? {8'b0,mul_a_reg[30:0],24'b0}  : 63'b0;
		stored25 <= mul_b_reg[25] ? {7'b0,mul_a_reg[30:0],25'b0}  : 63'b0;
		stored26 <= mul_b_reg[26] ? {6'b0,mul_a_reg[30:0],26'b0}  : 63'b0;
		stored27 <= mul_b_reg[27] ? {5'b0,mul_a_reg[30:0],27'b0}  : 63'b0;
		stored28 <= mul_b_reg[28] ? {4'b0,mul_a_reg[30:0],28'b0}  : 63'b0;
		stored29 <= mul_b_reg[29] ? {3'b0,mul_a_reg[30:0],29'b0}  : 63'b0;
		stored30 <= mul_b_reg[30] ? {2'b0,mul_a_reg[30:0],30'b0}  : 63'b0;
		stored31 <= mul_b_reg[31] ? {1'b0,mul_a_reg[30:0],31'b0}  : 63'b0;
		
		
		add0_0 <= stored0 + stored1;        
		add0_1 <= stored2 + stored3;         
		add0_2 <= stored4 + stored5;        
		add0_3 <= stored6 + stored7;         
		add0_4 <= stored8 + stored9;          
		add0_5 <= stored10 + stored11;         
		add0_6 <= stored12 + stored13;      
		add0_7 <= stored14 + stored15;
		add0_8 <= stored16 + stored17;
		add0_9 <= stored18 + stored19;
		add0_10 <= stored20 + stored21;
		add0_11 <= stored22 + stored23;
		add0_12 <= stored24 + stored25;
		add0_13 <= stored26 + stored27;
		add0_14 <= stored28 + stored29;
		add0_15 <= stored30 + stored31;
		
		add1_0 <= add0_0 + add0_1;         
		add1_1 <= add0_2 + add0_3;         
		add1_2 <= add0_4 + add0_5;      
		add1_3 <= add0_6 + add0_7;
      add1_4 <= add0_8 + add0_9;
      add1_5 <= add0_10 + add0_11;
      add1_6 <= add0_12 + add0_13;
      add1_7 <= add0_14 + add0_15;
		
		add2_0 <= add1_0 + add1_1;         
		add2_1 <= add1_2 + add1_3;
      add2_2 <= add1_4 + add1_5;
		add2_3 <= add1_6 + add1_7;
		
		add3_0 <= add2_0 + add2_1; 
      add3_1 <= add2_2 + add2_3;
		
	   add4_0 <= add3_0 + add3_1;
		
		//mul_out_reg <= {msb,add3_0[31:0]}; 
      mul_out_reg <= (add4_0==0)? 64'b0 : {msb,add4_0[62:0]};		
		mul_out <= (mul_out_reg==0)? 64'b0 : (mul_out_reg[63]==0)? mul_out_reg : {mul_out_reg[63],mul_out_reg[62:0]}; //~mul_out_reg[62:0]+1'b1    
		
      data_one <= (mul_out[63] == 0)?{mul_out[63],mul_out[46:16]}:(((~mul_out[46:16]+1'b1)== 0)?(32'hffffffff):{mul_out[63],~mul_out[46:16]+1'b1});	
		//data_one <= mul_32_out;
		
		//busy_one <= 1'b0;
		if(mul_sub >= 10)
			begin
			busy <= 1'b0;
			busy_one <= busy;
			end
			
		end
		else if(start == 1'b0)
		begin
		   mul_sub <= 0;
		end
	end
end
		 

endmodule
