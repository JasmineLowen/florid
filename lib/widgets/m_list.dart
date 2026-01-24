import 'package:flutter/material.dart';

class MListItemData {
  final String title;
  final String? subtitle;
  final Function onTap;
  final Widget? leading;
  final Widget? suffix;
  final bool selected;

  MListItemData({
    required this.title,
    this.subtitle,
    required this.onTap,
    this.leading,
    this.suffix,
    this.selected = false,
  });
}

class MListHeader extends StatefulWidget {
  final String title;
  const MListHeader({super.key, required this.title});

  @override
  State<MListHeader> createState() => _MListHeaderState();
}

class _MListHeaderState extends State<MListHeader> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class MListView extends StatelessWidget {
  final items;
  final bool? enableScroll;
  final bool? shrinkWrap;
  const MListView({
    super.key,
    required this.items,
    this.enableScroll,
    this.shrinkWrap,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme as part of key to force rebuild when theme changes
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      key: ValueKey(isDarkMode),
      shrinkWrap: shrinkWrap != null ? false : true,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      physics: enableScroll != null
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        bool isLastItem(int index) {
          return index == items.length - 1;
        }

        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? Radius.circular(16.0) : Radius.circular(4.0),
            topRight: index == 0 ? Radius.circular(16.0) : Radius.circular(4.0),
            bottomLeft: isLastItem(index)
                ? const Radius.circular(16.0)
                : const Radius.circular(4.0),
            bottomRight: isLastItem(index)
                ? const Radius.circular(16.0)
                : const Radius.circular(4.0),
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 16.0, right: 16.0),
              title: Text(items[index].title),
              leading: items[index].leading,
              subtitle:
                  items[index].subtitle != null &&
                      items[index].subtitle!.isNotEmpty
                  ? Text(items[index].subtitle!)
                  : null,
              onTap: () => items[index].onTap(),
              trailing: items[index].suffix,
              selected: items[index].selected,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 4);
      },
    );
  }
}

class MRadioListItemData<T> {
  final String title;
  final String subtitle;
  final T value;
  final Widget? leading;
  final Widget? suffix;

  MRadioListItemData({
    required this.title,
    required this.subtitle,
    required this.value,
    this.leading,
    this.suffix,
  });
}

class MRadioListView<T> extends StatelessWidget {
  final List<MRadioListItemData<T>> items;
  final T groupValue;
  final Function(T) onChanged;
  final bool? enableScroll;
  final bool? shrinkWrap;

  const MRadioListView({
    super.key,
    required this.items,
    required this.groupValue,
    required this.onChanged,
    this.enableScroll,
    this.shrinkWrap,
  });

  @override
  Widget build(BuildContext context) {
    // Use theme as part of key to force rebuild when theme changes
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      key: ValueKey(isDarkMode),
      shrinkWrap: shrinkWrap != null ? false : true,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      physics: enableScroll != null
          ? AlwaysScrollableScrollPhysics()
          : NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        bool isLastItem(int index) {
          return index == items.length - 1;
        }

        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: index == 0 ? Radius.circular(16.0) : Radius.circular(4.0),
            topRight: index == 0 ? Radius.circular(16.0) : Radius.circular(4.0),
            bottomLeft: isLastItem(index)
                ? const Radius.circular(16.0)
                : const Radius.circular(4.0),
            bottomRight: isLastItem(index)
                ? const Radius.circular(16.0)
                : const Radius.circular(4.0),
          ),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: RadioListTile<T>(
              contentPadding: EdgeInsets.only(left: 16.0, right: 4.0),
              title: Text(items[index].title),
              subtitle: items[index].subtitle.isNotEmpty
                  ? Text(items[index].subtitle)
                  : null,
              value: items[index].value,
              groupValue: groupValue,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
              secondary: items[index].suffix,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 4);
      },
    );
  }
}
