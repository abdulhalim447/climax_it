import 'package:flutter/material.dart';
import 'package:uddoktapay/models/credentials.dart';
import 'package:uddoktapay/models/customer_model.dart';
import 'package:uddoktapay/models/request_response.dart';
import 'package:uddoktapay/uddoktapay.dart';

class CheckUddoktapay extends StatelessWidget {
  CheckUddoktapay({super.key});

  double totalPrice = 5.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Ensure totalPrice is not zero or negative
              if (totalPrice > 0) {
                final customer = CustomerDetails(
                  fullName: 'CustomerName', // Ensure this is not null
                  email: 'customer.email@example.com', // Ensure this is not null
                );

                if (customer.fullName != null && customer.email != null) {
                  final response = await UddoktaPay.createPayment(
                    context: context!,
                    customer: customer,
                    amount: totalPrice.toString(), // Convert amount to String
                    credentials: UddoktapayCredentials(
                      apiKey: '87568b7376dadba61e141ed7a5833ab381ea3db2', // Ensure API Key is correct
                      panelURL: 'https://paysalat.anamulhasanmaruf.com', // Ensure Panel URL is correct
                    ),
                  );

                  // Handle the response
                  if (response.status == ResponseStatus.completed) {
                    // Payment completed successfully
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment Successful')),
                    );
                  } else if (response.status == ResponseStatus.canceled) {
                    // Payment was canceled
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment Canceled')),
                    );
                  } else if (response.status == ResponseStatus.pending) {
                    // Payment is pending
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment Pending')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Customer details are incomplete')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid amount')),
                );
              }
            },
            child: Text('Pay Now'),
          )),
    );
  }
}
