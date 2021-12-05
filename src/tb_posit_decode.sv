if (N == 8 && ES == 0) begin
    bits = 8'b10010010;
    //bits                 = 8'b11101110;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001110;
    #10;

    bits = 8'b00001000;
    //bits                 = 8'b00001000;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits = 8'b01101101;
    //bits                 = 8'b01101101;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001101;
    #10;

    bits = 8'b01111011;
    //bits                 = 8'b01111011;
    regime_bits_expected = 8'b00011110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b10010011;
    //bits                 = 8'b11101101;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001101;
    #10;

    bits = 8'b00000011;
    //bits                 = 8'b00000011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits = 8'b00110100;
    //bits                 = 8'b00110100;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010100;
    #10;

    bits = 8'b01110110;
    //bits                 = 8'b01110110;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000110;
    #10;

    bits = 8'b11010000;
    //bits                 = 8'b10110000;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010000;
    #10;

    bits = 8'b01111101;
    //bits                 = 8'b01111101;
    regime_bits_expected = 8'b00111110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits = 8'b11010010;
    //bits                 = 8'b10101110;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001110;
    #10;

    bits = 8'b01000111;
    //bits                 = 8'b01000111;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000111;
    #10;

    bits = 8'b10100111;
    //bits                 = 8'b11011001;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011001;
    #10;

    bits = 8'b11001111;
    //bits                 = 8'b10110001;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010001;
    #10;

    bits = 8'b00101001;
    //bits                 = 8'b00101001;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001001;
    #10;

    bits = 8'b11111101;
    //bits                 = 8'b10000011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits = 8'b10000101;
    //bits                 = 8'b11111011;
    regime_bits_expected = 8'b00011110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b11110101;
    //bits                 = 8'b10001011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b01010011;
    //bits                 = 8'b01010011;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010011;
    #10;

    bits = 8'b00010011;
    //bits                 = 8'b00010011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b00111111;
    //bits                 = 8'b00111111;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011111;
    #10;

    bits = 8'b10111110;
    //bits                 = 8'b11000010;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000010;
    #10;

    bits = 8'b01011100;
    //bits                 = 8'b01011100;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011100;
    #10;

    bits = 8'b00001011;
    //bits                 = 8'b00001011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b01101011;
    //bits                 = 8'b01101011;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001011;
    #10;

    bits = 8'b11011100;
    //bits                 = 8'b10100100;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits = 8'b00100011;
    //bits                 = 8'b00100011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b10011010;
    //bits                 = 8'b11100110;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000110;
    #10;

    bits = 8'b01011010;
    //bits                 = 8'b01011010;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011010;
    #10;

    bits = 8'b01100001;
    //bits                 = 8'b01100001;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits = 8'b11100110;
    //bits                 = 8'b10011010;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001010;
    #10;

    bits = 8'b01001000;
    //bits                 = 8'b01001000;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001000;
    #10;

    bits = 8'b11010011;
    //bits                 = 8'b10101101;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001101;
    #10;

    bits = 8'b10101100;
    //bits                 = 8'b11010100;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010100;
    #10;

    bits = 8'b01000011;
    //bits                 = 8'b01000011;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b01110100;
    //bits                 = 8'b01110100;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits = 8'b00101100;
    //bits                 = 8'b00101100;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001100;
    #10;

    bits = 8'b10101111;
    //bits                 = 8'b11010001;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010001;
    #10;

    bits = 8'b01001101;
    //bits                 = 8'b01001101;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001101;
    #10;

    bits = 8'b10101001;
    //bits                 = 8'b11010111;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010111;
    #10;

    bits = 8'b11101000;
    //bits                 = 8'b10011000;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001000;
    #10;

    bits = 8'b00100010;
    //bits                 = 8'b00100010;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000010;
    #10;

    bits = 8'b11011011;
    //bits                 = 8'b10100101;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000101;
    #10;

    bits = 8'b11000100;
    //bits                 = 8'b10111100;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011100;
    #10;

    bits = 8'b00111101;
    //bits                 = 8'b00111101;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011101;
    #10;

    bits = 8'b01110000;
    //bits                 = 8'b01110000;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits = 8'b10011101;
    //bits                 = 8'b11100011;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b01100000;
    //bits                 = 8'b01100000;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits = 8'b11100111;
    //bits                 = 8'b10011001;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001001;
    #10;

    bits = 8'b10010101;
    //bits                 = 8'b11101011;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001011;
    #10;

    bits = 8'b00000001;
    //bits                 = 8'b00000001;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits = 8'b00111100;
    //bits                 = 8'b00111100;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011100;
    #10;

    bits = 8'b11010101;
    //bits                 = 8'b10101011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001011;
    #10;

    bits = 8'b00110001;
    //bits                 = 8'b00110001;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010001;
    #10;

    bits = 8'b11011000;
    //bits                 = 8'b10101000;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001000;
    #10;

    bits = 8'b10001001;
    //bits                 = 8'b11110111;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000111;
    #10;

    bits = 8'b01011101;
    //bits                 = 8'b01011101;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011101;
    #10;

    bits = 8'b11000101;
    //bits                 = 8'b10111011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011011;
    #10;

    bits = 8'b11110100;
    //bits                 = 8'b10001100;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits = 8'b01010000;
    //bits                 = 8'b01010000;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010000;
    #10;

    bits = 8'b10101010;
    //bits                 = 8'b11010110;
    regime_bits_expected = 8'b00000010;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010110;
    #10;

    bits = 8'b10001100;
    //bits                 = 8'b11110100;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits = 8'b01110011;
    //bits                 = 8'b01110011;
    regime_bits_expected = 8'b00001110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000011;
    #10;

    bits = 8'b01101111;
    //bits                 = 8'b01101111;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001111;
    #10;

    bits = 8'b01111000;
    //bits                 = 8'b01111000;
    regime_bits_expected = 8'b00011110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits = 8'b00010000;
    //bits                 = 8'b00010000;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits = 8'b11110010;
    //bits                 = 8'b10001110;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000110;
    #10;

    bits = 8'b11001101;
    //bits                 = 8'b10110011;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00010011;
    #10;

    bits = 8'b11101100;
    //bits                 = 8'b10010100;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000100;
    #10;

    bits = 8'b00101000;
    //bits                 = 8'b00101000;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001000;
    #10;

    bits = 8'b00111001;
    //bits                 = 8'b00111001;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011001;
    #10;

    bits = 8'b01101001;
    //bits                 = 8'b01101001;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00001001;
    #10;

    bits = 8'b11011110;
    //bits                 = 8'b10100010;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000010;
    #10;

    bits = 8'b00001001;
    //bits                 = 8'b00001001;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits = 8'b11101111;
    //bits                 = 8'b10010001;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000001;
    #10;

    bits = 8'b01111111;
    //bits                 = 8'b01111111;
    regime_bits_expected = 8'b01111111;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000000;
    #10;

    bits = 8'b11001000;
    //bits                 = 8'b10111000;
    regime_bits_expected = 8'b00000001;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00011000;
    #10;

    bits = 8'b10011011;
    //bits                 = 8'b11100101;
    regime_bits_expected = 8'b00000110;
    exp_expected         = 8'b00000000;
    mant_expected        = 8'b00000101;
    #10;

    bits = 8'b10101000;
    //bits                 = 8'b11011000;
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