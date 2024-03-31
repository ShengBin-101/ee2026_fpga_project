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
    output reg [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an,
    output dp,
    inout PS2Clk, PS2Data,
    input RX_from_B,        // Connection between Master (Board A) and (Board B)
    output TX_to_B,         // Connection between Master (Board A) and (Board B)
    input RX_from_C,        // Connection between Master (Board A) and (Board C)
    output TX_to_C,         // Connection between Master (Board A) and (Board C)
    output reg B_left=0,           // detect left press from B
    output reg B_right=0,          // detect right press from B
    output reg C_left=0,           // detect left press from C
    output reg C_right=0           // detect right press from C
);

    assign JC[2] = 0; // Some boards require JC[2] to be cleared to 0 for OLED to work
    
    // =============== Instantiate OLED Module ====================
    reg [15:0] oled_data;
    
    wire frame_begin, sending_pixels, sample_pixel; 
    wire [12:0] pixel_index;
    // clk for oled
    
    wire clk_6p25m;
    flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
         
    Oled_Display oled(
        .clk(clk_6p25m), 
        .reset(0), 
        .frame_begin(frame_begin), 
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JC[0]), 
        .sdin(JC[1]), 
        .sclk(JC[3]), 
        .d_cn(JC[4]), 
        .resn(JC[5]), 
        .vccen(JC[6]),
        .pmoden(JC[7]));
       
       // =============== UART ====================
            // Connection Signals
       wire rx_B_full, rx_B_empty, rx_C_full, rx_C_empty;
       reg read_signal;
       reg send_signal;
       wire [15:0] rec_data_from_C;
       reg [15:0] write_data_to_C;
       wire [15:0] rec_data_from_B;
       reg [15:0] write_data_to_B;
       // Master Board A Transmit to and Receive from Board B
        
        reg reset;
        wire reset_signal;
        assign reset_signal = (reset) || SW[11];
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
        
        // UART Module connecting Board A and C
        uart_module UART_UNIT_C(
            .clk_100MHz(basys_clk),
            .reset(reset_signal),
            .read_uart(read_signal),
            .write_uart(send_signal),
            .rx(RX_from_C),
            .write_data(write_data_to_C[15:0]),
            .rx_full(rx_C_full),
            .rx_empty(rx_C_empty),
            .read_data(rec_data_from_C[15:0]),
            .tx(TX_to_C)
        );
           
       
    // =============== Project States ====================
    // State 1: Password Setting by Master Board
    // State 2: Await Slave Boards to guess password
    // State 3: All password correct, move on to Game Countdown 5,4,3,2,1
    // State 4: Game
    // State 5: Game Won/Over
    
    reg [2:0] game_state;
    // state = 00: Master Board Choose Password, Slave Boards Challenge Password
    // state = 01: Await Slave Boards to guess password
    // state = 10: Game Begin Countdown (5,4,3,2,1)
    // state = 11: Potato Spawn + Countdown Timer tick
    // state = 100: Bomb Explode, Game Over Screen
    // go back to game state (10)
    wire [1:0] possession;
    // possession: 00 - Master Board possess bomb
    // possession: 01 - Left Board possess bomb
    // possession: 10 - Right Board possess bomb
    // possession: 11 - Game Starting Countdown or Game End
    wire exploded; 
    // exploded: 0 for havent explode, 
    // explored: 1 for exploded
    wire [1:0] board_type;
    // board_type: 0 - Master (board A)
    // board_type: 1 - Slave (board B)
    // board_type: 2 - Slave (board C)
    
    // Registers to keep track of user lives, Start with 3 lives 
    reg [1:0] lives_A;  
    reg [1:0] lives_B;
    reg [1:0] lives_C;
    
    // module to update board_type
    master_select master_select_module(basys_clk, SW[15], SW[14], SW[13], board_type);
    
    // clk for 7-segment
    wire clk_200;
    flexible_clock_module clk_200_module(basys_clk, 249999 ,clk_200);
    wire clk_1;
    flexible_clock_module clk_0p5_module(basys_clk, 49999999 ,clk_1);
    
    
    wire [13:0] selected_password;   // can represent from 0000 - 9999 
    reg [13:0] master_password;      // to store master's password to compare for slave boards
    reg password_set=0;            // flag to determine if password is set
    reg all_ready=0;                  // 1 - all boards ready, 0 - boards still selecting password
    
    wire [3:0] an_password;
    wire [6:0] seg_password;
    // Module to control game state
    reg password_phase;
    wire [15:0] oled_data_password;
    password_phase(game_state, 
                    basys_clk, 
                    clk_200, 
                    clk_1, 
                    btnL, 
                    btnR, 
                    btnU, 
                    btnD, 
                    btnC, 
                    board_type,
                    pixel_index, 
                    an_password, 
                    seg_password, 
                    selected_password, 
                    oled_data_password, 
                    PS2Clk, 
                    PS2Data);
    
    // Potato Timer (Board A)
    
    // takes in a trigger signal to kickstart a randomised countdown timer
    wire [4:0] countdown;
    
    random_countdown_timer(.clk(basys_clk),.trigger(SW[7]),.count(countdown),.gameover(exploded));
    
    // TODO: Create a module that constructs write_data
    reg [13:0] password_from_B;
    reg [13:0] password_from_C;
    // module that controls writing/reading of data to UART
    reg B_ready;
    reg C_ready;
    
    reg transition;
    reg counter;
    
   initial begin
       password_set = 0;
       game_state = 0;
   end
    
    always @(posedge basys_clk) begin

        
        // update send packet for master
        if (board_type == 1) begin
            if (game_state == 0) begin
                write_data_to_B[13:0] <= selected_password;
                write_data_to_B[15:14] <= 0;
                write_data_to_C[13:0] <= selected_password;
                write_data_to_C[15:14] <= 0;
                send_signal <= btnC;
                if (btnC == 1) begin password_set <= 1; end
                read_signal <= clk_6p25m; // keep sampling for incoming password data
                password_from_B <= rec_data_from_B[13:0];
                password_from_C <= rec_data_from_C[13:0];
                if (password_from_B == selected_password) begin led[14] <= 1; B_ready<=1; end else begin led[14] <= 0;B_ready<=0; end
                if (password_from_C == selected_password) begin led[13] <= 1; C_ready<=1; end else begin led[13] <= 0;C_ready<=0; end
                if (password_set == 1 && B_ready && C_ready) begin 
                    // count to 3 seconds then trigger
                    game_state <= 1;
                    write_data_to_B[15] <= 1;
                    write_data_to_C[15] <= 1;
                end
            end
            else if (game_state == 1) begin
                send_signal <= clk_6p25m; 
                write_data_to_B[4:0] <= countdown;
                write_data_to_B[14:5] <= 0;
                write_data_to_C[4:0] <= countdown;
                write_data_to_C[14:5] <= 0;
            end
        end
        
        // display led, segment, oled based on master and slave
        if (board_type == 1) begin
            // master board
            if (game_state == 0) begin
                oled_data <= oled_data_password;
                seg <= seg_password;
                an <= an_password;
            end
            else if (game_state == 1) begin
                seg <= 6'b111111;
                an <= 4'b1111;
                led[13:0] <= countdown;
                oled_data <= (countdown == 0) ? `RED : `GREEN;
            end
        end
        else if (board_type == 2) begin
        // board is not master            
            if (game_state == 0) begin
                read_signal <= clk_6p25m;
                oled_data <= oled_data_password;
                // use B_left to indicate successful match
                write_data_to_B[13:0] <= selected_password;
                write_data_to_B[15:14] <= 0;
                send_signal <= btnC;
                // if btnC is pressed, check if selected_password == master_password, if they are equal,
                // play sound for successful check
                if (rec_data_from_B[15] == 1)
                begin
                        // play sound
                        game_state <= 1;
                end
                else begin
                master_password <= rec_data_from_B[13:0]; end
                seg <= seg_password;
                an <= an_password;
            end
            else if (game_state == 1) begin
                read_signal <= clk_6p25m;
                seg <= 6'b111111;
                an <= 4'b1111;
                led[4:0] <= rec_data_from_B[4:0];
                oled_data <= (rec_data_from_B[4:0] == 0) ? `RED : `GREEN;
            end
        end
        else if (board_type == 3) begin
        // board is not master            
            if (game_state == 0) begin
                read_signal <= clk_6p25m;
                oled_data <= oled_data_password;
                // use C_left to indicate successful match
                write_data_to_C[13:0] <= selected_password;
                write_data_to_C[15:14] <= 0;
                send_signal <= btnC;
                
                // if btnC is pressed, check if selected_password == master_password, if they are equal,
                // play sound for successful check
                if (rec_data_from_C[15] == 1)
                begin
                        // play sound
                        game_state <= 1;
                end 
                else begin master_password <= rec_data_from_C[13:0]; end
                seg <= seg_password;
                an <= an_password;
            end
            else if (game_state == 1) begin
                read_signal <= clk_6p25m;
                seg <= 6'b111111;
                an <= 4'b1111;
                led[4:0] <= rec_data_from_C[4:0];
                oled_data <= (rec_data_from_C[4:0] == 0) ? `RED : `GREEN;
            end
        end

    end    
