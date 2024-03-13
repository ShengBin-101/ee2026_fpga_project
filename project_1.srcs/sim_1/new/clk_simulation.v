`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2024 14:33:00
// Design Name: 
// Module Name: clk_simulation
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


module clk6p25m(

    );
    
    reg bassys_clock;
    reg [31:0] sim_m;
    wire clock_6_25;
    
    flexible_clock clk6p25m (bassys_clock, sim_m, clock_6_25);
    
    initial begin 
    bassys_clock = 0;
    sim_m = 7;
    end
    
    always begin
    #5 bassys_clock = ~bassys_clock;
    end
    
    
endmodule
