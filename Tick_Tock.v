`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.03.2024 23:01:50
// Design Name: 
// Module Name: Audio_Testing
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

`define C4_FREQ  261.6
`define D4_FREQ  293.7
`define E4_FREQ  329.6
`define F4_FREQ 349.2    
`define G4_FREQ  392
`define A4_FREQ  440
`define B4_FREQ  493.9

`define Sec 100000000
`define chime 4999999 //0.5 seconds for tick/tock
`define Slow  99999999 //1 sec
`define Medium 69999999 // 0.7 sec
`define Fast 39999999 //0.4 sec
`define Endgame 9999999 //0.1 sec

module Tick_Tock(
    input basys_clk,
   // input [6:0] timing, //Total time through uart
   // input Start, Start game flag
    output [3:0] JB,
    input btnC
    );
    
    reg audio = 0;
    assign JB[0] = audio;
     
     wire tick; //1600 HZ
     wire tock; //800 HZ
     
     flexible_clock_module Hz_1600 (basys_clk, 31249 , tick);
     flexible_clock_module Hz_800 (basys_clk, 62499 , tock);
     
     
     reg [1:0] state = 0; //0:tick 1:Silence 2:tock 3:Scilence
     
         
     reg [31:0] counter = 0; //to change tick tock state
     reg [31:0] countdown = 0; // total timing then countdown
     reg [5:0] timing = 25; // For testing
     reg playing = 0; //Current game starting
     reg [6:0] Game_state = 0; //Determine the quater of the game
     reg pressed = 0;    
         // Output based on state, toggling between tick and tock
         always @(posedge basys_clk) begin
         pressed <= btnC;
         
         if (pressed && !btnC) begin //For actual use start flag to intialize
          if (!playing) begin
          countdown <= timing * `Sec - 1;
          Game_state <= timing / 4;
          playing <= 1;
          end
          end
          
          if (countdown > 0)
          countdown <= countdown  - 1;
         
          if (countdown > (3 * Game_state * `Sec)) begin
          counter <= counter + 1;
          if (counter >= `Slow && (state == 1 || state == 3)) begin
          counter <= 0;
          state <= state + 1;
          end
          end
          else if (countdown > (2 * Game_state * `Sec)) begin
          counter <= counter + 1;
          if (counter >= `Medium && (state == 1 || state == 3)) begin
              counter <= 0;
              state <= state + 1;
              end                          
              end
              else if (countdown > (Game_state * `Sec)) begin
              counter <= counter + 1;
              if (counter >= `Fast && (state == 1 || state == 3)) begin
              counter <= 0;
              state <= state + 1;
              end                     
              end
              else if(countdown > 0) begin
              counter <= counter + 1;
              if (counter >= `Endgame && (state == 1 || state == 3)) begin
                  counter <= 0;
                  state <= state + 1;
                  end                                                        
                  end                                                                      
                   
                  if (countdown > 0) begin 
                  if (counter >= `chime && (state == 0 || state == 2)) begin
                   counter <= 0;
                   state <= state + 1;
                   end
                  
                  if (state == 0)
                  audio <= tick;
                            
                 if (state == 1)
                 audio <= 0;
                 
                 if (state == 2)
                 audio <= tock;
                 
                 if (state == 3)
                  audio <= 0;
                 end            
                else begin
                audio <= 0;
                state <= 0;
                counter <= 0;
                playing <= 0;
                end
                   
                           
          end
          
          
 

   endmodule
    
