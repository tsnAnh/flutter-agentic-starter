package dev.tsnanh.creativenote.screens

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import dev.tsnanh.creativenote.features.notes.domain.models.VoiceNote
import dev.tsnanh.creativenote.features.notes.presentation.NotesViewModel
import org.koin.compose.viewmodel.koinViewModel

@Composable
fun ListScreen() {
    val viewModel: NotesViewModel = koinViewModel()
    val notes by viewModel.notes.collectAsStateWithLifecycle()
    val error by viewModel.notesErrorMessage.collectAsStateWithLifecycle()

    when {
        error != null -> EmptyScreenContent(Modifier.fillMaxSize(), message = error.orEmpty())
        notes.isEmpty() -> EmptyScreenContent(
            modifier = Modifier.fillMaxSize(),
            message = "Pull to record on iOS first. Android voice capture comes later.",
        )
        else -> NoteList(notes)
    }
}

@Composable
private fun NoteList(
    notes: List<VoiceNote>,
    modifier: Modifier = Modifier,
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = WindowInsets.safeDrawing.asPaddingValues(),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(notes, key = { it.id }) { note ->
            NoteRow(note)
        }
    }
}

@Composable
private fun NoteRow(
    note: VoiceNote,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp),
    ) {
        Text(note.title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
        Text(note.summary, style = MaterialTheme.typography.bodyMedium)
        Text("${note.durationMillis / 1000}s · voice", style = MaterialTheme.typography.bodySmall)
    }
}
