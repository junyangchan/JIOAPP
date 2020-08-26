import 'package:flutter/material.dart';
import 'package:jio/services/database.dart';

import 'CategoryDropDownList.dart';

class SearchDialogBox extends StatefulWidget {
  SearchDialogBox(
      {this.database,
      this.deviceHeight,
      this.deviceWidth,
      this.categoryCallback,
      this.selectedCategoryList,
      this.colorCallback,
        this.myController,
      this.completed});
  final database;
  final deviceHeight;
  final deviceWidth;
  final categoryCallback;
  final myController;
  final List<int> selectedCategoryList;
  final colorCallback;
  final completed;

  static Future<void> show(
    BuildContext context, {
    database,
    deviceHeight,
    deviceWidth,
    categoryCallback,
    selectedCategoryList,
    colorCallback,
    completed,
        myController,
  }) async {
    await Navigator.of(context,rootNavigator: true).push(
      PageRouteBuilder(
        opaque:false,
        pageBuilder: (BuildContext context,_,__) => SearchDialogBox(
          deviceHeight: deviceHeight,
          database: database,
          deviceWidth: deviceWidth,
          categoryCallback: categoryCallback,
          selectedCategoryList: selectedCategoryList,
          colorCallback: colorCallback,
          completed: completed,
          myController: myController,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _SearchDialogBoxState createState() => _SearchDialogBoxState();
}

class _SearchDialogBoxState extends State<SearchDialogBox>{

  void dispose() {
    widget.myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(1, 1, 1, 0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              width:widget.deviceWidth*0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  searchBar(),
                  category(widget.database),
                  Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          elevation: 0,
                          color: Colors.transparent,
                          child: Text("Cancel"),
                          onPressed: () {
                            widget.colorCallback();
                            if(mounted){
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          elevation: 0,
                          color: Colors.transparent,
                          child: Text("Done"),
                          onPressed: () async {
                            await widget.completed(widget.myController.text);
                            await widget.colorCallback();
                            if(mounted){
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchBar() {
    return Container(
      width: widget.deviceWidth * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: widget.deviceHeight * 0.01),
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Colors.black, fontSize: 14),
        controller: widget.myController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
            size: 14,
          ),
          hintText: "Search for Event",
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget category(Database database) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white),
      width: widget.deviceWidth * 0.4,
      padding: EdgeInsets.symmetric(vertical: widget.deviceHeight * 0.01),
      child: CategoryDropDownList(
        database: database,
        preSelectedValue: widget.selectedCategoryList,
        callback: widget.categoryCallback,
        submitting: false,
        hint: _hint(),
        multiple: true,
      ),
    );
  }

  Widget _hint() {
    return Text(
      "Select category",
      style: TextStyle(
        color: Colors.black,
        fontSize: 12,
      ),
    );
  }
}
