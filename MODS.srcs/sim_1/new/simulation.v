`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 02:16:19 PM
// Design Name: 
// Module Name: simulation
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


module simulation(

    );
    
    // Simulation Inputs
        reg SIM_CLOCK;
        // Simulation Outputs
        reg SIM_M;
        wire output_clk;
        
        flexible_clock_module dut(SIM_CLOCK, 7, output_clk);
        
        initial begin
        SIM_CLOCK = 0;
        
        end
                
        always begin
            #5 SIM_CLOCK = ~SIM_CLOCK;
        end
    
endmodule
