`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 02:13:35 PM
// Design Name: 
// Module Name: flexible_clock_module
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



module note_generator(
    input basys_clk,
    input [31:0] my_m_value, //Frequency control
    input [6:0] volume, 
    output reg output_clk
    );
    reg [31:0] COUNT = 0;
    reg [3:0] count_vol = 0; // Additional counter for PWM duty cycle
    reg freq_signal = 0;
    
        
    always @ (posedge basys_clk) begin
        COUNT <= (COUNT == (my_m_value)) ? 0 : COUNT + 1;
        freq_signal <= (COUNT == 0) ? ~freq_signal : freq_signal;
        
        count_vol <= (count_vol >= 15) ? 0 : count_vol + 1; // Adjusted for PWM frequency
        output_clk <= (count_vol < volume) ? freq_signal : 0;
    end
endmodule
