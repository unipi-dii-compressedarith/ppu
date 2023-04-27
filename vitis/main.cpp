#include <cstdint>
#include <iostream>

void ppu_ap_top_wrap(int ppu_in1, int ppu_in2,unsigned int ppu_op, int& ppu_out);

int main() {
	int out{0};
	int a=20480,b=20480,op=0x00;
	ppu_ap_top_wrap(a,b,op++,out);
	ppu_ap_top_wrap(a,b,op++,out);
	ppu_ap_top_wrap(a,b,op++,out);
	ppu_ap_top_wrap(a,b,op++,out);

	return 0;
}
