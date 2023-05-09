import 'dart:convert';

import 'package:news_api/models/article.dart';
import 'package:http/http.dart' as http;

class ApiService {

  Future<List<Article>> fetchArticles(String country) async {
    final response = await http.get(

        Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=$country&category=business&apiKey=11f590b8cccc4d04be13482e1eee5f92'));
    if (response.statusCode == 200) {
      var getUsersData = json.decode(response.body);
      List<dynamic> body = getUsersData['articles'];
      var listUsers = body.map((i) => Article.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed to load articles');
    }
  }
}