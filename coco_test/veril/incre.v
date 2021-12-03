// This file is public domain, it can be freely copied without restrictions.
// SPDX-License-Identifier: CC0-1.0

`timescale 1us/1us
// 인풋이 0인지 아닌지 구별한 다음 이것에 따라 어떤 숫자를 0또는 원본으로 구별하고 싶다
module incre (
  input clk,
  input [3:0] add,
  input [3:0] add2,
  output reg[3:0] out,
  output reg out1
);

always @(posedge clk) begin
	if( add !=0 ) begin
		out1 <= 1;
	end else begin
		out1 <= 0;
	end
end

assign out = add2 & out1;

endmodule
