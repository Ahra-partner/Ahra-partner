import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const AhraApp());
}

class AhraApp extends StatelessWidget {
  const AhraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ahra',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            // 🌿 HERO SECTION
            Container(
              width: double.infinity,
              height: 500,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1500937386664-56d1dfef3854",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        founderCard("assets/prashanth.jpg","Prashanth V","Founder"),
                        const SizedBox(height: 20),
                        founderCard("assets/srinivas.jpg","Chundi Srinivasula Reddy","Co-Founder"),
                      ],
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/logo.png", height: 140),
                        const SizedBox(height: 20),
                        const Text(
                          "Digital Marketplace for Agriculture",
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                        const SizedBox(height: 25),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            launchURL("https://play.google.com/store/apps/details?id=com.brightcode.ahra");
                          },
                          child: const Text("Download Ahra App"),
                        ),

                        const SizedBox(height: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          onPressed: () {
                            launchURL("https://play.google.com/store/apps/details?id=your.partner.app");
                          },
                          child: const Text("Become Partner", style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 🌿 BACKGROUND
            Container(
              width: double.infinity,
              color: Colors.green.shade200,
              child: Column(
                children: [

                  // ABOUT
                  sectionTitle("ABOUT AHRA"),
                  paragraphText(
                    "Ahra is a next-generation B2B agri marketplace designed to simplify and strengthen agricultural trade in India. "
                    "In today’s agriculture ecosystem, farmers often struggle to get fair prices due to multiple intermediaries, while buyers face challenges in sourcing quality produce consistently. "
                    "Ahra solves this problem by directly connecting farmers, retailers, wholesalers, and exporters on a single digital platform — enabling transparent, efficient, and fair transactions.\n\n"
                    "Who can use Ahra:\n"
                    "• Farmers looking for better market access\n"
                    "• Retailers & wholesalers seeking reliable sourcing\n"
                    "• Exporters looking for quality produce\n"
                    "• Agri partners building strong networks\n\n"
                    "With Ahra, users can discover better opportunities, build long-term relationships, and grow together in a trusted agri ecosystem."
                  ),

                  // FEATURES
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        featureCard("🌾", "Direct Farmer Connection"),
                        featureCard("💰", "Fair Pricing"),
                        featureCard("🤝", "Trusted Network"),
                        featureCard("📦", "Quality Sourcing"),
                      ],
                    ),
                  ),

                  // VISION
                  sectionTitle("VISION"),
                  paragraphText(
                    "To become India’s most trusted and widely adopted digital platform for agricultural trade, transforming the way farmers and buyers connect, trade, and grow. "
                    "Our vision is to create an inclusive ecosystem where every farmer has equal access to markets, fair pricing, and growth opportunities. "
                    "We aim to empower buyers with reliable sourcing while bridging rural and urban markets through technology."
                    "By leveraging technology, trust, and strong networks, Ahra aspires to redefine agricultural commerce in India and drive sustainable growth for the entire agri ecosystem."
                  ),

                  // MISSION
                  sectionTitle("MISSION"),
                  paragraphText(
              "Our mission is to transform the agricultural supply chain by eliminating inefficiencies and reducing dependency on unnecessary intermediaries, ensuring that farmers receive fair and transparent pricing for their produce."
              "We are committed to empowering farmers with better market access, enabling them to connect directly with buyers and unlock improved income opportunities."
              "At the same time, we aim to support retailers, wholesalers, and exporters by providing a reliable, scalable, and quality-driven sourcing network."
              "Through Ahra, we strive to build a strong and connected ecosystem that bridges rural producers with urban markets, fostering long-term business relationships and trust."
              "By leveraging technology, we are digitizing agricultural trade to make it simple, fast, transparent, and accessible for every stakeholder in the ecosystem."
                  ),

                  // FOUNDERS ✅ FIXED
                  sectionTitle("FOUNDERS"),
                  paragraphText(
                    "Prashanth V & Chundi Srinivasula Reddy are the founders of Ahra. "
"Driven by a deep passion to transform the agricultural ecosystem, the founders of Ahra are committed to building a direct, transparent bridge between farmers and buyers across India." "With strong ground-level understanding of real-world agricultural challenges, they identified the critical gaps in pricing, market access, and supply chain inefficiencies faced by farmers and traders." "Through Ahra, they aim to eliminate unnecessary intermediaries, empower farmers with better price realization, and enable buyers with reliable, quality sourcing." "Their vision is to leverage technology to create a scalable, trusted, and sustainable agri-business network that connects rural and urban markets seamlessly." "By focusing on transparency, accessibility, and long-term value creation, they are working towards building a platform that drives growth for every stakeholder in the agricultural ecosystem."
                  ),

                  // APP
                //  Container(
                //    width: double.infinity,
                //    color: Colors.green.withOpacity(0.1),
                //    padding: const EdgeInsets.all(40),
                //    child: Column(
                //      children: [
                //        const Text(
                //          "Download Our Apps",
                //          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                //        ),
                //        const SizedBox(height: 20),

                 //       ElevatedButton(
                //          onPressed: () {
                //            launchURL("https://play.google.com/store/apps/details?id=your.ahra.app");
                //          },
                //          child: const Text("Ahra App - Play Store"),
                //        ),

                //        const SizedBox(height: 10),

                //        ElevatedButton(
                //          onPressed: () {
                //            launchURL("https://play.google.com/store/apps/details?id=your.partner.app");
                //          },
                //          child: const Text("Ahra Partner App - Play Store"),
                //        ),
                //      ],
                //    ),
                //  ),

                  // CONTACT
                  sectionTitle("CONTACT US"),
                  const SizedBox(height: 10),
                  const Text("Email: ahrapartner2026@gmail.com"),
                  const SizedBox(height: 5),
                  const Text("Phone: +91 63623 84841"),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget paragraphText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 16,
          height: 1.8,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget featureCard(String icon, String text) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget founderCard(String image, String name, String role) {
    return Column(
      children: [
        CircleAvatar(radius: 50, backgroundImage: AssetImage(image)),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(role, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}