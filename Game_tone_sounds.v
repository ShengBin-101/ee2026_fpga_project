`timescale 1ns / 1ps                                   
//////////////////////////////////////////////////////////////////////////////////
        // Company: 
       // Engineer: 
                 // 
// Create Date: 30.03.2024 14:38:18
    // Design Name: 
// Module Name: Game_tone_sounds
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
                    
`define A_Sharp2 429036 //~ 116.54 HZ
`define A2 454544 //~110 HZ
`define G2 510203 //~98 HZ
`define F_Sharp2 540540 //~92.5 HZ
`define A_Flat2 481555 //~103.83 HZ
                    
`define A_Sharp3 214518 //~ 233.08 HZ
`define A3 227272 //~220 HZ
`define G3 255101 //~196 HZ
`define F_Sharp3 270270 //~185 HZ
`define C3 382233 //~130.81 HZ
`define E3 303379 //164.81 HZ 
`define A_Flat3 240789 //~207.65 HZ
`define E_Flat3 321418 //~155.56 HZ
`define D3 340529 //146.83 HZ
`define F3 286351 // 174.61 HZ
                    
`define A_Sharp4 107263 //~466.16 HZ
`define A4 113635 //~440 HZ
`define B4 101238 //~493.88 HZ
`define C4 191109 //~261.63 HZ
`define D4 170264 //~293.66 HZ
`define E4 151684 //~329.63 HZ
`define F4 143171 //~349.23 HZ
`define G4 127551 //~392 HZ
`define A_Flat4 120394 //415.30 HZ 
`define B_Flat4 107258 //466.16 HZ
`define E_Flat4 160704 //311.13 HZ
                    
`define A_Sharp5 53628 //932.33 HZ
`define A_Flat5 60196 //830.61 HZ
`define A5 56817 //880 HZ
`define B5 50618 //987.77 HZ
`define C5 95556 //~523.25 HZ
`define C_Sharp5 90191 //554.37 HZ
`define D5 85132 //~587.33 HZ
`define E_Flat5 80352 // ~622.25 HZ
`define E5 75842 //~659.26 HZ
`define F5 71585 //~698.46 HZ
`define F_Sharp5 67567 //~739.99 HZ
`define G5 63775 //~783.99 HZ
                    
`define C6 47777 //~1046.5 HZ
 
 `define Sec 100000000
`define chime 50000000 //0.5 seconds for tick/tock
`define Slow  100000000 //1 sec
`define Medium 70000000 // 0.7 sec
`define Fast 40000000 //0.4 sec
`define Endgame 10000000 //0.1 sec

                    
`define Beat_70 85714285 // 60 / 70
`define Delay_70 5000000
                    
`define Beat_150_8 5000000
`define Delay_150 312500
                    
`define Beat_150_3 13333333
`define Delay_150_3 833333
                    
`define Beat_130 46153846
`define Delay_130 2884615  
                    
module Game_tone_sounds(
    input basys_clk,
    output [3:0] JB,
    input btnC,
    input btnL,
    input btnR,
    input btnD,
    input btnU,
    input [3:0] SW,
    output reg [15:0] led,
    inout  PS2Clk,
    inout PS2Data
                  );
      
      
      
       wire [3:0] zpos;
       wire left, middle, right, new_event;
       reg [11:0] value = 0;
                       
           MouseCtl mouse_module(.clk(basys_clk), .rst(0), .zpos(zpos), .new_event(new_event), 
                                    .ps2_clk(PS2Clk), .ps2_data(PS2Data));
 
 
 
       // Counter variable
           reg [7:0] counting = 128;
                                  
       // Previous zpos value for edge detection
         reg [3:0] prev_zpos = 0;
   
      
      
    reg [3:0] volume_level = 8;
    wire [3:0] volume;
    assign volume = volume_level;         
     
                    
      wire ASharp_2;
            wire A2;
            wire G2;
      wire F_Sharp2;
       wire A_Flat2;
                    
      wire ASharp_3;
            wire A3;
            wire G3;
      wire F_Sharp3;
            wire C3;
            wire E3;
       wire A_Flat3;
       wire E_Flat3;
            wire D3;
            wire F3;
                    
            wire A4;
            wire B4;
            wire C4;
            wire D4;
            wire E4;
            wire F4;
            wire G4;
       wire A_Flat4;
       wire B_Flat4;
       wire E_Flat4;
      wire ASharp_4;
                    
                    
            wire A5;
            wire B5;
            wire C5;
            wire D5;
            wire E5;
            wire F5;
            wire G5;
     wire ASharp_5; 
      wire FSharp_5;
      wire CSharp_5;
       wire E_Flat5;
       wire A_Flat5;
                    
            wire C6;
       
       wire tick; //1600 HZ
       wire tock; //800 HZ
       
       wire three;
       wire two;
       wire one;
       wire Go;
                    
      reg audio = 0;
