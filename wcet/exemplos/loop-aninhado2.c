
int main(){
	
		int i = 0;
		int j = 0;
		int k = 0;
		
		for(i = 0; i < 5; i++){
			for(j = 0; j < 10; j++){

			}	
			for(k = 0; k < 6; k++){
			
			}					
		}	
}	
// clang -emit-llvm -S loop-aninhado2.c -o loop-aninhado2.ll
// ./llc ../../../exemplos/loop-aninhado2.ll -march=newtarget -relocation-model=static -filetype=obj
