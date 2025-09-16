import 'package:stacked_services/stacked_services.dart';
import '../ui/bottom_sheets/notice/notice_sheet.dart';
import '../ui/bottom_sheets/analysis_results/analysis_results_sheet.dart';
import 'app.dart';

void setupBottomSheetUi() {
  final bottomSheetService = BottomSheetService();

  final builders = <BottomSheetType, SheetBuilder>{
    BottomSheetType.notice: (context, request, completer) =>
        NoticeSheet(completer: completer, request: request),
    BottomSheetType.analysisResults: (context, request, completer) =>
        AnalysisResultsSheet(completer: completer, request: request),
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}
