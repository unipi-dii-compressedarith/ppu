/*

cd ppu # root
make conversions N=16 ES=1 F=64

gtkwave waveforms/tb_posit_P16E1_to_float_F64.vcd 
*/

module posit_to_float #(
        parameter N = `N,
        parameter ES = `ES,
        parameter FSIZE = `F
    )(
        input [N-1:0] posit,
        output [FSIZE-1:0] float_bits
    );

    parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
    parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;

    wire [PIF_SIZE-1:0] pif;
    
    posit_to_pif #(
        .N(N),
        .ES(ES)
    ) posit_to_pif_inst (
        .p_cond(posit),
        .pif(pif)
    );

    pif_to_float #(
        .N(N),
        .ES(ES),
        .FSIZE(FSIZE)
    ) pif_to_float_inst (
        .pif(pif),
        .float(float_bits)
    );

endmodule




`ifdef TB_POSIT_TO_FLOAT
module tb_posit_to_float;

    parameter N = `N;
    parameter ES = `ES;
    parameter FSIZE = `F;
    parameter FLOAT_EXP_SIZE = FLOAT_EXP_SIZE_F`F;
    parameter FLOAT_MANT_SIZE = FLOAT_MANT_SIZE_F`F;


    
    reg [N-1:0] posit;
    wire [FSIZE-1:0] float_bits;

    reg [FSIZE-1:0] float_bits_expected;

    reg [200:0] ascii_x, ascii_exp, ascii_frac, posit_expected_ascii;
    

    posit_to_float #(
        .N(N),
        .ES(ES),
        .FSIZE(FSIZE)
    ) posit_to_float_inst (
        .posit(posit),
        .float_bits(float_bits)
    );


    reg diff;
    always @(*) begin
        diff = float_bits == float_bits_expected? 0 : 1'bX;
    end


    initial begin
        $dumpfile({"tb_posit_P",`STRINGIFY(`N),"E",`STRINGIFY(`ES),"_to_float_F",`STRINGIFY(`F),".vcd"});
        $dumpvars(0, tb_posit_to_float);                        


        if (N == 16 && ES == 1 && FSIZE == 64) begin



posit = 16'd7734; ascii_x = "0.2220458984375"; ascii_exp = "-3"; ascii_frac = "3496446976327680"; float_bits_expected = 4597168066894233600; #10; 
posit = 16'd3380; ascii_x = "0.0406494140625"; ascii_exp = "-5"; ascii_frac = "1354598325420032"; float_bits_expected = 4586019018988584960; #10; 
posit = 16'd12978; ascii_x = "0.584228515625"; ascii_exp = "-1"; ascii_frac = "758663023165440"; float_bits_expected = 4603437482195812352; #10; 
posit = 16'd5078; ascii_x = "0.09246826171875"; ascii_exp = "-4"; ascii_frac = "2159440836952064"; float_bits_expected = 4591327461127487488; #10; 
posit = 16'd2179; ascii_x = "0.0176239013671875"; ascii_exp = "-6"; ascii_frac = "576144092954624"; float_bits_expected = 4580736965128749056; #10; 
posit = 16'd13159; ascii_x = "0.6063232421875"; ascii_exp = "-1"; ascii_frac = "957674627792896"; float_bits_expected = 4603636493800439808; #10; 
posit = 16'd30079; ascii_x = "43.96875"; ascii_exp = "5"; ascii_frac = "1684451813752832"; float_bits_expected = 4631384868750622720; #10; 
posit = 16'd26229; ascii_x = "7.228515625"; ascii_exp = "2"; ascii_frac = "3634985441427456"; float_bits_expected = 4619824603496185856; #10; 
posit = 16'd25072; ascii_x = "4.96875"; ascii_exp = "2"; ascii_frac = "1090715534753792"; float_bits_expected = 4617280333589512192; #10; 
posit = 16'd7272; ascii_x = "0.19384765625"; ascii_exp = "-3"; ascii_frac = "2480498232262656"; float_bits_expected = 4596152118150168576; #10; 
posit = 16'd17585; ascii_x = "1.293212890625"; ascii_exp = "0"; ascii_frac = "1320513464958976"; float_bits_expected = 4608502932264976384; #10; 
posit = 16'd9066; ascii_x = "0.3033447265625"; ascii_exp = "-2"; ascii_frac = "960973162676224"; float_bits_expected = 4599136192707952640; #10; 
posit = 16'd5657; ascii_x = "0.110137939453125"; ascii_exp = "-4"; ascii_frac = "3432675301916672"; float_bits_expected = 4592600695592452096; #10; 
posit = 16'd3479; ascii_x = "0.043670654296875"; ascii_exp = "-5"; ascii_frac = "1790004930019328"; float_bits_expected = 4586454425593184256; #10; 
posit = 16'd7025; ascii_x = "0.17877197265625"; ascii_exp = "-3"; ascii_frac = "1937339488141312"; float_bits_expected = 4595608959406047232; #10; 
posit = 16'd30391; ascii_x = "53.71875"; ascii_exp = "5"; ascii_frac = "3056642325217280"; float_bits_expected = 4632757059262087168; #10; 
posit = 16'd27162; ascii_x = "10.1015625"; ascii_exp = "3"; ascii_frac = "1183074511486976"; float_bits_expected = 4621876292193615872; #10; 
posit = 16'd26432; ascii_x = "7.625"; ascii_exp = "2"; ascii_frac = "4081387162304512"; float_bits_expected = 4620271005217062912; #10; 
posit = 16'd26229; ascii_x = "7.228515625"; ascii_exp = "2"; ascii_frac = "3634985441427456"; float_bits_expected = 4619824603496185856; #10; 
posit = 16'd6338; ascii_x = "0.1368408203125"; ascii_exp = "-3"; ascii_frac = "426610511577088"; float_bits_expected = 4594098230429483008; #10; 
posit = 16'd10153; ascii_x = "0.36968994140625"; ascii_exp = "-2"; ascii_frac = "2156142302068736"; float_bits_expected = 4600331361847345152; #10; 
posit = 16'd20544; ascii_x = "2.03125"; ascii_exp = "1"; ascii_frac = "70368744177664"; float_bits_expected = 4611756387171565568; #10; 
posit = 16'd23982; ascii_x = "3.7099609375"; ascii_exp = "1"; ascii_frac = "3850489720471552"; float_bits_expected = 4615536508147859456; #10; 
posit = 16'd28005; ascii_x = "13.39453125"; ascii_exp = "3"; ascii_frac = "3036851115917312"; float_bits_expected = 4623730068798046208; #10; 
posit = 16'd28837; ascii_x = "18.578125"; ascii_exp = "4"; ascii_frac = "725677674332160"; float_bits_expected = 4625922494983831552; #10; 
posit = 16'd2841; ascii_x = "0.0277252197265625"; ascii_exp = "-6"; ascii_frac = "3487650883305472"; float_bits_expected = 4583648471919099904; #10; 
posit = 16'd19852; ascii_x = "1.8466796875"; ascii_exp = "0"; ascii_frac = "3813106325127168"; float_bits_expected = 4610995525125144576; #10; 
posit = 16'd22010; ascii_x = "2.7470703125"; ascii_exp = "1"; ascii_frac = "1682252790497280"; float_bits_expected = 4613368271217885184; #10; 
posit = 16'd16579; ascii_x = "1.047607421875"; ascii_exp = "0"; ascii_frac = "214404767416320"; float_bits_expected = 4607396823567433728; #10; 
posit = 16'd5825; ascii_x = "0.115264892578125"; ascii_exp = "-4"; ascii_frac = "3802111208849408"; float_bits_expected = 4592970131499384832; #10; 
posit = 16'd15518; ascii_x = "0.894287109375"; ascii_exp = "-1"; ascii_frac = "3551422557716480"; float_bits_expected = 4606230241730363392; #10; 
posit = 16'd2927; ascii_x = "0.0290374755859375"; ascii_exp = "-6"; ascii_frac = "3865882883260416"; float_bits_expected = 4584026703919054848; #10; 
posit = 16'd30624; ascii_x = "61.0"; ascii_exp = "5"; ascii_frac = "4081387162304512"; float_bits_expected = 4633781804099174400; #10; 
posit = 16'd28360; ascii_x = "14.78125"; ascii_exp = "3"; ascii_frac = "3817504371638272"; float_bits_expected = 4624510722053767168; #10; 
posit = 16'd17945; ascii_x = "1.381103515625"; ascii_exp = "0"; ascii_frac = "1716337650958336"; float_bits_expected = 4608898756450975744; #10; 
posit = 16'd9838; ascii_x = "0.3504638671875"; ascii_exp = "-2"; ascii_frac = "1809796139319296"; float_bits_expected = 4599985015684595712; #10; 
posit = 16'd29781; ascii_x = "34.65625"; ascii_exp = "5"; ascii_frac = "373833953443840"; float_bits_expected = 4630074250890313728; #10; 
posit = 16'd18755; ascii_x = "1.578857421875"; ascii_exp = "0"; ascii_frac = "2606942069456896"; float_bits_expected = 4609789360869474304; #10; 
posit = 16'd28911; ascii_x = "19.734375"; ascii_exp = "4"; ascii_frac = "1051133116153856"; float_bits_expected = 4626247950425653248; #10; 
posit = 16'd27788; ascii_x = "12.546875"; ascii_exp = "3"; ascii_frac = "2559663069462528"; float_bits_expected = 4623252880751591424; #10; 
posit = 16'd16658; ascii_x = "1.06689453125"; ascii_exp = "0"; ascii_frac = "301266186010624"; float_bits_expected = 4607483684986028032; #10; 
posit = 16'd13564; ascii_x = "0.65576171875"; ascii_exp = "-1"; ascii_frac = "1402976837042176"; float_bits_expected = 4604081796009689088; #10; 
posit = 16'd19625; ascii_x = "1.791259765625"; ascii_exp = "0"; ascii_frac = "3563517185622016"; float_bits_expected = 4610745935985639424; #10; 
posit = 16'd14124; ascii_x = "0.72412109375"; ascii_exp = "-1"; ascii_frac = "2018703348596736"; float_bits_expected = 4604697522521243648; #10; 
posit = 16'd5286; ascii_x = "0.09881591796875"; ascii_exp = "-4"; ascii_frac = "2616837674106880"; float_bits_expected = 4591784857964642304; #10; 
posit = 16'd9997; ascii_x = "0.36016845703125"; ascii_exp = "-2"; ascii_frac = "1984618488135680"; float_bits_expected = 4600159838033412096; #10; 
posit = 16'd26627; ascii_x = "8.01171875"; ascii_exp = "3"; ascii_frac = "6597069766656"; float_bits_expected = 4620699814751895552; #10; 
posit = 16'd1416; ascii_x = "0.00689697265625"; ascii_exp = "-8"; ascii_frac = "3448068464705536"; float_bits_expected = 4574601690245758976; #10; 
posit = 16'd1517; ascii_x = "0.00766754150390625"; ascii_exp = "-8"; ascii_frac = "4336473859948544"; float_bits_expected = 4575490095641001984; #10; 
posit = 16'd20524; ascii_x = "2.021484375"; ascii_exp = "1"; ascii_frac = "48378511622144"; float_bits_expected = 4611734396939010048; #10; 
posit = 16'd9189; ascii_x = "0.31085205078125"; ascii_exp = "-2"; ascii_frac = "1096213092892672"; float_bits_expected = 4599271432638169088; #10; 
posit = 16'd17518; ascii_x = "1.27685546875"; ascii_exp = "0"; ascii_frac = "1246846185897984"; float_bits_expected = 4608429264985915392; #10; 
posit = 16'd15441; ascii_x = "0.8848876953125"; ascii_exp = "-1"; ascii_frac = "3466760162377728"; float_bits_expected = 4606145579335024640; #10; 
posit = 16'd11234; ascii_x = "0.4356689453125"; ascii_exp = "-2"; ascii_frac = "3344714371694592"; float_bits_expected = 4601519933916971008; #10; 
posit = 16'd32678; ascii_x = "38912.0"; ascii_exp = "15"; ascii_frac = "844424930131968"; float_bits_expected = 4675580838140706816; #10; 
posit = 16'd6408; ascii_x = "0.14111328125"; ascii_exp = "-3"; ascii_frac = "580542139465728"; float_bits_expected = 4594252162057371648; #10; 
posit = 16'd13526; ascii_x = "0.651123046875"; ascii_exp = "-1"; ascii_frac = "1361195395186688"; float_bits_expected = 4604040014567833600; #10; 
posit = 16'd6641; ascii_x = "0.15533447265625"; ascii_exp = "-3"; ascii_frac = "1092914558009344"; float_bits_expected = 4594764534475915264; #10; 
posit = 16'd20731; ascii_x = "2.12255859375"; ascii_exp = "1"; ascii_frac = "275977418571776"; float_bits_expected = 4611961995845959680; #10; 
posit = 16'd9053; ascii_x = "0.30255126953125"; ascii_exp = "-2"; ascii_frac = "946679511515136"; float_bits_expected = 4599121899056791552; #10; 
posit = 16'd11659; ascii_x = "0.46160888671875"; ascii_exp = "-2"; ascii_frac = "3812006813499392"; float_bits_expected = 4601987226358775808; #10; 
posit = 16'd24475; ascii_x = "3.95068359375"; ascii_exp = "1"; ascii_frac = "4392548952965120"; float_bits_expected = 4616078567380353024; #10; 
posit = 16'd10507; ascii_x = "0.39129638671875"; ascii_exp = "-2"; ascii_frac = "2545369418301440"; float_bits_expected = 4600720588963577856; #10; 
posit = 16'd18301; ascii_x = "1.468017578125"; ascii_exp = "0"; ascii_frac = "2107763790446592"; float_bits_expected = 4609290182590464000; #10; 
posit = 16'd29632; ascii_x = "31.0"; ascii_exp = "4"; ascii_frac = "4222124650659840"; float_bits_expected = 4629418941960159232; #10; 
posit = 16'd3308; ascii_x = "0.0384521484375"; ascii_exp = "-5"; ascii_frac = "1037938976620544"; float_bits_expected = 4585702359639785472; #10; 
posit = 16'd2018; ascii_x = "0.015167236328125"; ascii_exp = "-7"; ascii_frac = "4239716836704256"; float_bits_expected = 4579896938245128192; #10; 
posit = 16'd7499; ascii_x = "0.20770263671875"; ascii_exp = "-3"; ascii_frac = "2979676511272960"; float_bits_expected = 4596651296429178880; #10; 
posit = 16'd25072; ascii_x = "4.96875"; ascii_exp = "2"; ascii_frac = "1090715534753792"; float_bits_expected = 4617280333589512192; #10; 
posit = 16'd20166; ascii_x = "1.92333984375"; ascii_exp = "0"; ascii_frac = "4158352976248832"; float_bits_expected = 4611340771776266240; #10; 
posit = 16'd7779; ascii_x = "0.22479248046875"; ascii_exp = "-3"; ascii_frac = "3595403022827520"; float_bits_expected = 4597267022940733440; #10; 
posit = 16'd10848; ascii_x = "0.412109375"; ascii_exp = "-2"; ascii_frac = "2920302883373056"; float_bits_expected = 4601095522428649472; #10; 
posit = 16'd5817; ascii_x = "0.115020751953125"; ascii_exp = "-4"; ascii_frac = "3784519022804992"; float_bits_expected = 4592952539313340416; #10; 
posit = 16'd15041; ascii_x = "0.8360595703125"; ascii_exp = "-1"; ascii_frac = "3026955511267328"; float_bits_expected = 4605705774683914240; #10; 
posit = 16'd1402; ascii_x = "0.0067901611328125"; ascii_exp = "-8"; ascii_frac = "3324923162394624"; float_bits_expected = 4574478544943448064; #10; 
posit = 16'd22848; ascii_x = "3.15625"; ascii_exp = "1"; ascii_frac = "2603643534573568"; float_bits_expected = 4614289661961961472; #10; 
posit = 16'd29357; ascii_x = "26.703125"; ascii_exp = "4"; ascii_frac = "3012661860106240"; float_bits_expected = 4628209479169605632; #10; 
posit = 16'd31284; ascii_x = "141.0"; ascii_exp = "7"; ascii_frac = "457396837154816"; float_bits_expected = 4639165013028765696; #10; 
posit = 16'd24080; ascii_x = "3.7578125"; ascii_exp = "1"; ascii_frac = "3958241859993600"; float_bits_expected = 4615644260287381504; #10; 
posit = 16'd31452; ascii_x = "183.0"; ascii_exp = "7"; ascii_frac = "1935140464885760"; float_bits_expected = 4640642756656496640; #10; 
posit = 16'd595; ascii_x = "0.001293182373046875"; ascii_exp = "-10"; ascii_frac = "1460151441686528"; float_bits_expected = 4563606573967998976; #10; 
posit = 16'd9469; ascii_x = "0.32794189453125"; ascii_exp = "-2"; ascii_frac = "1404076348669952"; float_bits_expected = 4599579295893946368; #10; 
posit = 16'd31654; ascii_x = "233.5"; ascii_exp = "7"; ascii_frac = "3711951255371776"; float_bits_expected = 4642419567446982656; #10; 
posit = 16'd25403; ascii_x = "5.615234375"; ascii_exp = "2"; ascii_frac = "1818592232341504"; float_bits_expected = 4618008210287099904; #10; 
posit = 16'd13448; ascii_x = "0.6416015625"; ascii_exp = "-1"; ascii_frac = "1275433488220160"; float_bits_expected = 4603954252660867072; #10; 
posit = 16'd30910; ascii_x = "87.75"; ascii_exp = "6"; ascii_frac = "1671257674219520"; float_bits_expected = 4635875274238459904; #10; 
posit = 16'd20332; ascii_x = "1.9638671875"; ascii_exp = "0"; ascii_frac = "4340871906459648"; float_bits_expected = 4611523290706477056; #10; 
posit = 16'd26801; ascii_x = "8.69140625"; ascii_exp = "3"; ascii_frac = "389227116232704"; float_bits_expected = 4621082444798361600; #10; 
posit = 16'd9614; ascii_x = "0.3367919921875"; ascii_exp = "-2"; ascii_frac = "1563505534697472"; float_bits_expected = 4599738725079973888; #10; 
posit = 16'd6272; ascii_x = "0.1328125"; ascii_exp = "-3"; ascii_frac = "281474976710656"; float_bits_expected = 4593953094894616576; #10; 
posit = 16'd14553; ascii_x = "0.7764892578125"; ascii_exp = "-1"; ascii_frac = "2490393836912640"; float_bits_expected = 4605169213009559552; #10; 
posit = 16'd4470; ascii_x = "0.07391357421875"; ascii_exp = "-4"; ascii_frac = "822434697576448"; float_bits_expected = 4589990454988111872; #10; 
posit = 16'd12505; ascii_x = "0.5264892578125"; ascii_exp = "-1"; ascii_frac = "238594023227392"; float_bits_expected = 4602917413195874304; #10; 
posit = 16'd31516; ascii_x = "199.0"; ascii_exp = "7"; ascii_frac = "2498090418307072"; float_bits_expected = 4641205706609917952; #10; 
posit = 16'd10856; ascii_x = "0.41259765625"; ascii_exp = "-2"; ascii_frac = "2929098976395264"; float_bits_expected = 4601104318521671680; #10; 
posit = 16'd307; ascii_x = "0.0003414154052734375"; ascii_exp = "-12"; ascii_frac = "1794402976530432"; float_bits_expected = 4554933626248101888; #10; 
posit = 16'd1467; ascii_x = "0.00728607177734375"; ascii_exp = "-8"; ascii_frac = "3896669208838144"; float_bits_expected = 4575050290989891584; #10; 
posit = 16'd5556; ascii_x = "0.1070556640625"; ascii_exp = "-4"; ascii_frac = "3210573953105920"; float_bits_expected = 4592378594243641344; #10; 
posit = 16'd25681; ascii_x = "6.158203125"; ascii_exp = "2"; ascii_frac = "2429920697384960"; float_bits_expected = 4618619538752143360; #10; 
posit = 16'd11885; ascii_x = "0.47540283203125"; ascii_exp = "-2"; ascii_frac = "4060496441376768"; float_bits_expected = 4602235715986653184; #10; 




        end

    end


endmodule
`endif
