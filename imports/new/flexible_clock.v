`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2024 04:44:11 PM
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


module flexible_clock(
input clock,
input [31:0] m,

output reg state = 0
    );
    reg [31:0] count = 0;
    
    always @(posedge clock) begin
    
        if (count >= m)
        begin
            count <= 0;
            state <= ~state;
        end
        else
        begin
            count <= count + 1;
        end
    end
    
endmodule