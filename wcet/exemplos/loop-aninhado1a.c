
int main(){
	
		int i = 0;
		int j = 0;
		
		for(i = 0; i < 1; i++){
			for(j = 0; j < 1; j++){
			}				
		}	
}	
// clang -emit-llvm -S loop-aninhado1a.c -o loop-aninhado1a.ll
// ./llc ../../../exemplos/loop-aninhado1a.ll -march=newtarget -relocation-model=static -filetype=obj