assign JB[0] = audio;
reg [5:0] state = 0;

    
     note_generator Hz_1000 (basys_clk  , 49999 , volume , three);
     note_generator Hz_600 (basys_clk , 83332 , volume , one);
     note_generator Hz_400 (basys_clk , 124999 , volume , Go); 

     
     note_generator Hz_1600 (basys_clk, 31249 , volume, tick);
     note_generator Hz_800 (basys_clk, 62499 , volume, tock);
                    
note_generator ASHARP_2 (basys_clk , `A_Sharp2 , volume, ASharp_2);
note_generator A_2 (basys_clk , `A2 , volume, A2);
note_generator G_2 (basys_clk , `G2 , volume, G2);
note_generator FSHARP_2 (basys_clk , `F_Sharp2 , volume, F_Sharp2);
note_generator AFlat_2 (basys_clk , `A_Flat2 , volume, A_Flat2);
                    
                    
note_generator ASHARP_3 (basys_clk , `A_Sharp3 , volume,  ASharp_3);
note_generator A_3 (basys_clk , `A3 , volume, A3);
note_generator G_3 (basys_clk , `G3 , volume, G3);
note_generator FSHARP_3 (basys_clk , `F_Sharp3 , volume, F_Sharp3);
note_generator C_3 (basys_clk , `C3 , volume, C3); 
note_generator E_3 (basys_clk , `E3 , volume, E3);
note_generator AFlat_3 (basys_clk , `A_Flat3 , volume, A_Flat3);
note_generator EFlat_3 (basys_clk , `E_Flat3 , volume, E_Flat3);
note_generator D_3 (basys_clk , `D3 , volume, D3);
note_generator F_3 (basys_clk , `F3 , volume, F3);
                    
note_generator A_4 (basys_clk , `A4 , volume, A4);
note_generator B_4 (basys_clk , `B4 , volume, B4);
note_generator C_4 (basys_clk , `C4 , volume, C4);
note_generator D_4 (basys_clk , `D4 , volume, D4);
note_generator E_4 (basys_clk , `E4 , volume, E4);
note_generator F_4 (basys_clk , `F4 , volume, F4);
note_generator G_4 (basys_clk , `G4 , volume, G4);
note_generator AFlat_4 (basys_clk , `A_Flat4 , volume, A_Flat4);
note_generator BFlat_4 (basys_clk , `B_Flat4 , volume, B_Flat4);
note_generator EFlat_4 (basys_clk , `E_Flat4, volume, E_Flat4);
note_generator ASHARP_4 (basys_clk , `A_Sharp4 , volume, ASharp_4);
                    
note_generator A_5 (basys_clk , `A5 , volume, A5);
note_generator B_5 (basys_clk , `B5 , volume, B5);
note_generator C_5 (basys_clk , `C5 , volume, C5);
note_generator D_5 (basys_clk , `D5 , volume, D5);
note_generator E_5 (basys_clk , `E5 , volume, E5);
note_generator F_5 (basys_clk , `F5 , volume, F5);
note_generator G_5 (basys_clk , `G5 , volume, G5);  
note_generator ASHARP_5 (basys_clk , `A_Sharp5 , volume, ASharp_5);
note_generator AFlat_5 (basys_clk , `A_Flat5 , volume, A_Flat5);
note_generator FSHARP_5 (basys_clk , `F_Sharp5 , volume, FSharp_5);
note_generator CSHARP_5 (basys_clk , `C_Sharp5 , volume, CSharp_5);
note_generator EFlat_5 (basys_clk , `E_Flat5 , volume, E_Flat5);
                    
