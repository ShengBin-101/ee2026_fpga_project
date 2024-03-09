`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 10:07:55 PM
// Design Name: 
// Module Name: task_d
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

module task_d(
    input basys_clk,
    input btnC,
    input btnL,
    input btnU,
    input btnR,
    input [12:0] pixel_index,
    output [15:0] oled_data
    );
    
    wire [6:0] square_top_bound, square_bottom_bound, square_left_bound, square_right_bound; 
    square_controls (square_top_bound, square_bottom_bound, square_left_bound, square_right_bound);

    wire [7:0] x;
    wire [6:0] y;
    index_to_xy convert_module(pixel_index, x, y);
    
    wire [15:0] oled_blue;
    draw_box(x, y, `BLUE, `BLACK, square_top_bound, square_bottom_bound, square_left_bound, square_right_bound, oled_blue);
    assign oled_data = oled_blue;
endmodule

module square_controls (
    output reg [6:0] square_top_bound = 0, square_bottom_bound = 4, square_left_bound = 0, square_right_bound = 4
    );

endmodule

module draw_box (
    input [7:0] x,
    input [6:0] y,
    input [15:0] main_col, bg_col,
    input [6:0] square_top_bound, square_bottom_bound, square_left_bound, square_right_bound,
    output [15:0] oled_data
    );
    assign oled_data = (x >= square_left_bound && x <= square_right_bound && y <= square_bottom_bound && y >= square_top_bound)
            ? main_col : bg_col;
endmodule