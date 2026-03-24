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
      'processors': 'Food Processor',
      'my_payment_requests': 'My Payment Requests',

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
      'processors': 'ఆహార ప్రాసెసర్',
      'my_payment_requests': 'నా చెల్లింపు అభ్యర్థనలు',

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

      // 🔹 ADD RETAILER
'add_retailer': 'చిల్లర వ్యాపారిని జోడించండి',
'retailer_name': 'చిల్లర వ్యాపారి పేరు',
'shop_name': 'దుకాణం పేరు',
'gst_number_optional': 'GST నంబర్ (ఐచ్ఛికం)',
//'pincode': 'పిన్ కోడ్',
//'post_office': 'పోస్ట్ ఆఫీస్',
//'mandal': 'మండలం',
//'district': 'జిల్లా',
//'state': 'రాష్ట్రం',
'products_required': 'అవసరమైన ఉత్పత్తులు',
'add_product': 'ఉత్పత్తిని జోడించండి',
'subscription_amount': 'సబ్‌స్క్రిప్షన్ మొత్తం',
'reference_number': 'రిఫరెన్స్ నంబర్',
//'submit': 'సమర్పించండి',

// 🔹 ADD WHOLESALER
'add_wholesaler': 'హోల్‌సేలర్‌ను జోడించండి',
'wholesaler_name': 'హోల్‌సేలర్ పేరు',
'company_name': 'కంపెనీ పేరు',
//'gst_number_optional': 'GST నంబర్ (ఐచ్ఛికం)',
//'pincode': 'పిన్ కోడ్',
//'post_office': 'పోస్ట్ ఆఫీస్',
//'mandal': 'మండలం',
//'district': 'జిల్లా',
//'state': 'రాష్ట్రం',
'products_supplied': 'సరఫరా చేసే ఉత్పత్తులు',
//'add_product': 'ఉత్పత్తిని జోడించండి',
//'subscription_amount': 'సబ్‌స్క్రిప్షన్ మొత్తం',
//'reference_number': 'రిఫరెన్స్ నంబర్',
//'submit': 'సమర్పించండి',

// 🔹 ADD PROCESSOR
'add_processor': 'ప్రాసెసర్‌ను జోడించండి',
'processor_name': 'ప్రాసెసర్ పేరు',
//'company_name': 'కంపెనీ పేరు',
//'gst_number_optional': 'GST నంబర్ (ఐచ్ఛికం)',
//'pincode': 'పిన్ కోడ్',
//'post_office': 'పోస్ట్ ఆఫీస్',
//'mandal': 'మండలం',
//'district': 'జిల్లా',
//'state': 'రాష్ట్రం',
'services_processing_types': 'సేవలు / ప్రాసెసింగ్ రకాలు',
'add_service': 'సేవను జోడించండి',
//'subscription_amount': 'సబ్‌స్క్రిప్షన్ మొత్తం',
//'reference_number': 'రిఫరెన్స్ నంబర్',
//'submit': 'సమర్పించండి',

// 🔹 ADD EXPORTER
'add_exporter': 'ఎగుమతిదారుని జోడించండి',
'exporter_name': 'ఎగుమతిదారుని పేరు',
//'company_name': 'కంపెనీ పేరు',
//'gst_number_optional': 'GST నంబర్ (ఐచ్ఛికం)',
//'pincode': 'పిన్ కోడ్',
//'post_office': 'పోస్ట్ ఆఫీస్',
//'mandal': 'మండలం',
//'district': 'జిల్లా',
//'state': 'రాష్ట్రం',
'products_for_export': 'ఎగుమతి ఉత్పత్తులు',
//'add_product': 'ఉత్పత్తిని జోడించండి',
//'subscription_amount': 'సబ్‌స్క్రిప్షన్ మొత్తం',
//'reference_number': 'రిఫరెన్స్ నంబర్',
//'submit': 'సమర్పించండి',
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
      'processors': 'खाद्य प्रसंस्करण',
      'my_payment_requests': 'मेरे भुगतान अनुरोध',

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

      // 🔹 ADD RETAILER
