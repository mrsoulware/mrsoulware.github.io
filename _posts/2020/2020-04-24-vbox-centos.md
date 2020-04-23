---
title: VirtualBox 와 CentOS 설치하기
categories:
  - 개발환경
tags:
  - CentOS
  - VirtualBox
---
 
리눅스에서 프로그램 개발 등을 하기 위한 용도로 개인 PC에서 VM(가상머신)으로 리눅스를 설치하는 방법을 알아보자.
전체 과정은 윈도우즈 PC에 VirtualBox를 설치하고 VM(Vitual Machine)을 생성한 후 CentOS 리눅스를 설치하는 순서이다.

# VirtualBox 설치

먼저 [https://www.virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads) 에서 VirtualBox 설치 파일을 다운로드 받는다.
해당 페이지의 링크 중 **"Windows hosts"**가 윈도우즈용 설치파일이다.
참고로, 호스트(host) OS는 VirtualBox를 설치하는 OS를 의미한다.
반대로 VirtualBox에 VM를 만들고 설치한 OS는 게스트(guest) OS라고 한다.
이 포스트에서는 윈도우즈 PC가 호스트OS가 되고, 리눅스가 게스트OS가 된다.

다운로드 받은 설치파일을 실행하여 설치를 시작한다.
설치진행 중에 입력값은 대부분 기본값으로 지정하여 설치를 하면 된다.

# VM 생성

먼저, "머신 > 새로 만들기" 메뉴를 실행한다.

![](/assets/images/vbox-cent1.png)

처음 실행시 나타나는 화면은 위와 같은 "가이드 모드" 화면이다.
"가이드 모드"는 단계가 상대적으로 길다.
단계를 단축하기위해 "전문가 모드" 버튼을 누른다.

![](/assets/images/vbox-cent2.png)

VM의 이름과 메모리 크기를 적당히 입력하고 "만들기" 버튼을 누른다.
용도에 따라 차이는 있겠지만 GUI 없이 일반 서버처럼 원격접속하여 사용하는 경우에, 메모리 크기는 1024MB 정도면 불편없이 사용이 가능하다.

![](/assets/images/vbox-cent3.png)

VM의 가상 디스크를 만드는 화면에서는 디스크 크기를 입력하고 역시 "만들기" 버튼을 누른다.
여기서 동적할당은 필요시 확장되는 방식으로, PC 디스크 공간을 처음부터 차지하지 않으니 넉넉히 입력하도록 한다.

![](/assets/images/vbox-cent4.png)

이제 VM 생성이 완료되었다.
하지만 추가적인 설정이 더 필요하다.


지금부터는 네트워크 설정을 해보려고 한다.
먼저, 다음의 구성도를 한번 살펴보자.

![](/assets/images/vm-network.jpg)

그림은 3가지의 네트워크가 존재한다.

"어댑터1"은 VM에서 인터넷으로 접속하기 위한 용도이다.
각종 소프트웨어 설치나 패치를 받기 위해서 필요할 것이다.

"어댑터2"는 PC(VirtualBox를 설치한 Windows)에서 VM에 접속하기 위해 필요하다.
ssh, sftp, http 등 VM에 설치된 각종 서비스에 접속하기 위해 필요하다.

**잠깐** : "어댑터1"를 "어댑터2"의 용도로 사용하는 방법도 있는데, 이 경우 "포트 포워딩" 설정이 필요하다. 포워딩해야 하는 포트가 필요할때마다 하나씩 추가해야 하므로 불편할 수 있으니 권장하지 않겠다.
{: .notice--warning}

"어댑터3"은 동일한 VirtualBox에 설치된 VM들끼리 연결하기 위한 용도이다.
DB서버와 WAS서버 용도로 VM을 각각 만들어 연결하고 싶을 경우가 예가 되겠다.

**잠깐** : "어댑터2"도 이 용도로 사용 가능하지만 역할을 분리해두면 환경 변경시 귀찮은 작업이 줄어든다.
{: .notice--warning}


위 3가지의 네트워크 환경을 설정해 보도록 하자.

![](/assets/images/vbox-cent4.png)

생성한 VM을 선택하고 "설정"을 누른다.

![](/assets/images/vbox-cent5.png)

기본적으로 "어댑터1"은 "네트워크 어댑터 사용하기"가 체크되어 있고 "NAT"로 되어 있을 것이다.
설정값이 다르다면 변경하고 "어댑터2" 탭으로 이동한다.

![](/assets/images/vbox-cent6.png)

"어댑터2"는 "호스트 전용 어댑터"로 변경하고 "네트워크 어댑터 사용하기"를 체크한다.

![](/assets/images/vbox-cent7.png)

"어댑터3"은 "내부 어댑터"로 변경하고 역시 "네트워크 어댑터 사용하기"를 체크한다.

여기까지의 과정을 실제 PC로 비유하면, 원하는 크기의 메모리와 하드디스크를 꼽았고 네트워크 카드(일명 랜카드)도 3개를 붙인후 네트워크 케이블도 각각 연결하였다고 생각하면 되겠다.

# CentOS 설치

이제 CentOS 설치를 시작해 보자. 
[https://www.centos.org/download/](https://www.centos.org/download/) 페이지에서 "CentOS Linux DVD ISO" 파일을 다운로드 받는다.

다운로드가 완료되었으면, 생성한 VM을 선택하고 “설정” 화면을 열어보자.

![](/assets/images/vbox-cent9.png)

저장소를 보면 장치 목록에서 "컨트롤러: IDE" 하위의 "비어 있음"으로 표시되는데 이부분을 클릭한 후, 오른쪽 상단의 광학 드라이브의 가장 오른쪽 "DISK 모양의 아이콘"을 클릭 후 "가상 광 디스크 파일 선택"을 통해 다운로드 받은 ISO 파일을 지정한다. 이제 "비어 있음"은 해당 ISO파일명으로 변경된다. 마치 CD를 PC에 삽입한 것과 같이 된 것이다.

![](/assets/images/vbox-cent10.png)

이제 VM의 전원버튼을 눌러보자. VM 선택 후 "시작" 버튼을 누른다.

![](/assets/images/vbox-cent11.png)

다시 한번, ISO 이미지를 선택하고 "시작" 버튼을 누른다.

**잠깐** : 최근 VirtualBox 버전에 추가된 기능으로 아직 OS가 설치되지 않은 VM을 처음 시작하게 될때 나오는 화면이다.
이미 전단계에서 ISO 파일을 선택하는 과정이 있었는데 구버전의 VirtualBox에서 하는 방식이다.
문제될 것은 없으니 그냥 진행하도록 한다.
{: .notice--warning}

![](/assets/images/vbox-cent12.png)

이제 설치 프로그램이 시작되었다. i키 입력후 엔터키를 누르거나, 방향키로 직접 "Install CentOS Linux 8"를 선택한 후 엔터키를 누르면 된다.

![](/assets/images/vbox-cent13.png)

원하는 언어를 선택하고 "계속 진행" 버튼을 누른다.

![](/assets/images/vbox-cent14.png)

설치 옵션 화면이 나타나는데, 여기서는 "시간 및 날짜", "소프트웨어 선택", "설치 목적지" 3가지를 설정해보겠다.

![](/assets/images/vbox-cent17.png)

"시간 및 날짜"에서는 지역을 변경한다.
지역은 콤보박스에서 선택하거나 지도를 클릭하여 설정할 수도 있다.
변경 후 완료 버튼을 누른다.

![](/assets/images/vbox-cent15.png)

"소프트웨어 선택"에서는 용도에 따른 환경을 선택하여 설치할 소프트웨어의 범위를 정하는 부분이다.
이 글에서는 "최소 설치"를 기준으로 진행하겠다.

**잠깐** : 대부분 자원이 풍부하지 않은 PC에 VirtualBox 상에서 설치하는 VM이다 보니 최대한 가볍게 사용할 수 있도록 메모리도 1GB 정도로 잡고 "최소설치"를 기준으로 진행하게 되었다.
나중에 필요한 소프트웨어는 추가로 설치하면 될것이고 그 과정에서 배우게 되는것도 많을 것이다.
{: .notice--warning}

![](/assets/images/vbox-cent16.png)

"설치 목적지"는 OS를 설치할 디스크와 파티션 등을 구성할 수 있는 화면이다.
그냥 "완료" 버튼을 누르면 자동으로 적정하게 구성된다.

![](/assets/images/vbox-cent18.png)

설치 옵션을 모두 완료하였으면 "설치 시작" 버튼을 누른다.

![](/assets/images/vbox-cent19.png)

설치가 진행되는 과정 중에 Root 암호를 설정하도록 한다.

![](/assets/images/vbox-cent20.png)

설치가 완료되었다.
"재부팅" 버튼을 누르기 전에, 먼저 아래와 같이 저장소에서 설치CD를 꺼내자.
CD를 꺼내지 않으면 재부팅 후 다시 원래의 설치시작 화면으로 돌아갈수도 있을 것이다.

![](/assets/images/vbox-cent21.png)

재부팅이 완료되면 아래와 같이 로그인 화면이 나온다.

![](/assets/images/vbox-cent22.png)

root 로 로그인 해보자.

# 네트워크 활성화

나머지 과정을 편리하게 진행하기 위해, 먼저 어댑터2(ifcfg-enp0s8)를 설정하고 리부팅한다.

```
$ vi /etc/sysconfig/network-scripts/ifcfg-enp0s8
...
BOOTPROTO=none
...
ONBOOT=yes
NETMASK=255.255.255.0
IPADDR=192.168.56.100
```
```
$ reboot
```

IP 192.168.56.100 의 끝자리 100은 다른 숫자로 변경해도 된다.
VM을 추가로 설치할 경우에 겹치지 않도록 IP를 배정한다.

리부팅 후 PC에 설치된 터미널 프로그램(putty 등)으로 ssh(root@192.168.56.100) 접속을 해보자.
지금부터는 터미널프로그램에서 나머지 설정을 진행할 수 있다.
 
어댑터3(ifcfg-enp0s9)를 다음과 같이 설정한다. IP의 끝자리는 일관성을 위해 두번째 어댑터의 설정과 동일(예제 기준 100)하게 하는 것이 좋겠다.
```
$ vi /etc/sysconfig/network-scripts/ifcfg-enp0s9
...
BOOTPROTO=none
...
ONBOOT=yes
NETMASK=255.255.255.0
IPADDR=10.0.0.100
```

어댑터1(ifcfg-enp0s3)을 다음과 같이 설정한다.
```
$ vi /etc/sysconfig/network-scripts/ifcfg-enp0s3
...
BOOTPROTO=dhcp
...
ONBOOT=yes
```
**잠깐** : 어댑터1은 인터넷에 연결하기 위한 것이었다. 
dhcp로 설정하게 되면 IP, DNS, GATEWAY 등 다소 어려울수 있는 설정을 자동으로 잡아준다.
{: .notice--warning}

변경한 설정값을 반영하기 위해 다음 명령을 실행한다.
```
$ systemctl restart network
```

# 기타 설정

**HOSTNAME 변경**

hostname은 다음과 같이 변경할 수 있다. 원하는 명칭으로 변경해 보기 바란다.

```
$ hostnamectl set-hostname mycentos
```

**리눅스 업데이트**

OS를 최신으로 업데이트하고 싶은 경우 다음과 같이 실행합니다. 커널이 패치된 경우에는 리부팅을 실행합니다.

```
$ yum update
$ reboot
```

**스냅샷 생성**

VM이 망가질 경우를 대비하여 복구를 위한 스냅샷을 생성하기를 권장한다.
먼저, 스냅샷 생성전에는 VM을 종료하는 것이 안전하다.

```
$ shutdown now
```

VM이 종료되면 VM 목록의 오른쪽에 위치한 메뉴를 클릭하여 "스냅샷" 관리 화면으로 이동한다.
(원래화면으로 돌아오고 싶으면 같은 메뉴를 클릭하고 "정보"를 선택한다.)

![](/assets/images/vbox-cent23.png)

"현재상태"를 선택하고 찍기 버튼을 눌러 현재 시점의 스냅샷을 만들수 있다.

혹시 VM에 문제가 생겨 해당 시점으로 되돌리고 싶다면 생성한 스냅샷을 선택하고 복원을 실행하면 완벽하게 원복이 가능하다.
VM은 비교적 망가지기 쉬우니 꼭 스냅샷을 만들어 두는게 좋으며, root 권한으로 위험한 작업을 하기 바로 전에 만들어 두면 걱정없이 작업을 할수 있을 것이다.

**기본 머신 폴더 변경**

C드라이브에 공간 여유가 없을 경우, "파일>환경설정>일반" 메뉴에서 기본 머신 폴더를 수정(ex. D:\VboxVM)할 수 있다.

**호스트 네트워크 관리자**

메인 메뉴를 통해 호스트 네트워크 관리자를 실행할 수 있다.
기본적으로 하나가 설정되어 있는데 설정값을 보면 다음과 같다.

* IPv4 주소 : 192.168.56.1
* 서브넷마스크 : 255.255.255.0

이것은 앞에 네트워크 설정에서 어댑터2와 관련되어 있는 부분이다.
설정한 IP의 192.168.56.* 부분이 동일하다는 것을 알수 있다.
만약 이부분에 맞지 않을 경우 제대로 접속할 수 없다.
접속 문제 발생시 확인해보고 차이가 있다면 어댑터 설정을 바꾸거나 호스트 네트워크 부분을 바꾸어 일치시키도록 한다.