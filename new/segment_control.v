`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2024 07:36:08 PM
// Design Name: 
// Module Name: segment_control
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

// this module creates a counter that allows us to display password digits on 7-segment display
module segment_control(input basys_clk, input clk_200, input clk_2,
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