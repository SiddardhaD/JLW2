package com.example.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface ProcurementOrderDao {
    @Query("SELECT * FROM procurement_orders")
    fun getAllOrders(): Flow<List<ProcurementOrder>>

    @Query("SELECT * FROM procurement_orders WHERE orderNo = :orderNo")
    fun getOrderById(orderNo: String): Flow<ProcurementOrder?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrders(orders: List<ProcurementOrder>)

    @Query("UPDATE procurement_orders SET status = :status WHERE orderNo = :orderNo")
    suspend fun updateOrderStatus(orderNo: String, status: String)

    @Query("DELETE FROM procurement_orders")
    suspend fun clearAllOrders()
}
