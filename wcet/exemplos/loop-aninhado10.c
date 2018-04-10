
int bar(){
	int k = 0;
	for(k = 0; k < 1; k++){
			
	}
	return 0;
}

int foo(){
	int k = 0;
	for(k = 0; k < 1; k++){
			
	}
	return 0;
}

int main(){
	
		int m = 0;
		int n = 0;
		
		for(m = 0; m < 2; m++){
			
			if(n == 0){
				//bar();
				n++;
				n--;
				n++;
				n--;
				n++;
				n--;
				n++;
				n--;
				bar();	
			} else {
				//bar(); 	
				//bar();
				//bar();	
				n++;
				n--;
				//foo();
				foo();
			}
		}
	return 0;				
}		
// clang -emit-llvm -S loop-aninhado10.c -o loop-aninhado10.ll
// ./llc ../../../exemplos/loop-aninhado10.ll -march=newtarget -relocation-model=static -filetype=obj











