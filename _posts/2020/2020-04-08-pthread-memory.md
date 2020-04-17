---
title: posix thread 와 memory 분석
categories:
  - multithread
tags:
  - pthread
  - pmap
toc: true
---

메모리 분석 방법 중 하나를 통해, POSIX 쓰레드에서 신규 쓰레드를 생성시 할당되는 메모리에 대해서 알아보자.

# 소스 코드

아래 소스는 숫자를 인자로 입력받아 해당 개수만큼 쓰레드를 생성하는 간단한 프로그램이다.

```c
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
```

**잠깐:** 일반적으로 쓰레드를 생성한 후 pthread_join()을 호출하지만 이 예제는 의도적으로 생략하였다.
{: .notice--info}

# 메모리 분석

`pmap -p <pid>` 명령을 실행하여 프로세스별 메모리를 살펴보자.

스레드를 생성하지 않은 프로세스의 메모리이다.

```bash
$ pmap -p 5252
5252:   ./threadtest 0
0000000000400000      4K r-x-- /home/sircoon/threadtest/threadtest
0000000000600000      4K r---- /home/sircoon/threadtest/threadtest
0000000000601000      4K rw--- /home/sircoon/threadtest/threadtest
...
ffffffffff600000      4K r-x--   [ anon ]
 total             6380K
```

스레드를 1개 생성한 프로세스의 메모리이다.

```bash
$ pmap -p 5253
5253:   ./threadtest 1
0000000000400000      4K r-x-- /home/sircoon/threadtest/threadtest
0000000000600000      4K r---- /home/sircoon/threadtest/threadtest
0000000000601000      4K rw--- /home/sircoon/threadtest/threadtest
0000000002480000    132K rw---   [ anon ]
00007f37cbe2a000      4K -----   [ anon ]
00007f37cbe2b000   8192K rw---   [ anon ]
...
ffffffffff600000      4K r-x--   [ anon ]
 total            14708K
```

2개를 비교해보면, 스레드를 생성했을 경우에 다음과 같이 추가된 메모리 영역이 존재함을 알수 있다.

```bash
0000000002480000    132K rw---   [ anon ]
00007f37cbe2a000      4K -----   [ anon ]
00007f37cbe2b000   8192K rw---   [ anon ]
```

위 메모리 영역 중 첫번째의 범위는 다음과 같이 계산하여 알수 있다.

0x2480000 + 132K (132 * 1024 = 0x21000) = 0x24a1000

/proc/pid/maps 파일을 보아도 알 수 있다.

```bash
$ cat /proc/5253/maps
...
02480000-024a1000 rw-p 00000000 00:00 0                        [heap]
7f37cbe2a000-7f37cbe2b000 ---p 00000000 00:00 0 
7f37cbe2b000-7f37cc62b000 rw-p 00000000 00:00 0 
...
```

다음과 같이 GDB를 통해 3개 영역의 메모리를 파일로 덤프 받는다.

```bash
$ gdb -p 5253
(gdb) dump memory 1.dmp 0x2480000      0x24a1000
(gdb) dump memory 2.dmp 0x7f37cbe2a000 0x7f37cbe2b000
(gdb) dump memory 3.dmp 0x7f37cbe2b000 0x7f37cc62b000
```

덤프 파일에 어떤 문자열이 있는지 찾아보자.

```bash
$ strings 1.dmp
$ strings 2.dmp
$ strings 3.dmp
Hello,wo
%%%%%%%%%%%%%%%%
Hello,world!
Thread End
pid =
```
3번째 영역에 문자열을 보면 thread_start() 함수안의 내용이 출력되고 있다.

pthread_create() 함수는 별도 쓰레드의 스택을 위한 메모리를 힙에 할당한다.
할당된 메모리는 쓰레드가 종료되더라도 회수되지 않으며, pthread_join()과 같은 함수를 호출하여 자원을 회수해야 한다.
예제 프로그램에서는 회수 과정을 가지지 않았기 때문에 이 메모리가 남아 있게 되는 것이다.

참고로, 할당된 메모리의 크기는 8192K 였다. 이것은 시스템의 기본 stack size와 일치함을 알수 있다.

```bash
$ ulimit -a
...
stack size              (kbytes, -s) 8192
...
```
