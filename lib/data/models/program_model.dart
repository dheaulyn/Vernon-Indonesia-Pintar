class ProgramModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String imageUrl;
  final List<String> benefit;
  final List<String> syarat;

  ProgramModel({
    this.id = '',
    required this.judul,
    required this.deskripsi,
    required this.imageUrl,
    required this.benefit,
    required this.syarat,
  });
}
