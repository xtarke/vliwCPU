
int main(int argc, char** argv){

	int i = 1;
	int j = 0;

	for(j = 0; j < 1; j++){
		
		if(i < 2){
			i++;
		} else {
			i--;	
		}		
    }
}

// clang -emit-llvm -S loop-if1.c -o loop-if1.ll
// ./llc ../../../exemplos/loop-if1.ll -march=newtarget -relocation-model=static -filetype=obj
