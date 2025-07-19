abstract class BlocCommunicationEvent {
  final String type;
  final Map<String, dynamic> data;
  
  const BlocCommunicationEvent({
    required this.type,
    required this.data,
  });
}

class PostCreatedCommunicationEvent extends BlocCommunicationEvent {
  const PostCreatedCommunicationEvent({
    required super.type,
    required super.data,
  });
}

class ActivityCreatedCommunicationEvent extends BlocCommunicationEvent {
  const ActivityCreatedCommunicationEvent({
    required super.type,
    required super.data,
  });
}