class Band {
  String id;
  String name;
  int votes;

  Band({
    required this.id,
    required this.name,
    required this.votes,
  });

  /// el objetivo de este factory constructor es regresar una nueva instancia de la clase
  factory Band.fromMap(Map<String, dynamic> obj) => Band(
        id: obj.containsKey('id') ? obj['id'] : 'no-id',
        name: obj.containsKey('name') ? obj['name'] : 'no-names',
        votes: obj.containsKey('votes') ? obj['votes'] : 0,
      );
} //and_class_Band