note_generator C_6 (basys_clk , `C6 , volume, C6);
                    
reg [31:0] countdown = 0; // total timing then countdown
reg [5:0] timing = 25; // For testing
reg [31:0] counter = 0; 
reg [3:0] playing = 0;

parameter MAX_ADDR_win = 28351;
parameter MAX_ADDR_explode = 15359;
parameter MAX_ADDR_over = 27839;

 reg [15:0] address_win = 28351;
 reg [15:0] address_explode = 15359;
 reg [15:0] address_over = 27839;
 wire [15:0] raw_audio_win; 
 wire [15:0] scaled_audio_win;
 wire [15:0] raw_audio_explode; 
 wire [15:0] scaled_audio_explode;
 wire [15:0] raw_audio_over;      
 wire [15:0] scaled_audio_over;            

blk_mem_gen_winner winning (  
         .clka(basys_clk),          // Clock input
         .ena(playing == 7),        // Memory enable
         .addra(address_win),     // Address input
         .douta(raw_audio_win)   // Data output
     );

blk_mem_gen_explode exploding (  
         .clka(basys_clk),          // Clock input
         .ena(playing == 8),        // Memory enable
         .addra(address_explode),     // Address input
         .douta(raw_audio_explode)   // Data output
     );

blk_mem_gen_game_over GameOver (
        .clka(basys_clk),          // Clock input
       .ena(playing == 9),        // Memory enable
       .addra(address_over),     // Address input
       .douta(raw_audio_over)   // Data output
   );

volume_control over_up (basys_clk, raw_audio_over , volume , scaled_audio_over);
volume_control win_up (basys_clk, raw_audio_win , volume , scaled_audio_win);
volume_control explode_up (basys_clk, raw_audio_explode , volume , scaled_audio_explode);



wire audio_win;
wire audio_explode;
wire audio_over;

PWM_module pwm_win (basys_clk , scaled_audio_win, audio_win); 
PWM_module pwm_explode (basys_clk ,scaled_audio_explode , audio_explode); 
PWM_module pwm_over (basys_clk , scaled_audio_over , audio_over);

parameter sample_rate = 6250; //100 MHZ / 16 KHZ 
 

always @(volume_level) begin
    led = 16'b0;  // Reset all LEDs to off
    case (volume_level)
        4'd0: led = 16'b0;
        4'd1: led = 16'b1;
        4'd2: led= 16'b11;
        4'd3: led = 16'b111;
        4'd4: led = 16'b1111;
        4'd5: led = 16'b11111;
        4'd6: led = 16'b111111;
        4'd7: led = 16'b1111111;
        4'd8: led = 16'b11111111;
        4'd9: led = 16'b111111111;
        4'd10: led = 16'b1111111111;
        4'd11: led = 16'b11111111111;
        4'd12: led = 16'h0FFF;
        4'd13: led = 16'h1FFF;
        4'd14: led = 16'h3FFF;
        4'd15: led = 16'h7FFF;
        default: led = 16'b0; // In case of an undefined input
    endcase
end 
                    
always @ (posedge basys_clk) begin 


if (!SW[1]) begin
   if (new_event) begin
   if (prev_zpos == zpos)
   volume_level <= volume_level; //unchanged
   // Detect scroll event and update counter
   else if (zpos[3] && volume_level < 15) 
       // Scroll up detected
       volume_level <= volume_level + 1;
   else if (!zpos[3] && volume_level > 0)
       // Scroll down detected
       volume_level <= volume_level - 1;
   
   
   prev_zpos <= zpos;
   
   end
   end 
                    
if (!SW[0] && playing == 4) 
       playing <= 0;

if (SW[0] && playing == 6) 
       playing <= 0;
                    
if (SW[0] && btnD && state == 0 && playing == 0) begin
        state <= 1; 
       playing <= 4;
             end    
  
 if (!SW[0] && btnD && state == 0 && playing == 0) begin
 state <= 1;
 playing <= 6;
 end 
 
 if (SW[0] && btnC && state == 0 && playing == 0) begin
 state <= 1;
 playing <= 7;
 address_win <= 0;
 end   
 
  if (SW[0] && btnR && state == 0 && playing == 0) begin
 state <= 1;
 playing <= 8;
 address_explode <= 0;
 end                    
                    
if (!SW[0] && btnR && state == 0 && playing == 0) begin
        state <= 1; 
       playing <= 3;
              end   
                    
if (!SW[0] && btnC && state == 0 && playing == 0) begin
        state <= 1; 
       playing <= 1;
               end  
                    
if (!SW[0] && btnL && state == 0 && playing == 0) begin
        state <= 1; 
       playing <= 2;
                 end


if (SW[0] && btnL && state == 0 && playing == 0) begin 
    state <= 1;
    playing <= 9;
    address_over <= 0;
    end
 
 if (btnU && state == 0 && playing == 0) begin
  state <= 1;
  playing <= 5;
  countdown <= `Sec * timing;
  end
                    
if ((state == 0 && playing != 0) || (state != 0 && playing == 0)) begin
         state <= 0;
       playing <= 0;
                 end
 
 if (state != 0 && playing != 0)
     counter <= counter + 1;
   else 
   counter <= 0;
                    
 
 if (playing == 5) begin
 countdown <= countdown - 1;
  if (countdown > ((timing / 4) * 3  * `Sec)) begin
          if (counter >= `Slow && (state == 2 || state == 4)) begin
          counter <= 0;
          state <= state + 1;
          end
          end
          else if (countdown > ((timing / 4) * 2 * `Sec)) begin
          if (counter >= `Medium && (state == 2 || state == 4)) begin
              counter <= 0;
              state <= state + 1;
              end                          
              end
              else if (countdown > ((timing / 4) * `Sec)) begin
              if (counter >= `Fast && (state == 2 || state == 4)) begin
              counter <= 0;
              state <= state + 1;
              end                     
              end
              else if(countdown > 0) begin
              if (counter >= `Endgame && (state == 2|| state == 4)) begin
                  counter <= 0;
                  state <= state + 1;
                  end                                                        
                  end 
                  
             if (countdown > 0) begin 
              if (counter >= `chime && (state == 1 || state == 3)) begin
                  counter <= 0;
                  state <= state + 1;
                  end
                  if (state == 1)
                  audio <= tick;
                                              
                  if (state == 2)
                    audio <= 0;
                                   
                  if (state == 3)
                  audio <= tock;
                                   
               if (state == 4)
                audio <= 0;

              if (state >= 5)
              state <= 1;    
                  end
              else if (countdown == 0) begin
              playing <= 0;
              state <= 0;
              counter <= 0;
              end
                  
                  end                   
                    
 

 if (counter > sample_rate && (playing == 7 || playing == 8 || playing == 9)) begin
     counter <= 0;
     if (address_win < MAX_ADDR_win && playing == 7) begin
     address_win <= address_win + 1;
     end
     else if (address_explode < MAX_ADDR_explode && playing == 8) begin
     address_explode <= address_explode + 1;
     end
     else if (address_over < MAX_ADDR_over && playing == 9) begin
     address_over <= address_over + 1;
     end
     else begin
     playing <= 0;
     state <= 0;
     end
     end
      
     
    
    
     
                    
if (state == 1) begin
                    
if (playing == 1) begin
if (counter < `Beat_70 )
  audio <= ASharp_3;
else if (counter <= `Beat_70 + `Delay_70)
         audio <= 0;
else if (counter > `Beat_70 + `Delay_70) begin
         state <= 2;
       counter <= 0;
                 end
                 end
                    
if (playing == 2) begin
if (counter < `Beat_150_8 )
        audio <= F4;
else if (counter <= `Beat_150_8 + `Delay_150)
         audio <= 0;
else if (counter > `Beat_150_8 + `Delay_150) begin
         state <= 2;
       counter <= 0;
                 end
                 end
                    
if (playing == 3) begin
if (counter < `Beat_150_3 )
        audio <= G3;
else if (counter <= `Beat_150_3 + `Delay_150_3)
         audio <= 0;
else if (counter > `Beat_150_3 + `Delay_150_3) begin
         state <= 2;
       counter <= 0;
                 end
            end     
                    
if (playing == 4) begin
if (counter < `Beat_130 /2)
        audio <= D5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2))
         audio <= 0;
else if (counter > (`Beat_130 / 2) + (`Delay_150_3 / 2)) begin
         state <= 2;
       counter <= 0;
                 end
           end                         
          
 if (playing == 6) begin
 if (counter < `chime)                  
         audio <= Go;           
   else if (counter <= 2 * `chime)
           audio <= 0;
   else begin
   state <= 2;
   counter <= 0;
   end
   end
 
 if (playing == 7) 
   audio <= audio_win;
   
 if (playing == 8)
 audio <= audio_explode;
 
 if (playing == 9)
 audio <= audio_over;
   
   end        
         
         
                    
if (state == 2) begin
                    
if (playing == 1) begin
if (counter < `Beat_70 )
        audio <= A3;
else if (counter <= `Beat_70 + `Delay_70)
         audio <= 0;
else if (counter > `Beat_70 + `Delay_70) begin
         state <= 3;
       counter <= 0;
                 end
                 end
                    
if (playing == 2) begin
if (counter < `Beat_150_8 )
        audio <= G4;
else if (counter <= `Beat_150_8 + `Delay_150)
         audio <= 0;
else if (counter > `Beat_150_8 + `Delay_150) begin
         state <= 3;
       counter <= 0;
                 end
                 end
                    
if (playing == 3) begin
if (counter < `Beat_150_3 )
        audio <= C4;
else if (counter <= `Beat_150_3 + `Delay_150_3)
         audio <= 0;
else if (counter > `Beat_150_3 + `Delay_150_3) begin
         state <= 3;
       counter <= 0;
                 end
               end  
                    
if (playing == 4) begin
if (counter < `Beat_130 /2)
        audio <= A4;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2))
         audio <= 0;
