---
title: RSA 암호화 알고리즘 (3)
categories:
  - algorithm
tags:
  - RSA
toc: true
---

[RSA 암호화 알고리즘 (1)](/algorithm/rsa-algorithm-1) 포스트의 4단계에서 다음 조건을 만족하는 e값을 구해야 했다.

```
1 < e < 6
e는 6와 서로소
```
위에서 두개의 수가 서로소라는 것은 최대공약수가 1임을 뜻한다.
다시 말하자면 2,3,4,5 중 6과 최대공약수가 1인 것을 찾아야 하는 것이다.

이 숫자들 중 4일 경우를 가정해 보자.
다음과 같이 4와 6를 소인수 분해한다.

```
4 = 2 ^ 2
6 = 2 * 3
```

최대공약수가 2이므로 4는 조건에 만족하지 않는다는 것을 알 수 있다.

하지만, 4나 6과 같이 작은 수의 소인수 분해와 달리 매우 큰수의 소인수 분해는 상당한 계산량을 필요로 한다.
소인수 분해를 하지 않고 빠르게 최대공약수를 계산하기 위해 사용하는 것이 유클리드 알고리즘(Euclidean algorithm)이다.

# 유클리드 알고리즘

X1와 X2의 최대공약수는 다음과 같은 과정을 반복하여 나머지가 0이 나올때까지 반복하여 구할 수 있다.

```
X1 mod X2 = X3
┌──────┘┌────┘
X2 mod X3 = X4
┌──────┘┌────┘
X3 mod X4 = X5
...
Xm mod Xn = 0

최대공약수는 Xn
```

위 과정을 4와 6을 예시로 해보자.
```
6 mod 4 = 2
4 mod 2 = 0

최대공약수는 2
```

조금더 큰 숫자로 다시 해보자.

```
224 mod 160 = 64
160 mod 64  = 32
 64 mod 32  = 0

최대공약수는 32
```

# 소스코드

위 과정은 두가지 방식(반복루프,재귀호출)으로 간단히 구현된다.

```c
#include <stdio.h>
#include <stdlib.h>

int
gcd(int x, int y)
{
    int remain;

    do {
        remain = x % y;
        x = y;
        y = remain;
    } while (remain != 0);

    return x;
}

int
gcd_recur(int x, int y)
{
    int remain = x % y;

    if (remain == 0) {
        return y;
    }
    return gcd_recur(y, remain);
}

int
main(int argc, char **argv)
{
    int x = atoi(argv[1]);
    int y = atoi(argv[2]);
    printf("GCD(%d, %d) = %d\n", x, y, gcd(x, y));
    printf("GCD_RECUR(%d, %d) = %d\n", x, y, gcd_recur(x, y));
    return 0;
}
```

```
$ ./test_gcd 224 160
GCD(224, 160) = 32
GCD_RECUR(224, 160) = 32
```

