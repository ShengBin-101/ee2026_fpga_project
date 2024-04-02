`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 07:23:51 PM
// Design Name: 
// Module Name: password_phase
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


// module password_phase allows the board to change password value of the board itself
module password_phase(
            input game_state,
            input basys_clk, 
            input clk_200, 
            input clk_1,
            input btnL, btnR, btnU, btnD, btnC,
            input [1:0] board_type,
            input [12:0] pixel_index,
            output [3:0] an_output,
            output [6:0] seg_output,
            output [13:0] selected_password,
            output [15:0] oled_data_password,
            inout PS2Clk, PS2Data);
        // State 1: Password Setting by Master Board
                  
        // Password is 4 digits XXXX
        // digit3,digit2,digit1,digit0
        reg [13:0] master_password;     // can represent from 0000 - 9999, for slave boards to check
        
        wire [3:0] digit0;
        wire [3:0] digit1;
        wire [3:0] digit2;
        wire [3:0] digit3;
        wire [1:0] selected_digit;

        // selected_digit: 00 - digit0 selected
        // selected_digit: 01 - digit1 selected
        // selected_digit: 10 - digit2 selected
        // selected_digit: 11 - digit3 selected
        
        // Mouse Module
        wire [11:0] xpos, ypos;
        wire [3:0] zpos;
        wire left, middle, right, new_event;
        reg [11:0] value = 0;
        reg setx = 0;
        reg sety = 0;
        reg setmax_x = `WIDTH;
        reg setmax_y = `HEIGHT;
        
        wire clk_25m;   // 25   MHZ CLK Signal
        wire clk_12p5m; // 12.5 MHZ CLK Signal
        wire clk_2;     // 2     HZ CLK Signal  (slow_clk)
        wire clk_6p25m;
        flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
        flexible_clock_module clk_25m_module(basys_clk, 1 ,clk_25m);
        flexible_clock_module clk_12p5m_module(basys_clk, 3 ,clk_12p5m);
        flexible_clock_module clk_2_module(basys_clk, 24999999 ,clk_2);
        
        MouseCtl mouse_module(.clk(basys_clk), .rst(0), .xpos(xpos), .ypos(ypos), .zpos(zpos), 
                                   .left(left), .middle(middle), .right(right), .new_event(new_event), 
                                   .value(value), .setx(setx), .sety(sety), .setmax_x(setmax_x), .setmax_y(setmax_y), 
                                   .ps2_clk(PS2Clk), .ps2_data(PS2Data) );
            
        password_select password_select_module(.clk_100M(basys_clk),
                           .mouse_l(left), 
                           .reset(0),
                           .enable(game_state==0),  
                           .mouse_x(xpos),
                           .mouse_y(ypos),
                           .pixel_index(pixel_index),
                           .oled_data(oled_data_password),
                           .digit_1(digit0),
                           .digit_2(digit1),
                           .digit_3(digit2),
                           .digit_4(digit3),
                           .btnL(btnL),
                           .btnR(btnR),
                           .btnU(btnU),
                           .btnD(btnD),
                           .selected_digit(selected_digit)                                    
                           );
        
        // module to map 4 bit binary number to 7-segment character
        segment_control segment_counter_module(basys_clk, clk_200, clk_1, digit0, digit1, digit2, digit3, selected_digit, an_output, seg_output);

        assign selected_password = (digit0 * 1) + (digit1 * 10) + (digit2 * 100) + (digit3 * 1000);
        
endmodule