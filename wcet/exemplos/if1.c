
int main(int argc, char** argv){

	int i = 1;
	int j = 0;


	if(i < 2){
		i++;
	} else {
		i--;	
	}		

}

// clang -emit-llvm -S if1.c -o if1.ll
// ./llc ../../../exemplos/if1.ll -march=newtarget -relocation-model=static -filetype=obj
