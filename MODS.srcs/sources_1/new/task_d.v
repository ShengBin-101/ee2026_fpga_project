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

// HAVEN'T IMPLEMENT RESET FOR TASK E YET

module task_d(
    input basys_clk,
    input SW0,
    input btnC, // set signal to set start to 1
    input btnL, // left movement
    input btnU, // up movement
    input btnR, // right movement
    input btnD, // rst signal for button controls
    input [12:0] pixel_index,
    output [15:0] oled_data
    );
    
    wire clk_45;    // 45 Hz
    wire clk_30;    // 30 Hz
    wire clk_15;    // 15 Hz
    
    flexible_clock_module clk_45_module(basys_clk, 1111110 ,clk_45);
    flexible_clock_module clk_30_module(basys_clk, 1666666 ,clk_30);
    flexible_clock_module clk_15_module(basys_clk, 3333332 ,clk_15);
    
    wire speed_clk; // 45 or 30 or 15 Hz Clock Signal depending on SW0 and movement
    speed_select (SW0, clk_45, clk_30, clk_15, move, speed_clk);
    
//    wire clk_25m;   //25M Hz Clock Signal to update button
//    flexible_clock_module clk_25m_module(basys_clk, 1 ,clk_25m);
    
    wire clk_1000;   //1000 Hz Clock Signal to update button, updates every 1 millisecond
    flexible_clock_module clk_1000_module(basys_clk, 49999 ,clk_1000);
    // square_top_bound     = y axis of top edge
    // square_bottom_bound  = y axis of bottom edge
    // square_left_bound    = x axis of left edge
    // square_right_bound   = x axis of right edge
    wire [6:0] square_top_bound, square_bottom_bound, square_left_bound, square_right_bound; 
    
    wire start, center;
    wire [1:0] move;    
    // 2'b01 = left movement,  
    // 2'b11 = right movement,  
    // 2'b10 = up movement, 
    
    button_controls (.clock(clk_1000), .btnC(btnC), .btnU(btnU), .btnL(btnL), .btnR(btnR), .rst(btnD), .start(start), .center(center), .move(move));
    square_controls (speed_clk, start, center, move, square_top_bound, square_bottom_bound, square_left_bound, square_right_bound);

    // x = x-coordinate of current pixel
    // y = y-coordinate of current pixel
    wire [7:0] x;
    wire [6:0] y;
    
    index_to_xy convert_module(pixel_index, x, y); // module to update x and y based on current pixel_index
    
    // wire [15:0] oled_;
    // outputs updated pixel value for current pixel
    draw_box(start, x, y, `BLUE, `WHITE, `BLACK, square_top_bound, square_bottom_bound, square_left_bound, square_right_bound, oled_data);

endmodule

    // multiplexer to select clk signal for box movement speed
module speed_select (input SW0, clk_45, clk_30, clk_15, [1:0] move, output reg speed_clk);
    always @ (SW0) begin
        if (SW0 == 0) begin
            speed_clk <= clk_45;
        end
        else if (move == 2'b10) begin
            speed_clk <= clk_15;
        end
        else begin
            speed_clk <= clk_30;
        end
    end
endmodule

// **************
// button_controls module updates state based on buttons pressed
module button_controls (
    input clock, btnC, btnU, btnL, btnR, rst,
    output reg start, reg center, reg [1:0] move
    );
    // TODO: Debounce???
    
    always @ (posedge clock, posedge rst) begin
        if (rst == 1) begin
            start <= 0;
            center <= 0;
        end 
        else if (start == 0) begin
            // if user havent pressed btnC, listen for btnC, once btnC pressed, set start and center to 1
            start <= (btnC == 1) ? 1 : start;
            center <= (btnC == 1) ? 1 : center;
        end
        else begin
            // start == 1, update move based on btnX that is pressed 
            center <= (btnC == 1) ? 1 : (btnL == 1 || btnR == 1 | btnU == 1) ? 0 : center;
            move <= (btnC == 1) ? 0 : (btnU == 1) ? 2'b10 : (btnL == 1) ? 2'b01 : (btnR == 1) ? 2'b11 : move;
        end
    end
    
    
    
endmodule

// **************
// square_controls module modifies the bounds of the square, allowing translation of the square box 
module square_controls ( input clock, start, center, [1:0] move,
    output reg [6:0] square_top_bound, square_bottom_bound, square_left_bound, square_right_bound
    );
    
    always @ (posedge clock) begin
        if (start == 0) begin
            square_top_bound <= 0;
            square_bottom_bound <= 4;
            square_left_bound <= 0;
            square_right_bound <= 4;
        end
        else begin
            if (center == 1) begin
            square_top_bound <= 59;
            square_bottom_bound <= 63;
            square_left_bound <= 46;
            square_right_bound <= 50;
            end
            else begin
                if (move == 2'b01 && square_left_bound > 0) begin
                    square_left_bound <= square_left_bound - 1;
                    square_right_bound <= square_right_bound - 1;
                end
                else if (move == 2'b11 && square_right_bound < 95) begin
                    square_left_bound <= square_left_bound + 1;
                    square_right_bound <= square_right_bound + 1;
                end
                else if (move == 2'b10 && square_top_bound > 0) begin
                    square_top_bound <= square_top_bound - 1;
                    square_bottom_bound <= square_bottom_bound - 1;
                end
            end
        end
    end

endmodule

// **************
// draw_box module looks at current x and y coordinates of current pixel, compares it with the bounds
// if within bounds of square, draw box's main colour (main_col)
// if not within bounds of square, draw background colour (bg_col)
module draw_box (
    input start,
    input [7:0] x,
    input [6:0] y,
    input [15:0] blue_col, white_col, bg_col,
    input [6:0] square_top_bound, square_bottom_bound, square_left_bound, square_right_bound,
    output [15:0] oled_data
    );
    
    assign oled_data = (x >= square_left_bound && x <= square_right_bound && y <= square_bottom_bound && y >= square_top_bound)
            ? (start ? white_col : blue_col ) : bg_col;
endmodule