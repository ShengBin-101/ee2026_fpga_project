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


module Top_Student (input bassys_clock, input restart, input btnD,  output [7:0] JC);

wire clk6p25m;

wire clk_20;

reg [15:0] oled_data = 16'h 0000;

wire beg;

wire sample;

wire sending;

wire [12:0] index;

assign JC[2] = 0;

flexible_clock clk_6_25 (.bassys_clock(bassys_clock), .m(7), .my_clk(clk6p25m));
flexible_clock clk_20HZ (.bassys_clock(bassys_clock), .m(2499999), .my_clk(clk_20));


Oled_Display oled_unit_A (.clk(clk6p25m), .reset(restart), .frame_begin(beg), .sending_pixels(sending),
  .sample_pixel(sample), .pixel_index(index), .pixel_data(oled_data), .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]),
  .pmoden(JC[7]));
   
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
  
  always @ (posedge bassys_clock) begin
  
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
  
  if (btnD == 1 && pressed != 1) begin
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

            


