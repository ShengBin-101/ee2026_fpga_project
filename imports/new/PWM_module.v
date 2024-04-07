`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.03.2024 18:22:37
// Design Name: 
// Module Name: PWM_module
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


module PWM_module(
    input basys_clk,
    input [15:0] audio_data,
    output reg pwm_out
    );
    
    //PWM Resolution = 12 bits
    reg [11:0] pwm_counter = 0;
    wire [11:0] pwm_value;
    
     assign pwm_value = audio_data >> (4); //16 - 12
   
       // Generate the PWM signal
       always @(posedge basys_clk) begin
           pwm_counter <= pwm_counter + 1;
   
           // Compare the counter with the threshold to set the PWM output
           pwm_out <= (pwm_counter < pwm_value) ? 1'b1 : 1'b0;
       end
 
    
endmodule
