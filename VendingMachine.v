`include "binary_to_segmented.v"

module vending_machine (
    input C_5, // coin 5 sensor
    input C_10, // coin 10 sensor
    input C_25, // coin 25 sensor
    input P_35, // product 35 request
    input P_50, // product 50 request
    input cancel, // cancel request
    input clk, // clock signal
    input reset, // reset signal
    output reg P_35_out, // product 35 output
    output reg P_50_out, // product 50 output
    output reg C_5_out, // coin 5 output
    output reg C_10_out, // coin 10 output
    output reg C_25_out, // coin 25 output
    output [6:0] balance_seg_1, // balance segment 1
    output [6:0] balance_seg_2, // balance segment 2
    output idle_led, // idle light
    output dispense_led, // dispensing product light
    output return_led, // returning coins light
    output insufficient_led // insufficient balance light
);

    parameter IDLE = 2'b00; // waiting for input(coin/product request)
    parameter DISPENSE = 2'b01; // dispensing product
    parameter INSUFFICIENT = 2'b10; // insufficient balance for product
    parameter RETURN = 2'b11; // returning coins

    reg [1:0] state; // one of the 4 states
    reg [7:0] balance; // balance in cents

    // machine works on edge of clk or reset pulse
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            // reset all outputs
            state <= IDLE;
            balance <= 0;
            P_35_out <= 0;
            P_50_out <= 0;
            C_5_out <= 0;
            C_10_out <= 0;
            C_25_out <= 0;
        end else begin
            // machine is active
            // default outputs to 0 (pulse system)
            P_35_out <= 0;
            P_50_out <= 0;
            C_5_out <= 0;
            C_10_out <= 0;
            C_25_out <= 0;
            
            if(cancel) begin
                state <= RETURN;
            end
            // manage different states
            case (state)
                IDLE , INSUFFICIENT: begin
                    // add coins to balance if they are recognized by sensor
                    if (C_5) begin
                        balance <= balance + 5;
                        // user added a coin so wait until they request again, if machine was INSUFFICIENT it should become IDLE again.
                        state <= IDLE;
                    end
                    if (C_10) begin 
                        balance <= balance + 10;
                        state <= IDLE;
                    end
                    if (C_25) begin
                        balance <= balance + 25;
                        state <= IDLE;
                    end

                    if(P_35) begin
                        if(balance >= 35) begin
                            // buy and dispense the selected product if balance is enough
                            balance <= balance - 35;
                            state <= DISPENSE;
                            P_35_out <= 1;
                        end else begin
                            // user wanted a product but doesnt have enough balance
                            state <= INSUFFICIENT;
                        end
                    end

                    // same as the P_35
                    if(P_50) begin
                        if(balance >= 50) begin
                            balance <= balance - 50;
                            state <= DISPENSE;
                            P_50_out <= 1;
                        end else begin
                            state <= INSUFFICIENT;
                        end
                    end
                end

                DISPENSE : begin
                    // a product was dispensed rn
                    if(balance>0) begin
                        // check if theres a leftover and returns if left
                        state <= RETURN;
                    end else begin
                        // wait for another request
                        state <= IDLE;
                    end
                end

                RETURN : begin
                    // machine is returning coins, using bigger coins has proirity
                    if (balance >= 25) begin
                        // return the coin
                        C_25_out <= 1;
                        // remove the returned coin from the balance
                        balance <= balance - 25;
                    end else if (balance >= 10) begin
                        C_10_out <= 1;
                        balance <= balance - 10;
                    end else if (balance >= 5) begin
                        C_5_out <= 1;
                        balance <= balance - 5;
                    end else begin
                        // all the leftover is returned, machine goes back to IDLE
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // set different led on/off based on machine state
    assign idle_led = (state == IDLE);
    assign dispense_led = (state == DISPENSE);
    assign return_led = (state == RETURN);
    assign insufficient_led = (state == INSUFFICIENT);

    wire [3:0] tens_digit = balance / 10; // 0-9 (dahgan)
    wire [3:0] units_digit = balance % 10; // 0-9 (yekan)

    binary_to_segmented units_decoder (
        .binary(units_digit),
        .segments(balance_seg_1)
    );
    binary_to_segmented tens_decoder (
        .binary(tens_digit),
        .segments(balance_seg_2)
    );
endmodule