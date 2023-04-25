
`timescale 1ns / 1ps
`default_nettype none

module gray_cnt 
#(
    parameter           N = 4,
    parameter logic     first_bit = 0
)  
( 
    input wire          clk,  
    input wire          rstp,  
    input wire          en,
    output reg [N-1:0] out
);  
  
    logic [N-1:0] q;  
    logic [N-1:0] n_q;  
    logic [N-1:0] n_out;  
  
    // always @ (posedge clk) begin  
    //     if( rstp ) begin  
    //         q[0]        <= #1 first_bit;  
    //         q[N-1:1]    <= #1 '0;  
    //     end else if( en ) begin  
    //         q <= #1 q + 1;  
    //     end  
    // end  

    // assign out = {q[N-1], q[N-1:1] ^ q[N-2:0]};  

    always_comb begin
        
        n_q = q + 1;
        n_out = {n_q[N-1], n_q[N-1:1] ^ n_q[N-2:0]};
    end

    always @ (posedge clk) begin  
        if( rstp ) begin  
            q[0]        <= #1 first_bit;  
            q[N-1:1]    <= #1 '0;  
            out[0]      <= #1 first_bit;  
            out[N-1:1]  <= #1 '0;  
        end else if( en ) begin  
            q <= #1 n_q;
            out <= #1 n_out;  
        end  
    end  

    

endmodule  
