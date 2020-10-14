import 'package:rxdart/rxdart.dart';

class MessagesBloc {
  final _groupIds = PublishSubject<List<String>>();

  //Add data to the stream
  Stream<List<String>> get groupIds => _groupIds.stream;

  dispose() {
    _groupIds.close();
  }
}
