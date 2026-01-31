// ignore_for_file: unused_field
import 'package:daleel/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class AddTripScreen extends StatefulWidget {
  final String userName;

  const AddTripScreen({
    super.key,
    required this.userName,
  });

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Page Controller
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _progressController;
  
  // Controllers للصفحة الأولى
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Dropdown values
  String? _selectedCategory;
  String? _selectedGovernorate;
  String? _selectedCity;
  DateTime? _selectedDate;
  
  // Location
  String? _currentLocation;
  double? _latitude;
  double? _longitude;
  
  // Files
  final List<PlatformFile> _selectedFiles = [];
  
  // الخطوات (الصفحة الثانية)
  final List<TripStep> _tripSteps = [];
  
  // القوائم
  final List<String> _categories = [
    'الجيش',
    'التخرج الجامعي',
    'السفر للخارج',
    'الزواج',
    'ترخيص السيارات',
    'أخرى',
  ];
  
  final Map<String, List<String>> _governoratesAndCities = {
    'القاهرة': ['مدينة نصر', 'المعادي', 'مصر الجديدة', 'الزمالك', 'المنيل'],
    'الجيزة': ['الدقي', 'المهندسين', 'الهرم', 'فيصل', '6 أكتوبر'],
    'الإسكندرية': ['المنتزه', 'سيدي جابر', 'المنشية', 'محطة الرمل', 'سموحة'],
    'الشرقية': ['الزقازيق', 'العاشر من رمضان', 'فاقوس', 'منيا القمح', 'أبو كبير'],
    'القليوبية': ['بنها', 'شبرا الخيمة', 'القناطر الخيرية', 'قليوب', 'طوخ'],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _placeNameController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _progressController.dispose();
    for (var step in _tripSteps) {
      step.titleController.dispose();
      step.descriptionController.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_currentStep == 1) {
      // لو في الصفحة الثانية، ارجع للأولى
      _previousStep();
      return false;
    }
    
    // التحقق إذا كان المستخدم أدخل بيانات
    if (_tripNameController.text.isNotEmpty ||
        _placeNameController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _selectedCategory != null ||
        _selectedFiles.isNotEmpty ||
        _tripSteps.isNotEmpty) {
      return await _showExitDialog();
    }
    return true;
  }

  Future<bool> _showExitDialog() async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ScaleTransition(
            scale: CurvedAnimation(
              parent: ModalRoute.of(context)!.animation!,
              curve: Curves.easeOutBack,
            ),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white,
                      const Color(0xFF379777).withOpacity(0.02),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF379777).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFF379777),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'تأكيد الخروج',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'هل أنت متأكد من الخروج؟\nسيتم فقدان جميع البيانات المدخلة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'خروج',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        false;
  }

  void _nextStep() {
    if (_currentStep == 0) {
      // التحقق من الصفحة الأولى
      if (!_formKey.currentState!.validate()) return;
      if (_selectedCategory == null) {
        _showSnackBar('يرجى اختيار القسم', isError: true);
        return;
      }
      if (_selectedGovernorate == null) {
        _showSnackBar('يرجى اختيار المحافظة', isError: true);
        return;
      }
      if (_selectedCity == null) {
        _showSnackBar('يرجى اختيار المدينة', isError: true);
        return;
      }
      if (_selectedDate == null) {
        _showSnackBar('يرجى اختيار التاريخ', isError: true);
        return;
      }
      
      // الانتقال للصفحة التانية
      setState(() {
        _currentStep = 1;
      });
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _progressController.animateTo(1.0);
    }
  }

  void _previousStep() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      _progressController.animateTo(0.0);
    }
  }

  void _addStep() {
    if (_tripSteps.length >= 10) {
      _showSnackBar('لا يمكن إضافة أكثر من 10 خطوات', isError: true);
      return;
    }
    
    setState(() {
      _tripSteps.add(TripStep(
        titleController: TextEditingController(),
        descriptionController: TextEditingController(),
      ));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _tripSteps[index].titleController.dispose();
      _tripSteps[index].descriptionController.dispose();
      _tripSteps.removeAt(index);
    });
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        for (var file in result.files) {
          if (file.size > 5 * 1024 * 1024) {
            _showSnackBar('حجم الملف ${file.name} أكبر من 5 ميجا', isError: true);
            return;
          }
        }
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء اختيار الملفات', isError: true);
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('خدمة الموقع غير مفعلة', isError: true);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('تم رفض إذن الموقع', isError: true);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _currentLocation =
              '${place.street}, ${place.subLocality}, ${place.locality}';
        });
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الحصول على الموقع', isError: true);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF379777),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF379777),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF379777),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _submitTrip() {
    // التحقق من الخطوات
    if (_tripSteps.isEmpty) {
      _showSnackBar('يرجى إضافة خطوة واحدة على الأقل', isError: true);
      return;
    }
    
    for (var step in _tripSteps) {
      if (step.titleController.text.isEmpty) {
        _showSnackBar('يرجى ملء عنوان جميع الخطوات', isError: true);
        return;
      }
    }

    // إنشاء خدمة جديدة وإضافتها للـ provider
    final servicesProvider = Provider.of<ServicesProvider>(context, listen: false);
    
    final newService = ServiceItem(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      title: _tripNameController.text,
      description: _descriptionController.text.isNotEmpty 
          ? _descriptionController.text 
          : 'خدمة مخصصة من إنشاء المستخدم',
      category: _selectedCategory!,
      steps: '(${_tripSteps.length} ${_tripSteps.length == 1 ? "خطوة" : "خطوات"})',
      author: widget.userName,
      source: 'خدمة مخصصة',
      rating: 0.0,
      reviewCount: 0,
      views: 0,
      isSaved: false,
    );
    
    servicesProvider.addUserService(newService);
    
    _showSnackBar('تم إضافة المشوار بنجاح ✨');
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: const Color(0xFF379777),
          selectionColor: const Color(0xFF379777).withOpacity(0.3),
          selectionHandleColor: const Color(0xFF379777),
        ),
      ),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: const Color(0xFFFAFAFA),
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildFirstPage(),
                    _buildSecondPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          _currentStep == 0 ? Icons.arrow_back_ios : Icons.arrow_back_ios,
          color: const Color(0xFF379777),
        ),
        onPressed: () async {
          if (_currentStep == 1) {
            _previousStep();
          } else {
            if (await _onWillPop()) {
              Navigator.pop(context);
            }
          }
        },
      ),
      title: const Text(
        'إضافة مشوار جديد',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Step 1
          Expanded(
            child: _buildStepIndicator(
              stepNumber: 1,
              title: 'المعلومات الأساسية',
              isActive: _currentStep == 0,
              isCompleted: _currentStep > 0,
            ),
          ),
          
          // خط الربط
          Expanded(
            flex: 0,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  height: 2,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _currentStep > 0
                            ? const Color(0xFF379777)
                            : Colors.grey.shade300,
                        _currentStep > 0
                            ? const Color(0xFF379777)
                            : Colors.grey.shade300,
                      ],
                      stops: [_progressController.value, _progressController.value],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Step 2
          Expanded(
            child: _buildStepIndicator(
              stepNumber: 2,
              title: 'الخطوات',
              isActive: _currentStep == 1,
              isCompleted: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? const Color(0xFF379777)
                : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isActive
                  ? const Color(0xFF379777)
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF379777).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.grey.shade400,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF379777) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstPage() {
    return Stack(
      children: [
        Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCard(
                  title: 'المعلومات الأساسية',
                  icon: Icons.info_outline,
                  children: [
                    _buildSectionTitle('اسم المشوار'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _tripNameController,
                      hintText: 'مثال: تجديد البطاقة الشخصية',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم المشوار';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('القسم'),
                    const SizedBox(height: 10),
                    _buildDropdown(
                      value: _selectedCategory,
                      items: _categories,
                      hint: 'اختر القسم',
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: 'الموقع',
                  icon: Icons.location_on_outlined,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildSectionTitle('المدينة'),
                              const SizedBox(height: 10),
                              _buildDropdown(
                                value: _selectedCity,
                                items: _selectedGovernorate != null
                                    ? _governoratesAndCities[_selectedGovernorate!]!
                                    : [],
                                hint: 'اختر المدينة',
                                enabled: _selectedGovernorate != null,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCity = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildSectionTitle('المحافظة'),
                              const SizedBox(height: 10),
                              _buildDropdown(
                                value: _selectedGovernorate,
                                items: _governoratesAndCities.keys.toList(),
                                hint: 'اختر المحافظة',
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGovernorate = value;
                                    _selectedCity = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('اسم المكان'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _placeNameController,
                      hintText: 'مثال: مكتب السجل المدني',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم المكان';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('الموقع الحالي (اختياري)'),
                    const SizedBox(height: 10),
                    _buildLocationField(),
                  ],
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: 'التفاصيل',
                  icon: Icons.description_outlined,
                  children: [
                    _buildSectionTitle('تاريخ الرحلة'),
                    const SizedBox(height: 10),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('وصف المشوار'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'اكتب تفاصيل المشوار... (اختياري)',
                      maxLines: 5,
                      required: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF379777).withOpacity(0.1),
                        const Color(0xFF379777).withOpacity(0.05),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF379777).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF379777),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'منشئ المشوار',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF379777),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildCard(
                  title: 'المرفقات',
                  icon: Icons.attach_file,
                  subtitle: 'اختياري - حد أقصى 5 ميجا',
                  children: [
                    _buildFilesSection(),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // زر التالي
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFAFAFA).withOpacity(0),
                  const Color(0xFFFAFAFA),
                  const Color(0xFFFAFAFA),
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF379777),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF379777).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'التالي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF379777),
                      const Color(0xFF379777).withOpacity(0.8),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF379777).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'خطوات المشوار',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'أضف الخطوات والأوراق المطلوبة',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.list_alt_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // قائمة الخطوات
              if (_tripSteps.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tripSteps.length,
                  itemBuilder: (context, index) {
                    return _buildStepCard(index);
                  },
                ),

              const SizedBox(height: 16),

              // زر إضافة خطوة
              _buildAddStepButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),

        // زر حفظ المشوار
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFAFAFA).withOpacity(0),
                  const Color(0xFFFAFAFA),
                  const Color(0xFFFAFAFA),
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF379777),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF379777).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'حفظ المشوار',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF379777).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_list_numbered_rounded,
              size: 48,
              color: const Color(0xFF379777),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد خطوات بعد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة الخطوات والأوراق المطلوبة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(int index) {
    final step = _tripSteps[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF379777).withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeStep(index),
                ),
                Row(
                  children: [
                    Text(
                      'الخطوة ${index + 1}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF379777),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF379777),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSectionTitle('عنوان الخطوة'),
                const SizedBox(height: 10),
                TextField(
                  controller: step.titleController,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'مثال: تقديم طلب للحصول على البطاقة',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('الوصف والأوراق المطلوبة'),
                const SizedBox(height: 10),
                TextField(
                  controller: step.descriptionController,
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'مثال: صورة من البطاقة القديمة - صورة شخصية - إثبات سكن',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddStepButton() {
    return InkWell(
      onTap: _addStep,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF379777),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF379777).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF379777),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'إضافة خطوة جديدة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF379777),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF379777).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF379777),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF379777), width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item, textAlign: TextAlign.right),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      hint: Text(hint, textAlign: TextAlign.right),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      isExpanded: true,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                  : 'اختر التاريخ',
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate != null ? Colors.black : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.calendar_today, color: Color(0xFF379777)),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField() {
    return InkWell(
      onTap: _getCurrentLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                _currentLocation ?? 'اضغط للحصول على الموقع الحالي',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 14,
                  color: _currentLocation != null ? Colors.black : Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.location_on, color: Color(0xFF379777)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_selectedFiles.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeFile(index),
                    ),
                    Expanded(
                      child: Text(
                        file.name,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.attach_file, size: 18, color: Color(0xFF379777)),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.add),
            label: const Text('إضافة ملفات'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF379777),
              side: const BorderSide(color: Color(0xFF379777)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// Model للخطوة
class TripStep {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  TripStep({
    required this.titleController,
    required this.descriptionController,
  });
}