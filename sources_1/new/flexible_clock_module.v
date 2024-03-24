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


module flexible_clock_module(
    input basys_clk,
    input [31:0] my_m_value,
    output reg output_clk
    );
    reg [31:0] COUNT = 0;
        
    always @ (posedge basys_clk) begin
        COUNT <= (COUNT == my_m_value) ? 0 : COUNT + 1;
        output_clk <= (COUNT == 0) ? ~output_clk : output_clk;
    end
endmodule
