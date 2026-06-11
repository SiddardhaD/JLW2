package com.example.ui

import android.widget.Toast
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.*
import java.text.NumberFormat
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OrderDetailScreen(
    orderNo: String,
    viewModel: OrderApprovalViewModel,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val orderFlow = remember(orderNo) { viewModel.getOrderDetails(orderNo) }
    val order by orderFlow.collectAsState(initial = null)
    val context = LocalContext.current
    val scrollState = rememberScrollState()

    Scaffold(
        modifier = modifier.fillMaxSize(),
        containerColor = Color(0xFFF8F9FF),
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "JLW",
                            fontFamily = FontFamily.Serif,
                            fontWeight = FontWeight.Black,
                            fontSize = 20.sp,
                            color = Color(0xFF0F2C59)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(text = "|", color = Color.Gray, fontSize = 20.sp)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "HLW",
                            style = MaterialTheme.typography.bodyLarge,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF003527)
                        )
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack, modifier = Modifier.testTag("back_icon_button")) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Back", tint = Color(0xFF0B1C30))
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.border(0.dp, Color.Transparent)
            )
        },
        bottomBar = {
            // Check if order details are loaded and not already final approved/rejected
            order?.let { currentOrder ->
                Surface(
                    tonalElevation = 8.dp,
                    color = Color.White,
                    modifier = Modifier.border(1.dp, Color(0xFFE5EEFF))
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .windowInsetsPadding(WindowInsets.navigationBars)
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.spacedBy(16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        if (currentOrder.status == "PENDING APPROVAL") {
                            // Reject Button
                            OutlinedButton(
                                onClick = {
                                    viewModel.rejectOrder(currentOrder.orderNo) {
                                        Toast.makeText(context, "Order ${currentOrder.orderNo} REJECTED", Toast.LENGTH_SHORT).show()
                                        onBack()
                                    }
                                },
                                modifier = Modifier
                                    .weight(1f)
                                    .height(48.dp)
                                    .testTag("reject_order_button"),
                                border = BorderStroke(1.dp, Color(0xFFBA1A1A)),
                                colors = ButtonDefaults.outlinedButtonColors(contentColor = Color(0xFFBA1A1A)),
                                shape = RoundedCornerShape(8.dp)
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.Center
                                ) {
                                    Icon(imageVector = Icons.Default.Close, contentDescription = null, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text("Reject Order", fontWeight = FontWeight.Bold)
                                }
                            }

                            // Approve Button
                            Button(
                                onClick = {
                                    viewModel.approveOrder(currentOrder.orderNo) {
                                        Toast.makeText(context, "Order ${currentOrder.orderNo} APPROVED successfully", Toast.LENGTH_SHORT).show()
                                        onBack()
                                    }
                                },
                                modifier = Modifier
                                    .weight(1f)
                                    .height(48.dp)
                                    .testTag("approve_order_button"),
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = Color(0xFF003527),
                                    contentColor = Color.White
                                ),
                                shape = RoundedCornerShape(8.dp)
                            ) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.Center
                                ) {
                                    Icon(imageVector = Icons.Default.Check, contentDescription = null, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text("Approve Order", fontWeight = FontWeight.Bold)
                                }
                            }
                        } else {
                            // Already processed state indicators
                            val isApproved = currentOrder.status == "APPROVED"
                            Button(
                                onClick = {},
                                enabled = false,
                                colors = ButtonDefaults.buttonColors(
                                    disabledContainerColor = if (isApproved) Color(0xFFE8F6EE) else Color(0xFFFDEBEB),
                                    disabledContentColor = if (isApproved) Color(0xFF27AE60) else Color(0xFFEB5757)
                                ),
                                modifier = Modifier.fillMaxWidth().height(48.dp),
                                shape = RoundedCornerShape(8.dp)
                            ) {
                                Icon(
                                    imageVector = if (isApproved) Icons.Default.CheckCircle else Icons.Default.Cancel,
                                    contentDescription = null
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = if (isApproved) "ORDER APPROVED" else "ORDER REJECTED",
                                    fontWeight = FontWeight.ExtraBold
                                )
                            }
                        }
                    }
                }
            }
        }
    ) { innerPadding ->
        if (order == null) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator(color = Color(0xFF003527))
            }
        } else {
            val currentOrder = order!!
            val items = remember(currentOrder) { currentOrder.getLineItems() }
            val attachments = remember(currentOrder) { currentOrder.getAttachments() }
            val numberFormat = remember { NumberFormat.getNumberInstance(Locale.US) }
            
            val subtotal = remember(items) { items.sumOf { it.totalCost } }
            val taxAmount = remember(subtotal) { subtotal * 0.085 }
            val grandTotal = remember(subtotal, taxAmount) { subtotal + taxAmount }

            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
                    .background(Color(0xFFF8F9FF)) // consistent surface background
                    .verticalScroll(scrollState)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Header Segment
                Column {
                    Text(
                        text = "PROCUREMENT ORDER",
                        style = MaterialTheme.typography.labelLarge,
                        color = Color(0xFF707974),
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                    Text(
                        text = currentOrder.orderNo,
                        style = MaterialTheme.typography.displayLarge.copy(fontSize = 32.sp, lineHeight = 38.sp),
                        fontWeight = FontWeight.ExtraBold,
                        color = Color(0xFF003527),
                        modifier = Modifier.padding(vertical = 4.dp)
                    )
                    
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(24.dp)
                    ) {
                        Column {
                            Text(
                                text = "Project ID",
                                style = MaterialTheme.typography.bodySmall,
                                color = Color(0xFF707974),
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = currentOrder.projectId,
                                style = MaterialTheme.typography.bodyMedium,
                                color = Color(0xFF0B1C30),
                                fontWeight = FontWeight.Bold
                            )
                        }
                        
                        Column {
                            Text(
                                text = "Order Date",
                                style = MaterialTheme.typography.bodySmall,
                                color = Color(0xFF707974),
                                fontWeight = FontWeight.Bold
                            )
                            Text(
                                text = currentOrder.orderDate,
                                style = MaterialTheme.typography.bodyMedium,
                                color = Color(0xFF0B1C30),
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))
                    
                    // Large Pending gold state badge
                    StatusBadge(
                        status = currentOrder.status,
                        badgeType = currentOrder.badgeType,
                        modifier = Modifier.testTag("detail_status_badge")
                    )
                }

                HorizontalDivider(color = Color(0xFFE5EEFF))

                // Line Item breakdown table
                Column {
                    Text(
                        text = "LINE ITEM BREAKDOWN",
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF0F2C59),
                        fontWeight = FontWeight.Black,
                        letterSpacing = 0.8.sp,
                        modifier = Modifier.padding(bottom = 8.dp)
                    )

                    TableLayout(
                        items = items,
                        subtotal = subtotal,
                        taxAmount = taxAmount,
                        grandTotal = grandTotal,
                        numberFormat = numberFormat
                    )
                }

                // Shipping Address Card
                AddressCard(
                    title = "SHIPPING ADDRESS",
                    content = currentOrder.shippingAddress,
                    icon = Icons.Default.LocalShipping,
                    modifier = Modifier.testTag("shipping_card")
                )

                // Billing Information Card
                AddressCard(
                    title = "BILLING INFORMATION",
                    content = currentOrder.billingInfo,
                    icon = Icons.Default.ReceiptLong,
                    modifier = Modifier.testTag("billing_card")
                )

                // Embedded PDF / File Document Previews! (Highly creative drawing exact screenshot features)
                Text(
                    text = "DOCUMENT VIEWER",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color(0xFF0F2C59),
                    fontWeight = FontWeight.Black,
                    letterSpacing = 0.8.sp,
                    modifier = Modifier.padding(top = 8.dp)
                )

                // Render Purchase Order preview canvas
                PdfDocumentView(
                    fileName = "purchase_order_${currentOrder.orderNo.replace("#", "")}.pdf",
                    pageString = "1 / 4",
                    titleText = "PURCHASE ORDER DETAILS",
                    infoList = listOf(
                        "Supplier: " + currentOrder.supplier,
                        "Originator: " + currentOrder.originator,
                        "Total Amount: " + numberFormat.format(grandTotal) + " USD"
                    )
                )

                // Render Vendor Quote preview canvas if available
                PdfDocumentView(
                    fileName = "Vendor_Quote_HLW_99284.pdf",
                    pageString = "1 / 4",
                    titleText = "VENDOR QUOTE & TERMS",
                    infoList = listOf(
                        "Primary Commercial Terms",
                        "Net 30 Days Operations",
                        "Logistical Freight Costs Included"
                    )
                )

                // All attachments list card section
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .testTag("attachments_card"),
                    shape = RoundedCornerShape(8.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    border = BorderStroke(1.dp, Color(0xFFE5EEFF))
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "ALL ATTACHMENTS (${attachments.size})",
                            style = MaterialTheme.typography.bodySmall,
                            color = Color(0xFF707974),
                            fontWeight = FontWeight.Black,
                            letterSpacing = 0.5.sp,
                            modifier = Modifier.padding(bottom = 12.dp)
                        )

                        attachments.forEachIndexed { index, attachment ->
                            AttachmentRowItem(attachment = attachment)
                            if (index < attachments.size - 1) {
                                HorizontalDivider(
                                    color = Color(0xFFF8F9FF),
                                    modifier = Modifier.padding(vertical = 8.dp)
                                )
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(48.dp))
            }
        }
    }
}

