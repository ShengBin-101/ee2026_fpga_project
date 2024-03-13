`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 02:30:01 PM
// Design Name: 
// Module Name: lab_mouse
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


module lab_mouse(
input clk,

output [15:13] led ,

inout PS2Clk,
inout PS2Data
    );
    
    reg [11:0] value = 0;
    reg setx = 0;
    reg sety = 0;
    reg setmax_x = 96;
    reg setmax_y = 64;
    wire [11:0] xpos;
    wire [11:0] ypos;
    wire [3:0] zpos;
    wire left;
    wire middle;
    wire right;
    wire new_event;


    
    MouseCtl mouse_control(.clk(clk), .rst(0), .value(value), .setx(setx), .sety(sety), .xpos(xpos), .ypos(ypos), .zpos(zpos), .left(left), .middle(middle), .right(right), .new_event(new_event),
                           .ps2_clk(PS2Clk), .ps2_data(PS2Data));
                           
    assign led[15] = left;
    assign led[14] = middle;
    assign led[13] = right;
    
endmodule
