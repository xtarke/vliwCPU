
int main(){
	
		int i = 0;
		int j = 0;
		int k = 0;
		int l = 0;
		int m = 0;
		
		for(m = 0; m < 1; m++){
			for(i = 0; i < 1; i++){
				for(j = 0; j < 1; j++){

				}	
				for(k = 0; k < 1; k++){
			
				}					
			}
			for(l = 0; l < 1; l++){
			
			}
		}			
}		
// clang -emit-llvm -S loop-aninhado4.c -o loop-aninhado4.ll
// ./llc ../../../exemplos/loop-aninhado4.ll -march=newtarget -relocation-model=static -filetype=obj











