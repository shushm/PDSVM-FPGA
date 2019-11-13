`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:45:05 10/28/2017 
// Design Name: 
// Module Name:    clkdiv 
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
module clkdiv(clk50, reset, clkout);
input clk50;              //系统时钟
output clkout;          //采样时钟输出
input reset;

reg clkout;
reg [15:0] cnt;
integer fifo=0;

initial
begin
    clkout <= 1'b0;
end

always @(posedge clk50 )   //分频进程
begin

  if(fifo < 100)
  begin
  fifo <= fifo+1;
  cnt <= 16'd0;
  clkout <= 1'b0;
  end
  else if(fifo >= 100)
  begin
  /*if(reset)
  begin
  cnt <= 16'd0;
  end
  else begin*/
  if(cnt >= 16'd162 && cnt <=16'd324)//325
  begin
    clkout <= 1'b1;
    cnt <= cnt + 16'd1;
  end
  else if(cnt > 16'd324)//325
  begin
    clkout <= 1'b0;
    cnt <= 16'd0;
  end
  else
  begin
    cnt <= cnt + 16'd1;
	 clkout <= 1'b0;
  end
// end
  end
end
endmodule
