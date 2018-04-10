
int main(){
	
		int i = 0;
		int j = 0;
		int k = 0;
		
		for(i = 0; i < 5; i++){
			for(j = 0; j < 6; j++){
			 	for(k = 0; k < 7; k++){
			
				}	
			}				
		}	
}	
// clang -emit-llvm -S loop-aninhado1.c -o loop-aninhado1.ll
// ./llc ../../../exemplos/loop-aninhado1.ll -march=newtarget -relocation-model=static -filetype=obj
