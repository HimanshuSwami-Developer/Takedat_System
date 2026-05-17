import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takedat_app/core/app_text.dart';

class EmployeeSearchModel {
  final String id;
  final String name;
  final String? email;

  EmployeeSearchModel({required this.id, required this.name, this.email});

  factory EmployeeSearchModel.fromJson(Map<String, dynamic> json) {
    return EmployeeSearchModel(
      id: json['id'],
      name: json['full_name'] ?? json['email'] ?? 'Unknown',
      email: json['email'],
    );
  }

  String get initials {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class EmployeeSearchField extends StatefulWidget {
  final String label;
  final String hint;
  final EmployeeSearchModel? initialValue;
  final void Function(EmployeeSearchModel?) onSelected;

  const EmployeeSearchField({
    super.key,
    this.label = 'Employee',
    this.hint = 'Search employee...',
    this.initialValue,
    required this.onSelected,
  });

  @override
  State<EmployeeSearchField> createState() => _EmployeeSearchFieldState();
}

class _EmployeeSearchFieldState extends State<EmployeeSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  List<EmployeeSearchModel> _suggestions = [];
  bool _isLoading = false;
  EmployeeSearchModel? _selected;

  /// Flag to prevent focus listener from clearing after a tap selection
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null) {
      _selected = widget.initialValue;
      _controller.text = widget.initialValue!.name;
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();

        /// Only restore/clear if we are NOT in the middle of selecting
        if (!_isSelecting) {
          if (_selected != null) {
            _controller.text = _selected!.name;
          } else {
            _controller.clear();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─── Supabase search ──────────────────────────────────────────────────────

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      _removeOverlay();
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('id, full_name, email')
          .ilike('full_name', '%$query%')
          .limit(8);

      if (!mounted) return;

      setState(() {
        _suggestions = (response as List)
            .map((e) => EmployeeSearchModel.fromJson(e))
            .toList();
      });

      _showOverlay();
    } catch (e) {
      if (!mounted) return;
      setState(() => _suggestions = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Overlay ──────────────────────────────────────────────────────────────

  void _showOverlay() {
    _removeOverlay();
    if (_suggestions.isEmpty || !mounted) return;

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned(
          width: MediaQuery.of(context).size.width*0.9,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,

            /// Offset pushes it below the field; width comes from the target
            offset: const Offset(0, 60),

            child: _buildDropdown(),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildDropdown() {
    return TextFieldTapRegion(
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 260),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (ctx, i) {
              final emp = _suggestions[i];
              return _SuggestionTile(
                employee: emp,
                onTap: () => _selectEmployee(emp),
              );
            },
          ),
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ─── Selection ────────────────────────────────────────────────────────────

  void _selectEmployee(EmployeeSearchModel emp) {
    /// Set flag BEFORE any focus changes to prevent the listener
    /// from clearing the controller
    _isSelecting = true;

    setState(() {
      _selected = emp;
      _controller.text = emp.name;
      _suggestions = [];
    });

    _removeOverlay();
    _focusNode.unfocus();
    widget.onSelected(emp);

    /// Reset flag after the frame so the focus listener has fired
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isSelecting = false;
    });
  }

  void _clearSelection() {
    setState(() {
      _selected = null;
      _suggestions = [];
      _controller.clear();
    });
    _removeOverlay();
    widget.onSelected(null);
    _focusNode.requestFocus();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.label.copyWith(fontSize: 13)),
        const SizedBox(height: 6),

        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.search, size: 20, color: Colors.grey),
                ),

                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,

                    onTap: () {
                      /// Re-show overlay if user taps back into a filled field
                      if (_selected != null) return;
                      if (_controller.text.length >= 2) {
                        _search(_controller.text);
                      }
                    },

                    onChanged: (val) {
                      /// Clear selection only when user actually edits text
                      if (_selected != null) {
                        setState(() => _selected = null);
                        widget.onSelected(null);
                      }
                      _search(val);
                    },

                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _selected != null
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: _clearSelection,
                                )
                              : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Suggestion tile ──────────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  final EmployeeSearchModel employee;
  final VoidCallback onTap;

  const _SuggestionTile({required this.employee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE6F1FB),
              child: Text(
                employee.initials,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF185FA5),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (employee.email != null)
                    Text(
                      employee.email!,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
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