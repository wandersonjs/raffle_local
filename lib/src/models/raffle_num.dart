class RaffleNum {
  late int index;
  late int number;
  late String buyer;

  RaffleNum({required this.index, required this.number, required this.buyer});

  RaffleNum.fromJSON(Map<String, dynamic> jsonMap) {
    index = jsonMap['index'];
    number = jsonMap['number'];
    buyer = jsonMap['buyer'] ?? jsonMap['buyer'];
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'number': number,
      'buyer': buyer,
    };
  }

  Map toMap() {
    Map map = {};
    map['number'] = number;
    map['buyer'] = buyer;
    return map;
  }
}
