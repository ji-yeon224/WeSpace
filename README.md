<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/808f89b0-38a0-4352-b65a-25c842d09d42" width="20%"/>

# 💬 WeSpace

### 미리보기
<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/1025bec5-04f2-4cff-9d77-c21842e05671" width="100%"/>


## 🗓️ 프로젝트
- 개인 프로젝트
- 2024.01.02 ~ 2024.02.19 (7주)
- 최소 지원 버전 iOS 16.0
</br>

## ✏️ 한 줄 소개
- 같은 관심사를 공유하는 사용자 간 소통할 수 있는 메신저 어플리케이션
</br>

## 💻 기술 스택
- `ReactorKit`
- `RxSwift`, `RxCocoa`, `RxDataSource`, `RxGesture`
- `Firebase Cloud Messaging`, `iamPort`, `KakaoOpenSDK` 
- `SoketIO`, `Moya`, `Kingfisher`, `Realm`, `Codable`
- `WebKit`, `UIKit`, `SnapKit`, `Then`, `AutoLayout`
- `DiffableDataSource`, `CompostionalLayout`
- `AnyFormatKit`, `SideMenu`, `IQKeyboardManager`, `Toast`
</br>

## 📖 프로젝트 목표
- 애플 로그인, 카카오 로그인으로 **소셜 로그인** 기능 추가
- `ReactorKit`을 활용하여 단방향 흐름으로 코드 구조화
- `SocketIO`를 통해 실시간 채팅 기능 구현
- `FCM` 기능을 추가하여 채널 또는 디엠 채팅방 알림 실시간 수신
- `iamPort`서비스를 추가하여 앱 내 인앱결제 기능 구현
</br>

## 🔎 주요 기능
### ✔️ 회원 가입 및 로그인
<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/006d9b85-4b3d-4ef2-bd2c-c98bbc75c141" width="100%"/>

- 애플 로그인 및 카카오 로그인으로 소셜 로그인을 사용할 수 있다.
- 이메일 회원가입 시 입력 값에 대한 유효성 및 조건 검증 로직을 통과한 후 회원가입을 완료한다.

### ✔️ 워크스페이스

<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/844a1918-6974-41c8-8716-9e0b28c26eb8" width="100%"/>

- 메인 화면에서 사용자의 채널 채팅 목록과 Dm 목록을 조회한다.
- `NSDiffableDataSourceSectionSnapshot`을 통해 하나의 섹션 내에서 계층적 구조를 가질 수 있도록 하여 섹션 별 토글이 가능하도록 구현하였다.
- 워크스페이스 관리자 여부에 따라 편집 및 삭제 권한이 주어진다.
- 워크스페이스를 나갈 때 워크스페이스 관리자 여부와 채널 관리자 여부를 확인한 후 퇴장 로직을 수행한다.

### ✔️ 채널, DM
<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/a24dce9e-f986-49dc-8acd-83882759185d" width="100%"/>

- `Realm`을 사용하여 과거 채팅 내역과 이미지 파일을 로컬에 저장하여 비효율적인 네트워크 통신 수를 줄였다.
- DB에 마지막으로 저장된 날짜 데이터를 Cursor 값으로 서버에 요청하여 읽지 않은 메세지를 서버에게 응답받는다.
-  채팅 방 진입 후 `SocketIO`를 통해 소켓 연결을 하여 실시간 채팅 기능을 구현하였고, 해당 화면을 나가거나 앱 종료 또는 백그라운드 모드로 전환 될 경우 소켓 연결을 해제하여 불필요한 서버 호출을 방지하였다.



### ✔️ Push Notification
<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/cd5a3916-2d44-4304-8b2f-29dd9d5dce0a" width="21%"/>
<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/5901d6dd-937c-498b-a3d2-2daa35527d11" width="22%"/>
<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/e264ebfb-c2c6-431f-bb7e-1e5855661752" width="22%"/>

- `Firebase Cloud Messaging` 서비스를 활용하여 실시간으로 채팅 Push Notification을 수신할 수 있다.
- 푸시 알림 탭 시 수신받은 데이터를 디코딩하여 해당 채팅방으로 화면을 이동하도록 구현하였다.