else if (counter > (`Beat_130 / 2) + (`Delay_150_3 / 2)) begin
         state <= 3;
       counter <= 0;
                 end
       end                     
    
     if (playing == 6) begin
       if (counter < `chime)                  
               audio <= Go;           
         else if (counter < 2 * `chime)
                 audio <= 0;
         else begin
         state <= 3;
         counter <= 0;
         end
         end
    
                    
                 end
                    
if (state == 3) begin
                    
if (playing == 1) begin
if (counter < `Beat_70 )
        audio <= A3;
else if (counter <= `Beat_70 + `Delay_70)
         audio <= 0;
else if (counter > `Beat_70 + `Delay_70) begin
         state <= 4;
       counter <= 0;
                 end
                 end
                    
                    
                    
if (playing == 2) begin
if (counter < `Beat_150_8 )
        audio <= A4;
else if (counter <= `Beat_150_8 + `Delay_150)
         audio <= 0;
else if (counter > `Beat_150_8 + `Delay_150) begin
         state <= 4;
       counter <= 0;
                 end
                 end
                    
if (playing == 3) begin
if (counter < `Beat_150_3 )
        audio <= E4;
else if (counter <= `Beat_150_3 + (`Delay_150_3 * 3))
         audio <= 0;
else if (counter > `Beat_150_3 + (`Delay_150_3 * 3)) begin
         state <= 4;
       counter <= 0;
                 end
                end 
                    
if (playing == 4) begin
if (counter < `Beat_130 /2)
        audio <= D5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2))
         audio <= 0;
