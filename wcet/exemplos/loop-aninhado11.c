
int main(){
	
		int i = 0;
		int j = 0;
		int k = 0;
		int l = 0;
		int m = 0;
		int n = 0;
		
		while(n++ < 10){
			
			for(m = 0; m < 10; m++){
				for(i = 0; i < 10; i++){
					for(j = 0; j < 10; j++){

					}	
					for(k = 0; k < 10; k++){
			
					}					
				}
				for(l = 0; l < 10; l++){
			
				}
			}	
		
			for(m = 0; m < 10; m++){
				for(i = 0; i < 10; i++){
					for(j = 0; j < 10; j++){

					}	
					for(k = 0; k < 10; k++){
			
					}					
				}
				for(l = 0; l < 10; l++){
			
				}
			}
			
			for(m = 0; m < 10; m++){
				for(i = 0; i < 10; i++){
					for(j = 0; j < 10; j++){

					}	
					for(k = 0; k < 10; k++){
			
					}					
				}
				for(l = 0; l < 10; l++){
			
				}
			}			
		}					
}		
// clang -emit-llvm -S loop-aninhado6.c -o loop-aninhado6.ll
// ./llc ../../../exemplos/loop-aninhado6.ll -march=newtarget -relocation-model=static -filetype=obj