### ✔️ 프로필 및 인앱결제
<img src = "https://github.com/ji-yeon224/WeSpace/assets/69784492/7717e5fc-f2a0-475e-bc34-ad8d33d3e298" width="60%"/>

- 프로필 사진, 닉네임, 연락처를 수정할 수 있다.
- 포트원을 웹뷰 기반으로 연동하여 인앱 결제를 구현하였다. 결제 영수증을 통해 서버에 유효성 체크 후 구매한 코인을 반영한다.

</br>

## 🚨 트러블 슈팅

### ✔️ DB 조회 및 네트워크 통신 비동기 이슈
- 채팅 목록 및 안읽은 메세지 개수 데이터 요청을 위해 DB 접근과 여러 번의 서버 통신을 구현하면서 모든 작업이 완료되기 전에 데이터가 리턴되어 안읽은 개수 데이터가 누락된 채로 뷰에 채널 목록이 보여지는 문제가 발생하였다.
- 여러 번의 서버 통신으로 여러 번의 비동기 작업이 수행되어 작업 완료 시점을 체크하지 못하여 발생하였다. 
- `DispatchGroup`을 통해 여러 개의 비동기 작업을 그룹화하고, 모든 작업이 완료되었음을 notify로 체크하여 데이터를 한 번에 리턴하도록 구현하였다.

``` swift
// HomeReactor.swift
private func requestUnreadCnt(data: [(Channel, String?)]) -> Observable<[Channel]> {
    return Observable.create { observer in
        let group = DispatchGroup()
        var channelItems: [Channel] = []

        data.forEach {
            var channel = $0.0
            let last = $0.1
            group.enter() 
            DispatchQueue.main.async {
                self.reqeustUnreadChannel(wsId: channel.workspaceID, name: channel.name, after: last) { unreadCount in
                    channel.unread = unreadCount ?? 0
                    channelItems.append(channel)
                    group.leave()
                }
            }
        }

        group.notify(queue: DispatchQueue.main) {
            observer.onNext(channelItems)
            observer.onCompleted()
        }

        return Disposables.create()
    }
}
```


```swift 
// HomeReactor.swift
private func reqeustUnreadChannel(wsId: Int, name: String, after: String?, completion: @escaping ((Int?) -> Void)) {
        
    ChannelsAPIManager.shared.request(api: .unreads(wsId: wsId, name: name, after: after ?? nil), responseType: UnreadChannelCntResDTO.self)
        .asObservable()
        .subscribe(with: self) { owner, result in
            switch result {
            case .success(let response):
                cnt = response?.count ?? 0
                completion(cnt)
                
            case .failure(let error):
                completion(nil)
            }
        }
        .disposed(by: disposeBag)
}
```

</br>

### ✔️ 채팅 이미지 로컬 저장 및 조회 시점 이슈
- 네트워크 통신 수를 줄이기 위해 이미지를 로컬에 저장하도록 구현하였는데, 여러 장의 이미지를 로컬에 저장한 후 이미지 이름을 DB에 저장하려고 할 때, 이미지 다운로드 과정이 비동기로 동작하면서 이미지 이름이 DB에 저장되지 않는 문제가 발생하였다. 
- 모든 이미지 저장을 완료한 시점을 기다린 후 DB에 저장하여 뷰에 이미지를 띄울 때 로컬에서 접근하도록 하는 것은 데이터가 많을 수록 속도가 느려질 수 있다는 문제가 있다.
- 때문에 저장 전에 정해둔 규칙에 맞는 이름을 미리 생성하여 저장하고, 이미지 저장은 비동기로 동작하도록 하여 사용자에게 보여줄 때 로컬에 이미지가 있으면 로컬에서, 없다면 Kingfisher를 사용하여 다운로드하는 방식으로 구현하였다.

```swift 
private func saveChatItems(wsId: Int, data: ChannelDTO, chat: [ChannelMessage]) -> [ChannelMessage] {
    
    let recordList = chat.map {
        let urls: [String] = $0.files.map { url in
        // 이미지 이름 먼저 저장
            ImageFileService.getFileName(type: .channel(wsId: wsId, channelId: data.channelId), fileURL: url)
        }
        saveImage(id: wsId, channelId: $0.channelID, files: $0.files, chatId: $0.chatID, fileNames: urls)
        let record = $0.toRecord()
        record.setImgUrls(urls: urls)
        return record
    }
    do {
        try channelRepository.updateChatItems(data: data, chat: recordList)
        
        debugPrint("[SAVE CHAT ITEMS SUCCESS]")
        return recordList.map { $0.toDomain() }
    } catch {
        print(error.localizedDescription)
        return chat
    }
}
```
</br>

