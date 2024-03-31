`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2024 09:56:36 PM
// Design Name: 
// Module Name: uart_16bit_buffer
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


module uart_16bit_buffer (
    input clk,
    input reset,
    input [15:0] data_in,
    output reg [15:0] data_out
);

    reg [7:0] buffer[1:0];
    reg [3:0] index;
    reg send_enable;
    wire receive_enable;
    reg [3:0] counter;
    
    // Connect to UART_UNIT module
    wire read_signal;
    wire send_signal;
    wire rx_full;
    wire rx_empty;
    wire [7:0] write_data;
    wire [7:0] rec_data;
    
    assign read_signal = 1'b0; // Not using UART_UNIT's read feature in this module
    assign send_signal = (counter == 0); // Enable sending when counter is 0
    assign send_data = (counter == 0) ? buffer[0] : buffer[1]; // Data to be sent
    assign receive_enable = (counter == 1); // Enable receiving when counter is 1
    assign rec_data = data_in; // Data received from UART_UNIT
    
    // Instantiate UART_UNIT module
    UART_UNIT uart_inst (
        .clk_100MHz(clk),
        .reset(reset),
        .read_uart(read_signal),
        .write_uart(send_signal),
        .rx(buffer[index]), // RX buffer
        .write_data(write_data),
        .rx_full(rx_full),
        .rx_empty(rx_empty),
        .read_data(rec_data),
        .tx(TX_to_B)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer[0] <= 8'h00;
            buffer[1] <= 8'h00;
            index <= 4'b0000;
            counter <= 4'b0000;
            data_out <= 16'h0000;
        end else begin
            case (counter)
                4'b00: begin // Send first 8 bits
                    if (send_enable) begin
                        buffer[0] <= data_in[7:0];
                        index <= 4'b0001;
                        counter <= counter + 1;
                    end
                end
                4'b01: begin // Send next 8 bits
                    if (send_enable) begin
                        buffer[1] <= data_in[15:8];
                        index <= 4'b0000;
                        counter <= counter + 1;
                    end
                end
                4'b10: begin // Receive first 8 bits
                    if (receive_enable) begin
                        data_out[7:0] <= buffer[0];
                        index <= 4'b0001;
                        counter <= counter + 1;
                    end
                end
                4'b11: begin // Receive next 8 bits
                    if (receive_enable) begin
                        data_out[15:8] <= buffer[1];
                        index <= 4'b0000;
                        counter <= counter + 1;
                    end
                end
            endcase
        end
    end

endmodule