'add_retailer': 'खुदरा विक्रेता जोड़ें',
'retailer_name': 'खुदरा विक्रेता का नाम',
'shop_name': 'दुकान का नाम',
'gst_number_optional': 'GST नंबर (वैकल्पिक)',
//'pincode': 'पिन कोड',
//'post_office': 'डाकघर',
//'mandal': 'मंडल',
//'district': 'जिला',
//'state': 'राज्य',
'products_required': 'आवश्यक उत्पाद',
'add_product': 'उत्पाद जोड़ें',
'subscription_amount': 'सब्सक्रिप्शन राशि',
'reference_number': 'रेफरेंस नंबर',
//'submit': 'सबमिट करें',

// 🔹 ADD WHOLESALER
'add_wholesaler': 'थोक विक्रेता जोड़ें',
'wholesaler_name': 'थोक विक्रेता का नाम',
'company_name': 'कंपनी का नाम',
//'gst_number_optional': 'GST नंबर (वैकल्पिक)',
//'pincode': 'पिन कोड',
//'post_office': 'डाकघर',
//'mandal': 'मंडल',
//'district': 'जिला',
//'state': 'राज्य',
'products_supplied': 'आपूर्ति किए जाने वाले उत्पाद',
//'add_product': 'उत्पाद जोड़ें',
//'subscription_amount': 'सब्सक्रिप्शन राशि',
//'reference_number': 'रेफरेंस नंबर',
//'submit': 'सबमिट करें',

// 🔹 ADD PROCESSOR
'add_processor': 'प्रोसेसर जोड़ें',
'processor_name': 'प्रोसेसर का नाम',
//'company_name': 'कंपनी का नाम',
//'gst_number_optional': 'GST नंबर (वैकल्पिक)',
//'pincode': 'पिन कोड',
//'post_office': 'डाकघर',
//'mandal': 'मंडल',
//'district': 'जिला',
//'state': 'राज्य',
'services_processing_types': 'सेवाएं / प्रोसेसिंग प्रकार',
'add_service': 'सेवा जोड़ें',
//'subscription_amount': 'सब्सक्रिप्शन राशि',
//'reference_number': 'रेफरेंस नंबर',
//'submit': 'सबमिट करें',

// 🔹 ADD EXPORTER
'add_exporter': 'निर्यातक जोड़ें',
'exporter_name': 'निर्यातक का नाम',
//'company_name': 'कंपनी का नाम',
//'gst_number_optional': 'GST नंबर (वैकल्पिक)',
//'pincode': 'पिन कोड',
//'post_office': 'डाकघर',
//'mandal': 'मंडल',
//'district': 'जिला',
//'state': 'राज्य',
'products_for_export': 'निर्यात के लिए उत्पाद',
//'add_product': 'उत्पाद जोड़ें',
//'subscription_amount': 'सब्सक्रिप्शन राशि',
//'reference_number': 'रेफरेंस नंबर',
//'submit': 'सबमिट करें',
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
      'processors': 'ಆಹಾರ ಸಂಸ್ಕಾರಕ',
      'my_payment_requests': 'ನನ್ನ ಪಾವತಿ ವಿನಂತಿಗಳು',

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
// 🔹 ADD RETAILER
'add_retailer': 'ಚಿಲ್ಲರೆ ವ್ಯಾಪಾರಿಯನ್ನು ಸೇರಿಸಿ',
'retailer_name': 'ಚಿಲ್ಲರೆ ವ್ಯಾಪಾರಿ ಹೆಸರು',
'shop_name': 'ಅಂಗಡಿ ಹೆಸರು',
'gst_number_optional': 'GST ಸಂಖ್ಯೆ (ಐಚ್ಛಿಕ)',
//'pincode': 'ಪಿನ್ ಕೋಡ್',
//'post_office': 'ಅಂಚೆ ಕಚೇರಿ',
//'mandal': 'ಮಂಡಲ',
//'district': 'ಜಿಲ್ಲೆ',
//'state': 'ರಾಜ್ಯ',
'products_required': 'ಅಗತ್ಯ ಉತ್ಪನ್ನಗಳು',
'add_product': 'ಉತ್ಪನ್ನ ಸೇರಿಸಿ',
'subscription_amount': 'ಚಂದಾದಾರಿಕೆ ಮೊತ್ತ',
'reference_number': 'ರೆಫರೆನ್ಸ್ ಸಂಖ್ಯೆ',
//'submit': 'ಸಲ್ಲಿಸಿ',

