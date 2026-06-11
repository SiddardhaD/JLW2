import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/procurement_order.dart';
import 'models/mock_data.dart';
import 'screens/login_screen.dart';
import 'screens/order_list_screen.dart';
import 'screens/order_detail_screen.dart';
import 'theme/colors.dart';

void main() {
  runApp(const JLWProcurementApp());
}

class JLWProcurementApp extends StatelessWidget {
  const JLWProcurementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JLW Orders Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: SystemColors.corporateGreen,
        scaffoldBackgroundColor: SystemColors.pageBackground,
        textTheme: GoogleFonts.sansSerifTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: SystemColors.corporateGreen,
          primary: SystemColors.corporateGreen,
          secondary: SystemColors.corporateNavy,
          background: SystemColors.pageBackground,
        ),
      ),
      home: const AppNavigationHarness(),
    );
  }
}

// Router state manager running the backstack simulation elegantly
class AppNavigationHarness extends StatefulWidget {
  const AppNavigationHarness({super.key});

  @override
  State<AppNavigationHarness> createState() => _AppNavigationHarnessState();
}

enum ScreenRoute { login, orderList, orderDetail }

class _AppNavigationHarnessState extends State<AppNavigationHarness> {
  // In-memory persistent states
  late List<ProcurementOrder> _orders;
  final String _approverId = "HLW-99284-EXEC";
  
  // Custom backstack simulation
  final List<ScreenRoute> _backstack = [ScreenRoute.login];
  String? _selectedOrderNo;

  @override
  void initState() {
    super.initState();
    _orders = getPrepopulatedOrders();
  }

  void _restoreOriginalData() {
    setState(() {
      _orders = getPrepopulatedOrders();
    });
  }

  void _navigateTo(ScreenRoute route) {
    setState(() {
      _backstack.add(route);
    });
  }

  void _navigateBack() {
    if (_backstack.length > 1) {
      setState(() {
        _backstack.removeLast();
      });
    }
  }

  void _handleLogout() {
    setState(() {
      _backstack.clear();
      _backstack.add(ScreenRoute.login);
      _selectedOrderNo = null;
    });
  }

  void _approveOrder(String orderNo) {
    setState(() {
      _orders = _orders.map((o) {
        if (o.orderNo == orderNo) {
          return o.copyWith(status: "APPROVED");
        }
        return o;
      }).toList();
    });
  }

  void _rejectOrder(String orderNo) {
    setState(() {
      _orders = _orders.map((o) {
        if (o.orderNo == orderNo) {
          return o.copyWith(status: "REJECTED");
        }
        return o;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = _backstack.last;

    // Standard cross-fade animation under 250ms for visual elegance
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _buildCurrentScreen(currentScreen),
    );
  }

  Widget _buildCurrentScreen(ScreenRoute route) {
    switch (route) {
      case ScreenRoute.login:
        return LoginScreen(
          key: const ValueKey("login_view"),
          onLoginSuccess: () {
            _navigateTo(ScreenRoute.orderList);
          },
        );
        
      case ScreenRoute.orderList:
        return OrderListScreen(
          key: const ValueKey("order_list_view"),
          orders: _orders,
          approverId: _approverId,
          onOrderSelect: (orderNo) {
            setState(() {
              _selectedOrderNo = orderNo;
            });
            _navigateTo(ScreenRoute.orderDetail);
          },
          onLogout: _handleLogout,
          onRestoreData: _restoreOriginalData,
        );
        
      case ScreenRoute.orderDetail:
        final selectedOrder = _orders.firstWhere(
          (o) => o.orderNo == _selectedOrderNo,
          orElse: () => _orders.first,
        );
        return OrderDetailScreen(
          key: const ValueKey("order_detail_view"),
          orderNo: _selectedOrderNo ?? '',
          order: selectedOrder,
          onApprove: _approveOrder,
          onReject: _rejectOrder,
          onBack: _navigateBack,
        );
    }
  }
}
