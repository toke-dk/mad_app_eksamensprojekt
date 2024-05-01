# Mad-app (eksamensprojekt)

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

> Bemærk: Private nøgler til OpenAI API og Salling API ligger i `/lib/env/env.g.dart` som er tilføjet til `.gitignore`.

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
* OpenAI API
* Salling API

### OpenAI API
I OpenAI's api bruger vi biblioteket [dart_openai](https://pub.dev/packages/dart_openai).

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

For at lave beskeden bruger vi `OpenAI.instance.chat.create` og giver argumentet til `model`
```dart
model: "gpt-3.5-turbo-0125",
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      temperature: 1,
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
For at bruge Sallings API skal vi bruge pakken [http](https://pub.dev/packages/http).

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
