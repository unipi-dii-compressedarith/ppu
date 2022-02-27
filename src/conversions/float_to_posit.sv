module float_to_posit #(
        parameter N = 16,
        parameter ES = 1,
        parameter FSIZE = `F,
        parameter EXP_SIZE = EXP_SIZE_F`F,
        parameter MANT_SIZE = MANT_SIZE_F`F
    )(
        input [FSIZE-1:0] float_bits,
        output [N-1:0] posit  
    );

    wire sign;
    wire [TE_SIZE-1:0] exp;
    wire [MANT_SIZE-1:0] frac;

    float_decoder #(
        .FSIZE(FSIZE),
        .EXP_SIZE(EXP_SIZE),
        .MANT_SIZE(MANT_SIZE)
    ) float_decoder_inst (
        .bits(float_bits),
        .sign(sign),
        .exp(float_exp),
        .frac(frac)
    );
    


    wire [EXP_SIZE-1:0] float_exp;
    assign exp = float_exp[TE_SIZE-1:0];

    wire [FRAC_FULL_SIZE-1:0] frac_full;
    assign frac_full = frac >> (MANT_SIZE - FRAC_FULL_SIZE);


    wire [N-1:0] posit_pif_out;
    pif_to_posit #(
        .N(N),
        .ES(ES)
    ) pif_to_posit_inst (
        .te(exp),
        .frac_full(frac_full),
        .frac_lsb_cut_off(1'b0),
        .posit(posit_pif_out)
    );


    set_sign #(
        .N(N)
    ) set_sign_inst (
        .posit_in(posit_pif_out),
        .sign(sign),
        .posit_out(posit)
    );

endmodule



`ifdef TB_FLOAT_TO_POSIT
module tb_float_to_posit;

    parameter N = 16;
    parameter ES = 1;
    parameter FSIZE = `F;
    parameter EXP_SIZE = EXP_SIZE_F`F;
    parameter MANT_SIZE = MANT_SIZE_F`F;


    reg [FSIZE-1:0] float_bits;
    
    wire [N-1:0] posit;
    reg [N-1:0] posit_expected;

    reg [200:0] ascii_x, ascii_exp, ascii_frac;
    

    float_to_posit #(
        .N(N),
        .ES(ES),
        .FSIZE(FSIZE),
        .EXP_SIZE(EXP_SIZE),
        .MANT_SIZE(MANT_SIZE)
    ) float_to_posit_inst (
        .float_bits(float_bits),
        .posit(posit)  
    );


    reg diff;
    always @(*) begin
        diff = posit == posit_expected? 0 : 1'bX;
    end


    initial begin
        $dumpfile({"tb_float_F",`STRINGIFY(`F),"_to_posit_P",`STRINGIFY(`N),"E",`STRINGIFY(`ES),".vcd"});
        $dumpvars(0, tb_float_to_posit);                        


    if (N == 16 && ES == 1 && FSIZE == 64) begin




float_bits = 13854141043498816859;
ascii_x = "-39.592786539384825";
ascii_exp = "5";
ascii_frac = "1068589707171163";
posit_expected = 16'd35597;
#10;

float_bits = 13856946266509743190;
ascii_x = "-59.52509486539263";
ascii_exp = "5";
ascii_frac = "3873812718097494";
posit_expected = 16'd34959;
#10;

float_bits = 13848338756031661172;
ascii_x = "-15.591263608397846";
ascii_exp = "3";
ascii_frac = "4273501494756468";
posit_expected = 16'd36969;
#10;

float_bits = 13855852604567306857;
ascii_x = "-51.75415937963846";
ascii_exp = "5";
ascii_frac = "2780150775661161";
posit_expected = 16'd35208;
#10;

float_bits = 13857648022042196010;
ascii_x = "-65.02273564806151";
ascii_exp = "6";
ascii_frac = "71968623179818";
posit_expected = 16'd34808;
#10;

float_bits = 13847871554981314060;
ascii_x = "-14.761347827238772";
ascii_exp = "3";
ascii_frac = "3806300444409356";
posit_expected = 16'd37181;
#10;

float_bits = 4634020108760940660;
ascii_x = "62.69325646315784";
ascii_exp = "5";
ascii_frac = "4319691824070772";
posit_expected = 16'd30678;
#10;

float_bits = 4631539553707495232;
ascii_x = "45.06785272437128";
ascii_exp = "5";
ascii_frac = "1839136770625344";
posit_expected = 16'd30114;
#10;

float_bits = 4630794565111856034;
ascii_x = "39.77439037581577";
ascii_exp = "5";
ascii_frac = "1094148174986146";
posit_expected = 16'd29945;
#10;

float_bits = 13854439123684634510;
ascii_x = "-41.71077364645235";
ascii_exp = "5";
ascii_frac = "1366669892988814";
posit_expected = 16'd35529;
#10;

float_bits = 4617880721095439296;
ascii_x = "5.502001226222035";
ascii_exp = "2";
ascii_frac = "1691103040680896";
posit_expected = 16'd25345;
#10;

float_bits = 13853283222744505430;
ascii_x = "-33.49760348378247";
ascii_exp = "5";
ascii_frac = "210768952859734";
posit_expected = 16'd35792;
#10;

float_bits = 13855479109963973130;
ascii_x = "-49.10032060719466";
ascii_exp = "5";
ascii_frac = "2406656172327434";
posit_expected = 16'd35293;
#10;

float_bits = 13856882570308607871;
ascii_x = "-59.07250613527048";
ascii_exp = "5";
ascii_frac = "3810116516962175";
posit_expected = 16'd34974;
#10;

float_bits = 13854598039033406918;
ascii_x = "-42.839935113162525";
ascii_exp = "5";
ascii_frac = "1525585241761222";
posit_expected = 16'd35493;
#10;

float_bits = 4634212555439391874;
ascii_x = "64.12134471420907";
ascii_exp = "6";
ascii_frac = "8538875151490";
posit_expected = 16'd30721;
#10;

float_bits = 4632140524539717400;
ascii_x = "49.33800731676291";
ascii_exp = "5";
ascii_frac = "2440107602847512";
posit_expected = 16'd30251;
#10;

float_bits = 4631670439470472230;
ascii_x = "45.99785200534852";
ascii_exp = "5";
ascii_frac = "1970022533602342";
posit_expected = 16'd30144;
#10;

float_bits = 4631539458436248018;
ascii_x = "45.06717578144493";
ascii_exp = "5";
ascii_frac = "1839041499378130";
posit_expected = 16'd30114;
#10;

float_bits = 13855040619335151530;
ascii_x = "-45.984657297114";
ascii_exp = "5";
ascii_frac = "1968165543505834";
posit_expected = 16'd35392;
#10;

float_bits = 13852093626363001224;
ascii_x = "-28.522506405069663";
ascii_exp = "4";
ascii_frac = "3524772198726024";
posit_expected = 16'd36063;
#10;

float_bits = 4626054285891937492;
ascii_x = "19.046340361969513";
ascii_exp = "4";
ascii_frac = "857468582438100";
posit_expected = 16'd28867;
#10;

float_bits = 4630092259143071504;
ascii_x = "34.784206331807695";
ascii_exp = "5";
ascii_frac = "391842206201616";
posit_expected = 16'd29785;
#10;

float_bits = 4632683665182455904;
ascii_x = "53.19725369870207";
ascii_exp = "5";
ascii_frac = "2983248245586016";
posit_expected = 16'd30374;
#10;

float_bits = 4633219925538618960;
ascii_x = "57.007612704179905";
ascii_exp = "5";
ascii_frac = "3519508601749072";
posit_expected = 16'd30496;
#10;

float_bits = 13857293489430364544;
ascii_x = "-61.99226210476172";
ascii_exp = "5";
ascii_frac = "4221035638718848";
posit_expected = 16'd34880;
#10;

float_bits = 4625128015006208072;
ascii_x = "15.877782557981973";
ascii_exp = "3";
ascii_frac = "4434797324079176";
posit_expected = 16'd28641;
#10;

float_bits = 4627942667203252900;
ascii_x = "25.75521847747099";
ascii_exp = "4";
ascii_frac = "2745849893753508";
posit_expected = 16'd29296;
#10;

float_bits = 4606219246166538624;
ascii_x = "0.8930663565623007";
ascii_exp = "-1";
ascii_frac = "3540426993891712";
posit_expected = 16'd15508;
#10;

float_bits = 13855370904404389179;
ascii_x = "-48.33147386388233";
ascii_exp = "5";
ascii_frac = "2298450612743483";
posit_expected = 16'd35317;
#10;

float_bits = 13839475674127013824;
ascii_x = "-3.9618168622282326";
ascii_exp = "1";
ascii_frac = "4417618844850112";
posit_expected = 16'd41038;
#10;

float_bits = 13857238011670233961;
ascii_x = "-61.59806891019145";
ascii_exp = "5";
ascii_frac = "4165557878588265";
posit_expected = 16'd34893;
#10;

float_bits = 4634287632547149214;
ascii_x = "65.1882545849862";
ascii_exp = "6";
ascii_frac = "83615982908830";
posit_expected = 16'd30730;
#10;

float_bits = 4632912415931321372;
ascii_x = "54.82262552776248";
ascii_exp = "5";
ascii_frac = "3211998994451484";
posit_expected = 16'd30426;
#10;

float_bits = 4619731508251910688;
ascii_x = "7.145830438058084";
ascii_exp = "2";
ascii_frac = "3541890197152288";
posit_expected = 16'd26187;
#10;

float_bits = 13852499128407122616;
ascii_x = "-29.963139064001297";
ascii_exp = "4";
ascii_frac = "3930274242847416";
posit_expected = 16'd35970;
#10;

float_bits = 4633828323948800244;
ascii_x = "61.33054341220296";
ascii_exp = "5";
ascii_frac = "4127907011930356";
posit_expected = 16'd30635;
#10;

float_bits = 4622300451200506688;
ascii_x = "10.855020252883719";
ascii_exp = "3";
ascii_frac = "1607233518377792";
posit_expected = 16'd27355;
#10;

float_bits = 4633267772523821744;
ascii_x = "57.3475859818185";
ascii_exp = "5";
ascii_frac = "3567355586951856";
posit_expected = 16'd30507;
#10;

float_bits = 4632544244931526572;
ascii_x = "52.2066132335452";
ascii_exp = "5";
ascii_frac = "2843827994656684";
posit_expected = 16'd30343;
#10;

float_bits = 4608334693136964800;
ascii_x = "1.255856299912736";
ascii_exp = "0";
ascii_frac = "1152274336947392";
posit_expected = 16'd17432;
#10;

float_bits = 13846828265561140868;
ascii_x = "-12.908093530240201";
ascii_exp = "3";
ascii_frac = "2763011024236164";
posit_expected = 16'd37656;
#10;

float_bits = 4624542033796579608;
ascii_x = "14.83687082849842";
ascii_exp = "3";
ascii_frac = "3848816114450712";
posit_expected = 16'd28374;
#10;

float_bits = 13845384554439955256;
ascii_x = "-10.343547406003935";
ascii_exp = "3";
ascii_frac = "1319299903050552";
posit_expected = 16'd38312;
#10;

float_bits = 13855718587252097651;
ascii_x = "-50.80190908175873";
ascii_exp = "5";
ascii_frac = "2646133460451955";
posit_expected = 16'd35238;
#10;

float_bits = 13852293685865195462;
ascii_x = "-29.23326053508915";
ascii_exp = "4";
ascii_frac = "3724831700920262";
posit_expected = 16'd36017;
#10;

float_bits = 4631795835980070128;
ascii_x = "46.8888477951931";
ascii_exp = "5";
ascii_frac = "2095419043200240";
posit_expected = 16'd30172;
#10;

float_bits = 13857893714089653662;
ascii_x = "-68.51422963916272";
ascii_exp = "6";
ascii_frac = "317660670637470";
posit_expected = 16'd34780;
#10;

float_bits = 13857861166470319068;
ascii_x = "-68.0517001494731";
ascii_exp = "6";
ascii_frac = "285113051302876";
posit_expected = 16'd34784;
#10;

float_bits = 4626027903655861648;
ascii_x = "18.952611830985518";
ascii_exp = "4";
ascii_frac = "831086346362256";
posit_expected = 16'd28861;
#10;

float_bits = 13853204045912782078;
ascii_x = "-32.935018257567194";
ascii_exp = "5";
ascii_frac = "131592121136382";
posit_expected = 16'd35810;
#10;

float_bits = 4617533119771807792;
ascii_x = "5.193269231913334";
ascii_exp = "2";
ascii_frac = "1343501717049392";
posit_expected = 16'd25187;
#10;

float_bits = 13839915172936753392;
ascii_x = "-4.313987082751041";
ascii_exp = "2";
ascii_frac = "353518027219184";
posit_expected = 16'd40799;
#10;

float_bits = 13850700607767687910;
ascii_x = "-23.573510186676593";
ascii_exp = "4";
ascii_frac = "2131753603412710";
posit_expected = 16'd36379;
#10;

float_bits = 4634949350419106010;
ascii_x = "74.59183112581687";
ascii_exp = "6";
ascii_frac = "745333854865626";
posit_expected = 16'd30805;
#10;

float_bits = 13854995487433722933;
ascii_x = "-45.66397585000269";
ascii_exp = "5";
ascii_frac = "1923033642077237";
posit_expected = 16'd35403;
#10;

float_bits = 13846925491526572088;
ascii_x = "-13.080801538901241";
ascii_exp = "3";
ascii_frac = "2860236989667384";
posit_expected = 16'd37611;
#10;

float_bits = 13854845662768395333;
ascii_x = "-44.59940757414055";
ascii_exp = "5";
ascii_frac = "1773208976749637";
posit_expected = 16'd35437;
#10;

float_bits = 4626294498581120900;
ascii_x = "19.89974726865286";
ascii_exp = "4";
ascii_frac = "1097681271621508";
posit_expected = 16'd28922;
#10;

float_bits = 13853291198517025915;
ascii_x = "-33.554274756047526";
ascii_exp = "5";
ascii_frac = "218744725380219";
posit_expected = 16'd35790;
#10;

float_bits = 13850152259785297970;
ascii_x = "-21.625386808897197";
ascii_exp = "4";
ascii_frac = "1583405621022770";
posit_expected = 16'd36504;
#10;

float_bits = 4630409931213048698;
ascii_x = "37.04140214856939";
ascii_exp = "5";
ascii_frac = "709514276178810";
posit_expected = 16'd29857;
#10;

float_bits = 13851636836979095996;
ascii_x = "-26.899664512538706";
ascii_exp = "4";
ascii_frac = "3067982814820796";
posit_expected = 16'd36166;
#10;

float_bits = 4621131951342068496;
ascii_x = "8.779347537508812";
ascii_exp = "3";
ascii_frac = "438733659939600";
posit_expected = 16'd26824;
#10;

float_bits = 4633732161093532524;
ascii_x = "60.64726522959867";
ascii_exp = "5";
ascii_frac = "4031744156662636";
posit_expected = 16'd30613;
#10;

float_bits = 13856992426903822453;
ascii_x = "-59.85308419232107";
ascii_exp = "5";
ascii_frac = "3919973112176757";
posit_expected = 16'd34949;
#10;

float_bits = 13857699794300843132;
ascii_x = "-65.75846369397362";
ascii_exp = "6";
ascii_frac = "123740881826940";
posit_expected = 16'd34802;
#10;

float_bits = 13854292589263850761;
ascii_x = "-40.669583964185286";
ascii_exp = "5";
ascii_frac = "1220135472205065";
posit_expected = 16'd35563;
#10;

float_bits = 4630794557487138806;
ascii_x = "39.774336198941384";
ascii_exp = "5";
ascii_frac = "1094140550268918";
posit_expected = 16'd29945;
#10;

float_bits = 4625566903780905804;
ascii_x = "17.31481126930457";
ascii_exp = "4";
ascii_frac = "370086471406412";
posit_expected = 16'd28756;
#10;

float_bits = 13854112141364877790;
ascii_x = "-39.387424526201116";
ascii_exp = "5";
ascii_frac = "1039687573232094";
posit_expected = 16'd35604;
#10;

float_bits = 13851197816568415022;
ascii_x = "-25.339950694239796";
ascii_exp = "4";
ascii_frac = "2628962404139822";
posit_expected = 16'd36266;
#10;

float_bits = 13855376192209012772;
ascii_x = "-48.36904597551646";
ascii_exp = "5";
ascii_frac = "2303738417367076";
posit_expected = 16'd35316;
#10;

float_bits = 13841979172749247744;
ascii_x = "-6.147187174473629";
ascii_exp = "2";
ascii_frac = "2417517839713536";
posit_expected = 16'd39861;
#10;

float_bits = 13857898224176824265;
ascii_x = "-68.57832183269706";
ascii_exp = "6";
ascii_frac = "322170757808073";
posit_expected = 16'd34779;
#10;

float_bits = 4629023126843066256;
ascii_x = "29.593782219227762";
ascii_exp = "4";
ascii_frac = "3826309533566864";
posit_expected = 16'd29542;
#10;

float_bits = 4633555099489844544;
ascii_x = "59.389166866773394";
ascii_exp = "5";
ascii_frac = "3854682552974656";
posit_expected = 16'd30572;
#10;

float_bits = 4634500313995727558;
ascii_x = "68.21063975135175";
ascii_exp = "6";
ascii_frac = "296297431487174";
posit_expected = 16'd30754;
#10;

float_bits = 4630155237359125248;
ascii_x = "35.231693471088875";
ascii_exp = "5";
ascii_frac = "454820422255360";
posit_expected = 16'd29799;
#10;

float_bits = 4634554462673341420;
ascii_x = "68.98013874194265";
ascii_exp = "6";
ascii_frac = "350446109101036";
posit_expected = 16'd30760;
#10;

float_bits = 13858158134607782064;
ascii_x = "-72.27187120600388";
ascii_exp = "6";
ascii_frac = "582081188765872";
posit_expected = 16'd34750;
#10;

float_bits = 13852974086679426150;
ascii_x = "-31.650529814873515";
ascii_exp = "4";
ascii_frac = "4405232515150950";
posit_expected = 16'd35862;
#10;

float_bits = 4634619263476792790;
ascii_x = "69.90101354521843";
ascii_exp = "6";
ascii_frac = "415246912552406";
posit_expected = 16'd30767;
#10;

float_bits = 4631007293330988350;
ascii_x = "41.28591528377227";
ascii_exp = "5";
ascii_frac = "1306876394118462";
posit_expected = 16'd29993;
#10;

float_bits = 13847125364825051524;
ascii_x = "-13.435847839668675";
ascii_exp = "3";
ascii_frac = "3060110288146820";
posit_expected = 16'd37520;
#10;

float_bits = 4634379674900981864;
ascii_x = "66.4962551029472";
ascii_exp = "6";
ascii_frac = "175658336741480";
posit_expected = 16'd30740;
#10;

float_bits = 4625781320004416952;
ascii_x = "18.07657071952937";
ascii_exp = "4";
ascii_frac = "584502694917560";
posit_expected = 16'd28805;
#10;

float_bits = 4631908471331790198;
ascii_x = "47.6891701047379";
ascii_exp = "5";
ascii_frac = "2208054394920310";
posit_expected = 16'd30198;
#10;

float_bits = 13852787731142993364;
ascii_x = "-30.98846195146855";
ascii_exp = "4";
ascii_frac = "4218876978718164";
posit_expected = 16'd35905;
#10;

float_bits = 13855083271517254399;
ascii_x = "-46.2877192786891";
ascii_exp = "5";
ascii_frac = "2010817725608703";
posit_expected = 16'd35383;
#10;

float_bits = 13844278423461877832;
ascii_x = "-8.378664077823615";
ascii_exp = "3";
ascii_frac = "213168924973128";
posit_expected = 16'd38815;
#10;

float_bits = 13856243882459128549;
ascii_x = "-54.534356016612755";
ascii_exp = "5";
ascii_frac = "3171428667482853";
posit_expected = 16'd35119;
#10;

float_bits = 13849062787802052272;
ascii_x = "-17.754804791350296";
ascii_exp = "4";
ascii_frac = "493933637777072";
posit_expected = 16'd36752;
#10;

float_bits = 4634575003634806658;
ascii_x = "69.27204336103571";
ascii_exp = "6";
ascii_frac = "370987070566274";
posit_expected = 16'd30762;
#10;

float_bits = 13851187673596766958;
ascii_x = "-25.303915620122034";
ascii_exp = "4";
ascii_frac = "2618819432491758";
posit_expected = 16'd36269;
#10;

float_bits = 13858250926974567068;
ascii_x = "-73.59053004906531";
ascii_exp = "6";
ascii_frac = "674873555550876";
posit_expected = 16'd34739;
#10;

float_bits = 13857877261273678322;
ascii_x = "-68.28042106168121";
ascii_exp = "6";
ascii_frac = "301207854662130";
posit_expected = 16'd34782;
#10;

float_bits = 13855544499812666051;
ascii_x = "-49.56494342700673";
ascii_exp = "5";
ascii_frac = "2472046021020355";
posit_expected = 16'd35278;
#10;

float_bits = 4631186865350406160;
ascii_x = "42.561851223203234";
ascii_exp = "5";
ascii_frac = "1486448413536272";
posit_expected = 16'd30034;
#10;

float_bits = 13849861207102423744;
ascii_x = "-20.59135996119835";
ascii_exp = "4";
ascii_frac = "1292352938148544";
posit_expected = 16'd36570;
#10;












    end

    if (N == 8 && ES == 0 && FSIZE == 64) begin
    float_bits = 4631840980365643314;
ascii_x = "47.209617947486905";
ascii_exp = "5";
ascii_frac = "2140563428773426";
posit_expected = 8'd126;
#10;

float_bits = 4626500949098613190;
ascii_x = "20.63320684614316";
ascii_exp = "4";
ascii_frac = "1304131789113798";
posit_expected = 8'd125;
#10;

float_bits = 4635274441167615127;
ascii_x = "79.2116485221362";
ascii_exp = "6";
ascii_frac = "1070424603374743";
posit_expected = 8'd127;
#10;

float_bits = 4629417380945110077;
ascii_x = "30.994454160482054";
ascii_exp = "4";
ascii_frac = "4220563635610685";
posit_expected = 8'd126;
#10;

float_bits = 4623678552057686250;
ascii_x = "13.303019135917982";
ascii_exp = "3";
ascii_frac = "2985334375557354";
posit_expected = 8'd123;
#10;

float_bits = 4635352308009339646;
ascii_x = "80.31820289701497";
ascii_exp = "6";
ascii_frac = "1148291445099262";
posit_expected = 8'd127;
#10;

float_bits = 4640663550923604007;
ascii_x = "183.5910086175438";
ascii_exp = "7";
ascii_frac = "1955934731993127";
posit_expected = 8'd127;
#10;

float_bits = 4639836699239122197;
ascii_x = "160.0904702991617";
ascii_exp = "7";
ascii_frac = "1129083047511317";
posit_expected = 8'd127;
#10;

float_bits = 4639588369707242464;
ascii_x = "153.03252050108767";
ascii_exp = "7";
ascii_frac = "880753515631584";
posit_expected = 8'd127;
#10;

float_bits = 4631443540117886445;
ascii_x = "44.38563513806353";
ascii_exp = "5";
ascii_frac = "1743123181016557";
posit_expected = 8'd126;
#10;

float_bits = 4637253516576973904;
ascii_x = "107.33600163496271";
ascii_exp = "6";
ascii_frac = "3049500012733520";
posit_expected = 8'd127;
#10;

float_bits = 4632984741371391886;
ascii_x = "55.336528688290045";
ascii_exp = "5";
ascii_frac = "3284324434521998";
posit_expected = 8'd127;
#10;

float_bits = 4630056891745434951;
ascii_x = "34.53290585707378";
ascii_exp = "5";
ascii_frac = "356474808565063";
posit_expected = 8'd126;
#10;

float_bits = 4626670805634974040;
ascii_x = "21.236658486306027";
ascii_exp = "4";
ascii_frac = "1473988325474648";
posit_expected = 8'd125;
#10;

float_bits = 4631231652986189901;
ascii_x = "42.8800865157833";
ascii_exp = "5";
ascii_frac = "1531236049320013";
posit_expected = 8'd126;
#10;

float_bits = 4640730546108138241;
ascii_x = "185.4951262856121";
ascii_exp = "7";
ascii_frac = "2022929916527361";
posit_expected = 8'd127;
#10;

float_bits = 4640037022849862920;
ascii_x = "165.78400975568388";
ascii_exp = "7";
ascii_frac = "1329406658252040";
posit_expected = 8'd127;
#10;

float_bits = 4639880327826781196;
ascii_x = "161.33046934046467";
ascii_exp = "7";
ascii_frac = "1172711635170316";
posit_expected = 8'd127;
#10;

float_bits = 4639836667482039793;
ascii_x = "160.08956770859325";
ascii_exp = "7";
ascii_frac = "1129051290428913";
posit_expected = 8'd127;
#10;

float_bits = 4630641545917197086;
ascii_x = "38.68712360384801";
ascii_exp = "5";
ascii_frac = "941128980327198";
posit_expected = 8'd126;
#10;


        
    end

    end


endmodule
`endif
