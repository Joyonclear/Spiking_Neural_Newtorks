// This file is public domain, it can be freely copied without restrictions.
// SPDX-License-Identifier: CC0-1.0

`timescale 1us/1us

module incre (
  input clk,
  input [3:0] add,
  input [3:0] add2,
  output reg[3:0] out
);

always @(posedge clk) begin
  out <= add + add2;
end

endmodule
