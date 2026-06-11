import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/procurement_order.dart';
import '../theme/colors.dart';

class OrderListScreen extends StatefulWidget {
  final List<ProcurementOrder> orders;
  final String approverId;
  final ValueChanged<String> onOrderSelect;
  final VoidCallback onLogout;
  final VoidCallback onRestoreData;

  const OrderListScreen({
    super.key,
    required this.orders,
    required this.approverId,
    required this.onOrderSelect,
    required this.onLogout,
    required this.onRestoreData,
  });

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  static const Color _pageBg = Color(0xFFF5F7FA);
  static const Color _sectionBg = Color(0xFFEEF2F7);
  static const Color _navBarBg = Color(0xFFE8EFF8);
  static const Color _cardBorder = Color(0xFFDCE3ED);
  static const Color _chipInactiveBg = Color(0xFFE8F0FE);
  static const Color _chipInactiveText = Color(0xFF1A3A5C);
  static const Color _badgeOrangeBg = Color(0xFFFFF0E0);
  static const Color _badgeOrangeText = Color(0xFFD35400);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _currentNavIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<ProcurementOrder> get _filteredOrders {
    var list = widget.orders;

    if (_searchQuery.isNotEmpty) {
      list = list.where((order) {
        return order.orderNo
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            order.supplier.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.originator.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedFilter != 'All') {
      list = list.where((order) {
        switch (_selectedFilter) {
          case 'High Value':
            return order.badgeType.toLowerCase() == 'high value';
          case 'Today':
            return order.badgeType.toLowerCase() == 'today';
          case 'Pending':
            return order.badgeType.toLowerCase() == 'pending' ||
                order.status.toLowerCase() == 'pending approval';
          default:
            return true;
        }
      }).toList();
    }

    return list;
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);

    if (index == 1) {
      _searchFocusNode.requestFocus();
    } else if (index == 2) {
      _showProfileDialog();
      setState(() => _currentNavIndex = 0);
    }
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Executive Profile Portal',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: SystemColors.corporateGreen,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: SystemColors.corporateGreen,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                widget.approverId,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: SystemColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: _cardBorder),
              const SizedBox(height: 12),
              _buildProfileDetailRow('Title', 'Chief Procurement Officer'),
              _buildProfileDetailRow('Section', 'Operations Executive Office'),
              _buildProfileDetailRow('Authority limit', '\$5,000,000.00 USD',
                  isBold: true),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  widget.onRestoreData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Restored prepopulated core states!')),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _chipInactiveBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history,
                          color: _chipInactiveText, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Restore Prepopulated States',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _chipInactiveText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: SystemColors.corporateGreen,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileDetailRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                GoogleFonts.inter(color: SystemColors.textGray, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: SystemColors.textBody,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listItems = _filteredOrders;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNav(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderSection()),
          if (listItems.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildOrderCard(listItems[index]),
                  childCount: listItems.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leadingWidth: 72,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      ),
      title: Text(
        'Orders Awaiting Approval',
        style: GoogleFonts.playfairDisplay(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: SystemColors.textDark,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: SystemColors.textDark, size: 22),
          onPressed: widget.onLogout,
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: _cardBorder),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      color: _sectionBg,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          _buildInfoCard(
            title: 'APPROVER ID',
            value: widget.approverId,
            icon: Icons.badge_outlined,
            iconBg: _chipInactiveBg,
            iconColor: const Color(0xFF4A7BA7),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'ACTIVE PROJECT',
            value: 'M30',
            icon: Icons.account_tree_outlined,
            iconBg: SystemColors.corporateGreen,
            iconColor: Colors.white,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (val) => setState(() => _searchQuery = val),
            style:
                GoogleFonts.inter(fontSize: 14, color: SystemColors.textDark),
            decoration: InputDecoration(
              hintText: 'Search Order No or Supplier...',
              hintStyle:
                  GoogleFonts.inter(color: SystemColors.textGray, fontSize: 14),
              prefixIcon: const Icon(Icons.search,
                  color: SystemColors.textGray, size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: SystemColors.corporateGreen, width: 1.2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'High Value', 'Today', 'Pending']
                  .map(_buildFilterChip)
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterName) {
    final isSelected = _selectedFilter == filterName;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = filterName),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? SystemColors.corporateGreen : _chipInactiveBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            filterName,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : _chipInactiveText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: SystemColors.textGray,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: SystemColors.corporateNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(ProcurementOrder order) {
    final formattedAmount = order.amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => widget.onOrderSelect(order.orderNo),
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _cardBorder),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 44),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderField('ORDER NO', order.orderNo, isBold: true),
                      const SizedBox(height: 10),
                      _buildOrderField('SUPPLIER', order.supplier,
                          isBold: true, fontSize: 15),
                      const SizedBox(height: 10),
                      _buildOrderField('ORIGINATOR', order.originator),
                      const SizedBox(height: 10),
                      _buildOrderField('AMOUNT', formattedAmount,
                          isBold: true, fontSize: 15),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _buildStatusBadge(order.status, order.badgeType),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderField(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: SystemColors.textGray,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: SystemColors.textDark,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, String badgeType) {
    Color bg;
    Color txt;
    String label;

    if (status == 'APPROVED') {
      bg = SystemColors.badgeGreenBg;
      txt = SystemColors.badgeGreenText;
      label = 'Approved';
    } else if (status == 'REJECTED') {
      bg = SystemColors.badgeRedBg;
      txt = SystemColors.badgeRedText;
      label = 'Rejected';
    } else if (badgeType.toLowerCase() == 'pending') {
      bg = _badgeOrangeBg;
      txt = _badgeOrangeText;
      label = 'Pending';
    } else if (badgeType.toLowerCase() == 'high value') {
      bg = SystemColors.badgeRedBg;
      txt = SystemColors.badgeRedText;
      label = 'High Value';
    } else if (badgeType.toLowerCase() == 'today') {
      bg = SystemColors.badgeGreenBg;
      txt = SystemColors.badgeGreenText;
      label = 'Today';
    } else {
      bg = _badgeOrangeBg;
      txt = _badgeOrangeText;
      label = 'Pending';
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
          fontWeight: FontWeight.w600,
          color: txt,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle,
              color: SystemColors.badgeGreenText, size: 64),
          const SizedBox(height: 16),
          Text(
            'No orders pending approval!',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: SystemColors.corporateGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All procurement items are processed, or try resetting the search filter query.',
            style:
                GoogleFonts.inter(color: SystemColors.textGray, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: SystemColors.corporateGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: widget.onRestoreData,
            icon: const Icon(Icons.history, size: 18),
            label: const Text('Reset Orders Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: _navBarBg,
        border: Border(top: BorderSide(color: _cardBorder, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.search_rounded,
              label: 'Search',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _currentNavIndex == index;

    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isActive ? SystemColors.corporateGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : SystemColors.textGray,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive
                  ? SystemColors.corporateGreen
                  : SystemColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
