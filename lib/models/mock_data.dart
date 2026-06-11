import 'procurement_order.dart';

List<ProcurementOrder> getPrepopulatedOrders() {
  return [
    ProcurementOrder(
      orderNo: "#ORD-2024-0019A",
      supplier: "Cisco Systems Intl.",
      originator: "Sarah Jenkins (Infrastructure)",
      amount: 450000.00,
      status: "PENDING APPROVAL",
      badgeType: "High Value",
      projectId: "PRJ-INF-2024-C3",
      orderDate: "June 11, 2024",
      shippingAddress: "HLW Data Center West\n1200 Silicon Blvd, Suite 400\nSalt Lake City, UT 84101",
      billingInfo: "Accounts Payable Dept\nHLW Headquarters, Floor 14\nNew York, NY 10001",
      lineItems: [
        LineItem(
          itemCode: "CS-9500-48X",
          description: "Catalyst 9500 48-port 25G Switch Enterprise Backbone Routing",
          qty: 6,
          unitCost: 55000.00,
        ),
        LineItem(
          itemCode: "SFP-25G-SR-S",
          description: "25GBASE-SR SFP28 Module for multi-mode fiber transceivers",
          qty: 48,
          unitCost: 2500.00,
        ),
      ],
      attachments: [
        Attachment(name: "technical_network_topology.pdf", role: "Engineering Team Ref", fileType: "pdf"),
        Attachment(name: "cisco_quote_authorized_v2.pdf", role: "Vendor Validated Quote", fileType: "pdf"),
        Attachment(name: "security_clearance_signoff.png", role: "SecOps Compliance Authorization", fileType: "image"),
      ],
    ),
    ProcurementOrder(
      orderNo: "#ORD-2024-0022B",
      supplier: "Grainger Industrial",
      originator: "Donald Carter (Facilities)",
      amount: 14500.00,
      status: "PENDING APPROVAL",
      badgeType: "Today",
      projectId: "PRJ-FAC-2024-F9",
      orderDate: "June 11, 2024",
      shippingAddress: "HLW Logistics Center\n450 Industrial Parkway\nChicago, IL 60609",
      billingInfo: "Finance Operations Office\nHLW Headquarters, Floor 14\nNew York, NY 10001",
      lineItems: [
        LineItem(
          itemCode: "HVAC-BLW-09",
          description: "Centrifugal Cabinet Fans - Industrial Air Control System",
          qty: 2,
          unitCost: 6500.00,
        ),
        LineItem(
          itemCode: "FILT-M13-10",
          description: "MERV 13 Premium Air Filter Pack (Case of 10 items)",
          qty: 15,
          unitCost: 100.00,
        ),
      ],
      attachments: [
        Attachment(name: "facilities_replacement_ticket.pdf", role: "Internal Services Ticket", fileType: "pdf"),
      ],
    ),
    ProcurementOrder(
      orderNo: "#ORD-2024-0034X",
      supplier: "Carahsoft Technology",
      originator: "Marcus Sterling (IT Security)",
      amount: 189000.00,
      status: "PENDING APPROVAL",
      badgeType: "High Value",
      projectId: "PRJ-SEC-2024-S01",
      orderDate: "June 10, 2024",
      shippingAddress: "HLW Cyber Security Lab\n800 Security Way, Bldg B\nAustin, TX 78701",
      billingInfo: "Corporate AP Operations\nHLW Headquarters, Floor 14\nNew York, NY 10001",
      lineItems: [
        LineItem(
          itemCode: "OKTA-ENT-L",
          description: "Okta Enterprise Access Management Annual Identity License Subscription",
          qty: 1200,
          unitCost: 150.00,
        ),
        LineItem(
          itemCode: "CS-DRT-SUPPORT",
          description: "Direct 24/7 Priority Emergency Security Incident Engineering Support",
          qty: 1,
          unitCost: 9000.00,
        ),
      ],
      attachments: [
        Attachment(name: "salesforce_soc2_type2_assessment.pdf", role: "Security Team Audit File", fileType: "pdf"),
        Attachment(name: "carahsoft_commercial_proposal.pdf", role: "Binding Legal Agreement", fileType: "pdf"),
      ],
    ),
    ProcurementOrder(
      orderNo: "#ORD-2024-0045Y",
      supplier: "Dell Technologies",
      originator: "Elena Rostova (DevOps)",
      amount: 87400.00,
      status: "PENDING APPROVAL",
      badgeType: "Pending",
      projectId: "PRJ-OPS-2024-D4",
      orderDate: "June 08, 2024",
      shippingAddress: "HLW Engineering Hub\n500 Technology Dr\nSeattle, WA 98101",
      billingInfo: "Finance Operations Office\nHLW Headquarters, Floor 14\nNew York, NY 10001",
      lineItems: [
        LineItem(
          itemCode: "DELL-R760",
          description: "PowerEdge R760 Rack Server with Intel Xeon dual processors",
          qty: 4,
          unitCost: 19850.00,
        ),
        LineItem(
          itemCode: "MEM-64G-DDR5",
          description: "Dell 64GB DDR5 Server RAM Upgrade Module",
          qty: 32,
          unitCost: 250.00,
        ),
      ],
      attachments: [
        Attachment(name: "hardware_needs_justification.pdf", role: "Product Management Approval", fileType: "pdf"),
      ],
    ),
  ];
}
