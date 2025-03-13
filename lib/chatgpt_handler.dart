import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_gallery/hive_handler.dart';

class ChatgptHandler {
  Future<OpenAI> get _openAI async => OpenAI.instance.build(
    token: (await HiveHandler.getOpenAIKey()).key,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30),
    ),
    enableLog: true,
  );

  Future<ChatCTResponse?> getChatResponse(String message) async {
    final request = ChatCompleteText(
      model: Gpt4OChatModel(),
      maxToken: 200,
      messages: [
        Messages(
          role: Role.system,
          content: 'You have to extract data from raw string.',
        ).toJson(),
        Messages(
          role: Role.user,
          content:
              'The string I provide, contains: 1. userId with optional (categories), urls with optional category.',
        ).toJson(),
        Messages(role: Role.user, content: message).toJson(),
      ],
      responseFormat: ResponseFormat.jsonSchema(
        jsonSchema: JsonSchema(
          name: 'url extractor',
          schema: {
            "type": "object",
            "properties": {
              "userId": {"type": "string"},
              "categories": {
                "type": "array",
                "items": {"type": "string"},
              },
              "contents": {
                "type": "array",
                "items": {
                  "type": "object",
                  "properties": {
                    "url": {"type": "string"},
                    "categories": {
                      "type": "array",
                      "items": {"type": "string"},
                    },
                  },
                  "required": ["url", "categories"],
                },
              },
            },
            "required": ["userId", "categories", "contents"],
          },
        ),
      ),
    );

    ChatCTResponse? response = await (await _openAI).onChatCompletion(
      request: request,
    );

    debugPrint('$response');
    return response;
  }
}
