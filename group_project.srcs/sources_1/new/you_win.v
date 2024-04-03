`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 07:08:02 PM
// Design Name: 
// Module Name: you_win
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


module you_win(
    input clk_6p25m,
    input [12:0] pixel_index,
    output reg [15:0] oled_data
);

wire [6:0] x = pixel_index % 96;
wire [5:0] y = pixel_index / 96;

parameter Y_X = 15;
parameter Y_Y = 7;

parameter O_X = 38;
parameter O_Y = 7;

parameter U_X = 61;
parameter U_Y = 7;

parameter W_X = 15;
parameter W_Y = 33;

parameter I_X = 38;
parameter I_Y = 33;

parameter N_X = 61;
parameter N_Y = 33;

parameter [15:0] RED = 16'hF800, GREEN = 16'h07E0, BLUE = 16'h001F,
                 YELLOW = 16'hFFE0, CYAN = 16'h07FF, MAGENTA = 16'hF81F;

reg [23:0] color_cycle_counter = 0; // Counter for cycling colors
reg [15:0] current_color_Y = RED, current_color_O = GREEN, current_color_U = BLUE,
           current_color_W = YELLOW, current_color_I = CYAN, current_color_N = MAGENTA;
           
reg [15:0] temp_color = 0;

always @(posedge clk_6p25m)
begin
    oled_data <= 16'h0000;
    
    color_cycle_counter <= color_cycle_counter + 1;
        if (color_cycle_counter >= 1000000) begin // Adjust for desired color change speed
            color_cycle_counter <= 0;
            
            // Rotate colors
            temp_color = current_color_Y;
            current_color_Y = current_color_O;
            current_color_O = current_color_U;
            current_color_U = current_color_W;
            current_color_W = current_color_I;
            current_color_I = current_color_N;
            current_color_N = temp_color;
        end
    
    //letter Y
    if (
        // Left diagonal arm of the "Y"
        ((y >= Y_Y) && (y < Y_Y + 12) && (x - Y_X >= 2 * (y - Y_Y) / 3) && (x - Y_X <= 2 * (y - Y_Y) / 3 + 4)) ||
        // Right diagonal arm of the "Y"
        ((y >= Y_Y) && (y < Y_Y + 12) && ((20 - (x - Y_X)) >= 2 * (y - Y_Y) / 3) && ((20 - (x - Y_X)) <= 2 * (y - Y_Y) / 3 + 4)) ||
        // Vertical line of the "Y"
        ((y >= Y_Y + 12) && (y <= Y_Y + 24) && (x >= Y_X + 8) && (x <= Y_X + 12))
    )
    begin
        oled_data <= current_color_Y; // Color the pixel with the color of "Y"
    end
    
    //letter O
    if (
        // Top horizontal rectangle
        (y >= O_Y) && (y <= O_Y+4) && (x >= O_X) && (x <= O_X+20) ||
        // Bottom horizontal rectangle
        (y >= O_Y+20) && (y <= O_Y+24) && (x >= O_X) && (x <= O_X+20) ||
        // Left vertical rectangle
        (x >= O_X) && (x <= O_X+4) && (y >= O_Y) && (y <= O_Y+24) ||
        // Right vertical rectangle
        (x >= O_X+16) && (x <= O_X+20) && (y >= O_Y) && (y <= O_Y+24)
    ) 
    begin
        oled_data <= current_color_O; // Color the pixel with the color of "O"
    end
    
    //letter U
    if (
        // Left vertical rectangle of the "U"
        (x >= U_X) && (x <= U_X+4) && (y >= U_Y) && (y <= U_Y+24) ||
        // Right vertical rectangle of the "U"
        (x >= U_X+16) && (x <= U_X+20) && (y >= U_Y) && (y <= U_Y+24) ||
        // Bottom horizontal rectangle of the "U"
        (y >= U_Y+20) && (y <= U_Y+24) && (x >= U_X) && (x <= U_X+20)
    )
    begin
        oled_data <= current_color_U; // Color the pixel with the color of "O"
    end
    
    //letter W
    if (
        // Left vertical bar of the "W"
        ((x >= W_X) && (x <= W_X+4) && (y >= W_Y) && (y <= W_Y+24)) || 
        // Right vertical bar of the "W"
        ((x >= W_X+16) && (x <= W_X+20) && (y >= W_Y) && (y <= W_Y+24)) ||
        // Bottom left slant of the "W"
        ((y >= W_Y + 12) && (y <= W_Y + 24) && (x - W_X >= -2*(y - W_Y - 24)/3) && (x - W_X <= -2*(y - W_Y - 24)/3 + 4)) ||
        // Bottom right slant of the "W"
        ((y >= W_Y + 12) && (y <= W_Y + 24) && (x >= W_X  + 2*(y - W_Y)/ 3) && (x <= W_X + 4 + 2*(y - W_Y)/3))
    )
    begin
        oled_data <= current_color_W; // Color the pixel with the color of "O"
    end 

    //letter I
    if (
        // Top horizontal rectangle of the "I"
        (y >= I_Y) && (y <= I_Y + 4) && (x >= I_X + 2) && (x <= I_X + 18) ||
        // Bottom horizontal rectangle of the "I"
        (y >= I_Y + 20) && (y <= I_Y + 24) && (x >= I_X + 2) && (x <= I_X + 18) ||
        // Center vertical rectangle of the "I"
        (x >= I_X + 8) && (x <= I_X + 12) && (y >= I_Y) && (y <= I_Y + 24)
    )
    begin
        oled_data <= current_color_I; // Color the pixel with the color of "O"
    end
    
    //letter N
    if (
        // Left vertical rectangle of the "N"
        (x >= N_X) && (x <= N_X + 4) && (y >= N_Y) && (y <= N_Y + 24) ||
        // Right vertical rectangle of the "N"
        (x >= N_X + 16) && (x <= N_X + 20) && (y >= N_Y) && (y <= N_Y + 24) ||
        // Diagonal rectangle of the "N"
        ((y >= N_Y) && (y <= N_Y + 24) && (x - N_X >= 2 * (y - N_Y) / 3) && (x - N_X <= 2 * (y - N_Y) / 3 + 4))
    )
    begin
        oled_data <= current_color_N; // Color the pixel with the color of "O"
    end 
   
    
end

endmodule
