import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' hide Response;
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app_exceptions.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static const int TIME_OUT_DURATION = 20;
  final storage = GetStorage();
  late final dio.Dio _dio;

  DioClient() {
    _dio = dio.Dio(
      dio.BaseOptions(
        connectTimeout: const Duration(seconds: TIME_OUT_DURATION),
        receiveTimeout: const Duration(seconds: TIME_OUT_DURATION),
      ),
    );
    _setupHeaders();
  }

  void _setupHeaders() {
    final token = storage.read('user_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }

    if (kIsWeb) {
      _dio.options.headers.addAll({
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json',
        'Accept': '*/*',
      });
    }
  }

  // GET
  Future<dynamic> get(String api) async {
    Uri uri = Uri.parse(api);

    // ✅ Override or add `language=en` to query parameters
    final updatedUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      'language': 'en',
    });

    final finalUrl = updatedUri.toString();
    print('🌐 [GET] Final URL: $finalUrl');

    try {
      print('⏳ Sending GET request...');
      final response = await _dio.get(finalUrl);
      print('✅ GET request successful. Status Code: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');
      return _processResponse(response);

    } on dio.DioException catch (e) {
      print('❌ DioException occurred: ${e.message}');
      print('🔎 Exception Type: ${e.type}');

      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        print('⏱ Timeout Error: API did not respond in time');
        throw ApiNotRespondingException(
          'API not responded in time'.tr,
          finalUrl,
        );
      } else if (e.type == dio.DioExceptionType.connectionError) {
        print('📡 Connection Error: No Internet');
        throw FetchDataException('No Internet connection'.tr, finalUrl);
      }

      print('⚠️ Handling response from DioException fallback');
      final fallbackResponse = e.response ?? dio.Response(
        requestOptions: dio.RequestOptions(path: finalUrl),
        statusCode: 500,
        data: {'success': false, 'message': 'Server error'},
      );

      print('📦 Fallback Response: ${fallbackResponse.data}');
      return _processResponse(fallbackResponse);

    } on SocketException {
      print('🚫 SocketException: No Internet connection');
      throw FetchDataException('No Internet connection'.tr, finalUrl);

    } on TimeoutException {
      print('⏰ TimeoutException: API did not respond in time');
      throw ApiNotRespondingException(
        'API not responded in time'.tr,
        finalUrl,
      );

    } catch (e, stack) {
      print('❗️Unexpected error in GET request: $e');
      print('🪵 Stack trace: $stack');
      rethrow;
    }
  }

  // POST
  Future<dynamic> post(
      String api, [
        dynamic payloadObj,
        bool? multiForm,
      ]) async {
    final uri = Uri.parse(api);
    final payload = multiForm == true ? payloadObj : json.encode(payloadObj);

    try {
      final response = await _dio.post(api, data: payload);
      return _processResponse(response);
    } on dio.DioException catch (e) {
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        throw ApiNotRespondingException(
          'API not responded in time'.tr,
          uri.toString(),
        );
      } else if (e.type == dio.DioExceptionType.connectionError) {
        throw FetchDataException('No Internet connection'.tr, uri.toString());
      }
      return _processResponse(e.response ?? dio.Response(
        requestOptions: dio.RequestOptions(path: api),
        statusCode: 500,
        data: {'success': false, 'message': 'Server error'},
      ));
    } on SocketException {
      throw FetchDataException('No Internet connection'.tr, uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
        'API not responded in time'.tr,
        uri.toString(),
      );
    }
  }

  // DELETE and other methods can follow same pattern

  dynamic _processResponse(dio.Response response) {
    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Data: ${response.data}');

    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
        throw BadRequestException(
          _decodeResponse(response),
          response.requestOptions.path,
        );
      case 401:
      case 403:
        throw UnAuthorizedException(
          _decodeResponse(response),
          response.requestOptions.path,
        );
      case 500:
        return {
          'success': false,
          'message': 'Server error occurred',
          'statusCode': 500,
          'data': response.data
        };
      default:
        throw FetchDataException(
          'Error occurred with code: ${response.statusCode}'.tr,
          response.requestOptions.path,
        );
    }
  }

  String _decodeResponse(dio.Response response) {
    try {
      if (response.data is String) {
        return response.data;
      }
      return jsonEncode(response.data);
    } catch (e) {
      debugPrint('Error decoding response: $e');
      return 'Unknown error occurred';
    }
  }
}