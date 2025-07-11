// Abaikan peringatan terkait penggunaan key dan prefer_const
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

// Import library bawaan Dart untuk encoding/decoding JSON
import 'dart:convert';

// Import package untuk menampilkan gambar dari internet dengan cache
import 'package:cached_network_image/cached_network_image.dart';
// Import package Flutter untuk membuat tampilan UI
import 'package:flutter/material.dart';
// Import package HTTP untuk melakukan request ke API
import 'package:http/http.dart' as http;
// Import package SharedPreferences untuk menyimpan data lokal (seperti session)
import 'package:shared_preferences/shared_preferences.dart';
// Import package untuk membuka URL di browser atau aplikasi lain
import 'package:url_launcher/url_launcher.dart';

// Fungsi utama aplikasi Flutter
void main() {
  runApp(
    const GhibliApp(),
  ); // Menjalankan widget GhibliApp sebagai aplikasi utama
}

// Membuat class GhibliApp yang merupakan widget StatelessWidget
class GhibliApp extends StatelessWidget {
  const GhibliApp(); // Constructor const tanpa parameter

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Widget utama aplikasi Flutter
      title: 'Studio Ghibli Films', // Judul aplikasi
      theme: ThemeData(
        // Tema aplikasi
        primarySwatch: Colors.deepPurple, // Warna utama aplikasi (ungu tua)
        scaffoldBackgroundColor: const Color(
          0xFFF2F2F7,
        ), // Warna latar belakang utama
        fontFamily: 'Arial', // Font default aplikasi
      ),
      debugShowCheckedModeBanner:
          false, // Menghilangkan banner debug merah di pojok kanan atas
      home:
          const SplashScreen(), // Halaman pertama yang ditampilkan (splash screen)
    );
  }
}

