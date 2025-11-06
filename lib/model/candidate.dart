class Candidate {
  final String id;
  final String title;
  final String imageUrl;

  const Candidate({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}

const topics = <String>[
  '고양이',
  '강아지',
  '디저트',
  '스포츠카',
  '풍경',
  '클래식 아트',
]; //임시로 임의의 주제를 넣어두었습니다 실제 진행시엔 로컬로 진행하기로 했으므로 로컬Json으로 분리해야합니다.
List<Candidate> samplesForTopic(String topic) {
  switch (topic) {
    case '고양이':
      return [
        Candidate(
          id: 'a1',
          title: '러시안블루',
          imageUrl: 'https://picsum.photos/id/100/800/600',
        ),
        Candidate(
          id: 'a2',
          title: '코숏',
          imageUrl: 'https://picsum.photos/id/101/800/600',
        ),
        Candidate(
          id: 'a3',
          title: '렉돌',
          imageUrl: 'https://picsum.photos/id/102/800/600',
        ),
        Candidate(
          id: 'a4',
          title: '브리티시숏헤어',
          imageUrl: 'https://picsum.photos/id/103/800/600',
        ),
        Candidate(
          id: 'a5',
          title: '스핑크스',
          imageUrl: 'https://picsum.photos/id/104/800/600',
        ),
        Candidate(
          id: 'a6',
          title: '샴',
          imageUrl: 'https://picsum.photos/id/108/800/600',
        ),
        Candidate(
          id: 'a7',
          title: '터키시알고라',
          imageUrl: 'https://picsum.photos/id/106/800/600',
        ),
        Candidate(
          id: 'a8',
          title: '먼치킨',
          imageUrl: 'https://picsum.photos/id/107/800/600',
        ),
      ];
    case '강아지':
      return [
        Candidate(
          id: 'b1',
          title: '리트리버',
          imageUrl: 'https://picsum.photos/id/200/800/600',
        ),
        Candidate(
          id: 'b2',
          title: '웰시코기',
          imageUrl: 'https://picsum.photos/id/200/800/600',
        ),
        Candidate(
          id: 'b3',
          title: '푸들',
          imageUrl: 'https://picsum.photos/id/200/800/600',
        ),
        Candidate(
          id: 'b4',
          title: '말티즈',
          imageUrl: 'https://picsum.photos/id/200/800/600',
        ),
        Candidate(
          id: 'b5',
          title: '불독',
          imageUrl: 'https://picsum.photos/id/200/800/600',
        ),
        Candidate(
          id: 'b6',
          title: '비숑',
          imageUrl: 'https://picsum.photos/id/200/800/600',
        ),
        Candidate(
          id: 'b7',
          title: '닥스훈트',
          imageUrl: 'https://picsum.photos/id/200/800/600',
        ),
        Candidate(
          id: 'b8',
          title: '시츄',
          imageUrl: 'https://picsum.photos/id/200/800/600',
        ),
      ];
    case '디저트':
      return [
        Candidate(
          id: 'c1',
          title: '마카롱',
          imageUrl: 'https://picsum.photos/id/300/800/600',
        ),
        Candidate(
          id: 'c2',
          title: '케이크',
          imageUrl: 'https://picsum.photos/id/300/800/600',
        ),
        Candidate(
          id: 'c3',
          title: '티라미수',
          imageUrl: 'https://picsum.photos/id/300/800/600',
        ),
        Candidate(
          id: 'c4',
          title: '아포가토',
          imageUrl: 'https://picsum.photos/id/300/800/600',
        ),
        Candidate(
          id: 'c5',
          title: '젤라또',
          imageUrl: 'https://picsum.photos/id/300/800/600',
        ),
        Candidate(
          id: 'c6',
          title: '에끌레어',
          imageUrl: 'https://picsum.photos/id/300/800/600',
        ),
        Candidate(
          id: 'c7',
          title: '휘낭시에',
          imageUrl: 'https://picsum.photos/id/300/800/600',
        ),
        Candidate(
          id: 'c8',
          title: '크림브륄레',
          imageUrl: 'https://picsum.photos/id/300/800/600',
        ),
      ];
    case '스포츠카':
      return [
        Candidate(
          id: 'd1',
          title: '페라리',
          imageUrl: 'https://picsum.photos/id/400/800/600',
        ),
        Candidate(
          id: 'd2',
          title: '람보르기니',
          imageUrl: 'https://picsum.photos/id/400/800/600',
        ),
        Candidate(
          id: 'd3',
          title: '포르쉐',
          imageUrl: 'https://picsum.photos/id/400/800/600',
        ),
        Candidate(
          id: 'd4',
          title: '맥라렌',
          imageUrl: 'https://picsum.photos/id/400/800/600',
        ),
        Candidate(
          id: 'd5',
          title: '코르벳  ',
          imageUrl: 'https://picsum.photos/id/400/800/600',
        ),
        Candidate(
          id: 'd6',
          title: 'GTR',
          imageUrl: 'https://picsum.photos/id/400/800/600',
        ),
        Candidate(
          id: 'd7',
          title: 'NSX',
          imageUrl: 'https://picsum.photos/id/400/800/600',
        ),
        Candidate(
          id: 'd8',
          title: 'R8',
          imageUrl: 'https://picsum.photos/id/400/800/600',
        ),
      ];
    case '풍경':
      return [
        Candidate(
          id: 'e1',
          title: '바다',
          imageUrl: 'https://picsum.photos/id/500/800/600',
        ),
        Candidate(
          id: 'e2',
          title: '산',
          imageUrl: 'https://picsum.photos/id/500/800/600',
        ),
        Candidate(
          id: 'e3',
          title: '도시',
          imageUrl: 'https://picsum.photos/id/500/800/600',
        ),
        Candidate(
          id: 'e4',
          title: '사막',
          imageUrl: 'https://picsum.photos/id/500/800/600',
        ),
        Candidate(
          id: 'e5',
          title: '설원',
          imageUrl: 'https://picsum.photos/id/500/800/600',
        ),
        Candidate(
          id: 'e6',
          title: '호수',
          imageUrl: 'https://picsum.photos/id/500/800/600',
        ),
        Candidate(
          id: 'e7',
          title: '숲',
          imageUrl: 'https://picsum.photos/id/500/800/600',
        ),
        Candidate(
          id: 'e8',
          title: '초원',
          imageUrl: 'https://picsum.photos/id/500/800/600',
        ),
      ];
    case '클래식 아트':
    default:
      return [
        Candidate(
          id: 'f1',
          title: '모나리자',
          imageUrl: 'https://picsum.photos/id/600/800/600',
        ),
        Candidate(
          id: 'f2',
          title: '진주 귀걸이를 한 소녀',
          imageUrl: 'https://picsum.photos/id/600/800/600',
        ),
        Candidate(
          id: 'f3',
          title: '비너스의 탄생',
          imageUrl: 'https://picsum.photos/id/600/800/600',
        ),
        Candidate(
          id: 'f4',
          title: '별이 빛나는 밤',
          imageUrl: 'https://picsum.photos/id/600/800/600',
        ),
        Candidate(
          id: 'f5',
          title: '키스',
          imageUrl: 'https://picsum.photos/id/600/800/600',
        ),
        Candidate(
          id: 'f6',
          title: '회화 추상',
          imageUrl: 'https://picsum.photos/id/600/800/600',
        ),
        Candidate(
          id: 'f7',
          title: '최후의 만찬',
          imageUrl: 'https://picsum.photos/id/600/800/600',
        ),
        Candidate(
          id: 'f8',
          title: '절규',
          imageUrl: 'https://picsum.photos/id/600/800/600',
        ),
      ];
  }
}
