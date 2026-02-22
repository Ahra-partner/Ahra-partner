class AppStrings {
  final String lang;

  AppStrings(this.lang);

  static const Map<String, Map<String, String>> _data = {
    // ================= ENGLISH =================
    'en': {
      // 🔹 BASIC DETAILS
      'basic_details': 'Basic Details',
      'step_of': 'Step {current} of {total}',
      'full_name': 'Full Name',
      'mobile': 'Mobile Number',
      'email': 'Email ID',
      'country': 'Country',
      'state': 'State',
      'district': 'District',
      'mandal': 'Mandal / Block',
      'village': 'Village',
      'post_office': 'Post Office',
      'pincode': 'Pincode',
      'save_continue': 'Save & Continue',
      'required': 'Required field',

      // 🔹 EDUCATION
      'education_experience': 'Education & Experience',
      'highest_qualification': 'Highest Qualification',
      'agri_experience': 'Experience in Agriculture?',
      'experience_years': 'Years of Experience',
      'yes': 'Yes',
      'no': 'No',

      // 🔹 KYC
      'kyc_upload': 'KYC Upload',
      'aadhaar_front': 'Aadhaar Front',
      'aadhaar_back': 'Aadhaar Back',
      'pan_card': 'PAN Card',
      'passport_photo': 'Passport Size Photo',
      'upload_below_70kb': 'Upload image (≤ 70 KB)',
      'submit_kyc': 'Submit KYC',

      // 🔹 KYC STATUS
      'kyc_status': 'KYC Status',
      'kyc_under_review': 'Your KYC is under review',
      'kyc_wait_admin': 'Please wait for admin approval',
      'kyc_rejected': 'KYC Rejected',
      'reupload_kyc': 'Re-upload KYC',
      'reason': 'Reason',
      'invalid_status': 'Invalid KYC status',

      // 🔹 DASHBOARD
      'welcome': 'Welcome',
      'wallet_balance': 'Wallet Balance',
      'withdraw': 'Withdraw',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'today_earnings': "Today's Earnings",
      'week_earnings': "This Week's Earnings",
      'month_earnings': "This Month's Earnings",
      'no_transactions': 'No transactions yet',
      'farmers': 'Farmers',
      'retailers': 'Retailers',
      'wholesalers': 'Wholesalers',
      'exporters': 'Exporters',
      'food_processor': 'Food Processor',

      // 🔹 ADD FARMER
      'add_farmer': 'Add Farmer',
      'farmer_name': 'Farmer Name',
      'mobile_number': 'Mobile Number',
      'category': 'Category',
      'product': 'Product',
      'other': 'Other',
      'enter_product_name': 'Enter Product Name',
      'quantity': 'Quantity',
      'quantity_unit': 'Unit',
      'transaction_number': 'Transaction Number',
      'platform_amount': 'Subscription Amount',
      'select_category': 'Select category',
      'select_product': 'Select product',
      'submit': 'Submit',

      // 🔥 SUBSCRIPTION (NEW)
      'subscription_history': 'Subscription History',
      'no_subscriptions_yet': 'No subscriptions yet',
      'amount': 'Amount',
      'add_month': 'Add Month',
    },

    // ================= TELUGU =================
    'te': {
      'basic_details': 'ప్రాథమిక వివరాలు',
      'step_of': 'దశ {current} / {total}',
      'full_name': 'పూర్తి పేరు',
      'mobile': 'మొబైల్ నంబర్',
      'email': 'ఇమెయిల్ ఐడి',
      'country': 'దేశం',
      'state': 'రాష్ట్రం',
      'district': 'జిల్లా',
      'mandal': 'మండలం',
      'village': 'గ్రామం',
      'post_office': 'పోస్ట్ ఆఫీస్',
      'pincode': 'పిన్ కోడ్',
      'save_continue': 'సేవ్ చేసి కొనసాగించండి',
      'required': 'తప్పనిసరి',

      'education_experience': 'విద్య & అనుభవం',
      'highest_qualification': 'గరిష్ట విద్యార్హత',
      'agri_experience': 'వ్యవసాయ అనుభవం ఉందా?',
      'experience_years': 'అనుభవ సంవత్సరాలు',
      'yes': 'అవును',
      'no': 'కాదు',

      'kyc_upload': 'కేవైసీ అప్లోడ్',
      'aadhaar_front': 'ఆధార్ ముందుభాగం',
      'aadhaar_back': 'ఆధార్ వెనుకభాగం',
      'pan_card': 'పాన్ కార్డు',
      'passport_photo': 'పాస్‌పోర్ట్ సైజ్ ఫోటో',
      'upload_below_70kb': 'చిత్రం అప్లోడ్ చేయండి (≤ 70 KB)',
      'submit_kyc': 'కేవైసీ సమర్పించండి',

      'kyc_status': 'కేవైసీ స్థితి',
      'kyc_under_review': 'మీ కేవైసీ పరిశీలనలో ఉంది',
      'kyc_wait_admin': 'అడ్మిన్ ఆమోదం కోసం వేచి ఉండండి',
      'kyc_rejected': 'కేవైసీ తిరస్కరించబడింది',
      'reupload_kyc': 'మళ్లీ కేవైసీ అప్లోడ్ చేయండి',
      'reason': 'కారణం',
      'invalid_status': 'చెల్లని కేవైసీ స్థితి',

      'welcome': 'స్వాగతం',
      'wallet_balance': 'వాలెట్ బ్యాలెన్స్',
      'withdraw': 'డబ్బు తీసుకోండి',
      'daily': 'రోజువారీ',
      'weekly': 'వారపు',
      'monthly': 'నెలవారీ',
      'today_earnings': 'ఈ రోజు ఆదాయం',
      'week_earnings': 'ఈ వారం ఆదాయం',
      'month_earnings': 'ఈ నెల ఆదాయం',
      'no_transactions': 'ఇంకా లావాదేవీలు లేవు',
      'farmers': 'రైతులు',
      'retailers': 'చిల్లర వ్యాపారులు',
      'wholesalers': 'హోల్‌సేలర్లు',
      'exporters': 'ఎగుమతిదారులు',
      'food_processor': 'ఆహార ప్రాసెసర్',

      'add_farmer': 'రైతును జోడించండి',
      'farmer_name': 'రైతు పేరు',
      'mobile_number': 'మొబైల్ నంబర్',
      'category': 'వర్గం',
      'product': 'ఉత్పత్తి',
      'other': 'ఇతర',
      'enter_product_name': 'ఉత్పత్తి పేరు నమోదు చేయండి',
      'quantity': 'పరిమాణం',
      'quantity_unit': 'యూనిట్',
      'transaction_number': 'లావాదేవీ నంబర్',
      'platform_amount': 'సబ్‌స్క్రిప్షన్ మొత్తం',
      'select_category': 'వర్గాన్ని ఎంచుకోండి',
      'select_product': 'ఉత్పత్తిని ఎంచుకోండి',
      'submit': 'సమర్పించండి',

      // 🔥 SUBSCRIPTION (NEW)
      'subscription_history': 'సబ్‌స్క్రిప్షన్ చరిత్ర',
      'no_subscriptions_yet': 'ఇంకా సబ్‌స్క్రిప్షన్లు లేవు',
      'amount': 'మొత్తం',
      'add_month': 'కొత్త నెల జోడించండి',
    },

    // ================= HINDI =================
    'hi': {
      'basic_details': 'मूल विवरण',
      'step_of': 'चरण {current} / {total}',
      'full_name': 'पूरा नाम',
      'mobile': 'मोबाइल नंबर',
      'email': 'ईमेल आईडी',
      'country': 'देश',
      'state': 'राज्य',
      'district': 'जिला',
      'mandal': 'मंडल / ब्लॉक',
      'village': 'गाँव',
      'post_office': 'डाकघर',
      'pincode': 'पिन कोड',
      'save_continue': 'सहेजें और जारी रखें',
      'required': 'आवश्यक',

      'education_experience': 'शिक्षा और अनुभव',
      'highest_qualification': 'उच्चतम योग्यता',
      'agri_experience': 'क्या कृषि अनुभव है?',
      'experience_years': 'अनुभव के वर्ष',
      'yes': 'हाँ',
      'no': 'नहीं',

      'kyc_upload': 'केवाईसी अपलोड',
      'aadhaar_front': 'आधार फ्रंट',
      'aadhaar_back': 'आधार बैक',
      'pan_card': 'पैन कार्ड',
      'passport_photo': 'पासपोर्ट फोटो',
      'upload_below_70kb': 'छवि अपलोड करें (≤ 70 KB)',
      'submit_kyc': 'केवाईसी सबमिट करें',

      'kyc_status': 'केवाईसी स्थिति',
      'kyc_under_review': 'आपका केवाईसी समीक्षा में है',
      'kyc_wait_admin': 'कृपया एडमिन अनुमोदन की प्रतीक्षा करें',
      'kyc_rejected': 'केवाईसी अस्वीकृत',
      'reupload_kyc': 'केवाईसी फिर से अपलोड करें',
      'reason': 'कारण',
      'invalid_status': 'अमान्य केवाईसी स्थिति',

      'welcome': 'स्वागत है',
      'wallet_balance': 'वॉलेट बैलेंस',
      'withdraw': 'निकालें',
      'daily': 'दैनिक',
      'weekly': 'साप्ताहिक',
      'monthly': 'मासिक',
      'today_earnings': 'आज की कमाई',
      'week_earnings': 'इस सप्ताह की कमाई',
      'month_earnings': 'इस महीने की कमाई',
      'no_transactions': 'कोई लेन-देन नहीं',
      'farmers': 'किसान',
      'retailers': 'खुदरा विक्रेता',
      'wholesalers': 'थोक विक्रेता',
      'exporters': 'निर्यातक',
      'food_processor': 'खाद्य प्रसंस्करण',

      'add_farmer': 'किसान जोड़ें',
      'farmer_name': 'किसान का नाम',
      'mobile_number': 'मोबाइल नंबर',
      'category': 'श्रेणी',
      'product': 'उत्पाद',
      'other': 'अन्य',
      'enter_product_name': 'उत्पाद का नाम दर्ज करें',
      'quantity': 'मात्रा',
      'quantity_unit': 'इकाई',
      'transaction_number': 'लेनदेन संख्या',
      'platform_amount': 'सब्सक्रिप्शन राशि',
      'select_category': 'श्रेणी चुनें',
      'select_product': 'उत्पाद चुनें',
      'submit': 'सबमिट करें',
      // 🔥 SUBSCRIPTION (NEW)
      'subscription_history': 'सब्सक्रिप्शन इतिहास',
      'no_subscriptions_yet': 'अभी तक कोई सब्सक्रिप्शन नहीं',
      'amount': 'राशि',
      'add_month': 'नया महीना जोड़ें',
    },


    // ================= KANNADA =================
    'kn': {
      'basic_details': 'ಮೂಲ ವಿವರಗಳು',
      'step_of': 'ಹಂತ {current} / {total}',
      'full_name': 'ಪೂರ್ಣ ಹೆಸರು',
      'mobile': 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ',
      'email': 'ಇಮೇಲ್ ಐಡಿ',
      'country': 'ದೇಶ',
      'state': 'ರಾಜ್ಯ',
      'district': 'ಜಿಲ್ಲೆ',
      'mandal': 'ಮಂಡಲ / ಬ್ಲಾಕ್',
      'village': 'ಗ್ರಾಮ',
      'post_office': 'ಅಂಚೆ ಕಚೇರಿ',
      'pincode': 'ಪಿನ್ ಕೋಡ್',
      'save_continue': 'ಉಳಿಸಿ ಮುಂದುವರಿಸಿ',
      'required': 'ಅಗತ್ಯ',

      'education_experience': 'ಶಿಕ್ಷಣ ಮತ್ತು ಅನುಭವ',
      'highest_qualification': 'ಅತ್ಯುನ್ನತ ಅರ್ಹತೆ',
      'agri_experience': 'ಕೃಷಿ ಅನುಭವವಿದೆಯೇ?',
      'experience_years': 'ಅನುಭವದ ವರ್ಷಗಳು',
      'yes': 'ಹೌದು',
      'no': 'ಇಲ್ಲ',

      'kyc_upload': 'ಕೆವೈಸಿ ಅಪ್ಲೋಡ್',
      'aadhaar_front': 'ಆಧಾರ್ ಮುಂಭಾಗ',
      'aadhaar_back': 'ಆಧಾರ್ ಹಿಂಭಾಗ',
      'pan_card': 'ಪ್ಯಾನ್ ಕಾರ್ಡ್',
      'passport_photo': 'ಪಾಸ್ಪೋರ್ಟ್ ಫೋಟೋ',
      'upload_below_70kb': 'ಚಿತ್ರ ಅಪ್ಲೋಡ್ ಮಾಡಿ (≤ 70 KB)',
      'submit_kyc': 'ಕೆವೈಸಿ ಸಲ್ಲಿಸಿ',

      'kyc_status': 'ಕೆವೈಸಿ ಸ್ಥಿತಿ',
      'kyc_under_review': 'ನಿಮ್ಮ ಕೆವೈಸಿ ಪರಿಶೀಲನೆಯಲ್ಲಿ ಇದೆ',
      'kyc_wait_admin': 'ದಯವಿಟ್ಟು ಆಡ್ಮಿನ್ ಅನುಮೋದನೆಗಾಗಿ ಕಾಯಿರಿ',
      'kyc_rejected': 'ಕೆವೈಸಿ ನಿರಾಕರಿಸಲಾಗಿದೆ',
      'reupload_kyc': 'ಮತ್ತೆ ಕೆವೈಸಿ ಅಪ್ಲೋಡ್ ಮಾಡಿ',
      'reason': 'ಕಾರಣ',
      'invalid_status': 'ಅಮಾನ್ಯ ಕೆವೈಸಿ ಸ್ಥಿತಿ',

      'welcome': 'ಸ್ವಾಗತ',
      'wallet_balance': 'ವಾಲೆಟ್ ಬ್ಯಾಲೆನ್ಸ್',
      'withdraw': 'ಹಿಂಪಡೆ',
      'daily': 'ದೈನಂದಿನ',
      'weekly': 'ವಾರದ',
      'monthly': 'ಮಾಸಿಕ',
      'today_earnings': 'ಇಂದಿನ ಆದಾಯ',
      'week_earnings': 'ಈ ವಾರದ ಆದಾಯ',
      'month_earnings': 'ಈ ತಿಂಗಳ ಆದಾಯ',
      'no_transactions': 'ವಹಿವಾಟುಗಳಿಲ್ಲ',
      'farmers': 'ರೈತರು',
      'retailers': 'ಚಿಲ್ಲರೆ ವ್ಯಾಪಾರಿಗಳು',
      'wholesalers': 'ಸಗಟು ವ್ಯಾಪಾರಿಗಳು',
      'exporters': 'ರಫ್ತುದಾರರು',
      'food_processor': 'ಆಹಾರ ಸಂಸ್ಕಾರಕ',

      'add_farmer': 'ರೈತನ್ನು ಸೇರಿಸಿ',
      'farmer_name': 'ರೈತನ ಹೆಸರು',
      'mobile_number': 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ',
      'category': 'ವರ್ಗ',
      'product': 'ಉತ್ಪನ್ನ',
      'other': 'ಇತರೆ',
      'enter_product_name': 'ಉತ್ಪನ್ನದ ಹೆಸರು ನಮೂದಿಸಿ',
      'quantity': 'ಪ್ರಮಾಣ',
      'quantity_unit': 'ಘಟಕ',
      'transaction_number': 'ವಹಿವಾಟು ಸಂಖ್ಯೆ',
      'platform_amount': 'ಚಂದಾದಾರಿಕೆ ಮೊತ್ತ',
      'select_category': 'ವರ್ಗ ಆಯ್ಕೆಮಾಡಿ',
      'select_product': 'ಉತ್ಪನ್ನ ಆಯ್ಕೆಮಾಡಿ',
      'submit': 'ಸಲ್ಲಿಸಿ',
      // 🔥 SUBSCRIPTION (NEW)
      'subscription_history': 'ಚಂದಾದಾರಿಕೆ ಇತಿಹಾಸ',
      'no_subscriptions_yet': 'ಇನ್ನೂ ಚಂದಾದಾರಿಕೆಗಳಿಲ್ಲ',
      'amount': 'ಮೊತ್ತ',
      'add_month': 'ಹೊಸ ತಿಂಗಳು ಸೇರಿಸಿ',
    },
    // ================= TAMIL =================
    'ta': {
      'basic_details': 'அடிப்படை விவரங்கள்',
      'step_of': 'படி {current} / {total}',
      'full_name': 'முழு பெயர்',
      'mobile': 'மொபைல் எண்',
      'email': 'மின்னஞ்சல் ஐடி',
      'country': 'நாடு',
      'state': 'மாநிலம்',
      'district': 'மாவட்டம்',
      'mandal': 'மண்டலம் / தொகுதி',
      'village': 'கிராமம்',
      'post_office': 'தபால் நிலையம்',
      'pincode': 'அஞ்சல் குறியீடு',
      'save_continue': 'சேமித்து தொடரவும்',
      'required': 'அவசியம்',

      'education_experience': 'கல்வி மற்றும் அனுபவம்',
      'highest_qualification': 'உயர் தகுதி',
      'agri_experience': 'விவசாய அனுபவம் உள்ளதா?',
      'experience_years': 'அனுபவ ஆண்டுகள்',
      'yes': 'ஆம்',
      'no': 'இல்லை',

      'kyc_upload': 'கேவைசி பதிவேற்றம்',
      'aadhaar_front': 'ஆதார் முன்பக்கம்',
      'aadhaar_back': 'ஆதார் பின்பக்கம்',
      'pan_card': 'பான் கார்டு',
      'passport_photo': 'பாஸ்போர்ட் புகைப்படம்',
      'upload_below_70kb': 'படத்தை பதிவேற்றவும் (≤ 70 KB)',
      'submit_kyc': 'கேவைசி சமர்ப்பிக்கவும்',

      'kyc_status': 'கேவைசி நிலை',
      'kyc_under_review': 'உங்கள் கேவைசி பரிசீலனையில் உள்ளது',
      'kyc_wait_admin': 'நிர்வாகி அனுமதிக்காக காத்திருக்கவும்',
      'kyc_rejected': 'கேவைசி நிராகரிக்கப்பட்டது',
      'reupload_kyc': 'மீண்டும் கேவைசி பதிவேற்றவும்',
      'reason': 'காரணம்',
      'invalid_status': 'செல்லாத கேவைசி நிலை',

      'welcome': 'வரவேற்பு',
      'wallet_balance': 'வாலெட் இருப்பு',
      'withdraw': 'பெறுக',
      'daily': 'தினசரி',
      'weekly': 'வாராந்திர',
      'monthly': 'மாதாந்திர',
      'today_earnings': 'இன்றைய வருமானம்',
      'week_earnings': 'இந்த வார வருமானம்',
      'month_earnings': 'இந்த மாத வருமானம்',
      'no_transactions': 'பரிவர்த்தனைகள் இல்லை',
      'farmers': 'விவசாயிகள்',
      'retailers': 'சில்லறை வியாபாரிகள்',
      'wholesalers': 'மொத்த வியாபாரிகள்',
      'exporters': 'ஏற்றுமதியாளர்கள்',
      'food_processor': 'உணவு செயலாக்கம்',

      'add_farmer': 'விவசாயியை சேர்க்கவும்',
      'farmer_name': 'விவசாயி பெயர்',
      'mobile_number': 'மொபைல் எண்',
      'category': 'வகை',
      'product': 'பொருள்',
      'other': 'மற்றவை',
      'enter_product_name': 'பொருளின் பெயரை உள்ளிடவும்',
      'quantity': 'அளவு',
      'quantity_unit': 'அலகு',
      'transaction_number': 'பரிவர்த்தனை எண்',
      'platform_amount': 'சந்தா தொகை',
      'select_category': 'வகையை தேர்ந்தெடுக்கவும்',
      'select_product': 'பொருளை தேர்ந்தெடுக்கவும்',
      'submit': 'சமர்ப்பிக்கவும்',
      // 🔥 SUBSCRIPTION (NEW)
      'subscription_history': 'சந்தா வரலாறு',
      'no_subscriptions_yet': 'இதுவரை சந்தாக்கள் இல்லை',
      'amount': 'தொகை',
      'add_month': 'புதிய மாதம் சேர்க்கவும்',
    },
// ================= ODIA =================
'or': {
  'basic_details': 'ମୂଳ ତଥ୍ୟ',
  'step_of': 'ପଦକ୍ରମ {current} / {total}',
  'full_name': 'ପୁରା ନାମ',
  'mobile': 'ମୋବାଇଲ୍ ନମ୍ବର',
  'email': 'ଇମେଲ୍ ଆଇଡି',
  'country': 'ଦେଶ',
  'state': 'ରାଜ୍ୟ',
  'district': 'ଜିଲ୍ଲା',
  'mandal': 'ମଣ୍ଡଳ / ବ୍ଲକ୍',
  'village': 'ଗାଁ',
  'post_office': 'ଡାକଘର',
  'pincode': 'ପିନ୍ କୋଡ୍',
  'save_continue': 'ସେଭ୍ କରି ଆଗକୁ ବଢନ୍ତୁ',
  'required': 'ଆବଶ୍ୟକ',

  'education_experience': 'ଶିକ୍ଷା ଓ ଅନୁଭବ',
  'highest_qualification': 'ଉଚ୍ଚତମ ଯୋଗ୍ୟତା',
  'agri_experience': 'କୃଷି ଅନୁଭବ ଅଛି କି?',
  'experience_years': 'ଅନୁଭବ ବର୍ଷ',
  'yes': 'ହଁ',
  'no': 'ନା',

  'kyc_upload': 'KYC ଅପଲୋଡ୍',
  'aadhaar_front': 'ଆଧାର ଆଗ ପଟ',
  'aadhaar_back': 'ଆଧାର ପଛ ପଟ',
  'pan_card': 'ପ୍ୟାନ୍ କାର୍ଡ',
  'passport_photo': 'ପାସପୋର୍ଟ ଫଟୋ',
  'upload_below_70kb': '70 KB ରୁ କମ୍ ଫଟୋ ଅପଲୋଡ୍ କରନ୍ତୁ',
  'submit_kyc': 'KYC ସମର୍ପଣ',

  'kyc_status': 'KYC ସ୍ଥିତି',
  'kyc_under_review': 'ଆପଣଙ୍କ KYC ପରୀକ୍ଷାଧୀନ ଅଛି',
  'kyc_wait_admin': 'ଅଡମିନ୍ ଅନୁମୋଦନ ପାଇଁ ଅପେକ୍ଷା କରନ୍ତୁ',
  'kyc_rejected': 'KYC ବାତିଲ୍ ହୋଇଛି',
  'reupload_kyc': 'ପୁନର୍ବାର KYC ଅପଲୋଡ୍ କରନ୍ତୁ',
  'reason': 'କାରଣ',
  'invalid_status': 'ଅବୈଧ KYC ସ୍ଥିତି',

  'welcome': 'ସ୍ୱାଗତ',
  'wallet_balance': 'ୱାଲେଟ୍ ବ୍ୟାଲାନ୍ସ',
  'withdraw': 'ଉତ୍ତୋଳନ',
  'daily': 'ଦୈନିକ',
  'weekly': 'ସାପ୍ତାହିକ',
  'monthly': 'ମାସିକ',
  'today_earnings': 'ଆଜିର ଆୟ',
  'week_earnings': 'ଏହି ସପ୍ତାହର ଆୟ',
  'month_earnings': 'ଏହି ମାସର ଆୟ',
  'no_transactions': 'କୌଣସି ଲେନଦେନ ନାହିଁ',

  'subscription_history': 'ସଦସ୍ୟତା ଇତିହାସ',
  'no_subscriptions_yet': 'ଏପର୍ଯ୍ୟନ୍ତ ସଦସ୍ୟତା ନାହିଁ',
  'amount': 'ରାଶି',
  'add_month': 'ନୂତନ ମାସ ଯୋଗ କରନ୍ତୁ',
},
// ================= MARATHI =================
'mr': {
  'basic_details': 'मूलभूत माहिती',
  'step_of': 'स्टेप {current} / {total}',
  'full_name': 'पूर्ण नाव',
  'mobile': 'मोबाईल नंबर',
  'email': 'ईमेल आयडी',
  'country': 'देश',
  'state': 'राज्य',
  'district': 'जिल्हा',
  'mandal': 'तालुका / विभाग',
  'village': 'गाव',
  'post_office': 'पोस्ट ऑफिस',
  'pincode': 'पिनकोड',
  'save_continue': 'सेव्ह करून पुढे जा',
  'required': 'आवश्यक',

  'education_experience': 'शिक्षण आणि अनुभव',
  'highest_qualification': 'उच्च शिक्षण',
  'agri_experience': 'शेतीचा अनुभव आहे का?',
  'experience_years': 'अनुभव वर्षे',
  'yes': 'होय',
  'no': 'नाही',

  'kyc_upload': 'KYC अपलोड',
  'aadhaar_front': 'आधार पुढील बाजू',
  'aadhaar_back': 'आधार मागील बाजू',
  'pan_card': 'पॅन कार्ड',
  'passport_photo': 'पासपोर्ट फोटो',
  'upload_below_70kb': '70 KB पेक्षा कमी फोटो अपलोड करा',
  'submit_kyc': 'KYC सबमिट करा',

  'kyc_status': 'KYC स्थिती',
  'kyc_under_review': 'आपले KYC पुनरावलोकनात आहे',
  'kyc_wait_admin': 'प्रशासक मंजुरीची प्रतीक्षा करा',
  'kyc_rejected': 'KYC नाकारले गेले आहे',
  'reupload_kyc': 'पुन्हा KYC अपलोड करा',
  'reason': 'कारण',
  'invalid_status': 'अवैध KYC स्थिती',

  'welcome': 'स्वागत आहे',
  'wallet_balance': 'वॉलेट शिल्लक',
  'withdraw': 'काढा',
  'daily': 'दैनिक',
  'weekly': 'साप्ताहिक',
  'monthly': 'मासिक',
  'today_earnings': 'आजची कमाई',
  'week_earnings': 'या आठवड्याची कमाई',
  'month_earnings': 'या महिन्याची कमाई',
  'no_transactions': 'कोणतेही व्यवहार नाहीत',

  'subscription_history': 'सदस्यता इतिहास',
  'no_subscriptions_yet': 'अद्याप सदस्यता नाही',
  'amount': 'रक्कम',
  'add_month': 'नवीन महिना जोडा',
},
// ================= MALAYALAM =================
'ml': {
  'basic_details': 'അടിസ്ഥാന വിവരങ്ങൾ',
  'step_of': 'ഘട്ടം {current} / {total}',
  'full_name': 'പൂർണ്ണ പേര്',
  'mobile': 'മൊബൈൽ നമ്പർ',
  'email': 'ഇമെയിൽ ഐഡി',
  'country': 'രാജ്യം',
  'state': 'സംസ്ഥാനം',
  'district': 'ജില്ല',
  'mandal': 'മണ്ഡലം / ബ്ലോക്ക്',
  'village': 'ഗ്രാമം',
  'post_office': 'പോസ്റ്റ് ഓഫീസ്',
  'pincode': 'പിൻകോഡ്',
  'save_continue': 'സേവ് ചെയ്ത് തുടരുക',
  'required': 'അവശ്യമാണ്',

  'education_experience': 'വിദ്യാഭ്യാസവും അനുഭവവും',
  'highest_qualification': 'ഉയർന്ന യോഗ്യത',
  'agri_experience': 'കൃഷി പരിചയം ഉണ്ടോ?',
  'experience_years': 'അനുഭവ വർഷങ്ങൾ',
  'yes': 'ഉണ്ട്',
  'no': 'ഇല്ല',

  'kyc_upload': 'KYC അപ്‌ലോഡ്',
  'aadhaar_front': 'ആധാർ മുന്ന് ഭാഗം',
  'aadhaar_back': 'ആധാർ പിൻ ഭാഗം',
  'pan_card': 'പാൻ കാർഡ്',
  'passport_photo': 'പാസ്‌പോർട്ട് ഫോട്ടോ',
  'upload_below_70kb': '70 KBൽ താഴെ ഫോട്ടോ അപ്‌ലോഡ് ചെയ്യുക',
  'submit_kyc': 'KYC സമർപ്പിക്കുക',

  'kyc_status': 'KYC നില',
  'kyc_under_review': 'നിങ്ങളുടെ KYC പരിശോധനയിലാണ്',
  'kyc_wait_admin': 'അഡ്മിൻ അംഗീകാരം കാത്തിരിക്കുക',
  'kyc_rejected': 'KYC നിരസിച്ചു',
  'reupload_kyc': 'വീണ്ടും KYC അപ്‌ലോഡ് ചെയ്യുക',
  'reason': 'കാരണം',
  'invalid_status': 'അസാധുവായ KYC നില',

  'welcome': 'സ്വാഗതം',
  'wallet_balance': 'വാലറ്റ് ബാലൻസ്',
  'withdraw': 'പിൻവലിക്കുക',
  'daily': 'ദൈനംദിനം',
  'weekly': 'ആഴ്ചതോറും',
  'monthly': 'മാസത്തിൽ',
  'today_earnings': 'ഇന്നത്തെ വരുമാനം',
  'week_earnings': 'ഈ ആഴ്ചയിലെ വരുമാനം',
  'month_earnings': 'ഈ മാസത്തിലെ വരുമാനം',
  'no_transactions': 'ഇടപാടുകൾ ഇല്ല',

  'subscription_history': 'സബ്സ്ക്രിപ്ഷൻ ചരിത്രം',
  'no_subscriptions_yet': 'ഇനിയും സബ്സ്ക്രിപ്ഷനുകൾ ഇല്ല',
  'amount': 'തുക',
  'add_month': 'പുതിയ മാസം ചേർക്കുക',
},    
  };

  String get(String key) =>
      _data[lang]?[key] ?? _data['en']![key] ?? key;

  // 🔹 BASIC
  String get basicDetails => get('basic_details');
  String get fullName => get('full_name');
  String get mobile => get('mobile');
  String get email => get('email');
  String get country => get('country');
  String get state => get('state');
  String get district => get('district');
  String get mandal => get('mandal');
  String get village => get('village');
  String get postOffice => get('post_office');
  String get pincode => get('pincode');
  String get saveAndContinue => get('save_continue');

  // 🔹 EDUCATION
  String get educationExperience => get('education_experience');
  String get highestQualification => get('highest_qualification');
  String get agriExperience => get('agri_experience');
  String get experienceYears => get('experience_years');
  String get yes => get('yes');
  String get no => get('no');

  // 🔹 KYC
  String get kycUpload => get('kyc_upload');
  String get aadhaarFront => get('aadhaar_front');
  String get aadhaarBack => get('aadhaar_back');
  String get panCard => get('pan_card');
  String get passportPhoto => get('passport_photo');
  String get uploadBelow70kb => get('upload_below_70kb');
  String get submitKyc => get('submit_kyc');

  // 🔹 KYC STATUS
  String get kycStatus => get('kyc_status');
  String get kycUnderReview => get('kyc_under_review');
  String get kycWaitAdmin => get('kyc_wait_admin');
  String get kycRejected => get('kyc_rejected');
  String get reuploadKyc => get('reupload_kyc');
  String get reason => get('reason');
  String get invalidStatus => get('invalid_status');

  // 🔹 DASHBOARD GETTERS
  String get welcome => get('welcome');
  String get walletBalance => get('wallet_balance');
  String get withdraw => get('withdraw');
  String get daily => get('daily');
  String get weekly => get('weekly');
  String get monthly => get('monthly');
  String get todayEarnings => get('today_earnings');
  String get weekEarnings => get('week_earnings');
  String get monthEarnings => get('month_earnings');
  String get noTransactions => get('no_transactions');
  String get farmers => get('farmers');
  String get retailers => get('retailers');
  String get wholesalers => get('wholesalers');
  String get exporters => get('exporters');
  String get foodProcessor => get('food_processor');

  // 🔹 ADD FARMER
  String get addFarmer => get('add_farmer');
  String get farmerName => get('farmer_name');
  String get mobileNumber => get('mobile_number');
  String get category => get('category');
  String get product => get('product');
  String get other => get('other');
  String get enterProductName => get('enter_product_name');
  String get quantity => get('quantity');
  String get quantityUnit => get('quantity_unit');
  String get transactionNumber => get('transaction_number');
  String get platformAmount => get('platform_amount');
  String get selectCategory => get('select_category');
  String get selectProduct => get('select_product');
  String get submit => get('submit');
  // 🔥 SUBSCRIPTION GETTERS (NEW)
  String get subscriptionHistory => get('subscription_history');
  String get noSubscriptionsYet => get('no_subscriptions_yet');
  String get amount => get('amount');
  String get addMonth => get('add_month');
  
  String stepOf(int current, int total) {
    return get('step_of')
        .replaceAll('{current}', '$current')
        .replaceAll('{total}', '$total');
  }
}
