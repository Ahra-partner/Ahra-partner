import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'partner_my_tickets_screen.dart';

class TicketSuccessScreen extends StatelessWidget {
  final String ticketId;

  const TicketSuccessScreen({
    super.key,
    required this.ticketId,
  });

  void _openWhatsApp() async {
    const number = "6362384841";
    final text =
        "Hi AHRA Support,\nMy Ticket ID: $ticketId\nPlease assist me.";

    final url =
        "https://wa.me/$number?text=${Uri.encodeComponent(text)}";

    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              const Icon(Icons.check_circle,
                  color: Colors.green,
                  size: 90),

              const SizedBox(height: 20),

              const Text(
                "Ticket Created Successfully!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Ticket ID: $ticketId",
                style: const TextStyle(
                    fontSize: 16),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PartnerMyTicketsScreen(),
                    ),
                  );
                },
                child:
                    const Text("View My Tickets"),
              ),

              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: _openWhatsApp,
                icon: const Icon(Icons.chat),
                label:
                    const Text("Chat on WhatsApp"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
