
int main(){
	
		int i = 0;
		int j = 0;
		int k = 0;
		int l = 0;
		int m = 0;
		
		for(i = 0; i < 10; i++){
			for(j = 0; j < 10; j++){

			}	
			for(k = 0; k < 10; k++){
			
			}					
		}
		for(l = 0; l < 10; l++){
			//m++;
		}
		m++;		
		m+=1;
		m+=2;
}	
// clang -emit-llvm -S loop-aninhado3.c -o loop-aninhado3.ll
// ./llc ../../../exemplos/loop-aninhado3.ll -march=newtarget -relocation-model=static -filetype=obj
