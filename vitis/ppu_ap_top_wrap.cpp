using namespace std;

void ppu_ap_top(int ppu_in1, int ppu_in2,unsigned int ppu_op, int& ppu_out){}

void ppu_ap_top_wrap(int ppu_in1, int ppu_in2,unsigned int ppu_op, int& ppu_out) {
    int tmp;
    ppu_ap_top(ppu_in1,ppu_in2,ppu_op,tmp);
    ppu_out = tmp;
}
