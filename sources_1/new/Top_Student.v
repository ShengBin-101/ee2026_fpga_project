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
    input B_start_round_from_m,
    output reg start_round_to_B,
    input left_press_from_B,
    input right_press_from_B,
    output reg B_left_press_to_m,
    output reg B_right_press_to_m,
    input C_start_round_from_m,
    output reg start_round_to_C,
    input left_press_from_C,
    input right_press_from_C,
    output reg C_left_press_to_m,
    output reg C_right_press_to_m
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
    reg [1:0] possession_reg;
    wire [1:0] possession_wire;
    
//    assign possession_wire = possession_reg;
    // possession: 00 - Master Board possess bomb
    // possession: 01 - Left Board possess bomb
    // possession: 10 - Right Board possess bomb
    // possession: 11 - Game Starting Countdown or Game End
    reg exploded_reg; 
    wire exploded_wire;
    assign exploded_wire = exploded_reg;
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
    
    
    // takes in a trigger signal to kickstart a randomised countdown timer
    wire [4:0] countdown;
    wire [4:0] countdown_start_value;
    reg start_bomb;
    random_countdown_timer(.clk(basys_clk),.trigger(start_bomb),.count(countdown), .countdown_start_value(countdown_start_value));
    
    // TODO: Create a module that constructs write_data
    reg [13:0] password_from_B;
    reg [13:0] password_from_C;
    // module that controls writing/reading of data to UART
    reg B_ready;
    reg C_ready;

    reg [1:0] bomb_animation_state_A;
    reg [1:0] bomb_animation_state_B;    
    reg [1:0] bomb_animation_state_C;
    
    reg [1:0] tick_speed;
    
    reg start_game;
    reg init_round;
    reg init_round_done_reg;
    wire init_round_done_wire;
    assign init_round_done_wire = init_round_done_reg;
    reg start_passing;
    reg round_end;
    reg game_end;
    reg reset_game;
    reg reset_round;
    wire exploded;
    assign exploded = (countdown == 0);
    
    wire one_sec_over;
    one_sec_countdown one_sec_countdown_module(basys_clk, init_round, reset_round, one_sec_over);
    wire two_sec_over;
    two_sec_countdown two_sec_countdown_module(basys_clk, round_end, reset_round, two_sec_over);
    
    wire three_sec_over;
    three_sec_countdown three_sec_countdown_module(basys_clk, one_sec_over, reset_round, three_sec_over);
    init_round init_round_module(basys_clk, init_round, init_round_done_wire, possession_wire);
    
    initial begin
       password_set = 0;
       game_state = 0;
        reset_game = 1;
    end
   
   wire left_pressed_A;
   wire right_pressed_A;
   wire left_pressed_B;
   wire right_pressed_B;
   wire left_pressed_C;
   wire right_pressed_C;
   // PRESS DETECTION + COOLDOWN/DEBOUNCING
   press_detection press_detection_module(basys_clk, init_round_done_reg, 
                                            btnL, 
                                            btnR,
                                            left_press_from_B,
                                            right_press_from_B,
                                            left_press_from_C,
                                            right_press_from_C,
                                            left_pressed_A,
                                            right_pressed_A,
                                            left_pressed_B,
                                            right_pressed_B,
                                            left_pressed_C,
                                            right_pressed_C
                                            );
   
    
    
    
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
            // ====================GAME MASTER===============================
            else if (game_state == 1) begin
                send_signal <= clk_6p25m; 
                init_round <= 1;

                // COUNTDOWN FOR 3 Seconds
                if (init_round) begin
                    // decide random starting player
                    if (reset_game == 1) begin
                        reset_game <= 0;
                       lives_A <= 3;
                        lives_B <= 3;
                        lives_C <= 3;
                    end
                    game_end <= 0;
                    exploded_reg <= 0;
                    
                    // Update Data Packet
                    if (possession_wire == 0) begin
                        bomb_animation_state_A <= 2'b11;
                        bomb_animation_state_B <= 2'b00;
                        bomb_animation_state_C <= 2'b00;
                    end                    
                    else if (possession_wire == 1) begin
                        bomb_animation_state_A <= 2'b00;
                        bomb_animation_state_B <= 2'b11;
                        bomb_animation_state_C <= 2'b00;
                    end                    
                    else if (possession_wire == 2) begin
                        bomb_animation_state_A <= 2'b00;
                        bomb_animation_state_B <= 2'b00;
                        bomb_animation_state_C <= 2'b11;
                    end
                    
                    // Update Send Data 
                    write_data_to_B[4:0] <= countdown;
                    write_data_to_B[6:5] <= bomb_animation_state_B;
                    write_data_to_B[8:7] <= tick_speed;
                    write_data_to_B[10:9] <= lives_B;
                    write_data_to_B[12:11] <= possession_wire;
                    write_data_to_B[13] <= exploded_reg;
                    write_data_to_B[14] <= game_end;
                    write_data_to_B[15] <= 1;
                    
                    // Update Send Data 
                    write_data_to_C[4:0] <= countdown;
                    write_data_to_C[6:5] <= bomb_animation_state_C;
                    write_data_to_C[8:7] <= tick_speed;
                    write_data_to_C[10:9] <= lives_C;
                    write_data_to_C[12:11] <= possession_wire;
                    write_data_to_C[13] <= exploded_reg;
                    write_data_to_C[14] <= game_end;
                    write_data_to_C[15] <= 1;                    
                  
                    if (one_sec_over == 1) begin
                        // update port to tell slave boards to start 3sec countdown
                        start_round_to_B <= 1;
                        start_round_to_C <= 1;
                        start_bomb <= 0;
                        possession_reg <= possession_wire;
                    end
                    
                    if (three_sec_over == 1) begin 
                        init_round_done_reg <= 1;
                        // Trigger Random Timer for bomb
                        start_bomb <= 1;
                    end
                end
                if (init_round_done_reg) begin
                    // Start Passing Phase 
                    // This phase updates bomb_animation_state for each board
                    // This phase updates which board possesses bomb based on button presses
                    // Button press flags have timers to include 1s "cooldowns" so users cannot spam buttons
                    
                    // Pushbutton event from A (itself)
                   if (possession_reg == 2'b01) begin
                        // bomb with A
                        // detect for left or right pushbutton press
                        if (left_pressed_A) begin
                            possession_reg <= 2'b10;
                            write_data_to_B[6:5] <= 2'b10; // enter from right
                        end
                        if (right_pressed_A) begin
                            possession_reg <= 2'b11;
                            write_data_to_C[6:5] <= 2'b01; // enter from left
                        end
                   end
                  // Pushbutton event from B
                  if (possession_reg == 2'b10) begin
                       // bomb with B
                       // detect for left or right pushbutton press
                       if (left_pressed_B) begin
                           possession_reg <= 2'b11;
                           write_data_to_C[6:5] <= 2'b10;
                       end
                       if (right_pressed_B) begin
                           possession_reg <= 2'b01;
                           bomb_animation_state_A <= 2'b01;
                           write_data_to_B[6:5] <= 2'b00;
                       end
                  end
                  // Pushbutton event from C
                 if (possession_wire == 2'b11) begin
                      // bomb with C
                      // detect for left or right pushbutton press
                      if (left_pressed_C) begin
                          possession_reg <= 2'b01;
                          bomb_animation_state_A <= 2'b10;
                      end
                      if (right_pressed_C) begin
                          possession_reg <= 2'b10;
                          write_data_to_B[6:5] <= 2'b01;
                          write_data_to_C[6:5] <= 2'b00;
                      end
                 end                   
                 
                 
                   
                   if (countdown == 0) begin
                        round_end <= 1;
                   end
                end 
                if (round_end) begin
                
                    // end of round, bomb has exploded
                    // check possession and update lives
                    if (possession_reg == 2'b01) begin
                        lives_A = lives_A - 1;
                    end
                    else if (possession_reg == 2'b10) begin
                        lives_B = lives_B - 1;
                    end                    
                    else if (possession_reg == 2'b11) begin
                        lives_C = lives_C - 1;
                    end                    
                    
                    if (  (lives_A != 0 && lives_B == 0 && lives_C == 0) ||
                          (lives_A == 0 && lives_B != 0 && lives_C == 0) ||
                          (lives_A == 0 && lives_B == 0 && lives_C != 0)   ) begin
                       // only one player standing
                       //update game_end
                       game_end = 1;
                          
                    end
                    write_data_to_B[12:11] <= possession_reg;
                    write_data_to_B[10:9] <= lives_B;
                    write_data_to_B[13] <= 1;   // update explosion
                    write_data_to_C[12:11] <= possession_reg;
                    write_data_to_C[10:9] <= lives_C;
                    write_data_to_C[13] <= 1;   // update explosion
                    
                    // update datapacket
                
                    if (game_end) begin
                        write_data_to_B[14] <= 1;
                        write_data_to_C[14] <= 1;
                        // wait for btnC to be pressed to restart game
                        if (btnC) begin
                            reset_game <= 1;
                            init_round <= 0;
                            init_round_done_reg <= 0;
                            round_end <= 0;
                            start_bomb <= 0;
                        end
                    end
                    else if (two_sec_over == 1) begin
                        // restart round after 2 seconds
                        reset_round <= 1;
                        init_round <= 0;
                        init_round_done_reg <= 0;
                        round_end <= 0;
                        start_bomb <= 0;
                    end
                
                end
//                write_data_to_B[4:0] <= countdown;
//                write_data_to_C[4:0] <= countdown;
            end
            // ====================GAME MASTER===============================
        end
        
        // display led, segment, oled based on master and slave
        if (board_type == 1) begin
            // master board
            if (game_state == 0) begin
                oled_data <= oled_data_password;
                seg <= seg_password;
                an <= an_password;
            end
            // ====================GAME MASTER (DISPLAY)===============================
            else if (game_state == 1) begin
                // display lives_A on 7-segment
                led[4:0] <= countdown;
                led[8:5] = lives_A;
                oled_data <= (init_round == 1) ? `PURPLE :          // init
                (lives_A == 0) ? `RED  :             // GAMEOVER
                (possession_reg == 2'b01 && countdown != 0) ? `ORANGE :       // Match INPROGRESS holding bomb
                (possession_reg != 2'b01 && countdown != 0) ? `BLUE :  // Match INPROGRESS not holding bomb
                (possession_reg == 2'b01 && countdown == 0) ? `YELLOW: // EXPLOSION
                `GREEN;                                           // SAFE
            end
            // =====================GAME MASTER (DISPLAY)==============================
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
                        // play sound for successful password
                        game_state <= 1;
                end
                else begin
                master_password <= rec_data_from_B[13:0]; end
                seg <= seg_password;
                an <= an_password;
            end
            // =====================GAME SLAVE==============================
            else if (game_state == 1) begin
                read_signal <= clk_6p25m;
                if (B_start_round_from_m) begin
                    // start 3 seconds countdown animation
                
                end
                if (btnL == 1)  
                    B_left_press_to_m <= 1 ;
                else if (btnL == 0)
                    B_left_press_to_m <= 0;
                if (btnR == 1)  
                    B_right_press_to_m <= 1 ;
                else if (btnR == 0)
                    B_right_press_to_m <= 0;
                    
                // check possession and animation_state and play correct animation
                led[8:5] = lives_B;
                // display lives_B (rec_data_from_B[10:9]) on 7-segment
                led[4:0] <= rec_data_from_B[4:0];
                oled_data <= (init_round == 1) ? `PURPLE :          // init
                (rec_data_from_B[10:9] == 0) ? `RED  :             // GAMEOVER
                (rec_data_from_B[12:11] == 2'b10 && rec_data_from_B[13] == 0) ? `ORANGE :       // Match INPROGRESS holding bomb
                (rec_data_from_B[12:11] != 2'b10 && rec_data_from_B[13] == 0) ? `BLUE :  // Match INPROGRESS not holding bomb
                (rec_data_from_B[12:11] == 2'b10 && rec_data_from_B[13] == 1) ? `YELLOW: // EXPLOSION
                `GREEN;                                           // SAFE
                            
            end
            // =====================GAME SLAVE==============================
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
            // =====================GAME SLAVE==============================
            else if (game_state == 1) begin
                read_signal <= clk_6p25m;
                if (C_start_round_from_m) begin
                    // start 3 seconds countdown animation
                    
                end
                
                if (btnL == 1)  
                    C_left_press_to_m <= 1 ;
                else if (btnL == 0)
                    C_left_press_to_m <= 0;
                if (btnR == 1)  
                    C_right_press_to_m <= 1 ;
                else if (btnR == 0)
                    C_right_press_to_m <= 0;

                // display lives_C (rec_data_from_C[10:9]) on 7-segment
                led[8:5] = lives_C;
                led[4:0] <= rec_data_from_C[4:0];
                oled_data <= (init_round == 1) ? `PURPLE :          // init
                (rec_data_from_C[10:9] == 0) ? `RED  :             // GAMEOVER
                (rec_data_from_C[12:11] == 2'b11 && rec_data_from_C[13] == 0) ? `ORANGE :       // Match INPROGRESS holding bomb
                (rec_data_from_C[12:11] != 2'b11 && rec_data_from_C[13] == 0) ? `BLUE :  // Match INPROGRESS not holding bomb
                (rec_data_from_C[12:11] == 2'b11 && rec_data_from_C[13] == 1) ? `YELLOW: // EXPLOSION
                `GREEN;                                           // SAFE
            end
            // =====================GAME SLAVE==============================
        end
            
    end
endmodule

module three_sec_countdown(input basys_clk, input trigger_signal, input reset, output reg three_sec_passed);
    reg [31:0] count=0;
    always @ (posedge basys_clk) begin
        if (trigger_signal && count <= 149999999) count <= count + 1;
        else if (reset == 1) three_sec_passed <= 0;
        else three_sec_passed <=1;
    end
endmodule

module two_sec_countdown(input basys_clk, input trigger_signal, input reset, output reg two_sec_passed);
    reg [31:0] count=0;
    
    always @ (posedge basys_clk) begin
        if (trigger_signal && count <= 99999999) count <= count + 1;
        else if (reset == 1) two_sec_passed <= 0;
        else two_sec_passed <=1;
    end
endmodule

module one_sec_countdown(input basys_clk, input trigger_signal, input reset, output reg one_sec_passed);
    reg [31:0] count=0;
    
    always @ (posedge basys_clk) begin
        if (trigger_signal && count <= 49999999) count <= count + 1;
        else if (reset == 1) one_sec_passed <= 0;
        else one_sec_passed <=1;
    end
endmodule

module init_round(input basys_clk, input board_type, input init_round, output reg init_round_done, output reg starting_player);  
    reg [2:0] lfsr_reg;
    always @(posedge basys_clk) begin
        // LFSR feedback polynomial: x^3 + x + 1
        lfsr_reg <= {lfsr_reg[1:0], lfsr_reg[2] ^ lfsr_reg[0]};
    end
    
    always @(posedge basys_clk) begin
        // Output the two LSBs of the LFSR register
        if (board_type == 1 && init_round == 1) begin
            starting_player <= lfsr_reg[1] + lfsr_reg[0];   // either 0, 1 or 2
            init_round_done <= 1;
        end
    end
endmodule


module press_detection (input basys_clk, input init_round_done_reg, 
                input btnL, 
                input btnR,
                input left_press_from_B,
                input right_press_from_B,
                input left_press_from_C,
                input right_press_from_C,
                output reg left_pressed_A,
                output reg right_pressed_A,
                output reg left_pressed_B,
                output reg right_pressed_B,
                output reg left_pressed_C,
                output reg right_pressed_C);
                
                // cooldown flags (1 - press is valid, 0 - press ignore)                         
                reg ignoreA=0;
                reg ignoreB=0;
                reg ignoreC=0;
                reg counterA=0;
                reg counterB=0;
                reg counterC=0;
                
                always @ (posedge basys_clk) begin
                    // COOLDOWN TIMERS FOR IgnoreA, IgnoreB, IgnoreC
                    if (init_round_done_reg == 1) begin
                    
                    if (ignoreA == 1) begin
                        if (counterA <= 49999999) counterA <= counterA + 1;
                        else ignoreA <= 0;
                    end
                    if (ignoreB == 1) begin
                        if (counterB <= 49999999) counterB <= counterB + 1;
                        else ignoreB <= 0;
                    end                
                    if (ignoreC == 1) begin
                        if (counterC <= 49999999) counterC <= counterC + 1;
                        else ignoreC <= 0;
                    end              
                    if (btnL) begin
                        if (ignoreA == 0) begin
                            left_pressed_A <= 1;
                            ignoreA <= 1;
                            counterA <= 0;
                        end
                    end
                    if (btnR) begin
                        if (ignoreA == 0) begin
                            right_pressed_A <= 1;
                            ignoreA <= 1;
                            counterA <= 0;
                        end
                    end                                         
                    if (left_press_from_B) begin
                        if (ignoreB == 0) begin
                            left_pressed_B <= 1;
                            ignoreB <= 1;
                            counterB <= 0;
                        end
                    end
                    if (right_press_from_B) begin
                        if (ignoreB == 0) begin
                            right_pressed_B <= 1;
                            ignoreB <= 1;
                            counterB <= 0;
                        end
                    end
                     if (left_press_from_C) begin
                        if (ignoreC == 0) begin
                            left_pressed_C <= 1;
                            ignoreC <= 1;
                            counterC <= 0;
                        end
                    end
                    if (right_press_from_C) begin
                        if (ignoreC == 0) begin
                            right_pressed_C <= 1;
                            ignoreC <= 1;
                            counterC <= 0;
                        end
                    end
                        
                    end
              end                                                           
endmodule