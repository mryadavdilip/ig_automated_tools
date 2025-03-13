import 'package:http/http.dart' as http;

class InstagramAPIs {
  String url = 'https://graph.instagram.com/v22.0';
  String username = 'mryadavdilip';

  receivedMessages() {
    http.post(Uri.parse('$url/$username'));
  }
}
