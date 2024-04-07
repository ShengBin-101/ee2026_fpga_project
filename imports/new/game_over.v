`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2024 03:21:14 PM
// Design Name: 
// Module Name: game_over
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


module game_over(
    input clk_6p25m,
    input [12:0] pixel_index,
    output reg [15:0] oled_data
    );
    
wire [6:0] x = pixel_index % 96;
wire [5:0] y = pixel_index / 96;

//thickness 4-5 pixel, height 24 width 20.
parameter G_X = 3;
parameter G_Y = 7;

parameter A_X = 26;
parameter A_Y = 7;

parameter M_X = 49; // A_X + 20 (width of A) + 3 (gap)
parameter M_Y = 7;

parameter E_X = 72; // M_X + 20 (width of M) + 3 (gap)
parameter E_Y = 7;

parameter O_X = 3; // Same as G_X, aligned with "GAME"
parameter O_Y = 33;

parameter V_X = 26; // O_X + 20 (width of O) + 3 (gap)
parameter V_Y = 33;

parameter E2_X = 49; 
parameter E2_Y = 33;

parameter R_X = 72; // E2_X + 20 (width of E) + 3 (gap)
parameter R_Y = 33;

parameter [15:0] RED    = 16'h8000, GREEN  = 16'h0400, BLUE   = 16'h0010,
                 YELLOW = 16'h8400, MAGENTA= 16'h8010, CYAN   = 16'h0410,
                 ORANGE = 16'h8200, BROWN  = 16'h6200;
                 
reg [23:0] color_cycle_counter = 0;
reg [15:0] temp_color = 0;
                 
reg [15:0] color_G, color_A, color_M, color_E, color_O, color_V, color_E2, color_R;

initial 
begin
    color_G  = RED;    color_A  = GREEN;  color_M  = BLUE;
    color_E  = YELLOW; color_O  = MAGENTA; color_V  = CYAN;
    color_E2 = ORANGE; color_R  = BROWN;
end

always @(posedge clk_6p25m)
begin

    oled_data <= 16'h0000;
    
        color_cycle_counter <= color_cycle_counter + 1;
    if (color_cycle_counter >= 1000000) begin // Adjust based on desired rotation speed
        color_cycle_counter <= 0;
        // Rotate colors in a clockwise direction
        temp_color = color_G;
        color_G  <= color_R;  color_R  <= color_E2;
        color_E2 <= color_V;  color_V  <= color_O;
        color_O  <= color_E;  color_E  <= color_M;
        color_M  <= color_A;  color_A  <= temp_color;
    end

   if (
        // Vertical bar of the "G"
        ((x >= G_X) && (x <= G_X+4) && (y >= G_Y) && (y <= G_Y+24)) || 
        // Top horizontal bar of the "G"
        ((y >= G_Y) && (y <= G_Y+4) && (x >= G_X) && (x <= G_X+20)) ||
        // Bottom horizontal bar of the "G"
        ((y >= G_Y+20) && (y <= G_Y+24) && (x >= G_X) && (x <= G_X+20)) ||
        // Middle horizontal bar to the right of the "G"
        ((y >= G_Y+11) && (y <= G_Y+15) && (x >= G_X+10) && (x <= G_X+20)) ||
        // Closing the "G" on the right
        ((x >= G_X+16) && (x <= G_X+20) && (y >= G_Y+12) && (y <= G_Y+24))
    ) 
    begin
        oled_data <= color_G; // Assuming black color for the "G" (you can change this)
    end
    
    // Logic for "A"
    if (
        // Left vertical bar of the "A"
        ((x >= A_X) && (x <= A_X+4) && (y >= A_Y) && (y <= A_Y+24)) || 
        // Right vertical bar of the "A"
        ((x >= A_X+16) && (x <= A_X+20) && (y >= A_Y) && (y <= A_Y+24)) ||
        // Top horizontal bar of the "A" (to make the top of the "A" look pointed, we start a bit inside)
        ((y >= A_Y) && (y <= A_Y+4) && (x >= A_X+4) && (x <= A_X+16)) ||
        // Middle horizontal bar of the "A"
        ((y >= A_Y+10) && (y <= A_Y+14) && (x >= A_X) && (x <= A_X+20))
    ) 
    begin
        oled_data <= color_A; // Black color for the "A"
    end
    
    if (
        // Left vertical bar of the "M"
        ((x >= M_X) && (x <= M_X+4) && (y >= M_Y) && (y <= M_Y+24)) || 
        // Right vertical bar of the "M"
        ((x >= M_X+16) && (x <= M_X+20) && (y >= M_Y) && (y <= M_Y+24)) ||
        // Middle left slant of the "M"
        ((y  >= M_Y) && (y <= M_Y + 12) && (x - M_X >= 2*(y - M_Y)/3) && (x - M_X <= 2*(y - M_Y)/3 + 4)) ||
        // Middle right slant of the "M"
        ((y >= M_Y) && (y <= M_Y + 12) && (x - M_X >= 16 - 2*(y - M_Y)/3) && (x - M_X <= 20 - 2*(y - M_Y)/3))
    ) 
    begin
        oled_data <= color_M; // Black color for the "M"
    end
    
    if (
        // Vertical bar of the "E"
        ((x >= E_X) && (x <= E_X+4) && (y >= E_Y) && (y <= E_Y+24)) || 
        // Top horizontal bar of the "E"
        ((y >= E_Y) && (y <= E_Y+4) && (x >= E_X) && (x <= E_X+20)) ||
        // Middle horizontal bar of the "E"
        ((y >= E_Y+10) && (y <= E_Y+14) && (x >= E_X) && (x <= E_X+20)) ||
        // Bottom horizontal bar of the "E"
        ((y >= E_Y+20) && (y <= E_Y+24) && (x >= E_X) && (x <= E_X+20))
    ) 
    begin
        oled_data <= color_E; // Black color for the "E"
    end
    
    if (
        // top horizontal bar of the "O"
        ((y >= O_Y) && (y <= O_Y+4) && (x >= O_X) && (x <= O_X+20)) ||
        //  bottom horizontal bar of the "O"
        ((y >= O_Y+20) && (y <= O_Y+24) && (x >= O_X) && (x <= O_X+20)) ||
        //  left vertical bar of the "O"
        ((x >= O_X) && (x <= O_X+4) && (y >= O_Y) && (y <= O_Y+24)) ||
        // right vertical bar of the "O"
        ((x >= O_X+16) && (x <= O_X+20) && (y >= O_Y) && (y <= O_Y+24))
    ) 
    begin
        oled_data <= color_O; // Black color for the "O"
    end
    
    if (    
        // Left side of the "V"
       ((y  >= V_Y) && (y <= V_Y + 24) && (x - V_X >= 1*(y - V_Y)/3) && (x - V_X <= 1*(y - V_Y)/3 + 4)) || //INCREASE 1/4 TO MAKE IT MORE HORIZONTAL. DEACREASE TO MAKE IT MORE VERTICLE
         // right slant of the v
        ((y >= V_Y) && (y <= V_Y + 24) && (x - V_X >= 16 - 1*(y - V_Y)/3) && (x - V_X <= 20 - 1*(y - V_Y)/3)) // SAME HERE
    ) 
    begin
        oled_data <= color_V; // Black color for the "V"
    end
    
    if (
        // Vertical bar of the "E"
        ((x >= E2_X) && (x <= E2_X+4) && (y >= E2_Y) && (y <= E2_Y+24)) || 
        // Top horizontal bar of the "E"
        ((y >= E2_Y) && (y <= E2_Y+4) && (x >= E2_X) && (x <= E2_X+20)) ||
        // Middle horizontal bar of the "E"
        ((y >= E2_Y+10) && (y <= E2_Y+14) && (x >= E2_X) && (x <= E2_X+20)) ||
        // Bottom horizontal bar of the "E"
        ((y >= E2_Y+20) && (y <= E2_Y+24) && (x >= E2_X) && (x <= E2_X+20))
    ) 
    begin
        oled_data <= color_E2; // Black color for the "E"
    end
    
    if (
        // Vertical bar of the "R"
        ((x >= R_X) && (x <= R_X+3) && (y >= R_Y) && (y <= R_Y+23)) || 
        // Top rounded part of the "R", similar to the top of the "O"
        ((y >= R_Y) && (y <= R_Y+3) && (x >= R_X) && (x <= R_X+19)) ||
        ((y >= R_Y+11) && (y <= R_Y+14) && (x >= R_X) && (x <= R_X+19)) ||
        ((x >= R_X+16) && (x <= R_X+19) && (y >= R_Y) && (y <= R_Y+14)) ||
        // Diagonal leg of the "R"
        
        ((y  >= R_Y + 14) && (y <= R_Y + 24) && (x - R_X >= 2*(y - R_Y)/3) && (x - R_X <= 2*(y - R_Y)/3 + 4))
    ) 
    begin
        oled_data <= color_R; // Black color for the "R"
    end
end
endmodule


