`timescale 1ns / 1ps

module stopwatch_cu(
    input clk,
    input rst,
    input i_clear,
    input i_runstop,
    output o_clear,
    output o_runstop
);

    parameter  STOP = 0 , RUN= 1, CLEAR= 2;

    reg [1:0] c_state, n_state;

    //reg clear_reg, clear_next;
    //reg runstop_reg, runstop_next;
    //assign o_clear = clear_reg;
    //assign o_runstop = runstop_reg;

    assign o_clear = (c_state == CLEAR) ? 1:0;
    assign o_runstop = (c_state == RUN) ? 1:0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= 0;
            //  o_clear <= 0;
            //  o_runstop <= 0;
        end else begin
            c_state <= n_state;
        end
    end

    always @(*) begin
        n_state = c_state;
        case (c_state)
            STOP: begin
                if (i_runstop) begin
                    n_state = RUN;
                end else if (i_clear ==1) begin
                    n_state = CLEAR;
                end else n_state = c_state;
            end 

            RUN: begin
                if (i_runstop) begin
                    n_state = STOP;
                end 
            end 

            CLEAR: begin
                if (i_clear) begin
                    n_state = STOP;
                end 
            end 
        endcase
    end

endmodule
