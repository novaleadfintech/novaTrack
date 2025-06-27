import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import '../style/app_color.dart';

class AppAccordion extends StatefulWidget {
  final Color headercolor;
  final Widget header;
  final Widget content;
final bool isOpen;
  const AppAccordion({
    super.key,
    this.headercolor = AppColor.grayprimary,
    required this.header,
    required this.content,
    this.isOpen = false,
  });

  @override
  State<AppAccordion> createState() => _AppAccordionState();
}

class _AppAccordionState extends State<AppAccordion> {
  @override
  Widget build(BuildContext context) {
    Color headercolor = AppColor.grayprimary;
    return Accordion(
      openAndCloseAnimation: true,
      maxOpenSections: 1,
      paddingListHorizontal: 4,
      paddingListBottom: 4,
      paddingListTop: 2,
      disableScrolling: true,
      //headerBorderColor: Colors.red,
      //headerBorderWidth: 50,
      // Configurer les propriétés de l'accordéon
      children: [
        AccordionSection(
          headerBackgroundColor: Theme.of(context).colorScheme.surface,
          headerPadding: const EdgeInsets.symmetric(
            //horizontal: 8,
            vertical: 0,
          ),
          isOpen: widget.isOpen,
          paddingBetweenClosedSections: 0,
          paddingBetweenOpenSections: 0,
          headerBackgroundColorOpened: headercolor.withOpacity(0.7),
          contentBackgroundColor: headercolor.withOpacity(0.05),
          contentBorderColor: headercolor,
          contentBorderWidth: 1,
          headerBorderRadius: 4,
          contentBorderRadius: 4,
          header: widget.header,
          content: widget.content,
        ),
      ],
    );
  }
}
