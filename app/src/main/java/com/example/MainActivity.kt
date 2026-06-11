package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.ExperimentalAnimationApi
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.with
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.ui.LoginScreen
import com.example.ui.OrderDetailScreen
import com.example.ui.OrderListScreen
import com.example.ui.OrderApprovalViewModel
import com.example.ui.OrderApprovalViewModelFactory
import com.example.ui.theme.MyApplicationTheme

sealed class Screen {
    object Login : Screen()
    object OrderList : Screen()
    data class OrderDetail(val orderNo: String) : Screen()
}

class MainActivity : ComponentActivity() {
    @OptIn(ExperimentalAnimationApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            MyApplicationTheme {
                val context = LocalContext.current
                val app = context.applicationContext as OrderApprovalApplication
                val viewModel: OrderApprovalViewModel = viewModel(
                    factory = OrderApprovalViewModelFactory(app.repository)
                )

                // Simple yet production-grade and crash-free backstack manager
                var currentScreen by remember { mutableStateOf<Screen>(Screen.Login) }
                val backstack = remember { mutableStateListOf<Screen>(Screen.Login) }

                fun navigateTo(screen: Screen) {
                    backstack.add(screen)
                    currentScreen = screen
                }

                fun navigateBack() {
                    if (backstack.size > 1) {
                        backstack.removeLast()
                        currentScreen = backstack.last()
                    }
                }

                // Beautiful transitions between screens (under 300ms as per design guidelines)
                AnimatedContent(
                    targetState = currentScreen,
                    transitionSpec = {
                        fadeIn(animationSpec = tween(220)) with fadeOut(animationSpec = tween(220))
                    },
                    label = "screen_transitions"
                ) { screen ->
                    when (screen) {
                        is Screen.Login -> {
                            LoginScreen(
                                viewModel = viewModel,
                                onLoginSuccess = {
                                    navigateTo(Screen.OrderList)
                                },
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                        is Screen.OrderList -> {
                            OrderListScreen(
                                viewModel = viewModel,
                                onOrderClick = { orderNo ->
                                    navigateTo(Screen.OrderDetail(orderNo))
                                },
                                onLogout = {
                                    backstack.clear()
                                    backstack.add(Screen.Login)
                                    currentScreen = Screen.Login
                                },
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                        is Screen.OrderDetail -> {
                            OrderDetailScreen(
                                orderNo = screen.orderNo,
                                viewModel = viewModel,
                                onBack = {
                                    navigateBack()
                                },
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                    }
                }
            }
        }
    }
}