@Composable
fun TableLayout(
    items: List<LineItem>,
    subtotal: Double,
    taxAmount: Double,
    grandTotal: Double,
    numberFormat: NumberFormat,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, Color(0xFFE5EEFF))
    ) {
        Column {
            // Header Row
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(0xFFE5EEFF))
                    .padding(horizontal = 12.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Item",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0B1C30),
                    modifier = Modifier.weight(1.5f)
                )
                Text(
                    text = "Description",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0B1C30),
                    modifier = Modifier.weight(3.5f)
                )
                Text(
                    text = "Qty",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0B1C30),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.weight(1f)
                )
                Text(
                    text = "Unit Cost",
                    style = MaterialTheme.typography.bodySmall,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0B1C30),
                    textAlign = TextAlign.End,
                    modifier = Modifier.weight(2f)
                )
            }

            // Data Rows
            items.forEachIndexed { index, item ->
                val rowBg = if (index % 2 == 1) Color(0xFFEFF4FF) else Color.White
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(rowBg)
                        .padding(horizontal = 12.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = item.itemCode,
                        style = MaterialTheme.typography.bodySmall,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF003527),
                        modifier = Modifier.weight(1.5f)
                    )
                    Text(
                        text = item.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF404944),
                        modifier = Modifier.weight(3.5f),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = item.qty.toString(),
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF404944),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.weight(1f)
                    )
                    Text(
                        text = "$" + numberFormat.format(item.unitCost),
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF404944),
                        textAlign = TextAlign.End,
                        modifier = Modifier.weight(2f)
                    )
                }
                HorizontalDivider(color = Color(0xFFE5EEFF).copy(alpha = 0.5f))
            }

            // Calculation Block
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "Subtotal",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color(0xFF707974)
                    )
                    Text(
                        text = "$" + numberFormat.format(subtotal),
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF0B1C30)
                    )
                }
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "Tax (8.5%)",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color(0xFF707974)
                    )
                    Text(
                        text = "$" + numberFormat.format(taxAmount),
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF404944)
                    )
                }
                
                Spacer(modifier = Modifier.height(4.dp))
                HorizontalDivider(color = Color(0xFFE5EEFF))
                Spacer(modifier = Modifier.height(4.dp))

                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(6.dp))
                        .background(Color(0xFFE8F6EE)) // highlighting in soft TodayGreenBg from screenshots
                        .padding(12.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Total (USD)",
                            style = MaterialTheme.typography.bodyLarge,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF003527)
                        )
                        Text(
                            text = "$" + numberFormat.format(grandTotal),
                            style = MaterialTheme.typography.headlineSmall,
                            fontWeight = FontWeight.Black,
                            color = Color(0xFF003527)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun AddressCard(
    title: String,
    content: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, Color(0xFFE5EEFF))
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(bottom = 8.dp)
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = Color(0xFF476083),
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = title,
                    style = MaterialTheme.typography.bodySmall,
                    color = Color(0xFF0F2C59),
                    fontWeight = FontWeight.Black,
                    letterSpacing = 0.5.sp
                )
            }
            Text(
                text = content,
                style = MaterialTheme.typography.bodyMedium,
                color = Color(0xFF404944),
                lineHeight = 22.sp,
                modifier = Modifier.padding(start = 28.dp)
            )
        }
    }
}

