`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 03:57:33 PM
// Design Name: 
// Module Name: task_e
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
`include "constants.vh"
// === Group Basic Task === (Task E)
module task_e(
    input basys_clk,
    input [15:0] SW, 
    input btnC,
    inout PS2Clk,
    inout PS2Data,
    output [7:0] JC,
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp,
    output [15:0] oled_data
    );
    
    assign oled_data = `ORANGE;
    
    
    
    
endmodule
