import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/providers/backend_list_provided.dart';
import 'package:common/communication_protocol.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/persons/admin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminsProvider extends BackendListProvided<Admin> {
  AdminsProvider({required super.uri, super.mockMe});

  static AdminsProvider of(BuildContext context, {listen = false}) =>
      Provider.of<AdminsProvider>(context, listen: listen);

  @override
  RequestFields getField([bool asList = false]) =>
      asList ? RequestFields.admins : RequestFields.admin;

  @override
  Admin deserializeItem(data) {
    return Admin.fromSerialized(data);
  }

  void initializeAuth(AuthProvider auth) {
    if (!auth.isFullySignedIn ||
        (auth.databaseAccessLevel ?? AccessLevel.teacher) <=
            AccessLevel.superAdmin) {
      return;
    }

    initializeFetchingData(authProvider: auth);
    auth.addListener(() => initializeFetchingData(authProvider: auth));
  }

  Future<bool> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await sendMessageWithResponse(
        message: CommunicationProtocol(
          requestType: RequestType.register,
          field: RequestFields.teacher,
          data: {'email': email, 'password': password},
        ),
      );

      return response.response == Response.success;
    } catch (e) {
      return false;
    }
  }
}
