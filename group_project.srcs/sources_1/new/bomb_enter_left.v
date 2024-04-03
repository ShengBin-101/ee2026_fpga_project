`timescale 1ns / 1ps

module bomb_enter_left(
    input clk_6p25m,
    input [12:0] pixel_index,
    output reg [15:0] oled_data,
    
    input [1:0] start_animation,
    input [27:0] bomb_animation_rate //bomb expansion and contraction rate
);

wire [6:0] x = pixel_index % 96;
wire [5:0] y = pixel_index / 96;

parameter bomb_speed = 62500;

// Circle properties
parameter circle_radius = 16;
reg [15:0] circle_x = 0; // Starting position of the circle on the x-axis
reg [15:0] circle_y = 32; // Position of the circle on the y-axis (centered)
reg [27:0] circle_move_counter = 0;

//rectangle properties
parameter rect_width = 8;
parameter rect_height = 8;
reg [15:0] rect_x = 0; // Starting position of the rectangle on the x-axis centre
reg [15:0] rect_y = 14; // Starting position of the rectangle on the y-axis centre
reg [27:0] rectangle_move_counter = 0;

//fuse properties
parameter fuse_1_length = 30; // Initial length of the fuse
reg [15:0] fuse_1_x = 0; // Starting x-position of the fuse
reg [15:0] fuse_1_y = 9; // left of the fuse
reg [27:0] fuse_1_move_counter = 0; // Counter for the fuse animation

parameter fuse_2_length = 3; // Initial length of the fuse
reg [15:0] fuse_2_x = 0; // Starting x-position of the fuse (connected to the circle initially)
reg [15:0] fuse_2_y = 9; // top of the fuse
reg [27:0] fuse_2_move_counter = 0; // Counter for the fuse animation

// fire properties
parameter fire_radius = 4;
reg [15:0] fire_x = 0 + fuse_1_length; // Starting position of the fire. always at end of fuse 1
reg [15:0] fire_y = 9; // Position of the circle on the y-axis (centered)
reg [27:0] fire_move_counter = 0;

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
    if (start_animation == 1)
    begin
        // Default to white background
        oled_data <= 16'hFFFF;
        
    
        circle_move_counter <= circle_move_counter + 1;
        if (circle_move_counter > bomb_speed)
        begin
            circle_move_counter <= 0;
            if (circle_x < 46) //control where circle stops
            begin
                circle_x <= circle_x + 1; // Move the circle right by 1 pixel each clock cycle
            end
        end
        
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
        
        
        //rectangle movement
        rectangle_move_counter <= rectangle_move_counter + 1;
        if (rectangle_move_counter >= bomb_speed) begin
            rectangle_move_counter <= 0; // Reset counter
            // Move rectangle to the right.
            if (rect_x < 46) //control where rectangle stops . increase to stop more right. decrease to stop more left
            begin
                rect_x <= rect_x + 1;
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
            if (fuse_1_x < 46) //end point of the fuse
            begin 
                fuse_1_x <= fuse_1_x + 1; // move the fuse to right
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
            if (fuse_2_x < 46) //end point of the fuse
            begin 
                fuse_2_x <= fuse_2_x + 1; // move fuse right
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
            if (fire_x < 46 + fuse_1_length) //control where circle stops
            begin
                fire_x <= fire_x + 1; // Move the circle right by 1 pixel each clock cycle
            end
        end
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
    
    else
    begin
        circle_x  <= 0;
        rect_x <= 0;
        fuse_1_x <= 0;
        fuse_2_x <= 0;
        fire_x = 0 + fuse_1_length;
    end
        
      
end

endmodule    
