`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2023 15:05:29
// Design Name: 
// Module Name: paint
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


module password_select(
    input clk_100M,
    input btnL, btnR, btnU, btnD, 
    input mouse_l, reset, enable,  
    input [11:0] mouse_x, mouse_y,
    input [12:0] pixel_index,
    output [6:0] seg, 
    output reg [15:0] oled_data,
    output reg [3:0] digit_1 = 4'b0000,
    output reg [3:0] digit_2 = 4'b0000,
    output reg [3:0] digit_3 = 4'b0000,
    output reg [3:0] digit_4 = 4'b0000,
    output reg [1:0] selected_digit
);   
    reg clockMouse;    
    reg clk_s;    
    reg clk_6p25MHz;    
    reg clk_25;

    reg [3:0] digit_1_pb;
    reg [3:0] digit_2_pb;
    reg [3:0] digit_3_pb;
    reg [3:0] digit_4_pb;    
    reg [3:0] digit_1_mouse;
    reg [3:0] digit_2_mouse;
    reg [3:0] digit_3_mouse;
    reg [3:0] digit_4_mouse;
   
    
    reg [2:0]pixel_data[360:0]; //going for 28 x 28, the scale down of 56 x 56. Original is 32 x 32, scale down of 64 x 64
    integer k;
    initial begin
          for (k=0; k<361; k=k+1) begin
              pixel_data[k] = 0;
          end
    end
    
    parameter WHITE = 16'b11111_111111_11111;
    parameter ORANGE = 16'b11111_101101_00000;
    parameter BLUE = 16'b00000_000000_11111;
    parameter GREEN = 16'b00000_111111_00000;
    parameter RED = 16'b11111_000000_00000;
    parameter PURPLE = 16'b11111_000000_11110;    
    parameter outline_color = 16'b00000_000000_00000;
    parameter background_color = 16'b11111_111111_11111;
    
    wire [6:0] row, col;
    assign col = pixel_index % 96;
    assign row = pixel_index / 96;        
    
    reg [2:0] state_choice = 3'b00;
    reg [2:0] state;
    
    // check if right click for reset with bounce detection
    reg [31:0] reset_count = 0;
    
    // initialize the reset to prevent unwanted error
    reg mouse_reset;
    initial begin
        mouse_reset = 1'b1;
    end
    reg pressed;
    reg released;
    reg [31:0] counter;

// ========= password selection using button ========
        
    
    // To determine the color at each x-y coordinate, configurable    
    wire red, blue, green, orange, outline, screen;
    assign red = (col > 66 && col < 78 && row > 5 && row < 29);
    assign blue =  (col > 80 && col < 92 && row > 5 && row < 29);
    assign green =  (col > 66 && col < 78 && row > 34 && row < 58);
    assign orange =  (col > 80 && col < 92 && row > 34 && row < 58);
    assign outline = (col > 55 || row > 55);    
    assign screen = (col < 56 && row < 56); // create a 56 x 56 screen
    
    // Create a 9 x 9 cursor
    wire within_cursor; wire [15:0] cursor_color;
    assign within_cursor = ((col >= (mouse_x - 3)) && (col <= (mouse_x + 3))) && ((row >= (mouse_y - 3)) && (row <= (mouse_y + 3)));
    assign cursor_color = (within_cursor && (col != (mouse_x - 3)) && (col != (mouse_x + 3)) && (row != (mouse_y - 3)) && (row != (mouse_y + 3))) ? 16'hF800 : // Bright Red for the middle pixel
                          (within_cursor && ((col == (mouse_x - 3)) || (col == (mouse_x + 3)) || (row == (mouse_y - 3)) || (row == (mouse_y + 3)))) ? 16'h0000 : // Black for the border
                          (within_cursor ? PURPLE : 0); // Purple for the remaining area
    
    // This is for color selection
    always @ (posedge mouse_l) begin
        if (enable) begin            
            if (mouse_l && ((mouse_x > 55) || (mouse_y > 55))) begin
                state_choice <= state; // Set colour
            end
        end
    end

    // We use 3 pixel per lines or per click    
    always @ (posedge clk_100M, posedge reset) begin
            
            // will held reset for 100ms if activate
            if (reset || reset_count > 0) begin
                reset_count = (reset_count > 999_999) ? 0 : reset_count + 1;
            end
            // double if statement to prevent premature detection under clear screen        
            mouse_reset = (reset_count > 0) ? 1 : ((mouse_reset && mouse_l && mouse_x < 55 && mouse_y < 55) ? 0 : mouse_reset);
        
                    if (btnL || btnR || btnU || btnD) begin pressed <= 1; counter <= 0; end 
                    else pressed <= 0;
                        if(counter >= 2499999 && pressed == 0) begin 
                                if (selected_digit < 2'b11 && btnL == 1) begin
                                    selected_digit <= selected_digit + 1;
                                end
                                else if (selected_digit > 2'b00 && btnR == 1) begin
                                    selected_digit <= selected_digit - 1;
                                end
                                
                                
                                if (selected_digit == 0) begin
                                    if (btnU == 1 && digit_1 < 9)
                                        digit_1 <= digit_1 + 1;
                                    else if (btnD == 1 && digit_1 > 0)
                                        digit_1 <= digit_1 - 1;
                                end
                                if (selected_digit == 1) begin
                                    if (btnU == 1 && digit_2 < 9)
                                        digit_2 <= digit_2 + 1;
                                    else if (btnD == 1 && digit_2 > 0)
                                        digit_2 <= digit_2 - 1;
                                end            
                                if (selected_digit == 2) begin
                                    if (btnU == 1 && digit_3 < 9)
                                        digit_3 <= digit_3 + 1;
                                    else if (btnD == 1 && digit_3 > 0)
                                        digit_3 <= digit_3 - 1;
                                end
                                if (selected_digit == 3) begin
                                    if (btnU == 1 && digit_4 < 9)
                                        digit_4 <= digit_4 + 1;
                                    else if (btnD == 1 && digit_4 > 0)
                                        digit_4 <= digit_4 - 1;
                                end  
                                
                            end
                            else if (pressed == 1)counter <= counter + 1;
     
    
        if (reset) begin
            for (k=0; k<361; k=k+1) begin //  here corresponding change from 1024 to 784
                pixel_data[k] <= 2'b00;
            end          
       
      end else if (enable && mouse_l && mouse_x < 96 && mouse_y < 64) begin                                   
            if (mouse_x > 0 && mouse_x < 32 && mouse_y > 0 && mouse_y < 18) begin
                if(selected_digit == 0) digit_1 <= 1;
                if(selected_digit == 1) digit_2 <= 1;
                if(selected_digit == 2) digit_3 <= 1;
                if(selected_digit == 3) digit_4 <= 1;
            end
                 
             else if (mouse_x > 33 && mouse_x < 63 && mouse_y > 0 && mouse_y < 18) begin
                 if(selected_digit == 0) digit_1 <= 2;
                 if(selected_digit == 1) digit_2 <= 2;
                 if(selected_digit == 2) digit_3 <= 2;
                 if(selected_digit == 3) digit_4 <= 2;
             end 
                                                        
            else if (mouse_x > 64 && mouse_x < 90 && mouse_y > 0 && mouse_y < 18) begin                           
                if(selected_digit == 0) digit_1 <= 3;
                if(selected_digit == 1) digit_2 <= 3;
                if(selected_digit == 2) digit_3 <= 3;
                if(selected_digit == 3) digit_4 <= 3;                          
            end
            
            else if (mouse_x > 0 && mouse_x < 32  && mouse_y > 19 && mouse_y < 35) begin
                if(selected_digit == 0) digit_1 <= 4;
                if(selected_digit == 1) digit_2 <= 4;
                if(selected_digit == 2) digit_3 <= 4;
                if(selected_digit == 3) digit_4 <= 4;                          
             end
            else if (mouse_x > 33 && mouse_x < 63  && mouse_y > 19 && mouse_y < 35) begin            
                if(selected_digit == 0) digit_1 <= 5;
                if(selected_digit == 1) digit_2 <= 5;
                if(selected_digit == 2) digit_3 <= 5;
                if(selected_digit == 3) digit_4 <= 5;                                           
            end
            else if (mouse_x > 64 && mouse_x < 90  && mouse_y > 19 && mouse_y < 35) begin        
                if(selected_digit == 0) digit_1 <= 6;
                if(selected_digit == 1) digit_2 <= 6;
                if(selected_digit == 2) digit_3 <= 6;
                if(selected_digit == 3) digit_4 <= 6;                                           
            end                        
            else if (mouse_x > 0 && mouse_x < 32  && mouse_y > 36 && mouse_y < 50) begin
                if(selected_digit == 0) digit_1 <= 7;
                if(selected_digit == 1) digit_2 <= 7;
                if(selected_digit == 2) digit_3 <= 7;
                if(selected_digit == 3) digit_4 <= 7;                                           
            end            
                                
            else if (mouse_x > 33 && mouse_x < 63  && mouse_y > 36 && mouse_y < 50) begin
                if(selected_digit == 0) digit_1 <= 8;
                if(selected_digit == 1) digit_2 <= 8;
                if(selected_digit == 2) digit_3 <= 8;
                if(selected_digit == 3) digit_4 <= 8;                                           
            end      
                               
            else if (mouse_x > 64 && mouse_x < 90  && mouse_y > 36 && mouse_y < 50) begin
                if(selected_digit == 0) digit_1 <= 9;
                if(selected_digit == 1) digit_2 <= 9;
                if(selected_digit == 2) digit_3 <= 9;
                if(selected_digit == 3) digit_4 <= 9;                                           
            end     
            else if (mouse_x > 0 && mouse_x < 32  && mouse_y > 51 && mouse_y < 63) begin
                if (mouse_l) begin pressed <= 1; counter <= 0; end
                else pressed <= 0;
                if(counter >= 2499999 && pressed == 0) begin 
                    if (selected_digit < 2'b11) begin
                        selected_digit <= selected_digit + 1;
                    end
                end
                else if (pressed == 1) counter <= counter + 1;
            end
             else if (mouse_x > 33 && mouse_x < 63 && mouse_y > 51 && mouse_y < 63) begin
                if(selected_digit == 0) digit_1 <= 0;
                 if(selected_digit == 1) digit_2 <= 0;
                 if(selected_digit == 2) digit_3 <= 0;
                 if(selected_digit == 3) digit_4 <= 0;                                           
             end               
             else if (mouse_x > 64 && mouse_x < 90  && mouse_y > 51 && mouse_y < 63) begin
                if (mouse_l) begin pressed <= 1; counter <= 0; end
                else pressed <= 0;
                             
                if(counter >= 2499999 && pressed == 0) begin 
                    if (selected_digit > 2'b00) begin
                        selected_digit <= selected_digit - 1;
                    end
                end
                else if (pressed == 1)counter <= counter - 1;
             end
        end
    end
    
    
    // This portion to generate the pixel data output
    always @ (pixel_index) begin
        if (enable) begin
            if (within_cursor && cursor_color != 1) oled_data <= cursor_color;
            //1
             else if(row >= 1 && row <= 12 && col >= 15 && col <= 17 || row >= 2 && row <= 4 && col >= 13 && col <= 15 ||
                col >= 12 && col <= 20 && row >= 11 && row <= 12) 
                    oled_data <= 16'b 111110111101111;
                //2
                else if(col >= 42 && col <= 48 && row >= 1 && row <= 2 || //top horizontal
                col >= 40 && col <= 42 && row >= 2 && row <= 3 || //drop down
                col >= 48 && col <= 50 && row >= 1 && row <= 2 || //first horizontal
                col >= 49 && col <= 50 && row >= 2 && row <= 3 || 
                col >= 47 && col <= 48 && row >= 4 && row <= 5 || 
                col >= 45 && col <= 46 && row >= 6 && row <= 7 || 
                col >= 43 && col <= 44 && row >= 8 && row <= 9 || 
                col >= 41 && col <= 42 && row >= 10 && row <= 11 ||
                col >= 41 && col <= 48 && row >= 11 && row <= 12 // last horizontal
                ) 
                         oled_data <= 16'b 1111100000000000;
                         
                
                //3
                else if(  col >= 78 && col <= 80 && row >= 2 && row <= 3 || //first dropdown
                col >= 80 && col <= 86 && row >= 1 && row <= 3 || //first horizontal
                col >= 86 && col <= 87 && row >= 3 && row <= 5 || //first vertical
                col >= 81 && col <= 86 && row >= 5 && row <= 7 || //first horizontal
                col >= 86 && col <= 87 && row >= 7 && row <= 9 || //second vertical
                col >= 80 && col <= 86 && row >= 9 && row <= 11 || //second horizontal
                col >= 78 && col <= 80 && row >= 9 && row <= 11    //first dropdown
                ) 
                             oled_data <= 16'b 1111111111100000;
                             
                    
                //4
                else if(col >= 11 && col <= 12 && row >= 23 && row <= 24 || col >= 13 && col <= 14 && row == 22 || col >= 15 && col <= 16 && row == 21 || 
                col >= 17 && col <= 18 && row == 20 || col >= 19 && col <= 20 && row == 19 || col >= 20 && col <= 21 && row >= 19 && row <= 18 || //slash
                
                    col >= 19 && col <= 21 && row >= 19 && row <= 24 || // first vertical
                    col >= 11 && col <= 21 && row >= 24 && row <= 25 ||  // second horizontal
                    col >= 19 && col <= 21 && row >= 25 && row <= 29 // second vertical    
                ) 
                    
                                    oled_data <= 16'b 0000001111111111;
                                    
               
               
               //5
               else if(col >= 40 && col <= 50 && row >= 19 && row <= 20 || // top horizontal
               col >= 40 && col <=42 && row >= 20 && row <= 22 || // first vertical
               col >= 40 && col <=49 && row >= 22 && row <= 23 || // second horizontal
               col >= 49 && col <=50 && row >= 24 && row <= 27 ||
               col >= 42 && col <=49 && row >= 28 && row <= 29 ||
               col >= 40 && col <=42 && row >= 27 && row <= 29
                ) 
                                        oled_data <= 16'b 0000001111110000;
                                       
                    
                //6    
                else if(col >= 76 && col <= 88 && row >= 19 && row <= 20 || //top horizontal
                col >= 86 && col <= 87 && row >= 20 && row <= 21 || //top dropdown
                col >= 74 && col <= 76 && row >= 20 && row <= 27 ||
                col >= 76 && col <= 86 && row >= 27 && row <= 28 ||  //end horizontal
                col >= 76 && col <= 86 && row >= 23 && row <= 24 || //middle horizontal
                col >= 86 && col <= 87 && row >= 25 && row <= 26)   //rhs vertical (pop out)
                   
                        oled_data <= 16'b 111110111101111;
                       
                
                //7
                else if(col >= 11 && col <= 21 && row >= 36 && row <= 37 || 
                col >= 20 && col <= 21 && row >= 37 && row <= 38 ||
                col >= 18 && col <= 19 && row >= 38 && row <= 39 ||
                col >= 16 && col <= 17 && row >= 40 && row <= 41 ||
                col >= 14 && col <= 15 && row >= 41 && row <= 42 ||
                col >= 12 && col <= 13 && row >= 42 && row <= 43 ||
                col >= 11 && col <= 12 && row >= 42 && row <= 46) 
                   
                             oled_data <= 16'b 1111100000000000;
                             
                
                //8
                else if(col >= 42 && col <= 48 && row >= 36 && row <= 37 || 
                col >= 40 && col <= 42 && row >= 37 && row <= 40 || //top vertical, first half
                col >= 48 && col <= 50 && row >= 37 && row <= 40 || //top vertical, second half
                col >= 42 && col <= 48 && row >= 40 && row <= 41 || //middle horizontal
                col >= 40 && col <= 42 && row >= 41 && row <= 44 || //bottom vertical, first half
                col >= 48 && col <= 50 && row >= 41 && row <= 44 || //bottom vertical, second half
                col >= 42 && col <= 48 && row >= 44 && row <= 45)  
                    
                                 oled_data <= 16'b 1111111111100000;
                                
                    
                //9
                else if(col >= 76 && col <= 82 && row >= 36 && row <= 37 || 
                col >= 74 && col <= 76 && row >= 37 && row <= 39 || //top vertical, first half
                col >= 82 && col <= 84 && row >= 37 && row <= 40 || //top vertical, second half
                col >= 76 && col <= 82 && row >= 40 && row <= 41 || //middle horizontal
               // col >= 74 && col <= 76 && row >= 41 && row <= 42 || //bottom vertical, first half
                col >= 82 && col <= 84 && row >= 41 && row <= 44 || //bottom vertical, second half
                col >= 76 && col <= 82 && row >= 44 && row <= 45)  
                     
                                       oled_data <= 16'b 0000001111111111;
                                      
                else if(col >= 11 && col <= 21 && row >= 55 && row <= 57 ||
                        col >= 9 && col <= 14 && row >= (56-((col-9))) && row <=(56+((col-9)))) 
                    
                    oled_data <= 0;
                //0
                else if(col >= 42 && col <= 48 && row >= 52 && row <= 53 || 
                col >= 40 && col <= 42 && row >= 53 && row <= 59 || //top vertical, first half
                col >= 42 && col <= 48 && row >= 59 && row <= 60 || 
                col >= 48 && col <= 50 && row >= 53 && row <= 59) //top vertical, second half
                   
                                            oled_data <= 16'b 0000001111110000;
                else if(col >= 74 && col <= 84 && row >= 55 && row <= 57 ||
                        col >= 81 && col <= 86 && row >= (56-(5-(col-81))) && row <=(56+(5-(col-81)))) 
                    oled_data <= 0;                           
            
                else 
                oled_data <= 16'b 11111_111111_11111;
    
        end
        
    end
    
    
     
endmodule


