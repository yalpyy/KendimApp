import 'package:kendin/domain/entities/entry_entity.dart';
import 'package:kendin/domain/entities/weekly_reflection_entity.dart';
import 'package:kendin/domain/repositories/entry_repository.dart';
import 'package:kendin/domain/repositories/reflection_repository.dart';

/// In-memory reflection repository for demo mode.
///
/// Generates mock reflections using local templates.
/// No Edge Function, no OpenAI, no Supabase.
class DemoReflectionRepository implements ReflectionRepository {
  DemoReflectionRepository(this._entryRepository);

  final EntryRepository _entryRepository;
  final Map<String, WeeklyReflectionEntity> _reflections = {};
  int _idCounter = 0;

  /// Static mock reflection templates.
  /// Each is a list of 5 sentences, selected based on entry count.
  static const List<List<String>> _templates = [
    // 0-1 entries
    [
      'Bu hafta sessizce geçti.',
      'Çok az yazdın ama o bile bir adımdı.',
      'Bazen az söz, derin bir nefes gibidir.',
      'Kendine vakit ayırmak her zaman kolay olmayabilir.',
      'Yine de burada olman bir şey anlatıyor.',
    ],
    // 2-3 entries
    [
      'Bu hafta birkaç kez kendine alan açtın.',
      'Yazıların genelde kısa ama tutarlıydı.',
      'Özellikle hafta ortasında daha az yazdın.',
      'Bu hafta kendine dönmeye çalıştığın belli.',
      'Sessiz bir tempo vardı.',
    ],
    // 4-5 entries
    [
      'Bu hafta yazılarında bir süreklilik var.',
      'Bazı günler daha fazla paylaştın, bazı günler birkaç kelimeyle yetindin.',
      'Haftanın ortasında bir duraksama oldu gibi.',
      'Ama sonra geri döndün, bu önemli.',
      'Kendine baktığın günleri fark etmek güzel.',
    ],
    // 6 entries (full week)
    [
      'Bu hafta her gün kendin için bir şeyler yazdın.',
      'Yazılarında hafif bir ritim oluşmuş.',
      'Bazı günler daha içe dönük, bazı günler daha hafiftin.',
      'Haftayı tam olarak tamamlaman bir bütünlük hissi veriyor.',
      'Sessizce ama kararlılıkla buradaydın.',
    ],
  ];

  @override
  Future<void> generateReflection(
    String userId,
    DateTime weekStart, {
    bool isPremium = false,
  }) async {
    final key = _reflectionKey(userId, weekStart);
    if (_reflections.containsKey(key)) return;

    // Fetch entries for the week to determine template.
    final entries = await _entryRepository.getWeekEntries(userId, weekStart);
    final content = _buildReflection(entries);

    _idCounter++;
    _reflections[key] = WeeklyReflectionEntity(
      id: 'demo-reflection-$_idCounter',
      userId: userId,
      weekStartDate: weekStart,
      content: content,
      isArchived: false,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<WeeklyReflectionEntity?> getReflection(
    String userId,
    DateTime weekStart,
  ) async {
    return _reflections[_reflectionKey(userId, weekStart)];
  }

  @override
  Future<List<WeeklyReflectionEntity>> getArchivedReflections(
    String userId,
  ) async {
    return _reflections.values
        .where((r) => r.userId == userId && r.isArchived)
        .toList();
  }

  @override
  Future<void> archiveReflection(String reflectionId) async {
    final key = _reflections.entries
        .where((e) => e.value.id == reflectionId)
        .map((e) => e.key)
        .firstOrNull;
    if (key == null) return;

    final old = _reflections[key]!;
    _reflections[key] = WeeklyReflectionEntity(
      id: old.id,
      userId: old.userId,
      weekStartDate: old.weekStartDate,
      content: old.content,
      isArchived: true,
      createdAt: old.createdAt,
    );
  }

  // ─── Helpers ─────────────────────────────────────

  String _reflectionKey(String userId, DateTime weekStart) {
    final dateStr = weekStart.toIso8601String().split('T').first;
    return '$userId:$dateStr';
  }

  String _buildReflection(List<EntryEntity> entries) {
    final count = entries.length;
    final int templateIndex;
    if (count <= 1) {
      templateIndex = 0;
    } else if (count <= 3) {
      templateIndex = 1;
    } else if (count <= 5) {
      templateIndex = 2;
    } else {
      templateIndex = 3;
    }
    return _templates[templateIndex].join(' ');
  }
}
