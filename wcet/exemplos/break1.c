
int main(){
	
		int m = 0;
		int n = 5;
		
		for(m = 0; m < 5 && m < n; m++){
			
			if(m > 3){
				break;
			}

		}			
}		
// clang -emit-llvm -S break1.c -o break1.ll
// ./llc ../../../exemplos/break1.ll -march=newtarget -relocation-model=static -filetype=obj











