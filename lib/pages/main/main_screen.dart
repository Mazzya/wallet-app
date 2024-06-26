import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/models/settings.dart';
import 'package:qubic_wallet/pages/main/downloadCmdUtils.dart';
import 'package:qubic_wallet/pages/main/tab_explorer.dart';
import 'package:qubic_wallet/pages/main/tab_settings.dart';
import 'package:qubic_wallet/pages/main/tab_transfers.dart';
import 'package:qubic_wallet/pages/main/tab_wallet_contents.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:qubic_wallet/resources/qubic_cmd_utils.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:qubic_wallet/timed_controller.dart';
import 'package:universal_platform/universal_platform.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final PersistentTabController _controller;
  final _timedController = getIt<TimedController>();
  final QubicHubStore qubicHubStore = getIt<QubicHubStore>();
  final SettingsStore settingsStore = getIt<SettingsStore>();

  @override
  void initState() {
    super.initState();
    _timedController.setupFetchTimer(true);
    _timedController.setupSlowTimer(true);
    _controller = PersistentTabController(initialIndex: 0);

    if (!getIt.isRegistered<PersistentTabController>()) {
      getIt.registerSingleton<PersistentTabController>(_controller);
    }
  }

  List<Widget> _buildScreens() {
    return [
      const TabWalletContents(),
      const TabTransfers(),
      const TabExplorer(),
      const TabSettings()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: ChangeForeground(
            color: LightThemeColors.gradient1,
            child: Image.asset("assets/images/menu-IDs-inactive.png")),
        inactiveIcon: LightThemeColors.shouldInvertIcon
            ? ThemedControls.invertedColors(
                child: Image.asset("assets/images/menu-IDs-inactive.png"))
            : Image.asset("assets/images/menu-IDs-inactive.png"),
        contentPadding: 0,
        iconSize: 36,
        title: ("IDs"),
        textStyle: TextStyles.menuActive,
        activeColorPrimary: LightThemeColors.menuActive,
        inactiveColorPrimary: LightThemeColors.menuInactive,
      ),
      PersistentBottomNavBarItem(
        icon: ChangeForeground(
            color: LightThemeColors.gradient1,
            child: Image.asset("assets/images/menu-transactions-inactive.png")),
        inactiveIcon: LightThemeColors.shouldInvertIcon
            ? ThemedControls.invertedColors(
                child:
                    Image.asset("assets/images/menu-transactions-inactive.png"))
            : Image.asset("assets/images/menu-transactions-inactive.png"),
        title: ("Transfers"),
        textStyle: TextStyles.menuActive,
        activeColorPrimary: LightThemeColors.menuActive,
        inactiveColorPrimary: LightThemeColors.menuInactive,
      ),
      PersistentBottomNavBarItem(
        icon: ChangeForeground(
            color: LightThemeColors.gradient1,
            child: Image.asset("assets/images/menu-explorer-inactive.png")),
        inactiveIcon: LightThemeColors.shouldInvertIcon
            ? ThemedControls.invertedColors(
                child: Image.asset("assets/images/menu-explorer-inactive.png"))
            : Image.asset("assets/images/menu-explorer-inactive.png"),
        title: ("Explorer"),
        textStyle: TextStyles.menuActive,
        activeColorPrimary: LightThemeColors.menuActive,
        inactiveColorPrimary: LightThemeColors.menuInactive,
      ),
      PersistentBottomNavBarItem(
        icon: ChangeForeground(
            color: LightThemeColors.gradient1,
            child: Image.asset("assets/images/menu-settings-active.png")),
        inactiveIcon: LightThemeColors.shouldInvertIcon
            ? ThemedControls.invertedColors(
                child: Image.asset("assets/images/menu-settings-inactive.png"))
            : Image.asset("assets/images/menu-settings-inactive.png"),

        // icon: Observer(builder: (BuildContext context) {
        //   if (qubicHubStore.updateAvailable) {

        //     return const Icon(Icons.settings, color: Colors.red);
        //   }
        //   return const Icon(Icons.settings);
        // }),
        title: ("Settings"),
        textStyle: TextStyles.menuActive,
        activeColorPrimary: LightThemeColors.menuActive,
        inactiveColorPrimary: LightThemeColors.menuInactive,
      ),
    ];
  }

  Widget getMain() {
    return SafeArea(
        child: Column(children: [
      Observer(builder: (context) {
        if (qubicHubStore.updateNeeded) {
          return Container(
              width: double.infinity,
              color: Colors.red,
              child: Column(children: [
                TextButton(
                    onPressed: () {},
                    child: const Text(
                        "This is an outdated version. Please update"))
              ]));
        }
        return Container();
      }),
      Observer(builder: (context) {
        if ((qubicHubStore.notice != null) && (qubicHubStore.notice != "")) {
          return Container(
              width: double.infinity,
              color: Theme.of(context).cardColor,
              child: Column(children: [
                Flex(direction: Axis.horizontal, children: [
                  Expanded(
                      child: Padding(
                          padding:
                              const EdgeInsets.all(ThemePaddings.smallPadding),
                          child: Text(qubicHubStore.notice!,
                              softWrap: true,
                              maxLines: 3,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary)))),
                  IconButton(
                      onPressed: () {
                        qubicHubStore.setNotice(null);
                      },
                      icon: Icon(Icons.close))
                ])
              ]));
        }
        return Container();
      }),
      Expanded(
          child: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: LightThemeColors.menuBg,

        // Default is Colors.white.
        handleAndroidBackButtonPress: true, // Default is true.
        resizeToAvoidBottomInset:
            true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
        stateManagement: true, // Default is true.
        hideNavigationBarWhenKeyboardShows:
            true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(0),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8.0,
                spreadRadius: 0),
          ],
          colorBehindNavBar: Theme.of(context).cardColor,
        ),
        popAllScreensOnTapOfSelectedTab: true,
        popActionScreens: PopActionScreensType.all,
        itemAnimationProperties: const ItemAnimationProperties(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 200),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style11, // Choose the nav bar style with this property.
      ))
    ]));
  }

  @override
  Widget build(BuildContext context) {
    // if (UniversalPlatform.isDesktop && !settingsStore.cmdUtilsAvailable) {
    //   return DownloadCmdUtils();
    // }
    // return getMain();
    return Observer(builder: (context) {
      if (UniversalPlatform.isDesktop && !settingsStore.cmdUtilsAvailable) {
        return DownloadCmdUtils();
      }
      return getMain();
    });
  }
}
