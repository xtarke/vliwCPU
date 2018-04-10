#include "boot.inc"

int main_app(){
	
		int i = 0;
		int j = 0;
		int k = 0;
		int a = 0;
		int b = 0;
		int c = 0;
		
		for(i = 0; i < 5; i++)
		{
			for(j = 0; j < 6; j++)
			{
				      a = i;
				      b = j;
				      c = a+b;			  
			}
		}				
}	
	
// clang -emit-llvm -S loop-aninhado1-1.c -o loop-aninhado1-1.ll
// ./llc ../../../exemplos/loop-aninhado1-1.ll -march=newtarget -relocation-model=static -filetype=obj
