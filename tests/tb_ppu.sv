/// PPU test bench
module tb_ppu #(
  parameter CLK_FREQ = `CLK_FREQ
);

  import ppu_pkg::*;

  parameter WORD = `WORD;
  parameter N = `N;
  parameter ES = `ES;
  parameter FSIZE = `F;

  localparam ASCII_SIZE = 300;

  logic                                 clk_i;
  logic                                 rst_i;
  logic                                 in_valid_i;
  logic                   [WORD-1:0]    operand1_i;
  logic                   [WORD-1:0]    operand2_i;
  logic                   [WORD-1:0]    operand3_i;
  ppu_pkg::operation_e                  op_i;
  wire                  [WORD-1:0]      result_o;
  wire                                  out_valid_o;
  wire [`FX_B-1:0]                      fixed_o;


  integer test_no;
  integer count_errors;


  clk_gen #(
    .CLK_FREQ     (CLK_FREQ)
  ) clk_gen_i (
    .clk_o        (clk_i)
  );  


  ppu_top #(
    .WORD         (WORD),
    `ifdef FLOAT_TO_POSIT
      .FSIZE        (FSIZE),
    `endif
    .N            (N),
    .ES           (ES)
  ) ppu_top_inst (
    .clk_i        (clk_i),
    .rst_i        (rst_i),
    
    .in_valid_i   (in_valid_i),
    .operand1_i   (operand1_i),
    .operand2_i   (operand2_i),
    .operand3_i   (operand3_i),
    .op_i         (op_i),

    .result_o     (result_o),
    .out_valid_o  (out_valid_o),
    
    .fixed_o      (fixed_o)
  );

  
  initial begin
    $display("Posit format: P<%0d,%0d>", N, ES);
    if (FSIZE !== 0) begin
      $display("Float support: F<%0d>", FSIZE);
    end else begin
      $display("Float support: None. (F = 0)");
    end
    $display("WORD = %0d", WORD);
    $display("CLK_FREQ = %0d MHz", CLK_FREQ);
  end


  // `define STRINGIFY(DEFINE) $sformatf("%0s", `"DEFINE`")
  
  initial rst_i = 0;
  
  
  initial begin: vcd_file
    $dumpfile({"tb_ppu.vcd"});
    $dumpvars(0, tb_ppu);
  end




  logic [(`FX_B)-1:0] fixed;


  ////// log to file //////
  integer f1;
  initial f1 = $fopen("tb_ppu.log", "w");

  initial begin: sequences
    
    op_i = SUB;
    #34;
    @(posedge clk_i);



// `define TEST_FMA_ONLY
`ifdef TEST_FMA_ONLY
`ifdef FMA_OP
    


    op_i = FMADD;
    $display("FMADD");
    for (int i=0; i<40; i++) begin
      operand1_i = {$random}%(1 << 16); 
      operand2_i = {$random}%(1 << 16);
      operand3_i = 0;//{$random}%(1 << 16);

      #1;

      
      fixed = ppu_top_inst.ppu_inst.ppu_core_ops_inst.fir_ops_inst.core_op_inst.core_fma_accumulator_inst.acc;
    

      $display("(0x%h, 0x%h, 0x%h, 0x%h)", 
        ppu_top_inst.ppu_inst.p1, 
        ppu_top_inst.ppu_inst.p2, 
        fixed, 
        ppu_top_inst.ppu_inst.posit
      );
      $fwrite(f1, "(0x%h, 0x%h, 0x%h, 0x%h)\n", 
        ppu_top_inst.ppu_inst.p1,
        ppu_top_inst.ppu_inst.p2,
        fixed,
        ppu_top_inst.ppu_inst.posit
      );

      @(posedge clk_i);
    end
    $display("");
`endif

`else


    
    op_i = P2F;
    //$display("op_i: %s", op_i.name());
    for (int i=0; i<30; i++) begin
      operand1_i = {$random}%(1 << 16); 
      operand2_i = {$random}%(1 << 16);
      operand3_i = 'bX;

      #1;

      $display("(0x%h, 0x%h, 0x%h)", 
        ppu_top_inst.ppu_inst.p1, 
        ppu_top_inst.ppu_inst.p2, 
        result_o
      );
      $fwrite(f1, "(0x%h, 0x%h, 0x%h)\n", 
        ppu_top_inst.ppu_inst.p1,
        ppu_top_inst.ppu_inst.p2,
        result_o
      );

      @(posedge clk_i);
    end
    $display("");
`endif

    #100;
    $finish;
  end


endmodule: tb_ppu

