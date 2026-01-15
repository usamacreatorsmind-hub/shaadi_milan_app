import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketStatus {
  pending,
  resolved,
  rejected,
  closed;

  /// UI text (must be UNIQUE)
  String get displayName {
    switch (this) {
      case TicketStatus.pending:
        return 'Pending';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.rejected:
        return 'Rejected';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  /// Firestore value (stable & lowercase)
  String get value => name;

  static TicketStatus fromString(String status) {
    return TicketStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => TicketStatus.pending,
    );
  }
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName => name[0].toUpperCase() + name.substring(1);

  static TicketPriority fromString(String priority) {
    return TicketPriority.values.firstWhere(
      (e) => e.name == priority.toLowerCase(),
      orElse: () => TicketPriority.medium,
    );
  }
}

class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final String? category;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;
  final String? adminResponse;
  final String agentId;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.description,
    this.status = TicketStatus.pending,
    this.priority = TicketPriority.medium,
    this.category,
    this.attachments = const [],
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.adminResponse,
    required this.agentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'subject': subject,
      'description': description,
      'status': status.value,
      'priority': priority.name,
      'category': category,
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'adminResponse': adminResponse,
      'agentId': agentId,
    };
  }

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userEmail: map['userEmail'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      description: map['description'] as String? ?? '',
      status: TicketStatus.fromString(map['status'] as String? ?? 'open'),
      priority: TicketPriority.fromString(
        map['priority'] as String? ?? 'medium',
      ),
      category: map['category'] as String?,
      attachments: List<String>.from(map['attachments'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      adminResponse: map['adminResponse'] as String?,

      agentId: map['agentId'] as String? ?? '',
    );
  }

  SupportTicket copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? subject,
    String? description,
    TicketStatus? status,
    TicketPriority? priority,
    String? category,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? adminResponse,
    String? agentId,
  }) {
    return SupportTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      agentId: agentId ?? this.agentId,
    );
  }
}

class SupportTicketState {
  final SupportTicket? supportTicket;
  final bool isLoading;
  final String? error;

  const SupportTicketState({
    this.supportTicket,
    this.isLoading = false,
    this.error,
  });

  SupportTicketState copyWith({
    SupportTicket? supportTicket,
    bool? isLoading,
    String? error,
  }) {
    return SupportTicketState(
      supportTicket: supportTicket ?? this.supportTicket,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory SupportTicketState.initial() => const SupportTicketState();
}

class AllSupportTicketsState {
  final List<SupportTicket> tickets;
  final bool isLoading;
  final String? error;

  const AllSupportTicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
  });

  AllSupportTicketsState copyWith({
    List<SupportTicket>? tickets,
    bool? isLoading,
    String? error,
  }) {
    return AllSupportTicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory AllSupportTicketsState.initial() => const AllSupportTicketsState();
}