// 🔹 ADD WHOLESALER
'add_wholesaler': 'ಸಗಟು ವ್ಯಾಪಾರಿಯನ್ನು ಸೇರಿಸಿ',
'wholesaler_name': 'ಸಗಟು ವ್ಯಾಪಾರಿ ಹೆಸರು',
'company_name': 'ಕಂಪನಿ ಹೆಸರು',
//'gst_number_optional': 'GST ಸಂಖ್ಯೆ (ಐಚ್ಛಿಕ)',
//'pincode': 'ಪಿನ್ ಕೋಡ್',
//'post_office': 'ಅಂಚೆ ಕಚೇರಿ',
//'mandal': 'ಮಂಡಲ',
//'district': 'ಜಿಲ್ಲೆ',
//'state': 'ರಾಜ್ಯ',
'products_supplied': 'ಪೂರೈಕೆ ಮಾಡುವ ಉತ್ಪನ್ನಗಳು',
//'add_product': 'ಉತ್ಪನ್ನ ಸೇರಿಸಿ',
//'subscription_amount': 'ಚಂದಾದಾರಿಕೆ ಮೊತ್ತ',
//'reference_number': 'ರೆಫರೆನ್ಸ್ ಸಂಖ್ಯೆ',
//'submit': 'ಸಲ್ಲಿಸಿ',

// 🔹 ADD PROCESSOR
'add_processor': 'ಪ್ರೊಸೆಸರ್ ಸೇರಿಸಿ',
'processor_name': 'ಪ್ರೊಸೆಸರ್ ಹೆಸರು',
//'company_name': 'ಕಂಪನಿ ಹೆಸರು',
//'gst_number_optional': 'GST ಸಂಖ್ಯೆ (ಐಚ್ಛಿಕ)',
//'pincode': 'ಪಿನ್ ಕೋಡ್',
//'post_office': 'ಅಂಚೆ ಕಚೇರಿ',
//'mandal': 'ಮಂಡಲ',
//'district': 'ಜಿಲ್ಲೆ',
//'state': 'ರಾಜ್ಯ',
'services_processing_types': 'ಸೇವೆಗಳು / ಪ್ರೊಸೆಸಿಂಗ್ ವಿಧಗಳು',
'add_service': 'ಸೇವೆ ಸೇರಿಸಿ',
//'subscription_amount': 'ಚಂದಾದಾರಿಕೆ ಮೊತ್ತ',
//'reference_number': 'ರೆಫರೆನ್ಸ್ ಸಂಖ್ಯೆ',
//'submit': 'ಸಲ್ಲಿಸಿ',

// 🔹 ADD EXPORTER
'add_exporter': 'ರಫ್ತುಗಾರರನ್ನು ಸೇರಿಸಿ',
'exporter_name': 'ರಫ್ತುಗಾರರ ಹೆಸರು',
////'company_name': 'ಕಂಪನಿ ಹೆಸರು',
//'gst_number_optional': 'GST ಸಂಖ್ಯೆ (ಐಚ್ಛಿಕ)',
//'pincode': 'ಪಿನ್ ಕೋಡ್',
//'post_office': 'ಅಂಚೆ ಕಚೇರಿ',
//'manda//'district': 'ಜಿಲ್ಲೆ',
//'state': 'ರಾಜ್ಯ',
'products_for_export': 'ರಫ್ತು ಉತ್ಪನ್ನಗಳು',
//'add_product': 'ಉತ್ಪನ್ನ ಸೇರಿಸಿ',
//'subscription_amount': 'ಚಂದಾದಾರಿಕೆ ಮೊತ್ತ',
//'reference_number': 'ರೆಫರೆನ್ಸ್ ಸಂಖ್ಯೆ',
//'submit': 'ಸಲ್ಲಿಸಿ',

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
      'processors': 'உணவு செயலாக்கம்',
      'my_payment_requests': 'என் பணம் கோரிக்கைகள்',

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

      // 🔹 ADD RETAILER
