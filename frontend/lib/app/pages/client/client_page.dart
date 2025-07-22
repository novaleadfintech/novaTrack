import 'package:flutter/material.dart';
import '../../../auth/authentification_token.dart';
import '../../../model/habilitation/role_model.dart';
import '../app_tab_bar.dart';
import '../error_page.dart';
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
  late RoleModel role;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  Future<void> _initializeData() async {
    await getRole();
  }

  Future<void> getRole() async {
    try {
      setState(() {
        isLoading = true;
      });
      role = await AuthService().getRole();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        hasError = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (hasError) {
      return ErrorPage(
        message: errorMessage ?? "Une erreur s'est produite",
        onPressed: () async {
          setState(() {
            isLoading = true;
            hasError = false;
          });
          await getRole();
        },
      );
    }
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
                    role: role,
                    onDetailClients: (p0) {
                      setState(() {
                        client = p0;
                        _index = 1;
                      });
                    },
                  ),
                  ArchivedClientPage(
                    role: role,
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
