import 'package:flutter/material.dart';
import '../../global/constant/general_menu_constants.dart';
import '../../model/habilitation/role_model.dart';
import '../responsitvity/responsivity.dart';
import '../../widget/header.dart';
import '../../widget/side_bar.dart';

class MainLayout extends StatefulWidget {
  final RoleModel role;
  const MainLayout({
    super.key,
    required this.role,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  int currentIndex = 0;

  late final List<Widget> pages;
  late final List<(String, String, int)> menu;

  @override
  void initState() {
    super.initState();
    final (filteredMenu, filteredPages) = getMenuAndPages(widget.role);
    menu = filteredMenu;
    pages = filteredPages;
  }

  Widget getPage(int index) {
    return pages[index];
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = Responsive.isDesktop(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: isDesktop
            ? null
            : AppBar(
                forceMaterialTransparency: false,
                automaticallyImplyLeading: true,
                title: Header(
                  title: menu[currentIndex].$1,
                ),
              ),
        drawer: isDesktop
            ? null
            : Drawer(
                key: _drawerKey,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                // backgroundColor: Theme.of(context).colorScheme.primary,
                // surfaceTintColor: Theme.of(context).colorScheme.error,
                width: 260,
                child: SideBar(
                  isMobile: true,
                  currentIndex: currentIndex,
                  getcurrentIndex: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  menu: menu,
                ),
              ),
        body: Row(
          children: [
            if (isDesktop)
              SideBar(
                currentIndex: currentIndex,
                getcurrentIndex: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                menu: menu,
              ),
            Expanded(
              child: Column(
                children: [
                  if (isDesktop)
                    Header(
                      title: menu[currentIndex].$1,
                    ),
                  Expanded(
                    child: getPage(currentIndex),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
