`timescale 1ns / 1ps



module bomb_at_center(
    input clk_6p25m,
    input [12:0] pixel_index,
    output reg [15:0] oled_data,
    
    input [27:0] bomb_animation_rate
);

wire [6:0] x = pixel_index % 96;
wire [5:0] y = pixel_index / 96;

// Circle properties
parameter circle_radius = 16;
reg [15:0] circle_x = 46; // Starting position of the circle on the x-axis
reg [15:0] circle_y = 32; // Position of the circle on the y-axis (centered)
reg [27:0] circle_move_counter = 0;

//rectangle properties
parameter rect_width = 8;
parameter rect_height = 8;
reg [15:0] rect_x = 46; // Starting position of the rectangle on the x-axis centre
reg [15:0] rect_y = 14; // Starting position of the rectangle on the y-axis centre
reg [27:0] rectangle_move_counter = 0;

// horizontal fuse properties
parameter fuse_1_length = 30; // Initial length of the fuse
reg [15:0] dynamic_fuse_1_length = 30; // always set as same value as fuse_1_length
reg [15:0] fuse_1_x = 46; // Starting x-position of the fuse. left most corner
reg [15:0] fuse_1_y = 9; // starting y-position of the fuse
reg [27:0] fuse_1_move_counter = 0; // Counter for the fuse animation

// verical fuse properties
parameter fuse_2_length = 3; // Initial length of the fuse
reg [15:0] fuse_2_x = 46; // Starting x-position of the fuse. 
reg [15:0] fuse_2_y = 9; // top of the fuse
reg [27:0] fuse_2_move_counter = 0; // Counter for the fuse animation

// fire properties
parameter fire_radius = 4;
reg [15:0] fire_x = 46 + fuse_1_length; // Starting position of the fire. always at end of fuse 1
reg [15:0] fire_y = 9; // Position of the circle on the y-axis (centered)
reg [27:0] fire_move_counter = 0;

//fire move to bomb counter
reg [27:0] counter = 0;

// Explosion properties
reg [15:0] explosion_radius = 0; // Radius of the explosion
reg [27:0] explosion_counter = 0; // Counter for explosion animation
reg explosion_active = 0; // Flag to indicate if the explosion animation is active
parameter explosion_max_radius = 20; // Maximum radius of the explosion
parameter explosion_rate = 100000; // Speed of explosion expansion

// Fire properties for pulsating effect
reg [5:0] pulsating_fire_radius = fire_radius_initial; // Current radius of the fire, initialize appropriately
parameter fire_radius_initial = 4; // Starting radius of the fire
parameter fire_radius_max = 8; // Maximum radius of the fire for pulsating effect
parameter fire_growth_rate = 50000; // Speed of fire growth and shrinkage
reg [27:0] fire_counter = 0;
reg fire_growing = 1; // Indicates whether the fire is growing or shrinking

//bomb expanding and contracting
parameter bomb_radius_min = 14; // Minimum radius of the bomb for contraction
parameter bomb_radius_max = 18; // Maximum radius of the bomb for expansion
//parameter bomb_animation_rate = 1562500; // Speed of bomb expansion and contraction
reg [15:0] dynamic_circle_radius = bomb_radius_min; // Dynamic radius of the circle
reg bomb_expanding = 1; // Flag to track whether the bomb is expanding or contracting
reg [27:0] bomb_animation_counter = 0; // Counter for bomb animation timing


always @(posedge clk_6p25m) begin
    // Default to white background
    oled_data <= 16'hFFFF;
        
        
    //circle 
    bomb_animation_counter <= bomb_animation_counter + 1;
    if (bomb_animation_counter >= bomb_animation_rate) 
    begin
        bomb_animation_counter <= 0; // Reset the counter for the next step
        if (bomb_expanding) 
        begin
            if (dynamic_circle_radius < bomb_radius_max) 
            begin
                dynamic_circle_radius <= dynamic_circle_radius + 1;
            end 
            else 
            begin
                bomb_expanding <= 0; // Start contracting
            end
        end 
        else //contracting bomb
        begin
            if (dynamic_circle_radius > bomb_radius_min) 
            begin
                dynamic_circle_radius <= dynamic_circle_radius - 1;
            end 
            else 
            begin
                bomb_expanding <= 1; // Start expanding
            end
        end
    end

    // Drawing the bomb with dynamic radius
    if ((x - circle_x)**2 + (y - circle_y)**2 <= dynamic_circle_radius**2) begin
        oled_data <= 16'h0000; // Color the pixel black if within the dynamic circle radius
    end

    
    
    //rectangle 
    if (x > (rect_x - rect_width/2) && x <= (rect_x + rect_width/2) && y > (rect_y - rect_height/2) && y <= (rect_y + rect_height/2))
    begin
        oled_data <= 16'h0000; // Color the pixel black if within the rectangle
    end
    
    
    // horizontal fuse
    if (x >= fuse_1_x && x <= fuse_1_x + dynamic_fuse_1_length && y == fuse_1_y) 
    begin
        oled_data <= 16'hF800; // Color the pixel red 
    end
    
    
    // vertical fuse
    if (y >= fuse_2_y && y <= fuse_2_y + fuse_2_length && x == fuse_2_x) 
    begin
        oled_data <= 16'hF800; // Color the pixel red 
    end
    
    
    // fire 
    if ((x - fire_x)**2 + (y - fire_y)**2 <= fire_radius**2) 
    begin
        oled_data <= 16'hFC00; // orange
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