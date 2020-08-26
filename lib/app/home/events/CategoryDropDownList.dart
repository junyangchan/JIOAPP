import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:jio/app/home/events/empty_content.dart';

class CategoryDropDownList extends StatefulWidget {
  CategoryDropDownList(
      {this.database,
      this.submitting,
      this.preSelectedValue,
      this.callback,
      this.hint,
      this.multiple: false});
  final database;
  final bool submitting;
  final preSelectedValue;
  final callback;
  final hint;
  final multiple;
  @override
  _CategoryDropDownListState createState() => _CategoryDropDownListState();
}

class _CategoryDropDownListState extends State<CategoryDropDownList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.database.categoryList(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            final List<Map<String, dynamic>> categories = snapshot.data;
            if (categories != null) {
              return _buildDropdownList(categories, context);
            }
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return EmptyContent(
              title: 'Something went wrong',
              message: 'Can\'t load items right now',
            );
          }
          return Center(child: LinearProgressIndicator());
        });
  }

  Widget _buildDropdownList(
      List<Map<String, dynamic>> categories, BuildContext context) {
    List<DropdownMenuItem> items = categories.map((Map<String, dynamic> value) {
      return DropdownMenuItem<String>(
        value: value['name'],
        child: !widget.multiple
            ? InputDecorator(
                decoration: InputDecoration(
                  labelText: "Category",
                  border: InputBorder.none,
                ),
                baseStyle: TextStyle(fontSize: 14),
                child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(value['name'], style: TextStyle(fontSize: 14))))
            : Text(value['name'], style: TextStyle(fontSize: 14)),
      );
    }).toList();
    return !widget.multiple
        ? SearchableDropdown.single(
            validator: (value) => value == null && widget.submitting
                ? 'Category can\'t be empty'
                : null,
            items: items,
            iconDisabledColor: Colors.transparent,
            iconEnabledColor: Colors.grey.shade700,
            value: widget.preSelectedValue,
            underline: Container(),
            hint: widget.hint,
            icon: Container(),
            onChanged: (value) {
              for (var i in categories) {
                if (i['name'] == value) {
                  widget.callback(i);
                  break;
                }
              }
            },
            dialogBox: true,
            isExpanded: true,
          )
        : SearchableDropdown.multiple(
            items: items,
            selectedItems: widget.preSelectedValue,
            hint: widget.hint,
            iconDisabledColor: Colors.grey,
            iconEnabledColor: Colors.grey.shade700,
            underline: Container(),
            searchHint: "Select any",
            onChanged: (value) {
              List<String> newlist = [];
              for (var i in value) {
                newlist.add(categories[i]['name']);
              }
              widget.callback(newlist, value);
            },
            dialogBox: true,
            isExpanded: true,
          );
  }
}