endmodule

// module password_phase allows the board to change password value of the board itself
module password_phase(
            input game_state,
            input basys_clk, 
            input clk_200, 
            input clk_1,
            input btnL, btnR, btnU, btnD, btnC,
            input [1:0] board_type,
            input [12:0] pixel_index,
            output [3:0] an_output,
            output [6:0] seg_output,
            output [13:0] selected_password,
            output [15:0] oled_data_password,
            inout PS2Clk, PS2Data);
        // State 1: Password Setting by Master Board
                  
        // Password is 4 digits XXXX
        // digit3,digit2,digit1,digit0
        reg [13:0] master_password;     // can represent from 0000 - 9999, for slave boards to check
        
        wire [3:0] digit0;
        wire [3:0] digit1;
        wire [3:0] digit2;
        wire [3:0] digit3;
        wire [1:0] selected_digit;

        // selected_digit: 00 - digit0 selected
        // selected_digit: 01 - digit1 selected
        // selected_digit: 10 - digit2 selected
        // selected_digit: 11 - digit3 selected
        
        // Mouse Module
        wire [11:0] xpos, ypos;
        wire [3:0] zpos;
        wire left, middle, right, new_event;
        reg [11:0] value = 0;
        reg setx = 0;
        reg sety = 0;
        reg setmax_x = `WIDTH;
        reg setmax_y = `HEIGHT;
        
        wire clk_25m;   // 25   MHZ CLK Signal
        wire clk_12p5m; // 12.5 MHZ CLK Signal
        wire clk_2;     // 2     HZ CLK Signal  (slow_clk)
        wire clk_6p25m;
        flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
        flexible_clock_module clk_25m_module(basys_clk, 1 ,clk_25m);
        flexible_clock_module clk_12p5m_module(basys_clk, 3 ,clk_12p5m);
        flexible_clock_module clk_2_module(basys_clk, 24999999 ,clk_2);
        
        MouseCtl mouse_module(.clk(basys_clk), .rst(0), .xpos(xpos), .ypos(ypos), .zpos(zpos), 
                                   .left(left), .middle(middle), .right(right), .new_event(new_event), 
                                   .value(value), .setx(setx), .sety(sety), .setmax_x(setmax_x), .setmax_y(setmax_y), 
                                   .ps2_clk(PS2Clk), .ps2_data(PS2Data) );
            
        password_select password_select_module(.clk_100M(basys_clk),
                           .mouse_l(left), 
                           .reset(0),
                           .enable(game_state==0),  
                           .mouse_x(xpos),
                           .mouse_y(ypos),
                           .pixel_index(pixel_index),
                           .oled_data(oled_data_password),
                           .digit_1(digit0),
                           .digit_2(digit1),
                           .digit_3(digit2),
                           .digit_4(digit3),
                           .btnL(btnL),
                           .btnR(btnR),
                           .btnU(btnU),
                           .btnD(btnD),
                           .selected_digit(selected_digit)                                    
                           );
        
        
        
        
        
        // module to map 4 bit binary number to 7-segment character
        
        
        segment_counter segment_counter_module(basys_clk, clk_200, clk_1, digit0, digit1, digit2, digit3, selected_digit, an_output, seg_output);

        assign selected_password = (digit0 * 1) + (digit1 * 10) + (digit2 * 100) + (digit3 * 1000);
        
        
        // CHECK WITH MASTER PASSWORD
        
