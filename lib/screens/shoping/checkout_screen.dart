import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:climax_it_user_app/screens/shoping/product.dart';
import '../../auth/saved_login/user_session.dart';

class CheckoutScreen extends StatefulWidget {
  final Product product;
  final int initialQuantity;

  const CheckoutScreen({
    Key? key,
    required this.product,
    this.initialQuantity = 1,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late int quantity;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String userId = "";

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _resellerPriceController = TextEditingController();

  String? selectedDistrict;
  String? selectedUpazila;
  List<String> upazilas = [];

  // Dummy data for dropdowns
  final List<String> districts = [
    'ঢাকা', 'ফরিদপুর', 'গাজীপুর', 'গোপালগঞ্জ', 'কিশোরগঞ্জ', 'মাদারীপুর', 'মানিকগঞ্জ', 'মুন্সিগঞ্জ', 'নারায়ণগঞ্জ', 'নরসিংদী', 'রাজবাড়ী', 'শরীয়তপুর', 'টাঙ্গাইল',
    'চট্টগ্রাম', 'বান্দরবান', 'ব্রাহ্মণবাড়িয়া', 'চাঁদপুর', 'কুমিল্লা', 'কক্সবাজার', 'ফেনী', 'খাগড়াছড়ি', 'লক্ষ্মীপুর', 'নোয়াখালী', 'রাঙামাটি',
    'রাজশাহী', 'বগুড়া', 'জয়পুরহাট', 'নওগাঁ', 'নাটোর', 'চাঁপাইনবাবগঞ্জ', 'পাবনা', 'সিরাজগঞ্জ',
    'খুলনা', 'বাগেরহাট', 'চুয়াডাঙ্গা', 'যশোর', 'ঝিনাইদহ', 'কুষ্টিয়া', 'মাগুরা', 'মেহেরপুর', 'নড়াইল', 'সাতক্ষীরা',
    'বরিশাল', 'বরগুনা', 'ভোলা', 'ঝালকাঠি', 'পটুয়াখালী', 'পিরোজপুর',
    'সিলেট', 'হবিগঞ্জ', 'মৌলভীবাজার', 'সুনামগঞ্জ',
    'ময়মনসিংহ', 'জামালপুর', 'নেত্রকোণা', 'শেরপুর',
    'রংপুর', 'দিনাজপুর', 'গাইবান্ধা', 'কুড়িগ্রাম', 'লালমনিরহাট', 'নীলফামারী', 'পঞ্চগড়', 'ঠাকুরগাঁও'
  ];

  final Map<String, List<String>> districtUpazilas = {
    'কুমিল্লা': [
      'দেবিদ্বার',
      'বরুড়া',
      'ব্রাহ্মণপাড়া',
      'চান্দিনা',
      'চৌদ্দগ্রাম',
      'দাউদকান্দি',
      'হোমনা',
      'লাকসাম',
      'মুরাদনগর',
      'নাঙ্গলকোট',
      'কুমিল্লা সদর',
      'মেঘনা',
      'মনোহরগঞ্জ',
      'সদর দক্ষিণ',
      'তিতাস',
      'বুড়িচং',
      'লালমাই'
    ],
    'ফেনী': [
      'ছাগলনাইয়া',
      'ফেনী সদর',
      'সোনাগাজী',
      'ফুলগাজী',
      'পরশুরাম',
      'দাগনভূঞা'
    ],
    'ব্রাহ্মণবাড়িয়া': [
      'ব্রাহ্মণবাড়িয়া সদর',
      'কসবা',
      'নাসিরনগর',
      'সরাইল',
      'আশুগঞ্জ',
      'আখাউড়া',
      'নবীনগর',
      'বাঞ্ছারামপুর',
      'বিজয়নগর'
    ],
    'রাঙ্গামাটি': [
      'রাঙ্গামাটি সদর',
      'কাপ্তাই',
      'কাউখালী',
      'বাঘাইছড়ি',
      'বরকল',
      'লংগদু',
      'রাজস্থলী',
      'বিলাইছড়ি',
      'জুরাছড়ি',
      'নানিয়ারচর'
    ],
    'নোয়াখালী': [
      'নোয়াখালী',
      'কোম্পানীগঞ্জ',
      'বেগমগঞ্জ',
      'হাতিয়া',
      'সুবর্ণচর',
      'কবিরহাট',
      'সেনবাগ',
      'চাটখিল',
      'সোনাইমুড়ী'
    ],
    'চাঁদপুর': [
      'হাইমচর',
      'কচুয়া',
      'শাহরাস্তি',
      'চাঁদপুর সদর',
      'মতলব',
      'হাজীগঞ্জ',
      'ফরিদগঞ্জ'
    ],
    'লক্ষ্মীপুর': ['লক্ষ্মীপুর সদর', 'কমলনগর', 'রায়পুর', 'রামগতি', 'রামগঞ্জ'],
    'চট্টগ্রাম': [
      'রাঙ্গুনিয়া',
      'সীতাকুন্ড',
      'মীরসরাই',
      'পটিয়া',
      'সন্দ্বীপ',
      'বাঁশখালী',
      'বোয়ালখালী',
      'আনোয়ারা',
      'চন্দনাইশ',
      'সাতকানিয়া',
      'লোহাগাড়া',
      'হাটহাজারী',
      'ফটিকছড়ি',
      'রাউজান',
      'কর্ণফুলী'
    ],
    'কক্সবাজার': [
      'কক্সবাজার সদর',
      'চকরিয়া',
      'কুতুবদিয়া',
      'উখিয়া',
      'মহেশখালী',
      'পেকুয়া',
      'রামু',
      'টেকনাফ'
    ],
    'খাগড়াছড়ি': [
      'খাগড়াছড়ি সদর',
      'দিঘীনালা',
      'পানছড়ি',
      'লক্ষীছড়ি',
      'মহালছড়ি',
      'মানিকছড়ি',
      'রামগড়',
      'মাটিরাঙ্গা',
      'গুইমারা'
    ],
    'বান্দরবান': [
      'বান্দরবান সদর',
      'আলীকদম',
      'নাইক্ষ্যংছড়ি',
      'রোয়াংছড়ি',
      'লামা',
      'রুমা',
      'থানচি'
    ],
    'সিরাজগঞ্জ': [
      'বেলকুচি',
      'চৌহালি',
      'কামারখন্দ',
      'কাজীপুর',
      'রায়গঞ্জ',
      'শাহজাদপুর',
      'সিরাজগঞ্জ',
      'তাড়াশ',
      'উল্লাপাড়া'
    ],
    'পাবনা': [
      'সুজানগর',
      'ঈশ্বরদী',
      'ভাঙ্গুড়া',
      'পাবনা সদর',
      'বেড়া',
      'আটঘরিয়া',
      'চাটমোহর',
      'সাঁথিয়া',
      'ফরিদপুর'
    ],
    'বগুড়া': [
      'কাহালু',
      'বগুড়া সদর',
      'সারিয়াকান্দি',
      'শাজাহানপুর',
      'দুপচাচিঁয়া',
      'আদমদিঘি',
      'নন্দিগ্রাম',
      'সোনাতলা',
      'ধুনট',
      'গাবতলী',
      'শেরপুর',
      'শিবগঞ্জ'
    ],
    'রাজশাহী': [
      'পবা',
      'দুর্গাপুর',
      'মোহনপুর',
      'চারঘাট',
      'পুঠিয়া',
      'বাঘা',
      'গোদাগাড়ী',
      'তানোর',
      'বাগমারা'
    ],
    'নাটোর': [
      'নাটোর সদর',
      'সিংড়া',
      'বড়াইগ্রাম',
      'বাগাতিপাড়া',
      'লালপুর',
      'গুরুদাসপুর',
      'নলডাঙ্গা'
    ],
    'জয়পুরহাট': ['আক্কেলপুর', 'কালাই', 'ক্ষেতলাল', 'পাঁচবিবি', 'জয়পুরহাট সদর'],
    'চাঁপাইনবাবগঞ্জ': [
      'চাঁপাইনবাবগঞ্জ সদর',
      'গোমস্তাপুর',
      'নাচোল',
      'ভোলাহাট',
      'শিবগঞ্জ'
    ],
    'নওগাঁ': [
      'মহাদেবপুর',
      'বদলগাছী',
      'পত্নিতলা',
      'ধামইরহাট',
      'নিয়ামতপুর',
      'মান্দা',
      'আত্রাই',
      'রাণীনগর',
      'নওগাঁ সদর',
      'পোরশা',
      'সাপাহার'
    ],
    'যশোর': [
      'মণিরামপুর',
      'অভয়নগর',
      'বাঘারপাড়া',
      'চৌগাছা',
      'ঝিকরগাছা',
      'কেশবপুর',
      'যশোর সদর',
      'শার্শা'
    ],
    'সাতক্ষীরা': [
      'আশাশুনি',
      'দেবহাটা',
      'কলারোয়া',
      'সাতক্ষীরা সদর',
      'শ্যামনগর',
      'তালা',
      'কালিগঞ্জ'
    ],
    'মেহেরপুর': ['মুজিবনগর', 'মেহেরপুর সদর', 'গাংনী'],
    'নড়াইল': ['নড়াইল সদর', 'লোহাগড়া', 'কালিয়া'],
    'চুয়াডাঙ্গা': ['চুয়াডাঙ্গা সদর', 'আলমডাঙ্গা', 'দামুড়হুদা', 'জীবননগর'],
    'কুষ্টিয়া': [
      'কুষ্টিয়া সদর',
      'কুমারখালী',
      'খোকসা',
      'মিরপুর',
      'দৌলতপুর',
      'ভেড়ামারা'
    ],
    'মাগুরা': ['শালিখা', 'শ্রীপুর', 'মাগুরা সদর', 'মহম্মদপুর'],
    'খুলনা': [
      'পাইকগাছা',
      'ফুলতলা',
      'দিঘলিয়া',
      'রূপসা',
      'তেরখাদা',
      'ডুমুরিয়া',
      'বটিয়াঘাটা',
      'দাকোপ',
      'কয়রা'
    ],
    'বাগেরহাট': [
      'ফকিরহাট',
      'বাগেরহাট সদর',
      'মোল্লাহাট',
      'শরণখোলা',
      'রামপাল',
      'মোড়েলগঞ্জ',
      'কচুয়া',
      'মোংলা',
      'চিতলমারী'
    ],
    'ঝিনাইদহ': [
      'ঝিনাইদহ সদর',
      'শৈলকুপা',
      'হরিণাকুন্ডু',
      'কালীগঞ্জ',
      'কোটচাঁদপুর',
      'মহেশপুর'
    ],
    'ঝালকাঠি': ['ঝালকাঠি সদর', 'কাঠালিয়া', 'নলছিটি', 'রাজাপুর'],
    'পটুয়াখালী': [
      'বাউফল',
      'পটুয়াখালী সদর',
      'দুমকি',
      'দশমিনা',
      'কলাপাড়া',
      'মির্জাগঞ্জ',
      'গলাচিপা',
      'রাঙ্গাবালী'
    ],
    'পিরোজপুর': [
      'পিরোজপুর সদর',
      'নাজিরপুর',
      'কাউখালী',
      'ভান্ডারিয়া',
      'মঠবাড়ীয়া',
      'নেছারাবাদ',
      'ইন্দুরকানী'
    ],
    'বরিশাল': [
      'বরিশাল সদর',
      'বাকেরগঞ্জ',
      'বাবুগঞ্জ',
      'উজিরপুর',
      'বানারীপাড়া',
      'গৌরনদী',
      'আগৈলঝাড়া',
      'মেহেন্দিগঞ্জ',
      'মুলাদী',
      'হিজলা'
    ],
    'ভোলা': [
      'ভোলা সদর',
      'বোরহান উদ্দিন',
      'চরফ্যাশন',
      'দৌলতখান',
      'মনপুরা',
      'তজুমদ্দিন',
      'লালমোহন'
    ],
    'বরগুনা': ['আমতলী', 'বরগুনা সদর', 'বেতাগী', 'বামনা', 'পাথরঘাটা', 'তালতলি'],
    'সিলেট': [
      'বালাগঞ্জ',
      'বিয়ানীবাজার',
      'বিশ্বনাথ',
      'কোম্পানীগঞ্জ',
      'ফেঞ্চুগঞ্জ',
      'গোলাপগঞ্জ',
      'গোয়াইনঘাট',
      'জৈন্তাপুর',
      'কানাইঘাট',
      'সিলেট সদর',
      'জকিগঞ্জ',
      'দক্ষিণ সুরমা',
      'ওসমানী'
    ],
    'মৌলভীবাজার': [
      'বড়লেখা',
      'কমলগঞ্জ',
      'কুলাউড়া',
      'মৌলভীবাজার সদর',
      'রাজনগর',
      'শ্রীমঙ্গল',
      'জুড়ী'
    ],
    'হবিগঞ্জ': [
      'নবীগঞ্জ',
      'বাহুবল',
      'আজমিরীগঞ্জ',
      'বানিয়াচং',
      'লাখাই',
      'চুনারুঘাট',
      'হবিগঞ্জ সদর',
      'মাধবপুর',
      'শায়েস্তাগঞ্জ'
    ],
    'সুনামগঞ্জ': [
      'সুনামগঞ্জ সদর',
      'দক্ষিণ সুনামগঞ্জ',
      'বিশ্বম্ভরপুর',
      'ছাতক',
      'জগন্নাথপুর',
      'দোয়ারাবাজার',
      'তাহিরপুর',
      'ধর্মপাশা',
      'জামালগঞ্জ',
      'শাল্লা',
      'দিরাই',
      'মধ্যনগর'
    ],
    'নরসিংদী': ['বেলাবো', 'মনোহরদী', 'নরসিংদী', 'পলাশ', 'রায়পুরা', 'শিবপুর'],
    'গাজীপুর': ['কালীগঞ্জ', 'কালিয়াকৈর', 'কাপাসিয়া', 'গাজীপুর সদর', 'শ্রীপুর'],
    'শরীয়তপুর': [
      'শরিয়তপুর সদর',
      'নড়িয়া',
      'জাজিরা',
      'গোসাইরহাট',
      'ভেদরগঞ্জ',
      'ডামুড্যা'
    ],
    'নারায়ণগঞ্জ': [
      'আড়াইহাজার',
      'বন্দর',
      'নারায়নগঞ্জ সদর',
      'রূপগঞ্জ',
      'সোনারগাঁ'
    ],
    'টাঙ্গাইল': [
      'বাসাইল',
      'ভুয়াপুর',
      'দেলদুয়ার',
      'ঘাটাইল',
      'গোপালপুর',
      'মধুপুর',
      'মির্জাপুর',
      'নাগরপুর',
      'সখিপুর',
      'টাঙ্গাইল সদর',
      'কালিহাতী',
      'ধনবাড়ী'
    ],
    'কিশোরগঞ্জ': [
      'ইটনা',
      'কটিয়াদী',
      'ভৈরব',
      'তাড়াইল',
      'হোসেনপুর',
      'পাকুন্দিয়া',
      'কুলিয়ারচর',
      'কিশোরগঞ্জ সদর',
      'করিমগঞ্জ',
      'বাজিতপুর',
      'অষ্টগ্রাম',
      'মিঠামইন',
      'নিকলী'
    ],
    'মানিকগঞ্জ': [
      'হরিরামপুর',
      'সাটুরিয়া',
      'মানিকগঞ্জ সদর',
      'ঘিওর',
      'শিবালয়',
      'দৌলতপুর',
      'সিংগাইর'
    ],
    'ঢাকা': ['সাভার', 'ধামরাই', 'কেরাণীগঞ্জ', 'নবাবগঞ্জ', 'দোহার'],
    'মুন্সিগঞ্জ': [
      'মুন্সিগঞ্জ সদর',
      'শ্রীনগর',
      'সিরাজদিখান',
      'লৌহজং',
      'গজারিয়া',
      'টংগীবাড়ি'
    ],
    'রাজবাড়ী': [
      'রাজবাড়ী সদর',
      'গোয়ালন্দ',
      'পাংশা',
      'বালিয়াকান্দি',
      'কালুখালী'
    ],
    'মাদারীপুর': ['মাদারীপুর সদর', 'শিবচর', 'কালকিনি', 'রাজৈর', 'ডাসার'],
    'গোপালগঞ্জ': [
      'গোপালগঞ্জ সদর',
      'কাশিয়ানী',
      'টুংগীপাড়া',
      'কোটালীপাড়া',
      'মুকসুদপুর'
    ],
    'ফরিদপুর': [
      'ফরিদপুর সদর',
      'আলফাডাঙ্গা',
      'বোয়ালমারী',
      'সদরপুর',
      'নগরকান্দা',
      'ভাঙ্গা',
      'চরভদ্রাসন',
      'মধুখালী',
      'সালথা'
    ],
    'পঞ্চগড়': ['পঞ্চগড়', 'দেবীগঞ্জ', 'বোদা', 'আটোয়ারী', 'তেতুলিয়া'],
    'দিনাজপুর': [
      'নবাবগঞ্জ',
      'বীরগঞ্জ',
      'ঘোড়াঘাট',
      'বিরামপুর',
      'পার্বতীপুর',
      'বোচাগঞ্জ',
      'কাহারোল',
      'ফুলবাড়ী',
      'দিনাজপুর সদর',
      'হাকিমপুর',
      'খানসামা',
      'বিরল',
      'চিরিরবন্দর'
    ],
    'লালমনিরহাট': [
      'লালমনিরহাট সদর',
      'কালীগঞ্জ',
      'হাতীবান্ধা',
      'পাটগ্রাম',
      'আদিতমারী'
    ],
    'নীলফামারী': [
      'সৈয়দপুর',
      'ডোমার',
      'ডিমলা',
      'জলঢাকা',
      'কিশোরগঞ্জ',
      'নীলফামারী সদর'
    ],
    'গাইবান্ধা': [
      'সাদুল্লাপুর',
      'গাইবান্ধা সদর',
      'পলাশবাড়ী',
      'সাঘাটা',
      'গোবিন্দগঞ্জ',
      'সুন্দরগঞ্জ',
      'ফুলছড়ি'
    ],
    'ঠাকুরগাঁও': [
      'ঠাকুরগাঁও',
      'পীরগঞ্জ',
      'রাণীশংকৈল',
      'হরিপুর',
      'বালিয়াডাঙ্গী'
    ],
    'রংপুর': [
      'রংপুর সদর',
      'গংগাচড়া',
      'তারাগঞ্জ',
      'বদরগঞ্জ',
      'মিঠাপুকুর',
      'পীরগঞ্জ',
      'কাউনিয়া',
      'পীরগাছা'
    ],
    'কুড়িগ্রাম': [
      'কুড়িগ্রাম সদর',
      'নাগেশ্বরী',
      'ভুরুঙ্গামারী',
      'ফুলবাড়ী',
      'রাজারহাট',
      'উলিপুর',
      'চিলমারী',
      'রৌমারী',
      'চর রাজিবপুর'
    ],
    'শেরপুর': ['শেরপুর সদর', 'নালিতাবাড়ী', 'শ্রীবরদী', 'নকলা', 'ঝিনাইগাতী'],
    'ময়মনসিংহ': [
      'ফুলবাড়ীয়া',
      'ত্রিশাল',
      'ভালুকা',
      'মুক্তাগাছা',
      'ময়মনসিংহ সদর',
      'ধোবাউড়া',
      'ফুলপুর',
      'হালুয়াঘাট',
      'গৌরীপুর',
      'গফরগাঁও',
      'ঈশ্বরগঞ্জ',
      'নান্দাইল',
      'তারাকান্দা'
    ],
    'জামালপুর': [
      'জামালপুর সদর',
      'মেলান্দহ',
      'ইসলামপুর',
      'দেওয়ানগঞ্জ',
      'সরিষাবাড়ী',
      'মাদারগঞ্জ',
      'বকশীগঞ্জ'
    ],
    'নেত্রকোণা': [
      'বারহাট্টা',
      'দুর্গাপুর',
      'কেন্দুয়া',
      'আটপাড়া',
      'মদন',
      'খালিয়াজুরী',
      'কলমাকান্দা',
      'মোহনগঞ্জ',
      'পূর্বধলা',
      'নেত্রকোণা সদর'
    ],
  };

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
    _loadUserInfo();
    _resellerPriceController.addListener(_validateResellerPrice);
  }

  Future<void> _loadUserInfo() async {
    String? storedUserId = await UserSession.getUserID();
    if (storedUserId != null) {
      setState(() {
        userId = storedUserId;
      });
    }
  }

  void _updateUpazilas(String district) {
    setState(() {
      selectedUpazila = null;
      upazilas = districtUpazilas[district] ?? [];
    });
  }

  double get adminPrice => double.parse(widget.product.adminPrice) * quantity;

  double get maxSellingPrice =>
      double.parse(widget.product.resellerPrice) * quantity;

  double get resellerPrice =>
      double.tryParse(_resellerPriceController.text) ?? 0.0;

  double get deliveryCharge => 130.0;

  double get profit {
    double calculatedProfit = resellerPrice - adminPrice;
    return (calculatedProfit < 0) ? 0.0 : calculatedProfit;
  }

  double get total => resellerPrice + deliveryCharge;

  void _updateQuantity(int change) {
    final newQuantity = quantity + change;
    if (newQuantity >= 1) {
      setState(() {
        quantity = newQuantity;
      });
      _validateResellerPrice(); // Revalidate price when quantity changes
    }
  }

  void _validateResellerPrice() {
    if (resellerPrice > maxSellingPrice) {
      _resellerPriceController.text = maxSellingPrice.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'রিসেলার মূল্য সর্বোচ্চ বিক্রয় মূল্যের চেয়ে বেশি হতে পারে না')),
      );
    }
    setState(() {}); // Update profit calculation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('চেকআউট'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product and Price Summary Card
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Product Title and Image
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Image.network(
                                widget.product.thumbnail,
                                height: 60,
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.product.productName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quantity Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.remove, size: 20),
                              ),
                              onPressed: () => _updateQuantity(-1),
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.add, size: 20),
                              ),
                              onPressed: () => _updateQuantity(1),
                            ),
                          ],
                        ),

                        const Divider(),

                        // Price Grid
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _resellerPriceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: 'রিসেলার বিক্রয় মূল্য',
                                        hintStyle: TextStyle(fontSize: 9), // Set the font size here
                                        border: OutlineInputBorder(),
                                      ),
                                    ),

                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'রিসেলার প্রফিট ৳${profit.toStringAsFixed(0)}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'অ্যাডমিন মূল্য',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          '${adminPrice.toStringAsFixed(0)}৳',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'সর্বোচ্চ বিক্রয় মূল্য',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        Text(
                                          '${maxSellingPrice.toStringAsFixed(0)}৳',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Customer Information Section
                  const Text(
                    'কাস্টমার বিবরণ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'কাস্টমার নাম',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'কাস্টমার নাম দিন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'কাস্টমার নাম্বার',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'কাস্টমার নাম্বার দিন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dropdowns
                  DropdownButtonFormField<String>(
                    value: selectedDistrict,
                    decoration: const InputDecoration(
                      labelText: 'জেলা নির্বাচন করুন',
                      border: OutlineInputBorder(),
                    ),
                    items: districts.map((String district) {
                      return DropdownMenuItem(
                        value: district,
                        child: SingleChildScrollView(
                          child: Text(
                            district,
                            style: TextStyle(
                              fontFamily: 'AdorshoLipi',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDistrict = newValue;
                        _updateUpazilas(newValue!);
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'জেলা নির্বাচন করুন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedUpazila,
                    decoration: const InputDecoration(
                      labelText: 'উপজেলা নির্বাচন করুন',
                      border: OutlineInputBorder(),
                    ),
                    items: upazilas.map((String upazila) {
                      return DropdownMenuItem(
                        value: upazila,
                        child: Text(
                          upazila,
                          style: TextStyle(
                            fontFamily: 'AdorshoLipi',
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedUpazila = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'উপজেলা নির্বাচন করুন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'ডেলিভারি ঠিকানা',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'ডেলিভারি ঠিকানা দিন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'অতিরিক্ত নির্দেশ',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Order Summary
                  Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('প্রফিট'),
                              Text('৳${profit.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('বিক্রয় মূল্য'),
                              Text('৳${resellerPrice.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ডেলিভারি চার্জ'),
                              Text('৳$deliveryCharge'),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'মোট',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '৳${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _deductBalance,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'অর্ডার নিশ্চিত করুন',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Future<void> _processOrder() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://climaxitbd.com/php/shopping/place_order.php'),
        body: {
          'user_id': userId,
          'product_id': widget.product.id,
          'quantity': quantity.toString(),
          'customer_name': _nameController.text,
          'customer_phone': _phoneController.text,
          'district': selectedDistrict,
          'upazila': selectedUpazila,
          'delivery_address': _addressController.text,
          'additional_info': _instructionsController.text,
          'total_amount': total.toString(),
          'reseller_price': resellerPrice.toString(),
          'delivery_charge': deliveryCharge.toString(),
          'reseller_profit': profit.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('অর্ডার সফলভাবে সম্পন্ন হয়েছে!')),
          );
          Navigator.of(context).pop();
        } else {
          throw Exception(data['message'] ?? 'Order failed');
        }
      } else {
        throw Exception('Failed to place order');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  // decrease balance from shopping balance

  Future<void> _deductBalance() async {
    double amount = double.tryParse(total.toString()) ?? 0.0;
    try {
      var response = await http.post(

        Uri.parse("https://climaxitbd.com/php/wallet/decrease-shop-balance.php"),
        headers: {"Content-Type": "application/json"},


        body: jsonEncode({
          "user_id": userId,
          "action": "deduct_balance",
          "amount": amount,
        }),
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == "success") {
        _processOrder();

      } else {
        _showMessage(responseData['message']);
      }
    } catch (e) {
      _showMessage("অফার কেনা সম্ভব হয়নি!");
    }
  }

  // মেসেজ দেখানোর ফাংশন
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }



}
