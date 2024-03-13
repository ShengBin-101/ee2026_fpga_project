`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2024 14:45:07
// Design Name: 
// Module Name: flexible_clock
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flexible_clock(input bassys_clock, input [31:0] m, output reg my_clk = 0);


reg [31:0] count = 32'd 0;

always @ (posedge bassys_clock)
begin

count <= (count == m) ? 0 : count + 1;
my_clk <= (count == 0) ? ~ my_clk : my_clk;

end

endmodule