'add_retailer': 'சில்லறை வியாபாரியை சேர்க்கவும்',
'retailer_name': 'சில்லறை வியாபாரி பெயர்',
'shop_name': 'கடை பெயர்',
'gst_number_optional': 'GST எண் (விருப்பம்)',
//'pincode': 'அஞ்சல் குறியீடு',
//'post_office': 'தபால் நிலையம்',
//'mandal': 'மண்டலம்',
//'district': 'மாவட்டம்',
//'state': 'மாநிலம்',
'products_required': 'தேவையான பொருட்கள்',
'add_product': 'பொருளை சேர்க்கவும்',
'subscription_amount': 'சந்தா தொகை',
'reference_number': 'குறிப்பு எண்',
//'submit': 'சமர்ப்பிக்கவும்',

// 🔹 ADD WHOLESALER
'add_wholesaler': 'மொத்த விற்பனையாளரை சேர்க்கவும்',
'wholesaler_name': 'மொத்த விற்பனையாளர் பெயர்',
'company_name': 'நிறுவனத்தின் பெயர்',
//'gst_number_optional': 'GST எண் (விருப்பம்)',
//'pincode': 'அஞ்சல் குறியீடு',
//'post_office': 'அஞ்சலகம்',
//'mandal': 'வட்டம்',
//'district': 'மாவட்டம்',
//'state': 'மாநிலம்',
'products_supplied': 'விநியோகிக்கும் பொருட்கள்',
//'add_product': 'பொருளை சேர்க்கவும்',
//'subscription_amount': 'சந்தா தொகை',
//'reference_number': 'குறிப்பு எண்',
//'submit': 'சமர்ப்பிக்கவும்',

// 🔹 ADD PROCESSOR
'add_processor': 'செயலாக்குநரை சேர்க்கவும்',
'processor_name': 'செயலாக்குநர் பெயர்',
//'company_name': 'நிறுவனத்தின் பெயர்',
//'gst_number_optional': 'GST எண் (விருப்பம்)',
//'pincode': 'அஞ்சல் குறியீடு',
//'post_office': 'அஞ்சலகம்',
//'mandal': 'வட்டம்',
//'district': 'மாவட்டம்',
//'state': 'மாநிலம்',
'services_processing_types': 'சேவைகள் / செயலாக்க வகைகள்',
'add_service': 'சேவையை சேர்க்கவும்',
//'subscription_amount': 'சந்தா தொகை',
//'reference_number': 'குறிப்பு எண்',
//'submit': 'சமர்ப்பிக்கவும்',

// 🔹 ADD EXPORTER
'add_exporter': 'ஏற்றுமதியாளரை சேர்க்கவும்',
'exporter_name': 'ஏற்றுமதியாளர் பெயர்',
//'company_name': 'நிறுவனத்தின் பெயர்',
//'gst_number_optional': 'GST எண் (விருப்பம்)',
//'pincode': 'அஞ்சல் குறியீடு',
//'post_office': 'அஞ்சலகம்',
//'mandal': 'வட்டம்',
//'district': 'மாவட்டம்',
//'state': 'மாநிலம்',
'products_for_export': 'ஏற்றுமதி பொருட்கள்',
//'add_product': 'பொருளை சேர்க்கவும்',
//'subscription_amount': 'சந்தா தொகை',
//'reference_number': 'குறிப்பு எண்',
//'submit': 'சமர்ப்பிக்கவும்',
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
  'my_payment_requests': 'ମୋର ଅଦାୟ ଅନୁରୋଧ',

'add_farmer': 'ଚାଷୀକୁ ଯୋଡନ୍ତୁ',
'farmer_name': 'ଚାଷୀଙ୍କ ନାମ',
'mobile_number': 'ମୋବାଇଲ୍ ନମ୍ବର',
'category': 'ଶ୍ରେଣୀ',
'product': 'ପଣ୍ୟ',
'other': 'ଅନ୍ୟ',
'enter_product_name': 'ପଣ୍ୟର ନାମ ଲେଖନ୍ତୁ',
'quantity': 'ପରିମାଣ',
'quantity_unit': 'ଏକକ',
'transaction_number': 'ଲେନଦେନ ସଂଖ୍ୟା',
'platform_amount': 'ପ୍ଲାଟଫର୍ମ ରାଶି',
'select_category': 'ଶ୍ରେଣୀ ବାଛନ୍ତୁ',
'select_product': 'ପଣ୍ୟ ବାଛନ୍ତୁ',
'submit': 'ଦାଖଲ କରନ୍ତୁ',

