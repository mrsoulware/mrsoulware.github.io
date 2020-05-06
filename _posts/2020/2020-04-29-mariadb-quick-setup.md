---
title: MariaDB 간단 설치 및 Database 생성
categories:
  - Development Environment
tags:
  - MariaDB
  - CentOS
---

개발 환경에 사용하기 위한 아주 간단하고 일반적인 MariaDB의 설치 및 기본 설정 과정을 알아보자.
전체 과정은 CentOS 7에서 MariaDB v5.5 설치를 기준으로 한다.

# 기본 설치

MariaDB는 다음과 같이 간단히 설치된다.

```
$ yum install mariadb-server -y
```

운영체제 부팅시 자동으로 MariaDB가 기동되길 원한다면 다음과 같이 활성화한다.

```
$ systemctl enable mariadb
```

이제 MariaDB를 기동해 보자.

```
$ systemctl start mariadb
```

초기의 취약한 보안 설정을 강화하기 위하여 `mysql_secure_installation`을 실행한다.
대부분 기본값으로 입력하는 것을 추천한다. (그냥 엔터만 누르면 된다.)
현재 패스워드(current password)를 물어보는 부분에서도 당황하지 말고 그냥 엔터를 누른다.
단, 신규 패스워드는 입력하도록 한다.

```
$ mysql_secure_installation
...
Enter current password for root (enter for none): 
...
Set root password? [Y/n]
New password:
Re-enter new password:
...
Remove anonymous users? [Y/n]
...
Disallow root login remotely? [Y/n]
...
Remove test database and access to it? [Y/n]
...
Reload privilege tables now? [Y/n]
...
Thanks for using MariaDB!
```

# 데이터베이스와 사용자 생성

## 관리자로 로그인

클라이언트 프로그램 `mysql`을 실행하여, MariaDB의 관리자 계정인 root로 로그인한다.
패스워드는 `mysql_secure_installation` 과정에서 입력한 값이다.

```
$ mysql -u root -p
Enter password:
...
MariaDB [(none)]> 
```

## 데이터베이스 생성

`mydb`라는 명칭으로 데이터베이스를 생성하는 명령이다.

```sql
MariaDB [(none)]> create database mydb default character set utf8 collate utf8_bin;
```

`default character set utf8` 는 기본 문자셋을 utf8로 지정하겠다는 의미이고, `collate utf8_bin`은 문자를 다루는 방식을 지정하는 부분이다.

참고로, `collate utf8_unicode_ci`라는 옵션도 가능한데, 이 옵션으로 지정시 문자열의 비교나 정렬시에 추가적인 프로세스가 수행된다.
예를 들면, `select * from user where id = 'ABC'`와 `select * from user where id = 'aBc'`의 결과가 동일한다.
즉, 대소문자를 구분하지 않는다.
또한 정렬시 단순한 문자 코드값 비교가 아닌, 별도로 정의된 기준 데이터 집합을 참조하여 조금더 사용자 친화적인 정렬을 수행한다.
국제화를 고려한 정확한 정렬이 필요하다면 유용하다.

`collate utf8_general_ci`옵션도 있는데 `collate utf8_unicode_ci`보다 조금덜 정확하고 조금더 빠른 방식이다.

취향에 따라 사용이 가능하겠지만, 대부분의 경우에 `collate utf8_bin`이 무난한 설정이 될것이고 속도 또한 빠르다.

## 사용자 생성

위에서 만든 데이터베이스에 접속하여 사용할 수 있는 사용자 계정을 만들어 보자.

```sql
MariaDB [(none)]> create user 'testuser'@'%' identified by 'mypassword';
MariaDB [(none)]> create user 'testuser'@'localhost' identified by 'mypassword';
MariaDB [(none)]> grant all privileges on mydb.* to 'testuser'@'%';
MariaDB [(none)]> grant all privileges on mydb.* to 'testuser'@'localhost';
MariaDB [(none)]> exit
Bye
```

위 예제에서는 모든 원격지에서 접속 가능한 사용자를 만들었으며, mydb에 전체 권한을 부여하였다.
만약 특정 IP에서만 접속이 가능하도록 하려면, `localhost`대신 IP를 지정하면 된다.

## 테스트

이제 데이터베이스와 사용자를 생성하였으니 테이블을 만들고 데이터 추가 및 조회를 해보자.

