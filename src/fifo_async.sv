`resetall
`timescale 1ns / 1ps
`default_nettype none

module fifo_async #(
    parameter WIDTH = 8,
    parameter DEPTH_LOG2 = 10
)(
    // Write side
    input wire  w_clk,      // write clock
    input wire  w_rst,      // write reset
    input wire  write ,
    input wire [WIDTH-1:0] w_data ,

    output logic    w_full ,

    // Read side
    input wire  r_clk , // read clock
    input wire  r_rst , // read reset
    input wire  read ,
    output logic [WIDTH-1:0] r_data ,
    output logic r_empty
);

// Your code
localparam max_size = 2**DEPTH_LOG2;

logic [WIDTH-1:0]           mem[max_size];

logic [DEPTH_LOG2-1:0]      w_addr_next;
logic [DEPTH_LOG2-1:0]      w_addr;
logic [DEPTH_LOG2-1:0]      w_addr_r1;
logic [DEPTH_LOG2-1:0]      w_addr_r2;
logic [DEPTH_LOG2-1:0]      r_addr;
logic [DEPTH_LOG2-1:0]      r_addr_w1;
logic [DEPTH_LOG2-1:0]      r_addr_w2;

logic                       w_step;
logic                       r_step;


assign w_step = write & ~w_full;

gray_cnt 
#(
    .N              (  DEPTH_LOG2  ),
    .first_bit      (   1          )
)  
w_gray_cnt
( 
    .clk        (   w_clk   ),  
    .rstp       (   w_rst   ),  
    .en         (   w_step  ),
    .out        (   w_addr_next  )
);

always @(posedge w_clk) begin
    if( w_rst )
        w_addr <= #1 '0;
    else if( w_step )
        w_addr <= #1 w_addr_next;
    
    r_addr_w1 <= #1 r_addr;
    r_addr_w2 <= #1 r_addr_w1;
    
end

always @(posedge r_clk) begin
    
    w_addr_r1 <= #1 w_addr;
    w_addr_r2 <= #1 w_addr_r1;

end

assign w_full  = (w_addr_next==r_addr_w2) ? 1 : 0;
assign r_empty = (w_addr_r2==r_addr) ? 1 : 0;

gray_cnt 
#(
    .N              (  DEPTH_LOG2  ),
    .first_bit      (   0          )
)  
r_gray_cnt
( 
    .clk        (   r_clk   ),  
    .rstp       (   r_rst   ),  
    .en         (   r_step  ),
    .out        (   r_addr  )
);

always @(posedge w_clk)
    if( w_step )
        mem[w_addr] <= #1 w_data;

assign r_data = mem[r_addr];

assign r_step = read & ~r_empty;




endmodule

`resetall