`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2024 21:03:28
// Design Name: 
// Module Name: volume_control
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


module volume_control(
    input wire clk,                    // System clock
    input wire [15:0] audio_in,        // Input audio signal
    input wire [3:0] volume_level,     // 4-bit volume level (0-15)
    output wire [15:0] audio_out       // Output audio signal
);

// Define a simple linear volume control
wire [19:0] scaled_audio; // Extended bit width to prevent overflow

// Volume scaling
// Assuming a very simple linear scaling for demonstration purposes
assign scaled_audio = audio_in * volume_level;

// Truncate scaled_audio to fit into the output bit width
assign audio_out = scaled_audio[19:4]; // Adjust this bit range based on actual scaling factors

endmodule
