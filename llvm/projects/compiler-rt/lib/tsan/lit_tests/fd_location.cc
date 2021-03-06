// RUN: %clangxx_tsan -O1 %s -o %t && %t 2>&1 | FileCheck %s
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

int fds[2];

void *Thread1(void *x) {
  write(fds[1], "a", 1);
  return NULL;
}

void *Thread2(void *x) {
  sleep(1);
  close(fds[0]);
  close(fds[1]);
  return NULL;
}

int main() {
  pipe(fds);
  pthread_t t[2];
  pthread_create(&t[0], NULL, Thread1, NULL);
  pthread_create(&t[1], NULL, Thread2, NULL);
  pthread_join(t[0], NULL);
  pthread_join(t[1], NULL);
}

// CHECK: WARNING: ThreadSanitizer: data race
// CHECK:   Location is file descriptor {{[0-9]+}} created by main thread at:
// CHECK:     #0 pipe
// CHECK:     #1 main

