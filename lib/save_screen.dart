import 'package:flutter/material.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({super.key});

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  // Mock Data للمشاوير
  final List<Trip> _trips = [
    Trip(
      title: 'مسوغات العمل',
      date: 'الأربعاء 5 مايو',
      completedSteps: 1,
      totalSteps: 5,
      currentStep: '٥. بيريت التأمينات - مكتب التأمينات',
    ),
    Trip(
      title: 'مسوغات العمل',
      date: 'الأربعاء 5 مايو',
      completedSteps: 3,
      totalSteps: 5,
      currentStep: '٥. بيريت التأمينات - مكتب التأمينات',
    ),
    Trip(
      title: 'مسوغات العمل',
      date: 'الأربعاء 5 مايو',
      completedSteps: 5,
      totalSteps: 5,
      currentStep: '٥. بيريت التأمينات - مكتب التأمينات',
    ),
    Trip(
      title: 'مسوغات العمل',
      date: 'الأربعاء 5 مايو',
      completedSteps: 5,
      totalSteps: 5,
      currentStep: '٥. بيريت التأمينات - مكتب التأمينات',
    ),
    Trip(
      title: 'مسوغات العمل',
      date: 'الأربعاء 5 مايو',
      completedSteps: 2,
      totalSteps: 5,
      currentStep: '٥. بيريت التأمينات - مكتب التأمينات',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 👈 Theme
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: _trips.length,
                itemBuilder: (context, index) {
                  return _buildTripCard(_trips[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر إضافة مشوار مع الأنيميشن
          _AnimatedButton(
            text: 'اضافة مشوار',
            onTap: () {
              // TODO: إضافة مشوار جديد
            },
          ),

          // العنوان
          Text(
            'مشاويري',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color, // 👈 Theme
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return _AnimatedCard(
      onTap: () {
        // TODO: فتح تفاصيل المشوار
      },
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // الصف الأول: العنوان والدائرة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // دائرة التقدم
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: trip.completedSteps / trip.totalSteps,
                            strokeWidth: 6,
                            backgroundColor: const Color(0xFFE8F5E9),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF379777),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${trip.completedSteps}/${trip.totalSteps}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF379777),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // العنوان والتاريخ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          trip.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color, // 👈 Theme
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // الخطوة الحالية
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF8F8F8), // 👈 Theme
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      trip.currentStep,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7), // 👈 Theme
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 👇 نفس الـ Animated Widgets من HomePage

class _AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  
  const _AnimatedButton({
    required this.text,
    required this.onTap,
  });
  
  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isPressed 
              ? const Color(0xFF379777) 
              : const Color(0xFFB2E4D0),
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isPressed ? [] : [
            BoxShadow(
              color: const Color(0xFF379777).withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: _isPressed ? Colors.white : const Color(0xFF379777),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  
  const _AnimatedCard({
    required this.child,
    this.onTap,
    this.margin,
  });
  
  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap!();
      } : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: widget.margin,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // 👈 Theme
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed 
                    ? const Color(0xFF379777).withOpacity(0.2)
                    : Colors.black.withOpacity(0.08),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 6 : 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// Model للمشوار
class Trip {
  final String title;
  final String date;
  final int completedSteps;
  final int totalSteps;
  final String currentStep;

  Trip({
    required this.title,
    required this.date,
    required this.completedSteps,
    required this.totalSteps,
    required this.currentStep,
  });
}