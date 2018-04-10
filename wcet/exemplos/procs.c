
int proc1(){
	return 1;
}

int proc2(){
	
	proc1();
	return proc1();
}

int main(){

	proc1();
	proc2();
	proc2();
	
}	

// clang -emit-llvm -S procs.c -o procs.ll
// ./llc ../../../exemplos/procs.ll -march=newtarget -relocation-model=static -filetype=obj
