
int main(){
	
		int m = 0;
		int n = 5;
		
		for(m = 0; m < 5 && m < n; m++){
			
			if(m > 7){
				break;
			}
			
			if(m  > 6){
				break;
			}	
			
			if(m < 5){
				continue;
			}	

		}			
}		
// clang -emit-llvm -S break1.c -o break1.ll
// ./llc ../../../exemplos/break1.ll -march=newtarget -relocation-model=static -filetype=obj











