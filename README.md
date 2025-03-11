# HiddenGems 팀
---

## ⏲️ 개발 기간 
- 2025.03.06(목) ~ 2025.03.10(월)
- 2025.03.11(화) 발표
---  
## 🧑‍🤝‍🧑 개발자 소개 
- 김동영, 최시온, 이민서, 양덕성
---
## 💻 개발환경
- **Language** : Dart
- **Framework** : Flutter
- **Backend** : Firebase (Authentication, Firestore, Storage)
- **Push Notification** : OneSignal
- **Payment** : Stripe

---
## 📌 앱 화면 및 주요 기능
**로그인 및 회원가입**
- 카카오, 구글, 이메일로 로그인 및 회원가입
- 프로필 사진과 닉네임 설정

**홈 화면**
- 실시간 진행중인 경매
- **좋아요가 많은 순**으로 5개의 작품
- 인기 작가들의 프로필
 
**작품 페이지**
- 저장된 모든 작품들을 보여줌
    - 작품을 통해 **경매 참여, 경매 시작**, 경매 페이지로 이동
- 작품 이름으로 작품 검색 기능
- 판매중인 작품만 필터링 기능
 
**경매 페이지**
- 저장된 모든 경매들을 보여줌
    - 참여중인 **입찰자 목록, 가격 제시, 경매 종료**
- 작품 이름으로 경매 검색 기능
- 진행 중인 경매만 필터링 기능

**작가 페이지**
- 작품이 있는 모든 작가들을 보여줌
- 작가 이름으로 작가 검색 기능
- 작가 상세 페이지에서 **작가 구독 기능**

**마이 페이지**
- 좋아요한 작품 보기, 구독한 작가 보기, 등록한 작품 보기, 참여중인 경매 보기
- **낙찰 내역 보기** : 배송지 입력 후 결제
- 프로필 편집 : 사용자 프로필 사진과 닉네임 변경

**알람 기능**
- **플랫폼**: OneSignal 활용
    - 좋아요 누른 작품의 경매 시작 시 해당 사용자들에게 알림 제공
    - 입찰한 작품의 낙찰자가 된 경우 해당 사용자에게 알림 발송

**결제 기능**
- Stripe 결제 서비스를 이용한 테스트 모드 결제
      
---
## Model

**AppUser**  
\- id  
\- signupDate  
\- profileURL  
\- nickName  
\- myLikeScore  
\- [myWorks] : 사용자가 등록한 작품들  
\- myWorksCount  
\- [likedWorks] : 사용자가 좋아요한 작품들  
\- [biddingWorks] : 사용자가 입찰중인 경매들  
\- [beDeliveryWorks] : 배송지 입력 예정 작품들  
\- [completeWorks] : 낙찰 내역  
\- [subscribeUsers] : 사용자가 구독중인 작품들  
  
**Work**  
\- id  
\- artistID : 작품을 생성한 작가의 아이디  
\- artistNickName  
\- selling : 작품 판매 여부  
\- title  
\- description  
\- createDate  
\- workPhotoURL  
\- minPrice  
\- [likedUsers] : 작품의 좋아요를 누른 사용자들  
\- likedCount  
\- doAuction : 경매 진행 여부  
  
**AuctionWork**  
\- workId : 경매의 해당 작품의 아이디  
\- workTitle  
\- artistId : 경매의 해당 작품의 해당 작가의 아이디  
\- artistNickname  
\- [auctionUserId] : 경매에 참여중인 사용자들의 아이디  
\- minPrice  
\- endDate  
\- nowPrice : 현재가  
\- auctionComplete : 경매 종료 여부  
\- lastBidderId : 현재가를 제시한 사용자의 아이디  
  
**AuctionedWork**  
\- id  
\- workId  
\- workTitle  
\- artistId  
\- artistNickname  
\- completeUserId : 낙찰자의 아이디  
\- completePrice : 낙찰 금액  
\- address  
\- name  
\- phone  
\- deliverComplete : 배송 완료 여부  
\- deliverRequest  

## Entity 관계 설명
* User ↔ Auction (Many-to-Many, 한 사용자가 여러 경매에 참여, 하나의 경매에 여러 사용자가 참여)
* User ↔ Work (One-to-Many 관계, 한 사용자가 여러 작품을 등록)
* User ↔ AuctionedWork (One-to-Many, 한 사용자가 여러 낙찰된 작품을 가짐)

---

## 👀 회고
### 📚 배운 점
- **firebase 연동과 flutter 개발**에 더 명확한 이해를 할 수 있었다.
- **팀워크**의 중요성을 배웠다.
- **수업에서 배웠던 것들**을 직접 프로젝트에 적용하면서 더 깊이 이해할 수 있는 기회가 되었다.
- **OneSignal**을 활용하여 **푸시 알림**을 구현하는 방법을 배웠다.
- **Podfile 오류를 해결**하는 방법을 익혔다.

### 👍 잘한 점
- 피그마를 사용하여 개발 시작은 늦춰졌지만 결론적으로 **UI 개선에 많은 시간을 들이지 않았다.**
- **유저 모델을 빠르게 구현**한 것이 이후 데이터 관련 작업도 자연스럽게 속도를 낼 수 있었다.
- **기획과 UI 구성을 동시에 진행**하여 작업 효율을 높였다.

### 😅 아쉬운 점
- 지난 프로젝트보다 많았던 **시간을 효율적으로 관리**하지 못했다.
- 시간이 부족했던 탓인지 코드의 **구조적인 설계가 다소 부족**
    - 빠르게 개발하는 데 집중하다 보니 최적화보다는 기능 구현에 초점을 맞췄고, 이는 유지보수 측면에서 다소 아쉬운 부분으로 남았다.
- **OneSignal ID 관리**가 미흡했고, **중복된 로직**을 재사용하지 못했다.
- **데이터 모델**을 개선하여 **중복 데이터**를 줄일 필요가 있다.

### 😅 깨달은 점
- **모델링 완성 후 개발**을 시작하니 개발 도중 큰 문제를 마주하지 않을 수 있었다
- 프로젝트가 예상보다 커 팀원들이 고생을 많이 하였다.
- **커뮤니케이션**의 중요성을 다시 한 번 깨달았다. 좋은 개발자는 코드만 잘 짜는 것이 아니라, 팀원들과의 협업을 잘하는 사람이라는 것을 느꼈다.
- **공식 문서**를 적극적으로 활용하는 것이 중요하다는 것을 깨달았다.
- 원활한 협업을 위해 **팀원 간 소통**이 필수적이라는 것을 느꼈다.