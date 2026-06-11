import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/procurement_order.dart';
import '../theme/colors.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderNo;
  final ProcurementOrder? order;
  final ValueChanged<String> onApprove;
  final ValueChanged<String> onReject;
  final VoidCallback onBack;

  const OrderDetailScreen({
    super.key,
    required this.orderNo,
    required this.order,
    required this.onApprove,
    required this.onReject,
    required this.onBack,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  // Simple view zoom multiplier simulation
  double _pdfZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    if (widget.order == null) {
      return Scaffold(
        backgroundColor: SystemColors.pageBackground,
        body: const Center(
          child: CircularProgressIndicator(color: SystemColors.corporateGreen),
        ),
      );
    }

    final order = widget.order!;
    final totalAmount = order.lineItems.fold<double>(0, (sum, item) => sum + item.totalCost);
    final taxAmount = totalAmount * 0.085;
    final grandTotal = totalAmount + taxAmount;

    return Scaffold(
      backgroundColor: SystemColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: SystemColors.textDark),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: [
            Text(
              "JLW",
              style: GoogleFonts.serif(
                fontWeight: FontWeight.black,
                fontSize: 20,
                color: SystemColors.corporateNavy,
              ),
            ),
            const SizedBox(width: 6),
            const Text("|", style: TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              "HLW",
              style: GoogleFonts.sansSerif(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: SystemColors.corporateGreen,
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(order),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Segment
            Text(
              "PROCUREMENT ORDER",
              style: GoogleFonts.sansSerif(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: SystemColors.textGray,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.orderNo,
              style: GoogleFonts.serif(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: SystemColors.corporateGreen,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                _buildHeaderMetaCol("Project ID", order.projectId),
                const SizedBox(width: 24),
                _buildHeaderMetaCol("Order Date", order.orderDate),
              ],
            ),
            
            const SizedBox(height: 12),
            _buildStatusBadge(order.status, order.badgeType),
            
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE5EEFF)),
            const SizedBox(height: 16),
            
            // 1. Line Item Breakdown Table Layout
            Text(
              "LINE ITEM BREAKDOWN",
              style: GoogleFonts.mono(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: SystemColors.corporateNavy,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            _buildLineItemTable(order.lineItems, totalAmount, taxAmount, grandTotal),
            
            const SizedBox(height: 16),
            
            // 2. Shipping Address Card
            _buildAddressCard(
              title: "SHIPPING ADDRESS",
              content: order.shippingAddress,
              icon: Icons.local_shipping,
            ),
            
            const SizedBox(height: 16),
            
            // 3. Billing Address Card
            _buildAddressCard(
              title: "BILLING INFORMATION",
              content: order.billingInfo,
              icon: Icons.receipt_long,
            ),
            
            const SizedBox(height: 24),
            
            // 4. Embedded PDF Document Viewer Previews
            Text(
              "DOCUMENT VIEWER",
              style: GoogleFonts.mono(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: SystemColors.corporateNavy,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildPdfDocumentView(
              fileName: "purchase_order_${order.orderNo.replaceAll('#', '')}.pdf",
              pageString: "1 / 4",
              titleText: "PURCHASE ORDER DETAILS",
              infoLines: [
                "Supplier: ${order.supplier}",
                "Originator: ${order.originator}",
                "Total Amount: \$${_formatCurrency(grandTotal)} USD",
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildPdfDocumentView(
              fileName: "Vendor_Quote_HLW_99284.pdf",
              pageString: "1 / 4",
              titleText: "VENDOR QUOTE & TERMS",
              infoLines: [
                "Primary Commercial Terms",
                "Net 30 Days Operations",
                "Logistical Freight Costs Included",
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 5. Attachments cards
            _buildAttachmentsSection(order.attachments),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMetaCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sansSerif(color: SystemColors.textGray, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: GoogleFonts.sansSerif(color: SystemColors.textDark, fontSize: 14, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildLineItemTable(List<LineItem> items, double subtotal, double tax, double total) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE5EEFF)),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            color: const Color(0xFFE5EEFF),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _cellText("Item", flex: 3, isHeader: true),
                _cellText("Description", flex: 7, isHeader: true),
                _cellText("Qty", flex: 2, isHeader: true, align: TextAlign.center),
                _cellText("Unit Cost", flex: 4, isHeader: true, align: TextAlign.end),
              ],
            ),
          ),
          
          // Data Rows
          ...List.generate(items.length, (idx) {
            final item = items[idx];
            final isAlternate = idx % 2 == 1;
            return Container(
              color: isAlternate ? SystemColors.containerBlue : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  _cellText(item.itemCode, flex: 3, isBoldCode: true),
                  _cellText(item.description, flex: 7, color: SystemColors.textBody),
                  _cellText(item.qty.toString(), flex: 2, align: TextAlign.center, color: SystemColors.textBody),
                  _cellText("\$${_formatCurrency(item.unitCost)}", flex: 4, align: TextAlign.end, color: SystemColors.textBody),
                ],
              ),
            );
          }),
          
          const Divider(color: Color(0xFFE5EEFF), height: 1),
          
          // Calculative Breakdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _calcRow("Subtotal", "\$${_formatCurrency(subtotal)}"),
                const SizedBox(height: 6),
                _calcRow("Tax (8.5%)", "\$${_formatCurrency(tax)}"),
                const SizedBox(height: 10),
                const Divider(color: Color(0xFFE5EEFF)),
                const SizedBox(height: 10),
                
                // Highlight Total Container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6EE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total (USD)",
                        style: GoogleFonts.sansSerif(
                          fontWeight: FontWeight.bold,
                          color: SystemColors.corporateGreen,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "\$${_formatCurrency(total)}",
                        style: GoogleFonts.sansSerif(
                          fontWeight: FontWeight.black,
                          color: SystemColors.corporateGreen,
                          fontSize: 22,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellText(String text, {
    required int flex, 
    bool isHeader = false, 
    TextAlign align = TextAlign.start,
    Color? color,
    bool isBoldCode = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: GoogleFonts.sansSerif(
          fontSize: 12,
          fontWeight: isHeader 
              ? FontWeight.bold 
              : (isBoldCode ? FontWeight.bold : FontWeight.normal),
          color: isHeader 
              ? SystemColors.textDark 
              : (isBoldCode ? SystemColors.corporateGreen : (color ?? SystemColors.textDark)),
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _calcRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.sansSerif(color: SystemColors.textGray, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.sansSerif(color: SystemColors.textDark, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAddressCard({required String title, required String content, required IconData icon}) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE5EEFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF476083), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SystemColors.corporateNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.leading(28), // custom margin extension fallback
              child: Text(
                content,
                style: GoogleFonts.sansSerif(
                  color: SystemColors.textBody,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfDocumentView({
    required String fileName,
    required String pageString,
    required String titleText,
    required List<String> infoLines,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE5EEFF)),
      ),
      child: SizedBox(
        height: 340,
        child: Column(
          children: [
            // PDF Toolbar banner
            Container(
              decoration: const BoxDecoration(
                color: SystemColors.containerBlue,
                border: Border(bottom: BorderSide(color: Color(0xFFE5EEFF), width: 0.6)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description, color: Color(0xFFBA1A1A), size: 20),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
                        child: Text(
                          fileName,
                          style: GoogleFonts.sansSerif(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: SystemColors.corporateNavy,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // Zooming tool controls
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.zoom_out, color: Color(0xFF476083), size: 18),
                        onPressed: () {
                          setState(() {
                            if (_pdfZoom > 0.6) _pdfZoom -= 0.1;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Text(
                        pageString,
                        style: GoogleFonts.sansSerif(
                          fontSize: 12,
                          color: SystemColors.textBody,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.zoom_in, color: Color(0xFF476083), size: 18),
                        onPressed: () {
                          setState(() {
                            if (_pdfZoom < 1.6) _pdfZoom += 0.1;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            // Desk paper canvas drawing
            Expanded(
              child: Container(
                color: const Color(0xFFF1F3F5),
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: _pdfZoom,
                  child: Card(
                    color: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(2))),
                    elevation: 2,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                titleText,
                                style: GoogleFonts.sansSerif(
                                  fontSize: 11,
                                  color: SystemColors.textGray,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 10),
                              
                              // Horizontal stylized placeholder lines
                              Container(height: 8, color: const Color(0xFFF1F3F5), width: 180),
                              const SizedBox(height: 6),
                              Container(height: 8, color: const Color(0xFFF1F3F5), width: 200),
                              const SizedBox(height: 14),
                              
                              // Outline descriptive box
                              Container(
                                width: 220,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0xFFD3E4FE)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  children: infoLines.map((line) => Text(
                                    line,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.sansSerif(color: SystemColors.textBody, fontSize: 11),
                                  )).toList(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(height: 8, color: const Color(0xFFF1F3F5), width: 140),
                            ],
                          ),
                        ),
                        
                        // Floating PDF navigation overlay
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F1C2E).withOpacity(0.95),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _docNavIcon(Icons.chevron_left),
                                  const SizedBox(width: 16),
                                  _docNavIcon(Icons.refresh, size: 14),
                                  const SizedBox(width: 16),
                                  _docNavIcon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docNavIcon(IconData icon, {double size = 18}) {
    return GestureDetector(
      onTap: () {},
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

  Widget _buildAttachmentsSection(List<Attachment> attachments) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE5EEFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ALL ATTACHMENTS (${attachments.length})",
              style: GoogleFonts.mono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: SystemColors.textGray,
              ),
            ),
            const SizedBox(height: 12),
            
            ...List.generate(attachments.length, (idx) {
              final attachment = attachments[idx];
              final isLast = idx == attachments.length - 1;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: SystemColors.containerBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              attachment.fileType == 'pdf' 
                                  ? Icons.picture_as_pdf
                                  : (attachment.fileType == 'image' ? Icons.image : Icons.playlist_add_check),
                              color: attachment.fileType == 'pdf' 
                                  ? const Color(0xFFBA1A1A)
                                  : (attachment.fileType == 'image' ? SystemColors.badgeGreenText : const Color(0xFF476083)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 180,
                                child: Text(
                                  attachment.name,
                                  style: GoogleFonts.sansSerif(fontSize: 14, fontWeight: FontWeight.bold, color: SystemColors.textDark),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                attachment.role,
                                style: GoogleFonts.sansSerif(fontSize: 12, color: SystemColors.textGray, fontWeight: FontWeight.w600),
                              )
                            ],
                          )
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: SystemColors.textGray, size: 20),
                    ],
                  ),
                  if (!isLast) const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: SystemColors.pageBackground, height: 1),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomActions(ProcurementOrder order) {
    if (order.status == "PENDING APPROVAL") {
      return Container(
        color: Colors.white,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5EEFF), width: 1)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Reject Button
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFBA1A1A),
                    side: const BorderSide(color: Color(0xFFBA1A1A)),
                    shape: RoundedCornerShape(8),
                  ),
                  onPressed: () {
                    widget.onReject(order.orderNo);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Order ${order.orderNo} REJECTED")),
                    );
                    widget.onBack();
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text("Reject Order", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Approve Button
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SystemColors.corporateGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedCornerShape(8),
                  ),
                  onPressed: () {
                    widget.onApprove(order.orderNo);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Order ${order.orderNo} APPROVED successfully")),
                    );
                    widget.onBack();
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text("Approve Order", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      final isApproved = order.status == "APPROVED";
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproved ? SystemColors.badgeGreenBg : SystemColors.badgeRedBg,
              foregroundColor: isApproved ? SystemColors.badgeGreenText : SystemColors.badgeRedText,
              disabledBackgroundColor: isApproved ? SystemColors.badgeGreenBg : SystemColors.badgeRedBg,
              disabledForegroundColor: isApproved ? SystemColors.badgeGreenText : SystemColors.badgeRedText,
              elevation: 0,
              shape: RoundedCornerShape(8),
            ),
            onPressed: null, // read-only final status display
            icon: Icon(isApproved ? Icons.check_circle : Icons.cancel),
            label: Text(
              isApproved ? "ORDER APPROVED" : "ORDER REJECTED",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildStatusBadge(String status, String badgeType) {
    Color bg;
    Color txt;
    String label;

    if (status == "APPROVED") {
      bg = SystemColors.badgeGreenBg;
      txt = SystemColors.badgeGreenText;
      label = "Approved";
    } else if (status == "REJECTED") {
      bg = SystemColors.badgeRedBg;
      txt = SystemColors.badgeRedText;
      label = "Rejected";
    } else if (badgeType.toLowerCase() == "pending") {
      bg = SystemColors.badgeYellowBg;
      txt = SystemColors.badgeYellowText;
      label = "Pending";
    } else if (badgeType.toLowerCase() == "high value") {
      bg = SystemColors.badgeRedBg;
      txt = SystemColors.badgeRedText;
      label = "High Value";
    } else if (badgeType.toLowerCase() == "today") {
      bg = SystemColors.badgeGreenBg;
      txt = SystemColors.badgeGreenText;
      label = "Today";
    } else {
      bg = SystemColors.badgeYellowBg;
      txt = SystemColors.badgeYellowText;
      label = "Pending";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.sansSerif(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: txt,
        ),
      ),
    );
  }

  String _formatCurrency(double amt) {
    return amt.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (match) => '${match[1]},'
    );
  }
}

// Support class-wide custom address indentation 
extension on BuildContext {
  // Simple layout utility
}

extension PaddingExtension on Widget {
  Widget padding(EdgeInsetsGeometry value) => Padding(padding: value, child: this);
}

extension on Padding {
  // Static margins helper
}
// Stub extension to mock dynamic margin values comfortably
extension MarginShim on EdgeInsets {
  static EdgeInsets leading(double val) => EdgeInsets.only(left: val);
}
