import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:git_touch/models/code.dart';
import 'package:git_touch/models/auth.dart';
import 'package:git_touch/models/theme.dart';
import 'package:git_touch/screens/issues.dart';
import 'package:git_touch/screens/notification.dart';
import 'package:git_touch/screens/repository.dart';
import 'package:git_touch/screens/repositories.dart';
import 'package:git_touch/screens/user.dart';
import 'package:primer/primer.dart';
import 'package:provider/provider.dart';
import 'package:git_touch/models/notification.dart';
import 'screens/news.dart';
import 'screens/search.dart';
import 'screens/login.dart';
import 'screens/issue.dart';
import 'screens/trending.dart';
import 'utils/utils.dart';
import 'package:fimber/fimber.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int active = 0;
  // String login;

  @override
  void initState() {
    super.initState();
    nextTick(() {
      // FIXME:
      Provider.of<ThemeModel>(context).init();
      Provider.of<AuthModel>(context).init();
      Provider.of<CodeModel>(context).init();
    });
  }

  Widget _buildNotificationIcon(BuildContext context, bool isActive) {
    final iconData = isActive ? Icons.notifications : Icons.notifications_none;
    int count = Provider.of<NotificationModel>(context).count;
    if (count == 0) {
      return Icon(iconData);
    }

    // String text = count > 99 ? '99+' : count.toString();
    return Stack(
      children: <Widget>[
        Icon(iconData),
        Positioned(
            right: -2,
            top: -2,
            child: Icon(Octicons.primitive_dot,
                color: PrimerColors.red500, size: 14))
      ],
    );
  }

  List<BottomNavigationBarItem> get _navigationItems {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.rss_feed),
        title: Text('News'),
      ),
      BottomNavigationBarItem(
        icon: _buildNotificationIcon(context, false),
        activeIcon: _buildNotificationIcon(context, true),
        title: Text('Notification'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.trending_up),
        title: Text('Trending'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        title: Text('Search'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        title: Text('Me'),
      ),
    ];
  }

  _buildScreen(int index) {
    // return IssuesScreen(owner: 'flutter', name: 'flutter', isPullRequest: true);
    // return IssueScreen(number: 29, owner: 'reactjs', name: 'rfcs');
    // return IssueScreen(
    //     number: 68, owner: 'reactjs', name: 'rfcs', isPullRequest: true);
    // return ReposScreen('pd4d10');
    // return OrganizationScreen('flutter');
    // return TrendingScreen();
    // return RepoScreen('flutter', 'flutter');
    // return Image.asset('images/spinner.webp', width: 32, height: 32);
    switch (index) {
      case 0:
        return NewsScreen();
      case 1:
        return NotificationScreen();
      case 2:
        return TrendingScreen();
      case 3:
        return SearchScreen();
      case 4:
        return UserScreen(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    var settings = Provider.of<AuthModel>(context);
    var themData = ThemeData(
      primaryColor: PrimerColors.white,
      accentColor: PrimerColors.blue500,
    );

    // TODO:
    if (!settings.ready || !Provider.of<ThemeModel>(context).ready) {
      return MaterialApp(theme: themData, home: Scaffold(body: Text('a')));
    }

    // Fimber.d(settings.activeLogin);
    if (settings.activeAccount == null) {
      return MaterialApp(theme: themData, home: LoginScreen());
    }

    switch (Provider.of<ThemeModel>(context).theme) {
      case AppThemeType.cupertino:
        return CupertinoApp(
          home: CupertinoTheme(
            data: CupertinoThemeData(
              primaryColor: PrimerColors.blue500,
            ),
            child: CupertinoTabScaffold(
              tabBar: CupertinoTabBar(
                items: _navigationItems,
                // backgroundColor: PrimerColors.gray000, // TODO:
              ),
              tabBuilder: (context, index) {
                return CupertinoTabView(builder: (context) {
                  return _buildScreen(index);
                });
              },
            ),
          ),
        );
      default:
        return MaterialApp(
          theme: themData,
          home: Scaffold(
            body: _buildScreen(active),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: PrimerColors.blue500,
              items: _navigationItems,
              currentIndex: active,
              type: BottomNavigationBarType.fixed,
              onTap: (int index) {
                setState(() {
                  active = index;
                });
              },
            ),
          ),
        );
    }
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (context) => NotificationModel()),
        ChangeNotifierProvider(builder: (context) => ThemeModel()),
        ChangeNotifierProvider(builder: (context) => AuthModel()),
        ChangeNotifierProvider(builder: (context) => CodeModel()),
      ],
      child: Home(),
    );
  }
}

void main() async {
  // Platform messages may fail, so we use a try/catch PlatformException.

  // try {
  //   String initialLink = await getInitialLink();
  //   Fimber.d(initialLink);
  // } on PlatformException {
  //   Fimber.d('test');
  // }

  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  // Fimber.d('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"

  // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  // Fimber.d('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"

  // TODO: Later, should check to enable debug log in debug build only
  Fimber.plantTree(DebugTree());

  runApp(App());
}
