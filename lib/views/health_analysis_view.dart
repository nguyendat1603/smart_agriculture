import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../viewmodels/health_analysis_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../services/ai_analysis_service.dart';
import '../l10n/app_translations.dart';

class HealthAnalysisView extends StatefulWidget {
  const HealthAnalysisView({super.key});

  @override
  State<HealthAnalysisView> createState() => _HealthAnalysisViewState();
}

class _HealthAnalysisViewState extends State<HealthAnalysisView> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _scanAnimation = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !context.mounted) return;

    final viewModel = context.read<HealthAnalysisViewModel>();
    viewModel.setImage(File(image.path));
    
    _scanAnimationController.repeat();
    await viewModel.analyzeImage();
    if (!mounted) return;
    _scanAnimationController.stop();
    _scanAnimationController.reset();
  }

  void _saveReport() {
    // Ghi chú: Kết nối với backend để lưu báo cáo (vd: Supabase)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Report saved successfully!'.tr(context))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "AgriPulse AI".tr(context),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<HealthAnalysisViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Health Analysis".tr(context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onBackground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "AI automated detail analysis".tr(context),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Hero: AI Scanning Image
                _buildHeroImage(viewModel),

                const SizedBox(height: 20),

                if (viewModel.state == AnalysisState.loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                if (viewModel.state == AnalysisState.error)
                  Center(
                    child: Text(
                      '${'Error'.tr(context)}: ${viewModel.errorMessage}',
                      style: const TextStyle(color: AppTheme.error),
                    ),
                  ),

                if (viewModel.state == AnalysisState.success && viewModel.result != null)
                  _buildAnalysisResults(context, viewModel.result!),

                const SizedBox(height: 32),

                // Actions
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroImage(HealthAnalysisViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Image
          if (viewModel.selectedImage != null)
            Positioned.fill(
              child: Image.file(
                viewModel.selectedImage!,
                fit: BoxFit.cover,
              ),
            )
          else
            Positioned.fill(
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCaW-mjUAtKl-82uDWhUoqRq4k7ZQEuj8NWt0mNgFeVZPE8EtPMengH5V2k1yVBJKtiqrWtmW3EcZvniFnfER_HpbRcx443qqZkb0dHYPOVnNoBG8rBF3o65NxPEwrshiEjmYK7uQN3hf1cQTWfoojU6LIel5Ih3BFGaz2_mrsOM06JIlxQc3kHm2jlfpXfVJHzysCBZw2-Zp_JTmaj8oDZOJMQ_oXZTg052iph3e-cpom5SD1IfKhjErAH71AURZtNyopJqTBKhJQs',
                fit: BoxFit.cover,
              ),
            ),
          
          // Heatmap Highlights (show if success or loading)
          if (viewModel.state == AnalysisState.loading || viewModel.state == AnalysisState.success)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.1),
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      left: 80,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [AppTheme.error.withValues(alpha: 0.5), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // AI Match Score
          if (viewModel.state == AnalysisState.success && viewModel.result != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.center_focus_strong, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '${'AI Match'.tr(context)}: ${viewModel.result!.matchPercentage}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Scan line animation
          if (viewModel.state == AnalysisState.loading)
            AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return Positioned(
                  top: _scanAnimation.value * 240, // 240 is hero height
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryContainer.withValues(alpha: 0.6),
                          blurRadius: 12,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults(BuildContext context, AIAnalysisResult result) {
    final lang = context.watch<SettingsViewModel>().currentLanguage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Diagnostic Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceContainer),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Diagnosis".tr(context),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.diseaseName.get(lang),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, size: 16, color: AppTheme.onErrorContainer),
                    const SizedBox(width: 6),
                    Text(
                      result.severity.get(lang),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Insights & Advice Bento Grid
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Insights
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceContainer),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "AI INSIGHT".tr(context),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.aiInsight.get(lang),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Expert Advice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.secondaryContainer.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: AppTheme.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "EXPERT ADVICE".tr(context),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.expertAdvice.get(lang),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Recommendations Checklist
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceContainer),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Action Plan".tr(context),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ...result.actionPlan.get(lang).map((action) {
                final parts = action.split('|');
                final title = parts.isNotEmpty ? parts[0] : '';
                final desc = parts.length > 1 ? parts[1] : '';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.priority_high, color: AppTheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.4,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _pickImage(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_a_photo),
                const SizedBox(width: 8),
                Text(
                  "Take new photo".tr(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: _saveReport,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save),
                const SizedBox(width: 8),
                Text(
                  "Save report".tr(context),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
