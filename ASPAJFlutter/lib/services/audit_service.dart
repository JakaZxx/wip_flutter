import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';

class AuditService {
  static String? _logPath;

  static Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logPath = '${directory.path}/layout_audit.log';
      debugPrint('AuditService initialized. Log path: $_logPath');
    } catch (e) {
      debugPrint('AuditService failed to get log path: $e');
    }

    // Original error handler
    final originalOnError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      // Pass to original handler first (so it shows in console/dev tools)
      originalOnError?.call(details);

      // Check if it's a layout overflow error
      final bool isOverflow = details.exceptionAsString().contains('A RenderFlex overflowed');
      
      if (isOverflow) {
        _reportOverflow(details);
      }
    };
  }

  static void _reportOverflow(FlutterErrorDetails details) {
    try {
      final String exception = details.exceptionAsString();
      final List<String> lines = exception.split('\n');
      
      // Extract overflow amount and axis
      String overflowInfo = 'Unknown overflow';
      for (var line in lines) {
        if (line.contains('overflowed by')) {
          overflowInfo = line.trim();
          break;
        }
      }

      // Create a structured message for the AI audit
      final String timestamp = DateTime.now().toIso8601String();
      final String auditLog = '''
[LAYOUT_AUDIT_ALARM]
TIMESTAMP: $timestamp
SCREEN_CONTEXT: ${details.context?.toString() ?? 'Generic Layout'}
OVERFLOW_DETAIL: $overflowInfo
WIDGET_SUMMARY: ${details.library ?? 'UI Library'}
FULL_EXCEPTION: ${exception.substring(0, exception.length > 500 ? 500 : exception.length)}
----------------------------------------------
''';

      // 1. Log to console
      debugPrint(auditLog);

      // 2. Persist to local file for AI to read
      _writeToFile(auditLog);
      
    } catch (e) {
      debugPrint('AuditService failed to report: $e');
    }
  }

  static void _writeToFile(String log) {
    if (_logPath == null) return;
    try {
      final file = File(_logPath!);
      file.writeAsStringSync(log, mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }
}
