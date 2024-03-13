`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  Sheng Bin
//
//////////////////////////////////////////////////////////////////////////////////

`include "constants.vh"

module Top_Student (
    input basys_clk,
    input btnU, btnL, btnR, btnD, btnC, 
    input [15:0] SW,
//    output [7:0] JB, 
    output [7:0] JC,
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp,
    inout PS2Clk, PS2Data
);

    assign an = 4'b0000;
    assign dp = 1;
    assign JC[2] = 0; // Some boards require JC[2] to be cleared to 0 for OLED to work

    // ===============OLED====================
    wire [15:0] oled_data;
    wire frame_begin, sending_pixels, sample_pixel; 
    wire [12:0] pixel_index;
    
    wire clk_6p25m;
    flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
    
    Oled_Display oled(
        .clk(clk_6p25m), 
        .reset(btnD), 
        .frame_begin(frame_begin), 
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JC[0]), 
        .sdin(JC[1]), 
        .sclk(JC[3]), 
        .d_cn(JC[4]), 
        .resn(JC[5]), 
        .vccen(JC[6]),
        .pmoden(JC[7]));

    task_d task_d_module(.basys_clk(basys_clk), .SW0(SW[0]), .btnC(btnC), .btnL(btnL), .btnR(btnR), .btnU(btnU), .btnD(btnD), .pixel_index(pixel_index) , .oled_data(oled_data));

endmodule