package com.example.data

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first

class ProcurementOrderRepository(private val orderDao: ProcurementOrderDao) {
    
    val allOrders: Flow<List<ProcurementOrder>> = orderDao.getAllOrders()

    fun getOrderById(orderNo: String): Flow<ProcurementOrder?> = orderDao.getOrderById(orderNo)

    suspend fun updateOrderStatus(orderNo: String, status: String) {
        orderDao.updateOrderStatus(orderNo, status)
    }

    suspend fun resetDatabase() {
        orderDao.clearAllOrders()
        orderDao.insertOrders(ProcurementOrder.INITIAL_ORDERS)
    }

    suspend fun ensurePrepopulated() {
        // Safe check to verify we have orders, populate if empty
        val currentOrders = orderDao.getAllOrders().first()
        if (currentOrders.isEmpty()) {
            orderDao.insertOrders(ProcurementOrder.INITIAL_ORDERS)
        }
    }
}
