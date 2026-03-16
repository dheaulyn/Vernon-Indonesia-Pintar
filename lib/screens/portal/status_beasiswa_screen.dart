import 'package:flutter/material.dart';
// import '../../core/app_colors.dart';
import 'portal_layout.dart';
import '../../data/mock_database.dart'; 

class StatusBeasiswaScreen extends StatefulWidget {
  const StatusBeasiswaScreen({super.key});

  @override
  State<StatusBeasiswaScreen> createState() => _StatusBeasiswaScreenState();
}

class _StatusBeasiswaScreenState extends State<StatusBeasiswaScreen> {
  int _rowsPerPage = 10;
  
  @override
  Widget build(BuildContext context) {
    final user = MockDatabase.currentUser ?? {};
    
    
    final bool isRegistered = user['is_registered'] == true;
    
    final currentProdi = user['prodi'] != null && user['prodi'].toString().isNotEmpty 
        ? user['prodi'] 
        : '-';
    final currentPT = user['pt'] != null && user['pt'].toString().isNotEmpty 
        ? user['pt'] 
        : '-';
    final currentBeasiswa = user['jenis_beasiswa'] ?? '-';
    final String currentStrata = user['strata'] != null && user['strata'].toString().isNotEmpty
        ? user['strata']
        : '-'; 

    return PortalLayout(
      activeMenu: 'status', 
      content: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Beasiswa',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B4856)
              ),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Show ', style: TextStyle(color: Colors.black54)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<int>(
                              value: _rowsPerPage,
                              underline: const SizedBox(),
                              items: [10, 25, 50, 100].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _rowsPerPage = newValue!;
                                });
                              },
                            ),
                          ),
                          const Text(' entries', style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Search: ', style: TextStyle(color: Colors.black54)),
                          SizedBox(
                            width: 200,
                            height: 35,
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Table(
                    columnWidths: const {
                      0: FixedColumnWidth(50),  
                      1: FlexColumnWidth(2),    
                      2: FlexColumnWidth(1),    
                      3: FlexColumnWidth(2),    
                      4: FlexColumnWidth(3),    
                      5: FixedColumnWidth(100), 
                      6: FixedColumnWidth(150), 
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1),
                      bottom: BorderSide(color: Colors.grey.shade300, width: 2),
                      top: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                    children: [
                      TableRow(
                        children: [
                          _buildTableHeader('No'),
                          _buildTableHeader('Beasiswa', sortable: true),
                          _buildTableHeader('Strata', sortable: true),
                          _buildTableHeader('Periode', sortable: true),
                          _buildTableHeader('Universitas', sortable: true),
                          _buildTableHeader('Status', sortable: true),
                          _buildTableHeader('Aksi', sortable: true),
                        ],
                      ),
                      
                      if (isRegistered)
                        TableRow(
                          children: [
                            _buildTableCell('1'),
                            _buildTableCell(currentBeasiswa, isBold: true),
                            _buildTableCell(currentStrata),
                            _buildTableCell('Periode 2026\nBatch 1'), 
                            _buildTableCell('$currentPT ;\n$currentProdi'),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.orange),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Draft',
                                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade600,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(60, 32),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                        )
                                      ),
                                    ),
                                    child: const Text('Edit', style: TextStyle(fontSize: 13)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade400,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(60, 32),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        )
                                      ),
                                    ),
                                    child: const Text('Hapus', style: TextStyle(fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  if (!isRegistered)
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'Belum ada data pengajuan beasiswa.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isRegistered ? 'Showing 1 to 1 of 1 entries' : 'Showing 0 to 0 of 0 entries', 
                        style: const TextStyle(color: Colors.black54)
                      ),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: null, 
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(4))
                              )
                            ),
                            child: const Text('Previous', style: TextStyle(color: Colors.black45)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              border: Border.all(color: Colors.blue.shade600),
                            ),
                            child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          OutlinedButton(
                            onPressed: null, 
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(4))
                              )
                            ),
                            child: const Text('Next', style: TextStyle(color: Colors.black45)),
                          ),
                        ],
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

  Widget _buildTableHeader(String text, {bool sortable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          if (sortable) ...[
            const SizedBox(width: 5),
            Icon(Icons.unfold_more, size: 16, color: Colors.grey.shade400),
          ]
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8), 
      child: Center( 
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            height: 1.4, 
          ),
        ),
      ),
    );
  }
}