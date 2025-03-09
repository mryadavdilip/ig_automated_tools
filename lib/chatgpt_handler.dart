import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:ig_automated_tools/hive_handler.dart';

class ChatgptHandler {
  Future<OpenAI> get openAI async => OpenAI.instance.build(
    token: (await HiveHandler.getOpenAIKey()).key,
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30),
    ),
    enableLog: true,
  );

  Future<String> getChatResponse(String message) async {
    final response = ChatCompleteText(
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
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'userId': {'type': 'string'},
                'url': {'type': 'string'},
                'category': {'type': 'string'},
              },
              'required': ['extractedData'],
            },
          },
        ),
      ),
    );
    return response.messages.first['content'];
  }
}
