import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';

extension OpenAIChatCompletionExtension on OpenAIChatCompletionModel {
  Map<String, dynamic> get myJsonDecode => jsonDecode(choices.first.message.content!.first.text.toString());
}