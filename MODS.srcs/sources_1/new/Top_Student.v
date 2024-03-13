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


module Top_Student (input sw, input CLOCK, input btnR, input btnL, output [7:0] JB);
//flexible_clock obj4 (CLOCK, w4);
flexible_clock obj4 (CLOCK, m, clk_6p25); //dot means module declaration do not need to be in order
//oLED instantiation
wire clk_6p25;
reg[15:0] oled_data = 16'd 0;
wire[7:0] coordinate_x;
wire[7:0] coordinate_y;
wire fb;
wire sending_pixel;
wire sample_pixel;
wire [12:0] pixel_index;
wire timeReached;
wire timeOut;
assign JB[2] = 0;

//oled_data ;
Oled_Display oled_display_A(.clk(clk_6p25), .reset(0), .frame_begin(fb), .sending_pixels(sending_pixel),
  .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JB[0]), .sdin(JB[1]), .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]),
  .pmoden(JB[7]));
  
  conversion obj1 (pixel_index, coordinate_x, coordinate_y);
  
  fourSec obj2 (sw, CLOCK, timeReached);
  fiftyMilli obj3 (timeReached, CLOCK, timeOut);
  
  reg B3 = 0;
  reg [2:0]pb = 3'b 100;
  reg once = 0;
 
 
 always @(posedge clk_6p25) 
 /* README (Week 7: 4.B1 and 4.B2)
 1. clock must be of 6.25MHz to run oLED
 2. Coordinate y refers to vertical axis of oLED. Each pixel is 1 coordinate.
 3. Coordinate X refers to horizontal axis of oLED
 4. coordinate_y > a && coordinate_y < b, means one vertical line from a to b is drawn 
 */
    begin
    // For 4.B1 (Start)
    if(!timeReached && (
           ((coordinate_y >= 23 && coordinate_y <= 40) &&  
           ((coordinate_x >= 51 && coordinate_x <= 53) || (coordinate_x >= 39 && coordinate_x <= 41)))  ||
           ((coordinate_x >= 41 && coordinate_x <= 53) &&  
           ((coordinate_y >= 23 && coordinate_y <= 25) || (coordinate_y >= 38 && coordinate_y <= 40)))
           ))
           oled_data <= 16'b 00000_111111_00000; 
    // For 4.B1 (End)    
    
    
    // For 4.B2 (Start)
      else if(!B3 && timeReached && (
      (
      (coordinate_x >= 11 && coordinate_x <= 16) ||
      (coordinate_x >= 28 && coordinate_x <= 33) || 
      (coordinate_x >= 44 && coordinate_x <= 49) || 
      (coordinate_x >= 60 && coordinate_x <= 65) || 
      (coordinate_x >= 77 && coordinate_x <= 82)
      ) && (coordinate_y >= 29 && coordinate_y <= 34)  
      ))begin
            oled_data <= 16'b 11111_111111_11111;
       end 
        
       else if(!B3 && timeReached && (
       ((coordinate_y >= 23 && coordinate_y <= 40) &&  
       ((coordinate_x >= 85 && coordinate_x <= 87) || (coordinate_x >= 72 && coordinate_x <= 74)))  ||
       ((coordinate_x >= 74 && coordinate_x <= 87) &&  
       ((coordinate_y >= 23 && coordinate_y <= 25) || (coordinate_y >= 38 && coordinate_y <= 40)))
       ))
       oled_data <= 16'b 00000_111111_00000;
    
      else if (!B3)
        oled_data <= 16'b 00000_000000_00000;
      
      //intermediate step.
      if(timeReached && (btnR || btnL))  begin
        B3 <= 1;
      end
        
      if(!timeReached) 
        B3 <= 0;
      
      if(timeReached && (btnR || btnL))  begin
       B3 <= 1;
       end
                
      if(!timeReached) 
        B3 <= 0;
      
      if(B3 == 1 && btnL && pb > 3'b 000) begin
        pb <= pb - 1; 
      end
      
      if(B3 == 1 && btnR && pb < 3'b 100)begin
        pb <= pb + 1; 
      end

      /*README work with pbR for right button
      work with pbL for left button */
      
        if(B3 == 1 && (
            (coordinate_x >= 11 && coordinate_x <= 16) ||
            (coordinate_x >= 28 && coordinate_x <= 33) || 
            (coordinate_x >= 44 && coordinate_x <= 49) || 
            (coordinate_x >= 60 && coordinate_x <= 65) || 
            (coordinate_x >= 77 && coordinate_x <= 82)
            ) && (coordinate_y >= 29 && coordinate_y <= 34)
            )   
                  oled_data <= 16'b 11111_111111_11111;
      
         else if(B3 == 1 && pb == 3'b 100 && (
             ((coordinate_y >= 23 && coordinate_y <= 40) &&  
             ((coordinate_x >= 85 && coordinate_x <= 87) || (coordinate_x >= 72 && coordinate_x <= 74)))  ||
             ((coordinate_x >= 74 && coordinate_x <= 87) &&  
             ((coordinate_y >= 23 && coordinate_y <= 25) || (coordinate_y >= 38 && coordinate_y <= 40)))
             ))
             oled_data <= 16'b 00000_111111_00000;      
      
        else if(B3 == 1 && pb == 3'b 011 && (
           ((coordinate_y >= 23 && coordinate_y <= 40) &&  
           ((coordinate_x >= 68 && coordinate_x <= 70) || (coordinate_x >= 55 && coordinate_x <= 57)))  ||
           ((coordinate_x >= 57 && coordinate_x <= 70) &&  
           ((coordinate_y >= 23 && coordinate_y <= 25) || (coordinate_y >= 38 && coordinate_y <= 40)))
           ))
           oled_data <= 16'b 00000_111111_00000;

        else if(B3 == 1 && pb == 3'b 010 && (
             ((coordinate_y >= 23 && coordinate_y <= 40) &&  
             ((coordinate_x >= 51 && coordinate_x <= 53) || (coordinate_x >= 39 && coordinate_x <= 41)))  ||
             ((coordinate_x >= 41 && coordinate_x <= 53) &&  
             ((coordinate_y >= 23 && coordinate_y <= 25) || (coordinate_y >= 38 && coordinate_y <= 40)))
             )) 
               oled_data <= 16'b 00000_111111_00000;
      
        else if(B3 == 1 && pb == 3'b 001 && (
           ((coordinate_y >= 23 && coordinate_y <= 40) &&  
           ((coordinate_x >= 36 && coordinate_x <= 38) || (coordinate_x >= 27 && coordinate_x <= 29)))  ||
           ((coordinate_x >= 29 && coordinate_x <= 38) &&  
           ((coordinate_y >= 23 && coordinate_y <= 25) || (coordinate_y >= 38 && coordinate_y <= 40)))
           )) 
             oled_data <= 16'b 00000_111111_00000;
          
        
         else if(B3 == 1 && pb == 3'b 000 && (
           ((coordinate_y >= 23 && coordinate_y <= 40) &&  
           ((coordinate_x >= 19 && coordinate_x <= 21) || (coordinate_x >= 6 && coordinate_x <= 8)))  ||
           ((coordinate_x >= 8 && coordinate_x <= 21) &&  
           ((coordinate_y >= 23 && coordinate_y <= 25) || (coordinate_y >= 38 && coordinate_y <= 40)))
           )) 
             oled_data <= 16'b 00000_111111_00000;
             
          else if (B3 == 1)
             oled_data <= 16'b 00000_000000_00000;
        end
    
    // For 4.B2 (End)
endmodule

/*README: Week 7 (Conversion module)
Conversion module converts each pixel into x and y, so 
we can use every x and y coordinate within the range 
*/
module conversion (input [12:0] pixel_index, output [7:0] coordinate_x, output [7:0] coordinate_y);
assign coordinate_y = pixel_index / 96;
assign coordinate_x = pixel_index - (coordinate_y * 96);

endmodule

module fourSec(input sw, input CLOCK, output reg timeReached);
reg [31:0]count = 0;

always @(posedge CLOCK) begin
if (sw == 1) begin
    count = (count < 299999999) ? count + 1 : count;
    if(count == 299999999)
      timeReached <= 1;
    end
else
    begin
    timeReached <= 0;
    count = 0;
    end
end
endmodule
module fiftyMilli(input sw, input CLOCK, output reg timeReached);
reg [31:0]count = 0;

always @(posedge CLOCK) begin
if (sw == 1) begin
    count = (count < 2999999) ? count + 1 : count;
    if(count == 2999999)
      timeReached <= 1;
    end
else
    begin
    timeReached <= 0;
    count = 0;
    end
end

endmodule