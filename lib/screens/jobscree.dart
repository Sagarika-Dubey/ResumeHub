import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class JobRecommendations extends StatefulWidget {
  const JobRecommendations({Key? key}) : super(key: key);

  @override
  _JobRecommendationsState createState() => _JobRecommendationsState();
}

class _JobRecommendationsState extends State<JobRecommendations> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<dynamic> _jobs = [];
  bool _isLoading = false;
  String _error = '';
  bool _showFilters = false;
  String _sortBy = 'relevance';
  int _resultsPerPage = 10;
  String _distanceKm = '30';
  List<String> _recentSearches = [];
  List<String> _savedJobs = [];

  // Replace with your actual Adzuna API credentials
  final String _appId = '18ee27b2';
  final String _appKey = '973e7637ba5482f29e75eaf0e10f6e16';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadSavedJobs();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  Future<void> _saveSearch(String keyword, String location) async {
    if (keyword.isEmpty) return;

    final search = '$keyword${location.isNotEmpty ? " in $location" : ""}';
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_recentSearches.contains(search)) {
        _recentSearches.remove(search);
      }
      _recentSearches.insert(0, search);
      if (_recentSearches.length > 5) {
        _recentSearches = _recentSearches.sublist(0, 5);
      }
    });

    await prefs.setStringList('recentSearches', _recentSearches);
  }

  Future<void> _loadSavedJobs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedJobs = prefs.getStringList('savedJobs') ?? [];
    });
  }

  Future<void> _toggleSaveJob(String jobId, String jobTitle) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_savedJobs.contains(jobId)) {
        _savedJobs.remove(jobId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from saved jobs: $jobTitle')),
        );
      } else {
        _savedJobs.add(jobId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved job: $jobTitle')),
        );
      }
    });

    await prefs.setStringList('savedJobs', _savedJobs);
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final keyword = _keywordController.text.trim();
      final location = _locationController.text.trim();

      if (keyword.isEmpty) {
        throw Exception('Please enter a job title or keyword');
      }

      // Save this search to recent searches
      await _saveSearch(keyword, location);

      final queryParams = {
        'app_id': _appId,
        'app_key': _appKey,
        'results_per_page': _resultsPerPage.toString(),
        'what': keyword,
        'content-type': 'application/json',
        'sort_by': _sortBy,
        'max_days_old': '30',
      };

      if (location.isNotEmpty) {
        queryParams['where'] = location;
        queryParams['distance'] = _distanceKm;
      }

      final uri =
          Uri.https('api.adzuna.com', '/v1/api/jobs/in/search/1', queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _jobs = data['results'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openJobLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open job listing')),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              // Navigate to saved jobs page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved Jobs feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search form
            TextField(
              controller: _keywordController,
              decoration: InputDecoration(
                labelText: 'Job Title or Keywords',
                border: const OutlineInputBorder(),
                hintText: 'e.g. Software Developer, Marketing',
                prefixIcon: const Icon(Icons.work),
                suffixIcon: _keywordController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _keywordController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() => _error = ''),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Location (Optional)',
                border: const OutlineInputBorder(),
                hintText: 'e.g. London, Manchester',
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: _locationController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _locationController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),

            // Recent searches
            if (_recentSearches.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8.0,
                  children: _recentSearches.map((search) {
                    return Chip(
                      label: Text(search),
                      onDeleted: () async {
                        setState(() {
                          _recentSearches.remove(search);
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setStringList(
                            'recentSearches', _recentSearches);
                      },
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                      labelStyle: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                    );
                  }).toList(),
                ),
              ),

            // Search filters
            TextButton.icon(
              icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
              label: Text(_showFilters ? 'Hide Filters' : 'Show Filters'),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),

            if (_showFilters)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sort By',
                          border: OutlineInputBorder(),
                        ),
                        value: _sortBy,
                        items: const [
                          DropdownMenuItem(
                            value: 'relevance',
                            child: Text('Relevance'),
                          ),
                          DropdownMenuItem(
                            value: 'date',
                            child: Text('Date Posted'),
                          ),
                          DropdownMenuItem(
                            value: 'salary',
                            child: Text('Salary'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _sortBy = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Results Per Page',
                          border: OutlineInputBorder(),
                        ),
                        value: _resultsPerPage,
                        items: const [
                          DropdownMenuItem(
                            value: 5,
                            child: Text('5'),
                          ),
                          DropdownMenuItem(
                            value: 10,
                            child: Text('10'),
                          ),
                          DropdownMenuItem(
                            value: 20,
                            child: Text('20'),
                          ),
                          DropdownMenuItem(
                            value: 50,
                            child: Text('50'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _resultsPerPage = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Distance (km)',
                          border: OutlineInputBorder(),
                          enabled: false,
                        ),
                        value: _distanceKm,
                        items: const [
                          DropdownMenuItem(
                            value: '5',
                            child: Text('5 km'),
                          ),
                          DropdownMenuItem(
                            value: '10',
                            child: Text('10 km'),
                          ),
                          DropdownMenuItem(
                            value: '30',
                            child: Text('30 km'),
                          ),
                          DropdownMenuItem(
                            value: '50',
                            child: Text('50 km'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _distanceKm = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchJobs,
              icon: const Icon(Icons.search),
              label: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Find Jobs'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 20),

            // Results count
            if (_jobs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Found ${_jobs.length} job${_jobs.length == 1 ? "" : "s"}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            // Job listings
            Expanded(
              child: _jobs.isEmpty && !_isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Enter job details and search to see recommendations',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _jobs.length,
                      itemBuilder: (context, index) {
                        final job = _jobs[index];
                        final jobId = job['id'] ?? '';
                        final isSaved = _savedJobs.contains(jobId);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  job['title'] ?? 'No title',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(job['company']['display_name'] ??
                                    'Unknown company'),
                                trailing: IconButton(
                                  icon: Icon(
                                    isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isSaved ? Colors.blue : null,
                                  ),
                                  onPressed: () => _toggleSaveJob(
                                    jobId,
                                    job['title'] ?? 'Job',
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            job['location']['display_name'] ??
                                                'Remote/Unknown location',
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (job['salary_min'] != null ||
                                        job['salary_max'] != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.attach_money,
                                              size: 16, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatSalary(job['salary_min'],
                                                job['salary_max']),
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Posted: ${_formatDate(job['created'])}',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (job['description'] != null)
                                      Text(
                                        _truncateText(
                                            job['description'] ?? '', 150),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        if (job['contract_time'] != null)
                                          Chip(
                                            label: Text(
                                              job['contract_time'] ==
                                                      'full_time'
                                                  ? 'Full Time'
                                                  : 'Part Time',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            labelStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant),
                                          ),
                                        if (job['contract_type'] != null)
                                          Chip(
                                            label: Text(
                                              job['contract_type'] ==
                                                      'permanent'
                                                  ? 'Permanent'
                                                  : 'Contract',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            labelStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _openJobLink(
                                          job['redirect_url'] ?? ''),
                                      icon: const Icon(Icons.open_in_new,
                                          size: 16),
                                      label: const Text('View Job'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSalary(dynamic min, dynamic max) {
    if (min == null && max == null) return 'Salary not specified';

    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    if (min != null && max != null) {
      // If min and max are different, show range
      if (min != max) {
        return '${formatter.format(min)} - ${formatter.format(max)} per year';
      } else {
        // If min and max are the same, show single value
        return '${formatter.format(min)} per year';
      }
    } else if (min != null) {
      return 'From ${formatter.format(min)} per year';
    } else {
      return 'Up to ${formatter.format(max)} per year';
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
