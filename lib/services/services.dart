import 'dart:async';
export 'src/bloc/data.dart';
export 'src/services/auth_user_service.dart';
export 'src/services/network.dart';
export 'src/services/storage.dart';
export 'src/services/user.dart';
export 'src/utils/utils.dart';
export 'src/widgets/splash_screen.dart';

Completer<dynamic> storageServiceReadyCompleter = Completer<dynamic>();
Completer<dynamic> networkServiceReadyCompleter = Completer<dynamic>();
Completer<dynamic> userServiceReadyCompleter = Completer<dynamic>();
Completer<dynamic> authUserServiceReadyCompleter = Completer<dynamic>();
Future<dynamic> get storageReady => storageServiceReadyCompleter.future;
Future<dynamic> get networkReady => networkServiceReadyCompleter.future;
Future<dynamic> get userServiceReady => userServiceReadyCompleter.future;
Future<dynamic> get authUserReady => userServiceReadyCompleter.future;
