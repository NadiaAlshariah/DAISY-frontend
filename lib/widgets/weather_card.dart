import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final iconUrl = weather['condition_icon'];
    final condition = weather['condition'] ?? 'Unavailable';
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconUrl != null)
                Image.network(iconUrl, width: 48, height: 48)
              else
                Icon(
                  Icons.cloud_outlined,
                  size: 48,
                  color: Colors.grey.shade700,
                ),
              const SizedBox(width: 12),
              Text(
                condition.toString().toUpperCase(),
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _weatherStat(
                context,
                'Temp',
                '${weather['temperature_c']}°C',
                Icons.thermostat,
              ),
              _weatherStat(
                context,
                'Humidity',
                '${weather['humidity']}%',
                Icons.water_drop,
              ),
              _weatherStat(
                context,
                'Wind',
                '${weather['wind_ms']} m/s',
                Icons.air,
              ),
              _weatherStat(
                context,
                'Precip',
                '${weather['precip_mm']} mm',
                Icons.grain,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weatherStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color.fromARGB(221, 255, 255, 255)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Color.fromARGB(255, 204, 215, 205),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
