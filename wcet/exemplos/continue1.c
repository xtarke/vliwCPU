
int main(){
	
		int m = 0;
		int k = 8;
		int v = 4;
		int j = 0;
		
		for(m = 0; m < 10; m++){
			
			j+=2;
			
			//if(m < v){
			//	continue;
			//}
			
			if(m < k){
				continue;
			}
			j+=1;
			
			
			if(m < k){
				continue;
			}	

			j+=3;
		}			
}		
// clang -emit-llvm -S continue1.c -o continue1.ll
// ./llc ../../../exemplos/continue1.ll -march=newtarget -relocation-model=static -filetype=obj











