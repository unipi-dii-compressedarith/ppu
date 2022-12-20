#include <cstdint>


void ppu_ap_top_wrap(int ppu_in1, int ppu_in2,unsigned int ppu_op, int& ppu_out);

int main() {
	uint64_t out{0};
	ppu_ap_top_wrap(0x01,0x02,0x1,out);
	return 0;
}
