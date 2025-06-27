import 'package:flutter/material.dart';
import '../app_tab_bar.dart';
import 'archived_clients_page.dart';
import 'unarchived_clients_page.dart';
import 'more_detail_client.dart';
import '../../../model/client/client_model.dart';
import '../../../model/client/enum_client.dart';
import 'package:gap/gap.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  ClientModel? client;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 0, left: 8, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_index == 1 && client != null)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _index = 0;
                      client = null;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(4),
                      const Text(
                        'Détails',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          Expanded(
              child: IndexedStack(
            index: _index,
            children: [
              AppTabBar(
                tabTitles: [
                  EtatClient.unarchived.label,
                  EtatClient.archived.label,
                ],
                views: [
                  UnarchivedClientPage(
                    onDetailClients: (p0) {
                      setState(() {
                        client = p0;
                        _index = 1;
                      });
                    },
                  ),
                  ArchivedClientPage(
                    onDetailClients: (p0) {
                      setState(() {
                        client = p0;
                        _index = 1;
                      });
                    },
                  ),
                ],
              ),
              client != null
                  ? MoreDatailClientPage(
                      client: client!,
                      refresh: () async {
                        setState(() {});
                      },
                    )
                  : Container()
            ],
          ))
        ],
      ),
    );
  }
}
