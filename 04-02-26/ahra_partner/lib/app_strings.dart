class AppStrings {
  final String lang;

  AppStrings(this.lang);

  static const Map<String, Map<String, String>> _data = {
    // ================= ENGLISH =================
    'en': {
      'select_language': 'Select Language',

      // Dashboard
      'dashboard': 'Partner Dashboard',
      'welcome': 'Welcome',
      'today_earnings': 'Today Earnings',
      'jobs_assigned': 'Jobs Assigned',
      'change_language': 'Change Language', // ✅ ADDED
      'logout': 'Logout',
      'logout_later': 'Logout will be added later',

      // KYC
      'kyc_pending': 'KYC is under review',
      'kyc_pending_desc':
          'Our team is verifying your documents. Please wait.',
      'kyc_approved': 'KYC Approved',
      'kyc_rejected': 'KYC Rejected',
      'kyc_rejected_desc':
          'Your KYC was rejected. Please update your details.',
      'update_kyc': 'Update KYC',
    },

    // ================= TELUGU =================
    'te': {
      'select_language': 'భాషను ఎంచుకోండి',

      // Dashboard
      'dashboard': 'భాగస్వామి డ్యాష్‌బోర్డ్',
      'welcome': 'స్వాగతం',
      'today_earnings': 'ఈ రోజు ఆదాయం',
      'jobs_assigned': 'కేటాయించిన పనులు',
      'change_language': 'భాష మార్చండి', // ✅ ADDED
      'logout': 'లాగ్ అవుట్',
      'logout_later': 'లాగ్ అవుట్ తరువాత చేర్చబడుతుంది',

      // KYC
      'kyc_pending': 'KYC పరిశీలనలో ఉంది',
      'kyc_pending_desc':
          'మీ డాక్యుమెంట్లు పరిశీలిస్తున్నాము. దయచేసి వేచిచూడండి.',
      'kyc_approved': 'KYC ఆమోదించబడింది',
      'kyc_rejected': 'KYC తిరస్కరించబడింది',
      'kyc_rejected_desc':
          'మీ KYC తిరస్కరించబడింది. దయచేసి వివరాలు నవీకరించండి.',
      'update_kyc': 'KYC నవీకరించండి',
    },

    // ================= HINDI =================
    'hi': {
      'select_language': 'भाषा चुनें',

      // Dashboard
      'dashboard': 'पार्टनर डैशबोर्ड',
      'welcome': 'स्वागत है',
      'today_earnings': 'आज की कमाई',
      'jobs_assigned': 'सौंपे गए कार्य',
      'change_language': 'भाषा बदलें', // ✅ ADDED
      'logout': 'लॉगआउट',
      'logout_later': 'लॉगआउट बाद में जोड़ा जाएगा',

      // KYC
      'kyc_pending': 'KYC की समीक्षा चल रही है',
      'kyc_pending_desc':
          'हम आपके दस्तावेज़ों की जांच कर रहे हैं। कृपया प्रतीक्षा करें।',
      'kyc_approved': 'KYC स्वीकृत',
      'kyc_rejected': 'KYC अस्वीकृत',
      'kyc_rejected_desc':
          'आपका KYC अस्वीकृत हो गया है। कृपया विवरण अपडेट करें।',
      'update_kyc': 'KYC अपडेट करें',
    },
  };

  // 🔑 Safe getter with English fallback
  String get(String key) {
    return _data[lang]?[key] ??
        _data['en']![key] ??
        key;
  }
}
