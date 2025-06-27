import 'dart:convert';

import '../global/config.dart';
import '../model/habilitation/module_permission_model.dart';
import 'package:http/http.dart' as http;

import 'request_header.dart';

class ModulePermissionService {
  static Future<List<ModulePermissionModel>> getModuleParmission(
      {required String id}) async {
     try {
      var body = '''
      query PermissionByRole {
          permissionByRole (roleId:"$id"){
              module {
                _id
                name
                alias
              }
              permissions{
                _id
                libelle
                alias
                isChecked
              }
          }
      }
    ''';

      var response = await http.post(
        Uri.parse(serverUrl),
        body: json.encode({'query': body}),
        headers: getHeaders(),
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        var data = jsonData['data']['permissionByRole'];
        List<ModulePermissionModel> modulePermission = [];
        if (data != null) {
          for (var role in data) {
            modulePermission.add(ModulePermissionModel.fromJson(role));
          }
          return modulePermission;
        } else {
          return [];
        }
      } else {
        throw Exception(jsonDecode(response.body)['errors'][0]['message']);
      }
    } catch (err) {
      rethrow;
    }
  }
}
