---
title: pthread memory
categories:
  - multithread programming
tags: pthread pmap
---


# 소스 코드

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <pthread.h>
    #include <unistd.h>
    
    void *
    thread_start(void *arg)
    {
        char buf[102400];
        memset(buf, 0, sizeof(buf));
    
        strcpy(buf, "Hello,world!");
        printf("%s", "Thread End\n");
    
        return NULL;
    }
    
    int
    main(int argc, char **argv)
    {
        pthread_t thread[100];
    
        printf("pid = %d\n", getpid());
    
        int i, cnt;
        cnt = atoi(argv[1]);
        for (i = 0; i < cnt; i++) {
            pthread_create(&thread[i], NULL, thread_start, NULL);
            sleep(1);
        }
    
        pause();
    
        return 0;
    }


# 메모리 분석

스레드를 생성하지 않은 프로세스의 메모리

    $ pmap -p 5252
    5252:   ./threadtest 0
    0000000000400000      4K r-x-- /home/sircoon/threadtest/threadtest
    0000000000600000      4K r---- /home/sircoon/threadtest/threadtest
    0000000000601000      4K rw--- /home/sircoon/threadtest/threadtest
    00007f1ad3df5000   1804K r-x-- /usr/lib64/libc-2.17.so
    00007f1ad3fb8000   2048K ----- /usr/lib64/libc-2.17.so
    00007f1ad41b8000     16K r---- /usr/lib64/libc-2.17.so
    00007f1ad41bc000      8K rw--- /usr/lib64/libc-2.17.so
    00007f1ad41be000     20K rw---   [ anon ]
    00007f1ad41c3000     92K r-x-- /usr/lib64/libpthread-2.17.so
    00007f1ad41da000   2044K ----- /usr/lib64/libpthread-2.17.so
    00007f1ad43d9000      4K r---- /usr/lib64/libpthread-2.17.so
    00007f1ad43da000      4K rw--- /usr/lib64/libpthread-2.17.so
    00007f1ad43db000     16K rw---   [ anon ]
    00007f1ad43df000    136K r-x-- /usr/lib64/ld-2.17.so
    00007f1ad45f5000     12K rw---   [ anon ]
    00007f1ad45fe000      8K rw---   [ anon ]
    00007f1ad4600000      4K r---- /usr/lib64/ld-2.17.so
    00007f1ad4601000      4K rw--- /usr/lib64/ld-2.17.so
    00007f1ad4602000      4K rw---   [ anon ]
    00007fff0cec6000    132K rw---   [ stack ]
    00007fff0cf32000      8K r-x--   [ anon ]
    ffffffffff600000      4K r-x--   [ anon ]
     total             6380K

스레드를 생성한 프로세스의 메모리

    $ pmap -p 5253
    5253:   ./threadtest 1
    0000000000400000      4K r-x-- /home/sircoon/threadtest/threadtest
    0000000000600000      4K r---- /home/sircoon/threadtest/threadtest
    0000000000601000      4K rw--- /home/sircoon/threadtest/threadtest
    0000000002480000    132K rw---   [ anon ]
    00007f37cbe2a000      4K -----   [ anon ]
    00007f37cbe2b000   8192K rw---   [ anon ]
    00007f37cc62b000   1804K r-x-- /usr/lib64/libc-2.17.so
    00007f37cc7ee000   2048K ----- /usr/lib64/libc-2.17.so
    00007f37cc9ee000     16K r---- /usr/lib64/libc-2.17.so
    00007f37cc9f2000      8K rw--- /usr/lib64/libc-2.17.so
    00007f37cc9f4000     20K rw---   [ anon ]
    00007f37cc9f9000     92K r-x-- /usr/lib64/libpthread-2.17.so
    00007f37cca10000   2044K ----- /usr/lib64/libpthread-2.17.so
    00007f37ccc0f000      4K r---- /usr/lib64/libpthread-2.17.so
    00007f37ccc10000      4K rw--- /usr/lib64/libpthread-2.17.so
    00007f37ccc11000     16K rw---   [ anon ]
    00007f37ccc15000    136K r-x-- /usr/lib64/ld-2.17.so
    00007f37cce2b000     12K rw---   [ anon ]
    00007f37cce34000      8K rw---   [ anon ]
    00007f37cce36000      4K r---- /usr/lib64/ld-2.17.so
    00007f37cce37000      4K rw--- /usr/lib64/ld-2.17.so
    00007f37cce38000      4K rw---   [ anon ]
    00007fffc9713000    132K rw---   [ stack ]
    00007fffc979f000      8K r-x--   [ anon ]
    ffffffffff600000      4K r-x--   [ anon ]
     total            14708K