### ✔️ 소켓 통신 종료 시점
- 실시간으로 채팅을 수행하기 위해 채팅 화면에 들어가있는 시점에는 소켓을 연결하고, 화면을 나갈 경우에는 연결을 종료해야 하기 때문에 viewWillAppear()와 viewDidDisappear()시점에 연결과 해제를 하였지만, 채팅 화면에서 앱을 나가게 되었을 경우에는 소켓이 종료되지 않는 문제가 발생하였다.
- SceneDelegate에서 sceneDidDisconnect()와 sceneDidEnterBackground() 시점에 소켓 연결을 해제하고, 백그라운드 모드에 있다가 다시 채팅 화면으로 돌아올 경우 재연결을 위해 sceneDidBecomeActive() 시점에 소켓을 다시 연결하도록 구현하였다.

``` swift
// SceneDelegate.swift
func sceneDidDisconnect(_ scene: UIScene) {
		if SocketNetworkManager.shared.isConnected {
        SocketNetworkManager.shared.disconnect()
    }
}

func sceneDidBecomeActive(_ scene: UIScene) {
		// 중단된게 있다면 다시 연결
    SocketNetworkManager.shared.reconnect()
}

func sceneDidEnterBackground(_ scene: UIScene) {
    // 연결된게 있다면 중단
    SocketNetworkManager.shared.pauseConnect()
}
```

```swift 
// SocketNetworkManager.swift

var flag: Bool = false // true -> 잠시 중단
func pauseConnect() {
    if isConnected && !flag {
        disconnect()
        flag = true
    }
}
func reconnect() {
    if flag {
        connect()
        flag = false
    }
}
```
- 백그라운드 모드 시 소켓 연결을 해제할 때 다시 포그라운드로 돌아와 소켓에 재연결을 해야할 경우를 체크하기 위해 flag값을 설정하였다.

## ✍🏻 회고
- 이번 프로젝트에 ReactorKit 프레임워크를 사용해 보았다. 이전에 MVVM + Input-Output 패턴과 다르게 데이터가 단방향으로만 흐르도록 구조화가 되어 있기 때문에 처음에는 구조를 익히고 익숙해지는데 시간이 좀 걸렸다. 익숙해지고 나니 많은 로직들이 작성되어 있어도 구조화되어 있기 때문에 가독성이 높아지고, 유지 보수하기 쉬운 코드를 작성할 수 있게 되었다.
- 본격적인 서버와의 작업으로 FCM과 인앱결제 구현을 경험하게 되었다. 아임포트 라이브러리로 포트원 서비스를 연동하고, 실 결제와 영수증 유효성 검증 로직 플로우를 경험해볼 수 있어서 좋았다.
- FCM 서비스를 활용하여 서버로부터 실시간으로 채팅 알림을 받아볼 수 있도록 구현하였다. 푸시 알림 탭 시 해당 채팅방으로 이동하도록 구현하면서 Coordinator 패턴 적용의 필요성을 느끼게 되었다. 여러 조건에 따라 화면 이동하도록 구현하며 화면 이동 로직이 ViewController에 완전히 의존하고 있다는 것을 깨달았고, ViewController 외부에서 화면 전환 로직을 구현하는 것이 필요하다는 것을 느꼈다.
- 이 프로젝트를 하면서 기획, 서버, 디자인이 제공되고, 오로지 iOS 개발만 담당하면 된다는 점에서 실제 업무 환경과 비슷한 경험을 해볼 수 있었다. 이 프로젝트로 비동기 작업 처리에 대한 중요성을 느끼게 되었다. 많은 네트워크 통신을 연결하며 비동기 작업을 처리하는 것이 가장 어렵게 느껴졌다. GCD와 Swift Concurrency에 대해 더 공부하여 이후에 비동기 작업을 수월하게 처리할 수 있도록 해야겠다.