else if (counter > (`Beat_130 / 2) + (`Delay_150_3 / 2)) begin
         state <= 4;
       counter <= 0;
                 end
              end
              
               if (playing == 6) begin
                    if (counter < `chime)                  
                            audio <= Go;           
                      else if (counter <= 2 * `chime)
                              audio <= 0;
                      else begin
                      state <= 4;
                      counter <= 0;
                      end
                      end
              
              
                 
                 end
                    
if (state == 4) begin
                    
if (playing == 1) begin
if (counter < `Beat_70 )
        audio <= G3;
else if (counter <= `Beat_70 + `Delay_70)
         audio <= 0;
else if (counter > `Beat_70 + `Delay_70) begin
         state <= 5;
       counter <= 0;
                 end
                 end
                    
if (playing == 2) begin
if (counter < `Beat_150_8 )
        audio <= B4;
else if (counter <= `Beat_150_8 + `Delay_150)
         audio <= 0;
else if (counter > `Beat_150_8 + `Delay_150) begin
         state <= 5;
       counter <= 0;
                 end
       end          
                    
if (playing == 3) begin
if (counter < `Beat_150_3 )
        audio <= G4;
else if (counter <= `Beat_150_3 + `Delay_150_3)
         audio <= 0;
else if (counter > `Beat_150_3 + `Delay_150_3) begin
         state <= 5;
       counter <= 0;
                 end
                end 
                    
if (playing == 4) begin
if (counter < `Beat_130 /2 * 3)
        audio <= A5;
else if (counter <= (`Beat_130 / 2 * 3) + (`Delay_130 / 2 * 3))
         audio <= 0;
         else  begin
         state <= 5;
       counter <= 0;
                 end
              end                    
                    
     if (playing == 6) begin
                if (counter < 2 *`chime)                  
                        audio <= tock;           
                  else begin
                  audio <= 0;
                  state <= 0;
                  counter <= 0;
                  playing <= 0;
                  end
                  end
                                      
                 end
                    
                    
                    
if (state == 5) begin
                    
if (playing == 1) begin
if (counter < (2 * `Beat_70))
        audio <= G3;
else if (counter <= (2 * `Beat_70) + `Delay_70)
         audio <= 0;
else if (counter > (2 * `Beat_70) + `Delay_70) begin
         state <= 6;
      counter <= 0; 
                 end
    end             
                    
if (playing == 2) begin
if (counter < `Beat_150_8 )
        audio <= C5;
else if (counter <= `Beat_150_8 + `Delay_150)
         audio <= 0;
else if (counter > `Beat_150_8 + `Delay_150) begin
         state <= 6;
       counter <= 0;
                 end
                end 
                    
if (playing == 3) begin
if (counter < `Beat_150_3 )
        audio <= C5;
else if (counter <= `Beat_150_3 + `Delay_150_3)
         audio <= 0;
else if (counter > `Beat_150_3 + `Delay_150_3) begin
         state <= 6;
       counter <= 0;
                 end
end                                      
                    
if (playing == 4) begin
if (counter < `Beat_130)
        audio <= G5;
else if (counter <= (`Beat_130) + (`Delay_130))
         audio <= 0;
         else  begin
         state <= 6;
       counter <= 0;
                 end
              end   
                    
                    
                    
                 end
                    
if (state == 6) begin
                    
if (playing == 1) begin
if (counter < (2 * `Beat_70))
  audio <= F_Sharp3;
else if (counter <= (2 * `Beat_70) + `Delay_70)
         audio <= 0;
else if (counter > (2 * `Beat_70) + `Delay_70) begin
         state <= 0;
       counter <= 0;
       playing <= 0;
                 end
                end 
                    
if (playing == 2) begin
if (counter < `Beat_150_8 )
        audio <= D5;
else if (counter <= `Beat_150_8 + `Delay_150)
         audio <= 0;
else if (counter > `Beat_150_8 + `Delay_150) begin
         state <= 7;
       counter <= 0;
                 end
   end              
                    
if (playing == 3) begin
if (counter < `Beat_150_3 )
        audio <= E5;
else if (counter <= `Beat_150_3 + (`Delay_150_3 * 3))
         audio <= 0;
else if (counter > `Beat_150_3 + (`Delay_150_3 * 3)) begin
         state <= 7;
       counter <= 0;
                 end
                end 
                    
if (playing == 4) begin
if (counter < `Beat_130 /2)
  audio <= FSharp_5;
else if (counter <= (`Beat_130 /2) + (`Delay_130 /2))
         audio <= 0;
         else  begin
         state <= 7;
       counter <= 0;
                 end
              end   
                    
                    
                 end
                    
if (state == 7) begin
if (playing == 2) begin
if (counter < `Beat_150_8 )
        audio <= E5;
else if (counter <= `Beat_150_8 + `Delay_150)
         audio <= 0;
else if (counter > `Beat_150_8 + `Delay_150) begin
         state <= 8;
       counter <= 0;
                 end
                end 
                    
if (playing == 3) begin
if (counter < 3 *`Beat_150_3 )
        audio <= G5;
else if (counter <= (`Beat_150_3 + `Delay_150_3) * 3)
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3) * 3) begin
         state <= 8;
       counter <= 0;
                 end
end                     
                    
                    
if (playing == 4) begin
if (counter < `Beat_130 /2)
        audio <= E5;
else if (counter <= (`Beat_130 /2) + (`Delay_130 /2))
         audio <= 0;
         else  begin
         state <= 8;
       counter <= 0;
                 end
              end   
                    
                 end
                    
if (state == 8) begin
if (playing == 2) begin
if (counter < `Beat_150_8 )
        audio <= F5;
else if (counter <= `Beat_150_8 + `Delay_150)
         audio <= 0;
else if (counter > `Beat_150_8 + `Delay_150) begin
         state <= 9;
       counter <= 0;
                 end
                 end
                    
if (playing == 3) begin
if (counter < 3 *`Beat_150_3 / 2 )
        audio <= E5;
else if (counter <= (`Beat_150_3 + `Delay_150_3) * 3 / 2)
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3) * 3 / 2) begin
         state <= 9;
       counter <= 0;
                 end
                end 
                    
