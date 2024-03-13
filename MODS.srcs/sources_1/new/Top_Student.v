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


module Top_Student (
input clk,
output [7:0] JC,

//task A2
input btnC,
input btnD
);

    wire clk_6p25m;
    
    wire unused1;
    wire unused2;
    wire unused3;
    wire [12:0] pixel_index;
    
    wire [15:0] oled_data;
    
    
    assign JC[2] = 0;
    
    flexible_clock clk6p25m (.clock(clk), .m(7), .state(clk_6p25m));
    
    Oled_Display oled_unit_A (.clk(clk_6p25m),
    .reset(0),
    .frame_begin(unused1),
    .sending_pixels(unused2),
    .sample_pixel(unused3),
    .pixel_index(pixel_index), //
    .pixel_data(oled_data), // colour of led
    .cs(JC[0]),
    .sdin(JC[1]),
    .sclk(JC[3]),
    .d_cn(JC[4]),
    .resn(JC[5]),
    .vccen(JC[6]),
    .pmoden(JC[7]));
    
    Task_A task_a(.clk_6p25m(clk_6p25m), .btnC(btnC), .pixel_index(pixel_index), .oled_data(oled_data), .btnD(btnD));

endmodule