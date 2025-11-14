// lib/pages/image_capture_page.dart
import 'dart:io';
import 'package:atividade_images/componentes/header.dart';
import 'package:atividade_images/pages/geo_page.dart';
import 'package:atividade_images/services/upload_service.dart'; // Importando o novo serviço
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Modelo para gerenciar o estado da imagem (local e upload)
class ImageItem {
  final XFile localFile;
  String? downloadUrl;
  bool isUploading;
  bool hasError;

  ImageItem(this.localFile) : isUploading = false, hasError = false;
}

class ImageCapturePage extends StatefulWidget {
  const ImageCapturePage({super.key, required this.title});
  final String title;

  @override
  State<ImageCapturePage> createState() => _ImageCapturePageState();
}

class _ImageCapturePageState extends State<ImageCapturePage> {
  // Alterada para List<ImageItem> para rastrear o status do upload
  final List<ImageItem> _images = [];
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService =
      UploadService(); // Instância do serviço de upload

  // Função para lidar com o upload e atualizar o estado
  Future<void> _handleUpload(ImageItem item) async {
    final index = _images.indexOf(item);
    if (index == -1) return;

    // 1. Atualiza o estado para "uploading"
    setState(() {
      _images[index].isUploading = true;
      _images[index].hasError = false;
    });

    try {
      // 2. Chama o serviço de upload
      final url = await _uploadService.uploadImage(item.localFile);

      // 3. Sucesso: atualiza com o URL
      setState(() {
        _images[index].downloadUrl = url;
        _images[index].isUploading = false;
        debugPrint("Upload de imagem concluído: $url");
      });
    } catch (e) {
      // 4. Erro: atualiza com status de erro
      setState(() {
        _images[index].isUploading = false;
        _images[index].hasError = true;
      });
      debugPrint("Erro ao fazer upload da imagem: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no upload: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        // Cria um novo ImageItem e o adiciona à lista
        final newItem = ImageItem(pickedFile);
        setState(() {
          _images.add(newItem);
        });

        // Inicia o upload imediatamente
        await _handleUpload(newItem);
      }
    } catch (e) {
      // Tratar erros (ex: permissão negada)
      debugPrint("Erro ao selecionar imagem: $e");
    }
  }

  Widget _buildImageList() {
    if (_images.isEmpty) {
      return const Center(child: Text('Nenhuma imagem selecionada.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 imagens por linha
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final item = _images[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            // Imagem (local)
            Image.file(File(item.localFile.path), fit: BoxFit.cover),

            // Overlay de status
            if (item.isUploading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 5),
                      Text(
                        "Upload...",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else if (item.hasError)
              Container(
                color: Colors.red.withOpacity(0.7),
                child: Center(
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => _handleUpload(item), // Tentar novamente
                    tooltip: 'Erro de upload. Tentar novamente.',
                  ),
                ),
              )
            else if (item.downloadUrl != null)
              // Ícone de sucesso
              const Positioned(
                top: 5,
                right: 5,
                child: Icon(Icons.check_circle, color: Colors.green, size: 20),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo cinza claro
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          const Header(),

          // Botões para Camera e Galeria
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF1744),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Câmera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF1744),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeria'),
                ),
              ],
            ),
          ),

          // coloca um espaço a + e o Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(thickness: 2),
          ),

          // Lista de Imagens (Expandida)
          Expanded(child: _buildImageList()),

          // Botão do Mapa
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GeoPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF1744),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Mapa"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
