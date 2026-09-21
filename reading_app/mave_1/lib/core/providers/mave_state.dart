/// The behavior states for the Mave NPC.
/// Kept in its own file to avoid circular imports between
/// [GeminiLiveService] and [app_providers].
enum MaveState { idle, listening, speaking, happy }
