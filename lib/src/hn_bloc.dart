import 'dart:async';
import 'dart:collection';

import 'package:hn_app/src/article.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class HackerNewsApiError extends Error {
  final String message;

  HackerNewsApiError(this.message);
}

class HackerNewsStream {
  HashMap<int, Article> _cachedArticles;
  static const _baseUrl = 'https://hacker-news.firebaseio.com/v0/';

  final _topArticlesSubject = BehaviorSubject<List<Article>>();
  final _newArticlesSubject = BehaviorSubject<List<Article>>();

  HackerNewsStream() {
    _cachedArticles = HashMap<int, Article>();
    _initializeArticles();
  }

  Stream<List<Article>> get topArticles => _topArticlesSubject.stream;
  Stream<List<Article>> get newArticles => _newArticlesSubject.stream;

  Future<void> _initializeArticles() async {
    _getArticlesAndUpdate();
  }

  Future<Article> _getArticle(int id) async {
    if (!_cachedArticles.containsKey(id)) {
      final storyUrl = '${_baseUrl}item/$id.json';
      final storyRes = await http.get(storyUrl);
      if (storyRes.statusCode == 200) {
        _cachedArticles[id] = parseArticle(storyRes.body);
      } else {
        throw HackerNewsApiError("Article $id couldn't be fetched.");
      }
    }
    return _cachedArticles[id];
  }

  _getArticlesAndUpdate() async {
    var topIds = await _getIds(StoriesType.topStories);
    var newIds = await _getIds(StoriesType.newStories);
    _topArticlesSubject.add(await _updateArticles(topIds));
    _newArticlesSubject.add(await _updateArticles(newIds));
  }

  Future<List<int>> _getIds(StoriesType type) async {
    final partUrl = type == StoriesType.topStories ? 'top' : 'new';
    final url = '$_baseUrl${partUrl}stories.json';
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw HackerNewsApiError("Stories $type couldn't be fetched.");
    }
    return parseTopStories(response.body).take(10).toList();
  }

  Future<List<Article>> _updateArticles(List<int> articleIds) async {
    final futureArticles = articleIds.map((id) => _getArticle(id));
    return Future.wait(futureArticles);
  }
}

enum StoriesType {
  topStories,
  newStories,
}
