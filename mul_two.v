`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:46:24 12/04/2017 
// Design Name: 
// Module Name:    mul_two 
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
module mul_two(

       mul_a,
       mul_b,
       data_two,
	    svm_enable,
		 start,
		 busy_two,//
		 clk,
		 rst_n

    );

      parameter   MUL_WIDTH  = 17;
      parameter   MUL_RESULT = 34;//33
		
		input [MUL_WIDTH-1:0]   mul_a;   
      input [MUL_WIDTH-1:0]   mul_b; 
      input                   clk; 
      input                   rst_n;
      input start;
		input svm_enable;
      output reg busy_two;///////////////////////////////////////
	   reg busy;//////
      output reg [MUL_RESULT-3:0]  data_two;
		
		reg [MUL_RESULT-3:0]   mul_32_out;
		
      reg [MUL_RESULT-3:0]   mul_out; 
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

       reg [MUL_RESULT-2:0]   add0_0; 
		 reg [MUL_RESULT-2:0]   add0_1; 
		 reg [MUL_RESULT-2:0]   add0_2; 
		 reg [MUL_RESULT-2:0]   add0_3; 
		 reg [MUL_RESULT-2:0]   add0_4; 
		 reg [MUL_RESULT-2:0]   add0_5; 
		 reg [MUL_RESULT-2:0]   add0_6; 
		 reg [MUL_RESULT-2:0]   add0_7;
		 	
		 reg [MUL_RESULT-2:0]   add1_0; 
		 reg [MUL_RESULT-2:0]   add1_1; 
		 reg [MUL_RESULT-2:0]   add1_2; 
		 reg [MUL_RESULT-2:0]   add1_3;
		
		 reg [MUL_RESULT-2:0]   add2_0; 
		 reg [MUL_RESULT-2:0]   add2_1;
		 
		 reg [MUL_RESULT-1:0]   add3_0;
		
		 reg [7:0] mul_sub;/////////////////////////////
		
		always @ ( posedge clk or negedge rst_n ) 
      begin 
      if ( !rst_n ) 
       begin 
         mul_a_reg <= 17'b0;
         mul_b_reg <= 17'b0;
		 
		   stored0 <= 33'b0; 
			stored1 <= 33'b0; 
			stored2 <= 33'b0;    
			stored3 <= 33'b0; 
			stored4 <= 33'b0; 
			stored5 <= 33'b0;
			stored6 <= 33'b0; 
			stored7 <= 33'b0;
			stored8 <= 33'b0; 
			stored9 <= 33'b0; 
			stored10 <= 33'b0; 
			stored11 <= 33'b0; 
			stored12 <= 33'b0;  
			stored13 <= 33'b0;     
			stored14 <= 33'b0;  
			stored15 <= 33'b0;
		   stored16 <= 33'b0;	
				
		add0_0 <= 33'b0;  
		add0_1 <= 33'b0;    
		add0_2 <= 33'b0;    
		add0_3 <= 33'b0;
		add0_4 <= 33'b0; 
		add0_5 <= 33'b0;     
		add0_6 <= 33'b0;     
		add0_7 <= 33'b0;
      		
		add1_0 <= 33'b0; 
		add1_1 <= 33'b0;
		add1_2 <= 33'b0;
		add1_3 <= 33'b0; 
		
		add2_0 <= 33'b0; 
		add2_1 <= 33'b0;
      		
		add3_0 <= 33'b0;
		
		msb <= 1'b0; 
		msb_reg_0 <= 1'b0;
		msb_reg_1 <= 1'b0;
		msb_reg_2 <= 1'b0; 
		msb_reg_3 <= 1'b0; 
		mul_out_reg <= 34'b0;
		mul_out <= 32'b0;
      mul_32_out <= 32'b0;	
      data_two <= 32'b0;///////////////////////
		mul_sub <= 8'b0;
		busy_two <= 1'b1;
      busy <= 1'b1;	
     	
    end
		else //if(svm_enable == 1'b1)
		begin 
		if(start == 1'b1)
		begin  
			busy_two <= 1'b1;
			busy <= 1'b1;
			mul_sub <= mul_sub + 1;/////////////////////////////////////////////		
			mul_a_reg <= (mul_a[16]==0)?  mul_a : {1'b0,~mul_a[15:0]+1'b1};          
			mul_b_reg <= (mul_b[16]==0)?  mul_b : {1'b0,~mul_b[15:0]+1'b1};
			//mul_a_reg <= (mul_a[31]==0)?  mul_a : {mul_a[31],mul_a[30:0]};
			//mul_b_reg <= (mul_b[31]==0)?  mul_b : {mul_b[31],mul_b[30:0]};
			
			msb_reg_0 <= mul_a[16] ^ mul_b[16];//mul_a_reg[31] ^ mul_b_reg[31];
			msb_reg_1 <= msb_reg_0;         
			msb_reg_2 <= msb_reg_1;          
			msb_reg_3 <= msb_reg_2;         
			msb <= msb_reg_3;          
			stored0 <= mul_b_reg[0] ? {17'b0,mul_a_reg[15:0]}       : 33'b0;         
			stored1 <= mul_b_reg[1] ? {16'b0,mul_a_reg[15:0],1'b0}  : 33'b0;          
			stored2 <= mul_b_reg[2] ? {15'b0,mul_a_reg[15:0],2'b0}  : 33'b0;          
			stored3 <= mul_b_reg[3] ? {14'b0,mul_a_reg[15:0],3'b0}  : 33'b0;          
			stored4 <= mul_b_reg[4] ? {13'b0,mul_a_reg[15:0],4'b0}  : 33'b0;          
			stored5 <= mul_b_reg[5] ? {12'b0,mul_a_reg[15:0],5'b0}  : 33'b0;         
			stored6 <= mul_b_reg[6] ? {11'b0,mul_a_reg[15:0],6'b0}  : 33'b0;         
			stored7 <= mul_b_reg[7] ? {10'b0,mul_a_reg[15:0],7'b0}  : 33'b0;          
			stored8 <= mul_b_reg[8] ? {9'b0,mul_a_reg[15:0],8'b0}  : 33'b0;          
			stored9 <= mul_b_reg[9] ? {8'b0,mul_a_reg[15:0],9'b0}  : 33'b0;          
			stored10 <= mul_b_reg[10] ? {7'b0,mul_a_reg[15:0],10'b0}  : 33'b0;          
			stored11 <= mul_b_reg[11] ? {6'b0,mul_a_reg[15:0],11'b0}  : 33'b0;          
			stored12 <= mul_b_reg[12] ? {5'b0,mul_a_reg[15:0],12'b0}  : 33'b0;          
			stored13 <= mul_b_reg[13] ? {4'b0,mul_a_reg[15:0],13'b0}  : 33'b0;          
			stored14 <= mul_b_reg[14] ? {3'b0,mul_a_reg[15:0],14'b0}  : 33'b0;         
			stored15 <= mul_b_reg[15] ? {2'b0,mul_a_reg[15:0],15'b0}  : 33'b0; 
			stored16 <= mul_b_reg[16] ? {1'b0,mul_a_reg[15:0],16'b0}  : 33'b0; 
			
			add0_0 <= stored0 + stored1;        
			add0_1 <= stored2 + stored3;         
			add0_2 <= stored4 + stored5;        
			add0_3 <= stored6 + stored7;         
			add0_4 <= stored8 + stored9;          
			add0_5 <= stored10 + stored11;         
			add0_6 <= stored12 + stored13;      
			add0_7 <= stored14 + stored15;         
			add1_0 <= add0_0 + add0_1;         
			add1_1 <= add0_2 + add0_3;         
			add1_2 <= add0_4 + add0_5;      
			add1_3 <= add0_6 + add0_7;         
			add2_0 <= add1_0 + add1_1;         
			add2_1 <= add1_2 + add1_3;          
			add3_0 <= (add2_0 + add2_1) + stored16;
			
			//mul_out_reg <= {msb,add3_0[31:0]}; 
			mul_out_reg <= (add3_0==0)? 34'b0 : {msb,add3_0[32:0]};
			mul_32_out <= (mul_out_reg[33]==0)? ({16'b0,mul_out_reg[31:16]}) : (0-{16'b0,mul_out_reg[31:16]});	
			mul_out <= (mul_32_out[31:0] == 0)? 32'b0 : mul_32_out;	
			
			data_two <= mul_out;
			
			if(mul_sub >= 10)
				begin
					  busy <= 1'b0;
			        busy_two <= busy;
				end

			end
			else if(start == 1'b0)
			begin
				mul_sub <= 0;
			end
   end
end

		
		
endmodule