// -----------------------------
// SPLASH SCREEN
// -----------------------------
class SplashScreen extends StatelessWidget {
  // Membuat halaman splash screen
  const SplashScreen(); // Constructor tanpa parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Struktur dasar tampilan
      backgroundColor: const Color(
        0xFFFFF4EC,
      ), // Warna latar belakang splash screen
      body: Center(
        // Isi halaman dipusatkan
        child: Column(
          // Mengatur elemen dalam kolom secara vertikal
          mainAxisAlignment:
              MainAxisAlignment.center, // Elemen diposisikan di tengah vertikal
          children: [
            Image.asset(
              'images/ghibli_logo.png',
              height: 120,
            ), // Menampilkan logo Ghibli
            const SizedBox(height: 24), // Jarak vertikal
            const Text(
              // Judul utama
              'STUDIO GHIBLI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12), // Jarak vertikal
            const Padding(
              // Teks deskripsi dengan padding
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Explore the legendary films of Studio Ghibli filled with imagination and wonder.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 28), // Jarak vertikal
            ElevatedButton(
              // Tombol untuk masuk ke halaman berikutnya
              onPressed: () {
                // Ketika tombol ditekan
                Navigator.pushReplacement(
                  // Ganti halaman menjadi HomePage
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                // Gaya tombol
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                // Teks pada tombol
                'Get Started',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------
// HOME PAGE
// -----------------------------
class HomePage extends StatefulWidget {
  // Halaman utama aplikasi
  const HomePage(); // Constructor tanpa parameter

  @override
  State<HomePage> createState() => _HomePageState(); // Menghubungkan dengan state-nya
}

class _HomePageState extends State<HomePage> {
  // State untuk HomePage
  List films = []; // List untuk menyimpan data film
  List filteredFilms = []; // List untuk menyimpan hasil filter pencarian
  Set<String> favoriteIds = {}; // Set untuk menyimpan ID film favorit
  bool isLoading = true; // Status loading saat data diambil
  TextEditingController searchController =
      TextEditingController(); // Controller untuk input pencarian
  int _selectedIndex = 1; // Index tab yang dipilih, default 1 (Home page aktif)

  @override
  void initState() {
    // Fungsi yang dijalankan pertama kali saat state dibuat
    super.initState();
    fetchFilms(); // Memanggil fungsi untuk mengambil data film dari API
    loadFavorites(); // Memanggil fungsi untuk memuat data favorit dari penyimpanan lokal
  }

  Future<void> fetchFilms() async {
    // Fungsi async untuk mengambil data film dari API
    final url = Uri.parse(
      'https://ghibliapi.vercel.app/films',
    ); // URL endpoint API
    final response = await http.get(url); // Mengirim request GET ke API
    if (response.statusCode == 200) {
      // Jika respons berhasil (status 200)
      final data = json.decode(
        response.body,
      ); // Decode response JSON menjadi list
      setState(() {
        films = data; // Simpan semua film ke variabel films
        filteredFilms = data; // Simpan juga ke filteredFilms (untuk pencarian)
        isLoading = false; // Set status loading menjadi false
      });
    } else {
      throw Exception('Failed to load films'); // Jika gagal, lempar exception
    }
  }

  Future<void> loadFavorites() async {
    // Fungsi async untuk memuat data favorit dari penyimpanan lokal
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences
    final ids =
        prefs.getStringList('favorites') ??
        []; // Mengambil list ID favorit, jika null maka kosong
    setState(() {
      favoriteIds = ids.toSet(); // Menyimpan ID favorit dalam bentuk Set
    });
  }

  Future<void> toggleFavorite(String id) async {
    // Fungsi untuk menambah/menghapus favorit
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan instance SharedPreferences
    setState(() {
      if (favoriteIds.contains(id)) {
        // Jika sudah ada di favorit
        favoriteIds.remove(id); // Hapus dari favorit
      } else {
        favoriteIds.add(id); // Tambah ke favorit
      }
      prefs.setStringList(
        'favorites',
        favoriteIds.toList(),
      ); // Simpan kembali ke SharedPreferences
    });
  }

  void filterFilms(String query) {
    // Fungsi untuk memfilter daftar film berdasarkan query pencarian
    final filtered =
        films.where((film) {
          // Memfilter list films
          final title =
              film['title']
                  .toString()
                  .toLowerCase(); // Mengambil judul film dan ubah jadi huruf kecil
          return title.contains(
            query.toLowerCase(),
          ); // Cek apakah judul mengandung query
        }).toList();
    setState(() {
      filteredFilms = filtered; // Update daftar film yang difilter
    });
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // Widget item navigasi bawah
    final isSelected =
        _selectedIndex == index; // Cek apakah item ini yang sedang aktif
    return GestureDetector(
      // Widget yang mendeteksi sentuhan
      onTap: () {
        // Ketika item diklik
        setState(() {
          _selectedIndex = index; // Update index yang dipilih
        });
        if (index == 0) {
          // Jika index 0, navigasi ke ProfilePage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          );
        } else if (index == 1) {
          // Stay on HomePage (tetap di halaman utama)
        } else if (index == 2) {
          // Jika index 2, navigasi ke CharacterPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CharacterPage()),
          );
        } else if (index == 3) {
          // Jika index 3, navigasi ke MerchandisePage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MerchandisePage(),
            ), // Navigasi ke MerchandisePage
          );
        }
      },
      child: Column(
        // Tampilan ikon dan label secara vertikal
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.deepPurple : Colors.black,
          ), // Ikon dengan warna sesuai status aktif
          const SizedBox(height: 4), // Jarak antara ikon dan teks
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
                  isSelected
                      ? Colors.deepPurple
                      : Colors.black, // Warna teks sesuai status aktif
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Struktur halaman utama
      floatingActionButton: FloatingActionButton(
        // Tombol melayang di kanan bawah
        onPressed: () {
          // Ketika tombol ditekan
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FavoritePage(),
            ), // Navigasi ke halaman FavoritePage
          );
        },
        backgroundColor: Colors.deepPurple, // Warna background tombol
        child: const Icon(Icons.favorite), // Ikon hati pada tombol
      ),
      body:
          isLoading // Jika masih loading data
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Tampilkan loading indicator
              : Column(
                // Jika sudah selesai loading
                children: [
                  Container(
                    // Bagian header dengan gradient
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        // Gradient warna ungu
                        colors: [Colors.deepPurple, Color(0xFF9575CD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                      children: [
                        const Text(
                          // Judul aplikasi
                          "Studio Ghibli Films 🎬",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12), // Jarak vertikal
                        TextField(
                          // Kolom pencarian
                          controller: searchController, // Controller input
                          onChanged: filterFilms, // Fungsi saat teks berubah
                          style: const TextStyle(
                            color: Colors.white,
                          ), // Warna teks input
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white24, // Warna latar input
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            hintText:
                                'Search for movie title...', // Placeholder teks
                            hintStyle: const TextStyle(
                              color: Colors.white70,
                            ), // Warna hint
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    // Widget yang mengisi ruang kosong di bawah header
                    child: GridView.builder(
                      // GridView untuk menampilkan daftar film
                      padding: const EdgeInsets.all(
                        12,
                      ), // Padding di sekitar grid
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        // Mengatur jumlah kolom grid
                        crossAxisCount:
                            MediaQuery.of(context).size.width >=
                                    1200 // Jika lebar layar >=1200
                                ? 4 // Tampilkan 4 kolom
                                : MediaQuery.of(context).size.width >=
                                    800 // Jika >=800
                                ? 3 // Tampilkan 3 kolom
                                : 2, // Jika lebih kecil, tampilkan 2 kolom
                        crossAxisSpacing: 12, // Jarak horizontal antar item
                        mainAxisSpacing: 12, // Jarak vertikal antar item
                        childAspectRatio: 0.68, // Rasio aspek item grid
                      ),
                      itemCount: filteredFilms.length, // Jumlah item di grid
                      itemBuilder: (context, index) {
                        // Fungsi untuk membangun setiap item
                        final film =
                            filteredFilms[index]; // Data film pada index ini
                        return buildFilmCard(film); // Widget kartu film
                      },
                    ),
                  ),
                ],
              ),
      bottomNavigationBar: Padding(
        // Navigasi bawah dengan padding
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 12,
        ), // Padding luar
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ), // Padding dalam
          decoration: BoxDecoration(
            color: Colors.grey[200], // Warna background navigasi
            borderRadius: BorderRadius.circular(30), // Sudut melengkung
          ),
          child: Row(
            // Baris item navigasi
            mainAxisAlignment:
                MainAxisAlignment.spaceAround, // Rata sebar antar item
            children: [
              _buildNavItem(Icons.person, "Profile", 0), // Item Profile
              _buildNavItem(Icons.home, "Home page", 1), // Item Home page
              _buildNavItem(Icons.face, "Character", 2), // Item Character
              _buildNavItem(Icons.store, "Merchandise", 3), // Item Merchandise
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFilmCard(Map film) {
    // Widget untuk menampilkan kartu film
    return Card(
      // Kartu material
      elevation: 4, // Bayangan kartu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Sudut melengkung kartu
      child: InkWell(
        // Area yang bisa ditekan
        borderRadius: BorderRadius.circular(12), // Sudut melengkung efek tekan
        onTap: () {
          // Ketika kartu ditekan
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FilmDetailPage(film: film),
            ), // Navigasi ke halaman detail film
          );
        },
        child: Column(
          // Isi kartu dalam kolom
          crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
          children: [
            Expanded(
              // Bagian gambar mengisi ruang
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12), // Sudut melengkung di atas
                ),
                child:
                    film['title'] ==
                            "Earwig and the Witch" // Jika judul Earwig
                        ? Image.asset(
                          'images/earwig.png', // Pakai gambar lokal
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                        : CachedNetworkImage(
                          // Jika bukan Earwig, pakai gambar online
                          imageUrl: film['image'] ?? '', // URL gambar
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder:
                              (context, url) => const Center(
                                child:
                                    CircularProgressIndicator(), // Loading indicator saat gambar dimuat
                              ),
                          errorWidget:
                              (context, url, error) => const Icon(
                                Icons.broken_image,
                                size: 60,
                              ), // Ikon error jika gagal load
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8), // Padding dalam
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
                children: [
                  Text(
                    film['title'], // Judul film
                    maxLines: 2, // Maksimal 2 baris
                    overflow:
                        TextOverflow.ellipsis, // Teks dipotong jika panjang
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ), // Teks tebal
                  ),
                  Text("Release: ${film['release_date']}"), // Tanggal rilis
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 16,
                      ), // Ikon bintang
                      const SizedBox(width: 4), // Jarak horizontal
                      Text(
                        (int.parse(film['rt_score']) / 10).toStringAsFixed(
                          1,
                        ), // Skor film dari 0-10
                      ),
                      const Spacer(), // Spasi fleksibel
                      IconButton(
                        // Tombol favorit
                        icon: Icon(
                          favoriteIds.contains(
                                film['id'],
                              ) // Cek apakah film favorit
                              ? Icons
                                  .favorite // Ikon hati penuh
                              : Icons.favorite_border, // Ikon hati kosong
                          color:
                              favoriteIds.contains(film['id']) // Warna ikon
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                        onPressed:
                            () => toggleFavorite(
                              film['id'],
                            ), // Aksi toggle favorit
                      ),
                    ],
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

// -----------------------------
// FAVORITES PAGE
// -----------------------------
class FavoritePage extends StatelessWidget {
  // Halaman favorit
  const FavoritePage(); // Constructor tanpa parameter

  Future<List<Map>> getFavoriteFilms() async {
    // Fungsi async untuk mengambil film favorit
    final prefs =
        await SharedPreferences.getInstance(); // Mendapatkan SharedPreferences
    final ids =
        prefs.getStringList('favorites') ??
        []; // Ambil daftar ID favorit, jika null kosong
    final url = Uri.parse(
      'https://ghibliapi.vercel.app/films',
    ); // Endpoint API film
    final response = await http.get(url); // Request GET ke API
    if (response.statusCode == 200) {
      // Jika berhasil
      final data = json.decode(response.body); // Decode JSON
      return List<Map>.from(
            data, // Konversi ke List<Map>
          )
          .where((film) => ids.contains(film['id']))
          .toList(); // Filter hanya film favorit
    } else {
      throw Exception('Failed to load films'); // Jika gagal, lempar exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Struktur halaman
      appBar: AppBar(
        title: const Text("My Favorites ❤️"), // Judul AppBar
        backgroundColor: Colors.deepPurple, // Warna AppBar
      ),
      body: FutureBuilder<List<Map>>(
        // FutureBuilder untuk menunggu data favorit
        future: getFavoriteFilms(), // Future yang dipanggil
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Jika masih loading
            return const Center(
              child: CircularProgressIndicator(),
            ); // Tampilkan loading indicator
          }
          final favorites = snapshot.data ?? []; // Data favorit
          if (favorites.isEmpty) {
            // Jika kosong
            return const Center(
              child: Text("No favorite films yet"),
            ); // Pesan tidak ada favorit
          }
          return ListView.builder(
            // ListView daftar film favorit
            padding: const EdgeInsets.all(12), // Padding sekitar list
            itemCount: favorites.length, // Jumlah item
            itemBuilder: (context, index) {
              // Builder untuk setiap item
              final film = favorites[index]; // Data film pada index
              return ListTile(
                // ListTile untuk setiap film
                leading:
                    film['title'] ==
                            "Earwig and the Witch" // Jika judul Earwig
                        ? Image.asset(
                          'images/earwig.png', // Gambar lokal
                          width: 50,
                          height: 80,
                        )
                        : CachedNetworkImage(
                          // Gambar online
                          imageUrl: film['image'],
                          width: 50,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                title: Text(film['title']), // Judul film
                subtitle: Text(
                  "Release: ${film['release_date']}",
                ), // Tanggal rilis
                trailing: const Icon(Icons.chevron_right), // Ikon panah kanan
                onTap: () {
                  // Ketika item ditekan
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => FilmDetailPage(
                            film: film,
                          ), // Navigasi ke detail film
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// -----------------------------
// DETAIL PAGE
// -----------------------------
class FilmDetailPage extends StatelessWidget {
  final Map film; // Data film yang ditampilkan
  const FilmDetailPage({
    required this.film,
  }); // Konstruktor dengan parameter wajib film

  String getYouTubeLink(String title) {
    // Mengambil link YouTube trailer berdasarkan judul
    final links = {
      // Map judul ke URL trailer YouTube
      'My Neighbor Totoro': 'https://www.youtube.com/watch?v=92a7Hj0ijLs',
      'Spirited Away': 'https://www.youtube.com/watch?v=ByXuk9QqQkk',
      'Howl\'s Moving Castle': 'https://www.youtube.com/watch?v=iwROgK94zcM',
      'Princess Mononoke': 'https://www.youtube.com/watch?v=4OiMOHRDs14',
      'Ponyo': 'https://www.youtube.com/watch?v=CqNUv0E_uXA',
      'Kiki\'s Delivery Service': 'https://www.youtube.com/watch?v=4bG17OYs-GA',
      'Castle in the Sky': 'https://www.youtube.com/watch?v=8ykEy-yPBFc',
      'The Wind Rises': 'https://www.youtube.com/watch?v=RzSpDgiFoyU',
      'Earwig and the Witch': 'https://www.youtube.com/watch?v=_PfhotgXEeQ',
    };
    return links[title] ??
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(title + " trailer")}'; // Default cari di YouTube
  }

  String? getMovieLink(String title) {
    // Mengambil link streaming film berdasarkan judul
    final links = {
      // Map judul ke URL streaming film
      'Castle in the Sky':
          'https://tv3.idlixku.com/movie/castle-in-the-sky-1986/',
      'Grave of the Fireflies':
          'https://tv3.idlixku.com/movie/grave-of-the-fireflies-1988/',
      'My Neighbor Totoro':
          'https://tv3.idlixku.com/movie/my-neighbor-totoro-1988/',
      'Kiki\'s Delivery Service':
          'https://tv3.idlixku.com/movie/kikis-delivery-service-1989/',
      'Only Yesterday': 'https://tv3.idlixku.com/movie/only-yesterday-1991/',
      'Porco Rosso': 'https://tv3.idlixku.com/movie/porco-rosso-1992/',
      'Pom Poko': 'https://tv3.idlixku.com/movie/pom-poko-1994/',
      'Whisper of the Heart':
          'https://tv3.idlixku.com/movie/whisper-of-the-heart-1995/',
      'Princess Mononoke':
          'https://tv3.idlixku.com/movie/princess-mononoke-1997/',
      'My Neighbors the Yamadas':
          'https://tv3.idlixku.com/movie/my-neighbors-the-yamadas-1999/',
      'Spirited Away': 'https://tv3.idlixku.com/movie/spirited-away-2001/',
      'The Cat Returns': 'https://tv3.idlixku.com/movie/the-cat-returns-2002/',
      'Howl\'s Moving Castle':
          'https://tv3.idlixku.com/movie/howls-moving-castle-2004/',
      'Tales from Earthsea':
          'https://tv3.idlixku.com/movie/tales-from-earthsea-2006/',
      'Ponyo': 'https://tv3.idlixku.com/movie/ponyo-2008/',
      'The Secret World of Arrietty':
          'https://tv3.idlixku.com/movie/the-secret-world-of-arrietty-2010/',
      'From Up on Poppy Hill':
          'https://tv3.idlixku.com/movie/from-up-on-poppy-hill-2011/',
      'The Wind Rises': 'https://tv3.idlixku.com/movie/the-wind-rises-2013/',
      'The Tale of the Princess Kaguya':
          'https://tv3.idlixku.com/movie/the-tale-of-the-princess-kaguya-2013/',
      'When Marnie Was There':
          'https://tv3.idlixku.com/movie/when-marnie-was-there-2014/',
      'The Red Turtle': 'https://tv5.lk21official.cc/red-turtle-2016/',
      'Earwig and the Witch':
          'https://tv3.idlixku.com/movie/earwig-and-the-witch-2021/',
    };
    return links[title]; // Return null jika tidak ada
  }

  Future<void> launchYouTube(String title) async {
    // Membuka link YouTube trailer
    final url = getYouTubeLink(title);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      ); // Launch eksternal
    } else {
      debugPrint('Failed to open URL: $url');
    }
  }

  Future<void> launchMovie(String title) async {
    // Membuka link streaming film
    final link = getMovieLink(title);
    if (link == null) {
      debugPrint('Movie link not available for "$title".');
      return;
    }
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Failed to open movie URL: $link');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(film['title']), // Judul AppBar film
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  film['title'] == "Earwig and the Witch"
                      ? Image.asset(
                        'images/earwig.png',
                        width: 200,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                      : CachedNetworkImage(
                        imageUrl: film['image'] ?? '',
                        width: 200,
                        height: 300,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const CircularProgressIndicator(),
                        errorWidget:
                            (context, url, error) =>
                                const Icon(Icons.broken_image, size: 100),
                      ),
            ),
            const SizedBox(height: 20),
            Text(
              film['description'], // Deskripsi film
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text("Director: ${film['director']}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.movie_creation_outlined),
                const SizedBox(width: 8),
                Text("Producer: ${film['producer']}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.date_range),
                const SizedBox(width: 8),
                Text("Release: ${film['release_date']}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange),
                const SizedBox(width: 8),
                Text("Rating: ${film['rt_score']}"),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_circle_fill),
              label: const Text("Watch Trailer on YouTube"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed:
                  () => launchYouTube(film['title']), // Aksi buka trailer
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.movie),
              label: const Text("Watch Movie"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () => launchMovie(film['title']), // Aksi buka film
            ),
          ],
        ),
      ),
    );
  }
}

// PROFILE PAGE
// -----------------------------
class ProfilePage extends StatelessWidget {
  // Konstruktor const agar widget immutable dan lebih efisien
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di bagian atas halaman
      appBar: AppBar(
        title: const Text("About Studio Ghibli"),
        backgroundColor: Colors.deepPurple,
      ),
      // Konten halaman di dalam SingleChildScrollView supaya bisa di-scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16), // Padding seluruh sisi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Teks rata kiri
          children: [
            // Logo Studio Ghibli di tengah
            Center(
              child: Image.asset(
                'images/ghibli_logo.png', // Pastikan gambar ada di folder assets
                height: 100,
              ),
            ),
            const SizedBox(height: 16), // Spasi vertikal
            // Judul besar
            const Text(
              'Studio Ghibli',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Paragraf deskripsi 1
            const Text(
              "Studio Ghibli is a Japanese animation film studio founded in 1985 by Hayao Miyazaki and Isao Takahata. The studio is renowned for producing high-quality animated films rich in imagination, human values, and visual beauty.",
              textAlign: TextAlign.justify, // Rata kiri-kanan
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            // Paragraf deskripsi 2
            const Text(
              "The studio has won numerous international awards and is known as a pioneer in modern Japanese animation..",
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Tombol untuk membuka Wikipedia
            ElevatedButton.icon(
              icon: const Icon(Icons.language), // Ikon globe
              label: const Text("Read More on Wikipedia"),
              onPressed: () async {
                final url = Uri.parse(
                  "https://en.wikipedia.org/wiki/Studio_Ghibli",
                ); // URL Wikipedia Studio Ghibli
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  // Jika gagal membuka URL, tampilkan di debug console
                  debugPrint("Could not launch Wikipedia");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Warna tombol
                foregroundColor: Colors.white, // Warna teks & ikon
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------
// CHARACTER PAGE
// -----------------------------
class CharacterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di bagian atas dengan judul "Characters"
      appBar: AppBar(
        title: const Text("Characters"),
        backgroundColor: Colors.deepPurple,
      ),
      // Isi halaman bisa di-scroll
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul besar di atas
            const Text(
              "Famous Characters from Studio Ghibli",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Memanggil builder card karakter satu per satu
            _buildCharacterCard(
              context,
              'Totoro',
              'The friendly forest spirit from "My Neighbor Totoro".',
              'images/totoro.jpg',
            ),
            _buildCharacterCard(
              context,
              'Chihiro',
              'The brave girl from "Spirited Away".',
              'images/chihiro.jpg',
            ),
            _buildCharacterCard(
              context,
              'Howl',
              'The charming wizard from "Howl\'s Moving Castle".',
              'images/howl.jpg',
            ),
            _buildCharacterCard(
              context,
              'Princess Mononoke',
              'The fierce princess from "Princess Mononoke".',
              'images/mononoke.jpg',
            ),
            _buildCharacterCard(
              context,
              'Kiki',
              'The young witch from "Kiki\'s Delivery Service".',
              'images/kiki.jpg',
            ),
            _buildCharacterCard(
              context,
              'Sophie',
              'The kind-hearted girl from "Howl\'s Moving Castle".',
              'images/sophie.jpg',
            ),
            _buildCharacterCard(
              context,
              'Ponyo',
              'The magical fish girl from "Ponyo".',
              'images/ponyo.jpg',
            ),
            _buildCharacterCard(
              context,
              'Calcifer',
              'The fire demon from "Howl\'s Moving Castle".',
              'images/calcifer.jpg',
            ),
            _buildCharacterCard(
              context,
              'Ashitaka',
              'The brave warrior from "Princess Mononoke".',
              'images/ashitaka.jpg',
            ),
            _buildCharacterCard(
              context,
              'Satsuki',
              'The caring sister from "My Neighbor Totoro".',
              'images/satsuki.jpg',
            ),
            _buildCharacterCard(
              context,
              'Gigi',
              'The black cat from "Kiki\'s Delivery Service".',
              'images/gigi.jpg',
            ),
            _buildCharacterCard(
              context,
              'Jiji',
              'The talking cat from "Kiki\'s Delivery Service".',
              'images/jiji.jpg',
            ),
          ],
        ),
      ),
    );
  }

  // Widget builder untuk satu kartu karakter
  Widget _buildCharacterCard(
    BuildContext context,
    String name,
    String description,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        // Event saat kartu ditekan, bisa ditambahkan aksi lain jika perlu
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
        ), // Spasi vertikal antar kartu
        elevation: 8, // Tinggi bayangan kartu
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Sudut kartu melengkung
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Gambar karakter dengan border dan shadow
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  12,
                ), // Sudut gambar melengkung
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.deepPurple,
                      width: 2,
                    ), // Border ungu di sekitar gambar
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4), // Bayangan bawah gambar
                      ),
                    ],
                  ),
                  child: Image.asset(
                    imagePath,
                    width: 100, // Lebar gambar
                    height: 100, // Tinggi gambar
                    fit: BoxFit.cover, // Crop gambar agar pas
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ), // Spasi horizontal antara gambar dan teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama karakter
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22, // Ukuran font besar
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple, // Warna teks ungu
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Deskripsi karakter
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54, // Warna abu-abu gelap
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------
// MERCHANDISE PAGE
// -----------------------------
class MerchandisePage extends StatelessWidget {
  // List produk yang ditampilkan di halaman Merchandise
  final List<Map<String, String>> products = [
    {
      'title': 'Totoro Plush Toy',
      'image':
          'https://tse1.mm.bing.net/th/id/OIP.4XGSuQipjUuzw920NdJzDQHaHa?pid=Api&P=0&h=220', // URL gambar Totoro
      'description': 'A soft and cuddly Totoro plush toy.', // Deskripsi produk
    },
    {
      'title': 'Spirited Away Art Book',
      'image':
          'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1435336738i/429853.jpg', // URL gambar Art Book
      'description':
          'An art book featuring stunning illustrations from Spirited Away.', // Deskripsi produk
    },
    {
      'title': 'Princess Mononoke Figure',
      'image':
          'https://down-id.img.susercontent.com/file/id-11134207-7rash-m22eumd296o9f1', // URL gambar Figure Mononoke
      'description':
          'A beautifully crafted figure of Princess Mononoke.', // Deskripsi produk
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dengan judul halaman
      appBar: AppBar(
        title: const Text("Merchandise Store"),
        backgroundColor: Colors.deepPurple,
      ),
      // ListView untuk menampilkan daftar produk
      body: ListView.builder(
        itemCount: products.length, // Jumlah item dalam list
        itemBuilder: (context, index) {
          final product = products[index]; // Data produk pada index tertentu
          return Card(
            margin: const EdgeInsets.all(16), // Margin sekitar kartu
            child: InkWell(
              // Event saat kartu diketuk
              onTap: () async {
                final url = Uri.parse(product['link']!); // URL link produk
                if (await canLaunchUrl(url)) {
                  // Membuka URL di aplikasi eksternal
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint(
                    "Could not launch ${product['link']}",
                  ); // Log jika gagal
                }
              },
              child: Column(
                children: [
                  // Gambar produk
                  Image.network(
                    product['image']!,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                  // Judul produk
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      product['title']!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Deskripsi produk
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      product['description']!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
