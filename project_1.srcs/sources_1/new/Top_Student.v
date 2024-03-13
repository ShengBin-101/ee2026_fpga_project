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


module Top_Student (input bassys_clock, input btnC, input btnD, input [15:0] sw,  output [7:0] JC , inout PS2Clk , inout PS2Data, output [15:0] led);



wire clk6p25m;
wire frame_begin, sending_pixel, sample_pixel;
wire [12:0] pixel_index;
wire [15:0] oled_data;
flexible_clock clk_6_25 (.bassys_clock(bassys_clock), .m(7), .my_clk(clk6p25m));

assign JC[2] = 0;

Oled_Display oled_unit_A (.clk(clk6p25m), .reset(btnC), .frame_begin(frame_begin), .sending_pixels(sending_pixel),
  .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]),
  .pmoden(JC[7]));

  
  task_c task_c_module (.bassys_clock(bassys_clock), .btnD(btnD),  .index(pixel_index), .SW(sw[5:1]), .oled_data(oled_data));
  
endmodule

            


