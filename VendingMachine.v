module vendingMachine (
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
    output reg [6:0] balance_seg_1, // balance segment 1
    output reg [6:0] balance_seg_2, // balance segment 2
    output reg idle_led, // idle light
    output reg dispense_led, // dispensing product light
    output reg return_led, // returning coins light
    output reg insufficient_led // insufficient balance light
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
            current_state <= IDLE;
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

            // manage different states
            case (state)
                IDLE || INSUFFICIENT: begin
                    // add coins to balance if they are recognized by sensor
                    if (C_5) balance <= balance + 5;
                    if (C_10) balance <= balance + 10;
                    if (C_25) balance <= balance + 25;

                    if(P_35) begin
                        if(balance >= 35) begin
                            // buy and dispense the selected product if balance is enough
                            balance <= balance - 35;
                            state <= DISPENSE;
                            p_35_out <= 1;
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
                            p_50_out <= 1;
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
                        C_25_out <= 1;
                        balance <= balance - 25;
                    end else if (balance >= 10) begin
                        C_10_out <= 1;
                        balance <= balance - 10;
                    end else if (balance >= 5) begin
                        C_5_out <= 1;
                        balance <= balance - 5;
                    end else begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule