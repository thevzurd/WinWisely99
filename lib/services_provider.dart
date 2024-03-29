import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO(FlutterDevelopers): Import modules here
import 'package:com.winwisely99.app/chat_view/chat_view.dart';
import 'package:com.winwisely99.app/services/services.dart';
import 'hive.dart';
import 'navigation.dart';

class ServicesProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        // Initializes hive and offers a service that stores app-wide data.
        FutureProvider<StorageService>(
          builder: (BuildContext context) async {
            await initializeHive();
            final StorageService storage = StorageService();
            // TODO(Vineeth): Removed await for now. Need to fix this later
            storage.initialize();
            print('${DateTime.now().toUtc().toString()} StorageService');
            storageServiceReadyCompleter.complete();
            return storage;
          },
        ),
        // This service offers network calls and automatically enriches the
        // header using the authentication provided by the
        // [AuthenticationStorageService].
        ProxyProvider<StorageService, NetworkService>(
          builder: (
            BuildContext _,
            StorageService storage,
            NetworkService __,
          ) {
            print(
                '${DateTime.now().toUtc().toString()} NetworkService $storage');
            return storage == null
                ? null
                : NetworkService('unique',
                    storage: storage,
                    subscriptions: <MessageType, Subscriptions<dynamic>>{
                        MessageType.CHAT: Subscriptions<Chat>(
                          receivingIsolate: chatIncoming,
                          sendingIsolate: chatOutgoing,
                          onSendDo: chatOnSendDo,
                          onRecieveDo: chatOnRecieveDo,
                        ),
                      });
          },
        ),
        // This service offers fetching of users.
        ProxyProvider<NetworkService, UserService>(
          builder: (
            BuildContext _,
            NetworkService network,
            UserService __,
          ) {
            print('${DateTime.now().toUtc().toString()} UserService $network');
            return network == null ? null : UserService(network: network);
          },
        ),
        // This service offers fetching of the currently logged in user.
        ProxyProvider2<StorageService, UserService, AuthUserService>(
          builder: (
            BuildContext _,
            StorageService storage,
            UserService user,
            AuthUserService __,
          ) {
            print(
                '${DateTime.now().toUtc().toString()} GlobalUserService $user');
            return storage == null || user == null
                ? null
                : AuthUserService(storage: storage, user: user);
          },
          dispose: (BuildContext _, AuthUserService authUser) =>
              authUser?.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'WinWisely99',
        initialRoute: '/',
        onGenerateRoute: routes,
      ),
    );
  }
}
