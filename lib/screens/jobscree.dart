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
  final ScrollController _scrollController = ScrollController();
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

  // Colors
  final Color _primaryColor = Colors.indigo;
  final Color _accentColor = Colors.indigoAccent;

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
        _showSnackBar('Removed from saved jobs: $jobTitle');
      } else {
        _savedJobs.add(jobId);
        _showSnackBar('Saved job: $jobTitle');
      }
    });

    await prefs.setStringList('savedJobs', _savedJobs);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        backgroundColor: _primaryColor,
      ),
    );
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

        // Scroll to results section if there are jobs found
        if (_jobs.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 300));
          _scrollToResults();
        }
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

  void _scrollToResults() {
    if (_scrollController.hasClients) {
      // Calculate a position that's approximately after the search section
      final scrollPosition = MediaQuery.of(context).size.height * 0.3;
      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _openJobLink(String url) async {
    try {
      // Ensure the URL is properly formatted
      final Uri uri = Uri.parse(url.trim());

      // Check if the URL can be launched before attempting
      if (await canLaunchUrl(uri)) {
        final bool launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          _showSnackBar('Could not open job listing: Launch failed');
        }
      } else {
        _showSnackBar('Could not open job listing: URL cannot be launched');
      }
    } catch (e) {
      _showSnackBar('Error opening job link: ${e.toString()}');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        title: const Text(
          'Job Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              _showSnackBar('Saved Jobs feature coming soon');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [_primaryColor.withOpacity(0.05), Colors.white],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            if (_keywordController.text.isNotEmpty) {
              await _fetchJobs();
            }
          },
          color: _primaryColor,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search form - enclosed in a Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Job Title field
                        TextField(
                          controller: _keywordController,
                          decoration: InputDecoration(
                            labelText: 'Job Title or Keywords',
                            labelStyle: TextStyle(color: _primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: _primaryColor, width: 2),
                            ),
                            hintText: 'e.g. Software Developer, Marketing',
                            prefixIcon: Icon(Icons.work, color: _primaryColor),
                            suffixIcon: _keywordController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _keywordController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onChanged: (_) => setState(() => _error = ''),
                        ),
                        const SizedBox(height: 12),
                        // Location field
                        TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location (Optional)',
                            labelStyle: TextStyle(color: _primaryColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: _primaryColor, width: 2),
                            ),
                            hintText: 'e.g. London, Manchester',
                            prefixIcon:
                                Icon(Icons.location_on, color: _primaryColor),
                            suffixIcon: _locationController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _locationController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Search button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _fetchJobs,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.search),
                            label: Text(
                              _isLoading ? 'Searching...' : 'Find Jobs',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent searches
                if (_recentSearches.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Searches',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _recentSearches.map((search) {
                            return GestureDetector(
                              onTap: () {
                                final parts = search.split(' in ');
                                _keywordController.text = parts[0];
                                if (parts.length > 1) {
                                  _locationController.text = parts[1];
                                } else {
                                  _locationController.clear();
                                }
                                _fetchJobs();
                              },
                              child: Chip(
                                label: Text(search),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () async {
                                  setState(() {
                                    _recentSearches.remove(search);
                                  });
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setStringList(
                                      'recentSearches', _recentSearches);
                                },
                                backgroundColor: Colors.grey.shade100,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                labelStyle: TextStyle(
                                  color: _primaryColor,
                                  fontSize: 12,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                // Filter options
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextButton.icon(
                    icon: Icon(
                      _showFilters ? Icons.expand_less : Icons.expand_more,
                      color: _primaryColor,
                    ),
                    label: Text(
                      _showFilters ? 'Hide Filters' : 'Show Filters',
                      style: TextStyle(color: _primaryColor),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                ),

                // Expandable filters section
                if (_showFilters)
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          const SizedBox(height: 16),
                          // Sort by dropdown
                          Row(
                            children: [
                              const Text('Sort by:'),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _sortBy,
                                    isExpanded: true,
                                    underline: Container(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'relevance',
                                        child: Text('Relevance'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'date',
                                        child: Text('Date'),
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Results per page
                          Row(
                            children: [
                              const Text('Results:'),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButton<int>(
                                    value: _resultsPerPage,
                                    isExpanded: true,
                                    underline: Container(),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 10,
                                        child: Text('10 per page'),
                                      ),
                                      DropdownMenuItem(
                                        value: 20,
                                        child: Text('20 per page'),
                                      ),
                                      DropdownMenuItem(
                                        value: 50,
                                        child: Text('50 per page'),
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
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Distance slider
                          Row(
                            children: [
                              const Text('Distance:'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Slider(
                                  value: double.parse(_distanceKm),
                                  min: 5,
                                  max: 100,
                                  divisions: 19,
                                  label: '$_distanceKm km',
                                  activeColor: _primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _distanceKm = value.round().toString();
                                    });
                                  },
                                ),
                              ),
                              Text('$_distanceKm km'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Apply filters button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _keywordController.text.isNotEmpty
                                  ? _fetchJobs
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Error message
                if (_error.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _error.replaceAll('Exception: ', ''),
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Results count
                if (_jobs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(
                      'Found ${_jobs.length} jobs',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                // Jobs list
                ..._jobs.map((job) => _buildJobCard(job)).toList(),

                // No results message
                if (_jobs.isEmpty &&
                    _isLoading == false &&
                    _error.isEmpty &&
                    _keywordController.text.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No jobs found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search criteria',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Search prompt when no search has been performed
                if (_jobs.isEmpty &&
                    _error.isEmpty &&
                    _keywordController.text.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter a job title to start searching',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Loading indicator
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(dynamic job) {
    final title = job['title'] ?? 'Untitled Job';
    final company = job['company']?['display_name'] ?? 'Unknown Company';
    final location = job['location']?['display_name'] ?? 'Remote/Unspecified';
    final salary = job['salary_min'] != null && job['salary_max'] != null
        ? '${NumberFormat.currency(symbol: '₹').format(job['salary_min'])} - '
            '${NumberFormat.currency(symbol: '₹').format(job['salary_max'])}'
        : 'Salary not specified';
    final date = _formatDate(job['created']);
    final description = job['description'] ?? 'No description available';
    final jobId = job['id']?.toString() ?? '';
    final isSaved = _savedJobs.contains(jobId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job header with title and save button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? _accentColor : Colors.grey,
                  ),
                  onPressed: () => _toggleSaveJob(jobId, title),
                  tooltip: isSaved ? 'Remove from saved jobs' : 'Save job',
                ),
              ],
            ),
          ),

          // Job details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company and location info
                Row(
                  children: [
                    Icon(Icons.business, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        company,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.attach_money,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        salary,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Job description
                Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                // View job button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final redirectUrl = job['redirect_url'];
                      if (redirectUrl != null &&
                          redirectUrl.toString().isNotEmpty) {
                        _openJobLink(redirectUrl.toString());
                      } else {
                        // Try alternative URL fields that Adzuna might provide
                        final alternativeUrl =
                            job['apply_url'] ?? job['url'] ?? job['adref'];
                        if (alternativeUrl != null &&
                            alternativeUrl.toString().isNotEmpty) {
                          _openJobLink(alternativeUrl.toString());
                        } else {
                          _showSnackBar('Job listing URL not available');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Job'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _locationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
