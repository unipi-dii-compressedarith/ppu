if (N == 8 && ES == 0) begin
    bits                 = 8'b10010010;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001110;
    #10;

    bits                 = 8'b00001000;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits                 = 8'b01101101;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001101;
    #10;

    bits                 = 8'b01111011;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 5;
    regime_bits_expected = 8'b00011110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b10010011;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001101;
    #10;

    bits                 = 8'b00000011;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 6;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits                 = 8'b00110100;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010100;
    #10;

    bits                 = 8'b01110110;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000110;
    #10;

    bits                 = 8'b11010000;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010000;
    #10;

    bits                 = 8'b01111101;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 6;
    regime_bits_expected = 8'b00111110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits                 = 8'b11010010;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001110;
    #10;

    bits                 = 8'b01000111;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000111;
    #10;

    bits                 = 8'b10100111;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011001;
    #10;

    bits                 = 8'b11001111;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010001;
    #10;

    bits                 = 8'b00101001;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001001;
    #10;

    bits                 = 8'b11111101;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 6;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits                 = 8'b10000101;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 5;
    regime_bits_expected = 8'b00011110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b11110101;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b01010011;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010011;
    #10;

    bits                 = 8'b00010011;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b00111111;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011111;
    #10;

    bits                 = 8'b10111110;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000010;
    #10;

    bits                 = 8'b01011100;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011100;
    #10;

    bits                 = 8'b00001011;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b01101011;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001011;
    #10;

    bits                 = 8'b11011100;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits                 = 8'b00100011;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b10011010;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000110;
    #10;

    bits                 = 8'b01011010;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011010;
    #10;

    bits                 = 8'b01100001;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits                 = 8'b11100110;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001010;
    #10;

    bits                 = 8'b01001000;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001000;
    #10;

    bits                 = 8'b11010011;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001101;
    #10;

    bits                 = 8'b10101100;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010100;
    #10;

    bits                 = 8'b01000011;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b01110100;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits                 = 8'b00101100;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001100;
    #10;

    bits                 = 8'b10101111;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010001;
    #10;

    bits                 = 8'b01001101;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001101;
    #10;

    bits                 = 8'b10101001;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010111;
    #10;

    bits                 = 8'b11101000;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001000;
    #10;

    bits                 = 8'b00100010;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000010;
    #10;

    bits                 = 8'b11011011;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000101;
    #10;

    bits                 = 8'b11000100;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011100;
    #10;

    bits                 = 8'b00111101;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011101;
    #10;

    bits                 = 8'b01110000;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits                 = 8'b10011101;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b01100000;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits                 = 8'b11100111;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001001;
    #10;

    bits                 = 8'b10010101;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001011;
    #10;

    bits                 = 8'b00000001;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 7;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits                 = 8'b00111100;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011100;
    #10;

    bits                 = 8'b11010101;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001011;
    #10;

    bits                 = 8'b00110001;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010001;
    #10;

    bits                 = 8'b11011000;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001000;
    #10;

    bits                 = 8'b10001001;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000111;
    #10;

    bits                 = 8'b01011101;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011101;
    #10;

    bits                 = 8'b11000101;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011011;
    #10;

    bits                 = 8'b11110100;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits                 = 8'b01010000;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010000;
    #10;

    bits                 = 8'b10101010;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010110;
    #10;

    bits                 = 8'b10001100;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits                 = 8'b01110011;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits                 = 8'b01101111;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001111;
    #10;

    bits                 = 8'b01111000;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 5;
    regime_bits_expected = 8'b00011110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits                 = 8'b00010000;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits                 = 8'b11110010;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000110;
    #10;

    bits                 = 8'b11001101;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010011;
    #10;

    bits                 = 8'b11101100;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits                 = 8'b00101000;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001000;
    #10;

    bits                 = 8'b00111001;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011001;
    #10;

    bits                 = 8'b01101001;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001001;
    #10;

    bits                 = 8'b11011110;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000010;
    #10;

    bits                 = 8'b00001001;
    sign_expected = 0;
    reg_s_expected = 0;
    reg_len_expected = 4;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits                 = 8'b11101111;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits                 = 8'b01111111;
    sign_expected = 0;
    reg_s_expected = 1;
    reg_len_expected = 7;
    regime_bits_expected = 8'b01111111;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits                 = 8'b11001000;
    sign_expected = 1;
    reg_s_expected = 0;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011000;
    #10;

    bits                 = 8'b10011011;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 3;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000101;
    #10;

    bits                 = 8'b10101000;
    sign_expected = 1;
    reg_s_expected = 1;
    reg_len_expected = 2;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011000;
    #10;


end

if (N == 5 && ES == 1) begin
    
    bits = 5'b10010;
    //bits                 = 5'b11110;
    regime_bits_expected = 5'b01110;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b00001;
    //bits                 = 5'b00001;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b01101;
    //bits                 = 5'b01101;
    regime_bits_expected = 5'b00110;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b01111;
    //bits                 = 5'b01111;
    regime_bits_expected = 5'b01111;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b11110;
    //bits                 = 5'b10010;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b00110;
    //bits                 = 5'b00110;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b01110;
    //bits                 = 5'b01110;
    regime_bits_expected = 5'b01110;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b11011;
    //bits                 = 5'b10101;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00001;
    #10;

    bits = 5'b01000;
    //bits                 = 5'b01000;
    regime_bits_expected = 5'b00010;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b10100;
    //bits                 = 5'b11100;
    regime_bits_expected = 5'b00110;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b00101;
    //bits                 = 5'b00101;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00001;
    #10;

    bits = 5'b11101;
    //bits                 = 5'b10011;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b10110;
    //bits                 = 5'b11010;
    regime_bits_expected = 5'b00010;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b01010;
    //bits                 = 5'b01010;
    regime_bits_expected = 5'b00010;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b11010;
    //bits                 = 5'b10110;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b00011;
    //bits                 = 5'b00011;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b01011;
    //bits                 = 5'b01011;
    regime_bits_expected = 5'b00010;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00001;
    #10;

    bits = 5'b10011;
    //bits                 = 5'b11101;
    regime_bits_expected = 5'b00110;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b11001;
    //bits                 = 5'b10111;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00001;
    #10;

    bits = 5'b11000;
    //bits                 = 5'b11000;
    regime_bits_expected = 5'b00010;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b00010;
    //bits                 = 5'b00010;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b01100;
    //bits                 = 5'b01100;
    regime_bits_expected = 5'b00110;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b11100;
    //bits                 = 5'b10100;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b01001;
    //bits                 = 5'b01001;
    regime_bits_expected = 5'b00010;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00001;
    #10;

    bits = 5'b10101;
    //bits                 = 5'b11011;
    regime_bits_expected = 5'b00010;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00001;
    #10;

    bits = 5'b00100;
    //bits                 = 5'b00100;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b10111;
    //bits                 = 5'b11001;
    regime_bits_expected = 5'b00010;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00001;
    #10;

    bits = 5'b10001;
    //bits                 = 5'b11111;
    regime_bits_expected = 5'b01111;
    exp_expected         = 5'b00000;
    mant_expected        = 5'b00000;
    #10;

    bits = 5'b00111;
    //bits                 = 5'b00111;
    regime_bits_expected = 5'b00001;
    exp_expected         = 5'b00001;
    mant_expected        = 5'b00001;
    #10;



end