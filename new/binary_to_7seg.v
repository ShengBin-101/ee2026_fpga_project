`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 07:25:17 PM
// Design Name: 
// Module Name: binary_to_7seg
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


