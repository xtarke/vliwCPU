
unsigned int a = 0xFFFFF;
unsigned int b = 0xFCFC;

int main(){
	
		a = 0xE;
		b = 0xF;
}	
// clang -emit-llvm -S global-data2.c -o global-data2.ll
// ./llc ../../../global-data1.ll -march=newtarget -relocation-model=static -filetype=obj

/*      lui     $1, %hi(a)
        addiu   $2, $zero, 14
        sw      $2, %lo(a)($1)
        lui     $1, %hi(b)
        addiu   $2, $zero, 15
        sw      $2, %lo(b)($1)
*/
