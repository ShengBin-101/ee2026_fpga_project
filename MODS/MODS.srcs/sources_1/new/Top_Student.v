`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////

// btnU - RST Signal for OLED
// btnD - RST Signal for MOUSECTL
`include "constants.vh"

module Top_Student (
    input basys_clk,
    input btnU, btnL, btnR, btnD, btnC, 
    input [15:0] SW,
    output [7:0] JB, 
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    inout PS2Clk, PS2Data
);

    assign an = 4'b0000;

    // ===============OLED====================
    wire [15:0] oled_data;
    wire frame_begin, sending_pixels, sample_pixel; 
    wire [12:0] pixel_index;
    
    wire clk_6p25m;
    flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);

    Oled_Display oled(
        .clk(clk_6p25m), .reset(btnU), 
        .frame_begin(frame_begin), 
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JB[0]), 
        .sdin(JB[1]), 
        .sclk(JB[3]), 
        .d_cn(JB[4]), 
        .resn(JB[5]), 
        .vccen(JB[6]),
        .pmoden(JB[7]));

    task_d task_d_module(.btnC(btnC), .btnL(btnL), .btnR(btnR), .btnU(btnU), .pixel_index(pixel_index) , .oled_data(oled_data));

    
endmodule