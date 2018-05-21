cd "lib" && rm -f "libcpu.so.0" && ln -s "libcpu.so.0.0.0" "libcpu.so.0"
cd "lib" && rm -f "libcpu.so" && ln -s "libcpu.so.0.0.0" "libcpu.so"
cd "lib" && rm -f "libcpu.la" && ln -s "../libcpu.la" "libcpu.la"
