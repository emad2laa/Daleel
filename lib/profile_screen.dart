import 'dart:ui';
import 'package:daleel/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 👈 Theme
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildMenuSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // صورة البروفايل
          GestureDetector(
            onTap: () {
              _showImagePickerDialog();
            },
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF379777),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF379777).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundColor: Color(0xFFB2E4D0),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF379777),
                    ),
                  ),
                ),
                // أيقونة الكاميرا
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF379777),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor, // 👈 Theme
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // اسم المستخدم
          Text(
            'عماد',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color, // 👈 Theme
            ),
          ),

          const SizedBox(height: 4),

          // التاريخ
          Text(
            'اليوم الأربعاء 5 مايو',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // الحساب
          _buildMenuItem(
            title: 'الحساب',
            icon: Icons.person_outline,
            onTap: () {
              // TODO: Navigate to account settings
            },
          ),

          const SizedBox(height: 12),

          // تعديل الحساب
          _buildMenuItem(
            title: 'تعديل الحساب',
            icon: Icons.edit_outlined,
            onTap: () {
              // TODO: Navigate to edit account
            },
          ),

          const SizedBox(height: 12),

          // الإشعارات مع Toggle
          _buildToggleMenuItem(
            title: 'الإشعارات',
            icon: Icons.notifications_outlined,
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // الوضع الليلي مع Toggle
          _buildToggleMenuItem(
            title: 'الوضع الليلي',
            icon: Icons.dark_mode_outlined,
            value: context.watch<ThemeProvider>().isDarkMode,
            onChanged: (value) {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),

          const SizedBox(height: 12),

          // المساعدة
          _buildMenuItem(
            title: 'المساعدة',
            icon: Icons.help_outline,
            onTap: () {
              // TODO: Navigate to help
            },
          ),

          const SizedBox(height: 12),

          // الوصف
          _buildMenuItem(
            title: 'الوصف',
            icon: Icons.info_outline,
            onTap: () {
              // TODO: Navigate to about
            },
          ),

          const SizedBox(height: 12),

          // تسجيل خروج
          _buildMenuItem(
            title: 'تسجيل خروج',
            icon: Icons.logout,
            onTap: () {
              _showLogoutDialog();
            },
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return _AnimatedCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // السهم
            Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: isLogout ? Colors.red.shade400 : Colors.grey.shade600,
            ),

            // العنوان والأيقونة
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isLogout 
                          ? Colors.red.shade600 
                          : Theme.of(context).textTheme.bodyLarge?.color, // 👈 Theme
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    icon,
                    size: 24,
                    color: isLogout
                        ? Colors.red.shade600
                        : const Color(0xFF379777),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _AnimatedCard(
      onTap: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Toggle Switch
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF379777),
              activeTrackColor: const Color(0xFFB2E4D0),
            ),

            // العنوان والأيقونة
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color, // 👈 Theme
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    icon,
                    size: 24,
                    color: const Color(0xFF379777),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎨 Dialog لاختيار الصورة مع Blur
  void _showImagePickerDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // 👈 Theme
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                
                // الأيقونة
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB2E4D0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 28,
                    color: Color(0xFF379777),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // العنوان
                Text(
                  'تغيير صورة الحساب',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color, // 👈 Theme
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // الوصف
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'اختر مصدر الصورة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // الخيارات
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // خيار الكاميرا
                      _AnimatedDialogButton(
                        icon: Icons.camera_alt_outlined,
                        title: 'التقاط صورة',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: فتح الكاميرا
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // خيار المعرض
                      _AnimatedDialogButton(
                        icon: Icons.photo_library_outlined,
                        title: 'اختيار من المعرض',
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: فتح المعرض
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // زر الإلغاء
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, // 👈 Theme
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🚪 Dialog لتأكيد تسجيل الخروج مع Blur
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // 👈 Theme
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                
                // أيقونة التحذير
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 28,
                    color: Colors.red.shade600,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // العنوان
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color, // 👈 Theme
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // الرسالة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // الأزرار
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      // زر الإلغاء
                      Expanded(
                        child: _AnimatedDialogButton(
                          icon: Icons.close,
                          title: 'إلغاء',
                          onTap: () => Navigator.pop(context),
                          isSecondary: true,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // زر التأكيد
                      Expanded(
                        child: _AnimatedDialogButton(
                          icon: Icons.logout,
                          title: 'تسجيل خروج',
                          onTap: () {
                            Navigator.pop(context);
                            // TODO: تسجيل الخروج
                          },
                          isDanger: true,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🎨 Animated Card Widget
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
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap!();
            }
          : null,
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
                    : Colors.black.withOpacity(0.06),
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

// 🎨 Animated Dialog Button
class _AnimatedDialogButton extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDanger;
  final bool isSecondary;

  const _AnimatedDialogButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
    this.isSecondary = false,
  });

  @override
  State<_AnimatedDialogButton> createState() => _AnimatedDialogButtonState();
}

class _AnimatedDialogButtonState extends State<_AnimatedDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (widget.isDanger) return Colors.red.shade600;
      if (widget.isSecondary) return Colors.grey.shade700;
      return const Color(0xFF379777);
    }

    Color getBgColor() {
      if (_isPressed) {
        return getColor();
      }
      if (widget.isDanger) return Colors.red.shade50;
      if (widget.isSecondary) return Colors.grey.shade100;
      return const Color(0xFFB2E4D0);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: getColor().withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _isPressed ? Colors.white : getColor(),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              widget.icon,
              size: 20,
              color: _isPressed ? Colors.white : getColor(),
            ),
          ],
        ),
      ),
    );
  }
}