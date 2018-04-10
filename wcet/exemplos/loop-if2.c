
int main(int argc, char** argv){

	int i = 1;
	int j = 0;

	for(j = 0; j < 5; j++){
		
		if(i < 6){
			i++;
			i+=1;
			i+=2;
			i+=3;
		} else {
			i--;
			i-=1;
			i-=2;
			i-=3;	
		}		
    }
}

// clang -emit-llvm -S loop-if2.c -o loop-if2.ll
// ./llc ../../../exemplos/loop-if2.ll -march=newtarget -relocation-model=static -filetype=obj