// 🔥 SUBSCRIPTION
'subscription_history': 'ସବସ୍କ୍ରିପ୍ସନ୍ ଇତିହାସ',
'subscription_amount': 'ସବସ୍କ୍ରିପ୍ସନ ରାଶି',
'no_subscriptions_yet': 'ଏପର୍ଯ୍ୟନ୍ତ କୌଣସି ସବସ୍କ୍ରିପ୍ସନ୍ ନାହିଁ',
'amount': 'ରାଶି',
'add_month': 'ନୂତନ ମାସ ଯୋଡନ୍ତୁ',

// 🔹 ADD RETAILER
'add_retailer': 'ଖୁଦ୍ର ବ୍ୟବସାୟୀଙ୍କୁ ଯୋଡନ୍ତୁ',
'retailer_name': 'ଖୁଦ୍ର ବ୍ୟବସାୟୀଙ୍କ ନାମ',
'shop_name': 'ଦୋକାନର ନାମ',
'gst_number_optional': 'GST ନମ୍ବର (ଇଚ୍ଛାଧୀନ)',
//'pincode': 'ପିନ୍ କୋଡ୍',
//'post_of//'district': 'ଜିଲ୍ଲା',
//'state': 'ରାଜ୍ୟ',
'products_required': 'ଆବଶ୍ୟକ ଉତ୍ପାଦ',
'add_product': 'ଉତ୍ପାଦ ଯୋଡନ୍ତୁ',
//'subscription_amount': 'ସବସ୍କ୍ରିପ୍ସନ ରାଶି',
'reference_number': 'ରେଫରେନ୍ସ ନମ୍ବର',
//'submit': 'ସବମିଟ୍ କରନ୍ତୁ',

// 🔹 ADD WHOLESALER
'add_wholesaler': 'ଥୋକ ବ୍ୟବସାୟୀଙ୍କୁ ଯୋଡନ୍ତୁ',
'wholesaler_name': 'ଥୋକ ବ୍ୟବସାୟୀଙ୍କ ନାମ',
'company_name': 'କମ୍ପାନୀ ନାମ',
//'gst_number_optional': 'GST ନମ୍ବର (ଇଚ୍ଛାଧୀନ)',
//'pin//'post_office': 'ଡାକଘର',
//'mandal': 'ମଣ୍ଡଳ',
//'district': 'ଜିଲ୍ଲା',
//'state': 'ରାଜ୍ୟ',
'products_supplied': 'ଯୋଗାଣ ହେଉଥିବା ଉତ୍ପାଦ',
//'add_product': 'ଉତ୍ପାଦ ଯୋଡନ୍ତୁ',
//'subscription_amount': 'ସବସ୍କ୍ରିପ୍ସନ ରାଶି',
//'reference_number': 'ରେଫରେନ୍ସ ନମ୍ବର',
//'submit': 'ସବମିଟ୍ କରନ୍ତୁ',

// 🔹 ADD PROCESSOR
'add_processor': 'ପ୍ରୋସେସର୍ ଯୋଡନ୍ତୁ',
'processor_name': 'ପ୍ରୋସେସର୍ ନାମ',
//'company_name': 'କମ୍ପାନୀ ନାମ',
//'gst_number_optional': 'GST ନମ୍ବର (ଇଚ୍ଛାଧୀନ)',
//'pincode': 'ପିନ୍ କୋଡ୍',
//'post_office': 'ଡାକଘର',
//'mandal': 'ମଣ୍ଡଳ',
//'district': 'ଜିଲ୍ଲା',
//'state': 'ରାଜ୍ୟ',
'services_processing_types': 'ସେବା / ପ୍ରୋସେସିଂ ପ୍ରକାର',
'add_service': 'ସେବା ଯୋଡନ୍ତୁ',
//'subscription_amount': 'ସବସ୍କ୍ରିପ୍ସନ ରାଶି',
//'reference_number': 'ରେଫରେନ୍ସ ନମ୍ବର',
//submit': 'ସବମିଟ୍ କରନ୍ତୁ',

