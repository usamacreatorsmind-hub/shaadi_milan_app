import 'package:cloud_firestore/cloud_firestore.dart';

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  String get value {
    switch (this) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }

  static TicketStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }

  static TicketPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TicketPriority.high;
      case 'urgent':
        return TicketPriority.urgent;
      case 'low':
        return TicketPriority.low;
      default:
        return TicketPriority.medium;
    }
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
  final String? assignedToId;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.subject,
    required this.description,
    this.status = TicketStatus.open,
    this.priority = TicketPriority.medium,
    this.category,
    this.attachments = const [],
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.adminResponse,
    this.assignedToId,
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
      'assignedToId': assignedToId,
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
      priority: TicketPriority.fromString(map['priority'] as String? ?? 'medium'),
      category: map['category'] as String?,
      attachments: List<String>.from(map['attachments'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
      adminResponse: map['adminResponse'] as String?,
      assignedToId: map['assignedToId'] as String?,
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
    String? assignedToId,
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
      assignedToId: assignedToId ?? this.assignedToId,
    );
  }
}

class SupportState {
  final SupportTicket? supportTicket;
  final bool isLoading;
  final String? error;

  const SupportState({this.supportTicket, this.isLoading = false, this.error});

  SupportState copyWith({
    SupportTicket? supportTicket,
    bool? isLoading,
    String? error,
  }) {
    return SupportState(
      supportTicket: supportTicket ?? this.supportTicket,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory SupportState.initial() => const SupportState();
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
