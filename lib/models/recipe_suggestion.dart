class RecipeSuggestion {
  String title;
  String shortDescription;

  RecipeSuggestion({required this.title, required this.shortDescription});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'shortDescription': shortDescription,
    };
  }

  factory RecipeSuggestion.fromMap(Map<String, dynamic> map) {
    print(map);
    return RecipeSuggestion(
        title: map['title'] as String,
        shortDescription: map['shortDescription'] as String);
  }
}
