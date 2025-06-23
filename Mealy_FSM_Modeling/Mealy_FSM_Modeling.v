`timescale 1ns / 1ps

module Mealy_FSM_Modeling (
    input  clk,
    input  reset,
    input  din_bit,
    output dout_bit
);
    reg [2:0] state_reg, next_state;

    parameter start = 3'b000;
    parameter rd0_once = 3'b001;
    parameter rd1_once = 3'b010;
    parameter rd0_twice = 3'b011;
    parameter rd1_twice = 3'b100;

    always @(state_reg or din_bit) begin
        case (state_reg)
            start:
            if (din_bit == 0) next_state = rd0_once;
            else if (din_bit == 1) next_state = rd1_once;
            else next_state = start;

            rd0_once:
            if (din_bit == 0) next_state = rd0_twice;
            else if (din_bit == 1) next_state = rd1_once;
            else next_state = start;

            rd0_twice:
            if (din_bit == 0) next_state = rd0_twice;
            else if (din_bit == 1) next_state = rd1_once;
            else next_state = start;

            rd1_once:
            if (din_bit == 0) next_state = rd0_once;
            else if (din_bit == 1) next_state = rd1_twice;
            else next_state = start;

            rd1_twice:
            if (din_bit == 0) next_state = rd0_once;
            else if (din_bit == 1) next_state = rd1_twice;
            else next_state = start;
            
            default: next_state = start;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset == 1) state_reg <= start;
        else state_reg <= next_state;
    end

    // Mealy
     assign dout_bit = (((state_reg == rd0_twice) && (din_bit==0) || (state_reg==rd1_twice) && (din_bit==1))) ? 1 : 0;
    
    // Moore
    // assign dout_bit = ((state_reg == rd0_twice) || (state_reg==rd1_twice)) ? 1 : 0;
endmodule



//////////////////////////////////////////////////////////////////////////////////

// module Mealy_FSM_Modeling (
//     input  clk,
//     input  reset,
//     input  din_bit,
//     output dout_bit
// );
//     reg [2:0] state_reg, next_state;

//     parameter A = 3'b000;
//     parameter B = 3'b001;
//     parameter C = 3'b011;
//     parameter D = 3'b100;

//     always @(state_reg or din_bit) begin
//         case (state_reg)
//             A:
//             if (din_bit == 0) next_state = A;
//             else if (din_bit == 1) next_state = B;
//             else next_state = A;
//             B:
//             if (din_bit == 0) next_state = C;
//             else if (din_bit == 1) next_state = B;
//             else next_state = A;
//             C:
//             if (din_bit == 0) next_state = A;
//             else if (din_bit == 1) next_state = D;
//             else next_state = A;
//             D:
//             if (din_bit == 0) next_state = A;
//             else if (din_bit == 1) next_state = B;
//             else next_state = A;
//             default: next_state = A;
//         endcase
//     end

//     always @(posedge clk or posedge reset) begin
//         if (reset == 1) state_reg <= A;
//         else state_reg <= next_state;
//     end

//     // Mealy
//      assign dout_bit = ((state_reg == D) && (din_bit==0) ) ? 1 : 0;
    
//     // Moore
//     // assign dout_bit = ((state_reg == rd0_twice) || (state_reg==rd1_twice)) ? 1 : 0;
// endmodule