`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2024 02:15:57 AM
// Design Name: 
// Module Name: random_countdown_timer
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


module random_countdown_timer(
    input clk,        // Clock input
    input trigger,
    output [4:0] count,
    output reg [4:0] countdown_start_value
);

// Define states for the countdown timer
parameter IDLE = 2'b00;
parameter TRIGGERED = 2'b01;
parameter COUNTING = 2'b10;

// Internal state and timer
reg [4:0] timer;
reg [1:0] state;

// Counter to count 1-second intervals
reg [28:0] sec_counter;

wire [3:0] random_value; // 4-bit random value (0-9)

    LFSR LFSR_module(clk,random_value);


    always @(*) begin
        countdown_start_value = random_value + 21;
    end


// Countdown timer logic
always @(posedge clk) begin
    case (state)
        IDLE: begin
            if (trigger) begin
                state <= TRIGGERED;
            end
        end
        TRIGGERED: begin
            timer <= random_value; // Random value between 20 and 30
            state <= COUNTING;
            sec_counter <= 0; // Reset the second counter
        end
        COUNTING: begin
            if (sec_counter == 100000000) begin // Assuming 100 MHz clock frequency
                if (timer > 0) begin
                    timer <= timer - 1;
                end else begin
                    state <= IDLE;

                end
                sec_counter <= 0; // Reset the second counter
            end else begin
                sec_counter <= sec_counter + 1;
            end
        end
    endcase
end


// Output countdown value
assign count = (state == COUNTING) ? timer : 0;

endmodule

module LFSR (
    input wire clk,         // Clock input
    output reg [3:0] random // Output random value (4-bit)
);

// Internal state for LFSR
reg [3:0] lfsr_state = 4'b1010; // Initial state

always @(posedge clk) begin
    // Calculate next state using XOR taps
    lfsr_state = {lfsr_state[2:0], lfsr_state[3] ^ lfsr_state[0]}; 
    random <= lfsr_state;
end

endmodule