// 🔹 ADD EXPORTER
'add_exporter': 'ରପ୍ତାନିକାରୀଙ୍କୁ ଯୋଡନ୍ତୁ',
'exporter_name': 'ରପ୍ତାନିକାରୀଙ୍କ ନାମ',
//'company_name': 'କମ୍ପାନୀ ନାମ',
//'gst_number_optional': 'GST ନମ୍ବର (ଇଚ୍ଛାଧୀନ)',
//'pincode': 'ପିନ୍ କୋଡ୍',
//'post_office': 'ଡାକଘର',
//'mandal': 'ମଣ୍ଡଳ',
//'district': 'ଜିଲ୍ଲା',
//'state': 'ରାଜ୍ୟ',
'products_for_export': 'ରପ୍ତାନି ପାଇଁ ଉତ୍ପାଦ',
//'add_product': 'ଉତ୍ପାଦ ଯୋଡନ୍ତୁ',
//'subscription_amount': 'ସବସ୍କ୍ରିପ୍ସନ ରାଶି',
//'reference_number': 'ରେଫରେନ୍ସ ନମ୍ବର',
//'submit': 'ସବମିଟ୍ କରନ୍ତୁ',
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
  'my_payment_requests': 'माझे पेमेंट विनंत्या',

  'subscription_history': 'सदस्यता इतिहास',
  'no_subscriptions_yet': 'अद्याप सदस्यता नाही',
  'amount': 'रक्कम',
  'add_month': 'नवीन महिना जोडा',

  // 🔹 ADD RETAILER
'add_retailer': 'चिल्लर विक्रेता जोडा',
'retailer_name': 'चिल्लर विक्रेत्याचे नाव',
'shop_name': 'दुकानाचे नाव',
'gst_number_optional': 'GST नंबर (पर्यायी)',
//'pincode': 'पिनकोड',
//'post_office': 'पोस्ट ऑफिस',
//'mandal': 'तालुका',
//'district': 'जिल्हा',
//'state': 'राज्य',
'products_required': 'आवश्यक उत्पादने',
'add_product': 'उत्पादन जोडा',
'subscription_amount': 'सबस्क्रिप्शन रक्कम',
'reference_number': 'संदर्भ क्रमांक',
//'submit': 'सबमिट करा',

// 🔹 ADD WHOLESALER
'add_wholesaler': 'घाऊक विक्रेता जोडा',
'wholesaler_name': 'घाऊक विक्रेत्याचे नाव',
'company_name': 'कंपनीचे नाव',
////'gst_number_optional': 'GST नंबर (पर्यायी)',
//'pincode': 'पिनकोड',
//'post_office': 'पोस्ट ऑफिस',
//'mandal': 'तालुका',
//'district': 'जिल्हा',
//'state': 'राज्य',
'products_supplied': 'पुरवठा केलेली उत्पादने',
//'add_product': 'उत्पादन जोडा',
//'subscription_amount': 'सबस्क्रिप्शन रक्कम',
//'reference_number': 'संदर्भ क्रमांक',
//'submit': 'सबमिट करा',

// 🔹 ADD PROCESSOR
'add_processor': 'प्रोसेसर जोडा',
'processor_name': 'प्रोसेसरचे नाव',
//'company_name': 'कंपनीचे नाव',
//'gst_number_optional': 'GST नंबर (पर्यायी)',
//'pincode': 'पिनकोड',
//'post_office': 'पोस्ट ऑफिस',
//'mandal': 'तालुका',
//'dis//'state': 'राज्य',
'services_processing_types': 'सेवा / प्रक्रिया प्रकार',
'add_service': 'सेवा जोडा',
//'subscription_amount': 'सबस्क्रिप्शन रक्कम',
//'reference_number': 'संदर्भ क्रमांक',
//'submit': 'सबमिट करा',

