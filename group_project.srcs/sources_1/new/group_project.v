module group_project (
input clk,
output [7:0] JXADC,

input [15:0]sw,

//task A2
input btnC,
input btnD,
input btnL,
input btnU,
input btnR
);

    wire clk_6p25m;
    wire unused1;
    wire unused2;
    wire unused3;
    wire [12:0] pixel_index;
    reg [15:0] oled_data;
    
    wire [15:0] you_win_wire;
    wire [15:0] game_over_wire;
    wire [15:0] bomb_enter_left_wire;
    wire [15:0] bomb_enter_right_wire;
    wire [15:0] bomb_leave_left_wire;
    wire [15:0] bomb_leave_right_wire;
    wire [15:0] bomb_explode_wire;
    wire [15:0] bomb_at_center_wire;
    wire[15:0] start_wire;
    
    reg [1:0] start_animation = 0;
    reg [27:0] bomb_animation_rate = 0;
    
    assign JXADC[2] = 0;
    
    flexible_clock clk6p25m (.clock(clk), .m(7), .state(clk_6p25m));
    
    Oled_Display oled_unit_A (.clk(clk_6p25m),
    .reset(0),
    .frame_begin(unused1),
    .sending_pixels(unused2),
    .sample_pixel(unused3),
    .pixel_index(pixel_index), //
    .pixel_data(oled_data), // colour of led
    .cs(JXADC[0]),
    .sdin(JXADC[1]),
    .sclk(JXADC[3]),
    .d_cn(JXADC[4]),
    .resn(JXADC[5]),
    .vccen(JXADC[6]),
    .pmoden(JXADC[7]));
    
    
    

        
 
       start start_screen(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(start_wire));
       bomb_enter_left enter_left(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(bomb_enter_left_wire), .start_animation(start_animation), .bomb_animation_rate(bomb_animation_rate));
       bomb_enter_right enter_right(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(bomb_enter_right_wire), .start_animation(start_animation), .bomb_animation_rate(bomb_animation_rate));
       bomb_leave_left leave_left(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(bomb_leave_left_wire), .start_animation(start_animation), .bomb_animation_rate(bomb_animation_rate));
       bomb_leave_right leave_right(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(bomb_leave_right_wire), .start_animation(start_animation), .bomb_animation_rate(bomb_animation_rate));
       bomb_explode explode(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(bomb_explode_wire), .start_animation(start_animation));
       bomb_at_center center(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(bomb_at_center_wire), .bomb_animation_rate(bomb_animation_rate));
       game_over game_over(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(game_over_wire));
       you_win you_win(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(you_win_wire));
       
    always @(posedge clk) //player A
    begin
        if (sw[9]) //game phase
        begin
            start_animation <= 0; //reset allanimation
              
              if (sw[7]) //start screen
              begin
                  oled_data <= start_wire;
              end
            
            if (sw[1]) //no bomb
            begin
                oled_data <= 16'h FFFF;
            end
            
            if(btnD) //BOMB EXPLODE
            begin
                oled_data <= bomb_explode_wire;
                start_animation <= 1;
            end
            
            if (btnU) //BOMB ENTER LEFT
            begin
                oled_data <= bomb_enter_left_wire;
                start_animation <= 1;
            end
            
            if(btnR) //bomb enter right
            begin
                oled_data <= bomb_enter_right_wire;
                start_animation <= 1;
            end
            
            if(btnC) //bomb leave right
            begin
                oled_data <= bomb_leave_right_wire;
                start_animation <= 1;
            end
            
            if(btnL) //bomb leave left
            begin
                oled_data <= bomb_leave_left_wire;
                start_animation <= 1;
            end
            
            if (sw[2] && sw[3]) //game_end and bomb not exploded
            begin
                oled_data <= you_win_wire;
            end
            
            if (sw[2] && sw[4]) // game end and bomb exploded
            begin
                oled_data <= game_over_wire;
            end
            
            
            
            //bomb_animation_rate or the quaters of the game
            if (sw[15]) // quater 0
            begin
                bomb_animation_rate = 1171875;
            end
            else if (sw[14]) //q1
            begin
                bomb_animation_rate <= 937500;
            end
            else if (sw[13]) //q2
            begin
                bomb_animation_rate <= 703125;
            end
            else if (sw[12]) //q3
            begin
                bomb_animation_rate <= 468750;
            end
                
        end
        
    end
endmodule