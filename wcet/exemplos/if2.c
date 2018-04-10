
int main(int argc, char** argv){

	int i = 1;

	if(i < 2){
		
		if(i < 1){
			i--;
		} else {
			i++;
		}		
	} else {
		i--;	
	}		

}

// clang -emit-llvm -S if2.c -o if2.ll
// ./llc ../../../exemplos/if2.ll -march=newtarget -relocation-model=static -filetype=obj