// 🔹 ADD EXPORTER
'add_exporter': 'निर्यातदार जोडा',
'exporter_name': 'निर्यातदाराचे नाव',
//'company_name': 'कंपनीचे नाव',
//'gst_number_optional': 'GST नंबर (पर्यायी)',
//'pincode': 'पिनकोड',
//'post_office': 'पोस्ट ऑफिस',
//'mandal': 'तालुका',
//'district': 'जिल्हा',
//'state': 'राज्य',
'products_for_export': 'निर्यातीसाठी उत्पादने',
//'add_product': 'उत्पादन जोडा',
//'subscription_amount': 'सबस्क्रिप्शन रक्कम',
//'reference_number': 'संदर्भ क्रमांक',
//'submit': 'सबमिट करा',
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
  'my_payment_requests': 'എന്റെ പേയ്മെന്റ് അഭ്യർത്ഥനകൾ',

  'subscription_history': 'സബ്സ്ക്രിപ്ഷൻ ചരിത്രം',
  'no_subscriptions_yet': 'ഇനിയും സബ്സ്ക്രിപ്ഷനുകൾ ഇല്ല',
  'amount': 'തുക',
  'add_month': 'പുതിയ മാസം ചേർക്കുക',
  // 🔹 ADD RETAILER
'add_retailer': 'ചില്ലറ വ്യാപാരിയെ ചേർക്കുക',
'retailer_name': 'ചില്ലറ വ്യാപാരി പേര്',
'shop_name': 'കടയുടെ പേര്',
'gst_number_optional': 'GST നമ്പർ (ഐച്ഛികം)',
//'pincode': 'പിൻകോഡ്',
//'post_office': 'പോസ്റ്റ് ഓഫീസ്',
//'mandal': 'മണ്ഡലം',
//'district': 'ജില്ല',
//'state': 'സംസ്ഥാനം',
'products_required': 'ആവശ്യമായ ഉൽപ്പന്നങ്ങൾ',
'add_product': 'ഉൽപ്പന്നം ചേർക്കുക',
'subscription_amount': 'സബ്സ്ക്രിപ്ഷൻ തുക',
'reference_number': 'റഫറൻസ് നമ്പർ',
'submit': 'സമർപ്പിക്കുക',

// 🔹 ADD WHOLESALER
'add_wholesaler': 'മൊത്ത വ്യാപാരിയെ ചേർക്കുക',
'wholesaler_name': 'മൊത്ത വ്യാപാരി പേര്',
'company_name': 'കമ്പനി പേര്',
//'gst_number_optional': 'GST നമ്പർ (ഐച്ഛികം)',
//'pincode': 'പിൻകോഡ്',
//'post_office': 'പോസ്റ്റ് ഓഫീസ്',
//'mandal': 'മണ്ഡലം',
//'district': 'ജില്ല',
//'state': 'സംസ്ഥാനം',
'products_supplied': 'വിതരിക്കുന്ന ഉൽപ്പന്നങ്ങൾ',
//'add_product': 'ഉൽപ്പന്നം ചേർക്കുക',
//'subscription_amount': 'സബ്സ്ക്രിപ്ഷൻ തുക',
//'reference_number': 'റഫറൻസ് നമ്പർ',
//'submit': 'സമർപ്പിക്കുക',

// 🔹 ADD PROCESSOR
'add_processor': 'പ്രോസസറെ ചേർക്കുക',
'processor_name': 'പ്രോസസർ പേര്',
//'company_name': 'കമ്പനി പേര്',
//'gst_number_optional': 'GST നമ്പർ (ഐച്ഛികം)',
//'pincode': 'പിൻകോഡ്',
//'post_office': 'പോസ്റ്റ് ഓഫീസ്',
//'mandal': 'മണ്ഡലം',
//'district': 'ജില്ല',
//'state': 'സംസ്ഥാനം',
'services_processing_types': 'സേവനങ്ങൾ / പ്രോസസ്സിംഗ് തരം',
'add_service': 'സേവനം ചേർക്കുക',
//'subscription_amount': 'സബ്സ്ക്രിപ്ഷൻ തുക',
//'reference_number': 'റഫറൻസ് നമ്പർ',
//'submit': 'സമർപ്പിക്കുക',

