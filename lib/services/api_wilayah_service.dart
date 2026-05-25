import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiWilayahService {
  static const String baseUrl = 'https://www.emsifa.com/api-wilayah-indonesia/api';

  static Future<List<Map<String, dynamic>>> getProvinces() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/provinces.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error getProvinces: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getRegencies(String provinceId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/regencies/$provinceId.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error getRegencies: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getDistricts(String regencyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/districts/$regencyId.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error getDistricts: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getVillages(String districtId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/villages/$districtId.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error getVillages: $e');
    }
    return [];
  }
}
