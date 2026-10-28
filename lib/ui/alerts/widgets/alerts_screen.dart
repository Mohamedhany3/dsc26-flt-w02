import 'package:flutter/material.dart';

import '../../../domain/models/stock_alert.dart';
import '../view_models/alerts_view_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.viewModel});

  final AlertsViewModel viewModel;

  Color severityColor(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return Colors.red;
      case Severity.high:
        return Colors.orange;
      case Severity.medium:
        return Colors.amber.shade700;
      case Severity.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final alerts = viewModel.visibleAlerts;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text(
              'Nour Shelf',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  key: const ValueKey('search-field'),
                  onChanged: viewModel.setQuery,
                  decoration: InputDecoration(
                    hintText: 'Search medicines',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Severity Filters
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: Severity.values.map((severity) {
                    final selected = viewModel.activeFilters.contains(severity);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: ValueKey('filter-${severity.name}'),
                        label: Text(severity.name.toUpperCase()),
                        selected: selected,
                        selectedColor: severityColor(severity).withOpacity(0.2),
                        backgroundColor: Colors.white,
                        checkmarkColor: severityColor(severity),
                        onSelected: (_) {
                          viewModel.toggleFilter(severity);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Alerts Count
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Stock Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${alerts.length} alerts',
                      key: const ValueKey('alerts-count'),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Alerts List
              Expanded(
                child: viewModel.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          key: ValueKey('alerts-loading'),
                        ),
                      )
                    : alerts.isEmpty
                    ? const Center(
                        child: Text(
                          'No alerts found',
                          key: ValueKey('alerts-empty'),
                        ),
                      )
                    : ListView.builder(
                        key: const ValueKey('alerts-list'),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          final color = severityColor(alert.severity);

                          return Card(
                            key: ValueKey('alert-${alert.id}'),
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Medicine Name
                                  Row(
                                    children: [
                                      Icon(Icons.medication, color: color),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          alert.medicineNameEn,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  Text(alert.medicineNameAr),

                                  const SizedBox(height: 8),

                                  // Severity
                                  Text(
                                    alert.severity.name.toUpperCase(),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // Days of Cover
                                  Text('Days of cover: ${alert.daysOfCover}'),

                                  // Branch Code
                                  Text('Branch: ${alert.branchCode}'),

                                  const SizedBox(height: 12),

                                  // Acknowledge Button / Check Mark
                                  if (alert.acknowledged)
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Acknowledged',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    ElevatedButton(
                                      key: ValueKey('ack-${alert.id}'),
                                      onPressed: () {
                                        viewModel.acknowledge(alert.id);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text('Acknowledge'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