endmodule

module binary_to_7seg(
    input [3:0] binary_input,
    output reg [6:0] seg_output
);

// 7-segment display patterns for numbers 0-9
// Each bit represents a segment (a-g), with 1 indicating segment ON and 0 indicating OFF
// Segments are labeled as follows:   a
//                                   -----
//                                f |     | b
//                                  |  g  |
//                                   -----
//                                e |     | c
//                                  |     |
//                                   -----
//                                     d

always @(*) begin
    case (binary_input)
        4'b0000: seg_output = 7'b1000000; // 0
        4'b0001: seg_output = 7'b1111001; // 1
        4'b0010: seg_output = 7'b0100100; // 2
        4'b0011: seg_output = 7'b0110000; // 3
        4'b0100: seg_output = 7'b0011001; // 4
        4'b0101: seg_output = 7'b0010010; // 5
        4'b0110: seg_output = 7'b0000010; // 6
        4'b0111: seg_output = 7'b1111000; // 7
        4'b1000: seg_output = 7'b0000000; // 8
        4'b1001: seg_output = 7'b0010000; // 9
        default: seg_output = 7'b1111111; // Blank (for invalid input)
    endcase
end

endmodule

// this module creates a counter that allows us to display password digits on 7-segment display
module segment_counter(input basys_clk, input clk_200, input clk_2,
    input [3:0] digit0, 
    input [3:0] digit1,
    input [3:0] digit2,
    input [3:0] digit3, 
    input [1:0] selected_digit,
    output reg [3:0] an_output, 
    output reg [6:0] seg_output);
    
    wire [6:0] seg_digit0;
    wire [6:0] seg_digit1;
    wire [6:0] seg_digit2;
    wire [6:0] seg_digit3;
    
    binary_to_7seg (digit0, seg_digit0);
    binary_to_7seg (digit1, seg_digit1);
    binary_to_7seg (digit2, seg_digit2);
    binary_to_7seg (digit3, seg_digit3);
            
    reg [1:0] count;    
    // counter to step through anodes of 7-segment
    always @ (posedge clk_200)
        begin
            if (count < 4)
                count <= count + 1;
            else
                count = 0;
        end
    // create counter

    
    always @ (posedge basys_clk)
        begin
        case (count)
               2'b00: begin an_output[3:0] <= 4'b1110; 
                    if (selected_digit == 0 && clk_2 == 0) begin
                    
                        seg_output[6:0] <= 6'b111111;
                    end
                    else
                        seg_output[6:0] <= seg_digit0; 
                    end
               2'b01: 
                    begin an_output[3:0] <= 4'b1101;
                    if (selected_digit == 1 && clk_2 == 0) begin
                        seg_output[6:0] <= 6'b111111;
                    end
                    else 
                        seg_output[6:0] <= seg_digit1; 
                    end
               2'b10: begin an_output[3:0] <= 4'b1011; 
                   if (selected_digit == 2 && clk_2 == 0) begin
                       seg_output[6:0] <= 6'b111111;
                   end
                   else 
                       seg_output[6:0] <= seg_digit2; 
                   end
               2'b11: begin an_output[3:0] <= 4'b0111; 
                   if (selected_digit == 3 && clk_2 == 0) begin
                        seg_output[6:0] <= 6'b111111;
                   end
                   else 
                       seg_output[6:0] <= seg_digit3; 
                   end
        endcase
    end
endmodule

module master_select(input basys_clk, 
                    input SW15, SW14, SW13, 
                    output reg [1:0] board_type);
    always @ (posedge basys_clk) begin
        if (SW15 == 1) begin
            board_type <= 1; // master - Board A
        end
        else if (SW14 == 1)begin
            board_type <= 2; // slave - Board B
        end
        else if (SW13 == 1)begin
            board_type <= 3;
        end
    end
endmodule