의심스러운 메모리 영역

    0000000002480000    132K rw---   [ anon ]
    00007f37cbe2a000      4K -----   [ anon ]
    00007f37cbe2b000   8192K rw---   [ anon ]

메모리 범위 찾아보기

    $ cat /proc/5253/maps
    00400000-00401000 r-xp 00000000 fd:02 128582                             /home/sircoon/threadtest/threadtest
    00600000-00601000 r--p 00000000 fd:02 128582                             /home/sircoon/threadtest/threadtest
    00601000-00602000 rw-p 00001000 fd:02 128582                             /home/sircoon/threadtest/threadtest
    02480000-024a1000 rw-p 00000000 00:00 0                                  [heap]
    7f37cbe2a000-7f37cbe2b000 ---p 00000000 00:00 0 
    7f37cbe2b000-7f37cc62b000 rw-p 00000000 00:00 0 
    7f37cc62b000-7f37cc7ee000 r-xp 00000000 fd:00 33572293                   /usr/lib64/libc-2.17.so
    7f37cc7ee000-7f37cc9ee000 ---p 001c3000 fd:00 33572293                   /usr/lib64/libc-2.17.so
    7f37cc9ee000-7f37cc9f2000 r--p 001c3000 fd:00 33572293                   /usr/lib64/libc-2.17.so
    7f37cc9f2000-7f37cc9f4000 rw-p 001c7000 fd:00 33572293                   /usr/lib64/libc-2.17.so
    7f37cc9f4000-7f37cc9f9000 rw-p 00000000 00:00 0 
    7f37cc9f9000-7f37cca10000 r-xp 00000000 fd:00 33556294                   /usr/lib64/libpthread-2.17.so
    7f37cca10000-7f37ccc0f000 ---p 00017000 fd:00 33556294                   /usr/lib64/libpthread-2.17.so
    7f37ccc0f000-7f37ccc10000 r--p 00016000 fd:00 33556294                   /usr/lib64/libpthread-2.17.so
    7f37ccc10000-7f37ccc11000 rw-p 00017000 fd:00 33556294                   /usr/lib64/libpthread-2.17.so
    7f37ccc11000-7f37ccc15000 rw-p 00000000 00:00 0 
    7f37ccc15000-7f37ccc37000 r-xp 00000000 fd:00 33565929                   /usr/lib64/ld-2.17.so
    7f37cce2b000-7f37cce2e000 rw-p 00000000 00:00 0 
    7f37cce34000-7f37cce36000 rw-p 00000000 00:00 0 
    7f37cce36000-7f37cce37000 r--p 00021000 fd:00 33565929                   /usr/lib64/ld-2.17.so
    7f37cce37000-7f37cce38000 rw-p 00022000 fd:00 33565929                   /usr/lib64/ld-2.17.so
    7f37cce38000-7f37cce39000 rw-p 00000000 00:00 0 
    7fffc9713000-7fffc9734000 rw-p 00000000 00:00 0                          [stack]
    7fffc979f000-7fffc97a1000 r-xp 00000000 00:00 0                          [vdso]
    ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
    
    
    02480000-024a1000 rw-p 00000000 00:00 0                                  [heap]
    7f37cbe2a000-7f37cbe2b000 ---p 00000000 00:00 0 
    7f37cbe2b000-7f37cc62b000 rw-p 00000000 00:00 0 
    
GDB를 통해 메모리 덤프
    
    $ gdb -p 5253
    (gdb) dump memory 1.dmp 0x2480000      0x24a1000
    (gdb) dump memory 2.dmp 0x7f37cbe2a000 0x7f37cbe2b000
    (gdb) dump memory 3.dmp 0x7f37cbe2b000 0x7f37cc62b000

문자열 검색
    
    $ strings 1.dmp
    $ strings 2.dmp
    $ strings 3.dmp
    Hello,wo
    %%%%%%%%%%%%%%%%
    Hello,world!
    Thread End
    pid =

