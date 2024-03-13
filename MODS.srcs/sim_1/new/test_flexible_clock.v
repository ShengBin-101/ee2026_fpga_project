`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 02:20:56 PM
// Design Name: 
// Module Name: test_flexible_clock
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


module test_flexible_clock();
 reg CLOCK; wire sec_clock; reg [31:0] m;
    
   flexible_clock obj1 (CLOCK, m, sec_clock);  
    
   initial begin  
       CLOCK = 0;  
       m = 7;
   end  
    
always begin  
   #5 CLOCK = ~CLOCK;  
end 

endmodule
