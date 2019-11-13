`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:48:07 12/04/2017 
// Design Name: 
// Module Name:    div_cal 
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
module div_cal(
      
		clk,
		rst_n,
		div_a,
		div_b,
      enable,
		svm_enable,
		out_b,
      busy_div
		
    );
	   parameter IN_WIDTH = 32;
	   parameter OUT_WIDTH = 32;
	   
		output reg [OUT_WIDTH-1:0] out_b;//wire
	   output reg busy_div;
		input [31:0] div_a;
		input [31:0] div_b;
	   input clk;
	   input rst_n;
	   input enable;
		input svm_enable;
	   reg done;
	   reg [31:0] yshang;
		reg [31:0] yyushu;
		reg [31:0] tempa;  
		reg [31:0] tempb; 
		reg [63:0] temp_a;
		reg [63:0] temp_b;
	   reg [5:0] status;  
		parameter s_idle =  6'b000000;  
		parameter s_init =  6'b000001;  
		parameter s_calc1 = 6'b000010;  
		parameter s_calc2 = 6'b000100;  
		parameter s_done =  6'b001000;
		
		reg [31:0] ii; ////
      reg start;
		
	  reg [31:0] a;
	  reg [31:0] b;
     
	  reg [7:0] couter;
     reg [7:0] sub_result;
	  
	  reg [7:0] move;
	  reg [7:0] sub_reg;
	  
	  reg [7:0] count;
	  
	  
/*initial
begin
    busy_div <= 1'b1;///////////
	 couter <= 31;
	 count <= 31;////
	 sub_result <= 0;
	 move <= 0;
	 sub_reg <= 0;
	 start <= 1'b0;
	 ii <= 32'h0;  
    tempa <= 32'h1;  
    tempb <= 32'h1;  
    yshang <= 32'h1;
    	 
    yyushu <= 32'h1;  
    done <= 1'b0;  
    status <= s_idle;
end*/
	
/*always @(posedge clk)
begin
    // if(!rst_n)
	  //begin
	   //   busy_div <= 1'b1;///////////
		//	start <= 1'b0;
	  //end
     if(enable == 1'b1) 
	  begin
	  
	       start <= 1'b1;
			// busy_e <= 1'b1;
			 a <= div_a;
			 b <= div_b;
			 
	  end
end*/
	
always @(posedge clk or negedge rst_n)
	begin
		 if(!rst_n)  
        begin  
		       busy_div <= 1'b1;///////////
				 couter <= 31;
				 count <= 31;////
				 sub_result <= 0;
				 move <= 0;
				 sub_reg <= 0;
				 start <= 1'b0;
            ii <= 32'h0;  
            tempa <= 32'h1;  
            tempb <= 32'h1;  
            yshang <= 32'h1;  
            yyushu <= 32'h1;  
            done <= 1'b0;  
            status <= s_idle;
           				
        end  
    else  begin  
        if(svm_enable == 1'b1)
		  begin
            case (status)  
            s_idle:  
                begin  
                    if(enable)  
                        begin 
        							   if(couter >= 0)
										begin
											if(div_a[couter] == 1)
											begin
											sub_result <= 31 - couter;	  
											  
                                 sub_reg <= sub_result;
									      tempa <= div_a<<(31 - couter);  
                                 tempb <= div_b; 
									 
                                 done <= 1'b0;////////// 
                                 status <= s_init;
											  
										   end
										
									      else begin
											couter <= couter - 1;
											status <= s_idle;
											end
										end
												  
                         	
                        end  
                    else  
                        begin   
                            busy_div <= 1'b1;///////////
									 couter <= 31;
									 count <= 31;////
									 sub_result <= 0;
									 move <= 0;
									 sub_reg <= 0;
									 start <= 1'b0;
									 ii <= 32'h0;  
									 tempa <= 32'h1;  
									 tempb <= 32'h1;  
									 yshang <= 32'h1;
										 
									 yyushu <= 32'h1;  
									 done <= 1'b0;  
									 status <= s_idle;
                            out_b <= 0;////////////////////									 
                        end  
                end  
                  
            s_init:  
                begin  
                    temp_a = {32'h00000000,tempa};  
                    temp_b = {tempb,32'h00000000};  
                      
                    status <= s_calc1;  
                end  
                  
            s_calc1:  
                begin  
                    if(ii < 32)  
                        begin  
                            temp_a = {temp_a[62:0],1'b0};  
                              
                            status <= s_calc2;  
                        end  
                    else  
                        begin  
                            status <= s_done;  
                        end  
                      
                end  
                  
            s_calc2:  
                begin  
                    if(temp_a[63:32] >= tempb)  
                        begin  
                            temp_a = temp_a - temp_b + 1'b1;  
                        end  
                    else  
                        begin  
                            temp_a = temp_a;  
                        end  
                    ii <= ii + 1'b1;     
                    status <= s_calc1;  
                end  
              
            s_done:  
                begin  
                    yshang <= temp_a[31:0];//<<8;  
                    yyushu <= temp_a[63:32];
						  
						  //out_b <= yshang;
						  			  
                    //out_b <= {{16{1'b0}},temp_a[14:0],1'b0};						  
                    done <= 1'b1;  
                   							 
                    status <= (enable == 1)?(s_done):(s_idle);//s_idle;
						 // busy_div <= 1'b0;///////////
                    start <= 1'b1;
						  if(start == 1'b1)
			           begin
							  if(count >= 0)
							  begin
									if(div_a[count] == 1)
									begin
					
									if(count >= 15)
									begin
									move <= count - 15;
									out_b <= yshang<<(count - 15);
									busy_div <= (enable == 1)?(1'b0):(1'b1);


									end
									else if(count <15)
									begin
									move <= 15 - count;
									out_b <= yshang>>(15 - count);
									busy_div <= (enable == 1)?(1'b0):(1'b1);


									end
														  
															
							  end
													
							  else begin
							  count <= count - 1;
														
							  end
							end
					   end
						  //busy_e <= 1'b0;//state
                    //if(enable == 1'b1)//xunhuan input start
                    // begin
                    // status <= s_idle;
                    // end							
                end  
              
            default:  
                begin  
                    status <= s_idle;  
                end  
            endcase  
        end  
     end
end  
  
	 
	/* div divider(
      
       .rst(rst_n),
       .clk(clk),
       .start(start),
       .a(32'b00000000000001000000000000000000),
		 .b(32'b00000000000000100000000000000000),
		 .yshang(exp_b),
		 .yyushu(yyushu),
		 .calc_done(calc_done)
		 
      ); */ 
	  
endmodule