if (playing == 4) begin
if (counter < `Beat_130)
  audio <= CSharp_5;
else if (counter <= ((`Beat_130 / 2) * 7 + (`Delay_130)))
         audio <= 0;
         else  begin
         state <= 9;
       counter <= 0;
                 end
              end   
                    
                    
               end  
                    
                    
if (state == 9) begin
if (playing == 2) begin
if (counter < `Beat_150_8 * 8 )
        audio <= G5;
else if (counter <= (`Beat_150_8 * 8) + `Delay_150)
         audio <= 0;
else if (counter > (`Beat_150_8 * 8) + `Delay_150) begin
         state <= 0;
       counter <= 0;
       playing <= 0;
                 end
              end   
                    
if (playing == 3) begin
if (counter < 3 *`Beat_150_3 / 2 )
         audio <= 0;
else if (counter <= (`Beat_150_3 + `Delay_150_3) * 3 / 2)
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3) * 3 / 2) begin
        state <= 10;
       counter <= 0;
                 end
               end  
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
  audio <= CSharp_5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2))
         audio <= 0;
         else  begin
        state <= 10;
       counter <= 0;
                 end
               end  
                    
                    
               end  
                    
if (state == 10) begin
                    
if (playing == 3) begin
if (counter < `Beat_150_3)
   audio <= A_Flat3;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3)) begin
        state <= 11;
       counter <= 0;
                 end
               end  
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
        audio <= A4;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 11;
       counter <= 0;
                 end
                 end
              end   
                    
                    
                    
if (state == 11) begin
if (playing == 3) begin
if (counter < `Beat_150_3)
        audio <= C4;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3)) begin
        state <= 12;
       counter <= 0;
                 end
           end      
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
  audio <= CSharp_5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 12;
      counter <= 0; 
                end 
                 end
                 end
                    
if (state == 12) begin
if (playing == 3) begin
if (counter < `Beat_150_3)
   audio <= E_Flat4;
else if (counter <= (`Beat_150_3 + (3 *`Delay_150_3)))
         audio <= 0;
else if (counter > (`Beat_150_3 + (3 *`Delay_150_3))) begin
        state <= 13;
       counter <= 0;
                 end
              end   
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2 * 3)
  audio <= FSharp_5;
else if (counter <= (`Beat_130 / 2 * 3) + (`Delay_130 / 2 * 3)) 
         audio <= 0;
         else  begin
        state <= 13;
      counter <= 0; 
                end 
                 end
                    
                 end
                    
if (state == 13) begin
if (playing == 3) begin
if (counter < `Beat_150_3)
   audio <= A_Flat4;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3)) begin
        state <= 14;
       counter <= 0;
                 end
            end     
                    
if (playing == 4) begin 
if (counter < `Beat_130)
        audio <= E5;
else if (counter <= (`Beat_130) + (`Delay_130)) 
         audio <= 0;
         else  begin
        state <= 14;
      counter <= 0; 
                end 
               end  
                 end
                    
