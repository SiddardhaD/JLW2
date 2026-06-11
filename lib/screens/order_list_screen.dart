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
  String _searchQuery = '';
  String _selectedFilter = 'All';
  int _currentNavIndex = 0; // 0 = Home, 1 = Search, 2 = Profile

  List<ProcurementOrder> get _filteredOrders {
    var list = widget.orders;
    
    // 1. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      list = list.where((order) {
        return order.orderNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.supplier.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.originator.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // 2. Filter by Badge Category
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

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Executive Profile Portal",
            style: GoogleFonts.sansSerif(
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
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.approverId,
                style: GoogleFonts.sansSerif(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: SystemColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Divider(color: Color(0xFFE5EEFF)),
              const SizedBox(height: 12),
              
              _buildProfileDetailRow("Title", "Chief Procurement Officer"),
              _buildProfileDetailRow("Section", "Operations Executive Office"),
              _buildProfileDetailRow("Authority limit", "\$5,000,000.00 USD", isBold: true),
              
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  widget.onRestoreData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Restored prepopulated core states!")),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SystemColors.containerBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, color: Color(0xFF476083), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Restore Prepopulated States",
                        style: GoogleFonts.sansSerif(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF476083),
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
                "Close",
                style: GoogleFonts.sansSerif(
                  fontWeight: FontWeight.bold,
                  color: SystemColors.corporateGreen,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildProfileDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.sansSerif(color: SystemColors.textGray, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.sansSerif(
              color: SystemColors.textBody,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listItems = _filteredOrders;

    return Scaffold(
      backgroundColor: SystemColors.pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
              "Orders Awaiting Approval",
              style: GoogleFonts.sansSerif(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: SystemColors.corporateGreen,
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0xFFBA1A1A)),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: SystemColors.containerBlue,
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _currentNavIndex = idx;
          });
          if (idx == 2) {
            _showProfileDialog();
            setState(() {
              _currentNavIndex = 0; // return focus to Home tab visual immediately
            });
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 1. APPROVER ID Badge Card
          _buildInfoCard(
            title: "APPROVER ID",
            value: widget.approverId,
            icon: Icons.badge,
            iconBg: SystemColors.containerBlue,
            iconColor: const Color(0xFF476083),
          ),
          
          const SizedBox(height: 12),
          
          // 2. ACTIVE PROJECT Badge Card
          _buildInfoCard(
            title: "ACTIVE PROJECT",
            value: "M30 - Procurement Cycle",
            icon: Icons.folder_shared,
            iconBg: const Color(0xFFE8F6EE),
            iconColor: SystemColors.corporateGreen,
          ),
          
          const SizedBox(height: 16),
          
          // 3. Search and filter container Card
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE5EEFF), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search query field
                  TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search Order No or Supplier...",
                      hintStyle: GoogleFonts.sansSerif(color: SystemColors.textGray, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: SystemColors.textGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFBFC9C3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: SystemColors.corporateGreen),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Horizontal filter row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All", "High Value", "Today", "Pending"].map((filterName) {
                        final isSelected = _selectedFilter == filterName;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFilter = filterName;
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? SystemColors.corporateGreen : SystemColors.containerBlue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                filterName,
                                style: GoogleFonts.sansSerif(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : const Color(0xFF476083),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // No items state indicator
          if (listItems.isEmpty) ...[
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: SystemColors.badgeGreenText, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    "No orders pending approval!",
                    style: GoogleFonts.sansSerif(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SystemColors.corporateGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "All procurement items are processed, or try resetting the search filter query.",
                      style: GoogleFonts.sansSerif(color: SystemColors.textGray, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SystemColors.corporateGreen,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: widget.onRestoreData,
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text("Reset Orders Data"),
                  )
                ],
              ),
            )
          ] else ...[
            // 4. Render lists
            ...listItems.map((order) => _buildOrderCard(order)),
          ],
        ],
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
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE5EEFF), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.sansSerif(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: SystemColors.textGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.sansSerif(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: SystemColors.textDark,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(ProcurementOrder order) {
    // Large beautifully formatted currency amount
    final formattedAmount = order.amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (match) => '${match[1]},'
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: SystemColors.cardBorder, width: 1),
        ),
        child: InkWell(
          onTap: () => widget.onOrderSelect(order.orderNo),
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ORDER NO",
                      style: GoogleFonts.sansSerif(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SystemColors.textGray,
                      ),
                    ),
                    Text(
                      order.orderNo,
                      style: GoogleFonts.sansSerif(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: SystemColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    Text(
                      "SUPPLIER",
                      style: GoogleFonts.sansSerif(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SystemColors.textGray,
                      ),
                    ),
                    Text(
                      order.supplier,
                      style: GoogleFonts.sansSerif(
                        fontSize: 16,
                        fontWeight: FontWeight.black,
                        color: SystemColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "ORIGINATOR",
                      style: GoogleFonts.sansSerif(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SystemColors.textGray,
                      ),
                    ),
                    Text(
                      order.originator,
                      style: GoogleFonts.sansSerif(
                        fontSize: 14,
                        color: SystemColors.textBody,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "AMOUNT",
                      style: GoogleFonts.sansSerif(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: SystemColors.textGray,
                      ),
                    ),
                    Text(
                      "\$$formattedAmount USD",
                      style: GoogleFonts.sansSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.black,
                        color: SystemColors.corporateGreen,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Badge aligned dynamically 
              Positioned(
                bottom: 16,
                right: 16,
                child: _buildStatusBadge(order.status, order.badgeType),
              ),
            ],
          ),
        ),
      ),
    );
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
}
