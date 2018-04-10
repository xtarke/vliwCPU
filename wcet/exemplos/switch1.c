
int main(int argc, char** argv){

	int i = 1;


	switch(i){
		case 1:
		{
			i++;
			break;
		}
		case 2:
		{
			i--;
			break;	
		}	
		case 3:
		{
			i+=3;
			break;	
		}	
		case 4:
		{
			i+=4;
			break;	
		}
	    case 5:
		{
			i+=5;
			break;	
		}
		case 6:
		{
			i+=6;
			break;	
		}						
		default:
		{
			
		}	
	}	
}

// clang -emit-llvm -S switch1.c -o switch1.ll
// ./llc ../../../exemplos/switch1.ll -march=newtarget -relocation-model=static -filetype=obj

