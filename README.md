## Asus 공유기 모니터링 시스템 만들기(feat. Synology 918+ & influxdb & grafana)

어제 공유기 모니터링 시스템에 대한 글( https://www.clien.net/service/board/cm_nas/12095038 )을
올려봤는데 나름 반응이 괜찮았던 것 같아 제작 과정을 정리해서 올려봅니다.

ASUS TM-AC1900을 개조한 AC68U 공유기의 CPU, load, memory, 온도, 네트워크 트래픽, 네트워크 에러
등 상황을 1분마다 수집(공유기에서 스크립트로 수집하여 NAS의 influxdb에 저장)하여 이쁘게 그래프로
(NAS에 설치된 grafana가) 그려줍니다.




먼저, 본 작업을 하는데 필요한 것은 다음과 같습니다.

1. ASUS AC68U 공유기 with 멀린펌
- Asus의 다른 기종도 되는지 확인은 못해봤지만 거의 비슷할 것 같습니다.
- 펌웨어는 멀린펌이어야 합니다.(JFFS를 마운트하여 persistent한 저장소로 사용하는 기능이 필요)
- 저 같은 경우는 멀린펌 최신인 384.4_2 버전을 사용중입니다.
    
2. Synology 918+
- 본 강좌 내용을 그대로 따라하시려면 docker 지원 가능한 Synology NAS 기종을 사용
- 제가 참고한 블로그와 같이 NAS가 아닌 별도의 서버가 있어도 가능할 듯 합니다.

    
이제부터 설치 과정 설명을 시작하겠습니다.

0. NAS의 IP 주소는 고정인 것이 좋습니다. 공유기에서 NAS 주소로 데이터를 쏴 줘야 하기 때문에..
- 저는 공유기(192.168.0.1)에서 NAS가 항상 192.168.0.50 주소를 받도록 설정해 뒀습니다.
- 다른 분들도 NAS는 port forwarding 설정을 하기 위해 고정 주소를 사용하고 계실거라 생각합니다.


1. NAS에 docker로 InfluxDB 설치
- InfluxDB는 시계열DB(Time series database)입니다.
- 모니터링 데이터와 같이 동일 타입의 데이터를 시간별로 저장하는데 적합한 데이터베이스라고 하는데
  자세한건 저도 잘 모릅니다.
- 처음 참고했던 글에서 influxdb 쓰고 있어서 그냥 썼습니다. 
  근데 사용하고 있는 버전이 달라서 고생 했습니다.ㅠㅠ

docker 작업은 Web UI에서 하는 것보다 ssh로 접속해서 커맨드로 하는게 편해서 그렇게 했습니다.
sudo -i 해서 root 권한으로 실행하시면 됩니다.

다음과 같이 하면 아주 간단히 influxdb 생성 및 실행이 됩니다.
docker 사용은 ssh 접속해서 root 권한으로 커맨드로 실행하시면 됩니다.

- docker 사용 디렉토리 생성
# mkdir -p /volume1/docker/influxdb/db
# cd /volume1/docker/influxdb

- 설정 파일 생성
# docker run --rm influxdb influxd config > /volume1/docker/influxdb/influxdb.conf

여기까지 하면 /volume1/docker/influxdb/influxdb.conf 설정 파일이 생성됩니다.

- docker 이미지 생성 및 실행
# docker run -d \
      --name=influxdb \
      -p 8086:8086 \
      -v /volume1/docker/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf:ro \
      -v /volume1/docker/influxdb/db:/var/lib/influxdb \
      -e INFLUXDB_ADMIN_ENABLED=true \
      influxdb -config /etc/influxdb/influxdb.conf

influxdb container 생성이 끝났습니다.

다음 명령으로, grafana에서 사용할 DB를 만들어 줍니다.

# curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE grafana_asus"

다음과 같이 결과가 출력되면 influxdb가 잘 동작하는 겁니다.
HTTP/1.1 200 OK
Content-Type: application/json
...
{"results":[{"statement_id":0}]}


2. 역시 NAS에 docker로 grafana 설치 
- Grafana is a free self contained web-based graphing tool for InfluxDB (and other TSDBs).
  라고 합니다. 자세한 설명은 생략...
  
- grafana 설치는 좀더 간단하게 됩니다.
# docker run -d --name=grafana -p 3000:3000 grafana/grafana

- 이렇게 설치한 후 웹브라우저에서 http://192.168.0.50:3000 접속해보면 바로 로그인 창이 나옵니다.
  (NAS의 IP 주소가 다르시다면 그 주소로...)



- 초기 ID/Password는 admin/admin입니다. 접속 후 설정 화면 들어가서 id, password만 미리 바꿔두시면
  됩니다.
- 3000번 포트를 공유기에서 port forwarding 설정해 두면 외부에서도 접속 가능합니다.


3. 공유기에서 정보 수집 스크립트 설치
- 위에서 말씀드린대로 공유기는 Merlin 펌웨어 사용중이어야 합니다. (JFFS 파티션 사용을 위해)
- 먼저 JFFS 파티션 사용을 설정해야 합니다. (관리-시스템 메뉴)



- 예전 버전 Merlin 펌에는 "Enable JFFS partition" 설정도 있었던 모양인데, 현재 최신 버전엔
  존재하지 않고 기본적으로 JFFS 파티션 사용은 가능한 상태였습니다.
- 만약 "Enable JFFS partition" 설정이 있다면 "예"로 설정합니다.
- 나머디 2개의 설정도 "예"로 두고 공유기 리부팅 합니다.
- 리부팅 후 다시 공유기에 ssh로 접근하여 /jffs 디렉토리 아래에 configs, scripts 디렉토리가
  생겼는지 확인합니다.
  
admin@RT-AC68U:/tmp/home/root# ls -l /jffs
drwxr-xr-x 2 admin root 0 Feb 14 2017 /jffs/configs
drwxr-xr-x 3 admin root 0 May 10 11:02 /jffs/scripts
...

- 이제 수집 script를 설치할 준비가 되었습니다.
- 먼저 공유기 내에 /jffs/scripts/routerstats 디렉토리를 생성하고, 첨부한 scripts_20180510.zip 
  파일의 압축을 풀어서 이 디렉토리에 복사합니다.
  (파일 복사는 scp를 쓰시든지 usb를 통해 복사해 넣으시면 됩니다.)
- 스크립트에서 보고하는 정보들에 대한 내용은 나중에 시간 많을 때 좀더 자세히 정리해 보겠습니다.
- todb2.sh 파일을 vi로 열어보시면 4번째 줄에 자료를 저장할 influxdb의 주소를 지정하게 되어 있습니다.
  저는 NAS의 IP가 192.168.0.50이라 다음과 같이 되어 있는데, 다른 주소라면 적절히 수정해 주시면 됩니다.
  
  dbhost="192.168.0.50:8086"
  
- 스크립트를 1분마다 돌리는 cron 작업을 등록해 봅니다.
admin@RT-AC68U:/tmp/home/root# cru a routerstats "* * * * * /jffs/scripts/routerstats/routerstats.sh"

- 다음 명령으로 cron 작업 내역을 확인할 수 있습니다.
admin@RT-AC68U:/tmp/home/root# cru l
* * * * * /jffs/scripts/routerstats/routerstats.sh #routerstats#

- 이제 공유기의 CPU, load, memory, 온도, 네트워크 트래픽, 네트워크 에러 등 지표가 NAS에 설치된 
  influxdb에 1분마다 저장되고 있습니다.

- 그런데 이 cron 작업은 공유기가 재부팅 되면 남아 있지 않습니다.
  그래서, 공유기가 시작할 때 cron 작업을 등록하는 스크립트를 작성해 봅니다.
admin@RT-AC68U:/jffs/scripts# echo '#!/bin/sh' > /jffs/scripts/init-start
admin@RT-AC68U:/jffs/scripts# echo 'cru a routerstats "* * * * * /jffs/scripts/routerstats/routerstats.sh"' >> /jffs/scripts/init-start
admin@RT-AC68U:/jffs/scripts# chmod a+x /jffs/scripts/init-start

- 공유기 재부팅 후 'cru l' 명령으로 cron 작업 등록이 잘 되어 있는지 확인해 봅니다. 
admin@RT-AC68U:/tmp/home/root# cru l
* * * * * /jffs/scripts/routerstats/routerstats.sh #routerstats#


4. grafana 설정
- 웹브라우저로 grafana에 접속합니다. (주소: http://nas_ip:3000)
- 아까 변경해 둔 ID, password로 로그인 합니다.

- Data Source 추가
  화면 왼쪽 4개 아이콘 중 톱니바퀴 모양 아이콘(Configuration)을 누르고 "Data Sources" 설정에
  들어갑니다.
  "Add data source"를 클릭하고, 다음과 같이 설정하고 "Save & Test"를 눌러 저장합니다.


  

- Home - "Import dashboard" - "Upload .json File"하여 첨부한 json 파일을 업로드하여 import합니다.
- 앞에서 influxdb에 데이터가 제대로 쌓이고 있었다면, import된 dashboard에 데이터가 짜잔! 하고
  나타날 겁니다.



여기까지 읽어주셔서 감사합니다.
혹시 잘 안되는 부분은 댓글 남겨주시면 제가 할수 있는 데까진 더 설명해 드리겠습니다.

혹시 제가 수집하여 그린 그래프 외에 추가하면 도움이 될만한 데이터가 있으면 알려주셔도 좋을 것 같습니다.
수집 가능한 리소스이면 추가해 보겠습니다.

감사합니다.
