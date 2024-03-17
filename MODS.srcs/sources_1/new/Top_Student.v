`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  Sheng Bin
//
//////////////////////////////////////////////////////////////////////////////////

`include "constants.vh"

module Top_Student (
    input basys_clk,
    input btnU, btnL, btnR, btnD, btnC, 
    input [15:0] SW,
    output [7:0] JC,
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    output dp,
    inout PS2Clk, PS2Data
);

    assign JC[2] = 0; // Some boards require JC[2] to be cleared to 0 for OLED to work
    // =============== Instantiate OLED Module ====================
    wire [15:0] oled_data;
    wire frame_begin, sending_pixels, sample_pixel; 
    wire [12:0] pixel_index;
        
    wire clk_6p25m;
    flexible_clock_module clk_6p25m_module(basys_clk, 7 ,clk_6p25m);
        
    Oled_Display oled(
        .clk(clk_6p25m), 
        .reset(0), 
        .frame_begin(frame_begin), 
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JC[0]), 
        .sdin(JC[1]), 
        .sclk(JC[3]), 
        .d_cn(JC[4]), 
        .resn(JC[5]), 
        .vccen(JC[6]),
        .pmoden(JC[7]));
    
    // ====== Instantiate module for each basic task (COLOURS are placeholders for unimplemented tasks) 
        wire [15:0] oled_data_a;
        wire [15:0] oled_data_b;
        wire [15:0] oled_data_c;
        wire [15:0] oled_data_d; 
        wire [15:0] oled_data_group;
        
        wire [6:0] seg_e;
        wire [4:0] an_e;
        wire dp_e;
        Task_A task_a_module(.clk_6p25m(clk_6p25m), .btnC(btnC), .pixel_index(pixel_index), .oled_data(oled_data_a), .btnD(btnD), .sw(SW[5:1]));
        task_b task_b_module(.clk_6p25(clk_6p25m), .pixel_index(pixel_index), .CLOCK(basys_clk), .btnL(btnL), .btnR(btnR), .btnC(btnC), .reset_sw(SW[5:1]) ,.sw0(SW[0]), .oled_data(oled_data_b));
        task_c task_c_module(.bassys_clock(basys_clk), .btnD(btnD),  .index(pixel_index), .SW(SW[5:1]), .oled_data(oled_data_c));        
        task_d task_d_module(.basys_clk(basys_clk), .SW_reset(SW[5:1]),.SW0(SW[0]), .btnC(btnC), .btnL(btnL), .btnR(btnR), .btnU(btnU), .pixel_index(pixel_index) , .oled_data(oled_data_d));
        task_e task_e_module(.basys_clk(basys_clk), .SW(SW), .btnC(btnC), .PS2Clk(PS2Clk), .PS2Data(PS2Data), .JC(JC), .led(led), .seg(seg_e), .an(an_e), .dp(dp_e), .oled_data(oled_data_group), .pixel_index(pixel_index));
   
   


    // ====== Instantiate MUX to select which task to perform =======
    basic_task_mux basic_task_mux_module(
        .basys_clk(basys_clk), 
        .SW(SW), 
        .led(led),
        .seg_e(seg_e),
        .seg(seg),
        .an_e(an_e),
        .an(an),
        .dp_e(dp_e),
        .dp(dp),
        .oled_data_a(oled_data_a),
        .oled_data_b(oled_data_b),
        .oled_data_c(oled_data_c),
        .oled_data_d(oled_data_d),
        .oled_data_group(oled_data_group),
        .oled_data(oled_data)
        );    


endmodule

module basic_task_mux(
    input basys_clk, 
    input [15:0] SW, 
    output reg [15:0] led,
    input [6:0] seg_e,
    output reg [6:0] seg,
    input [3:0] an_e,
    output reg [3:0] an,
    input dp_e,
    output reg dp,
    input [15:0] oled_data_a,
    input [15:0] oled_data_b,
    input [15:0] oled_data_c,
    input [15:0] oled_data_d,
    input [15:0] oled_data_group,
    output reg [15:0] oled_data
    );
    
    // === Group Basic Task === (Task E)
    
    // Switches SW[4],SW[3],SW[2],SW[1] shall be used to select basic task to perform
    // if SW[5] == 1; group_task, else
    // if SW[4] == 1: task_d, else
    // if SW[3] == 1: task_c, else
    // if SW[2] == 1: task_b, else
    // if SW[1] == 1: task_a
    // When individual basic task is running, 7-segment should be OFF and specific LED turn ON
        // led[0] ON when task_a is running
        // led[1] ON when task_b is running
        // led[2] ON when task_c is running
        // led[3] ON when task_d is running
    always @ (posedge basys_clk) begin
        
        // SELECT GROUP TASK
        if (SW[5] == 1) begin
            led <= 16'b10000;
            seg <= seg_e;
            an <= an_e;
            dp <= dp_e;
            oled_data <= oled_data_group;
        end
        // SELECT TASK D
        else if (SW[4] == 1) begin
            led = 16'b1000;
            seg <= 7'b1111111;
            an <= 4'b1111;
            dp <= 1;
            oled_data <= oled_data_d;
        end
        // SELECT GROUP C
        else if (SW[3] == 1) begin
            led = 16'b100;
            seg <= 7'b1111111;
            an <= 4'b1111;
            dp <= 1;
            oled_data <= oled_data_c;
        end
        // SELECT GROUP B
        else if (SW[2] == 1) begin
            led = 16'b10;
            seg <= 7'b1111111;
            an <= 4'b1111;
            dp <= 1;
            oled_data <= oled_data_b;
        end
        // SELECT GROUP A
        else if (SW[1] == 1) begin
            led = 16'b1;
            seg <= 7'b1111111;
            an <= 4'b1111;
            dp <= 1;
            oled_data <= oled_data_a;
        end
        // NOTHING SELECTED (SHOW BLACK SCREEN)
        else begin
            led = 16'b0;
            seg <= 7'b1111111;
            an <= 4'b1111;
            dp <= 1;
            oled_data <= `BLACK;
        end
               
    end
    
    
endmodule