class Surah {
  int number;
  String name;
  String nameMeaning;
  String source;

  Surah({required this.number, required this.name, required this.nameMeaning, required this.source});

  void printDetails() {
    print("Number: $number, Name: $name, Name Meaning: $nameMeaning, Source: $source");
  }
}
