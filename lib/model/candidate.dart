class Candidate {
  // 부전승용 특수 ID (실제 데이터와 겹치지 않게 고정 문자열 사용)
  static const String byeId = '__bye__';

  static const Candidate byeCandidate = Candidate(
    id: byeId,
    title: '부전승입니다. 옆 후보를 선택하세요.',
    imageUrl: '', // 화면에서 별도 위젯으로 처리할 것이므로 사용하지 않음
  );

  final String id;
  final String title;
  final String imageUrl;

  const Candidate({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  bool get isBye => id == byeId;
}

List<Candidate> samplesForTopic(String topic) {
  switch (topic) {
    case '아이돌':
      return [
        Candidate(
          id: 'id1',
          title: '카리나 (aespa)',
          imageUrl:
              'https://upload3.inven.co.kr/upload/2024/01/25/bbs/i13635914561.jpg?MW=800',
        ),
        Candidate(
          id: 'id2',
          title: '정국 (BTS)',
          imageUrl:
              'https://cdn.topstarnews.net/news/photo/202309/15391541_1171723_5712.jpg',
        ),
        Candidate(
          id: 'id3',
          title: '아이유',
          imageUrl: 'https://pbs.twimg.com/media/DpKB4DdUcAABpAY.jpg',
        ),
        Candidate(
          id: 'id4',
          title: '리사 (BLACKPINK)',
          imageUrl:
              'https://external-preview.redd.it/blackpinks-lisa-is-ready-to-be-unleashed-v0-TbGZB8mC6K2KyxnkDXaYLkgBaauHFzfp1Uvn8F5uQAI.jpg?width=640&crop=smart&auto=webp&s=bb6f3b02b6605c02229a51ac238d4a0f891c8af1',
        ),
        Candidate(
          id: 'id5',
          title: '차은우',
          imageUrl:
              'https://image.xportsnews.com/contents/images/upload/article/2017/0526/1495782052118543.jpg',
        ),
        Candidate(
          id: 'id6',
          title: '윈터 (aespa)',
          imageUrl: 'https://i.ytimg.com/vi/CoJJHgj-79g/maxresdefault.jpg',
        ),
        Candidate(
          id: 'id7',
          title: '뷔 (BTS)',
          imageUrl:
              'https://cdn.topstarnews.net/news/photo/202203/14678965_773424_3223.jpg',
        ),
        Candidate(
          id: 'id8',
          title: '제니 (BLACKPINK)',
          imageUrl:
              'https://digitalchosun.dizzo.com/site/data/img_dir/2019/02/18/2019021880031_0.jpg',
        ),
        Candidate(
          id: 'id9',
          title: '수지',
          imageUrl:
              'https://file3.instiz.net/data/cached_img/upload/2018/11/27/16/6dba778bea52f5a23da1b688a0ea52b9.jpg',
        ),
      ];

    case '배우':
      return [
        Candidate(
          id: 'a1',
          title: '송강',
          imageUrl:
              'https://i.namu.wiki/i/b7tAomJZ93aTMLzSYho9-Ae7L6KPC0ZlnMkoB8A88tKnpoOPDxSpOlHoRcSFlZl0vUlj4b2R7_HxKHoH1BeZgA.webp',
        ),
        Candidate(
          id: 'a2',
          title: '한소희',
          imageUrl:
              'https://i.namu.wiki/i/Z5T_i_4uWHDDeKzmd8vV1SsaEJ7D4yA7HhLEa52gbLjKVLH3ecdt2WLD_XOE3cPyHz1GdkUw9S_8Z2KSSm9-fA.webp',
        ),
        Candidate(
          id: 'a3',
          title: '박보검',
          imageUrl:
              'https://i.namu.wiki/i/KCEn-6Lut_1gY_Hc3LkT6e1n_2k1yMfUj6xPcdlJnoavRr-3TXof-0x9anDKL0uwnQYZy8eAjYQ7eK_z0H5NYg.webp',
        ),
        Candidate(
          id: 'a4',
          title: '수지',
          imageUrl:
              'https://i.namu.wiki/i/xSdnr1s0K7Tph2CaAIxq3E4zWcBASpnRz16N4R3zH6UxkgKpN0Umu-NnBfeakOQIFoA2W8TgT5f6G0z7kjsz1A.webp',
        ),
        Candidate(
          id: 'a5',
          title: '유아인',
          imageUrl:
              'https://i.namu.wiki/i/2KcYThZtHDy64GZyGD5noKqX0tp7RprQLv3T8gPzK-DIzn95R4nqJk_QSboWTRDUkwrAE_mHk2Y2aXrE7bMT8w.webp',
        ),
        Candidate(
          id: 'a6',
          title: '김태리',
          imageUrl:
              'https://i.namu.wiki/i/Y19pHnUptYV58rG2AR0kxN5Z2PjS8V7ItnVXP2eRcvSKsr-dmch0ZMoM8FJ7DuwEE9J0QbO_J0sR_vNgn4UTnA.webp',
        ),
        Candidate(
          id: 'a7',
          title: '이도현',
          imageUrl:
              'https://i.namu.wiki/i/ig0MNk-VX_cAi6VgSliZnC3QuHWiH7xz9K82c2xg_r2CMg7Q2OaOHYQeHkcdAUMbCJgN5aYyb1BaDvk6FJdy3Q.webp',
        ),
        Candidate(
          id: 'a8',
          title: '정해인',
          imageUrl:
              'https://i.namu.wiki/i/pzUwZdwblPfTZeY9N-DF4GL_0C3GfUKKDu5kCeFfgKkM1oRBx8BGRxwX6uByU3hWHzbmc4R21tkB7vJYvNm54A.webp',
        ),
      ];

    case '가수':
      return [
        Candidate(
          id: 'g1',
          title: '임영웅',
          imageUrl:
              'https://i.namu.wiki/i/lYxDXEkQX1T9ChfhdzrcQcbSLQYWrxq4dnASpVZ8u2Y0RbAc3U3u7oFVU95V7uNghGo4CgxQvDN7nTV5gAZ-MQ.webp',
        ),
        Candidate(
          id: 'g2',
          title: '태연',
          imageUrl:
              'https://i.namu.wiki/i/kMwykmb2qRWidptD92i5iTVqjKM9xZ9nU3iYbX8KkWTgwcTEijRLt8ASeRCceK_CEGROlRnyxqJRmNlyH_0ygQ.webp',
        ),
        Candidate(
          id: 'g3',
          title: '지코',
          imageUrl:
              'https://i.namu.wiki/i/IVMtd82xgb-bZmfxK8pEonGk6W37R3fsbD65r25eFw8f5fX8HleHfA0B8ngRM8lKRa9a3QKxqV8X5S3zBu9xDA.webp',
        ),
        Candidate(
          id: 'g4',
          title: '선미',
          imageUrl:
              'https://i.namu.wiki/i/nk0TgZK45S8Gxq6wNsYtrTXnZo6h8zODUYP0MZV5ScOr0yiPrkhoKy3q8gVFaSEuYh4M9GhDN5ay7cKXDb0Nlw.webp',
        ),
        Candidate(
          id: 'g5',
          title: '딘',
          imageUrl:
              'https://i.namu.wiki/i/RmTe7rN5LzpeyePLS09Pa94Sp4fZKce2rHlg5UqCSdLNhbL-B4RW2bb80ucXyAEGfPbH0XXZCqEKd2vePsu7_Q.webp',
        ),
        Candidate(
          id: 'g6',
          title: '아이유',
          imageUrl:
              'https://i.namu.wiki/i/DApJQyeKh5GDCswYMCyMG-mHULGmC2kBkzQb5rUSRSV7b8gY5lKh8FRFqzOEGVbPKsbZ6rMiTrL7m1DgWUEYcA.webp',
        ),
        Candidate(
          id: 'g7',
          title: '백현',
          imageUrl:
              'https://i.namu.wiki/i/n7m5a7nZpn2JzYqHClfa8vu1ZmJZdpMwmxwcs3UboAAp3VvndAF-7V09snhAQQBfTte1rN1dfILdTgHdud5xDQ.webp',
        ),
        Candidate(
          id: 'g8',
          title: '로제',
          imageUrl:
              'https://i.namu.wiki/i/ZQG8Zx5xZC7kAW7dc2N97_sLhXBgErS5IYF6ErkZDTaswZC4qE67Zu9FlUypzTZgWR_qLBMFSbYZs-Qm1fE_GQ.webp',
        ),
      ];

    case '예능인':
      return [
        Candidate(
          id: 'v1',
          title: '유재석',
          imageUrl:
              'https://i.namu.wiki/i/1suAbCmcbXegq86HuM2Ca6Cmb4mJkMTPpYTeKRuQegzrkcmQFzMHR9An1cFRxYBaEukygb1IJT7lyzB8kaJdAw.webp',
        ),
        Candidate(
          id: 'v2',
          title: '신동엽',
          imageUrl:
              'https://i.namu.wiki/i/hMWqT_0JoBi0XXokFze_d-cqtxR0RbyhhbV49VNGjHQyGE7e39nPhWkoH8HAg6soocUjOMIChWda2qgBmiP7sA.webp',
        ),
        Candidate(
          id: 'v3',
          title: '이경규',
          imageUrl:
              'https://i.namu.wiki/i/TvPpKhEX7PyRTmfR22kVGtUhBdcYvZ2c8HglZbHKb_A1R45eGd7msDR5UHdZmlR_7hdYXZr2T3aDqCrx8eF8OA.webp',
        ),
        Candidate(
          id: 'v4',
          title: '이수근',
          imageUrl:
              'https://i.namu.wiki/i/dwnW9WxzZeU2XJWqA2CyyGX6CGPzqWq3JeLCpHD_8qvfHXZytC3jErwzXZ7QJwzRYxwzRL6vImBqR7viUFvw5A.webp',
        ),
        Candidate(
          id: 'v5',
          title: '김종국',
          imageUrl:
              'https://i.namu.wiki/i/fSjsmH4x98SuMcpT2V4ARqAVU5v6hQZa9nPOZ4a9NR1r3eKJK3pcEonlwbmHR8JVLpPhmwdHBcRj60Tn5T_qxA.webp',
        ),
        Candidate(
          id: 'v6',
          title: '박나래',
          imageUrl:
              'https://i.namu.wiki/i/teQxq0LOU53CnFvddU12Z3SDGVWcqzdlUO2H7bgjSbe1sJ1X63HYh0tR2RrsV7qg4WHzSRHVaAmFrvzogBFR2g.webp',
        ),
        Candidate(
          id: 'v7',
          title: '조세호',
          imageUrl:
              'https://i.namu.wiki/i/bTRRr4KzKNkV9F3yksEBvM3QKZehH4H02XeDsu7NYfsXNhkSEz6pUzEs2ofKn6_kBGt3IoQAFaxQ_dGZk2f-GA.webp',
        ),
        Candidate(
          id: 'v8',
          title: '이광수',
          imageUrl:
              'https://i.namu.wiki/i/FjNNeW6YNB4JrEBkSPH6HVvJCKUuO7VlfAvvWpMZfx-FqH7F_4kRlbzFeK2DA_c7qeqsBk3Av0d2IoScImldpQ.webp',
        ),
      ];

    case '스트릿':
      return [
        Candidate(
          id: 's1',
          title: '후드티 스트릿',
          imageUrl:
              'https://images.unsplash.com/photo-1614281422552-43ffb8e1f3c7',
        ),
        Candidate(
          id: 's2',
          title: '카고 팬츠 룩',
          imageUrl:
              'https://images.unsplash.com/photo-1614281422520-3dffb8e1f3c7',
        ),
        Candidate(
          id: 's3',
          title: '오버핏 자켓',
          imageUrl:
              'https://images.unsplash.com/photo-1602810318383-6a5d3f13a92d',
        ),
        Candidate(
          id: 's4',
          title: '스트릿 셋업',
          imageUrl:
              'https://images.unsplash.com/photo-1602288637789-50b46f28e949',
        ),
        Candidate(
          id: 's5',
          title: '뉴욕 스트릿',
          imageUrl:
              'https://images.unsplash.com/photo-1603661957038-7eb3d62d7c76',
        ),
        Candidate(
          id: 's6',
          title: '그래픽 티셔츠',
          imageUrl:
              'https://images.unsplash.com/photo-1614281422587-43ffb8e1f3c7',
        ),
        Candidate(
          id: 's7',
          title: '버킷햇 코디',
          imageUrl:
              'https://images.unsplash.com/photo-1603661944307-f823c8e3a7b3',
        ),
        Candidate(
          id: 's8',
          title: '오버핏 후드',
          imageUrl:
              'https://images.unsplash.com/photo-1610902302567-c68a0a9a31b7',
        ),
      ];

    case '캐주얼':
      return [
        Candidate(
          id: 'c1',
          title: '셔츠 캐주얼',
          imageUrl:
              'https://images.unsplash.com/photo-1516826957135-700dedea6982',
        ),
        Candidate(
          id: 'c2',
          title: '청바지 코디',
          imageUrl:
              'https://images.unsplash.com/photo-1512436991641-6745cdb1723f',
        ),
        Candidate(
          id: 'c3',
          title: '니트 베스트',
          imageUrl:
              'https://images.unsplash.com/photo-1521334884684-d80222895322',
        ),
        Candidate(
          id: 'c4',
          title: '기본 흰티',
          imageUrl:
              'https://images.unsplash.com/photo-1578190818871-479cb1d8f2d1',
        ),
        Candidate(
          id: 'c5',
          title: '맨투맨 룩',
          imageUrl:
              'https://images.unsplash.com/photo-1541099649105-f69ad21f3246',
        ),
        Candidate(
          id: 'c6',
          title: '라운드 셔츠',
          imageUrl:
              'https://images.unsplash.com/photo-1576866209830-5f28ab2f04be',
        ),
        Candidate(
          id: 'c7',
          title: '청재킷 코디',
          imageUrl:
              'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c',
        ),
        Candidate(
          id: 'c8',
          title: '슬랙스 캐주얼',
          imageUrl:
              'https://images.unsplash.com/photo-1534447677768-be436bb09401',
        ),
      ];

    // 🍖 식사 궁합
    case '한식':
      return [
        Candidate(
          id: 'k1',
          title: '불고기',
          imageUrl:
              'https://images.unsplash.com/photo-1600891964095-4316a60d51c9',
        ),
        Candidate(
          id: 'k2',
          title: '비빔밥',
          imageUrl:
              'https://images.unsplash.com/photo-1594007654729-407eedc4beef',
        ),
        Candidate(
          id: 'k3',
          title: '김치찌개',
          imageUrl:
              'https://images.unsplash.com/photo-1605475128031-226b6f83fa08',
        ),
        Candidate(
          id: 'k4',
          title: '된장찌개',
          imageUrl:
              'https://images.unsplash.com/photo-1631986159264-96e9f2b70e3d',
        ),
        Candidate(
          id: 'k5',
          title: '제육볶음',
          imageUrl:
              'https://images.unsplash.com/photo-1589734577924-68fda01e1ebc',
        ),
        Candidate(
          id: 'k6',
          title: '불닭볶음면',
          imageUrl:
              'https://images.unsplash.com/photo-1617196034973-681b3e19eb88',
        ),
        Candidate(
          id: 'k7',
          title: '닭갈비',
          imageUrl:
              'https://images.unsplash.com/photo-1588166515264-07d8a0a5f6e2',
        ),
        Candidate(
          id: 'k8',
          title: '갈비탕',
          imageUrl:
              'https://images.unsplash.com/photo-1603034896760-e27b04b664a4',
        ),
      ];

    case '강아지':
    case '고양이':
    case '토끼':
    case '햄스터':
      return [
        Candidate(
          id: 'p1',
          title: '푸들',
          imageUrl: 'https://images.unsplash.com/photo-1558788353-f76d92427f16',
        ),
        Candidate(
          id: 'p2',
          title: '리트리버',
          imageUrl: 'https://images.unsplash.com/photo-1560807707-8cc77767d783',
        ),
        Candidate(
          id: 'p3',
          title: '코숏',
          imageUrl:
              'https://images.unsplash.com/photo-1574158622682-e40e69881006',
        ),
        Candidate(
          id: 'p4',
          title: '러시안블루',
          imageUrl:
              'https://images.unsplash.com/photo-1606214174587-14f59df1b28c',
        ),
        Candidate(
          id: 'p5',
          title: '토끼',
          imageUrl:
              'https://images.unsplash.com/photo-1618828664893-d4eabdd4515c',
        ),
        Candidate(
          id: 'p6',
          title: '햄스터',
          imageUrl:
              'https://images.unsplash.com/photo-1606112219348-204d7d8b94ee',
        ),
        Candidate(
          id: 'p7',
          title: '비숑',
          imageUrl:
              'https://images.unsplash.com/photo-1601758003122-58c45b4b8b5b',
        ),
        Candidate(
          id: 'p8',
          title: '먼치킨',
          imageUrl:
              'https://images.unsplash.com/photo-1611171711398-d9c468ba9931',
        ),
      ];

    case '낭만적':
    case '감성적':
    case '유머러스':
    case '차분함':
      return [
        Candidate(
          id: 'm1',
          title: '감성 일러스트',
          imageUrl:
              'https://images.unsplash.com/photo-1504198453319-5ce911bafcde',
        ),
        Candidate(
          id: 'm2',
          title: '로맨틱 커플',
          imageUrl:
              'https://images.unsplash.com/photo-1504198458649-3128b932f49b',
        ),
        Candidate(
          id: 'm3',
          title: '웃긴 밈',
          imageUrl:
              'https://images.unsplash.com/photo-1540924788198-44ffde64c6a1',
        ),
        Candidate(
          id: 'm4',
          title: '편안한 느낌',
          imageUrl:
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
        ),
        Candidate(
          id: 'm5',
          title: '유쾌한 순간',
          imageUrl:
              'https://images.unsplash.com/photo-1502784444185-1a6a9b452c1c',
        ),
        Candidate(
          id: 'm6',
          title: '감성 풍경',
          imageUrl:
              'https://images.unsplash.com/photo-1470770841072-f978cf4d019e',
        ),
        Candidate(
          id: 'm7',
          title: '잔잔한 물결',
          imageUrl:
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
        ),
        Candidate(
          id: 'm8',
          title: '따뜻한 분위기',
          imageUrl:
              'https://images.unsplash.com/photo-1484249170766-998fa6efe3c0',
        ),
      ];

    case '커피':
    case '디저트':
    case '브런치':
      return [
        Candidate(
          id: 'c1',
          title: '아메리카노',
          imageUrl:
              'https://images.unsplash.com/photo-1509042239860-f550ce710b93',
        ),
        Candidate(
          id: 'c2',
          title: '라떼',
          imageUrl:
              'https://images.unsplash.com/photo-1587734195503-904fca47e0e3',
        ),
        Candidate(
          id: 'c3',
          title: '크로플',
          imageUrl:
              'https://images.unsplash.com/photo-1602665222014-2ef8b3b4e7f2',
        ),
        Candidate(
          id: 'c4',
          title: '케이크',
          imageUrl: 'https://images.unsplash.com/photo-1559628233-5b64d1f0a7d2',
        ),
        Candidate(
          id: 'c5',
          title: '샌드위치',
          imageUrl:
              'https://images.unsplash.com/photo-1572656639536-9e7f84e1f9c5',
        ),
        Candidate(
          id: 'c6',
          title: '브런치 플레이트',
          imageUrl:
              'https://images.unsplash.com/photo-1512058564366-18510be2db19',
        ),
        Candidate(
          id: 'c7',
          title: '카푸치노',
          imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55b',
        ),
        Candidate(
          id: 'c8',
          title: '티라미수',
          imageUrl:
              'https://images.unsplash.com/photo-1606755962773-1c64d449b67d',
        ),
      ];

    default:
      return [];
  }
}
