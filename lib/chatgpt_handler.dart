import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:ig_automated_tools/hive_handler.dart';

class ChatgptHandler {
  Future<OpenAI> get openAI async => OpenAI.instance.build(
    token: (await HiveHandler.getOpenAIKey()).key,
    baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
    enableLog: true,
  );

  ChatCompleteText getResponse() => ChatCompleteText(
    model: ChatModelFromValue(model: 'gpt-4'),
    messages: [
      {
        "name": "url_extractor",
        "schema": {
          "type": "object",
          "properties": {
            "urls": {
              "type": "array",
              "description":
                  "A collection of extracted URLs from the raw string.",
              "items": {
                "type": "string",
                "description": "A URL extracted from the provided raw string.",
              },
            },
          },
          "required": ["urls"],
          "additionalProperties": false,
        },
        "strict": true,
      },
    ],
  );
}
