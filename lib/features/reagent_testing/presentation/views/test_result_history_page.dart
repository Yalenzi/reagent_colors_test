import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/test_result_entity.dart';
import '../providers/reagent_testing_providers.dart';
import '../states/test_result_history_state.dart';

class TestResultHistoryPage extends ConsumerStatefulWidget {
  const TestResultHistoryPage({super.key});

  @override
  ConsumerState<TestResultHistoryPage> createState() =>
      _TestResultHistoryPageState();
}

class _TestResultHistoryPageState extends ConsumerState<TestResultHistoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedReagentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load test results when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testResultHistoryControllerProvider.notifier).loadTestResults();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testResultHistoryControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(testResultHistoryControllerProvider.notifier)
                .refresh(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.cloud_sync),
                    SizedBox(width: 8),
                    Text('Sync to Cloud'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.analytics), text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(state, theme),
          _buildStatisticsTab(state, theme),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(TestResultHistoryState state, ThemeData theme) {
    return state.when(
      initial: () => const Center(child: Text('Loading...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      loaded: (results) => _buildHistoryList(results, theme),
      error: (message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Error: $message'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(testResultHistoryControllerProvider.notifier)
                  .refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<TestResultEntity> results, ThemeData theme) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text('No test results yet', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Complete some tests to see your history here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Filter results based on search and reagent filter
    final filteredResults = _filterResults(results);

    return Column(
      children: [
        _buildSearchAndFilter(theme),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredResults.length,
            itemBuilder: (context, index) {
              final result = filteredResults[index];
              return _buildResultCard(result, theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by substance or notes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Filter by reagent:', style: theme.textTheme.bodyMedium),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedReagentFilter,
                  isExpanded: true,
                  items: _getReagentFilterOptions().map((reagent) {
                    return DropdownMenuItem(
                      value: reagent,
                      child: Text(reagent),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedReagentFilter = value ?? 'All');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(TestResultEntity result, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    result.reagentName,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  dateFormat.format(result.testCompletedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _showDeleteConfirmation(result),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.palette,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Observed: ${result.observedColor}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.science,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Possible: ${result.possibleSubstances.join(', ')}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Confidence: ${result.confidencePercentage}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: _getConfidenceColor(result.confidencePercentage),
                  ),
                ),
              ],
            ),
            if (result.notes != null && result.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsTab(TestResultHistoryState state, ThemeData theme) {
    return state.when(
      initial: () => const Center(child: Text('Loading...')),
      loading: () => const Center(child: CircularProgressIndicator()),
      loaded: (results) => _buildStatistics(results, theme),
      error: (message) => Center(child: Text('Error: $message')),
    );
  }

  Widget _buildStatistics(List<TestResultEntity> results, ThemeData theme) {
    if (results.isEmpty) {
      return const Center(child: Text('No data for statistics'));
    }

    final controller = ref.read(testResultHistoryControllerProvider.notifier);
    final stats = controller.getStatistics();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard(
            'Total Tests',
            stats['totalTests'].toString(),
            Icons.science,
            theme,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Most Used Reagent',
            stats['mostUsedReagent'],
            Icons.favorite,
            theme,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            'Average Confidence',
            '${stats['averageConfidence'].toStringAsFixed(1)}%',
            Icons.analytics,
            theme,
          ),
          const SizedBox(height: 24),
          Text(
            'Tests by Reagent',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildReagentBreakdown(stats['testsByReagent'], theme),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReagentBreakdown(
    Map<String, int> testsByReagent,
    ThemeData theme,
  ) {
    final total = testsByReagent.values.fold(0, (sum, count) => sum + count);

    return testsByReagent.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(entry.key, style: theme.textTheme.bodyMedium),
            ),
            Expanded(
              flex: 3,
              child: LinearProgressIndicator(
                value: entry.value / total,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${entry.value} ($percentage%)',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }).toList();
  }

  List<TestResultEntity> _filterResults(List<TestResultEntity> results) {
    var filtered = results;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((result) {
        final query = _searchQuery.toLowerCase();
        return result.possibleSubstances.any(
              (substance) => substance.toLowerCase().contains(query),
            ) ||
            (result.notes?.toLowerCase().contains(query) ?? false) ||
            result.observedColor.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by reagent
    if (_selectedReagentFilter != 'All') {
      filtered = filtered
          .where((result) => result.reagentName == _selectedReagentFilter)
          .toList();
    }

    return filtered;
  }

  List<String> _getReagentFilterOptions() {
    final state = ref.watch(testResultHistoryControllerProvider);
    return state.maybeWhen(
      loaded: (results) {
        final reagents = results.map((r) => r.reagentName).toSet().toList()
          ..sort();
        return ['All', ...reagents];
      },
      orElse: () => ['All'],
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 80) return Colors.green;
    if (confidence >= 60) return Colors.orange;
    return Colors.red;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'sync':
        ref
            .read(testResultHistoryControllerProvider.notifier)
            .syncToFirestore();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Syncing to cloud...')));
        break;
      case 'clear':
        _showClearAllConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation(TestResultEntity result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Test Result'),
        content: Text(
          'Are you sure you want to delete this ${result.reagentName} test result?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(testResultHistoryControllerProvider.notifier)
                  .deleteTestResult(result.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Results'),
        content: const Text(
          'Are you sure you want to delete all test results? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(testResultHistoryControllerProvider.notifier)
                  .clearAllResults();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
