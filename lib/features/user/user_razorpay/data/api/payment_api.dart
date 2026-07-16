import 'package:shadi_milan/features/user/user_razorpay/data/firestore/payment_api._firestore.dart';
import 'package:dio/dio.dart';

class PaymentApi {
  final Dio _dio = Dio(
    BaseOptions(headers: {"Content-Type": "application/json"}),
  );

  Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String uid,
    required String agentId,
    required String email,
    required String fullName,
    required String phone,
    required String paymentType,
    required String region,
    required String district,
    required String gender,
    required double agentCommission,
    required double commissionRate,
    required String agentDesignation,
  }) async {
    try {
      final response = await _dio.post(
        await fetchBaseUrl(), // Replace with your actual endpoint
        data: {
          "amount": amount, // Razorpay expects amount in paisa
          "uid": uid,
          "agentId": agentId,
          "email": email,
          "fullName": fullName,
          "phone": phone,
          "paymentType": paymentType,
          "region": region,
          "district": district,
          "gender": gender,
          "agentCommission": agentCommission,
          "commissionRate": commissionRate,
          "agentDesignation": agentDesignation,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        // The server responded with a status code other than 2xx
        print("Error data: ${e.response?.data}");
        print("Error headers: ${e.response?.headers}");
        print("Error request options: ${e.response?.requestOptions}");
        throw Exception(
          "Failed to create order: ${e.response?.data['message'] ?? e.message}",
        );
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print("Error request: ${e.requestOptions}");
        print("Error message: ${e.message}");
        throw Exception("Failed to create order: ${e.message}");
      }
    }
  }

  Future<String> fetchBaseUrl() async {
    final paymentApiFirestore = PaymentApiFirestore();
    final firestoreBaseUrl = await paymentApiFirestore.getUrl();
    _dio.options.baseUrl = firestoreBaseUrl ?? "No url";

    return _dio.options.baseUrl;
  }
}
