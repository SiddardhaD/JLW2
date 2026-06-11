package com.example.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.Login
import androidx.compose.material.icons.filled.Face
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shadow
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun JlwLogo(modifier: Modifier = Modifier, sizeMultiplier: Float = 1.0f) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "JLW",
            fontFamily = FontFamily.Serif,
            fontWeight = FontWeight.Black,
            fontSize = (42 * sizeMultiplier).sp,
            color = Color(0xFF0F2C59), // Elegant deep Navy matching screenshot
            letterSpacing = 1.sp,
            style = TextStyle(
                shadow = Shadow(
                    color = Color.Black.copy(alpha = 0.12f),
                    offset = Offset(2f, 2f),
                    blurRadius = 3f
                )
            )
        )
        Text(
            text = "SINCE 1875",
            fontFamily = FontFamily.SansSerif,
            fontWeight = FontWeight.Bold,
            fontSize = (10 * sizeMultiplier).sp,
            color = Color(0xFF707974),
            letterSpacing = 4.sp
        )
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    viewModel: OrderApprovalViewModel,
    onLoginSuccess: () -> Unit,
    modifier: Modifier = Modifier
) {
    var username by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var passwordVisible by remember { mutableStateOf(false) }
    val keepSignedIn by viewModel.keepSignedIn.collectAsState()
    
    val scope = rememberCoroutineScope()
    val focusManager = LocalFocusManager.current
    val scrollState = rememberScrollState()
    
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf("") }

    // Surface background color #F8F9FF
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(Color(0xFFF8F9FF))
            .windowInsetsPadding(WindowInsets.safeDrawing)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 24.dp)
                .verticalScroll(scrollState),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Top
        ) {
            Spacer(modifier = Modifier.height(30.dp))
            
            // Outer white container card with subtle border from screenshot
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .wrapContentHeight(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                border = BorderStroke(1.dp, Color(0xFFE5EEFF))
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    JlwLogo(sizeMultiplier = 1.0f)
                    
                    Spacer(modifier = Modifier.height(24.dp))
                    
                    Text(
                        text = "Order Approval Portal",
                        style = MaterialTheme.typography.headlineMedium,
                        color = Color(0xFF003527), // Specific dark green heading
                        fontWeight = FontWeight.Bold,
                        textAlign = TextAlign.Center
                    )
                    
                    Text(
                        text = "Enterprise procurement management",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color(0xFF707974),
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                    
                    Spacer(modifier = Modifier.height(28.dp))

                    if (errorMessage.isNotEmpty()) {
                        Text(
                            text = errorMessage,
                            color = MaterialTheme.colorScheme.error,
                            style = MaterialTheme.typography.bodySmall,
                            modifier = Modifier.padding(bottom = 12.dp)
                        )
                    }

                    // Username Form
                    Column(modifier = Modifier.fillMaxWidth()) {
                        Text(
                            text = "Username",
                            style = MaterialTheme.typography.bodyMedium,
                            fontWeight = FontWeight.Bold,
                            color = Color(0xFF0B1C30),
                            modifier = Modifier.padding(bottom = 6.dp)
                        )
                        
                        TextField(
                            value = username,
                            onValueChange = {
                                username = it
                                errorMessage = ""
                            },
                            placeholder = { Text("Enter corporate ID", color = Color(0xFF707974)) },
                            leadingIcon = {
                                Icon(
                                    imageVector = Icons.Default.Person,
                                    contentDescription = "User Icon",
                                    tint = Color(0xFF707974)
                                )
                            },
                            singleLine = true,
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = Color(0xFFEFF4FF),
                                unfocusedContainerColor = Color(0xFFEFF4FF),
                                disabledContainerColor = Color(0xFFEFF4FF),
                                focusedIndicatorColor = Color.Transparent,
                                unfocusedIndicatorColor = Color.Transparent,
                                disabledIndicatorColor = Color.Transparent
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("username_input")
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(18.dp))

                    // Password Form
                    Column(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Password",
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF0B1C30)
                            )
                            
                            Text(
                                text = "Forgot?",
                                style = MaterialTheme.typography.bodyMedium,
                                fontWeight = FontWeight.Bold,
                                color = Color(0xFF476083),
                                modifier = Modifier
                                    .clickable { /* Handle forgot password link */ }
                                    .testTag("forgot_password_button")
                            )
                        }
                        
                        Spacer(modifier = Modifier.height(6.dp))
                        
                        TextField(
                            value = password,
                            onValueChange = {
                                password = it
                                errorMessage = ""
                            },
                            placeholder = { Text("........", color = Color(0xFF707974), fontWeight = FontWeight.Black) },
                            leadingIcon = {
                                Icon(
                                    imageVector = Icons.Default.Lock,
                                    contentDescription = "Password Icon",
                                    tint = Color(0xFF707974)
                                )
                            },
                            trailingIcon = {
                                val image = if (passwordVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility
                                val description = if (passwordVisible) "Hide password" else "Show password"
                                
                                IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                    Icon(imageVector = image, contentDescription = description, tint = Color(0xFF707974))
                                }
                            },
                            visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                            singleLine = true,
                            colors = TextFieldDefaults.colors(
                                focusedContainerColor = Color(0xFFEFF4FF),
                                unfocusedContainerColor = Color(0xFFEFF4FF),
                                disabledContainerColor = Color(0xFFEFF4FF),
                                focusedIndicatorColor = Color.Transparent,
                                unfocusedIndicatorColor = Color.Transparent,
                                disabledIndicatorColor = Color.Transparent
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier
                                .fillMaxWidth()
                                .testTag("password_input")
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(16.dp))

                    // Keep signed in for 24 hours Checkbox
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { viewModel.setKeepSignedIn(!keepSignedIn) }
                            .padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Checkbox(
                            checked = keepSignedIn,
                            onCheckedChange = { viewModel.setKeepSignedIn(it) },
                            colors = CheckboxDefaults.colors(checkedColor = Color(0xFF003527))
                        )
                        Text(
                            text = "Keep me signed in for 24 hours",
                            style = MaterialTheme.typography.bodyMedium,
                            color = Color(0xFF404944),
                            modifier = Modifier.padding(start = 4.dp)
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(20.dp))

                    // Sign In Button
                    Button(
                        onClick = {
                            focusManager.clearFocus()
                            if (username.isBlank()) {
                                errorMessage = "Please enter corporate ID"
                                return@Button
                            }
                            isLoading = true
                            scope.launch {
                                delay(1200) // Simulated loading
                                isLoading = false
                                viewModel.loginUser(username)
                                onLoginSuccess()
                            }
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(52.dp)
                            .testTag("sign_in_button"),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFF003527), // Corporate deep green
                            contentColor = Color.White
                        ),
                        shape = RoundedCornerShape(8.dp),
                        enabled = !isLoading
                    ) {
                        if (isLoading) {
                            CircularProgressIndicator(
                                color = Color.White,
                                modifier = Modifier.size(24.dp),
                                strokeWidth = 2.5.dp
                            )
                        } else {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.Center,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = "Sign In ",
                                    style = MaterialTheme.typography.bodyLarge,
                                    fontWeight = FontWeight.Bold
                                )
                                Icon(
                                    imageVector = Icons.AutoMirrored.Filled.Login,
                                    contentDescription = "Sign In Arrow",
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        }
                    }
                    
                    Spacer(modifier = Modifier.height(24.dp))

                    // OR BIOMETRIC Divider
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        HorizontalDivider(
                            modifier = Modifier.weight(1f),
                            color = Color(0xFFE5EEFF)
                        )
                        Text(
                            text = "OR BIOMETRIC",
                            style = MaterialTheme.typography.labelMedium,
                            color = Color(0xFF707974),
                            textAlign = TextAlign.Center,
                            modifier = Modifier.padding(horizontal = 12.dp)
                        )
                        HorizontalDivider(
                            modifier = Modifier.weight(1f),
                            color = Color(0xFFE5EEFF)
                        )
                    }
                    
                    Spacer(modifier = Modifier.height(20.dp))

                    // Face ID / Fingerprint Row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        // Face ID card
                        OutlinedCard(
                            onClick = {
                                isLoading = true
                                scope.launch {
                                    delay(800)
                                    isLoading = false
                                    viewModel.loginUser("HLW-99284-EXEC") // standard biometric admin ID
                                    onLoginSuccess()
                                }
                            },
                            modifier = Modifier
                                .weight(1f)
                                .height(100.dp)
                                .testTag("face_id_card"),
                            shape = RoundedCornerShape(8.dp),
                            border = BorderStroke(1.dp, Color(0xFFE5EEFF)),
                            colors = CardDefaults.outlinedCardColors(containerColor = Color.White)
                        ) {
                            Column(
                                modifier = Modifier.fillMaxSize(),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Face,
                                    contentDescription = "Face ID",
                                    tint = Color(0xFF003527),
                                    modifier = Modifier.size(36.dp)
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = "Face ID",
                                    style = MaterialTheme.typography.bodySmall,
                                    fontWeight = FontWeight.Bold,
                                    color = Color(0xFF0B1C30)
                                )
                            }
                        }

                        // Fingerprint card
                        OutlinedCard(
                            onClick = {
                                isLoading = true
                                scope.launch {
                                    delay(800)
                                    isLoading = false
                                    viewModel.loginUser("HLW-99284-EXEC")
                                    onLoginSuccess()
                                }
                            },
                            modifier = Modifier
                                .weight(1f)
                                .height(100.dp)
                                .testTag("fingerprint_card"),
                            shape = RoundedCornerShape(8.dp),
                            border = BorderStroke(1.dp, Color(0xFFE5EEFF)),
                            colors = CardDefaults.outlinedCardColors(containerColor = Color.White)
                        ) {
                            Column(
                                modifier = Modifier.fillMaxSize(),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Fingerprint,
                                    contentDescription = "Fingerprint",
                                    tint = Color(0xFF003527),
                                    modifier = Modifier.size(36.dp)
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = "Fingerprint",
                                    style = MaterialTheme.typography.bodySmall,
                                    fontWeight = FontWeight.Bold,
                                    color = Color(0xFF0B1C30)
                                )
                            }
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(30.dp))

            // Footer Section
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Privacy\nPolicy",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color(0xFF476083),
                    fontWeight = FontWeight.SemiBold,
                    textAlign = TextAlign.Center,
                    textDecoration = TextDecoration.Underline,
                    modifier = Modifier.clickable { }
                )
                Text(
                    text = "Terms of\nService",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color(0xFF476083),
                    fontWeight = FontWeight.SemiBold,
                    textAlign = TextAlign.Center,
                    textDecoration = TextDecoration.Underline,
                    modifier = Modifier.clickable { }
                )
                Text(
                    text = "Security\nStandards",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color(0xFF476083),
                    fontWeight = FontWeight.SemiBold,
                    textAlign = TextAlign.Center,
                    textDecoration = TextDecoration.Underline,
                    modifier = Modifier.clickable { }
                )
            }
            
            Spacer(modifier = Modifier.height(20.dp))
            
            Text(
                text = "© 2024 HLW Enterprise Systems. All rights reserved.",
                style = MaterialTheme.typography.bodySmall,
                color = Color(0xFF707974),
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(bottom = 36.dp)
            )
        }
    }
}
