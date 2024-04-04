`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  Sheng Bin
//
//////////////////////////////////////////////////////////////////////////////////

`include "constants.vh"

module Top_Student (
    input basys_clk,
    input btnU, btnL, btnR, btnD, btnC, 
    input [15:0] SW,
    output [7:0] JC,
    output [7:0] JXADC,
    output reg [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an,
    output dp,
    inout PS2Clk, PS2Data,
    input RX_from_B,        // Connection between Master (Board A) and (Board B)
    output TX_to_B,         // Connection between Master (Board A) and (Board B)
    input B_start_round_from_m,
    output reg start_round_to_B,
    input left_press_from_B,
    input right_press_from_B,
    output reg B_left_press_to_m,
    output reg B_right_press_to_m
);

    assign JC[2] = 0; // Some boards require JC[2] to be cleared to 0 for OLED to work

    // =============== Instantiate OLED Module ====================
    reg [15:0] oled_data_pw;
    
    wire frame_begin_pw, sending_pixels_pw, sample_pixel_pw; 
    wire [12:0] pixel_index_pw;
    // clk for oled
    
    wire clk_6p25m;
    flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
         
    Oled_Display oled_password(
        .clk(clk_6p25m), 
        .reset(0), 
        .frame_begin(frame_begin_pw), 
        .sending_pixels(sending_pixels_pw),
        .sample_pixel(sample_pixel_pw), 
        .pixel_index(pixel_index_pw), 
        .pixel_data(oled_data_pw), 
        .cs(JC[0]), 
        .sdin(JC[1]), 
        .sclk(JC[3]), 
        .d_cn(JC[4]), 
        .resn(JC[5]), 
        .vccen(JC[6]),
        .pmoden(JC[7]));


    reg [15:0] oled_data_bomb;
    wire frame_begin_bomb, sending_pixels_bomb, sample_pixel_bomb; 
    wire [12:0] pixel_index_bomb;
    Oled_Display oled_bomb(
        .clk(clk_6p25m), 
        .reset(0), 
        .frame_begin(frame_begin_bomb), 
        .sending_pixels(sending_pixels_bomb),
        .sample_pixel(sample_pixel_bomb), 
        .pixel_index(pixel_index_bomb), 
        .pixel_data(oled_data_bomb), 
        .cs(JXADC[0]), 
        .sdin(JXADC[1]), 
        .sclk(JXADC[3]), 
        .d_cn(JXADC[4]), 
        .resn(JXADC[5]), 
        .vccen(JXADC[6]),
        .pmoden(JXADC[7]));
       // =============== UART ====================
            // Connection Signals
       wire rx_B_full, rx_B_empty;
       reg read_signal;
       reg send_signal;
       wire [15:0] rec_data_from_B;
       reg [15:0] write_data_to_B;
       // Master Board A Transmit to and Receive from Board B
       
        reg [1:0] game_state;
        wire reset_signal;
        reg uart_reset;
        assign reset_signal =(SW[11]) || uart_reset;
        // UART Module connecting Board A and B
        uart_module UART_UNIT_B(
            .clk_100MHz(basys_clk),
            .reset(reset_signal),
            .read_uart(read_signal),
            .write_uart(send_signal),
            .rx(RX_from_B),
            .write_data(write_data_to_B[15:0]), 
            .rx_full(rx_B_full),
            .rx_empty(rx_B_empty),
            .read_data(rec_data_from_B[15:0]),
            .tx(TX_to_B)
        );
        

    wire [1:0] board_type;
    master_select master_select_module(basys_clk, SW[15], SW[14], SW[13], board_type);
    
    // clk for 7-segment
    wire clk_200;
    flexible_clock_module clk_200_module(basys_clk, 249999 ,clk_200);
    wire clk_1;
    flexible_clock_module clk_0p5_module(basys_clk, 49999999 ,clk_1);
    
    
    wire [13:0] selected_password;   // can represent from 0000 - 9999 
    reg [13:0] master_password;     
    
    wire [3:0] an_password;
    wire [6:0] seg_password;
    // Module to control game state
    reg password_phase;
    wire [15:0] oled_data_password;
    password_phase( basys_clk, 
                    clk_200, 
                    clk_1, 
                    btnL, 
                    btnR, 
                    btnU, 
                    btnD, 
                    btnC,
                    pixel_index_pw, 
                    an_password, 
                    seg_password, 
                    selected_password, 
                    oled_data_password, 
                    PS2Clk, 
                    PS2Data);
    

    // TODO: Create a module that constructs write_data
    reg [13:0] password_from_B;
    // module that controls writing/reading of data to UART
    reg A_ready;
    reg B_ready;
    wire [13:0] password_one;
//    wire [13:0] password_two_master;
//    wire [13:0] password_two_B;    
//    wire reset_password_1;
//    wire reset_password_2;
//    wire [13:0] password_two;
//    assign password_two = (board_type == 1) ? password_two_master : password_two_B;
  
    reg two_sec_start=0;
    wire two_sec_over;
    two_sec_countdown two_sec_countdown_module(basys_clk, two_sec_start, two_sec_over);
    
  
    reg reset_reg;  
    random_generator random_generator_module_1(basys_clk, reset_reg, game_state, password_one);
    reg exploded;
    initial begin
       game_state = 2'b00;
       reset_reg = 1;
       A_ready = 0;
       B_ready = 0;
       exploded = 0;
       password_from_B = 10001;
       uart_reset = 1;
    end
   
   // PRESS DETECTION + COOLDOWN/DEBOUNCING

    always @(posedge basys_clk) begin
        // update send packet for master
        if (board_type == 1) begin
            uart_reset <= 0;
            if (game_state == 2'b00) begin
                reset_reg <= 0;
                 oled_data_pw <= oled_data_password;
                 oled_data_bomb <= `CYAN;
                 seg <= seg_password;
                 an <= an_password;

                if (btnC == 1) begin
                    send_signal <= btnC;
                    A_ready = 0;
                    B_ready = 0;
                    password_from_B <= 10001;
                    game_state <= 2'b01;
                    write_data_to_B[15:14] <= 2'b01;
                    write_data_to_B[13:0] <= 0;
                end               
            end
            if (game_state == 2'b01) begin
                send_signal <= clk_6p25m;
                write_data_to_B[15:14] <= 2'b01;
                write_data_to_B[13:0] <= password_one;
                read_signal <= clk_6p25m; // keep sampling for incoming password data
                password_from_B <= rec_data_from_B[13:0];
                oled_data_pw <= oled_data_password;
                seg <= seg_password;
                an <= an_password;
                oled_data_bomb <= `ORANGE;
                led[13:0] <= password_one;   
                if (selected_password == password_one)begin 
                        led[14] <= 1; 
                        A_ready <= 1; 
                end
                else begin 
                        led[14] <= 0; 
                        A_ready <= 0; 
                end
                
                if (password_from_B == password_one) begin 
                    led[15] <= 1; 
                    B_ready <= 1; 
                end 
                else begin 
                    led[15] <= 0;
                    B_ready <= 0; 
                end
                
                if (A_ready==1 && B_ready==1) begin 
                    if (btnC == 1)
                    begin
                        send_signal <= btnC;
                        write_data_to_B[15:14] <= 2'b10;
                        write_data_to_B[13:0] <= 0;
                        game_state <= 2'b10;
                                                
                    end
                    
                    
                end
            end
            if (game_state == 2'b10) begin
                send_signal <= clk_6p25m;
                write_data_to_B[15:14] <= 2'b10;
                write_data_to_B[13:0] <= 0;
                oled_data_pw <= oled_data_password;
                seg <= seg_password;
                an <= an_password;                
                
                if (exploded == 1) begin
                    oled_data_bomb <= `RED;
                end
                else begin
                    oled_data_bomb <= `GREEN;
                end
                
                if (btnU == 1) begin
                    game_state <= 0;
                    write_data_to_B <= 0;
                    two_sec_start <= 0;
                    
                end
            
            end
        end
            // ====================GAME MASTER (DISPLAY)===============================
        // display led, segment, oled based on master and slave
        
            // =====================GAME MASTER (DISPLAY)==============================
         if (board_type == 2'b10) begin
            // board is not master 
//                reset_reg <= 0;
                uart_reset <= 0;
                read_signal <= clk_6p25m;
                if (game_state == 0) begin
                    oled_data_pw <= oled_data_password;
                    seg <= seg_password;
                    an <= an_password;
                    if (rec_data_from_B[15:14] != 2'b00) begin
                        game_state <= 2'b01;
                    end
                end           
                if (game_state == 2'b01) begin
                    oled_data_pw <= oled_data_password;
                    write_data_to_B[13:0] <= selected_password;
                    write_data_to_B[15:14] <= 0;
                    send_signal <= clk_6p25m;
                    master_password <= rec_data_from_B[13:0]; 
                    seg <= seg_password;
                    an <= an_password;
                    led[13:0] <= master_password;
                   if (rec_data_from_B[15:14] != 2'b01) begin
                        game_state <= 2'b10;
                    end
                end
                // =====================GAME SLAVE==============================
                if (game_state == 2'b10) begin
                    // password solved
                    oled_data_pw <= oled_data_password;
                    seg <= seg_password;
                    an <= an_password;
                    
                   if (rec_data_from_B[15:14] != 2'b10) begin
                         game_state <= 2'b00;
                   end                    
                end
    
                
            end
        
    end
       
endmodule
        

module random_generator (
    input basys_clk,
    input rst,
    input [1:0] game_state,
    output reg [13:0] random_value
);

reg [31:0] seed = 12345; // Initial seed value

// Linear feedback shift register (LFSR) to generate pseudo-random numbers
always @(posedge basys_clk) begin
    if (rst) begin
        seed <= 12345; // Reset seed value
    end else if (game_state != 1) begin
        seed <= seed ^ (seed << 13);
        seed <= seed ^ (seed >> 17);
        seed <= seed ^ (seed << 5);
    end
end

// Output random value
always @(posedge basys_clk) begin
    if (game_state == 2'b00) begin
        random_value <= 0;
    end
    else if (game_state == 2'b01) begin
        random_value <= seed % 10000; // Extract 13 bits of random value
    end
end

endmodule


module two_sec_countdown(input basys_clk, input two_sec_start, output reg two_sec_passed);
    reg [31:0] count=0;
    initial begin 
            count = 0;
            two_sec_passed = 0;
    end
    always @ (posedge basys_clk) begin
        if (two_sec_start)begin
            if (count <= 499_999_999) begin
                count <= count + 1; 
                two_sec_passed <= 0; 
            end
            else begin
                two_sec_passed <=1; 
            end
        end
        else begin
            count <= 0;
        end
        
        end
endmodule
