`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 03:57:33 PM
// Design Name: 
// Module Name: task_e
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
// === Group Basic Task === (Task E)
module task_e(
    input basys_clk,
    input [15:0] SW, 
    input btnC,
    inout PS2Clk,
    inout PS2Data,
    output [7:0] JC,
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp,
    output [15:0] oled_data,
    input [12:0] pixel_index
    );
    
    reg [6:0] seg_7 = 0;
    reg [3:0] an_4 = 0;
    reg dp_1 = 0;
    
   assign seg = seg_7;
   assign an = an_4;
   assign dp = dp_1;
   
    wire [11:0] xpos, ypos;
          wire [3:0] zpos;
          wire left, middle, right, new_event;
          reg [11:0] value = 0;
          reg setx = 0;
          reg sety = 0;
          reg setmax_x = `WIDTH;
          reg setmax_y = `HEIGHT;
      
      MouseCtl mouse_module(.clk(basys_clk), .rst(0), .xpos(xpos), .ypos(ypos), .zpos(zpos), 
                           .left(left), .middle(middle), .right(right), .new_event(new_event), 
                           .value(value), .setx(setx), .sety(sety), .setmax_x(setmax_x), .setmax_y(setmax_y), 
                           .ps2_clk(PS2Clk), .ps2_data(PS2Data) );
    
   
    wire clk_25m;   // 25   MHZ CLK Signal
    wire clk_12p5m; // 12.5 MHZ CLK Signal
    wire clk_2;     // 2     HZ CLK Signal  (slow_clk)
    wire clk_6p25m;
    
    flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
    flexible_clock_module clk_25m_module(basys_clk, 1 ,clk_25m);
    flexible_clock_module clk_12p5m_module(basys_clk, 3 ,clk_12p5m);
    flexible_clock_module clk_2_module(basys_clk, 24999999 ,clk_2);
    
    wire [15:0] colour_chooser;
    wire [15:0] led_e;
    wire [6:0] seg_AN;
    wire reset;
    reg success = 0;
    assign reset = (success)? 1 : 
                   (!SW[5]) ? 1 :
                   right;
        
    
    paint paint_module( .clk_100M(basys_clk),.clk_25M(clk_25m), .clk_12p5M(clk_12p5m), .clk_6p25M(clk_6p25m),
            .slow_clk(clk_2),
               .mouse_l(left), 
               .reset (reset),
               .enable(SW[6]),  
               .mouse_x(xpos),
               .mouse_y(ypos),
               .pixel_index(pixel_index),
               .led(led_e),       
               .seg(seg_AN), 
               .colour_chooser(colour_chooser));
    
   
   wire [6:0] X;
   wire [6:0] Y;
   assign X = pixel_index % 96;
   assign Y = pixel_index / 96;
   
   reg [6:0] seg_AN_0 = 7'b 0100100; 
   reg [6:0] seg_AN_1 = 7'b 1111001;
   reg [15:0] correct = 15'h 0000; 
   
    assign oled_data = (success) ? correct : colour_chooser ;
    
   
    reg [31:0] timer = 249999;
    reg [31:0] counter = 0;             
    reg [1:0] state = 0; 
    reg pressed = 0;
   
   
    reg [31:0] timer1 = 99999999;
    reg [31:0] counter1 = 0;
    reg [2:0] color_state = 0;
    
    reg [15:0] color_E1 = 0; // Color state for the first E
    reg [15:0] color_E2 = 0; // Color state for the second E
    reg [15:0] color_2 = 0;  // Color state for the first 2
    reg [15:0] color_0 = 0;  // Color state for 0
    reg [15:0] color_2_2 = 0;// Color state for the second 2
    reg [15:0] color_6 = 0;  // Color state for 6
    
   always @ (posedge basys_clk) begin
   
   if (!SW[5]) begin
   pressed <= 0;
   success <= 0;
   state <= 0;
   seg_AN_0 <= 7'b 0100100; 
   seg_AN_1 <= 7'b 1111001; 
   end
   
   else begin
   
   counter <= counter + 1;
   counter1 <= counter1 + 1;
   
   
   if (counter >= timer) begin
   counter <= 0;
   state <= state + 1;
   end
   
    if (counter1 >= timer1) begin
     counter1 <= 0;
     color_state <= color_state + 1;
     if (color_state >= 5)
     color_state <= 0;
     end
     
     case (color_state)
             0: begin
              color_E1 <= 16'hF800; // Red
              color_E2 <= 16'h07E0; // Green
              color_2 <= 16'h001F;  // Blue
              color_0 <= 16'b 10111_001100_11111; // Purple
              color_2_2 <= 16'b 11111_100110_00000; //Orange
              color_6 <= 16'b 10101_110111_11011; //Turqoise
             end
             1 : begin 
              color_6 <= 16'hF800; // Red
              color_E1 <= 16'h07E0; // Green
              color_E2 <= 16'h001F;  // Blue
              color_2 <= 16'b 10111_001100_11111; // Purple
              color_0 <= 16'b 11111_100110_00000; //Orange
              color_2_2 <= 16'b 10101_110111_11011; //Turqoise
            end
              2 : begin 
               color_2_2 <= 16'hF800; // Red
               color_6 <= 16'h07E0; // Green
               color_E1 <= 16'h001F;  // Blue
               color_E2 <= 16'b 10111_001100_11111; // Purple
               color_2 <= 16'b 11111_100110_00000; //Orange
               color_0 <= 16'b 10101_110111_11011; //Turqoise
               end
             3 : begin
             color_0 <= 16'hF800; // Red
             color_2_2 <= 16'h07E0; // Green
             color_6 <= 16'h001F;  // Blue
             color_E1 <= 16'b 10111_001100_11111; // Purple
             color_E2 <= 16'b 11111_100110_00000; //Orange
             color_2 <= 16'b 10101_110111_11011; //Turqoise
             end
            4 : begin
             color_2 <= 16'hF800; // Red
             color_0 <= 16'h07E0; // Green
             color_2_2 <= 16'h001F;  // Blue
             color_6 <= 16'b 10111_001100_11111; // Purple
             color_E1 <= 16'b 11111_100110_00000; //Orange
             color_E2 <= 16'b 10101_110111_11011; //Turqoise
             end
            5 : begin
              color_E2 <= 16'hF800; // Red
              color_2 <= 16'h07E0; // Green
              color_0 <= 16'h001F;  // Blue
              color_2_2 <= 16'b 10111_001100_11111; // Purple
              color_6 <= 16'b 11111_100110_00000; //Orange
              color_E1 <= 16'b 10101_110111_11011; //Turqoise 
              end
         endcase
   
   
    if (state == 2) begin
     an_4 <= 4'b 1011;
     seg_7 <= 7'b 0110000;
     dp_1 <= 0;
     end
     else if (state == 3) begin
     an_4 <=  4'b 0111;
     seg_7 <= 7'b 0010010;
     dp_1 <= 1;
     end 
  
  
  
  if (btnC && !pressed)
  pressed <= 1;
  
  if (((seg_AN_0 != 7'b 0100100) || (seg_AN_1 != 7'b 1111001)) && pressed == 1) begin
  pressed <= 0;
  end
  
  if (pressed == 1 && (seg_AN_0 == 7'b 0100100) && (seg_AN_1 == 7'b 1111001)) begin 
  success <= 1;
  end
  
  if (success) begin
  
  if (state == 0) begin
     an_4 <= 4'b 1110;
     seg_7 <= 7'b 0100100;
     dp_1 <= 1;
     end
     else if (state == 1) begin
     an_4 <= 4'b 1101;
     seg_7 <= 7'b 1111001;
     dp_1 <= 1;
     end
     
  
   //E
   if (((X >= 1) && (X <= 3) && (Y >= 25) && (Y <= 44)) || 
   ((Y >= 25) && (Y <= 27) && (X >= 4) && (X <= 13)) ||
   ((Y >= 34) && (Y <= 36) && (X >= 4) && (X <= 13)) ||
   ((Y >= 42) && (Y <= 44) && (X >= 4) && (X <= 13))) begin
   correct <= color_E1;
   end
   
   //E
   else if (((X >= 18) && (X <= 20) && (Y >= 25) && (Y <= 44)) || 
     ((Y >= 25) && (Y <= 27) && (X >= 21) && (X <= 30)) ||
     ((Y >= 34) && (Y <= 36) && (X >= 21) && (X <= 30)) ||
     ((Y >= 42) && (Y <= 44) && (X >= 21) && (X <= 30))) begin
     correct <= color_E2 ;
     end
            
            //2
   else if (((X >= 35) && (X <= 45) && (Y >= 25) && (Y <= 27)) ||
            ((X >= 43) && (X <= 45) && (Y >= 28) && (Y <= 34)) ||  
            ((X >= 35) && (X <= 45) && (Y >= 35) && (Y <= 37)) ||
            ((X >= 35) && (X <= 37) && (Y >= 38) && (Y <= 44)) || 
            ((X >= 38) && (X <= 45) && (Y >= 42) && (Y <= 44))) begin
            correct <= color_2;
            end
            
            //0
   else if (((X >= 49) && (X <= 51) && (Y >= 25) && (Y <= 44)) ||  // Left vertical line
                     ((X >= 60) && (X <= 62) && (Y >= 25) && (Y <= 44)) ||  // Right vertical line
                     ((Y >= 25) && (Y <= 27) && (X >= 52) && (X <= 59)) ||  // Top horizontal line
                     ((Y >= 42) && (Y <= 44) && (X >= 52) && (X <= 59))) begin  // Bottom horizontal line
                correct <= color_0;
            end
            
            // 2
            else if (((X >= 67) && (X <= 77) && (Y >= 25) && (Y <= 27)) ||  // Top vertical line
                     ((Y >= 28) && (Y <= 34) && (X >= 75) && (X <= 77)) ||  // Top horizontal line
                     ((Y >= 35) && (Y <= 37) && (X >= 67) && (X <= 77)) ||  // Middle horizontal line
                     ((Y >= 38) && (Y <= 44) && (X >= 67) && (X <= 69)) ||  // Bottom horizontal line
                     ((X >= 67) && (X <= 77) && (Y >= 42) && (Y <= 44))) begin  // Bottom vertical line
                correct <= color_2_2;
            end
            
            // "6"
            else if (((X >= 82) && (X <= 84) && (Y >= 25) && (Y <= 44)) ||  // Left vertical line
                     ((X >= 92) && (X <= 94) && (Y >= 35) && (Y <= 44)) ||  // Right vertical line
                     ((Y >= 25) && (Y <= 27) && (X >= 85) && (X <= 94)) ||  // Top horizontal line
                     ((Y >= 34) && (Y <= 36) && (X >= 85) && (X <= 94)) ||  // Middle horizontal line
                     ((Y >= 42) && (Y <= 44) && (X >= 85) && (X <= 94))) begin  // Bottom horizontal line
                correct <= color_6;
            end
            else begin
            correct <= 16'h 0000;
            end
    
    end 
         
   if (!success) begin      
  
  
   if (SW[15]) begin
       
       if (state == 0) begin
             an_4 <= 4'b 1110;
             seg_7 <= seg_AN_0;
             dp_1 <= 1;
             end
       else if (state == 1) begin
             an_4 <= 4'b 1101;
             seg_7 <= seg_AN;
             seg_AN_1 <= seg_AN;
             dp_1 <= 1;
             end 
   
   end
   
  else if (SW[14]) begin
   
   if (state == 0) begin
         an_4 <= 4'b 1110;
         seg_7 <= seg_AN;
         seg_AN_0 <= seg_AN;
         dp_1 <= 1;
         end
   else if (state == 1) begin
         an_4 <= 4'b 1101;
         seg_7 <= seg_AN_1;
         dp_1 <= 1;
         end
   
   end
   
   else if (SW[13]) begin
   
   if (state == 0) begin
      an_4 <= 4'b 1111;
      seg_7 <= 7'b 1111111;
      seg_AN_0 <= 7'b 1111111;
      dp_1 <= 1;
      end
      else if (state == 1) begin
      an_4 <= 4'b 1111;
      seg_7 <= 7'b 1111111;
      seg_AN_1 <= 7'b 1111111;
      dp_1 <= 1;
      end
  
  end
  
  else begin
  
   if (state == 0) begin
   an_4 <= 4'b 1110;
   seg_7 <= 7'b 0100100;
   dp_1 <= 1;
   seg_AN_0 <= 7'b 0100100;
   end
   else if (state == 1) begin
   an_4 <= 4'b 1101;
   seg_7 <= 7'b 1111001;
   dp_1 <= 1;
   seg_AN_1 <= 7'b 1111001;
   end
   
   end              
                   
  end
  
  end
  
  end            
 
endmodule
