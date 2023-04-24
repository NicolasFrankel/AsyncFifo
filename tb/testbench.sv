// Code your testbench here
// or browse Examples


module tb
  ();
  
  int       test_id=0;
  
  string	test_name[3:0]=
  {
   "randomize", 
   "low_write_high_read", 
   "high_write_low_read", 
   "direct_base" 
  };
  
localparam  WIDTH = 16;

initial begin
  $dumpfile("dump.vcd");
  $dumpvars(1);
end


task test_finish;
  		input int 	test_id;
  		input string	test_name;
  		input int		result;
begin

    automatic int fd = $fopen( "global.txt", "a" );

    $display("");
    $display("");

    if( 1==result ) begin
        $fdisplay( fd, "test_id=%-5d test_name: %25s         TEST_PASSED", 
        test_id, test_name );
        $display(      "test_id=%-5d test_name: %25s         TEST_PASSED", 
        test_id, test_name );
    end else begin
        $fdisplay( fd, "test_id=%-5d test_name: %25s         TEST_FAILED *******", 
        test_id, test_name );
        $display(      "test_id=%-5d test_name: %25s         TEST_FAILED *******", 
        test_id, test_name );
    end

    $fclose( fd );

    $display("");
    $display("");

    $finish();
end endtask  
  
/////////////////////////////////////////////////////////////////


logic                   w_clk=0;
logic                   w_rst;
logic                   write=0;
logic [WIDTH-1:0]       w_data;

logic                   w_full;

// Read side    
logic                   r_clk=0;
logic                   r_rst;
logic                   read=0;
logic  [WIDTH-1:0]      r_data;
logic                   r_empty;

logic                   reset_p;

int                     cnt_wr=0;
int                     cnt_rd=0;
int                     cnt_ok=0;  
int                     cnt_error=0;

int                     show_ok=0;
int                     show_error=0;

logic                   test_start=0;
logic                   test_timeout=0;
logic                   test_done=0;

int                     tick_current=0;

logic [15:0]            q_data [$];
int                     q_start_time[$];

logic [15:0]             expect_data;

localparam  MAX_TRANSACTION = 10000;

int                     delay[MAX_TRANSACTION];
int                     delay_min;
int                     delay_max;
real                    delay_avr;
real                    velocity;

real                    cv_all;

int                     write_done=0;

always #5 w_clk = ~w_clk;

always #7 r_clk = ~r_clk;

always @(posedge w_clk) w_rst <= #1 reset_p;

always @(posedge r_clk) r_rst <= #1 reset_p;


fifo_async 
#(
    .WIDTH          (  16 ),
    .DEPTH_LOG2     (  8  )

) uut(

    // Write side
    .w_clk,      // write clock
    .w_rst,      // write reset
    .write ,
    .w_data ,

    .w_full ,

    // Read side
    .r_clk , // read clock
    .r_rst , // read reset
    .read ,
    .r_data ,
    .r_empty
);


// // Insert the component bind_fifo_w8 into the component fifo_w8 for simulation purpose
// bind fifo_256   bind_fifo_256  dut(.*); 

//always @(posedge clk ) cv_all = $get_coverage();


initial begin
    #40000000;
    $display( "Timeout");
    test_timeout = '1;
end


// Main process  
initial begin  

    automatic int args=-1;
    automatic int current_delay;
    automatic int cnt;

   
    if( $value$plusargs( "test_id=%0d", args )) begin
        if( args>=0 && args<4 )
        test_id = args;

        $display( "args=%d  test_id=%d", args, test_id );

    end

    $display("chip-expo-2021-template-4-fifo  test_id=%d  name: %s", test_id, test_name[test_id] );
    
    reset_p <= #1 '1;

    #100;

    reset_p <= #1 '0;

    repeat (100) @(posedge w_clk );

    test_start <= #1 '1;

    @(posedge w_clk iff test_done=='1 || test_timeout=='1);

    if( test_timeout )
        cnt_error++;

    $display( "cnt_wr: %d", cnt_wr );
    $display( "cnt_rd: %d", cnt_rd );
    $display( "cnt_ok: %d", cnt_ok );
    $display( "cnt_error: %d", cnt_error );

    current_delay = delay[0];
    delay_min = current_delay;
    delay_max = current_delay;
    delay_avr = current_delay;

    cnt = cnt_rd;
    if( cnt>MAX_TRANSACTION )
        cnt = MAX_TRANSACTION;

    for( int ii=1; ii<cnt; ii++ ) begin
        current_delay = delay[ii];

        if( current_delay < delay_min )
            delay_min = current_delay;

        if( current_delay > delay_max )
            delay_max = current_delay;

        delay_avr += current_delay;
    end

    delay_avr /= cnt;

    velocity = 1.0 * cnt_rd / tick_current;

    $display("");
    $display("");

    $display("Statistics -  min_delay: %-4d max_delay: %-4d  avr_delay: %-6.3f  velocity: %f Tr/clock",
        delay_min, delay_max, delay_avr, velocity
    );

    // $display("overall coverage = %0f", $get_coverage());
    // $display("coverage of covergroup cg = %0f", uut.dut.cg.get_coverage());
    // $display("coverage of covergroup cg.data_we  = %0f", uut.dut.cg.data_we.get_coverage());
    // $display("coverage of covergroup cg.full     = %0f", uut.dut.cg.full.get_coverage());
    // $display("coverage of covergroup cg.data_rd  = %0f", uut.dut.cg.data_rd.get_coverage());
    // $display("coverage of covergroup cg.empty    = %0f", uut.dut.cg.empty.get_coverage());
    // $display("coverage of covergroup cg.cnt_wr   = %0f", uut.dut.cg.cnt_wr.get_coverage());
    // $display("coverage of covergroup cg.cnt_rd   = %0f", uut.dut.cg.cnt_rd.get_coverage());    

    if( 0==cnt_error && cnt_ok>0 )
        test_finish( test_id, test_name[test_id], 1 );  // test passed
    else
        test_finish( test_id, test_name[test_id], 0 );  // test failed



