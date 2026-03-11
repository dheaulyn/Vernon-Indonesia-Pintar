import 'models/program_model.dart';

class DummyData {
  static List<ProgramModel> listProgram = [
    ProgramModel(
      judul: "Beasiswa Berprestasi",
      deskripsi:
          "Program apresiasi bagi siswa dan mahasiswa yang memiliki prestasi luar biasa baik di bidang akademik maupun non-akademik (olahraga, seni, dan organisasi). Beasiswa ini bertujuan untuk mencetak calon pemimpin masa depan yang kompetitif dan memiliki dedikasi tinggi dalam mengharumkan nama bangsa.",
      imageUrl: "assets/beaberprestasi.png",
      syarat: [
        "Merupakan siswa/mahasiswa aktif di jenjang pendidikan formal (SMA/SMK/MA atau Perguruan Tinggi).",
        "Memiliki prestasi akademik minimal peringkat 10 besar di sekolah atau IPK minimal 3.5 untuk mahasiswa.",
        "Memiliki prestasi non-akademik yang diakui secara resmi (misalnya juara lomba tingkat kota, provinsi, nasional, atau internasional).",
        "Mempunyai motivasi kuat untuk terus berprestasi dan berkontribusi positif bagi masyarakat.",
        "Tidak sedang menerima beasiswa lain yang bersifat tumpang tindih dengan program ini.",
      ],
      benefit: [
        "Pembebasan biaya UKT/SPP 100%.",
        "Uang saku bulanan Rp 1.500.000.",
        "Mentoring eksklusif setiap bulan.",
        "Jaringan alumni Vernon Indonesia.",
      ],
    ),
    ProgramModel(
      judul: "Beasiswa Reguler",
      deskripsi:
          "Program bantuan pendidikan yang ditujukan bagi masyarakat umum guna menjamin keberlangsungan pendidikan bagi siswa/mahasiswa yang memiliki keterbatasan finansial namun memiliki semangat belajar yang tinggi. Beasiswa ini merupakan bentuk komitmen kami dalam memeratakan akses pendidikan berkualitas di seluruh Indonesia.",
      imageUrl: "assets/beareguler.png",
      syarat: [
        "Merupakan siswa/mahasiswa aktif di jenjang pendidikan formal (SMA/SMK/MA atau Perguruan Tinggi).",
        "Memiliki kondisi ekonomi keluarga yang kurang mampu (dibuktikan dengan surat keterangan tidak mampu dari kelurahan/desa).",
        "Memiliki motivasi kuat untuk terus belajar dan berkontribusi positif bagi masyarakat.",
        "Tidak sedang menerima beasiswa lain yang bersifat tumpang tindih dengan program ini.",
      ],
      benefit: [
        "Bantuan biaya pendidikan penuh",
        "Uang saku bulanan Rp 750.000.",
        "Pelatihan pengembangan karakter",
        "Kesempatan magang di perusahaan mitra Vernon Indonesia.",
      ],
    ),
  ];
}
