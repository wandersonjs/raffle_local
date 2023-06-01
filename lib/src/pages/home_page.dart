import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:raffle_local/src/controllers/raffle_controller.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends StateMVC<MyHomePage> {
  RaffleController _raffleController = new RaffleController();

  _MyHomePageState() : super(RaffleController()) {
    _raffleController = controller as RaffleController;
  }

  @override
  void initState() {
    super.initState();
    _raffleController.getRaffleNums().then((value) {
      if (_raffleController.raffleNums.isEmpty &&
          _raffleController.raffleSoldNums.isEmpty) {
        _raffleController.createRaffle(context);
      }
      setState(() {
        _raffleController.loadingRaffleNums = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = (MediaQuery.of(context).size.height - 250);
    double width = (MediaQuery.of(context).size.width - 50);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          _raffleController.raffleDetails.premiumDescription.isNotEmpty
              ? IconButton(
                  onPressed: () => _raffleController.showRaffleDetails(context),
                  icon: Icon(
                    Icons.info_outline,
                  ),
                )
              : Container(),
          _raffleController.raffleSoldNums.isNotEmpty
              ? IconButton(
                  onPressed: () => _raffleController.getEarnigs(context),
                  icon: Icon(
                    Icons.monetization_on_outlined,
                  ),
                )
              : Container(),
        ],
      ),
      body: _raffleController.loadingRaffleNums
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Loading!"),
                  SizedBox(
                    height: 20,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            )
          : ListView(
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          width: 260,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text("Total quotas"),
                                  Text(_raffleController.raffleDetails.max
                                      .toString()),
                                ],
                              ),
                              _raffleController.raffleSoldNums.length > 0
                                  ? TextButton(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Free',
                                            style: TextStyle(
                                                color: _raffleController.selling
                                                    ? Colors.blue
                                                    : Colors.black),
                                          ),
                                          Text(
                                            _raffleController.raffleNums.length
                                                .toString(),
                                            style: TextStyle(
                                                color: _raffleController.selling
                                                    ? Colors.blue
                                                    : Colors.black),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _raffleController.selling = true;
                                        });
                                      },
                                    )
                                  : Column(
                                      children: [
                                        Text('Free'),
                                        Text(
                                          _raffleController.raffleNums.length
                                              .toString(),
                                        ),
                                      ],
                                    ),
                              _raffleController.raffleSoldNums.length > 0
                                  ? TextButton(
                                      child: Column(
                                        children: [
                                          Text(
                                            'Sold',
                                            style: TextStyle(
                                                color: _raffleController.selling
                                                    ? Colors.black
                                                    : Colors.blue),
                                          ),
                                          Text(
                                            _raffleController
                                                .raffleSoldNums.length
                                                .toString(),
                                            style: TextStyle(
                                                color: _raffleController.selling
                                                    ? Colors.black
                                                    : Colors.blue),
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _raffleController.selling = false;
                                        });
                                      },
                                    )
                                  : Column(
                                      children: [
                                        Text('Sold'),
                                        Text(
                                          _raffleController
                                              .raffleSoldNums.length
                                              .toString(),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    _raffleController.raffleNums.isNotEmpty &&
                            _raffleController.selling
                        ? Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Select one of the numbers below"),
                              ],
                            ),
                          )
                        : Container(),
                    _raffleController.raffleNums.isEmpty &&
                            (_raffleController.raffleSoldNums.isNotEmpty ||
                                _raffleController.raffleSellingNums.isNotEmpty)
                        ? Container(
                            height: height,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "All the numbers where sold!",
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Icon(
                                  Icons.warning_amber,
                                  size: 50,
                                  color: Colors.amber,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text("Awaiting raffling!")
                              ],
                            ),
                          )
                        : _raffleController.raffleNums.isEmpty &&
                                _raffleController.selling
                            ? Container(
                                height: height,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Please crete a new raffle!",
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    IconButton(
                                      onPressed: () => _raffleController
                                          .createRaffle(context),
                                      icon: Icon(
                                        Icons.fiber_new,
                                        size: 50,
                                        color: Colors.green,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(top: 20),
                                height: height,
                                width: width,
                                child: GridView.builder(
                                  itemCount: _raffleController.selling == false
                                      ? _raffleController.raffleSoldNums.length
                                      : _raffleController.raffleNums.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: width >= 800 ? 20 : 4,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 2.2,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: _raffleController.selling
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      child: TextButton(
                                        child: Container(
                                          child: Center(
                                            child: _raffleController.selling ==
                                                    false
                                                ? Text(
                                                    _raffleController
                                                        .raffleSoldNums[index]
                                                        .number
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )
                                                : Text(
                                                    _raffleController
                                                        .raffleNums[index]
                                                        .number
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                          ),
                                        ),
                                        onPressed: () {
                                          if (_raffleController.selling) {
                                            _raffleController.buyingRaffleNum(
                                              _raffleController
                                                  .raffleNums[index],
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              )
                  ],
                )
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: Colors.amber,
                onPressed: () {
                  _raffleController.raffle(context);
                },
                tooltip: 'Sort',
                child: Icon(
                  Icons.sort,
                ),
              ),
              SizedBox(
                width: 11,
              ),
              FloatingActionButton(
                backgroundColor: Colors.blueGrey,
                onPressed: () {
                  _raffleController.sellAllRaffleNumbers();
                },
                tooltip: 'Sell all numbers',
                child: Icon(Icons.select_all),
              ),
              SizedBox(
                width: 11,
              ),
              FloatingActionButton(
                onPressed: () {
                  _raffleController.showSellingNumbers(context);
                },
                tooltip: 'Confirm selling',
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 10,
                      child: Icon(
                        Icons.shopping_cart_outlined,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${_raffleController.raffleSellingNums.length}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
