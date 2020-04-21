---
title: RSA 암호화 알고리즘 (4)
categories:
  - algorithm
tags:
  - RSA
toc: true
classes: wide
---

RSA 알고리즘에서는 키를 생성하기 위한 첫번째 단계가 임의의 소수 p,q를 정하는 것이다.
그러므로, 랜덤하게 생성한 임의의 수가 소수인지 판단할 수 있는 방법이 필요한 것이다.

소수(prime number)의 정의는 "1과 자기 자신만으로 나누어 떨어지는 1보다 큰 양의 정수" 이다.
즉, 양의 정수 p가 소수인지 판단하기 위해서는 2부터 √p 까지 나누어 보면 된다.
또한, 특정 범위(e.g. 2~100)의 수에서 소수의 집합을 구하기 위해서는 에라토스테네스의 체(sieve of Erathosthenes)라는 방법을 사용하면 효율적으로 찾는 것이 가능하다.
이것은 합성수(composite number)를 체로 거르듯이 제거하여 최종적으로 남은 수가 소수라고 판단하는 방법이다.

이 방법들 모두 정확하게 소수를 판단할 수 있지만, 2^1024 와 같이 큰 수를 판단하기에는 너무 많은 계산이 필요하다.
예를 들어 2^1024는 16진수로 표기하면 다음과 같다. RSA는 이 정도의 큰 수를 다룬다.

```
0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
```

# 페르마의 소정리 (Fermat's little theorem)

소수는 다음과 같은 성질을 가지고 있다.

```
p가 소수이며 a에 의해 나누어 떨어지지 않을 경우 다음식이 성립한다.
(a ^ (n - 1)) mod p = 1
```

위 페르마 소정리에서 역관계는 성립하지 않는다. 즉, 위 조건을 만족한다고 해서 항상 소수임을 보장하지 않는다.
예를 들어 561은 합성수이지만 위의 나머지 계산을 만족한다. 이러한 수를 카마이클 수(Carmichael number) 또는 절대 유사 소수(absoulte pseudoprime)라고 한다.
{: .notice--warning}


예를 들어, n = 5 일 경우 다음이 성립한다.

```
a = 1 인 경우
(1 ^ (5 - 1)) mod 5 = 1

a = 2 인 경우
(2 ^ (5 - 1)) mod 5 = 1

a = 3 인 경우
(3 ^ (5 - 1)) mod 5 = 1

a = 4 인 경우
(4 ^ (5 - 1)) mod 5 = 1

```

이와 같이 임의 a값을 통해 식을 만족하는지 테스트하여 소수일 가능성이 높다고 판단한 수를 아마도 소수(Probable prime)라고 한다.
이러한 테스트를 페르마 테스트라고 하며 많은 경우의 a를 확인할 수록 소수일 가능성은 더욱 높아진다.

# 소스코드

다음은 구현소스이다.

여기서 a를 선택할 경우 일반적으로 1과 n - 1은 제외하였다. (1 < a < n - 1)

a = 1 인 경우는 모든 수에 항상 성립하고, n - 1 인 경우는 홀수인 경우에 항상 성립하기 때문에 테스트의 의미가 없기 때문이다.

```c
#include <stdio.h>
#include <stdlib.h>

#define TRUE  1
#define FALSE 0

int
modular_exp(int base, int exp, int mod)
{
    // 생략 : 이전 포스트에서 정의하였다.
}

int
is_prime(int n, int k)
{  
    if (n < 2) {   
        return FALSE; 
    } else if (n == 2 || n == 3) {
        return TRUE; 
    }   

    int a, i;

    for (i = 0; i < k; i++) {
        a = 2 + rand() % (n - 3); 
        if (n % a == 0) {
            return FALSE;
        }   
        if (modular_exp(a, n - 1, n) != 1) {   
            return FALSE;
        }   
    }   
    return TRUE;
}

int
main(int argc, char **argv)
{
    int n = atoi(argv[1]);
    int k = atoi(argv[2]); // 테스트 횟수

    if (is_prime(n, k)) {
        printf("%d 는 아마도 소수일 것이다.\n", n);
    } else {
        printf("%d 는 합성수이다.\n", n);
    }
    return 0;
}
```
```
$ ./isprime 19 3
19 는 아마도 소수일 것이다.
$ ./isprime 39 3
39 는 합성수이다.
```

실제 RSA에서는 페르마 테스트를 개선한 밀러-라빈(Miller-Rabin) 테스트를 사용한다.
밀러-라빈 소수판별법에서 n이 합성수임에도, 아마도 소수일 것이라고 판별할 확률은 최대 4^(-k)이다.
(k는 테스트 횟수이다.)
{: .notice--info}