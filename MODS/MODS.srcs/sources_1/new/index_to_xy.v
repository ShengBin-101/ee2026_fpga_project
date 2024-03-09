`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 10:12:34 PM
// Design Name: 
// Module Name: index_to_xy
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

/**
* This is to turn the pixel index into X and Y coordinates 
*/
module index_to_xy(
    input [12:0] pixel_index,
    output [7:0] x,
    output [6:0] y
    );
    assign x = pixel_index % `WIDTH;
    assign y = pixel_index / `WIDTH;
    
endmodule
