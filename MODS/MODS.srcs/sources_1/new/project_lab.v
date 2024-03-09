`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2024 11:11:38 PM
// Design Name: 
// Module Name: project_lab
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
include "constants.vh";

module project_lab(
    input basys_clk,
    input btnU, btnL, btnR, btnD, btnC, 
    input [15:0] SW,
    output [7:0] JB, 
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    inout PS2Clk, PS2Data
    );
    
    // always keep 7-segment ON 
    assign an = 4'b0000;
    
        // ===============OLED====================
        wire [15:0] oled_data;
        wire frame_begin, sending_pixels, sample_pixel; 
        wire [12:0] pixel_index;
        
        wire clk_6p25m;  // 6.25   MHZ CLK Signal
        flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
    
        Oled_Display oled(.clk(clk_6p25m), 
            .reset(btnU), 
            .frame_begin(frame_begin), 
            .sending_pixels(sending_pixels),
            .sample_pixel(sample_pixel), 
            .pixel_index(pixel_index), 
            .pixel_data(colour_chooser), 
            .cs(JB[0]), 
            .sdin(JB[1]), 
            .sclk(JB[3]), 
            .d_cn(JB[4]), 
            .resn(JB[5]), 
            .vccen(JB[6]),
            .pmoden(JB[7]));
    
    
    
    //    ================MOUSE CONTROL==============================
    
    //     Setting up the mouse 
        wire [11:0] xpos, ypos;
        wire [3:0] zpos;
        wire left, middle, right, new_event;
        reg [11:0] value = 0;
        reg setx = 0;
        reg sety = 0;
        reg setmax_x = `WIDTH;
        reg setmax_y = `HEIGHT;
    
        MouseCtl mouse_module(.clk(basys_clk), .rst(rst), .xpos(xpos), .ypos(ypos), .zpos(zpos), 
                 .left(left), .middle(middle), .right(right), .new_event(new_event), 
                 .value(value), .setx(setx), .sety(sety), .setmax_x(setmax_x), .setmax_y(setmax_y), 
                 .ps2_clk(PS2Clk), .ps2_data(PS2Data) );
                 
        assign led[13] = right;
        assign led[14] = middle;
        assign led[15] = left;
        
        
    // ====================PAINT MODULE=========================
    
        // xpos connected to mouse_x of point module
        // ypos connected to mouse_y of point module 
    
        wire clk_25m;   // 25   MHZ CLK Signal
        wire clk_12p5m; // 12.5 MHZ CLK Signal
        wire clk_2;     // 2     HZ CLK Signal  (slow_clk)
                
        flexible_clock_module clk_25m_module(basys_clk, 1 ,clk_25m);
        flexible_clock_module clk_12p5_module(basys_clk, 3 ,clk_12p5m);
        flexible_clock_module clk_2_module(basys_clk, 24999999 ,clk_2);         
                
        wire [15:0] colour_chooser;
        
        paint paint_module( .clk_100M(basys_clk),.clk_25M(clk_25m), .clk_12p5M(clk_12p5m), .clk_6p25M(clk_6p25m),
        .slow_clk(clk_2),
           .mouse_l(left), 
           .reset (right),
           .enable(SW[0]),  
           .mouse_x(xpos),
           .mouse_y(ypos),
           .pixel_index(pixel_index),
           .led(led),       
           .seg(seg), 
           .colour_chooser(colour_chooser));
    
    
    
endmodule
