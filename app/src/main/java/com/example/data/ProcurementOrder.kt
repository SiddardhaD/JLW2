package com.example.data

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "procurement_orders")
data class ProcurementOrder(
    @PrimaryKey val orderNo: String,
    val supplier: String,
    val originator: String,
    val amount: Double,
    val projectId: String,
    val orderDate: String,
    val status: String, // "PENDING APPROVAL", "APPROVED", "REJECTED"
    val badgeType: String, // "Pending", "High Value", "Today"
    val shippingAddress: String,
    val billingInfo: String,
    val lineItemsRaw: String, // format: "itemCode|description|qty|unitCost;;..."
    val attachmentsRaw: String // format: "name|role|fileType;;..."
) {
    // Companion object with initial prepopulated data matching screenshots
    companion object {
        val INITIAL_ORDERS = listOf(
            ProcurementOrder(
                orderNo = "#ORD-2024-8831",
                supplier = "Emirates Steel Industries",
                originator = "Saeed Al-Mansoori",
                amount = 1245000.00,
                projectId = "HLW-99-ALPHA",
                orderDate = "Oct 24, 2023",
                status = "PENDING APPROVAL",
                badgeType = "Pending",
                shippingAddress = "HLW Tech Hub - Logistics Center\n99 Innovation Way, Suite 400\nSan Francisco, CA 94105\nUnited States",
                billingInfo = "Net 30 Terms\nPO Reference: ALPHA-992-B\nAttention: Accounts Payable\nbilling@hlw-enterprise.com",
                lineItemsRaw = "SRV-001|Data Center Maintenance - Tier 3 Support (Q4)|1|12450.00;;" +
                        "HRD-552|Industrial Grade Router Cluster - Model X5|4|3200.00;;" +
                        "LIC-APP|Enterprise Security Suite - Annual Seat License|50|120.00;;" +
                        "SRV-CON|On-site Consultation & Integration Services|12|250.00",
                attachmentsRaw = "Vendor_Quote_HLW_99284.pdf|MAIN DOCUMENT|pdf;;" +
                        "Site_Survey_Photo_M30.jpg|REFERENCE|image;;" +
                        "Compliance_Check_Log.pdf|AUDIT TRAIL|list"
            ),
            ProcurementOrder(
                orderNo = "#ORD-2024-8902",
                supplier = "Global Logistics Corp",
                originator = "Jane Doe",
                amount = 45320.50,
                projectId = "M30-FLUID",
                orderDate = "Nov 12, 2023",
                status = "PENDING APPROVAL",
                badgeType = "High Value",
                shippingAddress = "Global Terminal C\n100 Shipping Way\nNew York, NY 10001\nUnited States",
                billingInfo = "Net 15 Terms\nPO Reference: LOG-441-A\nAttention: Procurement Dept\npayables@globallogistics.com",
                lineItemsRaw = "LOG-01|Global Ocean Freight Cargo Handling (40ft Container)|2|18500.00;;" +
                        "LOG-02|Brokerage & Customs Clearance Duties (Air/Sea Hub)|1|4500.00;;" +
                        "SRV-INS|On-site Carrier Loading Verification Support Hours|15|254.70",
                attachmentsRaw = "BOL_GlobalLogistics_8902.pdf|MAIN DOCUMENT|pdf;;" +
                        "Customs_Clearance_Cert.pdf|REFERENCE|pdf"
            ),
            ProcurementOrder(
                orderNo = "#ORD-2024-8915",
                supplier = "Dxb Electrics Ltd",
                originator = "Michael Chen",
                amount = 12800.00,
                projectId = "DXB-CABLE",
                orderDate = "Dec 01, 2023",
                status = "PENDING APPROVAL",
                badgeType = "Today",
                shippingAddress = "Dxb Warehouse Hub\nZone 5, Al Quoz Industrial Area\nDubai\nUnited Arab Emirates",
                billingInfo = "Immediate Bank Transfer\nPO Reference: DXB-900-E\nAttention: Finance Controller\naccounts@dxbelectrics.ae",
                lineItemsRaw = "CAB-HVY|High-Voltage Core Transmission Copper Cable (50m roll)|4|2500.00;;" +
                        "CAB-LGT|Low-Voltage Secondary Braided Wire Reels (100m roll)|10|280.00",
                attachmentsRaw = "Electrical_Specs_Sheet.pdf|MAIN DOCUMENT|pdf;;" +
                        "Supplier_Terms_Of_Trade.pdf|REFERENCE|pdf;;" +
                        "Compliance_Check_Log.pdf|AUDIT TRAIL|list"
            ),
            ProcurementOrder(
                orderNo = "#ORD-2024-9004",
                supplier = "Apex Construction",
                originator = "Fatima Khalid",
                amount = 312000.00,
                projectId = "APEX-M30",
                orderDate = "Jan 10, 2024",
                status = "PENDING APPROVAL",
                badgeType = "Pending",
                shippingAddress = "HLW Tech Hub - Logistics Center\n99 Innovation Way, Suite 400\nSan Francisco, CA 94105\nUnited States",
                billingInfo = "Net 30 Terms\nPO Reference: APEX-312-C\nAttention: Accounts Payable\nbilling@hlw-enterprise.com",
                lineItemsRaw = "CON-ST1|Structural Steel Reinforcements Frame Assembly A|1|185000.00;;" +
                        "CON-CM1|Certified Hydraulic Cement Blend (Bulk Supply Tons)|4|25000.00;;" +
                        "SRV-LAB|Qualified Field Engineering Supervisor Support Days|11|2454.54",
                attachmentsRaw = "Structural_Design_Plans.pdf|MAIN DOCUMENT|pdf;;" +
                        "Apex_Trade_Safety_Audit.pdf|REFERENCE|pdf"
            )
        )
    }
}

data class LineItem(
    val itemCode: String,
    val description: String,
    val qty: Int,
    val unitCost: Double
) {
    val totalCost: Double get() = qty * unitCost
}

data class Attachment(
    val name: String,
    val role: String, // "MAIN DOCUMENT", "REFERENCE", "AUDIT TRAIL"
    val fileType: String // "pdf", "image", "list"
)

fun ProcurementOrder.getLineItems(): List<LineItem> {
    if (lineItemsRaw.isEmpty()) return emptyList()
    return lineItemsRaw.split(";;").mapNotNull { rawLine ->
        val parts = rawLine.split("|")
        if (parts.size >= 4) {
            LineItem(
                itemCode = parts[0],
                description = parts[1],
                qty = parts[2].toIntOrNull() ?: 0,
                unitCost = parts[3].toDoubleOrNull() ?: 0.0
            )
        } else null
    }
}

fun ProcurementOrder.getAttachments(): List<Attachment> {
    if (attachmentsRaw.isEmpty()) return emptyList()
    return attachmentsRaw.split(";;").mapNotNull { rawLine ->
        val parts = rawLine.split("|")
        if (parts.size >= 3) {
            Attachment(
                name = parts[0],
                role = parts[1],
                fileType = parts[2]
            )
        } else null
    }
}