// 🔹 ADD EXPORTER
'add_exporter': 'കയറ്റുമതിക്കാരനെ ചേർക്കുക',
'exporter_name': 'കയറ്റുമതിക്കാരന്റെ പേര്',
//'company_name': 'കമ്പനി പേര്',
//'gst_number_optional': 'GST നമ്പർ (ഐച്ഛികം)',
//'pincode': 'പിൻകോഡ്',
//'post_office': 'പോസ്റ്റ് ഓഫീസ്',
//'mandal': 'മണ്ഡലം',
//'district': 'ജില്ല',
//'state': 'സംസ്ഥാനം',
'products_for_export': 'കയറ്റുമതി ഉൽപ്പന്നങ്ങൾ',
//'add_product': 'ഉൽപ്പന്നം ചേർക്കുക',
//'subscription_amount': 'സബ്സ്ക്രിപ്ഷൻ തുക',
//'reference_number': 'റഫറൻസ് നമ്പർ',
//'submit': 'സമർപ്പിക്കുക',
},    
  };

  String get(String key) =>
      _data[lang]?[key] ?? _data['en']![key] ?? key;

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
  String get required => get('required');

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

  // 🔹 DASHBOARD
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
  String get processors => get('processors');
  String get myPaymentRequests => get('my_payment_requests');

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

  // 🔥 SUBSCRIPTION
  String get subscriptionHistory => get('subscription_history');
  String get noSubscriptionsYet => get('no_subscriptions_yet');
  String get amount => get('amount');
  String get addMonth => get('add_month');


// 🔹 ADD RETAILER
String get addRetailer => get('add_retailer');
String get retailerName => get('retailer_name');
String get shopName => get('shop_name');
String get gstNumberOptional => get('gst_number_optional');
//String get pincode => get('pincode');
//String get postOffice => get('post_office');
//String get mandal => get('mandal');
//String get district => get('district');
//String get state => get('state');
String get productsRequired => get('products_required');
String get addProduct => get('add_product');
String get subscriptionAmount => get('subscription_amount');
String get referenceNumber => get('reference_number');
//String get submit => get('submit');
//String get mobileNumber => get('mobile_number');
String get requiredField => get('required');

  // 🔥 ADD WHOLESALER (NEW)
String get addWholesaler => get('add_wholesaler');
String get wholesalerName => get('wholesaler_name');
String get companyName => get('company_name');
//String get gstNumberOptional => get('gst_number_optional');

//String get pincode => get('pincode');
//String get postOffice => get('post_office');
//String get mandal => get('mandal');
//String get district => get('district');
//String get state => get('state');

String get productsSupplied => get('products_supplied');
//String get addProduct => get('add_product');

//String get subscriptionAmount => get('subscription_amount');
//String get referenceNumber => get('reference_number');

//String get submit => get('submit');

  // 🔥 ADD PROCESSOR (NEW)
String get addProcessor => get('add_processor');
String get processorName => get('processor_name');
//String get companyName => get('company_name');
//String get gstNumberOptional => get('gst_number_optional');

//String get pincode => get('pincode');
//String get postOffice => get('post_office');
//String get mandal => get('mandal');
//String get district => get('district');
//String get state => get('state');

String get servicesProcessingTypes => get('services_processing_types');
String get addService => get('add_service');

//String get subscriptionAmount => get('subscription_amount');
//String get referenceNumber => get('reference_number');
//String get submit => get('submit');

  // 🔥 ADD EXPORTER (NEW)
String get addExporter => get('add_exporter');
String get exporterName => get('exporter_name');
//String get companyName => get('company_name');
//String get gstNumberOptional => get('gst_number_optional');

//String get pincode => get('pincode');
//String get postOffice => get('post_office');
//String get mandal => get('mandal');
//String get district => get('district');
//String get state => get('state');

String get productsForExport => get('products_for_export');
//String get addProduct => get('add_product');

//String get subscriptionAmount => get('subscription_amount');
//String get referenceNumber => get('reference_number');
//String get submit => get('submit');
  
  String stepOf(int current, int total) {
    return get('step_of')
        .replaceAll('{current}', '$current')
        .replaceAll('{total}', '$total');
  }
}
