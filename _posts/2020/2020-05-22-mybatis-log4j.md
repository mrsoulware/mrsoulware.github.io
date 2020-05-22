---
title: MyBatis에 Log4j를 명시적으로 지정하기
categories:
  - Development Environment
tags:
  - MyBatis
  - Log4j
  - Log4j2
---

MyBatis를 사용하여 개발하다보면 실제 실행된 SQL등을 확인하기 위해 로그를 설정하여 사용하는 경우가 많다.

그런데, Log4j에 MyBatis의 설정을 아무리 해봐도 로그 파일이 생성되지 않는다거나, 혹은 잘되던 것이 어느날부터 갑자기 안된다는 이야기를 종종 듣곤 한다.
이러한 경우에 MyBatis가 혹시 다른 로그 구현체를 바라보고 있는것이 아닌지 의심해 볼 필요가 있다.

예를 들어, 많은 종류의 라이브러리와 어플리케이션들이 실행시 Commons Logging (commons-logging-1.2.jar)을 요구한다.
그래서, 해당 파일을 클래스패스에 포함하면 그 순간 MyBatis는 Log4j가 아닌 Commons Logging을 구현체로 선택하게 된다.

# 구현체 우선 순위

다음은 MyBatis의 `org.apache.ibatis.logging.LogFactory` 소스의 일부분이다. (MyBatis 3.4.6 기준)

```java
  static {
    tryImplementation(new Runnable() {
      @Override
      public void run() {
        useSlf4jLogging();
      }
    });
    tryImplementation(new Runnable() {
      @Override
      public void run() {
        useCommonsLogging();
      }
    });
    tryImplementation(new Runnable() {
      @Override
      public void run() {
        useLog4J2Logging();
      }
    });
    tryImplementation(new Runnable() {
      @Override
      public void run() {
        useLog4JLogging();
      }
    });
    tryImplementation(new Runnable() {
      @Override
      public void run() {
        useJdkLogging();
      }
    });
    tryImplementation(new Runnable() {
      @Override
      public void run() {
        useNoLogging();
      }
    });
  }
```
MyBatis는 로그 구현체가 존재하는지 위와 같이 차례대로 확인하고, 첫번째로 찾은 구현체를 선택하여 사용한다.
즉, 로그 구현체의 우선순위를 정리하면 다음과 같다.

1. SLF4J
2. Apache Commons Logging
3. Log4j 2
4. Log4j
5. JDK logging

**참고** : 사실 우선순위가 중요한 것은 아니다.
MyBatis의 우선순위 때문에 여러분의 소스코드를 수정할 수는 없지 않은가?
하지만 이제 문제가 발생하게 된 원인은 파악할 수 있게 되었다.
{: .notice--info}

# 소스 코드에서 명시적 지정

방법은 여러분이 먼저 아래 메소드 중 하나를 실행하는 것이다.

```
LogFactory.useCustomLogging(Class<? extends Log> clazz);
LogFactory.useSlf4jLogging();
LogFactory.useCommonsLogging();
LogFactory.useLog4JLogging();
LogFactory.useLog4J2Logging();
LogFactory.useJdkLogging();
LogFactory.useStdOutLogging();
LogFactory.useNoLogging();
```

**잠깐** : 이미 로그 구현체가 선택이 되어 있는 상태에서도 위 메소드를 호출하면 해당 구현체로 변경될 것이다.
하지만, 가급적이면 MyBatis의 다른 메소드가 호출되기 전 초기에 호출하여 설정하는 것이 좋을 것이다.
{: .notice--warning}

이 메소드들 중 `useCustomLogging()`가 있는데, 정해진 로그 구현체가 아닌 직접 구현체를 만든 경우에 사용할 수 있는 메소드이다.
직접 로그 구현체를 개발할 경우에는 `org.apache.ibatis.logging.Log` 인터페이스를 implements 해야 한다.
Log 인터페이스에서 구현해야 할 메소드는 다음과 같다.

```java
public interface Log {
  boolean isDebugEnabled();
  boolean isTraceEnabled();
  void error(String s, Throwable e);
  void error(String s);
  void debug(String s);
  void trace(String s);
  void warn(String s);
}
```

# 설정 파일에서 명시적 지정

MyBatis에서는 설정 파일(mybatis-config.xml)에서 로그 구현체를 지정하는 방법도 제공한다.

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
  <settings>
    <setting name="logImpl" value="LOG4J2"/>
  </settings>
...
</configuration>
```

위 예제는 **Apache Log4j 2**를 사용하기 위해 **LOG4J2**라고 지정하였다.
지정할 수 있는 코드값은 다음과 같다.
* SLF4J
* LOG4J
* LOG4J2
* JDK_LOGGING
* COMMONS_LOGGING
* STDOUT_LOGGING
* NO_LOGGING

위에 나열한 코드값 외에도 클래스명을 직접 지정할 수도 있다.
예를 들어, **com.mycomp.log.MyLog**라는 클래스를 지정할 수 있다.
물론, 해당 클래스는 org.apache.ibatis.logging.Log를 implements 한 것이어야 한다.
