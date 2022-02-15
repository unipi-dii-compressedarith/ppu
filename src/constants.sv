/*
Fixed point equivalent values of the rational numbers 
1.466, 1.0012, 2.0 expressed on a range of different bits.

to visualize what i mean try:

>>> import fixed2float as f2f
>>> a = f2f.Fx(3148211028, 1, 32) # e.g.: fp_1_466___N32
>>> print(a, a.eval())


This file exists because SV doesn't support proper conditional compilation.
*/


parameter fp_1_466___N5 = 5'd23;
parameter fp_1_466___N6 = 6'd47;
parameter fp_1_466___N7 = 7'd94;
parameter fp_1_466___N8 = 8'd188;
parameter fp_1_466___N9 = 9'd375;
parameter fp_1_466___N10 = 10'd751;
parameter fp_1_466___N11 = 11'd1501;
parameter fp_1_466___N12 = 12'd3002;
parameter fp_1_466___N13 = 13'd6005;
parameter fp_1_466___N14 = 14'd12009;
parameter fp_1_466___N15 = 15'd24019;
parameter fp_1_466___N16 = 16'd48038;
parameter fp_1_466___N17 = 17'd96076;
parameter fp_1_466___N18 = 18'd192152;
parameter fp_1_466___N19 = 19'd384303;
parameter fp_1_466___N20 = 20'd768606;
parameter fp_1_466___N21 = 21'd1537212;
parameter fp_1_466___N22 = 22'd3074425;
parameter fp_1_466___N23 = 23'd6148850;
parameter fp_1_466___N24 = 24'd12297699;
parameter fp_1_466___N25 = 25'd24595399;
parameter fp_1_466___N26 = 26'd49190797;
parameter fp_1_466___N27 = 27'd98381595;
parameter fp_1_466___N28 = 28'd196763189;
parameter fp_1_466___N29 = 29'd393526378;
parameter fp_1_466___N30 = 30'd787052757;
parameter fp_1_466___N31 = 31'd1574105514;
parameter fp_1_466___N32 = 32'd3148211028;
parameter fp_1_0012___N5 = 10'd513;
parameter fp_1_0012___N6 = 12'd2050;
parameter fp_1_0012___N7 = 14'd8202;
parameter fp_1_0012___N8 = 16'd32807;
parameter fp_1_0012___N9 = 18'd131229;
parameter fp_1_0012___N10 = 20'd524917;
parameter fp_1_0012___N11 = 22'd2099669;
parameter fp_1_0012___N12 = 24'd8398674;
parameter fp_1_0012___N13 = 26'd33594697;
parameter fp_1_0012___N14 = 28'd134378789;
parameter fp_1_0012___N15 = 30'd537515157;
parameter fp_1_0012___N16 = 32'd2150060628;
parameter fp_1_0012___N17 = 34'd8600242514;
parameter fp_1_0012___N18 = 36'd34400970054;
parameter fp_1_0012___N19 = 38'd137603880216;
parameter fp_1_0012___N20 = 40'd550415520865;
parameter fp_1_0012___N21 = 42'd2201662083459;
parameter fp_1_0012___N22 = 44'd8806648333835;
parameter fp_1_0012___N23 = 46'd35226593335339;
parameter fp_1_0012___N24 = 48'd140906373341354;
parameter fp_1_0012___N25 = 50'd563625493365418;
parameter fp_1_0012___N26 = 52'd2254501973461671;
parameter fp_1_0012___N27 = 54'd9018007893846683;
parameter fp_1_0012___N28 = 56'd36072031575386729;
parameter fp_1_0012___N29 = 58'd144288126301546913;
parameter fp_1_0012___N30 = 60'd577152505206187649;
parameter fp_1_0012___N31 = 62'd2308610020824750593;
parameter fp_1_0012___N32 = 64'd9234440083299002369;
parameter fp_2___N5 = 20'd524288;
parameter fp_2___N6 = 24'd8388608;
parameter fp_2___N7 = 28'd134217728;
parameter fp_2___N8 = 32'd2147483648;
parameter fp_2___N9 = 36'd34359738368;
parameter fp_2___N10 = 40'd549755813888;
parameter fp_2___N11 = 44'd8796093022208;
parameter fp_2___N12 = 48'd140737488355328;
parameter fp_2___N13 = 52'd2251799813685248;
parameter fp_2___N14 = 56'd36028797018963968;
parameter fp_2___N15 = 60'd576460752303423488;
parameter fp_2___N16 = 64'd9223372036854775808;
parameter fp_2___N17 = 68'd147573952589676412928;
parameter fp_2___N18 = 72'd2361183241434822606848;
parameter fp_2___N19 = 76'd37778931862957161709568;
parameter fp_2___N20 = 80'd604462909807314587353088;
parameter fp_2___N21 = 84'd9671406556917033397649408;
parameter fp_2___N22 = 88'd154742504910672534362390528;
parameter fp_2___N23 = 92'd2475880078570760549798248448;
parameter fp_2___N24 = 96'd39614081257132168796771975168;
parameter fp_2___N25 = 100'd633825300114114700748351602688;
parameter fp_2___N26 = 104'd10141204801825835211973625643008;
parameter fp_2___N27 = 108'd162259276829213363391578010288128;
parameter fp_2___N28 = 112'd2596148429267413814265248164610048;
parameter fp_2___N29 = 116'd41538374868278621028243970633760768;
parameter fp_2___N30 = 120'd664613997892457936451903530140172288;
parameter fp_2___N31 = 124'd10633823966279326983230456482242756608;
parameter fp_2___N32 = 128'd170141183460469231731687303715884105728;
