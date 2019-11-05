import 'package:meta/meta.dart';
import 'package:grpc/grpc.dart';
import 'package:repository/repository.dart';
import 'package:repository_hive/repository_hive.dart';
import '../../services/services.dart';

import '../../conversations/bloc/bloc.dart';
import '../../conversations/bloc/data.dart';
import 'data.dart';

class ChatBloc {
  ChatBloc(
      {@required this.network,
      @required this.user,
      @required this.conversationsId})
      : assert(network != null),
        assert(user != null),
        _chats = CachedRepository<ChatModel>(
          // strategy: CacheStrategy.onlyFetchFromSourceIfNotInCache,
          source: _ChatFetcher(
              network: network, user: user, conversationsId: conversationsId),
          cache: HiveRepository<ChatModel>('chats'),
        ),
        _conversations = CachedRepository<Conversations>(
          // strategy: CacheStrategy.onlyFetchFromSourceIfNotInCache,
          source: ConversationsDownloader(network: network, user: user),
          cache: HiveRepository<Conversations>('conversations'),
        );

  final NetworkService network;
  final UserService user;
  final String conversationsId;
  final Repository<ChatModel> _chats;
  final Repository<Conversations> _conversations;

  Stream<List<ChatModel>> getChats() => _chats.fetchAllItems();
  Future<Conversations> getConversation(Id<Conversations> id) =>
      _conversations.fetch(id).first;
  Future<User> getCurrentUser() async {
    // TODO(Vineeth): Remove this logic later once authentication is complete
    return user.getUser(const Id<User>('A'));
  }

  Future<dynamic> sendChat(ChatModel chat) async {
    network.send(
      MessageHandler<ChatModel>(
        message: chat,
        status: MessageStatus.NEW,
        messageType: MessageType.CHAT,
      ),
    );
  }
}

class _ChatFetcher extends CollectionFetcher<ChatModel> {
  _ChatFetcher(
      {@required this.network,
      @required this.user,
      @required this.conversationsId});

  final NetworkService network;
  final UserService user;
  final String conversationsId;
  @override
  Future<List<ChatModel>> downloadAll() async {
    final List<Map<String, dynamic>> dataList = await network.getAllItemForId(
      path: 'chats',
      field: 'conversationsId',
      id: conversationsId,
    );

    return <ChatModel>[
      // ignore: sdk_version_ui_as_code
      for (dynamic data in dataList)
        ChatModel(
          id: Id<ChatModel>(data['_id']),
          text: data['text'],
          uid: Id<User>(data['uid']),
          user: await user.getUser(Id<User>(data['uid'])),
          createdAt: DateTime.parse(data['createdAt']),
          attachmentType: _getAttachmentType(data),
          attachmentUrl: data['attachmentUrl'],
          conversationsId: data['conversationsId'],
        ),
    ];
  }

  static AttachmentType _getAttachmentType(Map<String, dynamic> data) {
    AttachmentType type;
    switch (data['attachmentType']) {
      case 'image':
        type = AttachmentType.image;
        break;
      case 'file':
        type = AttachmentType.file;
        break;
      case 'video':
        type = AttachmentType.video;
        break;
      case 'geolocation':
        type = AttachmentType.geolocation;
        break;
      case 'calender':
        type = AttachmentType.calender;
        break;
      default:
        return AttachmentType.none;
    }
    return type;
  }
}
