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
  string out;


  logic [WORD-1:0] operand1_i_queue [$];
  logic [WORD-1:0] operand2_i_queue [$];
  logic [WORD-1:0] result_o_queue [$];
  logic in_valid_i_queue [$];

  initial begin
    
    repeat (5) begin
      
      op_i = MUL;

      operand1_i_queue.push_back($random);
      operand2_i_queue.push_back(16384); // 1.0
      in_valid_i_queue.push_back(1'b1);

      #1;
    end

    #200;
    $finish;
  end


  always @(posedge clk_i) begin
    in_valid_i = in_valid_i_queue.pop_front();
  end 

  always @(posedge clk_i) begin
    if (in_valid_i) begin
      operand1_i = operand1_i_queue.pop_front();
      operand2_i = operand2_i_queue.pop_front();
      
      #1;
      $display("operand1_i: %h", operand1_i);
    end
  end

  // monitor output valid signal
  always @(posedge clk_i) begin
    if (out_valid_o) begin
      result_o_queue.push_back(result_o);
    end
  end
  
  // monitor queues and print captured data
  always @(posedge clk_i) begin
    if (result_o_queue.size() != 0) begin
      $display("Output %h", result_o_queue.pop_front());
    end
  end

  


/*
  initial begin: process1
    rst_i = 1;
    #12;
    @(posedge clk_i);
    rst_i = 0;

    for (int i=0; i<7; i++) begin
      op_i = operation_e'(i);
      
      $display("[%s]", op_i.name());
      $fwrite(f1, "[%s]\n", op_i.name());

      for (int j=0; j<5; ++j) begin

        in_valid_i = 1'b1;
        case (op_i)
          F2P: begin
            operand1_i = {longint'($random)}%((1 << 32));
          end
          P2F: begin
            operand2_i = {$random}%((1 << 16));
          end
          FMADD: begin
            operand1_i = {$random}%((1 << 16));
            operand2_i = {$random}%((1 << 16));
            operand3_i = 0;
          end
          ADD, SUB, MUL, DIV: begin
            operand1_i = {$random}%((1 << 16));
            operand2_i = {$random}%((1 << 16));
          end
          default: $error("default arm not allowed");
        endcase
    
        #1;
        $display("\"0x%h, 0x%h, 0x%h\" = \"0x%h\"", operand1_i, operand2_i, operand3_i, result_o);
        $fwrite(f1, "\"0x%h, 0x%h, 0x%h\" = \"0x%h\"\n", operand1_i, operand2_i, operand3_i, result_o);
        @(posedge clk_i);
      end

      in_valid_i = 1'b0;

    end

    #100;
    $finish;
  end: process1
*/


  
  
//   initial begin: sequences
    
//     op_i = SUB;
//     #34;
//     @(posedge clk_i);



// // `define TEST_FMA_ONLY
// `ifdef TEST_FMA_ONLY
// `ifdef FMA_OP
    
//     op_i = FMADD;
//     $display("FMADD");
//     for (int i=0; i<40; i++) begin
//       operand1_i = {$random}%(1 << 16); 
//       operand2_i = {$random}%(1 << 16);
//       operand3_i = 0;

//       #1;

//       fixed = ppu_top_inst.ppu_inst.ppu_core_ops_inst.fir_ops_inst.core_op_inst.core_fma_accumulator_inst.acc;    

//       $display("(0x%h, 0x%h, 0x%h, 0x%h)", 
//         ppu_top_inst.ppu_inst.p1, 
//         ppu_top_inst.ppu_inst.p2, 
//         fixed, 
//         ppu_top_inst.ppu_inst.posit
//       );
//       $fwrite(f1, "(0x%h, 0x%h, 0x%h, 0x%h)\n", 
//         ppu_top_inst.ppu_inst.p1,
//         ppu_top_inst.ppu_inst.p2,
//         fixed,
//         ppu_top_inst.ppu_inst.posit
//       );

//       @(posedge clk_i);
//     end
//     $display("");
// `endif

// `else


    
//     op_i = F2P;
    
//     if ((op_i == MUL) || (op_i == ADD)) begin

//       //$display("op_i: %s", op_i.name());
//       for (int i=0; i<30; i++) begin
//         operand1_i = {$random}%(1 << 16); 
//         operand2_i = {$random}%(1 << 16);
//         operand3_i = 'bX;

//         #1;

//         $display("(0x%h, 0x%h, 0x%h)", 
//           ppu_top_inst.ppu_inst.p1, 
//           ppu_top_inst.ppu_inst.p2, 
//           result_o
//         );
//         $fwrite(f1, "(0x%h, 0x%h, 0x%h)\n", 
//           ppu_top_inst.ppu_inst.p1,
//           ppu_top_inst.ppu_inst.p2,
//           result_o
//         );
//       end
//       @(posedge clk_i);
//     end

//     if (op_i == F2P) begin

//       //$display("op_i: %s", op_i.name());
//       for (int i=0; i<30; i++) begin
//         operand1_i = {$random}%(1 << 31); 
//         operand2_i = 'bX;
//         operand3_i = 'bX;

//         #1;

//         if (operand1_i == 'h24c6) begin
//           //force ppu_top_inst.ppu_inst.ppu_core_ops_inst.float_fir_i = 'b11; //'b0_11010_0011000110_00000000000000000000000000000000;
//         end

//         $display("(0x%h, 0x%h, 0x%h)", 
//           operand1_i,
//           ppu_top_inst.ppu_inst.p2, 
//           result_o
//         );
//         $fwrite(f1, "(0x%h, 0x%h, 0x%h)\n", 
//           operand1_i,
//           ppu_top_inst.ppu_inst.p2,
//           result_o
//         );
//         @(posedge clk_i);
//       end
//     end

// `endif

//     #100;
//     $finish;
//   end: sequences


endmodule: tb_ppu