```
$ mysql -u testuser -p mydb
Enter password:
...
MariaDB [mydb]>
```

```sql
MariaDB [mydb]> create table sample (
    -> name varchar(3),
    -> age int(3) unsigned );
...
MariaDB [mydb]> insert into sample values ('lee', 21);
...
MariaDB [mydb]> select * from sample;
+------+------+
| name | age  |
+------+------+
| lee  |   21 |
+------+------+
1 row in set (0.00 sec)

MariaDB [mydb]>
```

여기까지 정상적으로 수행되었으면, 최소한의 설정은 완료된 것이다.

# 추가 설정

## strict mode 활성화

우선 예제부터 살펴보자.

```sql
MariaDB [mydb]> desc sample;
+-------+-----------------+------+-----+---------+-------+
| Field | Type            | Null | Key | Default | Extra |
+-------+-----------------+------+-----+---------+-------+
| name  | varchar(3)      | YES  |     | NULL    |       |
| age   | int(3) unsigned | YES  |     | NULL    |       |
+-------+-----------------+------+-----+---------+-------+
2 rows in set (0.00 sec)

MariaDB [mydb]> insert into sample values ('park', 1000);
...
MariaDB [mydb]> insert into sample values ('hong', -1);
...
MariaDB [mydb]> select * from sample;
+------+------+
| name | age  |
+------+------+
| par  | 1000 |
| hon  |    0 |
+------+------+
2 rows in set (0.00 sec)

MariaDB [mydb]> 
```

테이블에 정의된 컬럼의 범위를 넘어가는 경우 MariaDB는 에러없이 입력되며 일부 데이터는 변경된다.
문자열은 길이에 맞게 자동으로 잘라서 들어가며, 숫자는 자리수가 넘어가더라도 그대로 입력된다.
심지어 unsigned 조건에 맞지 않는 -1은 0으로 바꿔서 입력된다.

아마도 성능 향상을 위해 데이터 유효성 체크를 하지 않는 것으로 추측되나, 개발 중인 프로그램의 버그를 오랫동안 감추는 나쁜 영향을 줄 것이다.

다음과 같이 설정을 변경하고 재시작하여 데이터 체크 기능을 활성화시킬 수 있다.

```bash
$ vi /etc/my.cnf
[mysqld]
...
sql_mode="NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES"
...
```

변경한 설정이 반영되도록 재시작한다.

```
$ systemctl restart mariadb
```

정상적으로 설정되었는지 확인해보자.

```sql
MariaDB [mydb]> show variables like 'sql_mode';
+---------------+--------------------------------------------+
| Variable_name | Value                                      |
+---------------+--------------------------------------------+
| sql_mode      | STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION |
+---------------+--------------------------------------------+
1 row in set (0.00 sec)
```

이제 데이터 유효성 체크가 정상적으로 작동한다.

```sql
MariaDB [mydb]> insert into sample values ('park', 1000);
ERROR 1406 (22001): Data too long for column 'name' at row 1
MariaDB [mydb]> insert into sample values ('hong', -1);
ERROR 1406 (22001): Data too long for column 'name' at row 1
```

**참고** : v5.7부터는 기본 설정이므로 별도로 변경할 필요가 없다.
{: .notice--info}


## 테이블명 대소문자 구분

오라클과 같은 데이터베이스에서는 테이블명의 대소문자를 구분하지 않지만, MariaDB에서 구분한다.
이것은 테이블명이 그대로 파일로 만들어지기 때문이다.

해결방법은 무조건 소문자로 변환하는 과정을 거치도록 하는 것이다.
다음과 같이 설정값을 변경하고 재시작하면 적용된다.

```bash
$ vi /etc/my.cnf
[mysqld]
...
lower_case_table_names=1
...
```
**주의** : 이미 생성된 테이블은 적용되지 않으므로 rename하거나 재생성한다.
{: .notice--warning}

```
- show variables like 'lower_case_table_names'; 로 확인해서 0이면 대소문자 구분하는 것
```

## 방화벽 설정

외부 서버에서 접속을 하기 위해서는 방화벽에서 서비스 포트(TCP:3306)를 개방하자.

```
$ firewall-cmd --permanent --add-port=3306/tcp
$ firewall-cmd --reload
```
