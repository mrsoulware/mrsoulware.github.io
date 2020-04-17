---
title: RSA 암호화 알고리즘 (2)
categories:
  - algorithm
tags:
  - RSA
toc: true
---

이전 포스트 예제의 7단계에서는 `(5 ^ 11) mod 14` 와 같은 연산을 하는 과정이 있었다.
하지만, `(5 ^ 100) mod 14`과 같은 경우라면 `5 ^ 100`을 먼저 계산한 후 일반적인 변수형에는 담을수 조차 없을 것이다.

해결법은 식을 분해하여 작은 범위의 수로 별도 계산하고, 별도 계산된 값을 병합하는 방법이다.
지금부터 거듭제곱의 몇가지 규칙을 알아보고, 해당 규칙들을 적용하여 값을 구해보도록 하자.

# 거듭제곱의 나머지 구하기

## 규칙1

```
(A * B) mod m = ((A mod m) * (B mod m)) mod m
```

다음은 위 규칙을 이용한 예시이다.

```
(7 * 8) mod 5
 = ((7 mod 5) * (8 mod 5)) mod 5
 = (2 * 3) mod 5
 = 6 mod 5
 = 1
```

## 규칙2

```
RZ = (A * B * C * ... Z) mod m

RA = (1  * (A mod m)) mod m
RB = (RA * (B mod m)) mod m
RC = (RB * (C mod m)) mod m
...
RZ = (RY * (Z mod m)) mod m
```

`(2 * 7 * 8) mod 5`를 예를 들어 보면 다음과 같다.

```
RA = (1 * (2 mod 5)) mod 5 = 2
RB = (2 * (7 mod 5)) mod 5 = 4
RC = (4 * (8 mod 5)) mod 5 = 2
최종결과 : 2
```

## 규칙3

```
(b ^ (2 ^ n)) mod m
위 결과값을 X라고 하면 다음이 성립한다.

(b ^ (2 ^ (n + 1))) mod m = (X * X) mod m
```

`b = 7, m = 9`일때 예를 살펴보자.

```
2 ^ 0 인 경우에는 직접 계산한다.
(7 ^ (2 ^ 0)) mod 9 = 7 mod 9 = 7

위 결과값을 X라고 하면 2 ^ 1 인 경우는 다음이 성립한다.
(7 ^ (2 ^ 1)) mod 9 = (X * X) mod 9
  = (7 * 7) mod 9 = 4

다시 위 결과값을 X라고 하면 역시 2 ^ 2 인 경우도 성립한다.
(7 ^ (2 ^ 2)) mod 9 = (X * X) mod 9
  = (4 * 4) mod 9 = 7
```

n = 0 인 경우에만 직접 계산하고, 나머지는 이전 값을 이용하여 연쇄적으로 구할 수 있다.

## Right-to-left 바이너리 메소드

`5 ^ 27 mod 19`를 예로 들어 값을 구해보자.

27은 이진수로 ‭11011‬ 이며, `2^0 + 2^1 + 2^3 + 2^4 = 1 + 2 + 8 + 16`로 표현된다.

즉, `5 ^ 27 mod 19` 은 다음과 같이 변형할 수 있다.

```
`5 ^ 27 mod 19`
 = ( 5 ^ (1 + 2 + 8 + 16) ) mod 19
 = ( (5 ^ 1) * (5 ^ 2) * (5 ^ 8) * (5 ^ 16) ) mod 19
```

다시, `( (5 ^ 1) * (5 ^ 2) * (5 ^ 8) * (5 ^ 16) ) mod 19`는 규칙1을 적용하면 다음과 같다.

```
( (5 ^ 1) * (5 ^ 2) * (5 ^ 8) * (5 ^ 16) ) mod 19
 = ( ((5 ^ 1) mod 19) * ((5 ^ 2) mod 19) * ((5 ^ 8) mod 19) * ((5 ^ 16) mod 19) ) mod 19
```

다음과 같이 A, B, C, D 를 다음과 같이 정의하고, 위의 식에 치환하여 보자.

```
A = (5 ^ 1) mod 19
B = (5 ^ 2) mod 19
C = (5 ^ 8) mod 19
D = (5 ^ 16) mod 19

( ((5 ^ 1) mod 19) * ((5 ^ 2) mod 19) * ((5 ^ 8) mod 19) * ((5 ^ 16) mod 19) ) mod 19
 = ( A * B * C * D ) mod 19
```

이제 규칙2을 사용할 시점이 왔다.

```
RD = ( A * B * C * D ) mod 19

RA = (1  * (A mod 19)) mod 19
RB = (RA * (B mod 19)) mod 19
RC = (RB * (C mod 19)) mod 19
RD = (RC * (D mod 19)) mod 19
```

이제 A, B, C, D 값만 구하면, 위 결과에 대입하여 최종값을 계산할 수 있다.

그러면 A~D값은 어떻게 구해야 할까? 먼저, 규칙3에 의해 순서대로 다음값을 구할수 있다.

```
(5 ^ (2 ^ 0)) mod 19 = 25 mod 19 = 6
(5 ^ (2 ^ 1)) mod 19 = (6 * 6) mod 19 = 17
(5 ^ (2 ^ 2)) mod 19 = (17 * 17) mod 19 = 4
(5 ^ (2 ^ 3)) mod 19 = (4 * 4) mod 19 = 16
(5 ^ (2 ^ 4)) mod 19 = (16 * 16) mod 19 = 9
```

다음과 같이 A~D를 위한 값이 위 결과에 모두 있다.

```
A = (5 ^ 1) mod 19 = 6
B = (5 ^ 2) mod 19 = 17
C = (5 ^ 8) mod 19 = 16
D = (5 ^ 16) mod 19 = 9
```

27의 2진수인 11011의 3번째 비트가 0이다. 그래서, 3번째것은 쓰이지 않고 있다.
{: .notice--info}

이제 A = 6, B = 17, C = 16, D = 9 를 아래 과정에 대입해보자.

```
RA = (1  * (A mod 19)) mod 19
RB = (RA * (B mod 19)) mod 19
RC = (RB * (C mod 19)) mod 19
RD = (RC * (D mod 19)) mod 19

RA = (1  * (6 mod 19)) mod 19 = 6
RB = (6 * (17 mod 19)) mod 19 = 7
RC = (7 * (16 mod 19)) mod 19 = 17
RD = (17 * (9 mod 19)) mod 19 = 1
```
`5 ^ 27 mod 19`의 최종 결과는 `1`이 나왔다.

## 소스코드

위 과정을 구현한 소스이다. 단, 배열을 사용하지 않고 하나의 반복문안에서 두가지 과정(A~D 구하기와 A~D 대입하기)을 동시에 수행하도록 구현되어 있다.

```c
#include <stdio.h>
#include <stdlib.h>

int
modular_exp(int base, int exp, int mod)
{
    // mod값은 (mod - 1)^2 연산시 오버플로우 되지 않을만큼 작다고 가정
    
    int result = 1;

    if (mod == 1) {
        return 0;
    }

    base = base % mod;
    while (exp > 0) {
        if (exp & 0x1) {
            result = (result * base) % mod;
        }
        exp = exp >> 1;
        base = (base * base) % mod;
    }
    return result;
}

int
main(int argc, char **argv) {

    int base = atoi(argv[1]);
    int exp = atoi(argv[2]);
    int mod = atoi(argv[3]);
    int remain = modular_exp(base, exp, mod);
    printf("modular_exp(%d, %d, %d) = %d\n", base, exp, mod, remain);
    return 0;
}
```
