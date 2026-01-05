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
    required String email,
    required String fullName,
    required String phone, 
  }) async {
    try {
      final response = await _dio.post(
        "/create-order", // Replace with your actual endpoint
        data: {
          "amount": amount, // Razorpay expects amount in paisa
          "uid": uid,
          "email": email,
          "fullName": fullName,
          "phone": phone, 
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception("Failed to create order: ${e.message}");
    }
  }
 
}
