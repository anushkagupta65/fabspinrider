class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
    );
  }
}

class States {
  final int id;
  final String name;

  States({required this.id, required this.name});

  factory States.fromJson(Map<String, dynamic> json) {
    return States(
      id: json['id'],
      name: json['name'],
    );
  }
}
