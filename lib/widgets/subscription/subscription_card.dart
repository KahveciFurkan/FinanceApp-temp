import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../../types/type.dart';

class SubscriptionCard extends StatefulWidget {
  final Subscription sub;
  final VoidCallback onFreeze;
  final VoidCallback onDelete;
  final VoidCallback onTogglePaid;

  const SubscriptionCard({
    Key? key,
    required this.sub,
    required this.onFreeze,
    required this.onDelete,
    required this.onTogglePaid,
  }) : super(key: key);

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  String get _daysLeft {
    final diff = widget.sub.renewDate.difference(DateTime.now()).inDays;
    if (diff < 0) return 'Gün geçti';
    if (diff == 0) return 'Bugün';
    return '$diff gün kaldı';
  }

  bool get isPaidForThisMonth {
    final now = DateTime.now();
    return widget.sub.isPaid &&
        widget.sub.paidMonth.year == now.year &&
        widget.sub.paidMonth.month == now.month;
  }

  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: widget.sub.name);
    final priceCtrl = TextEditingController(text: widget.sub.price.toString());
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Abonelik Düzenle',
              style: TextStyle(color: Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'İsim'),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: InputDecoration(labelText: 'Fiyat'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: sub.adını ve fiyatını güncelle, Hive’a kaydet
                  Navigator.pop(context);
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
    );
  }

  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sub.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration:
                        isPaidForThisMonth ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Fiyat: ₺${widget.sub.price}',
                  style: TextStyle(
                    color: Colors.white70,
                    decoration:
                        isPaidForThisMonth ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  'Yenileme: ${DateFormat('dd MMM yyyy').format(widget.sub.renewDate)}',
                  style: TextStyle(
                    color: Colors.white70,
                    decoration:
                        isPaidForThisMonth ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  'Kategori: ${widget.sub.category}',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 12),
                Text(
                  'Durum: ${widget.sub.isFrozen ? "Dondurulmuş" : "Aktif"}',
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: widget.onFreeze,
                  icon: Icon(
                    widget.sub.isFrozen
                        ? Icons.lock_open
                        : Icons.ac_unit_rounded,
                  ),
                  label: Text(widget.sub.isFrozen ? 'Çöz' : 'Dondur'),
                ),
                ElevatedButton.icon(
                  onPressed: widget.onDelete,
                  icon: Icon(Icons.delete_outline),
                  label: Text('Sil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String getDaysLeft() {
    final today = DateTime.now();
    final renewDate = widget.sub.renewDate;

    final difference = renewDate.difference(today).inDays;

    if (difference > 0) {
      return '$difference gün kaldı';
    } else if (difference == 0) {
      return 'Bugün yenileniyor';
    } else {
      return '${-difference} gün geçti';
    }
  }

  @override
  Widget build(BuildContext context) {
    String _daysLeft = getDaysLeft();

    return Slidable(
      key: Key(widget.sub.key.toString()),

      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onTogglePaid(),
            backgroundColor: Colors.green,
            icon: Icons.check,
            label: 'Ödendi',
          ),
        ],
      ),

      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => widget.onFreeze(),
            backgroundColor: Colors.orange,
            icon: widget.sub.isFrozen ? Icons.lock_open : Icons.ac_unit_rounded,
            label: widget.sub.isFrozen ? 'Çöz' : 'Dondur',
            flex: 1,
          ),
          SlidableAction(
            onPressed: (_) => widget.onDelete(),
            backgroundColor: Colors.red,
            icon: Icons.delete_outline,
            label: 'Sil',
            flex: 1,
          ),
        ],
      ),

      child: GestureDetector(
        onLongPress: () => _showEditDialog(context),
        onTap: () => _showDetailModal(context),
        child: Stack(
          children: [
            Opacity(
              opacity: widget.sub.isFrozen ? 0.5 : 1,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color:
                    isPaidForThisMonth
                        ? Colors.green.withOpacity(0.3)
                        : Color(widget.sub.colorValue).withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        IconData(
                          widget.sub.iconCodePoint,
                          fontFamily: 'MaterialIcons',
                        ),
                        size: 32,
                        color: Color(widget.sub.colorValue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.sub.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      decoration:
                                          isPaidForThisMonth
                                              ? TextDecoration.lineThrough
                                              : null,
                                    ),
                                  ),
                                ),
                                if (isPaidForThisMonth)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.greenAccent,
                                  ),
                              ],
                            ),
                            Text(
                              '₺${widget.sub.price.toStringAsFixed(2)} / ay',
                              style: TextStyle(
                                color: Colors.white70,
                                decoration:
                                    isPaidForThisMonth
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            Text(
                              'Yenileme: ${DateFormat('dd.MM.yyyy').format(widget.sub.renewDate)}',
                              style: TextStyle(
                                color: Colors.white70,
                                decoration:
                                    isPaidForThisMonth
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isPaidForThisMonth)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _daysLeft,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.sub.isFrozen)
              Positioned(
                top: 8,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DONDURULDU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
