`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME: Low Jun Chen (A0277498A)
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input sw, input CLOCK, input btnR, input btnL, input btnC, output [7:0] JB);
flexible_clock obj4 (CLOCK, 7, clk_6p25); //dot means module declaration do not need to be in order
wire clk_6p25;
wire[15:0] oled_data;
wire[7:0] coordinate_x;
wire[7:0] coordinate_y;
wire fb;
wire sending_pixel;
wire sample_pixel;
wire [12:0] pixel_index;
wire timeReached;
wire timeOut;
wire [31:0] counter = 0;
assign JB[2] = 0;

//oled_data ;
Oled_Display oled_display_A(.clk(clk_6p25), .reset(0), .frame_begin(fb), .sending_pixels(sending_pixel),
  .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]),
  .pmoden(JB[7]));
  
  task_b obj3(clk_6p25, pixel_index, CLOCK, btnL, btnR, btnC, sw, oled_data);
   

endmodule