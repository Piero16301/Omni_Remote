import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:omni_remote/app/helpers/icon_helper.dart';
import 'package:omni_remote/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class DevicePreview extends StatelessWidget {
  const DevicePreview({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.tileType,
    required this.rangeMin,
    required this.rangeMax,
    required this.divisions,
    required this.interval,
    super.key,
  });

  final String title;
  final String subtitle;
  final String iconName;
  final DeviceTileType tileType;
  final double rangeMin;
  final double rangeMax;
  final int divisions;
  final double interval;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Text(
          l10n.modifyDevicePreview,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        DevicePreviewTile(
          key: Key('$rangeMin$rangeMax$divisions$interval'),
          title: title,
          subtitle: subtitle,
          iconName: iconName,
          tileType: tileType,
          rangeMin: rangeMin,
          rangeMax: rangeMax,
          divisions: divisions,
          interval: interval,
        ),
      ],
    );
  }
}

class DevicePreviewTile extends StatefulWidget {
  const DevicePreviewTile({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.tileType,
    required this.rangeMin,
    required this.rangeMax,
    required this.divisions,
    required this.interval,
    super.key,
  });

  final String title;
  final String subtitle;
  final String iconName;
  final DeviceTileType tileType;
  final double rangeMin;
  final double rangeMax;
  final int divisions;
  final double interval;

  @override
  State<DevicePreviewTile> createState() => _DevicePreviewTileState();
}

class _DevicePreviewTileState extends State<DevicePreviewTile> {
  bool _boolValue = true;
  late double _numberValue;
  late double? _minValue;
  late double? _maxValue;
  int? _divisions;

  @override
  void initState() {
    super.initState();
    if (widget.tileType == DeviceTileType.number) {
      if (widget.rangeMin >= widget.rangeMax) {
        _minValue = 0;
        _maxValue = 10;
      } else {
        _minValue = widget.rangeMin;
        _maxValue = widget.rangeMax;
      }

      _numberValue = (_minValue! + _maxValue!) / 2;

      if (_numberValue < _minValue! || _numberValue > _maxValue!) {
        _numberValue = (_minValue! + _maxValue!) / 2;
      }

      // Finalmente inicializar las divisiones
      if (widget.divisions == 0 || _divisions == null) {
        _divisions = 1;
      }
      if (widget.divisions > 0) {
        _divisions = widget.divisions;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (widget.tileType) {
      case DeviceTileType.boolean:
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              spacing: 16,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                HugeIcon(
                  icon: IconHelper.getIconByName(widget.iconName),
                  size: 28,
                  strokeWidth: 2,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        widget.title.isEmpty
                            ? l10n.modifyDeviceDeviceTitle
                            : widget.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Visibility(
                        visible: widget.subtitle.isNotEmpty,
                        child: Text(
                          widget.subtitle.isEmpty
                              ? l10n.modifyDeviceDeviceSubtitle
                              : widget.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _boolValue,
                  onChanged: (value) {
                    setState(() {
                      _boolValue = value;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      case DeviceTileType.number:
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    HugeIcon(
                      icon: IconHelper.getIconByName(widget.iconName),
                      size: 28,
                      strokeWidth: 2,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            widget.title.isEmpty
                                ? l10n.modifyDeviceDeviceTitle
                                : widget.title,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          Text(
                            widget.subtitle.isEmpty
                                ? l10n.modifyDeviceDeviceSubtitle
                                : widget.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8,
                      children: [
                        Visibility(
                          visible: widget.interval > 0,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                if (_numberValue - widget.interval <
                                    _minValue!) {
                                  _numberValue = _minValue!;
                                } else {
                                  _numberValue = _numberValue - widget.interval;
                                }
                              });
                            },
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedRemove01,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        Text(
                          _numberValue.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Visibility(
                          visible: widget.interval > 0,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                if (_numberValue + widget.interval >
                                    _maxValue!) {
                                  _numberValue = _maxValue!;
                                } else {
                                  _numberValue = _numberValue + widget.interval;
                                }
                              });
                            },
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedAdd01,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Slider(
                  min: _minValue!,
                  max: _maxValue!,
                  divisions: _divisions,
                  value: _numberValue,
                  onChanged: (value) {
                    setState(() {
                      _numberValue = value;
                    });
                  },
                ),
              ],
            ),
          ),
        );
    }
  }
}
