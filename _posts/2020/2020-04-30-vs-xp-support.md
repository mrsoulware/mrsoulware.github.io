---
title: Windows XP용 바이너리 빌드 방법
categories:
  - Development Environment
tags:
  - Visual Studio
---

Visual Studio C/C++로 개발한 소스를 빌드하여 만든 바이너리 파일이 Windows XP에서 실행되지 않는 경우가 있다.
이유는 Windows의 바이너리 파일 형식이 Windows XP 이후에 변경되었기 때문이다.
이후 운영체제에서 구버전 파일 형식의 실행을 지원해 주었기 때문에, 개발자가 아닌 대부분의 사용자는 그러한 변화를 감지하지 못했을 것이다.

지금 시대에 무슨 Windows XP 얘기를 하느냐고 생각할 수도 있는데, 이 문제는 Windows Server 2003 에서도 동일하게 발생한다.
PC와 달리 서버 운영체제는 기업 내부의 폐쇄망에서 사용되는 경우가 많기 때문에 특별히 문제가 없으면 업그레이드 하지 않고 사용하기도 한다.
미국 공군의 ICBM을 제어하는 컴퓨터가 1970년대에 만들어진 것이고 저장 장치는 230KB 용량의 8인치 FDD라고 하지 않는가.

# Windows XP 지원 설치

기본 옵션으로 Visual Studio를 설치하면 XP용 바이너리 파일을 만들수 없다.
Visual Studio Installer를 실행하여 다음 화면과 같이 **C++용 윈도우즈 XP 지원**을 추가로 설치해야 한다.
Visual Studio 2017 기준인데, 필자가 설치해보니 무료 버전인 Visual Studio Community에서는 해당 지원이 없는 것으로 보였다.

![](/assets/images/vs-xp-support.png)

# 커맨드라인에서 빌드

GUI에서는 간단하게 해당 프로젝트 속성의 플랫폼 도구 집합 속성을 Windows XP 도구 집합으로 설정하면 된다.
커맨드라인(Command line) 방식으로 빌드하는 경우에는 명령 프롬프트를 실행하고 다음과 같은 명령을 실행해주어야 한다.

**32비트 바이너리 생성용**
```bat
@rem set-env-xp32.bat

"%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvars32.bat"

if "%INCLUDE%" == "" (
    set INCLUDE=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Include
) else (
    set INCLUDE=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Include;%INCLUDE%
)
if "%PATH%" == "" (
    set PATH=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Bin
) else (
    set PATH=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Bin;%PATH%
)
if "%LIB%" == "" (
    set LIB=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Lib
) else (
    set LIB=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Lib;%LIB%
)
if "%CL%" == "" (
    set CL=/D_USING_V110_SDK71_
) else (
    set CL=/D_USING_V110_SDK71_;%CL%
)
if "%LINK%" == "" (
    set LINK=/SUBSYSTEM:CONSOLE,5.01
) else (
    set LINK=/SUBSYSTEM:CONSOLE,5.01 %LINK%
)
```

**64비트 바이너리 생성용**
```bat
@rem set-env-xp64.bat

"%ProgramFiles(x86)%\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsx86_amd64.bat"

if "%INCLUDE%" == "" (
    set INCLUDE=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Include
) else (
    set INCLUDE=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Include;%INCLUDE%
)
if "%PATH%" == "" (
    set PATH=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Bin
) else (
    set PATH=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Bin;%PATH%
)
if "%LIB%" == "" (
    set LIB=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Lib\x64
) else (
    set LIB=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Lib\x64;%LIB%
)
if "%CL%" == "" (
    set CL=/D_USING_V110_SDK71_
) else (
    set CL=/D_USING_V110_SDK71_;%CL%
)
if "%LINK%" == "" (
    set LINK=/SUBSYSTEM:CONSOLE,5.02
) else (
    set LINK=/SUBSYSTEM:CONSOLE,5.02 %LINK%
)
```

명령 프롬프트를 새로 실행할 때마다 수행해 줘야 하므로 배치 파일로 저장해두고 사용하는 것이 편리할 것이다.
