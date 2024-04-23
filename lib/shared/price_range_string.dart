import 'package:syncfusion_flutter_sliders/sliders.dart';

String getPriceRangeString(SfRangeValues values, int minRange, int maxRange) {
  return "${values.start <= minRange ? '<' : ''}${values.start}kr til ${values.end >= maxRange ? '>' : ''}${values.end}kr";
}
