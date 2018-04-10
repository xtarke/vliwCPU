
int main(){
	
		int i = 0;
		int j = 0;
		int k = 0;
		int l = 0;
		int m = 0;
		
		for(m = 0; m < 5; m++){
			for(i = 0; i < 5; i++){
				for(j = 0; j < 5; j++){

				}	
				for(k = 0; k < 5; k++){
			
				}					
			}
			for(l = 0; l < 5; l++){
			
			}
		}	
		
		for(m = 0; m < 5; m++){
			for(i = 0; i < 5; i++){
				for(j = 0; j < 5; j++){

				}	
				for(k = 0; k < 5; k++){
			
				}					
			}
			for(l = 0; l < 5; l++){
			
			}
		}				
}		
// clang -emit-llvm -S loop-aninhado5.c -o loop-aninhado5.ll
// ./llc ../../../exemplos/loop-aninhado5.ll -march=newtarget -relocation-model=static -filetype=obj











