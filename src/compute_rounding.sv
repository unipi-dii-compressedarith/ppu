module compute_rouding #(
        parameter N = `N,
        parameter ES = `ES
    )(
        input [MANT_LEN_SIZE-1:0] mant_len,
        input [(3*MANT_SIZE+2)-1:0] mant_up_shifted,
        input [(S+2)-1:0] mant_len_diff,
        input [K_SIZE-1:0] k,
        input [ES-1:0] exp,
        output round_bit,
        output sticky_bit
    );
    
    wire [(3*MANT_SIZE+2)-1:0] _tmp0, _tmp1, _tmp2, _tmp3;
    
    assign _tmp0 = (1 << (mant_len_diff - 1));
    assign _tmp1 = mant_up_shifted & _tmp0;

    assign round_bit = $signed(mant_len) >= 0 ?
        _tmp1 != 0 :
        (
            $signed(k) == N - 2 - ES ? 
                exp > 0 && $signed(mant_up_shifted) > 0 :
                $signed(k) == -(N - 2) ? 
                    $signed(exp) > 0 : 
                    1'b0
        );


    
    assign _tmp2 = ((1 << (mant_len_diff - 1)) - 1);
    assign _tmp3 = mant_up_shifted & _tmp2;

    assign sticky_bit = $signed(mant_len) >= 0 ? _tmp3 != 0 : 1'b0;

endmodule
