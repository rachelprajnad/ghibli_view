// Import package untuk pengujian widget Flutter
import 'package:flutter_test/flutter_test.dart';
// Import file utama aplikasi
import 'package:ghibli_view/main.dart';

void main() {
  // Test unit untuk memastikan judul muncul di halaman utama
  testWidgets(
    'Cek apakah judul "Studio Ghibli Films" muncul di halaman utama',
    (WidgetTester tester) async {
      // Membangun aplikasi GhibliApp di dalam environment test
      await tester.pumpWidget(const GhibliApp());

      // Memverifikasi bahwa teks 'Studio Ghibli Films' ditemukan di tampilan
      expect(find.text('Studio Ghibli Films'), findsOneWidget);
    },
  );
}
