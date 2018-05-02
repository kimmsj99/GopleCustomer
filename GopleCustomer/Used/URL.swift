//
//  URL.swift
//  GopleComp
//
//  Created by 김민주 on 2017. 11. 10..
//  Copyright © 2017년 김민주. All rights reserved.
//

import Foundation


public let domain           = "http://gople.ghsoft.kr"      //도메인

public let newUserInfoURL   = "/index/base/getMemberData"   //최신 유저 정보

//MARK: - Login
public let loginURL         = "/index/base/checkLoginData"    //로그인
public let loginSuccessURL  = "/index/base/setLoginTrace"     //로그인 성공 시

//MARK: - Join
public let certifiNumURL    = "/index/base/actionSMS"           //전화번호 인증번호 전송
public let joinURL          = "/index/base/setSignupData"       //회원가입
public let checkListURL     = "/index/base/getDefaultCheckList" //체크리스트 기본값

//MARK: - TabBar
public let homeURL          = "/index/main/home"                //Home
public let newsURL          = "/index/content/news_lists"       //고플 소식
public let saleURL          = "/index/content/discount"         //고플 할인혜택
public let bookmarkURL      = "/index/bookmark/view"            //예약
public let wishURL          = "/index/bookmark/wish"            //찜

public let mapURL           = "/index/data/map"                 //지도
public let searchURL        = "/index/data/search"              //검색
public let searchWeddingURL = "/index/data/search/1"            //웨딩플래너 -> 검색
public let searchSaleURL    = "/index/data/search/2"            //할인혜택 -> 검색

public let imgUpladURL      = "/index/data/setFileUpload"       //이미지 업로드
public let shareURL         = "/index/base/share"               //링크 공유
public let comDetailURL     = "/index/data/detail"              //업체 상세보기

//MARK: - My Page
public let setMarriageURL   = "/index/mypage/setMarriageUpdate" //결혼예정일 수정
public let setPhoneURL      = "/index/mypage/setPhoneUpdate"    //전화번호 수정
public let scheduleURL      = "/index/bookmark/schedule"        //캘린더
public let getCheckListURL  = "/index/mypage/getCheckList"      //체크리스트 데이터 가져오기
public let setCheckListURL  = "/index/mypage/setCheckList"      //체크리스트 데이터 저장
public let suggestURL       = "/index/mypage/suggest"           //추천인 보기
public let noticeURL        = "/index/mypage/notice"            //공지사항
public let alertURL         = "/index/base/setAlertUpdate"      //알림설정
public let serviceURL       = "/index/mypage/service"           //서비스 이용약관
public let privacyURL       = "/index/mypage/privacy"           //개인정보 처리 방침
public let locationURL      = "/index/mypage/location"          //위치기반 서비스 동의서
public let logoutURL        = "/index/base/logout"              //로그아웃
public let logout2URL       = "/index/mypage/logout"            //로그아웃
public let withdrawalURL    = "/index/base/setMemberDelete"     //회원탈퇴
public let withdrawal2URL   = "/index/mypage/leave"             //회원탈퇴
