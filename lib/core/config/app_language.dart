import 'package:flutter/material.dart';

enum AppLang { en, hi, mr, pa, ta, te }

const langNames = {
  AppLang.en: 'English',
  AppLang.hi: 'हिंदी',
  AppLang.mr: 'मराठी',
  AppLang.pa: 'ਪੰਜਾਬੀ',
  AppLang.ta: 'தமிழ்',
  AppLang.te: 'తెలుగు',
};

// Add every UI string you want translated here.
final Map<AppLang, Map<String, String>> _strings = {
  AppLang.en: {
    'app_name': 'CropMitra AI',
    'tagline': 'Your smart farming companion',
    'detect_disease': 'Detect Crop Disease',
    'detect_disease_desc': 'Take a photo and identify crop problems',
    'get_advice': 'Get Farming Advice',
    'get_advice_desc': 'Ask CropMitra AI about your crops',
    'weather': 'Weather',
    'tools': 'Tools',
    'ai_assistant': 'AI Assistant',
    'quick_access': 'Quick access',
    'select_language': 'Select language',
    'expert_review': 'Expert review recommended',
    'expert_review_desc':
        'AI suggestions are preliminary. Connect with an agriculture expert before treating your crop.',
    'contact_expert': 'Contact an expert',
    'report_case': 'Report this case',
    'report_intro':
        'Save this observation locally for your demo and future follow-up.',
    'crop_name': 'Crop name',
    'suspected_disease': 'Suspected disease',
    'location': 'Village / location',
    'symptoms': 'Symptoms and notes',
    'save_report': 'Save report',
    'report_saved': 'Disease report saved locally',
    'recent_reports': 'Recent reports',
    'required': 'Required',
  },
  AppLang.hi: {
    'app_name': 'क्रॉपमित्र AI',
    'tagline': 'आपका स्मार्ट खेती साथी',
    'detect_disease': 'फसल रोग पहचानें',
    'detect_disease_desc': 'फोटो लें और फसल की समस्या पहचानें',
    'get_advice': 'खेती की सलाह लें',
    'get_advice_desc': 'अपनी फसल के बारे में क्रॉपमित्र AI से पूछें',
    'weather': 'मौसम',
    'tools': 'उपकरण',
    'ai_assistant': 'AI सहायक',
    'quick_access': 'त्वरित पहुंच',
    'select_language': 'भाषा चुनें',
    'expert_review': 'विशेषज्ञ की सलाह लें',
    'expert_review_desc':
        'AI सुझाव प्रारंभिक हैं। फसल का उपचार करने से पहले कृषि विशेषज्ञ से संपर्क करें।',
    'contact_expert': 'विशेषज्ञ से संपर्क करें',
    'report_case': 'इस मामले की रिपोर्ट करें',
    'report_intro':
        'डेमो और भविष्य की निगरानी के लिए यह जानकारी स्थानीय रूप से सहेजें।',
    'crop_name': 'फसल का नाम',
    'suspected_disease': 'संदिग्ध रोग',
    'location': 'गांव / स्थान',
    'symptoms': 'लक्षण और टिप्पणियां',
    'save_report': 'रिपोर्ट सहेजें',
    'report_saved': 'रोग रिपोर्ट स्थानीय रूप से सहेजी गई',
    'recent_reports': 'हाल की रिपोर्ट',
    'required': 'आवश्यक',
  },
  AppLang.mr: {
    'app_name': 'क्रॉपमित्र AI',
    'tagline': 'तुमचा स्मार्ट शेती साथी',
    'detect_disease': 'पिकाचा रोग ओळखा',
    'detect_disease_desc': 'फोटो घेऊन पिकाची समस्या ओळखा',
    'get_advice': 'शेतीचा सल्ला घ्या',
    'get_advice_desc': 'तुमच्या पिकांबद्दल क्रॉपमित्र AI ला विचारा',
    'weather': 'हवामान',
    'tools': 'साधने',
    'ai_assistant': 'AI सहाय्यक',
    'quick_access': 'जलद प्रवेश',
    'select_language': 'भाषा निवडा',
    'expert_review': 'तज्ज्ञांचा सल्ला घ्या',
    'expert_review_desc':
        'AI सूचना प्राथमिक आहेत. पिकावर उपचार करण्यापूर्वी कृषी तज्ज्ञांशी संपर्क साधा.',
    'contact_expert': 'तज्ज्ञांशी संपर्क साधा',
  },
  AppLang.pa: {
    'app_name': 'ਕ੍ਰੌਪਮਿੱਤਰਾ AI',
    'tagline': 'ਤੁਹਾਡਾ ਸਮਾਰਟ ਖੇਤੀ ਸਾਥੀ',
    'detect_disease': 'ਫਸਲ ਦੀ ਬਿਮਾਰੀ ਪਛਾਣੋ',
    'detect_disease_desc': 'ਫੋਟੋ ਲੈ ਕੇ ਫਸਲ ਦੀ ਸਮੱਸਿਆ ਪਛਾਣੋ',
    'get_advice': 'ਖੇਤੀ ਦੀ ਸਲਾਹ ਲਓ',
    'get_advice_desc': 'ਆਪਣੀਆਂ ਫਸਲਾਂ ਬਾਰੇ CropMitra AI ਨੂੰ ਪੁੱਛੋ',
    'weather': 'ਮੌਸਮ',
    'tools': 'ਸਾਧਨ',
    'ai_assistant': 'AI ਸਹਾਇਕ',
    'quick_access': 'ਤੁਰੰਤ ਪਹੁੰਚ',
    'select_language': 'ਭਾਸ਼ਾ ਚੁਣੋ',
    'expert_review': 'ਮਾਹਰ ਦੀ ਸਲਾਹ ਲਓ',
    'expert_review_desc':
        'AI ਸੁਝਾਅ ਮੁੱਢਲੇ ਹਨ। ਫਸਲ ਦਾ ਇਲਾਜ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਖੇਤੀ ਮਾਹਰ ਨਾਲ ਸੰਪਰਕ ਕਰੋ।',
    'contact_expert': 'ਮਾਹਰ ਨਾਲ ਸੰਪਰਕ ਕਰੋ',
  },
  AppLang.ta: {
    'app_name': 'கிராப்மித்ரா AI',
    'tagline': 'உங்கள் ஸ்மார்ட் விவசாயத் துணை',
    'detect_disease': 'பயிர் நோயைக் கண்டறியுங்கள்',
    'detect_disease_desc': 'புகைப்படம் எடுத்து பயிர் பிரச்சினையை அறியுங்கள்',
    'get_advice': 'விவசாய ஆலோசனை பெறுங்கள்',
    'get_advice_desc': 'உங்கள் பயிர்கள் பற்றி CropMitra AIயிடம் கேளுங்கள்',
    'weather': 'வானிலை',
    'tools': 'கருவிகள்',
    'ai_assistant': 'AI உதவியாளர்',
    'quick_access': 'விரைவு அணுகல்',
    'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
    'expert_review': 'நிபுணர் ஆலோசனை பரிந்துரைக்கப்படுகிறது',
    'expert_review_desc':
        'AI பரிந்துரைகள் ஆரம்ப நிலையானவை. பயிருக்கு சிகிச்சை அளிப்பதற்கு முன் வேளாண் நிபுணரைத் தொடர்பு கொள்ளுங்கள்.',
    'contact_expert': 'நிபுணரைத் தொடர்பு கொள்ளுங்கள்',
  },
  AppLang.te: {
    'app_name': 'క్రాప్‌మిత్ర AI',
    'tagline': 'మీ స్మార్ట్ వ్యవసాయ సహచరుడు',
    'detect_disease': 'పంట వ్యాధిని గుర్తించండి',
    'detect_disease_desc': 'ఫోటో తీసి పంట సమస్యను గుర్తించండి',
    'get_advice': 'వ్యవసాయ సలహా పొందండి',
    'get_advice_desc': 'మీ పంటల గురించి CropMitra AIని అడగండి',
    'weather': 'వాతావరణం',
    'tools': 'పరికరాలు',
    'ai_assistant': 'AI సహాయకుడు',
    'quick_access': 'త్వరిత ప్రాప్యత',
    'select_language': 'భాషను ఎంచుకోండి',
    'expert_review': 'నిపుణుల సమీక్ష సిఫార్సు చేయబడింది',
    'expert_review_desc':
        'AI సూచనలు ప్రాథమికమైనవి. పంటకు చికిత్స చేసే ముందు వ్యవసాయ నిపుణుడిని సంప్రదించండి.',
    'contact_expert': 'నిపుణుడిని సంప్రదించండి',
  },
};

class AppLanguage extends ValueNotifier<AppLang> {
  AppLanguage() : super(AppLang.en);

  String t(String key) =>
      _strings[value]?[key] ?? _strings[AppLang.en]![key] ?? key;

  void set(AppLang lang) {
    if (value != lang) {
      value = lang;
    }
  }
}

// One global instance, simplest possible state management — no extra packages.
final appLanguage = AppLanguage();
