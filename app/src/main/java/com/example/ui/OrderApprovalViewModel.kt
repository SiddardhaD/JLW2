package com.example.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.data.ProcurementOrder
import com.example.data.ProcurementOrderRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class OrderApprovalViewModel(private val repository: ProcurementOrderRepository) : ViewModel() {

    init {
        // Safe measure to ensure initial data exists
        viewModelScope.launch {
            repository.ensurePrepopulated()
        }
    }

    // State of logged-in user
    private val _currentUser = MutableStateFlow("HLW-99284-EXEC")
    val currentUser: StateFlow<String> = _currentUser.asStateFlow()

    // State of keep signed in
    private val _keepSignedIn = MutableStateFlow(false)
    val keepSignedIn: StateFlow<Boolean> = _keepSignedIn.asStateFlow()

    // State of search query
    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    // State of list filter
    private val _selectedFilter = MutableStateFlow("All")
    val selectedFilter: StateFlow<String> = _selectedFilter.asStateFlow()

    // Combine all list states reactively
    val uiState: StateFlow<List<ProcurementOrder>> = combine(
        repository.allOrders,
        _searchQuery,
        _selectedFilter
    ) { orders, query, filter ->
        var filteredList = orders

        // 1. Filter by Search Query
        if (query.isNotEmpty()) {
            filteredList = filteredList.filter { order ->
                order.orderNo.contains(query, ignoreCase = true) ||
                        order.supplier.contains(query, ignoreCase = true) ||
                        order.originator.contains(query, ignoreCase = true)
            }
        }

        // 2. Filter by Badge Type Filter
        if (filter != "All") {
            filteredList = filteredList.filter { order ->
                when (filter) {
                    "High Value" -> order.badgeType.equals("High Value", ignoreCase = true)
                    "Today" -> order.badgeType.equals("Today", ignoreCase = true)
                    "Pending" -> order.badgeType.equals("Pending", ignoreCase = true) || 
                                 order.status.equals("PENDING APPROVAL", ignoreCase = true)
                    else -> true
                }
            }
        }

        filteredList
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    fun loginUser(username: String) {
        if (username.trim().isNotEmpty()) {
            _currentUser.value = username.trim()
        } else {
            _currentUser.value = "HLW-99284-EXEC"
        }
    }

    fun setKeepSignedIn(keep: Boolean) {
        _keepSignedIn.value = keep
    }

    fun setSearchQuery(query: String) {
        _searchQuery.value = query
    }

    fun setSelectedFilter(filter: String) {
        _selectedFilter.value = filter
    }

    fun getOrderDetails(orderNo: String): Flow<ProcurementOrder?> {
        return repository.getOrderById(orderNo)
    }

    fun approveOrder(orderNo: String, onComplete: () -> Unit) {
        viewModelScope.launch {
            repository.updateOrderStatus(orderNo, "APPROVED")
            onComplete()
        }
    }

    fun rejectOrder(orderNo: String, onComplete: () -> Unit) {
        viewModelScope.launch {
            repository.updateOrderStatus(orderNo, "REJECTED")
            onComplete()
        }
    }

    fun resetAllData() {
        viewModelScope.launch {
            repository.resetDatabase()
            _searchQuery.value = ""
            _selectedFilter.value = "All"
        }
    }
}

// Factory for standard Viewmodel constructor injection
class OrderApprovalViewModelFactory(private val repository: ProcurementOrderRepository) :
    ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(OrderApprovalViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return OrderApprovalViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
