`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/13/2024 03:10:05 PM
// Design Name: 
// Module Name: Task_A
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


module Task_A(

input clk_6p25m,
input btnC,
input btnD,
input [12:0] pixel_index,
output reg [15:0] oled_data

);


//task A.1
wire [6:0] x = pixel_index % 96;
wire [5:0] y = pixel_index / 96;
//task A.2
reg [1:0] btnCpressed = 0;
//task A3
reg [27:0] two_sec_counter = 0;
reg [23:0] onePfive_sec_counter = 0;
reg [22:0] one_sec_counter = 0;
reg [4:0] stage = 0;
reg [4:0] stage_part_b = 0;
reg [13:0] milisec_counter = 0;
reg [21:0] two_hun_milisec_counter = 0;


always @ (posedge clk_6p25m) 
begin
       
    oled_data <= 16'h 0000; //set black at the start
       
    if ((((x >= 1) && (x <= 95))) && ((y >= 1) && (y <= 63)) && !((x >= 2) && (x <= 94) && (y >= 2) && (y <= 62))) //set first outer red border
    begin
        oled_data <= 16'h F800;
    end
   
    if (btnC)
    begin
        btnCpressed <= 1;
    end
   
   if (btnCpressed &&
           ((x >= 3) && (x <= 93) && ((y == 3) || (y == 4) || (y == 5) || (y == 60) || (y == 61) || (y == 59)) || // create second orange border
           ((y >= 3) && (y <= 61) && ((x == 3) || (x == 4) || (x == 5) || (x == 91) || (x == 92) || (x == 93)))))
   begin
       oled_data <= 16'h FC00; // Orange color
   end
   
   if (btnCpressed)                  
   begin

       if (stage == 0)
       begin
           if (two_sec_counter >= 12499999)
           begin
               two_sec_counter <= 0;
               stage <= 1;
           end
           else
           begin
               two_sec_counter <= two_sec_counter + 1;
           end
       end
       
       else if (stage == 1)
       begin
           if (onePfive_sec_counter >= 9374999)
           begin
               onePfive_sec_counter <= 0;
               stage <= 2;
           end
           else
           begin
               onePfive_sec_counter <= onePfive_sec_counter + 1;
           end
       end
    
       else if (stage == 2)
       begin
           if (one_sec_counter >= 6249999)
           begin
               one_sec_counter <= 0;
               stage <= 3;
           end
           else
           begin
               one_sec_counter <= one_sec_counter + 1;
           end
       end
       
       else if (stage == 3)
       begin
           if (one_sec_counter >= 6249999)
           begin
               one_sec_counter <= 0;
               stage <= 0;
           end
           else
           begin
               one_sec_counter <= one_sec_counter + 1;
           end
       end
       
       if (stage >= 1 &&        
          ((x >= 7) && (x <= 89) && ((y == 7) || (y == 57)) ||
          ((y >= 7) && (y <= 57) && ((x == 7) || (x == 89)))))

       begin
           oled_data <= 16'h 07E0;
       end
       
       if (stage >= 2 &&
          ((x >= 9) && (x <= 87) && ((y == 9) || (y == 10) || (y == 55) || (y == 54)) ||
          ((y >= 9) && (y <= 55) && ((x == 9) || (x == 10) || (x == 87) || (x == 86)))))
       
       begin
           oled_data <= 16'h 07E0; 
       end
       
       if (stage >= 3 &&
          ((x >= 12) && (x <= 84) && ((y == 12) || (y == 13) || (y == 14) || (y == 52) || (y == 51) || (y == 50)) ||
          ((y >= 12) && (y <= 52) && ((x == 12) || (x == 13) || (x == 14) || (x == 84) || (x == 83) || (x == 82)))))
       
       begin
           oled_data <= 16'h 07E0; 
       end
       
       
       if (btnD)
       begin
           if (two_hun_milisec_counter >= 1249999)  //ignore btnd for 200 ms
           begin
               two_hun_milisec_counter <= 0;
               
               if (stage_part_b == 0)
               begin
                   stage_part_b <= 1;
               end
               else if (stage_part_b == 1)
               begin
                   stage_part_b <= 2;
               end
               else if (stage_part_b == 2)
               begin
                   stage_part_b <= 3;
               end
               else if (stage_part_b == 3)
               begin
                   stage_part_b <= 1;
               end
           end
           else
           begin
               two_hun_milisec_counter <= two_hun_milisec_counter + 1;
           end
       end

   
       if (stage_part_b == 1 && ((x >= 44 && x < 52) && (y >= 29 && y <= 35))) //red square
       begin
           oled_data <= 16'h F800;
       end
       
       else if (stage_part_b == 2 && ((x - 48) ** 2 + (y - 32) ** 2) <= (8 ** 2)) //orange circle
       begin
           oled_data <= 16'h FC00;
       end
       
       else if (stage_part_b == 3 && ((x >= 38) && (x < 58) && (y >= 25) && (y < 40) && (y < (-3/2)*x + 97) && (y < (3/2)*x - 17))) //green triangle
       begin
           oled_data <= 16'h 07E0;
       end


   end 
       

           
end
           
endmodule