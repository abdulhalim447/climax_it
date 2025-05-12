import 'dart:convert';
import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
import 'package:climax_it_user_app/widgets/custom_circular_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _withdraw_numberController =
      TextEditingController();
  double calculatedAmount = 0; // After deducting charge
  String? selectedPaymentMethod;
  bool isLoading = false; // To show loading state
  String mainWalletBalance = "";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _amountController.addListener(_updateAmount);
  }

  // ইউজারের ID লোড করার ফাংশন
  Future<void> _loadUserId() async {
    final String? userID = await UserSession.getUserID();
    setState(() {
      userId = userID!;
    });

    if (userId.isNotEmpty) {
      fetchWalletBalance(); // ইউজারের ব্যালেন্স চেক করবো
    }
  }

 Future<void> fetchWalletBalance() async {
    try {
      // Retrieve the token from UserSession
      String? token = await UserSession.getToken();

      if (token == null) {
        throw Exception("Token not found");
      }

      // Define API URL
      final String apiUrl = "https://climaxitbd.com/php/wallet/get_wallet_balance.php?token=$token";

      // Make the GET request
      final response = await http.get(Uri.parse(apiUrl));
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        // Parse JSON response
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Extract wallet data
          final walletData = data['data'];

          setState(() {
            mainWalletBalance = walletData['main_wallet_balance'];
          });



        } else {
          throw Exception("Failed to fetch wallet data: ${data['status']}");
        }
      } else {
        throw Exception("Failed to connect to the API");
      }
    } catch (e) {
      print("Error: $e");
    }
  }



  void _updateAmount() {
    setState(() {
      double inputAmount = double.tryParse(_amountController.text) ?? 0;
      calculatedAmount = inputAmount - (inputAmount * 0.02); // Deduct 2% charge
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateAmount);
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdraw() async {
    final String? userId = await UserSession.getUserID();
    if (_amountController.text.isEmpty ||
        _withdraw_numberController.text.isEmpty ||
        selectedPaymentMethod == null) {
      _showMessage("সব তথ্য প্রদান করুন", isError: true);
      return;
    }

    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount < 250) {
      _showMessage("সর্বনিম্ন ২৫০ টাকা উইথড্র দিতে পারবেন", isError: true);
      return;
    }
    if (amount > double.parse(mainWalletBalance)) {
      _showMessage("পর্যাপ্ত পরিমান ব্যালেন্স নেই", isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        "https://climaxitbd.com/php/withdraw/withdraw.php"); // Change to your API URL
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "amount": amount.toStringAsFixed(2),
        "pay_method": selectedPaymentMethod,
        "withdraw_number": _withdraw_numberController.text.toString(),
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        _showMessage("উইথড্র সফল হয়েছে", isError: false);
        _withdraw_numberController.clear();
        _amountController.clear();
        setState(() {
          selectedPaymentMethod = null;
        });
      } else {
        _showMessage(responseData['message'], isError: true);
      }
    } else {
      _showMessage("সার্ভার সমস্যা, আবার চেষ্টা করুন", isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('উইথড্র')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _withdraw_numberController,
                decoration: const InputDecoration(
                  labelText: 'পেমেন্ট নাম্বার',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'টাকার পরিমাণ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Text(
                'আপনি পাবেন ${calculatedAmount.toStringAsFixed(2)} Tk',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'পেমেন্ট মেথড',
                  border: OutlineInputBorder(),
                ),
                items: <String>['বিকাশ', 'নগদ', 'উপায়']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMethod = newValue;
                  });
                },
                value: selectedPaymentMethod,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitWithdraw,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CustomCircularIndicator()
                      : const Text('উইথড্র',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'পেমেন্ট রিকোয়েস্ট দেওয়ার ২৪ থেকে ৪৮ ঘণ্টার মধ্যে পেমেন্ট করা হবে। সর্বনিম্ন ২৫০ টাকা উইথড্র দিতে পারবেন এবং উইথড্র দেওয়ার সময় ২% চার্জ কেটে নেওয়া হবে, ধন্যবাদ।',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
