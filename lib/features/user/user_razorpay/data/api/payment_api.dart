import 'package:arvika_marriage_bureau/features/user/user_razorpay/data/firestore/payment_api._firestore.dart';
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
  }) async {
    try {
      final response = await _dio.post(
        await fetchBaseUrl(), // Replace with your actual endpoint
        data: {
          "amount": amount, // Razorpay expects amount in paisa
          "uid": uid,
          "email": email,
          "agentId": agentId,
          "fullName": fullName,
          "phone": phone,
          "paymentType": paymentType,
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

  Future<String> fetchBaseUrl() async {
    final paymentApiFirestore = PaymentApiFirestore();
    final firestoreBaseUrl = await paymentApiFirestore.getUrl();

    print("this is Pa");

    _dio.options.baseUrl = firestoreBaseUrl ?? "No url";

    return _dio.options.baseUrl;
  }
}
