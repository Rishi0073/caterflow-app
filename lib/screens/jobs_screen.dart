import 'package:flutter/material.dart';
import '../models/job.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  final Set<String> appliedJobIds;
  final Set<String> appliedDates;
  final Function(Job) onApply;

  const JobsScreen({
    super.key,
    required this.appliedJobIds,
    required this.appliedDates,
    required this.onApply,
  });

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String selectedFilter = 'nearby';
  String selectedDate = '2026-04-11';

  @override
  Widget build(BuildContext context) {
    List<Job> filteredJobs = dummyJobs
        .where((j) => j.date == selectedDate)
        .toList();
    filteredJobs.sort(
      (a, b) => selectedFilter == 'money'
          ? b.priceValue.compareTo(a.priceValue)
          : a.distanceValue.compareTo(b.distanceValue),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF800020),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'CATERFLOW ELITE',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        letterSpacing: 3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Catering Jobs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: _buildFilterBtn('Nearby', 'nearby')),
                        const SizedBox(width: 15),
                        Expanded(child: _buildFilterBtn('Most Money', 'money')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 120,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final job = filteredJobs[index];
              final isApplied = widget.appliedJobIds.contains(job.id);
              final isDateBooked =
                  widget.appliedDates.contains(job.date) && !isApplied;

              return _buildJobCard(context, job, isApplied, isDateBooked);
            }, childCount: filteredJobs.length),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBtn(String label, String value) {
    bool isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF800020) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    Job job,
    bool isApplied,
    bool isDateBooked,
  ) {
    bool isDisabled = isApplied || isDateBooked;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JobDetailsScreen(
            job: job,
            isApplied: isApplied,
            isDateBooked: isDateBooked,
            onApply: () => widget.onApply(job),
          ),
        ),
      ),
      child: Container(
        height: 240,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: NetworkImage(job.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.9), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${job.location} • ${job.distance} | ${job.time}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    job.price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isDisabled ? null : () => widget.onApply(job),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDisabled
                          ? Colors.grey[800]
                          : const Color(0xFF800020),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      isApplied
                          ? 'Applied'
                          : isDateBooked
                          ? 'Date Booked'
                          : 'Apply Now',
                      style: TextStyle(
                        color: isDisabled ? Colors.grey[400] : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
