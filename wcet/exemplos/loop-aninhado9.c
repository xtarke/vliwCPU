
int main(){
	
		int i = 0;
		int j = 0;
		int k = 0;

		
		for(i = 0; i < 5; i++){
			for(k = 0; k < 5; k++){

			}	
		}	
		
		for(j = 0; j < 5; j++){
			for(k = 0; k < 5; k++){

			}	
		}				
}		
// clang -emit-llvm -S loop-aninhado9.c -o loop-aninhado9.ll
// ./llc ../../../exemplos/loop-aninhado9.ll -march=newtarget -relocation-model=static -filetype=obj