end
  

always @(posedge w_clk)  if( test_start ) tick_current <= #1 tick_current+1;

// Generate test sequence 
initial begin

  @(posedge w_clk iff test_start=='1);

  case( test_id )
  0: begin
          fork
            test_seq0_write();
            test_seq0_read();
          join
  end
  1: begin
          fork
            test_seq1_write();
            test_seq1_read();
          join
  end

  2: begin
          fork
            test_seq2_write();
            test_seq2_read();
          join
  end

  3: begin
           fork 
            test_seq3_write();
            test_seq3_read();
           join
 end

  endcase

    read_tail();

  #500;

  test_done=1;

end 

task sync_write;
    input int cnt;

    @(posedge w_clk iff tick_current==cnt);

endtask

task sync_read;
    input int sync_tick;

    @(posedge w_clk iff tick_current==sync_tick);
    @(posedge r_clk);

endtask

task write_data;
        input logic [15:0]     data;
        input int              next_delay;

        automatic int pkg_cnt;

        w_data <= #1 data;
        write  <= #1 '1;

        q_data.push_back( data );
        q_start_time.push_back( tick_current );

        @(posedge w_clk iff ~w_full);
        if( next_delay>0 ) begin
            w_data <= #1 '0;
            write <= #1 '0;

            repeat(next_delay) @(posedge w_clk);
        end
        cnt_wr++;
endtask

task read_data;
        input int   next_delay;
        read <= #1 '1;
        @(posedge r_clk iff read & ~r_empty);

        expect_data = q_data.pop_front();

        if( expect_data==r_data ) begin
            cnt_ok++;
            if( cnt_ok<16 ) begin
                    $display("cnt_ok: %-4d  cnt_error: %-4d  expect: %h  read: %h - OK",
                        cnt_ok, cnt_error, expect_data, r_data 
                    );
            end
        end else begin
            cnt_error++;
            if( cnt_error<16 ) begin
                    $display("cnt_ok: %-4d  cnt_error: %-4d  expect: %h  read: %h - ERROR",
                        cnt_ok, cnt_error, expect_data, r_data 
                    );
            end

        end


        if( cnt_rd < MAX_TRANSACTION )
            delay[cnt_rd] = tick_current - q_start_time.pop_front();
        
        if( next_delay>0 ) begin
            read <= #1 '0;
            repeat(next_delay) @(posedge r_clk);
        end        
        cnt_rd++;
endtask

task test_seq0_write;

automatic logic [15:0]     v;


        for( int ii=0; ii<16; ii++) begin
            v = 16'h0800 + ii;
            write_data( v, 0 );
        end

        write_data( 16'hA010, 1 );

        sync_write( 'h80 );



        v = 16'h0900;
        write_data( v, 2 );
        v = 16'h0A00;
        write_data( v, 2 );

        sync_write( 'hA0 );

        for( int ii=0; ii<255; ii++ ) begin
            v = 16'h0B00 + ii;
            write_data( v, 2 );
        end

endtask;



task test_seq0_read;


        for( int ii=0; ii<18; ii++ )
            read_data( 0 );
        read_data( 1 );

        sync_read( 'h600 );

        for( int ii=0; ii<254; ii++ )
            read_data( 0 );
        read_data( 1 );
        
endtask;

task read_tail();

    automatic int cnt = cnt_wr - cnt_rd;
    for( int ii=0; ii<cnt; ii++ )
        read_data( 1 );

endtask;



task test_seq1_write;

automatic logic [15:0]      v;
automatic int               delay;


        for( int ii=0; ii<1000; ii++) begin

            delay = $urandom_range( 0, 5 );

            v = $urandom_range( 0, 65535 );
            write_data( v, delay );
        end

        write_data( 16'hA010, 1 );

        write_done=1;

endtask;



task test_seq1_read;

automatic int               delay;

        while( 0==write_done ) begin
            delay = $urandom_range( 5, 25 );
            read_data( delay );
        end

        read_data( 1 );

        
endtask;



task test_seq2_write;

automatic logic [15:0]      v;
automatic int               delay;


        for( int ii=0; ii<2000; ii++) begin

            delay = $urandom_range( 5, 15 );

            v = $urandom_range( 0, 65535 );
            
            write_data( v, delay );
        end

        write_data( 16'hA010, 1 );

        write_done=1;

endtask;



task test_seq2_read;

automatic int               delay;

        for( int ii=0; ii<2000; ii++) begin
            delay = $urandom_range( 0, 5 );
            read_data( delay );
        end

        read_data( 1 );

        
endtask;



task test_seq3_write;

automatic logic [15:0]      v;
automatic int               delay;


        for( int ii=0; ii<10000; ii++) begin

            delay = $urandom_range( 0, 5 );
           
            v = $urandom_range( 0, 65535 );
            
            write_data( v, delay );
        end

        write_data( 16'hA010, 1 );

        write_done=1;

endtask;



task test_seq3_read;

automatic int               delay;

        for( int ii=0; ii<10000; ii++) begin
            delay = $urandom_range( 0, 5 );
            read_data( delay );
        end

        read_data( 1 );

        
endtask;


endmodule