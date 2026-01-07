import 'dart:convert';

import 'package:dio/dio.dart';

class PaymentApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://parade-johnston-nvidia-harris.trycloudflare.com",
      headers: {"Content-Type": "application/json"},
    ),
  );

  Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String uid,
    required String agentId,
    required String email,
    required String fullName,

    required String phone,
    required String region,
    required String district,
    required String gender,
  }) async {
    try {
      final response = await _dio.post(
        "/create-order", // Replace with your actual endpoint
        data: {
          "amount": amount, // Razorpay expects amount in paisa
          "uid": uid,
          "email": email,
          "agentId": agentId,
          "fullName": fullName,
          "phone": phone,
          "region": region,
          "district": district,
          "gender": gender,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception("Failed to create order: ${e.message}");
    }
  }
}
