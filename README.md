# Project_5 팀
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
    - 

### 👍 잘한 점
    - 

### 😅 아쉬운 점
    - 

### 😅 깨달은 점
    - 
