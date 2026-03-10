import 'models/program_model.dart';

class DummyData {
  static List<ProgramModel> listProgram = [
    ProgramModel(
      id: "1",
      judul: "Beasiswa Siswa Berprestasi",
      deskripsi:
          "Membantu anak-anak berbakat untuk lanjut ke jenjang perguruan tinggi.",
      targetDana: 100000000,
      terkumpul: 65000000,
      imageUrl:
          "https://images.unsplash.com/photo-1523050335456-c4d98930b83e?q=80&w=500",
    ),
    ProgramModel(
      id: "2",
      judul: "Digital Literasi Pelosok",
      deskripsi:
          "Penyediaan laptop dan jaringan internet untuk sekolah di desa terpencil.",
      targetDana: 50000000,
      terkumpul: 10000000,
      imageUrl:
          "https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=500",
    ),
  ];
}
