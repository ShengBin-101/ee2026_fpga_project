module group_project (
input clk,
output [7:0] JC,

input [1:0]sw,

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
    
    assign JC[2] = 0;
    
    flexible_clock clk6p25m (.clock(clk), .m(7), .state(clk_6p25m));
    
    Oled_Display oled_unit_A (.clk(clk_6p25m),
    .reset(0),
    .frame_begin(unused1),
    .sending_pixels(unused2),
    .sample_pixel(unused3),
    .pixel_index(pixel_index), //
    .pixel_data(oled_data), // colour of led
    .cs(JC[0]),
    .sdin(JC[1]),
    .sclk(JC[3]),
    .d_cn(JC[4]),
    .resn(JC[5]),
    .vccen(JC[6]),
    .pmoden(JC[7]));
    
    
       //bomb_enter_left enter_left(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(oled_data));
       //bomb_enter_right enter_right(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(oled_data));
       // bomb_leave_left leave_left(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(oled_data));
       //bomb_leave_right leave_right(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(oled_data));
      //bomb_explode explode(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(oled_data));
     // bomb_at_center center(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(oled_data));
       // game_over game_over(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(oled_data));
       you_win you_win(.clk_6p25m(clk_6p25m), .pixel_index(pixel_index), .oled_data(you_win_wire));
    always @(posedge clk)
    begin
        if (sw[1])
        begin
            oled_data <= you_win_wire;
        end
    end
endmodule