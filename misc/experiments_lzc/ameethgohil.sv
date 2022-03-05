/*

[5] https://github.com/ameetgohil/leading-zeroes-counter/blob/36c5e0608a48b43a3533d3d0f5a9efc70eba163b/rtl/lzc.sv
*/


module lzc #(parameter WIDTH=WIDTH)
  (input wire[WIDTH-1:0] i_data,
   output wire [$clog2(WIDTH):0] lzc_cnt
   );

   wire       allzeroes;

   function bit f(bit[WIDTH-1:0] x, int size);
      bit                        jval = 0;
      bit                        ival = 0;

      for(int i = 1; i < size; i+=2) begin
         jval = 1;
         for(int j = i+1; j < size; j+=2) begin
            jval &= ~x[j];
         end
         ival |= jval & x[i];
      end

      return ival;

   endfunction // f

   function bit[WIDTH-1:0] f_input(bit[WIDTH-1:0] x, int stage );
      bit[WIDTH-1:0] dout = 0;
      int            stagePow2 = 2**stage;
      int            j=0;
      for(int i=0; i<WIDTH; i++) begin
         dout[j] |= x[i];
         if(i % stagePow2 == stagePow2 - 1)
           j++;
      end
      return dout;
   endfunction

   genvar i;

   assign allzeroes = ~(|i_data);

   assign lzc_cnt[$clog2(WIDTH)] = allzeroes;

   generate
      for(i=0; i < $clog2(WIDTH); i++) begin
         assign lzc_cnt[i] = ~allzeroes & ~f(f_input(i_data, i),WIDTH);
      end
   endgenerate

endmodule



`ifdef TB
module tb_ameetgohil;
    
   parameter N = 32;
   reg [N-1:0] in_i;
   reg val;
   wire [$clog2(N):0] lz;
   wire q;

   reg [$clog2(N):0] lz_expected;
   reg all_zeroes_expected;

   lzc #(
      .WIDTH(N)
   ) lzc_inst (
      .i_data(in_i),
      .lzc_cnt(lz)
   );

   reg diff;
   always_comb begin
      diff = (in_i != 0 && lz == lz_expected) ? 0 : 'bx;
   end

   initial begin
      $dumpfile("tb_ameetgohil.vcd");
      $dumpvars(0, tb_ameetgohil);

      `include "tv_lzc.sv"


      #10;
      $finish;
   end




endmodule
`endif
