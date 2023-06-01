class Buyer {
  late String name;
  late String phone;
  late String address;

  Buyer();

  Buyer.fromJson(Map<String, dynamic> json) {
    try {
      name = json['name'] = "";
      phone = json['phone'] = "";
      address = json['address'] = "";
    } catch (e) {
      name = "";
      phone = "";
      address = "";
    }
  }
}
