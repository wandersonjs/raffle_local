class RaffleNum {
  late int index;
  late int number;
  late String buyer;

  RaffleNum({required this.index, required this.number, required this.buyer});

  RaffleNum.fromJSON(Map<String, dynamic> jsonMap) {
    this.index = jsonMap['index'];
    this.number = jsonMap['number'];
    this.buyer = jsonMap['buyer'] ?? jsonMap['buyer'];
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'number': number,
      'buyer': buyer,
    };
  }

  Map toMap() {
    Map map = new Map();
    map['number'] = number;
    map['buyer'] = buyer;
    return map;
  }
}
