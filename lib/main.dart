import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  bool isFavorite() {
    return favorites.contains(current);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritePage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text("Главный экран"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text("Фавориты"),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: theme.colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var theme = Theme.of(context);
    var textStyle = TextStyle(color: theme.colorScheme.primary);
    var buttonStyle = ButtonStyle(backgroundColor: MaterialStateProperty.all(theme.colorScheme.background));

    if (favorites.isEmpty) {
      return Center(
        child: Text("No Favorites found"),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: favorites
            .map(
              (favorite) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton.icon(
                  style: buttonStyle,
                  onPressed: () {},
                  label: Text(
                    favorite.asLowerCase,
                    style: textStyle,
                  ),
                  icon: Icon(
                    Icons.favorite,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [MainCard(pair: pair), SizedBox(height: 16), ButtonsBlock()],
      ),
    );
  }
}

class ButtonsBlock extends StatelessWidget {
  const ButtonsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    IconData icon;
    if (appState.isFavorite()) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            appState.toggleFavorite();
          },
          icon: Icon(icon),
          label: Text("Нравится"),
        ),
        SizedBox(width: 16),
        ElevatedButton(
            onPressed: () {
              appState.getNext();
            },
            child: Text("Дальше")),
      ],
    );
  }
}

class MainCard extends StatelessWidget {
  const MainCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textStyle = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          pair.asLowerCase,
          style: textStyle,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
