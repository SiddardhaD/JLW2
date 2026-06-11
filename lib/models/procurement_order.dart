class ProcurementOrder {
  final String orderNo;
  final String supplier;
  final String originator;
  final double amount;
  final String status; // "PENDING APPROVAL", "APPROVED", "REJECTED"
  final String badgeType; // "High Value", "Today", "Pending"
  final String projectId;
  final String orderDate;
  final String shippingAddress;
  final String billingInfo;
  final List<LineItem> lineItems;
  final List<Attachment> attachments;

  ProcurementOrder({
    required this.orderNo,
    required this.supplier,
    required this.originator,
    required this.amount,
    required this.status,
    required this.badgeType,
    required this.projectId,
    required this.orderDate,
    required this.shippingAddress,
    required this.billingInfo,
    required this.lineItems,
    required this.attachments,
  });

  ProcurementOrder copyWith({String? status}) {
    return ProcurementOrder(
      orderNo: orderNo,
      supplier: supplier,
      originator: originator,
      amount: amount,
      status: status ?? this.status,
      badgeType: badgeType,
      projectId: projectId,
      orderDate: orderDate,
      shippingAddress: shippingAddress,
      billingInfo: billingInfo,
      lineItems: lineItems,
      attachments: attachments,
    );
  }
}

class LineItem {
  final String itemCode;
  final String description;
  final int qty;
  final double unitCost;

  LineItem({
    required this.itemCode,
    required this.description,
    required this.qty,
    required this.unitCost,
  });

  double get totalCost => qty * unitCost;
}

class Attachment {
  final String name;
  final String role;
  final String fileType; // "pdf", "image", "other"

  Attachment({
    required this.name,
    required this.role,
    required this.fileType,
  });
}
