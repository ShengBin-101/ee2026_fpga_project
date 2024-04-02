`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 07:38:53 PM
// Design Name: 
// Module Name: master_select
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
