
int main(){
	
		int i = 0;
		int j = 0;
		int k = 0;
		
		for(i = 0; i < 5; i++){	
			j+=2;
			j+=3;
			k+=4;
			k+=5;
			j+=6;
			j+=7;
			k+=8;
			k+=9;		
		}	
}	
// clang -emit-llvm -S loop-grande1.c -o loop-grande1.ll
// ./llc ../../../exemplos/loop-grande1.ll -march=newtarget -relocation-model=static -filetype=obj