if (state == 14) begin
if (playing == 3) begin
if (counter < `Beat_150_3)
        audio <= C5;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3)) begin
        state <= 15;
       counter <= 0;
                 end
              end   
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
  audio <= CSharp_5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 15;
      counter <= 0; 
                end 
end                           
                    
              end   
                    
if (state == 15) begin
if (playing == 3) begin
if (counter < `Beat_150_3)
   audio <= E_Flat5;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3)) begin
        state <= 16;
       counter <= 0;
                 end
              end   
                    
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
        audio <= D5;
else if (counter <= (`Beat_130 /2) + (`Delay_130 / 2))
         audio <= 0;
         else  begin
        state <= 16;
       counter <= 0;
                 end
                end 
                    
                    
            end     
                    
if (state == 16) begin
if (playing == 3) begin
if (counter < 3 *`Beat_150_3)
   audio <= A_Flat5;
else if (counter <= 3 *(`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > 3 * (`Beat_150_3 + `Delay_150_3)) begin
        state <= 17;
       counter <= 0;
                 end
              end   
                    
if (playing == 4) begin
if (counter < `Beat_130)
  audio <= FSharp_5;
else if (counter <= (`Beat_130 / 2 * 7) + (`Delay_130)) 
         audio <= 0;
         else  begin
        state <= 17;
      counter <= 0; 
                end 
           end      
                    
                    
               end  
                    
if (state == 17) begin 
if (playing == 3) begin
if (counter < 3 *`Beat_150_3 / 2 )
   audio <= E_Flat5;
else if (counter <= (`Beat_150_3 + `Delay_150_3) * 3 / 2)
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3) * 3 / 2) begin
        state <= 18;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
        audio <= D5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 18;
      counter <= 0; 
                end 
    end             
                    
                    
                    
end                           
                    
if (state == 18) begin 
if (playing == 3) begin
if (counter < 3 *`Beat_150_3 / 2 )
         audio <= 0;
else if (counter <= (`Beat_150_3 + `Delay_150_3) * 3 / 2)
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3) * 3 / 2) begin
        state <= 19;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
        audio <= A4;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 19;
      counter <= 0; 
                end 
     end            
                    
                    
                end 
                    
if (state == 19) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  )
  audio <= ASharp_3;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3)) begin
        state <= 20;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
        audio <= D5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 20;
      counter <= 0; 
                end 
end                    
                    
                    
                    
                end 
                    
                    
if (state == 20) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  )
        audio <= D4;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3)) begin
        state <= 21;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2 * 3)
        audio <= A5;
else if (counter <= (`Beat_130 / 2 * 3) + (`Delay_130)) 
         audio <= 0;
         else  begin
        state <= 21;
      counter <= 0; 
                end 
                 end
                    
                    
                end 
                    
                    
if (state == 21) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  )
        audio <= F4;
else if (counter <= (`Beat_150_3 + (3 *`Delay_150_3)))
         audio <= 0;
else if (counter > `Beat_150_3 +  (3 *`Delay_150_3)) begin
        state <= 22;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130)
        audio <= G5;
else if (counter <= (`Beat_130) + (`Delay_130)) 
         audio <= 0;
         else  begin
        state <= 22;
      counter <= 0; 
                end 
                 end
                    
                end 
                    
                    
if (state == 22) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  )
  audio <= ASharp_4;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > `Beat_150_3 +  `Delay_150_3) begin
        state <= 23;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
  audio <= FSharp_5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 23;
      counter <= 0; 
                end 
end                      
                    
                    
                    
                end 
                    
                    
if (state == 23) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  )
        audio <= D5;
else if (counter <= (`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter > (`Beat_150_3 + `Delay_150_3)) begin
        state <= 24;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
        audio <= E5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 24;
      counter <= 0; 
                end 
end                      
                    
                    
                    
                    
                end 
                    
if (state == 24) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  )
        audio <= F5;
else if (counter <= `Beat_150_3 + `Delay_150_3)
         audio <= 0;
else if (counter >  (`Beat_150_3 + `Delay_150_3)) begin
        state <= 25;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130)
  audio <= CSharp_5;
else if (counter <= (`Beat_130 / 2 * 7) + (`Delay_130)) 
         audio <= 0;
         else  begin
        state <= 25;
      counter <= 0; 
                end 
      end           
                    
                    
                    
                    
                    
         end        
                    
if (state == 25) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  * 3 )
  audio <= ASharp_5;
else if (counter <= 3 *(`Beat_150_3 + `Delay_150_3))
         audio <= 0;
else if (counter >  3 * (`Beat_150_3 +  `Delay_150_3)) begin
        state <= 26;
       counter <= 0;
                 end
                 end
