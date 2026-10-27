import 'package:flutter/material.dart';
import '../../../core/constants/aurum_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../controllers/gold_vault_controller.dart';
import '../../../domain/models/gold_vault_item.dart';

/// Modal thêm giao dịch mua vàng vào Két Vàng cá nhân
class AddVaultTransactionSheet extends StatefulWidget {
  final GoldVaultController controller;

  const AddVaultTransactionSheet({super.key, required this.controller});

  @override
  State<AddVaultTransactionSheet> createState() => _AddVaultTransactionSheetState();
}

class _AddVaultTransactionSheetState extends State<AddVaultTransactionSheet> {
  final _titleController = TextEditingController(text: 'Nhẫn trơn 9999 PNJ');
  final _quantityController = TextEditingController(text: '1.0');
  final _priceController = TextEditingController(text: '14880000');
  final _noteController = TextEditingController(text: 'Két sắt gia đình');

  GoldBrandType _brand = GoldBrandType.pnj;
  GoldProductType _productType = GoldProductType.ring9999;
  WeightUnit _unit = WeightUnit.chi;
  final DateTime _purchaseDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AurumColors.bgCardElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.add_shopping_cart, color: AurumColors.gold, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Thêm Vàng Vào Két Cá Nhân',
                      style: TextStyle(color: AurumColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AurumColors.textMuted),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tên món vàng
            _buildTextField('Tên Gợi Nhớ', _titleController, 'Ví dụ: Nhẫn trơn 1 chỉ tháng 9'),
            const SizedBox(height: 12),

            // Thương hiệu & Loại vàng
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Thương Hiệu', style: TextStyle(color: AurumColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<GoldBrandType>(
                        value: _brand,
                        dropdownColor: AurumColors.bgCard,
                        style: const TextStyle(color: AurumColors.textPrimary, fontSize: 12.5),
                        decoration: _dropdownDecoration(),
                        items: GoldBrandType.values.map((b) {
                          return DropdownMenuItem(value: b, child: Text(_brandName(b)));
                        }).toList(),
                        onChanged: (val) => setState(() => _brand = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chủng Loại', style: TextStyle(color: AurumColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<GoldProductType>(
                        value: _productType,
                        dropdownColor: AurumColors.bgCard,
                        style: const TextStyle(color: AurumColors.textPrimary, fontSize: 12.5),
                        decoration: _dropdownDecoration(),
                        items: GoldProductType.values.map((p) {
                          return DropdownMenuItem(value: p, child: Text(_productName(p)));
                        }).toList(),
                        onChanged: (val) => setState(() => _productType = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Số lượng & Đơn vị
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField('Số Lượng', _quantityController, '1.0', keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Đơn Vị', style: TextStyle(color: AurumColors.textSecondary, fontSize: 11)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<WeightUnit>(
                        value: _unit,
                        dropdownColor: AurumColors.bgCard,
                        style: const TextStyle(color: AurumColors.textPrimary, fontSize: 12.5),
                        decoration: _dropdownDecoration(),
                        items: WeightUnit.values.map((u) {
                          return DropdownMenuItem(value: u, child: Text(u.uppercaseLabel));
                        }).toList(),
                        onChanged: (val) => setState(() => _unit = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Giá mua trên mỗi đơn vị
            _buildTextField('Giá Mua Mỗi Đơn Vị (VND)', _priceController, '14880000', keyboardType: TextInputType.number),
            const SizedBox(height: 12),

            // Nơi cất giữ
            _buildTextField('Nơi Lưu Trữ Ghi Chú', _noteController, 'Két sắt / Hộp an toàn'),
            const SizedBox(height: 20),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final double qty = CurrencyFormatter.parseFloat(_quantityController.text, 1.0);
                  final double price = CurrencyFormatter.parseVnd(_priceController.text, 14880000.0);

                  final newItem = GoldVaultItem(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Món vàng mới',
                    brand: _brand,
                    productType: _productType,
                    unit: _unit,
                    quantity: qty,
                    buyPricePerUnit: price,
                    purchaseDate: _purchaseDate,
                    storageNote: _noteController.text.trim(),
                  );

                  widget.controller.addItem(newItem);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AurumColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Lưu Món Vàng Vào Két',
                  style: TextStyle(color: Color(0xFF141002), fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AurumColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AurumColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: AurumColors.bgPanel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AurumColors.border)),
          ),
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: AurumColors.bgPanel,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AurumColors.border)),
    );
  }

  String _brandName(GoldBrandType b) {
    switch (b) {
      case GoldBrandType.sjc: return 'SJC';
      case GoldBrandType.pnj: return 'PNJ';
      case GoldBrandType.doji: return 'DOJI';
      case GoldBrandType.baoTinMinhChau: return 'BTMC';
      case GoldBrandType.miHong: return 'Mi Hồng';
      case GoldBrandType.other: return 'Khác';
    }
  }

  String _productName(GoldProductType p) {
    switch (p) {
      case GoldProductType.ring9999: return 'Nhẫn trơn 9999';
      case GoldProductType.barSjc: return 'Vàng miếng SJC';
      case GoldProductType.miniBar: return 'Miếng mini';
      case GoldProductType.jewelry: return 'Trang sức';
      case GoldProductType.other: return 'Khác';
    }
  }
}
