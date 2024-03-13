`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 02:20:17 PM
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
//module flexible_clock(input CLOCK, output reg sec_clock = 0);
//reg [31:0]count = 0;
//reg var = 0;

//always @(posedge CLOCK) begin
//count <= (count == 7) ? 0 : count + 1;
//sec_clock <= (count == 0) ? ~sec_clock : sec_clock;
//end

//endmodule

module flexible_clock(input CLOCK, input [31:0] m, output reg sec_clock = 0);
reg [31:0]count = 0;
reg var = 0;

always @(posedge CLOCK) begin
count <= (count == m) ? 0 : count + 1;
sec_clock <= (count == 0) ? ~sec_clock : sec_clock;
end

endmodule
