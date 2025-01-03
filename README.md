En app der gør det nemt studerende at lave sunde retter. Dette er vores teknologi eksamensprojekt i 2.g

# Struktur

Denne sektion beskriver struktur og nøglekomponenter i programmet

## Projektstruktur

Projektet er organiseret i følgende mapper:
  * lib
    * env
    * models
    * pages
    * providers
    * shared
      * widgets
      * enums
    * main.dart: Programmet starter her
  * assets: Indeholder vores logo til appen
  * pubspec.yaml: Definerer projektets afhængigheder og konfigurationer samt installerede biblioteker.

> Bemærk: Private nøgler til OpenAI API og Salling API ligger i `/lib/env/env.g.dart` som er tilføjet til `.gitignore` af sikkerhedsmessige årsager, hvilket betyder at de ikke ligger på github.

## Sider (Widgets)

Widgets er byggestenene i brugergrænsefladen i Flutter. Dette projekt bruger en kombination af StatefulWidgets og StatelessWidgets til at oprette brugergrænsefladen.
Hver side består af en widget

Vigtige widgets brugt:
* `MyHomePage`: Appens hovedskærm.
* `ShoppingList`: Indkøbslisten til madplanen.
* `RecipePage`: En oversigt over en specifik opskrift.

## Providers

Dette projekt bruger Provider state-management. Providers er en state-management metode der gør så man kan give forskellige informationer videre i appens widget-tree.

Vi har to provider-klasser
* `PersonalInfoProvider`: Bruges til den personlige information
* `RecipesProvider`: Bruges til de forskellige opskrifter


## Klasser(Models)

Følgende klasser bruges i projektet:

* `Ingredient`: til en ingrediens
* `PersonalInfo`: til den personlige information man giver når den skal beregne næringsbehov
* `Recipe`: til en opskrift

## API'er
Vi har brugt følgende API'er
* [OpenAI API](https://platform.openai.com/docs/overview)
* [Salling API](https://developer.sallinggroup.com/api-reference)

### OpenAI API
I OpenAI's api bruger vi dart-biblioteket [dart_openai](https://pub.dev/packages/dart_openai).

Alt dette sker i
```dart
Future<OpenAIChatCompletionModel>_makeOpenAiDinnerPlan()
```

Vi starter med at give vores nøgle
```dart
OpenAI.apiKey = Env.apiKey
```
Derefter laver vi først en *assistant* besked ved hjælp af `OpenAIChatCompletionChoiceMessageModel` som skal have en *content*. 

For at lave beskeden bruger vi `OpenAIChatCompletionChoiceMessageContentItemModel.text` og giver beskeden og husker at give argumentet `role: OpenAIChatMessageRole.assistant`. Til vores user besked bruger vi `role: OpenAIChatMessageRole.user`

Vores json-format for responsen fortæller vi ChatGPT at den skal være
```dart
"recipes": [{
            "name": TEXT,
            "description": TEXT,
            "durationInMins": INTEGER,
            "ingredientsForRecipe": List<{"name": TEXT, "quantity": DOUBLE, "unit": STRING, "price": DOUBLE}>,
            "instructions": List<TEXT>,
            "energyInKcal": INTEGER,
            "spices": List<String>,
          }]
```

For at lave beskeden bruger vi `OpenAI.instance.chat.create` og laver vores chatCompletion:
```dart
OpenAI.instance.chat.create(
    model: "gpt-3.5-turbo-0125",
    responseFormat: {"type": "json_object"},
    messages: requestMessages,
    temperature: 1,
    seed: generateRandomNumber(1, 40));
```
For at udskyde vores timeout fra 30 sekunder bruger vi OpenAI's `requestTimeOut` så vi kan lave anmodninger for mere end 30 sekunder.
```dart
OpenAI.requestsTimeOut = 60.seconds;
```

For at håndtere responsen laver vi funktionen
```dart
Future<void> handleOpenAiRequest()
```
Som omdanner `OpenAIChatCompletionModel` til vores `List<Recipe>` dart-format.

### Salling API
Vi bruger den API fra salling der hedder *[Product Suggestions - Relevant Products](https://developer.sallinggroup.com/api-reference#relevant-products)* som får et produkt som input og giver en masse forslag til produkter fra Bilka ToGo retur.

For at bruge Sallings API i dart skal vi bruge dart-pakken [http](https://pub.dev/packages/http).

Vi laver en funktion til at beregne bilkas pris
```dart
Future<Map<String, dynamic>?> _getBilkaPrice(
    {required Ingredient ingredient, bool? tryWithoutUnits})
```

Vores url er `https://api.sallinggroup.com/v1-beta/product-suggestions/relevant-products?query=(Ingrediens)`
Vore vi bruger headers: `{'Authorization': 'Bearer $token'}`

Vi laver vores http anmodning med
```dart
response = await http.get(url, headers: headers);
```
Hvor vi får en masse forslag. Dem giver vi så videre til at den skal finde det forslag der er tættest på ingrediensen

Få at finde den tætteste pris laver vi funktionen
```dart
Map<String, dynamic> _getClosestPrice(
    List<dynamic> suggestions, Ingredient ingredient)
```
På den måde kan vi gå igennem alle ingredienser på indkøbslisten og derefter få de bilka-produkter som vi tror passer til de respektive produkter

## Biblioteker
Bibiliotekerne er inde i pubspec.yaml
Vi bruger følgende biblioteker
* [cupertino_icons: ^1.0.6](https://pub.dev/packages/cupertino_icons)
* [envied: ^0.5.4+1](https://pub.dev/packages/envied)
* [flutter_animate: ^4.5.0](https://pub.dev/packages/flutter_animate)
* [dart_openai: ^5.1.0](https://pub.dev/packages/dart_openai)
* [provider: ^6.1.2](https://pub.dev/packages/provider)
* [gap: ^3.0.1](https://pub.dev/packages/gap)
* [syncfusion_flutter_sliders: ^25.1.40](https://pub.dev/packages/syncfusion_flutter_sliders)
* [http: ^1.2.1](https://pub.dev/packages/http)
* [html: ^0.15.4](https://pub.dev/packages/html)
* [url_launcher: ^6.2.6](https://pub.dev/packages/url_launcher)
* [package_info_plus: ^8.0.0](https://pub.dev/packages/package_info_plus)
* [google_fonts: ^6.2.1](https://pub.dev/packages/google_fonts)
* [flutter_launcher_icons: ^0.13.1](https://pub.dev/packages/flutter_launcher_icons)

## Billeder fra appen
<img src="https://github.com/user-attachments/assets/b86fe095-2c9b-45a1-80fc-9070ee60aae1" width="200">
<img src="https://github.com/user-attachments/assets/eb2aa98e-2a3e-455d-b49c-b01d36c9a76d" width="200">
<img src="https://github.com/user-attachments/assets/b1f544e9-48a5-40e3-a68e-31c6b59afb8d" width="200">
<img src="https://github.com/user-attachments/assets/cb9a7719-5e70-410d-9012-2b54bfcbf845" width="200">

