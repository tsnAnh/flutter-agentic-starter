package dev.tsnanh.kmpagenticstarter.screens

import androidx.compose.foundation.layout.Box
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import dev.tsnanh.kmpagenticstarter.R

@Composable
fun EmptyScreenContent(
    modifier: Modifier = Modifier,
    message: String? = null,
) {
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center,
    ) {
        Text(message ?: stringResource(R.string.no_data_available))
    }
}
