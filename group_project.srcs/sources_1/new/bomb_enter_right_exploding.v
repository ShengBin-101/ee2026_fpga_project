`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2024 10:53:32 PM
// Design Name: 
// Module Name: bomb_enter_right_exploding
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2024 06:04:17 PM
// Design Name: 
// Module Name: bomb_enter_left
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

module bomb_enter_right_exploding(
    input clk_6p25m,
    input [12:0] pixel_index,
    output reg [15:0] oled_data
);

wire [6:0] x = pixel_index % 96;
wire [5:0] y = pixel_index / 96;

parameter bomb_speed = 100000;

// Circle properties
parameter circle_radius = 16;
reg [15:0] circle_x = 95; // Starting position of the circle on the x-axis
reg [15:0] circle_y = 32; // Position of the circle on the y-axis (centered)
reg [27:0] circle_move_counter = 0;

//rectangle properties
parameter rect_width = 8;
parameter rect_height = 5;
reg [15:0] rect_x = 95; // Starting position of the rectangle on the x-axis centre
reg [15:0] rect_y = 14; // Starting position of the rectangle on the y-axis centre
reg [27:0] rectangle_move_counter = 0;

//fuse properties
parameter fuse_1_length = 30; // Initial length of the fuse
reg [15:0] fuse_1_x = 95; // Starting x-position of the fuse
reg [15:0] fuse_1_y = 9; // left of the fuse
reg [27:0] fuse_1_move_counter = 0; // Counter for the fuse animation

parameter fuse_2_length = 3; // Initial length of the fuse
reg [15:0] fuse_2_x = 95; // Starting x-position of the fuse (connected to the circle initially)
reg [15:0] fuse_2_y = 9; // top of the fuse
reg [27:0] fuse_2_move_counter = 0; // Counter for the fuse animation

// fire properties
parameter fire_radius = 4;
reg [15:0] fire_x = 95 + fuse_1_length; // Starting position of the fire. always at end of fuse 1
reg [15:0] fire_y = 9; // Position of the circle on the y-axis (centered)
reg [27:0] fire_move_counter = 0;

// Continuous Explosion properties
reg [5:0] explosion_radius = 0;
parameter explosion_max_radius = 16;
parameter explosion_growth_rate = 250; // Speed of explosion growth
parameter explosion_pause_duration = 10000; // Pause between explosions
reg [27:0] explosion_counter = 0;
reg [15:0] explosion_color = 16'hFC00; // Initial explosion color, e.g., orange
reg explosion_growing = 1; // Indicates whether the explosion is growing or shrinking

// Fire properties for pulsating effect
reg [5:0] pulsating_fire_radius = fire_radius_initial; // Current radius of the fire, initialize appropriately
parameter fire_radius_initial = 4; // Starting radius of the fire
parameter fire_radius_max = 8; // Maximum radius of the fire for pulsating effect
parameter fire_growth_rate = 50000; // Speed of fire growth and shrinkage
reg [27:0] fire_counter = 0;
reg fire_growing = 1; // Indicates whether the fire is growing or shrinking



always @(posedge clk_6p25m) begin
    // Default to white background
    oled_data <= 16'hFFFF;
    

    circle_move_counter <= circle_move_counter + 1;
    if (circle_move_counter > bomb_speed)
    begin
        circle_move_counter <= 0;
        if (circle_x > 46) //control where circle stops
        begin
            circle_x <= circle_x - 1; // Move the circle right by 1 pixel each clock cycle
        end
    end
    
    // Check if current pixel is within the circle's area
    if ((x - circle_x)**2 + (y - circle_y)**2 <= circle_radius**2) 
    begin
        oled_data <= 16'h0000; // Color the pixel black if within the circle
    end
    
    
    //rectangle movement
    rectangle_move_counter <= rectangle_move_counter + 1;
    if (rectangle_move_counter >= bomb_speed) begin
        rectangle_move_counter <= 0; // Reset counter
        // Move rectangle to the right.
        if (rect_x > 46) //control where rectangle stops . increase to stop more right. decrease to stop more left
        begin
            rect_x <= rect_x - 1;
        end
    end
    
    // Check if current pixel is within the rectangle's area
    if (x > (rect_x - rect_width/2) && x <= (rect_x + rect_width/2) && y > (rect_y - rect_height/2) && y <= (rect_y + rect_height/2))
    begin
        oled_data <= 16'h0000; // Color the pixel black if within the rectangle
    end
    
    
    // horizontal fuse movement
    fuse_1_move_counter <= fuse_1_move_counter + 1;
    if (fuse_1_move_counter >= bomb_speed) 
    begin
        fuse_1_move_counter <= 0; // Reset counter
        if (fuse_1_x > 46) //end point of the fuse
        begin 
            fuse_1_x <= fuse_1_x - 1; // move the fuse to right
        end
    end
    if (x >= fuse_1_x && x <= fuse_1_x + fuse_1_length && y == fuse_1_y) 
    begin
        oled_data <= 16'hF800; // Color the pixel red 
    end
    
    
    // vertical fuse movement
    fuse_2_move_counter <= fuse_2_move_counter + 1;
    if (fuse_2_move_counter >= bomb_speed) 
    begin
        fuse_2_move_counter <= 0; // Reset counter
        if (fuse_2_x > 46) //end point of the fuse
        begin 
            fuse_2_x <= fuse_2_x - 1; // move fuse right
        end
    end
    if (y >= fuse_2_y && y <= fuse_2_y + fuse_2_length && x == fuse_2_x) 
    begin
        oled_data <= 16'hF800; // Color the pixel red 
    end
    
    
    // fire movement
    fire_move_counter <= fire_move_counter + 1;
    if (fire_move_counter > bomb_speed)
    begin
        fire_move_counter <= 0;
        if (fire_x > 46 + fuse_1_length) //control where circle stops
        begin
            fire_x <= fire_x - 1; // Move the circle right by 1 pixel each clock cycle
        end
    end
    
    //fire logic
    if ((x - fire_x)**2 + (y - fire_y)**2 <= fire_radius**2) 
    begin
        oled_data <= 16'hFC00; // orange
    end 
    
    
    // Continuous explosion logic
    explosion_counter <= explosion_counter + 1;
    if (explosion_growing) begin
        // If the explosion is growing and reaches the maximum size, start shrinking
        if (explosion_radius >= explosion_max_radius || explosion_counter >= explosion_growth_rate) begin
            explosion_counter <= 0;
            explosion_radius <= explosion_radius + 1;
            explosion_color <= (explosion_color == 16'hFC00) ? 16'hFEA0 : 16'hFC00; // Flicker effect
            if (explosion_radius == explosion_max_radius) begin
                explosion_growing <= 0; // Start shrinking
            end
        end
    end else begin
        // If the explosion is shrinking and disappears, pause and then grow again
        if (explosion_radius == 0 && explosion_counter >= explosion_pause_duration) begin
            explosion_counter <= 0;
            explosion_growing <= 1; // Start growing
        end else if (explosion_radius > 0) begin
            explosion_radius <= explosion_radius - 1;
        end
    end

    // Draw the explosion
    if ((x - circle_x)**2 + (y - circle_y)**2 <= explosion_radius**2) begin
        oled_data <= explosion_color;
    end
    
        // Pulsating fire logic
    fire_counter <= fire_counter + 1;
    if (fire_growing) begin
        // If the fire is growing and reaches the maximum size, start shrinking
        if (pulsating_fire_radius >= fire_radius_max || fire_counter >= fire_growth_rate) begin
            fire_counter <= 0;
            pulsating_fire_radius <= pulsating_fire_radius + 1;
            if (pulsating_fire_radius == fire_radius_max) begin
                fire_growing <= 0; // Start shrinking
            end
        end
    end else begin
        // If the fire is shrinking and reaches the minimum size, start growing
        if (pulsating_fire_radius == fire_radius_initial || fire_counter >= fire_growth_rate) begin
            fire_counter <= 0;
            if (pulsating_fire_radius > fire_radius_initial) begin
                pulsating_fire_radius <= pulsating_fire_radius - 1;
            end else begin
                fire_growing <= 1; // Start growing
            end
        end
    end

    // Fire drawing with pulsating effect
    if ((x - fire_x)**2 + (y - fire_y)**2 <= pulsating_fire_radius**2) begin
        oled_data <= 16'hFC00; // Orange color for the fire
    end
      
end

endmodule    