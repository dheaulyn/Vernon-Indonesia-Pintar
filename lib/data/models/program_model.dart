class ProgramModel {
  final String id;
  final String judul;
  final String deskripsi;
  final double targetDana;
  final double terkumpul;
  final String imageUrl;

  ProgramModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.targetDana,
    required this.terkumpul,
    required this.imageUrl,
  });

  double get persentase => terkumpul / targetDana;
}
