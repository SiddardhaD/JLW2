package com.example.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material.icons.filled.AssignmentInd
import androidx.compose.material.icons.filled.Badge
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.FolderShared
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.ProcurementOrder
import java.text.NumberFormat
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OrderListScreen(
    viewModel: OrderApprovalViewModel,
    onOrderClick: (orderNo: String) -> Unit,
    onLogout: () -> Unit,
    modifier: Modifier = Modifier
) {
    val orders by viewModel.uiState.collectAsState()
    val approverId by viewModel.currentUser.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()
    val selectedFilter by viewModel.selectedFilter.collectAsState()
    
    var currentNavDestination by remember { mutableStateOf("home") } // "home", "search", "profile"
    var showProfileDialog by remember { mutableStateOf(false) }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        containerColor = Color(0xFFF8F9FF), // matching surface background
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        // Quick compact version of logo
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = "JLW",
                                fontFamily = FontFamily.Serif,
                                fontWeight = FontWeight.Black,
                                fontSize = 20.sp,
                                color = Color(0xFF0F2C59)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "|",
                                fontSize = 16.sp,
                                color = Color.Gray
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "Orders Awaiting Approval",
                                style = MaterialTheme.typography.bodyLarge,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF003527)
                            )
                        }
                    }
                },
                actions = {
                    IconButton(
                        onClick = onLogout,
                        modifier = Modifier.testTag("logout_button")
                    ) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ExitToApp,
                            contentDescription = "Logout",
                            tint = Color(0xFFBA1A1A)
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.border(0.dp, Color.Transparent) // flat topbar
            )
        },
        bottomBar = {
            NavigationBar(
                containerColor = Color.White,
                tonalElevation = 8.dp
            ) {
                NavigationBarItem(
                    selected = currentNavDestination == "home",
                    onClick = { 
                        currentNavDestination = "home"
                        viewModel.setSelectedFilter("All")
                    },
                    icon = { Icon(imageVector = Icons.Default.Home, contentDescription = "Home") },
                    label = { Text("Home", fontWeight = FontWeight.Bold) },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = Color(0xFF003527),
                        selectedTextColor = Color(0xFF003527),
                        indicatorColor = Color(0xFFEFF4FF)
                    ),
                    modifier = Modifier.testTag("nav_home")
                )
                NavigationBarItem(
                    selected = currentNavDestination == "search",
                    onClick = { currentNavDestination = "search" },
                    icon = { Icon(imageVector = Icons.Default.Search, contentDescription = "Search") },
                    label = { Text("Search", fontWeight = FontWeight.Bold) },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = Color(0xFF003527),
                        selectedTextColor = Color(0xFF003527),
                        indicatorColor = Color(0xFFEFF4FF)
                    ),
                    modifier = Modifier.testTag("nav_search")
                )
                NavigationBarItem(
                    selected = currentNavDestination == "profile",
                    onClick = { 
                        currentNavDestination = "profile"
                        showProfileDialog = true
                    },
                    icon = { Icon(imageVector = Icons.Default.Person, contentDescription = "Profile") },
                    label = { Text("Profile", fontWeight = FontWeight.Bold) },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = Color(0xFF003527),
                        selectedTextColor = Color(0xFF003527),
                        indicatorColor = Color(0xFFEFF4FF)
                    ),
                    modifier = Modifier.testTag("nav_profile")
                )
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .background(Color(0xFFF8F9FF)) // consistent surface background
        ) {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                item {
                    Spacer(modifier = Modifier.height(16.dp))
                }

                // 1. APPROVER ID info card
                item {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("approver_card"),
                        shape = RoundedCornerShape(8.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, Color(0xFFE5EEFF))
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(40.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(Color(0xFFEFF4FF)),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Badge,
                                    contentDescription = "Approver Badge",
                                    tint = Color(0xFF476083),
                                    modifier = Modifier.size(24.dp)
                                )
                            }
                            Spacer(modifier = Modifier.width(16.dp))
                            Column {
                                Text(
                                    text = "APPROVER ID",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = Color(0xFF707974),
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 0.5.sp
                                )
                                Text(
                                    text = approverId,
                                    style = MaterialTheme.typography.titleMedium,
                                    color = Color(0xFF0B1C30),
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }

                // 2. ACTIVE PROJECT info card
                item {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("project_card"),
                        shape = RoundedCornerShape(8.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, Color(0xFFE5EEFF))
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(40.dp)
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(Color(0xFFE8F6EE)),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.FolderShared,
                                    contentDescription = "Project Badge",
                                    tint = Color(0xFF003527),
                                    modifier = Modifier.size(24.dp)
                                )
                            }
                            Spacer(modifier = Modifier.width(16.dp))
                            Column {
                                Text(
                                    text = "ACTIVE PROJECT",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = Color(0xFF707974),
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 0.5.sp
                                )
                                Text(
                                    text = "M30 - Procurement Cycle",
                                    style = MaterialTheme.typography.titleMedium,
                                    color = Color(0xFF003527),
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }

                // 3. Search and Filters container card
                item {
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("search_filter_card"),
                        shape = RoundedCornerShape(8.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        border = BorderStroke(1.dp, Color(0xFFE5EEFF))
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp)
                        ) {
                            // Search Row
                            OutlinedTextField(
                                value = searchQuery,
                                onValueChange = { viewModel.setSearchQuery(it) },
                                placeholder = { 
                                    Text(
                                        "Search Order No or Supplier...", 
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = Color(0xFF707974)
                                    ) 
                                },
                                leadingIcon = {
                                    Icon(
                                        imageVector = Icons.Default.Search,
                                        contentDescription = "Search orders",
                                        tint = Color(0xFF707974)
                                    )
                                },
                                singleLine = true,
                                shape = RoundedCornerShape(8.dp),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = Color(0xFF003527),
                                    unfocusedBorderColor = Color(0xFFBFC9C3)
                                ),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(52.dp)
                                    .testTag("search_input")
                            )

                            Spacer(modifier = Modifier.height(12.dp))

                            // Filter Pills Row
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                val filters = listOf("All", "High Value", "Today", "Pending")
                                filters.forEach { filterName ->
                                    val isSelected = selectedFilter == filterName
                                    Box(
                                        modifier = Modifier
                                            .clip(RoundedCornerShape(20.dp))
                                            .background(
                                                if (isSelected) Color(0xFF003527) else Color(0xFFEFF4FF)
                                            )
                                            .clickable { viewModel.setSelectedFilter(filterName) }
                                            .padding(horizontal = 14.dp, vertical = 8.dp)
                                            .testTag("filter_pill_$filterName"),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        Text(
                                            text = filterName,
                                            style = MaterialTheme.typography.bodySmall,
                                            fontWeight = FontWeight.Bold,
                                            color = if (isSelected) Color.White else Color(0xFF476083)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state block
                if (orders.isEmpty()) {
                    item {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 40.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Icon(
                                imageVector = Icons.Default.CheckCircle,
                                contentDescription = "All done",
                                tint = Color(0xFF27AE60),
                                modifier = Modifier.size(64.dp)
                            )
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(
                                text = "No orders pending approval!",
                                style = MaterialTheme.typography.headlineSmall,
                                color = Color(0xFF003527),
                                fontWeight = FontWeight.Bold,
                                textAlign = TextAlign.Center
                            )
                            Text(
                                text = "All procurement items are processed, or try changing filters / search query.",
                                style = MaterialTheme.typography.bodyMedium,
                                color = Color(0xFF707974),
                                textAlign = TextAlign.Center,
                                modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp)
                            )
                            Spacer(modifier = Modifier.height(24.dp))
                            Button(
                                onClick = { viewModel.resetAllData() },
                                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF003527))
                            ) {
                                Icon(imageVector = Icons.Default.History, contentDescription = null)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("Reset Orders Data", fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }

                // 4. Order Cards Lists
                items(orders, key = { it.orderNo }) { order ->
                    OrderCard(
                        order = order,
                        onClick = { onOrderClick(order.orderNo) }
                    )
                }

                item {
                    Spacer(modifier = Modifier.height(24.dp))
                }
            }
        }
    }

    // Profile Dialog
    if (showProfileDialog) {
        AlertDialog(
            onDismissRequest = { 
                showProfileDialog = false 
                currentNavDestination = "home"
            },
            title = {
                Text(
                    "Executive Profile Portal",
                    style = MaterialTheme.typography.headlineSmall,
                    color = Color(0xFF003527),
                    fontWeight = FontWeight.Bold
                )
            },
            text = {
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(72.dp)
                            .clip(CircleShape)
                            .background(Color(0xFF003527))
                            .align(Alignment.CenterHorizontally),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Person,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(40.dp)
                        )
                    }
                    
                    Text(
                        text = approverId,
                        fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.titleMedium,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.fillMaxWidth(),
                        color = Color(0xFF0B1C30)
                    )

                    HorizontalDivider(color = Color(0xFFE5EEFF))
                    
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Text(
                            text = "Title: Chief Procurement Officer",
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color(0xFF404944)
                        )
                        Text(
                            text = "Section: Operations Executive Office",
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color(0xFF404944)
                        )
                        Text(
                            text = "Authority limit: $5,000,000.00 USD",
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color(0xFF404944),
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(8.dp))
                            .background(Color(0xFFEFF4FF))
                            .clickable { viewModel.resetAllData() }
                            .padding(12.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Default.History,
                                contentDescription = null,
                                tint = Color(0xFF476083)
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                "Restore Prepopulated Core States",
                                style = MaterialTheme.typography.bodySmall,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF476083)
                            )
                        }
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = { 
                        showProfileDialog = false 
                        currentNavDestination = "home"
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF003527))
                ) {
                    Text("Close", fontWeight = FontWeight.Bold)
                }
            }
        )
    }
}

