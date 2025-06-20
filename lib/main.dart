// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'dart:convert'; // Import untuk JSON encoding/decoding

import 'package:cached_network_image/cached_network_image.dart'; // Import untuk caching gambar dari jaringan
import 'package:flutter/material.dart'; // Import untuk material design Flutter
import 'package:http/http.dart' as http; // Import untuk HTTP requests
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk SharedPreferences
import 'package:url_launcher/url_launcher.dart'; // Import untuk meluncurkan URL

// Fungsi utama yang menjalankan aplikasi Flutter.
void main() {
  runApp(const GhibliApp()); // Menjalankan aplikasi GhibliApp
}

// Widget utama aplikasi
class GhibliApp extends StatelessWidget {
  const GhibliApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studio Ghibli Films', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.deepPurple, // Warna tema utama
        scaffoldBackgroundColor: const Color(
          0xFFF2F2F7,
        ), // Warna latar belakang scaffold
        fontFamily: 'Arial', // Jenis font default
      ),
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      home: const SplashScreen(), // Halaman splash pertama
    );
  }
}

// -----------------------------
// SPLASH SCREEN (tanpa timer)
// -----------------------------
class SplashScreen extends StatelessWidget {
  const SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EC), // Warna latar belakang
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Menyusun anak di tengah
          children: [
            Image.asset(
              'images/ghibli_logo.png',
              height: 120,
            ), // Logo Studio Ghibli
            const SizedBox(height: 24), // Spasi vertikal
            const Text(
              'STUDIO GHIBLI', // Judul aplikasi
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12), // Spasi vertikal
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 40,
              ), // Padding horizontal
              child: Text(
                'Explore the legendary films of Studio Ghibli filled with imagination and wonder.', // Deskripsi aplikasi
                textAlign: TextAlign.center, // Teks rata tengah
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 28), // Spasi vertikal
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ), // Navigasi ke HomePage
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, // Warna tombol
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    30,
                  ), // Bentuk tombol bulat
                ),
              ),
              child: const Text(
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
// HOME PAGE (daftar film + favorit)
// -----------------------------
class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List films = [];
  List filteredFilms = [];
  Set<String> favoriteIds = {}; // Set ID film favorit
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFilms(); // Ambil data film dari API
    loadFavorites(); // Ambil favorit dari SharedPreferences
  }

  // Ambil data film dari API
  Future<void> fetchFilms() async {
    final url = Uri.parse('https://ghibliapi.vercel.app/films');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body); // Mendecode respons JSON
      setState(() {
        films = data; // Mengisi list films dengan data dari API
        filteredFilms = data; // Mengisi list filteredFilms dengan data dari API
        isLoading = false; // Mematikan status loading
      });
    } else {
      throw Exception('Failed to load films'); // Menangani error jika gagal
    }
  }

  // Ambil favorit dari SharedPreferences
  Future<void> loadFavorites() async {
    final prefs =
        await SharedPreferences.getInstance(); // Mengambil instance SharedPreferences
    final ids =
        prefs.getStringList('favorites') ?? []; // Mengambil data ID favorit
    setState(() {
      favoriteIds = ids.toSet(); // Mengubah list favorit menjadi set
    });
  }

  // Simpan atau hapus dari favorit
  Future<void> toggleFavorite(String id) async {
    final prefs =
        await SharedPreferences.getInstance(); // Mengambil instance SharedPreferences
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id); // Menghapus film dari favorit
      } else {
        favoriteIds.add(id); // Menambahkan film ke favorit
      }
      prefs.setStringList(
        'favorites',
        favoriteIds.toList(),
      ); // Menyimpan perubahan ke SharedPreferences
    });
  }

  // Filter film berdasarkan query pencarian
  void filterFilms(String query) {
    final filtered =
        films.where((film) {
          final title =
              film['title'].toString().toLowerCase(); // Mengambil judul film
          return title.contains(
            query.toLowerCase(),
          ); // Membandingkan dengan query pencarian
        }).toList();

    setState(() {
      filteredFilms = filtered; // Memperbarui list filteredFilms
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoritePage()),
          );
        },
        backgroundColor: Colors.deepPurple, // Warna tombol favorit
        child: const Icon(Icons.favorite), // Icon tombol favorit
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Menampilkan loading indicator
              : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 50,
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepPurple,
                          Color(0xFF9575CD),
                        ], // Warna gradient latar belakang
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(
                          24,
                        ), // Sudut bulat bawah kiri
                        bottomRight: Radius.circular(
                          24,
                        ), // Sudut bulat bawah kanan
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Studio Ghibli Films 🎬", // Judul halaman utama
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12), // Spasi vertikal
                        TextField(
                          controller:
                              searchController, // Controller untuk input pencarian
                          onChanged:
                              filterFilms, // Memanggil fungsi filter saat teks berubah
                          style: const TextStyle(
                            color: Colors.white,
                          ), // Memanggil fungsi filter saat teks berubah
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Colors.white24, // Warna latar input pencarian
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white, // Warna icon pencarian
                            ),
                            hintText:
                                'Search for movie title...', // Hint text untuk input pencarian
                            hintStyle: const TextStyle(
                              color: Colors.white70,
                            ), // Gaya hint text
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // Bentuk border input pencarian
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
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width >= 1200
                                ? 4
                                : MediaQuery.of(context).size.width >= 800
                                ? 3
                                : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            0.68, // Rasio aspek child dalam GridView
                      ),
                      itemCount:
                          filteredFilms.length, // Jumlah item dalam GridView
                      itemBuilder: (context, index) {
                        final film =
                            filteredFilms[index]; // Mengambil data film untuk ditampilkan
                        return Card(
                          elevation: 4, // Elevasi untuk efek bayangan
                          // Membentuk kartu film dengan tampilan rounded (sudut melengkung)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            // Tambahkan efek sentuh dengan radius yang sama
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              // Navigasi ke halaman detail film saat kartu ditekan
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FilmDetailPage(film: film),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child:
                                        film['title'] == "Earwig and the Witch"
                                            // Jika film adalah "Earwig and the Witch", tampilkan gambar lokal
                                            ? Image.asset(
                                              'images/earwig.png',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                            // Jika bukan, tampilkan gambar dari internet
                                            : CachedNetworkImage(
                                              imageUrl: film['image'] ?? '',
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              placeholder:
                                                  (
                                                    context,
                                                    url,
                                                  ) => const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(
                                                        Icons.broken_image,
                                                        size: 60,
                                                      ),
                                            ),
                                  ),
                                ),
                                // Bagian teks (judul, tanggal rilis, rating, dan tombol favorit)
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Judul film
                                      Text(
                                        film['title'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Tanggal rilis
                                      Text("Release: ${film['release_date']}"),
                                      // Rating dan tombol favorit
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            (int.parse(film['rt_score']) / 10)
                                                .toStringAsFixed(1),
                                          ),
                                          const Spacer(),
                                          // Tombol favorit (warna berubah jika sudah difavoritkan)
                                          IconButton(
                                            icon: Icon(
                                              favoriteIds.contains(film['id'])
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color:
                                                  favoriteIds.contains(
                                                        film['id'],
                                                      )
                                                      ? Colors.red
                                                      : Colors.grey,
                                            ),
                                            onPressed:
                                                () =>
                                                    toggleFavorite(film['id']),
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
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}

// -----------------------------
// HALAMAN FAVORIT SAYA
// -----------------------------
// Mendapatkan daftar film favorit berdasarkan ID dari SharedPreferences
class FavoritePage extends StatelessWidget {
  const FavoritePage();

  Future<List<Map>> getFavoriteFilms() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? [];
    final url = Uri.parse('https://ghibliapi.vercel.app/films');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Filter hanya film yang ada di daftar favorit
      return List<Map>.from(
        data,
      ).where((film) => ids.contains(film['id'])).toList();
    } else {
      throw Exception('Failed to load films'); // Teks diubah ke bahasa Inggris
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites ❤️"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map>>(
        future: getFavoriteFilms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Menampilkan loading jika data masih dimuat
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const Center(child: Text("No favorite films yet"));
          }
          // Menampilkan daftar film favorit
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final film = favorites[index];
              return ListTile(
                leading:
                    film['title'] == "Earwig and the Witch"
                        ? Image.asset(
                          'images/earwig.png',
                          width: 50,
                          height: 80,
                        )
                        : CachedNetworkImage(
                          imageUrl: film['image'],
                          width: 50,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                title: Text(film['title']),
                subtitle: Text("Release: ${film['release_date']}"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FilmDetailPage(film: film),
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
// DETAIL FILM (tidak diubah)
// -----------------------------
class FilmDetailPage extends StatelessWidget {
  final Map film;
  const FilmDetailPage({required this.film});
  // Mendapatkan link YouTube berdasarkan judul film
  String getYouTubeLink(String title) {
    final links = {
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
    // Kembalikan link langsung jika tersedia, jika tidak cari otomatis di YouTube
    return links[title] ??
        'https://www.youtube.com/results?search_query=${Uri.encodeComponent(title + " trailer")}';
  }

  // Fungsi untuk membuka YouTube trailer
  Future<void> launchYouTube(String title) async {
    final url = getYouTubeLink(title);
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Failed to open URL: $url'); // Teks diubah ke bahasa Inggris
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(film['title']),
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
              film['description'],
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.person),
                SizedBox(width: 8),
                Text("Director: ${film['director']}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.movie_creation_outlined),
                SizedBox(width: 8),
                Text("Producer: ${film['producer']}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.date_range),
                SizedBox(width: 8),
                Text("Release: ${film['release_date']}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange),
                SizedBox(width: 8),
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
                  () => launchYouTube(
                    film['title'],
                  ), // Meluncurkan trailer di YouTube
            ),
          ],
        ),
      ),
    );
  }
}
