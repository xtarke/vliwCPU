#!bash

llc_bin=../../../../Trabalhos/llvm/Debug+Asserts+Checks/bin/llc

for file in *.c; do
   echo compiling file $file
   file_llvm="${file%.*}.ll"
   
   echo $filename
   clang -emit-llvm -S $file -o $file_llvm
   
   echo assembling $file
   $llc_bin $file_llvm -march=newtarget -relocation-model=static -filetype=obj
   $llc_bin $file_llvm -march=newtarget -relocation-model=static
done


