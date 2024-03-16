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
    input [4:0] SW_reset,   // Switches to check if task_d is selected
    input SW0,              // Switch to vary box speed
    input btnC,             // set signal to set start to 1
    input btnL,             // left movement
    input btnU,             // up movement
    input btnR,             // right movement
    input [12:0] pixel_index,
    output [15:0] oled_data
    );
    
    // =========== Clocks ==================
    wire clk_1000;   //1000 Hz Clock Signal to update button, updates every 1 millisecond
    wire clk_45;    // 45 Hz, for box speed
    wire clk_30;    // 30 Hz, for box speed
    wire clk_15;    // 15 Hz, for box speed
    
    flexible_clock_module clk_1000_module(basys_clk, 49999 ,clk_1000);
    flexible_clock_module clk_45_module(basys_clk, 1111110 ,clk_45);
    flexible_clock_module clk_30_module(basys_clk, 1666666 ,clk_30);
    flexible_clock_module clk_15_module(basys_clk, 3333332 ,clk_15);
    
    wire speed_clk; // 45 or 30 or 15 Hz Clock Signal depending on SW0 and movement
    speed_select speed_select_module(basys_clk, SW0, clk_45, clk_30, clk_15, move, speed_clk);
    
    // ======== Active/Reset Logic =============
    wire active;    // active == 1 means we have selected task d to run, active == 0 means 
    reset_logic reset_logic_module(.clock(basys_clk), .SW_reset(SW_reset), .active(active));
    
    // ======== Update State and Movement of Box =========
    wire start, center; // Start determines if box is blue or white, center determines if box is centered or moving
    wire [1:0] move;    
    // 2'b00 = don't care,
    // 2'b01 = left movement,  
    // 2'b11 = right movement,  
    // 2'b10 = up movement, 
    
    button_controls button_control_module(.clock(clk_1000), .btnC(btnC), .btnU(btnU), .btnL(btnL), .btnR(btnR), .active(active), .start(start), .center(center), .move(move));
    square_controls square_control_module(speed_clk, start, center, move, square_top_bound, square_bottom_bound, square_left_bound, square_right_bound);

    // ========== Draw Pixels ===================
    // x = x-coordinate of current pixel
    // y = y-coordinate of current pixel
    // square_top_bound     = y axis of top edge
    // square_bottom_bound  = y axis of bottom edge
    // square_left_bound    = x axis of left edge
    // square_right_bound   = x axis of right edge
    wire [7:0] x;
    wire [6:0] y;
    wire [6:0] square_top_bound, square_bottom_bound, square_left_bound, square_right_bound; 
    
    // module to update x and y based on current pixel_index
    index_to_xy convert_module(pixel_index, x, y); 
    
    // outputs updated pixel value for current pixel
    draw_box draw_box_module(start, x, y, `BLUE, `WHITE, `BLACK, square_top_bound, square_bottom_bound, square_left_bound, square_right_bound, oled_data);

endmodule

module reset_logic(input clock, input [4:0] SW_reset, output reg active);
    always @ (posedge clock) begin
        if ((SW_reset[4:0] >= 5'b01000) && (SW_reset[4:0] < 5'b10000)) begin
            active <= 1;
        end
        else begin
            active <= 0;
        end   
    end
endmodule

// multiplexer to select clk signal for box movement speed
module speed_select (input basys_clk, SW0, clk_45, clk_30, clk_15, [1:0] move, output reg speed_clk);
    always @ (posedge basys_clk) begin
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
// start is a flag to indicate blue/white box (0 for blue, 1 for white)
module button_controls (
    input clock, btnC, btnU, btnL, btnR, active,
    output reg start, reg center, reg [1:0] move
    );
    // TODO: Debounce???
    // if task_d selected using switches, active flag will be turned on
    
    always @ (posedge clock) begin
            if (active == 1 && start == 0) begin
                start <= (btnC == 1) ? 1 : start;
                center <= (btnC == 1) ? 1 : center;
            end
            else if (active == 1 && start == 1) begin
                center <= (btnC == 1) ? 1 : (btnL == 1 || btnR == 1 | btnU == 1) ? 0 : center;
                move <= (btnC == 1) ? 0 : (btnU == 1) ? 2'b10 : (btnL == 1) ? 2'b01 : (btnR == 1) ? 2'b11 : move;
            end
            else if (active == 0) begin
                start <= 0;
                center <= 0;
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