@Composable
fun OrderCard(
    order: ProcurementOrder,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val numberFormat = remember { NumberFormat.getNumberInstance(Locale.US) }
    val formattedAmount = remember(order.amount) { numberFormat.format(order.amount) }

    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .testTag("order_card_${order.orderNo}"),
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, Color(0xFFEFF4FF))
    ) {
        Box(modifier = Modifier.fillMaxWidth()) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
            ) {
                // ORDER NO label and value
                Text(
                    text = "ORDER NO",
                    style = MaterialTheme.typography.labelMedium,
                    color = Color(0xFF707974),
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp
                )
                Text(
                    text = order.orderNo,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0B1C30),
                    modifier = Modifier.padding(bottom = 8.dp)
                )

                // SUPPLIER label and bold supplier
                Text(
                    text = "SUPPLIER",
                    style = MaterialTheme.typography.labelMedium,
                    color = Color(0xFF707974),
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp
                )
                Text(
                    text = order.supplier,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.ExtraBold,
                    color = Color(0xFF0B1C30),
                    modifier = Modifier.padding(bottom = 8.dp),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                // ORIGINATOR label and value
                Text(
                    text = "ORIGINATOR",
                    style = MaterialTheme.typography.labelMedium,
                    color = Color(0xFF707974),
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp
                )
                Text(
                    text = order.originator,
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color(0xFF404944),
                    modifier = Modifier.padding(bottom = 8.dp)
                )

                // AMOUNT label and bold amount
                Text(
                    text = "AMOUNT",
                    style = MaterialTheme.typography.labelMedium,
                    color = Color(0xFF707974),
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 0.5.sp
                )
                Text(
                    text = "$formattedAmount USD",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Black,
                    color = Color(0xFF003527),
                    modifier = Modifier.padding(bottom = 4.dp)
                )
            }

            // Status Badge styled exactly like the screenshots (offset to bottom right inside padding)
            Box(
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(16.dp)
            ) {
                StatusBadge(status = order.status, badgeType = order.badgeType)
            }
        }
    }
}

@Composable
fun StatusBadge(
    status: String,
    badgeType: String,
    modifier: Modifier = Modifier
) {
    // If the order has been approved or rejected, prioritize that over the tag!
    val (bgColor, textColor, label) = when {
        status == "APPROVED" -> Triple(Color(0xFFE8F6EE), Color(0xFF27AE60), "Approved")
        status == "REJECTED" -> Triple(Color(0xFFFDEBEB), Color(0xFFEB5757), "Rejected")
        badgeType.equals("Pending", ignoreCase = true) -> Triple(Color(0xFFFEF8E7), Color(0xFFC49A13), "Pending")
        badgeType.equals("High Value", ignoreCase = true) -> Triple(Color(0xFFFDEBEB), Color(0xFFEB5757), "High Value")
        badgeType.equals("Today", ignoreCase = true) -> Triple(Color(0xFFE8F6EE), Color(0xFF27AE60), "Today")
        else -> Triple(Color(0xFFFEF8E7), Color(0xFFC49A13), "Pending")
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .background(bgColor)
            .padding(horizontal = 12.dp, vertical = 4.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodySmall,
            fontWeight = FontWeight.Bold,
            color = textColor
        )
    }
}
