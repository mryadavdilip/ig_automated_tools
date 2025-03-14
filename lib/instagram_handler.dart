import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:smart_gallery/hive_handler.dart';
import 'package:smart_gallery/models/meta_models/accounts.dart';
import 'package:smart_gallery/models/meta_models/content_publishing_limit.dart';
import 'package:smart_gallery/models/meta_models/error.dart';
import 'package:smart_gallery/models/meta_models/fb_instagram_business_account.dart';

enum Method { get, post, put, patch, delete }

class _APIManager {
  final String baseUrl = 'https://graph.facebook.com/v22.0';
  final Duration connectionTimeout = const Duration(seconds: 30);

  Future<String?> get accessToken async => await HiveHandler.getFbAccessToken();

  final Map<String, String> _defaultHeader = {};

  Future<Map<String, String>> get getDefaultAuthorizedHeaders async {
    Map<String, String> headers = {
      'Authorization': 'Bearer ${await accessToken}',
    };
    headers.addAll(_defaultHeader);
    return headers;
  }

  Future<http.Response> _handleResponse(
    Future<http.Response> Function() request,
  ) async {
    return await request()
        .timeout(
          connectionTimeout,
          onTimeout: () => http.Response('Request timeout', 408),
        )
        .catchError((error) => http.Response('Error: $error', 0));
  }

  Future<dynamic> _request({
    required String endpoint,
    required Map<String, String> headers,
    dynamic body,
    Method method = Method.get,
    bool bodyBytes = false,
    bool retryOnUnauthorized = true,
  }) async {
    if (kDebugMode) {
      log('$endpoint request body: $body');
    }

    final Uri url = Uri.parse('$baseUrl/$endpoint');
    final String? jsonBody = body != null ? jsonEncode(body) : null;

    http.Response res = await switch (method) {
      Method.get => _handleResponse(() => http.get(url, headers: headers)),
      Method.post => _handleResponse(
        () => http.post(url, headers: headers, body: jsonBody),
      ),
      Method.put => _handleResponse(
        () => http.put(url, headers: headers, body: jsonBody),
      ),
      Method.patch => _handleResponse(
        () => http.patch(url, headers: headers, body: jsonBody),
      ),
      Method.delete => _handleResponse(
        () => http.delete(url, headers: headers, body: jsonBody),
      ),
    };

    if (kDebugMode) {
      log(
        'res.headers: ${res.headers}\n$endpoint\nres.statusCode: ${res.statusCode}\nres.body: ${res.body}',
      );
    }

    if (res.statusCode == 200) {
      dynamic decodedJson = '';
      try {
        decodedJson = jsonDecode(res.body);
      } catch (e) {
        if (kDebugMode) {
          print('$endpoint error jsonDecode res.body: $e');
        }
        decodedJson = bodyBytes ? res.bodyBytes : res.body;
      }
      if (decodedJson is String && !bodyBytes) {
        log(decodedJson);
      }
      return decodedJson;
    } else if (res.statusCode == 403 && !retryOnUnauthorized) {
      Fluttertoast.showToast(msg: 'Refresh token expired'); //todo: logout
    } else if (res.statusCode == 400) {
      log(res.body);
    }

    return res;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool? bodyBytes,
  }) async {
    return await _request(
      endpoint: endpoint,
      headers: headers ?? _defaultHeader,
      method: Method.get,
      bodyBytes: bodyBytes ?? false,
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return await _request(
      endpoint: endpoint,
      headers: headers ?? _defaultHeader,
      body: body,
      method: Method.post,
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return await _request(
      endpoint: endpoint,
      headers: headers ?? _defaultHeader,
      body: body,
      method: Method.put,
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return await _request(
      endpoint: endpoint,
      headers: headers ?? _defaultHeader,
      body: body,
      method: Method.patch,
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    return await _request(
      endpoint: endpoint,
      headers: headers ?? _defaultHeader,
      body: body,
      method: Method.delete,
    );
  }
}

class EndPoints {
  static const String me = 'me',
      accounts = 'accounts',
      contentPublishingLimit = 'content_publishing_limit';
}

class Fields {
  static const String instagramBusinessAccount = 'instagram_business_account',
      quotaUsage = 'quota_usage',
      rateLimitSettings = 'rate_limit_settings';
}

class InstagramAPIs {
  final _APIManager _apiManager = _APIManager();

  Future<FBAccounts?> getFacebookAccounts() async {
    var res = await _apiManager.get(
      '${EndPoints.me}/${EndPoints.accounts}',
      headers: await _apiManager.getDefaultAuthorizedHeaders,
    );

    if (res is! http.Response && res is! String && res != null) {
      try {
        return fbAccountsFromJson(res);
      } catch (e) {
        Fluttertoast.showToast(msg: errorFromJson(res).error.message);
      }
    }
    return null;
  }

  Future<FbInstagramBusinessAccount?> getInstagramBusinessAccounts({
    FBAccountData? facebookAccount,
  }) async {
    FBAccountData? account =
        facebookAccount ?? await HiveHandler.getSelectedFBAccount();

    var res = await _apiManager.get(
      '${account?.id}?fields=${Fields.instagramBusinessAccount}',

      headers: await _apiManager.getDefaultAuthorizedHeaders,
    );

    if (res is! http.Response && res is! String && res != null) {
      try {
        return fbInstagramBusinessAccountFromJson(res);
      } catch (e) {
        Fluttertoast.showToast(msg: errorFromJson(res).error.message);
      }
    }
    return null;
  }

  Future<ContentPublishingLimit?> getContentPublishingLimit() async {
    FBAccountData? account = await HiveHandler.getSelectedFBAccount();

    var res = await _apiManager.get(
      '${account?.id}/${EndPoints.contentPublishingLimit}?fields=${Fields.quotaUsage},${Fields.rateLimitSettings}&since=${DateTime.now().millisecondsSinceEpoch / 1000}',

      headers: await _apiManager.getDefaultAuthorizedHeaders,
    );

    if (res is! http.Response && res is! String && res != null) {
      try {
        return contentPublishingLimitFromJson(res);
      } catch (e) {
        Fluttertoast.showToast(msg: errorFromJson(res).error.message);
      }
    }

    return null;
  }
}
