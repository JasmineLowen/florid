import 'package:florid/screens/categories_screen.dart';
import 'package:florid/screens/latest_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final tabs = [LatestScreen(), CategoriesScreen()];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        // appBar: AppBar(
        //   bottom: const TabBar(
        //     tabs: [
        //       Tab(icon: Icon(Icons.new_releases), text: "Latest"),
        //       Tab(icon: Icon(Icons.directions_transit)),
        //     ],
        //   ),
        // ),
        body: Column(
          children: [
            TabBar(
              // indicatorPadding: EdgeInsetsGeometry.all(10),
              // indicatorSize: TabBarIndicatorSize.tab,
              // indicator: BoxDecoration(
              //   borderRadius: BorderRadius.circular(8),
              //   color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              // ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.new_releases, fill: 1),
                      SizedBox(width: 8),
                      Text("Latest"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Symbols.category, fill: 1),
                      SizedBox(width: 8),
                      Text("Categories"),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(child: TabBarView(children: tabs)),
          ],
        ),
      ),
    );
  }
}