if (playing == 4) begin
if (counter < `Beat_130 / 2)
  audio <= CSharp_5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 26;
      counter <= 0; 
                end 
                 end
                    
                    
         end        
                    
                    
if (state == 26) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  )
  audio <= ASharp_5;
else if (counter <= `Beat_150_3 + `Delay_150_3)
         audio <= 0;
else if (counter > (`Beat_150_3 +  `Delay_150_3)) begin
        state <= 27;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
        audio <= A4;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 27;
      counter <= 0; 
                end 
                 end
                    
                    
         end        
                    
                    
                    
if (state == 27) begin 
if (playing == 3) begin
if (counter < `Beat_150_3  )
  audio <= ASharp_5;
else if (counter <= `Beat_150_3 + `Delay_150_3)
         audio <= 0;
else if (counter > (`Beat_150_3 +  `Delay_150_3)) begin
        state <= 28;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2)
  audio <= CSharp_5;
else if (counter <= (`Beat_130 / 2) + (`Delay_130 / 2)) 
         audio <= 0;
         else  begin
        state <= 28;
      counter <= 0; 
                end 
                 end
                    
                    
         end        
                    
if (state == 28) begin 
if (playing == 3) begin
if (counter < `Beat_150_3)
  audio <= ASharp_5;
else if (counter <= `Beat_150_3 + 3 * `Delay_150_3)
         audio <= 0;
else if (counter > `Beat_150_3 +  3 *`Delay_150_3) begin
        state <= 29;
       counter <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2 * 3)
  audio <= FSharp_5;
else if (counter <= (`Beat_130 / 2 * 3) + (`Delay_130 / 2 * 3)) 
         audio <= 0;
         else  begin
        state <= 29;
      counter <= 0; 
                end 
    end             
                    
         end        
                    
if (state == 29) begin 
if (playing == 3) begin
if (counter < 12 * `Beat_150_3)
        audio <= C6;
else if (counter <= `Beat_150_3 +  `Delay_150_3)
         audio <= 0;
else if (counter > `Beat_150_3 +  `Delay_150_3) begin
         state <= 0;
       counter <= 0;
       playing <= 0;
                 end
                 end
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2 * 3)
        audio <= E5;
else if (counter <= (`Beat_130 ) + (`Delay_130)) 
         audio <= 0;
         else  begin
        state <= 30;
      counter <= 0; 
                end 
end                           
                    
         end        
                    
if (state == 30) begin         
if (playing == 4) begin
                    
if (counter < `Beat_130 / 2) 
  audio <= CSharp_5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 31;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 31) begin         
if (playing == 4) begin
                    
if (counter < `Beat_130 * 2) 
        audio <= D5;
else if (counter <= `Beat_130 * 4 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 32;
       counter <= 0;
                end 
                 end
                    
            end     
                    
if (state == 32) begin
if (playing == 4) begin
                    
if (counter < `Beat_130 * 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 33;
       counter <= 0;
                end 
                 end
                    
                    
end                        
                    
if (state == 33) begin
if (playing == 4) begin
                    
if (counter < `Beat_130 * 2) 
        audio <= A5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 34;
       counter <= 0;
                end 
                 end
                    
                 end
                    
                    
if (state == 34) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= G5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 35;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 35) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= A5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 36;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 36) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= G5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 37;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 37) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 38;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 38) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
        audio <= E5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 39;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 39) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
  audio <= CSharp_5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 40;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 40) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
        audio <= E5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 41;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 41) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 42;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 42) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= G5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 43;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 43) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 44;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 44) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= E5;
else if (counter <= `Beat_130 / 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 45;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 45) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
        audio <= D5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 46;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 46) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 47;
       counter <= 0;
                end 
                 end
                    
                 end
                    
                    
if (state == 47) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
        audio <= A5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 48;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 48) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= G5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 49;
       counter <= 0;
                end 
                 end
                    
                 end
                    
                    
if (state == 49) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 50;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 50) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= G5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 51;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 51) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= A5;
else if (counter <= `Beat_130 / 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 52;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 52) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
        audio <= B5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 53;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 53) begin
                    
if (playing == 4) begin
if (counter < `Beat_130) 
        audio <= A5;
else if (counter <= `Beat_130 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 54;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 54) begin
                    
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= G5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 55;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 55) begin
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 / 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 56;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 56) begin
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
        audio <= G5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
        state <= 57;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 57) begin
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 58;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 58) begin
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= G5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 59;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 59) begin
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
  audio <= FSharp_5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 60;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 60) begin
if (playing == 4) begin
if (counter < `Beat_130 / 2) 
        audio <= E5;
else if (counter <= `Beat_130 / 2 + (`Delay_130 / 2))
         audio <= 0;
          else begin
        state <= 61;
       counter <= 0;
                end 
                 end
                    
                 end
                    
if (state == 61) begin
if (playing == 4) begin
if (counter < `Beat_130 * 2) 
        audio <= D5;
else if (counter <= `Beat_130 * 2 + (`Delay_130))
         audio <= 0;
          else begin
         state <= 1;
       counter <= 0;
                end 
                 end
                    
                 end
                    
                 end
                    
                    
           endmodule
                    
