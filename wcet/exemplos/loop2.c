

int main(){

	int ii = 0;
	int j = 10;

	while(j-- > 0){
		ii++;
	}	 

	return 0;
}
/*
 * NewTarget
 # BB#0:
        addiu   $sp, $sp, -16
        addiu   $1, $zero, 0 #??????? otimização peephole no mips, ok
        sw      $1, 12($sp)
        sw      $1, 8($sp)
        addiu   $1, $zero, 10
        sw      $1, 4($sp)
        j       $BB0_1
$BB0_2:                                 #   in Loop: Header=BB0_1 Depth=1
        lw      $1, 8($sp)
        addiu   $1, $1, 1
        sw      $1, 8($sp)
$BB0_1:                                 # =>This Inner Loop Header: Depth=1
        lw      $1, 4($sp)
        addiu   $2, $1, -1
        sw      $2, 4($sp)
        cmplti  $p1, $1, 1
        brf     $p1, $BB0_2

Mips
# BB#0:
        addiu   $sp, $sp, -16
        sw      $zero, 12($sp)
        sw      $zero, 8($sp)
        addiu   $1, $zero, 10
        j       $BB0_2
        sw      $1, 4($sp)
$BB0_1:                                 #   in Loop: Header=BB0_2 Depth=1
        lw      $1, 8($sp)
        addiu   $1, $1, 1
        sw      $1, 8($sp)
$BB0_2:                                 # =>This Inner Loop Header: Depth=1
        lw      $1, 4($sp)
        addiu   $2, $1, -1
        slti    $1, $1, 1
        beq     $1, $zero, $BB0_1
        sw      $2, 4($sp)

 */ 
