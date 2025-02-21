import 'dart:convert';
import 'package:get/get.dart';
import 'package:uddoktapay/models/customer_model.dart';
import 'package:uddoktapay/models/request_response.dart';
import 'package:uddoktapay/uddoktapay.dart';

void onButtonTap(String selected) async {
  switch (selected) {
    case 'uddoktapay':
      uddoktapay();
      break;

    default:
      print('No gateway selected');
  }
}

double totalPrice = 1.00;

/// UddoktaPay
void uddoktapay() async {
  final response = await UddoktaPay.createPayment(
    context: Get.context!,
    customer: CustomerDetails(
      fullName: 'Md Shirajul Islam',
      email: 'ytshirajul@icould.com',
    ),
    amount: totalPrice.toString(),
  );

  if (response.status == ResponseStatus.completed) {
    print('Payment completed, Trx ID: ${response.transactionId}');
    print(response.senderNumber);
  }

  if (response.status == ResponseStatus.canceled) {
    print('Payment canceled');
  }

  if (response.status == ResponseStatus.pending) {
    print('Payment pending');
  }
}

