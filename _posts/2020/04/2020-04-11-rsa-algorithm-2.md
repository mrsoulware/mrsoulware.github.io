---
title: RSA 암호화 알고리즘 (2)
tags: RSA
toc: true
---

# 거듭제곱의 나머지 구하기

## 규칙1

```
(A * B) mod m = ((A mod m) * (B mod m)) mod m
```

```
(7 * 8) mod 5
 = ((7 mod 5) * (8 mod 5)) mod 5
 = (2 * 3) mod 5
 = 6 mod 5
 = 1
최종결과 : 1
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
n = 0 인 경우에 직접 계산하여 1이 나온다.
(7 ^ (2 ^ 0)) mod 9 = 7 mod 9 = 7

위 결과값을 X라고 하면 다음이 성립한다.
(7 ^ (2 ^ 1)) mod 9 = (X * X) mod 9
  = (7 * 7) mod 9 = 4

다시 위 결과값을 X라고 하면 다음도 성립한다.
(7 ^ (2 ^ 2)) mod 9 = (X * X) mod 9
  = (4 * 4) mod 9 = 7
```

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
A, B, C, D 값을 구하여 위에 대입하면 결과를 구할 수 있다.

그러면 A~D값은 어떻게 구해야 할까? 이제 규칙3이 필요하다.

규칙3에 의해 순서대로 다음값을 구할수 있다.
```
(5 ^ (2 ^ 0)) mod 19 = 25 mod 19 = 6
(5 ^ (2 ^ 1)) mod 19 = (6 * 6) mod 19 = 17
(5 ^ (2 ^ 2)) mod 19 = (17 * 17) mod 19 = 4
(5 ^ (2 ^ 3)) mod 19 = (4 * 4) mod 19 = 16
(5 ^ (2 ^ 4)) mod 19 = (16 * 16) mod 19 = 9
```
다음과 같이 A~D 값을 모두 구하였다.
```
A = (5 ^ 1) mod 19 = 6
B = (5 ^ 2) mod 19 = 17
C = (5 ^ 8) mod 19 = 16
D = (5 ^ 16) mod 19 = 9
```

```
A = 6, B = 17, C = 16, D = 9 를 아래 과정에 대입해보자.

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
