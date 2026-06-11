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
  static const Color _pageBg = Color(0xFFF5F7FA);
  static const Color _cardBorder = Color(0xFFDCE3ED);
  static const Color _sectionBlue = Color(0xFFE8F0FE);
  static const Color _rejectRed = Color(0xFFBA1A1A);
  static const Color _rejectBg = Color(0xFFFDEBEB);

  final Map<String, double> _pdfZoom = {};
  final Map<String, int> _pdfPage = {};

  double _zoomFor(String fileName) => _pdfZoom[fileName] ?? 1.0;
  int _pageFor(String fileName) => _pdfPage[fileName] ?? 1;

  Future<bool> _showActionConfirmation({
    required bool isApprove,
    required String orderNo,
    required double amount,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isApprove ? SystemColors.badgeGreenBg : _rejectBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isApprove ? Icons.check_rounded : Icons.close_rounded,
                    color: isApprove ? SystemColors.badgeGreenText : _rejectRed,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isApprove ? 'Approve Order?' : 'Reject Order?',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SystemColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  isApprove
                      ? 'You are about to approve $orderNo for \$${_formatCurrency(amount)} USD. This action will be recorded in the audit trail.'
                      : 'You are about to reject $orderNo. The originator will be notified and this order will be returned for revision.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: SystemColors.textGray,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SystemColors.textBody,
                          side: const BorderSide(color: _cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApprove
                              ? SystemColors.corporateGreen
                              : _rejectRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(
                          isApprove ? 'Confirm Approve' : 'Confirm Reject',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<void> _handleReject(ProcurementOrder order, double grandTotal) async {
    final confirmed = await _showActionConfirmation(
      isApprove: false,
      orderNo: order.orderNo,
      amount: grandTotal,
    );
    if (!confirmed || !mounted) return;

    widget.onReject(order.orderNo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${order.orderNo} rejected')),
    );
    widget.onBack();
  }

  Future<void> _handleApprove(ProcurementOrder order, double grandTotal) async {
    final confirmed = await _showActionConfirmation(
      isApprove: true,
      orderNo: order.orderNo,
      amount: grandTotal,
    );
    if (!confirmed || !mounted) return;

    widget.onApprove(order.orderNo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order ${order.orderNo} approved successfully')),
    );
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order == null) {
      return const Scaffold(
        backgroundColor: _pageBg,
        body: Center(
          child: CircularProgressIndicator(color: SystemColors.corporateGreen),
        ),
      );
    }

    final order = widget.order!;
    final totalAmount =
        order.lineItems.fold<double>(0, (sum, item) => sum + item.totalCost);
    final taxAmount = totalAmount * 0.085;
    final grandTotal = totalAmount + taxAmount;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomActions(order, grandTotal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(order),
            const SizedBox(height: 16),
            _buildLineItemSection(
                order.lineItems, totalAmount, taxAmount, grandTotal),
            const SizedBox(height: 16),
            _buildInfoBlock('SHIPPING ADDRESS', order.shippingAddress),
            const SizedBox(height: 12),
            _buildInfoBlock('BILLING INFORMATION', order.billingInfo),
            const SizedBox(height: 20),
            _buildPdfDocumentView(
              fileName:
                  'purchase_order_${order.orderNo.replaceAll('#', '')}.pdf',
              totalPages: 4,
              titleText: 'PURCHASE ORDER DETAILS',
              infoLines: [
                'Supplier: ${order.supplier}',
                'Originator: ${order.originator}',
                'Total Amount: \$${_formatCurrency(grandTotal)} USD',
              ],
            ),
            const SizedBox(height: 16),
            _buildPdfDocumentView(
              fileName: 'Vendor_Quote_HLW_99284.pdf',
              totalPages: 4,
              titleText: 'VENDOR QUOTE & TERMS',
              infoLines: const [
                'Primary Commercial Terms',
                'Net 30 Days Operations',
                'Logistical Freight Costs Included',
              ],
            ),
            const SizedBox(height: 20),
            // _buildAttachmentsSection(order.attachments),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          SizedBox(
            height: 32,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: SystemColors.textDark, size: 22),
          onPressed: widget.onBack,
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: _cardBorder),
      ),
    );
  }

  Widget _buildOrderHeader(ProcurementOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROCUREMENT ORDER',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: SystemColors.textGray,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          order.orderNo.replaceAll('#', ''),
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: SystemColors.textDark,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildHeaderMetaCol('Project ID', order.projectId),
            const SizedBox(width: 32),
            _buildHeaderMetaCol('Order Date', order.orderDate),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatusBadge(order.status, order.badgeType),
      ],
    );
  }

  Widget _buildHeaderMetaCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: SystemColors.textGray,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            color: SystemColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLineItemSection(
    List<LineItem> items,
    double subtotal,
    double tax,
    double total,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _sectionBlue,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              'LINE ITEM BREAKDOWN',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: SystemColors.corporateNavy,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Container(
            color: _sectionBlue.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _cellText('Item', flex: 3, isHeader: true),
                _cellText('Description', flex: 7, isHeader: true),
                _cellText('Qty',
                    flex: 2, isHeader: true, align: TextAlign.center),
                _cellText('Unit Cost',
                    flex: 4, isHeader: true, align: TextAlign.end),
              ],
            ),
          ),
          ...List.generate(items.length, (idx) {
            final item = items[idx];
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: _cardBorder.withValues(alpha: 0.7),
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cellText(item.itemCode, flex: 3, isBoldCode: true),
                  _cellText(item.description,
                      flex: 7, color: SystemColors.textBody),
                  _cellText(
                    item.qty.toString(),
                    flex: 2,
                    align: TextAlign.center,
                    color: SystemColors.textBody,
                  ),
                  _cellText(
                    '\$${_formatCurrency(item.unitCost)}',
                    flex: 4,
                    align: TextAlign.end,
                    color: SystemColors.textBody,
                  ),
                ],
              ),
            );
          }),
          Container(
            color: _sectionBlue.withValues(alpha: 0.35),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _calcRow('Subtotal', '\$${_formatCurrency(subtotal)}'),
                const SizedBox(height: 6),
                _calcRow('Tax (8.5%)', '\$${_formatCurrency(tax)}'),
                const SizedBox(height: 10),
                const Divider(color: _cardBorder, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: SystemColors.textDark,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '\$${_formatCurrency(total)}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        color: SystemColors.textDark,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: SystemColors.corporateNavy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              color: SystemColors.textBody,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfDocumentView({
    required String fileName,
    required int totalPages,
    required String titleText,
    required List<String> infoLines,
  }) {
    final zoom = _zoomFor(fileName);
    final page = _pageFor(fileName);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 320,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: _sectionBlue,
                border:
                    Border(bottom: BorderSide(color: _cardBorder, width: 0.6)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      color: _rejectRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SystemColors.corporateNavy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.search,
                        color: Color(0xFF476083), size: 20),
                    onPressed: () {},
                  ),
                  Text(
                    '$page / $totalPages',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: SystemColors.textBody,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    icon: const Icon(Icons.zoom_in,
                        color: Color(0xFF476083), size: 20),
                    onPressed: () {
                      setState(() {
                        final current = _zoomFor(fileName);
                        if (current < 1.6) {
                          _pdfZoom[fileName] = current + 0.1;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: const Color(0xFFF1F3F5),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Transform.scale(
                      scale: zoom,
                      child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.white,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    titleText,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: SystemColors.textGray,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                      height: 8,
                                      width: 180,
                                      color: const Color(0xFFF1F3F5)),
                                  const SizedBox(height: 6),
                                  Container(
                                      height: 8,
                                      width: 200,
                                      color: const Color(0xFFF1F3F5)),
                                  const SizedBox(height: 14),
                                  Container(
                                    width: 220,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFD3E4FE)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      children: infoLines
                                          .map(
                                            (line) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2),
                                              child: Text(
                                                line,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.inter(
                                                  color: SystemColors.textBody,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                      height: 8,
                                      width: 140,
                                      color: const Color(0xFFF1F3F5)),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F1C2E)
                                        .withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _docNavIcon(
                                        Icons.chevron_left,
                                        onTap: page > 1
                                            ? () => setState(() =>
                                                _pdfPage[fileName] = page - 1)
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      _docNavIcon(Icons.refresh,
                                          size: 16, onTap: () {}),
                                      const SizedBox(width: 16),
                                      _docNavIcon(
                                        Icons.chevron_right,
                                        onTap: page < totalPages
                                            ? () => setState(() =>
                                                _pdfPage[fileName] = page + 1)
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _docNavIcon(IconData icon, {double size = 18, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: onTap == null ? Colors.white38 : Colors.white,
        size: size,
      ),
    );
  }

  Widget _buildAttachmentsSection(List<Attachment> attachments) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALL ATTACHMENTS (${attachments.length})',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: SystemColors.textGray,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(attachments.length, (idx) {
            final attachment = attachments[idx];
            final isLast = idx == attachments.length - 1;
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: Icon(
                        attachment.fileType == 'pdf'
                            ? Icons.picture_as_pdf
                            : (attachment.fileType == 'image'
                                ? Icons.image_outlined
                                : Icons.insert_drive_file_outlined),
                        color: attachment.fileType == 'pdf'
                            ? _rejectRed
                            : (attachment.fileType == 'image'
                                ? SystemColors.badgeGreenText
                                : const Color(0xFF476083)),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attachment.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: SystemColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            attachment.role.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: SystemColors.textGray,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: SystemColors.textGray, size: 20),
                  ],
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: _cardBorder, height: 1),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget? _buildBottomActions(ProcurementOrder order, double grandTotal) {
    if (order.status == 'PENDING APPROVAL') {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _cardBorder, width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _rejectRed,
                      backgroundColor: _rejectBg,
                      side: const BorderSide(color: _rejectRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _handleReject(order, grandTotal),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Reject Order',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SystemColors.corporateGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _handleApprove(order, grandTotal),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Approve Order',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isApproved = order.status == 'APPROVED';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: _cardBorder,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproved
                  ? SystemColors.badgeGreenBg
                  : SystemColors.badgeRedBg,
              foregroundColor: isApproved
                  ? SystemColors.badgeGreenText
                  : SystemColors.badgeRedText,
              disabledBackgroundColor: isApproved
                  ? SystemColors.badgeGreenBg
                  : SystemColors.badgeRedBg,
              disabledForegroundColor: isApproved
                  ? SystemColors.badgeGreenText
                  : SystemColors.badgeRedText,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: null,
            icon: Icon(isApproved ? Icons.check_circle : Icons.cancel),
            label: Text(
              isApproved ? 'ORDER APPROVED' : 'ORDER REJECTED',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, String badgeType) {
    Color bg;
    Color txt;
    String label;

    if (status == 'APPROVED') {
      bg = SystemColors.badgeGreenBg;
      txt = SystemColors.badgeGreenText;
      label = 'APPROVED';
    } else if (status == 'REJECTED') {
      bg = SystemColors.badgeRedBg;
      txt = SystemColors.badgeRedText;
      label = 'REJECTED';
    } else if (status == 'PENDING APPROVAL') {
      bg = SystemColors.badgeYellowBg;
      txt = SystemColors.badgeYellowText;
      label = 'PENDING APPROVAL';
    } else if (badgeType.toLowerCase() == 'high value') {
      bg = SystemColors.badgeRedBg;
      txt = SystemColors.badgeRedText;
      label = 'HIGH VALUE';
    } else if (badgeType.toLowerCase() == 'today') {
      bg = SystemColors.badgeGreenBg;
      txt = SystemColors.badgeGreenText;
      label = 'TODAY';
    } else {
      bg = SystemColors.badgeYellowBg;
      txt = SystemColors.badgeYellowText;
      label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: txt,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _cellText(
    String text, {
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
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight:
              isHeader || isBoldCode ? FontWeight.w700 : FontWeight.w400,
          color: isHeader
              ? SystemColors.textDark
              : (isBoldCode
                  ? SystemColors.corporateGreen
                  : (color ?? SystemColors.textDark)),
        ),
        maxLines: 3,
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
          style: GoogleFonts.inter(color: SystemColors.textGray, fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            color: SystemColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amt) {
    return amt.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
