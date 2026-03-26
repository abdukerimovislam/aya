import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../../data/models/cycle_model.dart';
import '../../data/providers/cycle_provider.dart';
import '../../data/providers/wellness_provider.dart';
import '../../data/providers/medication_provider.dart'; // 🔥 Импорт трекера
import '../../core/utils/symptom_localization.dart';
import '../../l10n/app_localizations.dart';

class PdfService {

  // Фирменные цвета для PDF
  static const PdfColor primaryColor = PdfColor.fromInt(0xFF6B4EFF);
  static const PdfColor accentColor = PdfColor.fromInt(0xFFFF4E7E);

  /// 🔥 ТОЧКА ВХОДА
  static Future<void> generateReport(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final cycleProvider = Provider.of<CycleProvider>(context, listen: false);
    final wellnessProvider = Provider.of<WellnessProvider>(context, listen: false);
    final medProvider = Provider.of<MedicationProvider>(context, listen: false); // 🔥

    // 1. Собираем данные (за последние 90 дней)
    final List<SymptomLog> logs = [];
    final now = DateTime.now();

    for (int i = 0; i < 90; i++) {
      final date = now.subtract(Duration(days: i));
      final log = wellnessProvider.getLogForDate(date);
      final takenMeds = medProvider.getTakenForDay(date); // 🔥 Проверяем витамины

      // Фильтруем пустые дни (теперь учитываем и медикаменты)
      bool hasData = log.flow != FlowIntensity.none ||
          log.painSymptoms.isNotEmpty ||
          log.symptoms.isNotEmpty ||
          (log.temperature != null && log.temperature! > 0) ||
          (log.notes != null && log.notes!.trim().isNotEmpty) ||
          log.hadSex ||
          log.ovulationTest != OvulationTestResult.none ||
          log.mucus != CervicalMucusType.none ||
          takenMeds.isNotEmpty; // 🔥 Если выпила витаминку — день важен для отчета

      if (hasData) {
        logs.add(log);
      }
    }

    if (logs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.msgExportEmpty)),
        );
      }
      return;
    }

    // 2. Вызываем генератор
    try {
      await PdfService().generateMedicalReport(
        logs: logs,
        cycleProvider: cycleProvider,
        medProvider: medProvider, // 🔥 Передаем провайдер
        l10n: l10n,
      );
    } catch (e) {
      debugPrint("Error generating PDF: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.msgExportError}: $e')),
        );
      }
    }
  }

  // --- ЛОГИКА ГЕНЕРАЦИИ PDF ---

  Future<void> generateMedicalReport({
    required List<SymptomLog> logs,
    required CycleProvider cycleProvider,
    required MedicationProvider medProvider, // 🔥
    required AppLocalizations l10n,
    String userName = "",
  }) async {
    final pdf = pw.Document();

    pw.Font fontRegular;
    pw.Font fontBold;

    try {
      fontRegular = await PdfGoogleFonts.openSansRegular();
      fontBold = await PdfGoogleFonts.openSansBold();
    } catch (e) {
      debugPrint("Offline mode: Using fallback fonts. Error: $e");
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    logs.sort((a, b) => a.date.compareTo(b.date));

    final totalLogs = logs.length;
    final painDays = logs.where((l) => l.painSymptoms.isNotEmpty).length;
    final startDate = logs.first.date;
    final endDate = logs.last.date;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (pw.Context context) {
          return [
            // 1. ШАПКА
            _buildMedicalHeader(userName, startDate, endDate, fontBold, fontRegular, l10n),
            pw.SizedBox(height: 20),

            if (cycleProvider.isCOCEnabled || cycleProvider.isTTCMode)
              _buildModeBadge(cycleProvider, fontBold, l10n),

            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.SizedBox(height: 10),

            // 2. СВОДКА
            pw.Text(l10n.pdfClinicalSummary.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 12, letterSpacing: 1.0, color: primaryColor)),
            pw.SizedBox(height: 10),
            _buildClinicalSummaryGrid(
                cycleProvider.cycleLength,
                cycleProvider.avgPeriodDuration,
                painDays,
                totalLogs,
                fontRegular,
                fontBold,
                l10n
            ),

            pw.SizedBox(height: 20),

            // 🔥 3. ПРЕПАРАТЫ И ВИТАМИНЫ (НОВЫЙ БЛОК)
            if (medProvider.activeMedications.isNotEmpty) ...[
              pw.Text(l10n.pdfMedicationRegistry.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 12, letterSpacing: 1.0, color: primaryColor)),
              pw.SizedBox(height: 8),
              _buildMedicationRegistry(medProvider, fontRegular, fontBold),
              pw.SizedBox(height: 20),
            ],

            // 4. ТАБЛИЦА
            pw.Text(l10n.pdfDetailedLogs.toUpperCase(), style: pw.TextStyle(font: fontBold, fontSize: 12, letterSpacing: 1.0, color: primaryColor)),
            pw.SizedBox(height: 10),
            _buildStrictTable(logs, cycleProvider, medProvider, fontRegular, fontBold, l10n),

            pw.SizedBox(height: 20),

            // 5. ДИСКЛЕЙМЕР
            pw.Divider(thickness: 0.5, color: PdfColors.grey400),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                l10n.pdfDisclaimer,
                style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ayla_Medical_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}',
    );
  }

  // --- WIDGETS ---

  pw.Widget _buildMedicalHeader(String name, DateTime start, DateTime end, pw.Font bold, pw.Font regular, AppLocalizations l10n) {
    final now = DateTime.now();
    final safeName = name.trim().isEmpty ? l10n.pdfDefaultPatient : name;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(l10n.pdfReportTitle.toUpperCase(), style: pw.TextStyle(font: bold, fontSize: 22, color: primaryColor)),
            pw.SizedBox(height: 4),
            pw.Text(l10n.pdfPeriodRange(DateFormat('MMM dd, yyyy').format(start), DateFormat('MMM dd, yyyy').format(end)), style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('${l10n.pdfPatient}: $safeName', style: pw.TextStyle(font: bold, fontSize: 12)),
            pw.SizedBox(height: 2),
            pw.Text('${l10n.pdfGenerated}: ${DateFormat('dd.MM.yyyy').format(now)}', style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey600)),
          ],
        )
      ],
    );
  }

  pw.Widget _buildMedicationRegistry(MedicationProvider provider, pw.Font regular, pw.Font bold) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 5,
      children: provider.activeMedications.map((med) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        // 🔥 УБРАН med.iconStr ЧТОБЫ ИЗБЕЖАТЬ КРАША ШРИФТА (Emoji fallback error)
        child: pw.Text("${med.name}: ${med.dosage}", style: pw.TextStyle(font: regular, fontSize: 9)),
      )).toList(),
    );
  }

  pw.Widget _buildModeBadge(CycleProvider cycle, pw.Font bold, AppLocalizations l10n) {
    String text = "";
    PdfColor textColor = primaryColor;
    PdfColor bgColor = const PdfColor.fromInt(0xFFF0EDFF);
    PdfColor borderColor = const PdfColor.fromInt(0xFFD3C9FF);

    if (cycle.isCOCEnabled) {
      text = l10n.pdfModeCoc;
      textColor = const PdfColor.fromInt(0xFF00B4D8);
      bgColor = const PdfColor.fromInt(0xFFE5F7FA);
      borderColor = const PdfColor.fromInt(0xFFB2EBF4);
    } else if (cycle.isTTCMode) {
      text = l10n.pdfModeTtc;
      textColor = accentColor;
      bgColor = const PdfColor.fromInt(0xFFFFEAF0);
      borderColor = const PdfColor.fromInt(0xFFFFB3C6);
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: borderColor),
      ),
      child: pw.Text(text.toUpperCase(), style: pw.TextStyle(font: bold, fontSize: 9, color: textColor)),
    );
  }

  pw.Widget _buildClinicalSummaryGrid(int cycleLen, int periodLen, int painDays, int totalDays, pw.Font regular, pw.Font bold, AppLocalizations l10n) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
        color: PdfColors.grey50,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _medicalMetric(l10n.pdfAvgCycle, "$cycleLen ${l10n.unitDays}", bold, regular),
          _medicalMetric(l10n.pdfAvgPeriod, "$periodLen ${l10n.unitDays}", bold, regular),
          _medicalMetric(
              l10n.pdfPainReported,
              totalDays > 0 ? "${((painDays/totalDays)*100).toStringAsFixed(1)}%" : "0%",
              bold,
              regular,
              isWarning: totalDays > 0 && painDays > totalDays * 0.3
          ),
        ],
      ),
    );
  }

  pw.Widget _medicalMetric(String label, String value, pw.Font bold, pw.Font regular, {bool isWarning = false}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label.toUpperCase(), style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 16, color: isWarning ? accentColor : PdfColors.black)),
      ],
    );
  }

  pw.Widget _buildStrictTable(List<SymptomLog> logs, CycleProvider cycleProvider, MedicationProvider medProvider, pw.Font regular, pw.Font bold, AppLocalizations l10n) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(45), // Date
        1: const pw.FixedColumnWidth(25), // CD
        2: const pw.FixedColumnWidth(30), // BBT
        3: const pw.FixedColumnWidth(35), // Flow
        4: const pw.FlexColumnWidth(2),   // Symptoms
        5: const pw.FlexColumnWidth(1.2), // Medications 🔥
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: primaryColor),
          children: [
            _th(l10n.pdfTableDate.toUpperCase(), bold, color: PdfColors.white),
            _th(l10n.pdfTableCD.toUpperCase(), bold, color: PdfColors.white),
            _th(l10n.pdfTableBBT.toUpperCase(), bold, color: PdfColors.white),
            _th(l10n.pdfFlowShort.toUpperCase(), bold, color: PdfColors.white),
            _th(l10n.pdfClinicalSymptoms.toUpperCase(), bold, color: PdfColors.white),
            _th(l10n.pdfMedicationShort.toUpperCase(), bold, color: PdfColors.white),
          ],
        ),
        // Rows
        ...List.generate(logs.length, (index) {
          final log = logs[index];
          final isEven = index % 2 == 0;
          final takenMeds = medProvider.getTakenNamesForDay(log.date); // 🔥 Получаем названия

          String cd = cycleProvider.getCycleDayFromDate(log.date).toString();

          List<String> symptoms = [];
          symptoms.addAll(log.painSymptoms);
          symptoms.addAll(log.symptoms);

          if (log.hadSex) symptoms.add(log.protectedSex ? l10n.pdfSymptomSexProtected : l10n.pdfSymptomSexUnprotected);
          if (log.ovulationTest != OvulationTestResult.none) {
            symptoms.add('${l10n.lblTest}: ${_lhShort(log.ovulationTest, l10n)}');
          }

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: isEven ? PdfColors.white : PdfColors.grey100),
            children: [
              _td(DateFormat('dd.MM.yy').format(log.date), regular),
              _td(cd, bold, align: pw.TextAlign.center, color: primaryColor),
              _td((log.temperature != null && log.temperature! > 0) ? "${log.temperature}°" : "-", regular, align: pw.TextAlign.center),
              _td(_flowShort(log.flow, l10n), bold, align: pw.TextAlign.center, color: accentColor),
              _td(localizeSymptomTokens(symptoms, l10n).join(", "), regular, fontSize: 8),
              _td(takenMeds.join(", "), regular, fontSize: 7, color: primaryColor), // 🔥 Вывод медикаментов
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _th(String text, pw.Font font, {PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 8, fontWeight: pw.FontWeight.bold, color: color), textAlign: pw.TextAlign.center),
    );
  }

  pw.Widget _td(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left, double fontSize = 9, PdfColor color = PdfColors.black}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: fontSize, color: color), textAlign: align),
    );
  }

  String _flowShort(FlowIntensity f, AppLocalizations l10n) {
    switch (f) {
      case FlowIntensity.light: return l10n.flowLight;
      case FlowIntensity.medium: return l10n.pdfFlowMedium;
      case FlowIntensity.heavy: return l10n.flowHeavy;
      default: return "-";
    }
  }

  String _lhShort(OvulationTestResult r, AppLocalizations l10n) {
    switch (r) {
      case OvulationTestResult.negative:
        return l10n.pdfLhNegativeShort;
      case OvulationTestResult.positive:
        return l10n.pdfLhPositiveShort;
      case OvulationTestResult.peak:
        return l10n.pdfLhPeakShort;
      default:
        return "";
    }
  }
}
