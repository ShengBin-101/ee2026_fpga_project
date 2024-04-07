`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2024 07:41:19 PM
// Design Name: 
// Module Name: start
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


module start(

    input clk_6p25m,
    input [12:0] pixel_index,
    output reg [15:0] oled_data
    );
    
wire [6:0] x = pixel_index % 96;
wire [5:0] y = pixel_index / 96;

parameter S_X = 6;
parameter S_Y = 19;

parameter T_X = 23; 
parameter T_Y = 19;

parameter A_X = 40; 
parameter A_Y = 19;

parameter R_X = 38 + 15 + 2 + 2;
parameter R_Y = 19;

parameter T2_X = R_X + 15 + 2 + 2;
parameter T2_Y = 19;

// Brighter color definitions
parameter [15:0] BRIGHT_RED    = 16'hF800, BRIGHT_GREEN  = 16'h07E0, BRIGHT_BLUE   = 16'h001F,
                 BRIGHT_YELLOW = 16'hFFE0, BRIGHT_MAGENTA= 16'hF81F, BRIGHT_CYAN   = 16'h07FF,
                 BRIGHT_ORANGE = 16'hFC00, BRIGHT_WHITE  = 16'hFFFF;


reg [23:0] color_cycle_counter = 0;
reg [15:0] temp_color = 0;
                 
reg [15:0] color_S, color_T, color_A, color_R, color_T2;


initial 
begin
    color_S  = BRIGHT_RED;    
    color_T  = BRIGHT_GREEN;  
    color_A  = BRIGHT_BLUE;
    color_R  = BRIGHT_YELLOW; 
    color_T2 = BRIGHT_MAGENTA;
end

always @(posedge clk_6p25m)
begin

    oled_data <= 16'h0000;
    
    
    color_cycle_counter <= color_cycle_counter + 1;
    if (color_cycle_counter >= 1000000) // Adjust based on desired speed
    begin
        color_cycle_counter <= 0;
        // Rotate colors in a specified direction
        temp_color = color_S;
        color_S  <= color_T2;
        color_T2 <= color_R;
        color_R  <= color_A;
        color_A  <= color_T;
        color_T  <= temp_color;
    end
    
    // letter S
    if (
        // Top horizontal rectangle of the "S"
        ((y >= S_Y) && (y <= S_Y+3) && (x >= S_X) && (x <= S_X+15)) ||
        // Middle horizontal rectangle of the "S"
        ((y >= S_Y+10) && (y <= S_Y+13) && (x >= S_X) && (x <= S_X+15)) ||
        // Bottom horizontal rectangle of the "S"
        ((y >= S_Y+20) && (y <= S_Y+23) && (x >= S_X) && (x <= S_X+15)) ||
        // Upper left vertical rectangle
        ((x >= S_X) && (x <= S_X+3) && (y >= S_Y+4) && (y <= S_Y+9)) ||
        // Lower left vertical rectangle
        ((x >= S_X) && (x <= S_X+3) && (y >= S_Y+16) && (y <= S_Y+19)) ||
        // Upper right vertical rectangle
        ((x >= S_X+12) && (x <= S_X+15) && (y >= S_Y+4) && (y <= S_Y+7)) ||
        // Lower right vertical rectangle
        ((x >= S_X+12) && (x <= S_X+15) && (y >= S_Y+14) && (y <= S_Y+19))
    )
    begin
        oled_data <= color_S; // Color for the "S"
    end
    
    // letter T
    if (
        // Top horizontal bar of the "T"
        ((y >= T_Y) && (y <= T_Y+3) && (x >= T_X) && (x <= T_X+15)) || 
        // Vertical bar of the "T"
        ((x >= T_X+6) && (x <= T_X+9) && (y > T_Y) && (y <= T_Y+23))
    )
    begin
        oled_data <= color_T; // Assigning color for "T"
    end
    
    // A
    if (
        // Left vertical bar of the "A"
        ((x >= A_X) && (x <= A_X+3) && (y >= A_Y) && (y <= A_Y+23)) ||
        // Right vertical bar of the "A"
        ((x >= A_X+12) && (x <= A_X+15) && (y >= A_Y) && (y <= A_Y+23)) ||
        // Middle crossbar of the "A"
        ((y >= A_Y+10) && (y <= A_Y+13) && (x >= A_X) && (x <= A_X+15)) ||
        // Top bar of the "A" (adjusted to maintain rectangular shapes)
        ((y >= A_Y) && (y <= A_Y+3) && (x >= A_X+4) && (x <= A_X+11))
    )
    begin
        oled_data <= color_A; // Assigning color for "A"
    end
    
    //R
    if (
        // Vertical bar of the "R"
        ((x >= R_X) && (x <= R_X+3) && (y >= R_Y) && (y <= R_Y+23)) || 
        // Top horizontal part of the rounded part of the "R"
        ((y >= R_Y) && (y <= R_Y+3) && (x >= R_X) && (x <= R_X+15)) ||
        // Bottom horizontal part of the rounded part, creating the middle segment
        ((y >= R_Y+11) && (y <= R_Y+14) && (x >= R_X) && (x <= R_X+15)) ||
        // Right-side closure of the rounded part of the "R"
        ((x >= R_X+12) && (x <= R_X+15) && (y >= R_Y) && (y <= R_Y+14)) ||
        // Diagonal leg of the "R", maintaining the relationship similar to your example
        ((y >= R_Y+14) && (y <= R_Y+23) && ((x - R_X) >= 2*(y - R_Y)/3) && ((x - R_X) <= 2*(y - R_Y)/3 + 3))
    )
    begin
        oled_data <= color_R; // Assigning color for "A"
    end
    
    if (
        // Top horizontal bar of the "T"
        ((y >= T2_Y) && (y <= T2_Y+3) && (x >= T2_X) && (x <= T2_X+15)) || 
        // Vertical bar of the "T"
        ((x >= T2_X+6) && (x <= T2_X+9) && (y > T2_Y) && (y <= T2_Y+23))
    )
    begin
        oled_data <= color_T2; 
    end
    
end
endmodule
