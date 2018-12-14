import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:hn_app/src/article.dart';
import 'package:hn_app/src/hn_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  final hnBloc = HackerNewsStream();
  runApp(MyApp(bloc: hnBloc));
}

class MyApp extends StatelessWidget {
  final HackerNewsStream bloc;

  MyApp({
    Key key,
    this.bloc,
  }) : super(key: key);

  static const primaryColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(
        title: 'Flutter Hacker News',
        stream: bloc,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final HackerNewsStream stream;

  final String title;

  MyHomePage({Key key, this.title, this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
          length: 2,
          child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: TabBarView(
          children: <Widget>[
            StreamBuilder<List<Article>>(
              stream: stream.topArticles,
              initialData: <Article>[],
              builder: (context, snapshot) => ListView(
                    children: snapshot.data.map((article) => _buildItem(article, context)).toList(),
                  ),
            ),
            StreamBuilder<List<Article>>(
              stream: stream.newArticles,
              initialData: <Article>[],
              builder: (context, snapshot) => ListView(
                    children: snapshot.data.map((article) => _buildItem(article, context)).toList(),
                  ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[200]))),
          child: TabBar(
            labelColor: Theme.of(context).accentColor,
            unselectedLabelColor: Theme.of(context).disabledColor,
            tabs: [
              Tab(
                text: 'Top Stories',
                icon: Icon(Icons.arrow_drop_up),
              ),
              Tab(
                text: 'New Stories',
                icon: Icon(Icons.new_releases),
              ),
            ],
            /*onTap: (index) {
              if (index == 0) {
                widget.bloc.storiesType.add(StoriesType.topStories);
              } else {
                widget.bloc.storiesType.add(StoriesType.newStories);
              }
              setState(() {
                _currentIndex = index;
              });
            },*/
          ),
        ),
      ),
    );
  }

  Widget _buildItem(Article article, BuildContext context) {
    return ExpansionTile(
      //key: Key(article.title),
      title: Text(article.title ?? '[null]'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text('${article.descendants} comments'),
                  IconButton(
                    icon: Icon(Icons.launch),
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Scaffold(
                                  appBar: AppBar(title: Text(article.title)),
                                  body: WebView(
                                    initialUrl: article.url,
                                    javaScriptMode: JavaScriptMode.unrestricted,
                                  ))));
                    },
                  )
                ],
              ),
              Container(
                  child: WebView(
                    initialUrl: article.url,
                    gestureRecognizers: Set()
                      ..add(Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer())),
                  ),
                  height: 200),
            ],
          ),
        ),
      ],
    );
  }
}
