`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2024 07:57:47 AM
// Design Name: 
// Module Name: task_b
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


module single_task_b(input clk_6p25, input [12:0] pixel_index, input CLOCK,
input btnL, input btnR, input btnC, input [4:0] reset_sw,input sw0, output reg[15:0] oled_data = 16'd 0);


  reg B3 = 0;
  reg [2:0]pb = 3'b 100;
  reg [2:0]pb2 = 0;
  reg left = 0;
  reg right = 0;
  reg centre = 0;
  reg [31:0] counter = 0;
  wire[7:0] coordinate_x;
  wire[7:0] coordinate_y;
  reg timeReached;
  reg releasedBtn = 1;
  
  //conversion (from module conversion)
  assign coordinate_y = pixel_index / 96;
  assign coordinate_x = pixel_index - (coordinate_y * 96);
  
  reg [31:0]count = 0;
  
  //conversion (from module fourSec)
  always @(posedge CLOCK) begin
  if (sw0 == 1 && ((reset_sw == 5'b 00010) || (reset_sw == 5'b 00011))) begin
      count = (count < 399999999) ? count + 1 : count;
      if(count == 399999999)
        timeReached <= 1;
      end
  else
      begin
      timeReached <= 0;
      count = 0;
      end
  end

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
            
          if(!timeReached) begin 
            B3 <= 0;
            counter <= 0;
            right <= 0;
            left <= 0;
            pb <= 3'b 100;
            pb2 <= 0;
          end
          if(timeReached && (btnR || btnL || btnC))  B3 <= 1;
          
          if(!btnL && !btnR && !btnC) releasedBtn <= 1;
          
          if(btnL) begin
            counter <= 0;
            left <= 0;
                if(counter >= 924999 && releasedBtn) begin 
                left <= 1;
                releasedBtn <= 0;
                end
           else counter <= counter + 1;
          end  
            
            else if(btnR) begin
              counter <= 0;
              right <= 0;
              if(counter >= 924999 && releasedBtn) begin 
              right <= 1;
              releasedBtn <= 0;
              end
              else counter <= counter + 1;
            end  
            
             else if(btnC) begin
             counter <= 0;
             centre <= 0;
             
             if(counter >= 924999 && releasedBtn) begin
             centre <= 1;
             releasedBtn <= 0;
             end
             
             else counter <= counter + 1;
           end  
            
            if(left == 1 && pb > 3'b 000) 
                pb <= pb - 1;
            else if(right == 1 && pb < 3'b 100) 
                pb <= pb + 1;
            else if(centre == 1 && pb2 == 3'b 011)
                pb2 <= 3'b 000; 
            else if(centre == 1 && pb2 < 3'b 011)
                pb2 <= pb2 + 1;      
             
    
          if(B3 == 1 && (
                           (coordinate_x >= 11 && coordinate_x <= 16) ||
                           (coordinate_x >= 28 && coordinate_x <= 33) || 
                           (coordinate_x >= 44 && coordinate_x <= 49) || 
                           (coordinate_x >= 60 && coordinate_x <= 65) || 
                           (coordinate_x >= 77 && coordinate_x <= 82)
                           ) && (coordinate_y >= 29 && coordinate_y <= 34) && pb2 == 3'b 000
                           )   
                                                            
                                   oled_data <= 16'b 11111_111111_11111;
                                   
          else if(B3 == 1 && (
                          (coordinate_x >= 11 && coordinate_x <= 16) ||
                          (coordinate_x >= 28 && coordinate_x <= 33) || 
                          (coordinate_x >= 44 && coordinate_x <= 49) || 
                          (coordinate_x >= 60 && coordinate_x <= 65) || 
                          (coordinate_x >= 77 && coordinate_x <= 82)
                          ) && (coordinate_y >= 29 && coordinate_y <= 34) && pb2 == 3'b 001
                          )   
                                   oled_data <= 16'b 11111_000000_00000;
          else if(B3 == 1 && (
                          (coordinate_x >= 11 && coordinate_x <= 16) ||
                          (coordinate_x >= 28 && coordinate_x <= 33) || 
                          (coordinate_x >= 44 && coordinate_x <= 49) || 
                          (coordinate_x >= 60 && coordinate_x <= 65) || 
                          (coordinate_x >= 77 && coordinate_x <= 82)
                          ) && (coordinate_y >= 29 && coordinate_y <= 34) && pb2 == 3'b 010
                          )   
                                 oled_data <= 16'b 00000_111111_00000;
                                 
          else if(B3 == 1 && (
                           (coordinate_x >= 11 && coordinate_x <= 16) ||
                           (coordinate_x >= 28 && coordinate_x <= 33) || 
                           (coordinate_x >= 44 && coordinate_x <= 49) || 
                           (coordinate_x >= 60 && coordinate_x <= 65) || 
                           (coordinate_x >= 77 && coordinate_x <= 82)
                           ) && (coordinate_y >= 29 && coordinate_y <= 34) && pb2 == 3'b 011
                           )   
                                oled_data <= 16'b 00000_000000_11111;
                     
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
                          ((coordinate_x >= 36 && coordinate_x <= 38) || (coordinate_x >= 23 && coordinate_x <= 25)))  ||
                          ((coordinate_x >= 25 && coordinate_x <= 38) &&  
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
endmodule

module conversion (input [12:0] pixel_index, output [7:0] coordinate_x, output [7:0] coordinate_y);
assign coordinate_y = pixel_index / 96;
assign coordinate_x = pixel_index - (coordinate_y * 96);

endmodule