@Composable
fun PdfDocumentView(
    fileName: String,
    pageString: String,
    titleText: String,
    infoList: List<String>,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .height(340.dp),
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, Color(0xFFE5EEFF))
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Document toolbar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color(0xFFEFF4FF))
                    .border(BorderStroke(1.dp, Color(0xFFE5EEFF).copy(alpha = 0.6f)))
                    .padding(horizontal = 12.dp, vertical = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Description,
                        contentDescription = "PDF File",
                        tint = Color(0xFFBA1A1A),
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = fileName,
                        style = MaterialTheme.typography.bodySmall,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF0F2C59),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.widthIn(max = 140.dp)
                    )
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    // Zoom out
                    Icon(
                        imageVector = Icons.Default.ZoomOut,
                        contentDescription = "Zoom out",
                        tint = Color(0xFF476083),
                        modifier = Modifier.size(18.dp).clickable { }
                    )
                    // Page indicator
                    Text(
                        text = pageString,
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF404944),
                        fontWeight = FontWeight.SemiBold
                    )
                    // Zoom in
                    Icon(
                        imageVector = Icons.Default.ZoomIn,
                        contentDescription = "Zoom in",
                        tint = Color(0xFF476083),
                        modifier = Modifier.size(18.dp).clickable { }
                    )
                }
            }

            // Document body paper canvas
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .background(Color(0xFFF1F3F5)) // light gray desk desk background
                    .padding(20.dp),
                contentAlignment = Alignment.Center
            ) {
                // White paper sheet layout
                Card(
                    modifier = Modifier.fillMaxSize(),
                    shape = RoundedCornerShape(2.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                ) {
                    Box(modifier = Modifier.fillMaxSize()) {
                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.Center,
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(
                                text = titleText,
                                style = MaterialTheme.typography.bodySmall,
                                color = Color(0xFF707974),
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 1.sp,
                                textAlign = TextAlign.Center
                            )
                            
                            Spacer(modifier = Modifier.height(10.dp))
                            
                            // Visual horizontal drawing placeholder bars
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth(0.8f)
                                    .height(10.dp)
                                    .clip(RoundedCornerShape(2.dp))
                                    .background(Color(0xFFF1F3F5))
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth(0.9f)
                                    .height(10.dp)
                                    .clip(RoundedCornerShape(2.dp))
                                    .background(Color(0xFFF1F3F5))
                            )
                            Spacer(modifier = Modifier.height(14.dp))

                            // Outline box
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth(0.85f)
                                    .border(BorderStroke(1.dp, Color(0xFFD3E4FE)), RoundedCornerShape(4.dp))
                                    .padding(vertical = 12.dp, horizontal = 16.dp),
                                contentAlignment = Alignment.Center
                            ) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    infoList.forEach { info ->
                                        Text(
                                            text = info,
                                            style = MaterialTheme.typography.bodySmall,
                                            color = Color(0xFF404944),
                                            textAlign = TextAlign.Center,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                        Spacer(modifier = Modifier.height(4.dp))
                                    }
                                }
                            }
                            
                            Spacer(modifier = Modifier.height(12.dp))
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth(0.7f)
                                    .height(10.dp)
                                    .clip(RoundedCornerShape(2.dp))
                                    .background(Color(0xFFF1F3F5))
                            )
                        }

                        // Floating document navigation bar inside the page
                        Row(
                            modifier = Modifier
                                .align(Alignment.BottomCenter)
                                .padding(bottom = 12.dp)
                                .clip(RoundedCornerShape(20.dp))
                                .background(Color(0xFF0F1C2E).copy(alpha = 0.95f))
                                .padding(horizontal = 14.dp, vertical = 6.dp),
                            horizontalArrangement = Arrangement.spacedBy(20.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.ChevronLeft,
                                contentDescription = "Page back",
                                tint = Color.White,
                                modifier = Modifier.size(20.dp).clickable { }
                            )
                            Icon(
                                imageVector = Icons.Default.Refresh,
                                contentDescription = "Reload page",
                                tint = Color.White,
                                modifier = Modifier.size(18.dp).clickable { }
                            )
                            Icon(
                                imageVector = Icons.Default.ChevronRight,
                                contentDescription = "Page forward",
                                tint = Color.White,
                                modifier = Modifier.size(20.dp).clickable { }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun AttachmentRowItem(
    attachment: Attachment,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clickable { }
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(RoundedCornerShape(6.dp))
                    .background(Color(0xFFEFF4FF)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = when {
                        attachment.fileType == "pdf" -> Icons.Default.PictureAsPdf
                        attachment.fileType == "image" -> Icons.Default.Image
                        else -> Icons.Default.PlaylistAddCheck
                    },
                    contentDescription = null,
                    tint = when {
                        attachment.fileType == "pdf" -> Color(0xFFBA1A1A)
                        attachment.fileType == "image" -> Color(0xFF27AE60)
                        else -> Color(0xFF476083)
                    },
                    modifier = Modifier.size(24.dp)
                )
            }
            Spacer(modifier = Modifier.width(16.dp))
            Column {
                Text(
                    text = attachment.name,
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF0B1C30),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.widthIn(max = 180.dp)
                )
                Text(
                    text = attachment.role,
                    style = MaterialTheme.typography.bodySmall,
                    color = Color(0xFF707974),
                    fontWeight = FontWeight.SemiBold
                )
            }
        }

        Icon(
            imageVector = Icons.Default.ChevronRight,
            contentDescription = "View attachment",
            tint = Color(0xFF707974),
            modifier = Modifier.size(20.dp)
        )
    }
}
