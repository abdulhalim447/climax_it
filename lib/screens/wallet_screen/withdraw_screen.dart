import 'dart:convert';
import 'package:climax_it_user_app/auth/saved_login/user_session.dart';
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
  String shoppingWalletBalance = "";
  String userId = "";
  String? amountError; // For storing amount validation error

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
      _fetchWalletBalance(); // ইউজারের ব্যালেন্স চেক করবো
    }
  }

  // API থেকে ইউজারের ওয়ালেট ব্যালেন্স ফেচ করা
  Future<void> _fetchWalletBalance() async {
    try {
      var response = await http.post(
        Uri.parse(
            "https://climaxitbd.com/php/wallet/decrease-shop-balance.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "action": "check_balance",
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        setState(() {
          // Store only the numeric value without the symbol
          shoppingWalletBalance = responseData['balance'].toString();
        });
      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage("ব্যালেন্স লোড করা সম্ভব হয়নি!");
    }
  }

  void _updateAmount() {
    setState(() {
      double inputAmount = double.tryParse(_amountController.text) ?? 0;
      calculatedAmount = inputAmount - (inputAmount * 0.02); // Deduct 2% charge

      // Clear error when user starts typing
      amountError = null;
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateAmount);
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdraw() async {
    try {
      final String? userId = await UserSession.getUserID();
      if (_amountController.text.isEmpty ||
          _withdraw_numberController.text.isEmpty ||
          selectedPaymentMethod == null) {
        _showMessage("সব তথ্য প্রদান করুন", isError: true);
        return;
      }

      double amount = double.tryParse(_amountController.text) ?? 0;
      double balance = double.tryParse(shoppingWalletBalance) ?? 0;
      double totalAmountWithCharge = amount +
          (amount * 0.02); // Add 2% charge to check total required amount

      // Validate amount
      if (amount < 250) {
        setState(() {
          amountError = 'সর্বনিম্ন উইথড্র ২৫০ টাকা';
        });
        return;
      }

      // Validate balance including charge
      if (totalAmountWithCharge > balance) {
        setState(() {
          amountError = 'পর্যাপ্ত পরতিমাণ ব্যালেন্স নেই।';
        });
        return;
      }

      setState(() {
        isLoading = true;
      });

      var url = Uri.parse("https://climaxitbd.com/php/withdraw/withdraw.php");
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

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == "success") {
          _showMessage("উইথড্র সফল হয়েছে", isError: false);
          _withdraw_numberController.clear();
          _amountController.clear();
          setState(() {
            selectedPaymentMethod = null;
            amountError = null;
          });
          // Refresh balance after successful withdraw
          _fetchWalletBalance();
        } else {
          _showMessage(responseData['message'], isError: true);
        }
      } else {
        _showMessage("সার্ভার সমস্যা, আবার চেষ্টা করুন", isError: true);
      }
    } catch (e) {
      _showMessage("কিছু সমস্যা হয়েছে, আবার চেষ্টা করুন", isError: true);
    } finally {
      setState(() {
        isLoading = false;
      });
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
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'টাকার পরিমাণ',
                  border: const OutlineInputBorder(),
                  errorText: amountError,
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
                items: <String>['বিকাশ', 'নগদ', 'উপায়']
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('উইথড্র',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'পেমেন্ট রিকোয়েস্ট দেওয়ার ২৪ থেকে ৪৮ ঘণ্টার মধ্যে পেমেন্ট করা হবে। সর্বনিম্ন ২৫০ টাকা উইথড্র দিতে পারবেন এবং উইথড্র দেওয়ার সময় ২% চার্জ কেটে নেওয়া হবে, ধন্যবাদ।',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
