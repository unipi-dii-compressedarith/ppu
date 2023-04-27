"""

after running 

  make -f Makefile_new.mk TOP=tb_fir_to_fixed

from the ROOT,
and copying the stdout into the array as a tuple

```
  ***** Using NR *****
  VCD info: dumpfile tb_fir_to_fixed.vcd opened for output.
     13604,           52341652286034984748078596096
     24193,          302096055211860455208976908288
     54793,           32142919691913760497087807488
     22115,          221707323910766073607715028992
     31501,        15469298730910111915139456303104
     39309,          572392525664577704606482563072
     33893,        18281898500166495899710266540032
     21010,          178959706929192785990104645632
     58113,           16088384807431485056989790208
     52493,           46915993207604529011997278208
     61814,            4047483644069778476916277248
     52541,           46451765692872511408910106624
     22509,          236949460644467318242410496000
     [...]
```
run this script to validate the conversion.

"""

from hardposit import from_bits
from fixed2float import to_Fx

arr = [
    (13604, 52341652286034984748078596096),
    (24193, 302096055211860455208976908288),
    (54793, 32142919691913760497087807488),
    (22115, 221707323910766073607715028992),
    (31501, 15469298730910111915139456303104),
    (39309, 572392525664577704606482563072),
    (33893, 18281898500166495899710266540032),
    (21010, 178959706929192785990104645632),
    (58113, 16088384807431485056989790208),
    (52493, 46915993207604529011997278208),
    (61814, 4047483644069778476916277248),
    (52541, 46451765692872511408910106624),
    (22509, 236949460644467318242410496000),
    (63372, 1378175434360677259165040640),
    (59897, 8682505236472266732739756032),
    (9414, 25716270034842391804349775872),
    (33989, 16380422599824151797465211731968),
    (53930, 36316131621223460408173527040),
    (63461, 1270581036414975262616190976),
    (29303, 2048790765017304354958050590720),
    (54802, 32099398362407633846798385152),
    (56207, 25305235256173417884949676032),
    (27122, 787948835005144544973292568576),
    (38606, 728527713119446291778134605824),
    (31464, 14736438227653166792399174762496),
    (20165, 152363338897670944146568773632),
    (18780, 125573542735010761635079913472),
    (10429, 30624508862477786253656850432),
    (22573, 239425340723038078792208744448),
    (9829, 27723086895402676234362028032),
    (25187, 411460320557478268869596413952),
    (34570, 7506868398226545986988289294336),
    (8832, 22901890726779535085633798144),
    (8480, 21199723172762137207647502336),
    (17834, 107275241529323734446727233536),
    (52381, 47999190741979236752534011904),
    (16022, 75727113340660371503594864640),
    (47123, 118474730322233659121205248000),
    (14349, 59546850170938174629327405056),
    (54867, 31785077649307830261374779392),
    (56683, 23003440495627163936309116928),
    (10965, 33216445819731551204226891776),
    (18946, 128784449711907216723099516928),
    (16046, 75959227098026380305138450432),
    (59677, 9214432597102703569610473472),
    (29391, 2157729488474417819149173522432),
    (18723, 124471002387522219827747880960),
    (25866, 516530481391824919701659582464),
    (2762, 2101113074490225505639333888),
    (19516, 139809853186792634796419842048),
    (48626, 89402482212141056727871127552),
    (24970, 377881196991862328912957669376),
    (45889, 142343761704704897546603986944),
    (13528, 51606625387709290209857241088),
    (62328, 2804707901505939685318328320),
    (4745, 6520945871001309768365113344),
    (3563, 3663045233432326399359713280),
    (26038, 543146192236460595611990753280),
    (63942, 689087717180338629582520320),
    (5038, 7229376401295482464742932480),
    (700, 134190765977223838392385536),
    (56618, 23317761208726967521732722688),
    (39435, 552894970045832965276821356544),
    (48753, 86945944946684130244868177920),
    (16773, 86752516815545789576915189760),
    (21839, 211030091071929668736710082560),
    (24635, 326042457846787029901556842496),
    (13114, 47602663073145638383230386176),
    (12926, 45784438640445236104472297472),
    (19221, 134103723318211585091806691328),
    (39921, 477690112659246113576699559936),
    (19417, 137894914688523062183685259264),
    (1890, 1046929759786268865295548416),
    (64332, 418288333586661694448336896),
    (21919, 214124941170143119423957893120),
    (41359, 301477085192217765071527346176),
    (43512, 218186931924048273450970644480),
    (24759, 345230528455710424162493267968),
    (22175, 224028461484426161623150886912),
    (37980, 922265329267608304799847546880),
    (49243, 78348064517584887554357854208),
    (14217, 58270224505425126220837683200),
    (12873, 45271854092928633334396878848),
    (16080, 76288054920961559440658530304),
    (49367, 77148810104527175413049327616),
    (64593, 260523514126952587149180928),
    (12182, 39101496709615566026696556544),
    (32524, 385365782469381738054997774434304),
    (52930, 42689588542231785417224486912),
    (60872, 6325099888223739842062712832),
    (23159, 262095117692451605076298956800),
    (60733, 6661181266076606752631029760),
    (56082, 25909698165980732472302764032),
    (126, 4684587551006688051986432),
    (33133, 186344638233549722020015371190272),
    (59193, 10865825266696287022259109888),
    (36639, 1546187109067439963349006155776),
    (63187, 1601826710989383656485683200),
    (12165, 39019289753881771242816536576),
    (34936, 4773496791484426340011023007744),
]

N, ES = 16, 1
FX_M, FX_N = 32, 128

for (operand2_i_bits_posit, fixed_o) in arr:
  p = from_bits(operand2_i_bits_posit, N, ES)

  try:
    if fixed_o != to_Fx(p.eval(), FX_M, FX_N, False).val:
      print(f"Error: {p}")
  except Exception:
    print(to_Fx(p.eval(), FX_M, FX_N, True))

print("Ok")
