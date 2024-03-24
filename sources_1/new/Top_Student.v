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
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp,
    inout PS2Clk, PS2Data,
    input RX_from_B,        
    output TX_to_B
);

    assign JC[2] = 0; // Some boards require JC[2] to be cleared to 0 for OLED to work
    // =============== Instantiate OLED Module ====================
    wire [15:0] oled_data;
    
    wire explode; // 0 for havent explode, 1 for exploded
    wire frame_begin, sending_pixels, sample_pixel; 
    wire [12:0] pixel_index;
        
    wire clk_6p25m;
    flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
    wire clk_200;
        flexible_clock_module clk_200_module(basys_clk, 249999 ,clk_200);
        
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
      
    // Password Generation (Master Board A) 
    wire [6:0] seg_tens;
    wire [6:0] seg_ones;
    
    reg [7:0] master_password; // 8 bits can represent 00 to 99
    always @ (posedge basys_clk) begin
        
        if (SW[14:11] > 4'b1001) begin
        end
        else begin
            if (SW[10:7] > 4'b1001) begin
            end
            else begin
                // valid password
                master_password <= {SW[14:11],SW[10:7]};
            end
        end
    end
    
    // Display chosen password
    
    password_seg password_seg_tens(basys_clk, SW[14:11], seg_tens);
    password_seg password_seg_ones(basys_clk, SW[10:7], seg_ones);
    segment_counter segment_counter_module(basys_clk, clk_200, seg_tens, seg_ones, an, seg);
    
    // Potato Timer (Board A)
        wire trigger_signal;
        wire [4:0] countdown;
        wire gameover;
            
        random_countdown_timer(.clk(basys_clk),.trigger(SW[0]),.count(countdown),.gameover(gameover));
            
    // =============== UART ====================
    
    
    
                
    
    
    // Connection Signals
        wire rx_full, rx_empty, btn_tick;
        wire [7:0] rec_data;
        wire [6:5] write_data;
        // Master Board A Transmit to and Receive from Board B

        uart_module UART_UNIT
            (
                .clk_100MHz(basys_clk),
                .reset(btnC),
                .read_uart(clk_6p25m),
                .write_uart(clk_6p25m),
                .rx(RX_from_B),
                .write_data({gameover,write_data,countdown[4:0]}),  // Board A
//                .write_data(),  // Board B/C/D
                .rx_full(rx_full),
                .rx_empty(rx_empty),
                .read_data(rec_data),
                .tx(TX_to_B)
            );
            
            
                //Board A
                assign led[4:0] = countdown;
                assign oled_data = gameover ? `RED : `GREEN;
            // Board B
//          assign oled_data = rec_data[7] ?  `RED : `GREEN ;
//            assign led = rec_data[4:0];
        // Board B Transmit to and Receive from Master Board A 
        
    // =============== Project States ====================
    // State 1: Password Setting by Master Board
    // State 2: Await Slave Boards to guess password
    // State 3: All password correct, move on to Game Countdown 5,4,3,2,1
    // State 4: Game
    // State 5: Game Won/Over
    
    
    
endmodule

module segment_counter(input basys_clk, input clk_200, input [6:0] seg_tens, input [6:0] seg_ones, output reg [3:0] an, output reg [6:0] seg_output);

    reg [1:0] count;
    
    always @ (posedge clk_200)
        begin
            if (count < 2)
                count <= count + 1;
            else
                count = 0;
        end
    
    // create counter
    always @ (posedge basys_clk)
        begin
            case (count)
                2'b00: begin an[3:0] <= 4'b1111; seg_output[6:0] <= 7'b1111111; end //Step 1
                2'b01: begin an[3:0] <= 4'b1101; seg_output[6:0] <= seg_ones; end //Step 2
                2'b10: begin an[3:0] <= 4'b1011; seg_output[6:0] <= seg_tens; end //Step 3
                2'b11: begin an[3:0] <= 4'b1111; seg_output[6:0] <= 7'b1111111; end //Step 4
            endcase
    end
endmodule

module password_seg(input basys_clk, input [3:0] number, output reg [6:0] seg);

    always @ (basys_clk) begin
        case (number) 
            4'b0000: begin seg = 7'b1000000; end
            4'b0001: begin seg = `DIG1; end
            4'b0010: begin seg = `DIG2; end
            4'b0011: begin seg = `DIG3; end
            4'b0100: begin seg = `DIG4; end
            4'b0101: begin seg = `DIG5; end
            4'b0110: begin seg = `DIG6; end
            4'b0111: begin seg = `DIG7; end
            4'b1000: begin seg = `DIG8; end
            4'b1001: begin seg = `DIG9; end
            default: begin seg = 7'b1111111; end
            endcase
    end

endmodule