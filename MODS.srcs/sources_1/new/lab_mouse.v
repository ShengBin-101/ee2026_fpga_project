`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 02:27:08 PM
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
input CLOCK, output [15:0] led, inout PS2Data, inout PS2Clk
);
reg [11:0] value = 0;
wire [11:0] xpos = 0;
wire [11:0] ypos = 0;
wire [3:0] zpos = 0;
reg setx = 0;
reg sety = 0;
reg setmax_x = 0;
reg setmax_y = 0;
wire left, middle, right, new_event;


//mouse_data ;
MouseCtl mouse_lab(.clk(CLOCK), .rst(0), .value(value), .setx(setx),
  .sety(sety), .setmax_x(setmax_x), .setmax_y(setmax_y), .xpos(xpos), .ypos(ypos), .zpos(zpos),
  .left(left), .middle(middle), .right(right), .new_event(new_event), .ps2_clk(PS2Clk), .ps2_data(PS2Data)); 
  
  assign led[15] = left;
  assign led[14] = middle;
  assign led[13] = right;
  
endmodule
