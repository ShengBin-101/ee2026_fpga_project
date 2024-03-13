`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 04:53:07 PM
// Design Name: 
// Module Name: task_c
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


module task_c(input bassys_clock, input btnD, input [12:0] index, input [4:0] SW,  output reg [15:0] oled_data = 16'h 000);


  wire [6:0] X;
  wire [6:0] Y;
  assign X = index % 96;
  assign Y = index / 96;
  reg [5:0] square_Y = 2;
  reg [6:0] square_X = 45;
  reg [6:0] X_moved = 0;
  reg [5:0] Y_moved = 0;
  reg pressed = 0;
  reg [31:0] counter = 0;
  reg [31:0] counter1 = 0;
  reg [31:0] counter2 = 0;
  reg [31:0] counter3 = 0;
  reg [31:0] counter4 = 0;
  reg [31:0] counter5 = 0;
  reg Green = 0;
  reg Right = 0;
  reg Return = 0;
  reg Restart = 0;
  reg Double = 0;
  reg Stop = 0;  

  
  always @ (posedge bassys_clock) begin
  
  if ((SW >= 5'b 00100) && (SW < 5'b 01000)) begin
  Stop <= 0;
  end
  else begin
  Stop <= 1;
  square_Y <= 2;
  square_X <= 45;
  X_moved <= 0;
  Y_moved <= 0;
  pressed <= 0;
  Double <= 0;
  end
  
  
  if (pressed == 0) begin
  Green <= 0;
  Right <= 0;
  Return <= 0;
  Restart <= 0;
  counter <= 0;
  counter1 <= 0;
  counter2 <= 0;
  counter3 <= 0;
  counter4 <= 0;
  counter5 <= 0;
  end
  
  if (btnD == 1 && pressed != 1 && Stop == 0) begin
  pressed <= 1;
  counter <= 0;
  end
  
  if (pressed == 1)
  counter <= counter + 1;
  
  if (pressed == 1 && Y_moved < 30 && counter >= 4999999 && !Right) begin
        square_Y <= square_Y + 1;
        Y_moved <= Y_moved + 1;
        counter <= 0;
    end
  else if (Y_moved >= 30) begin
   Right <= 1;
   counter1 <= counter1 + 1;
   end
   
   if (Right == 1 && X_moved < 15 && counter1 >= 4999999 && !Green) begin
   square_X <= square_X + 1;
   X_moved <= X_moved + 1;
   counter1 <= 0;
   end
   else if (X_moved >= 15 && counter2 < 49999999) begin
   counter2 <= counter2 + 1;
   end
   
   if (counter2 >= 49999999)
   Green <= 1;
   
   if (Green == 1) 
   counter3 <= counter3 + 1;
   
   if (counter3 >= 49999999 && Green == 1)
   Return <= 1; 
   
   if (Return == 1) begin
   counter4 <= counter4 + 1;
  
   if (X_moved > 0 && counter4 >= 9999999) begin
   square_X <= square_X - 1;
   X_moved <= X_moved - 1;
   counter4 <= 0;
   end
   else if (X_moved == 0 && Y_moved > 0 && counter4 >= 9999999) begin
      square_Y <= square_Y - 1;
      Y_moved <= Y_moved - 1;
      counter4 <= 0;
      end
    
    if (X_moved == 0 && Y_moved == 0)
    Restart = 1; 
    counter5 <= 0;  
   end  
   
   if (Restart == 1)
   counter5 <= counter5 + 1;
    
    if (counter5 >= 49999999) begin
    pressed <= 0; 
    Double <= 1;
    end
   
   if (Return == 1) begin
           // Green trail for the square and its path
            if (((X >= square_X) && (X <= square_X + 4) && (Y >= square_Y) && (Y <= square_Y + 4)) || // Square
                ((X >= square_X) && (X <= 64) && (Y >= 32) && (Y <= 36)) || // Vertical trail
                ((X >= square_X) && (X <= 49) && (Y >= square_Y) && (Y <= 32))) begin // Horizontal trail
                oled_data <= 16'h 07E0; // Green
            end
            // Red trail only in areas not yet reached by the returning square
            else if (((X >= 45) && (X <= 49) && (Y >= 2) && (Y < square_Y)) || 
                     ((X >= 45) && (X < square_X) && (Y >= square_Y) && (Y <= square_Y + 4))) begin
                oled_data <= 16'h f800; // Red
            end
            else begin
                oled_data <= 16'h 0000; // Black
            end
        end 
       
 else if (Green) begin
     if (((X >= 45) && (X <= 49) && (Y >= 2) && (Y <= (square_Y + 4))) || 
       ((X >= 45) && (X < (square_X)) && (Y >= square_Y) && (Y <= (square_Y + 4))))
       begin
       oled_data <= 16'h f800;
       end
     else if ((X >= square_X) && (X <= square_X + 4) && (Y >= square_Y) && (Y <= square_Y + 4)) begin
     oled_data <= 16'h 07E0;
     end  
     else begin
     oled_data <= 16'h 0000;
     end
     end
 
  else if (Right) begin
  
  if ((Double == 1) && (X > square_X + 4) && (X <= 64) && (Y >= square_Y) && (Y <= square_Y + 4))
  begin
  oled_data <= 16'h 07E0; 
  end
  else if (((X >= 45) && (X <= 49) && (Y >= 2) && (Y < square_Y + 4)) || 
  ((X >= 45) && (X <= (square_X + 4)) && (Y >= square_Y) && (Y <= (square_Y + 4))))
  begin  
  oled_data <= 16'h f800;
  end
  else begin
  oled_data <= 16'h 0000 ;
  end
  end

  else
  

 if ((Double == 1) && ((X >= 45) && (X <= 49) && (Y > square_Y + 4) && (Y <= 36))
          ||((Double == 1) && ((X >= 49) && (X <= 64) && (Y >= 32) && (Y <= 36)))) begin
          oled_data <= 16'h 07E0;
  end   
  else if ((X >= 45) && (X <= 49) && (Y >= 2) && (Y <= square_Y + 4)) 
   begin
   oled_data <= 16'h f800;
   end
   else
   oled_data <= 16'h 0000 ;
   end
   
   
endmodule