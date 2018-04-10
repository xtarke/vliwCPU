typedef  unsigned char  bool;
typedef  unsigned int   uint;


void inc (uint* a) {
	(*a)++;
}

int main () {
  uint x = 513239;
  inc(&x);
  return 0;
}
