import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:raffle_local/src/models/raffle_details.dart';
import 'package:raffle_local/src/models/raffle_num.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class RaffleController extends ControllerMVC {
  RaffleDetails raffleDetails = RaffleDetails();
  String _buyer = "";

  int min = 1;

  bool selling = true;
  bool finished = false;
  bool loadingRaffleNums = true;

  static const raffleTime = Duration(seconds: 10);

  List<RaffleNum> raffleNums = [];
  List<RaffleNum> raffleSellingNums = [];
  List<RaffleNum> raffleSoldNums = [];
  Map<String, dynamic> winner = {};

  int sorteado = 0;
  int sellingNums = 0;
  int freeNums = 0;
  double total = 0.0;

  double liquidEarning = 0.0;

  //Shows an dialog to insert the raffle details
  void createRaffle(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Create new Raffle",
          ),
          content: Form(
            child: SizedBox(
              height: 350,
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        raffleDetails.premiumDescription = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Premium description",
                      hintText: "Insert here the permium description",
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        raffleDetails.premiumValue = double.parse(value);
                      });
                    },
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      labelText: "Premium value",
                      hintText: "Insert here the premium value",
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        raffleDetails.max = int.parse(value);
                      });
                    },
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      labelText: "Max quotas",
                      hintText: "Inform here the raffle max quotas",
                    ),
                  ),
                  TextFormField(
                    onChanged: (value) {
                      setState(() {
                        raffleDetails.quotaValue = double.parse(value);
                      });
                    },
                    keyboardType: const TextInputType.numberWithOptions(),
                    decoration: const InputDecoration(
                      labelText: "Quota price",
                      hintText: "Inform here the quota price",
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                saveRaffleDetails().then((value) {
                  setState(() {
                    sellingNums = 0;
                    freeNums = 0;
                    sorteado = 0;
                    finished = false;
                  });
                  for (var i = min; i <= raffleDetails.max; i++) {
                    RaffleNum value = RaffleNum(
                      index: i - 1,
                      number: i,
                      buyer: "",
                    );
                    raffleNums.add(value);
                    sellingNums++;
                    setState(() {});
                  }
                  setState(() {
                    freeNums = sellingNums;
                  });
                  Navigator.of(context).pop();
                });
              },
              child: const Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            )
          ],
        );
      },
    );
  }

  //Saves the raffle details
  Future<void> saveRaffleDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('raffleDetails', jsonEncode(raffleDetails));
  }

  //Saves all the raffle numbers into the shared preferences
  Future<void> saveRaffleNums() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('raffleNums', jsonEncode(raffleNums));
  }

  //Saves all the sold numbers into the shared preferences
  Future<void> saveraffleSoldNums() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('raffleSoldNums', jsonEncode(raffleSoldNums));
  }

  //Clears all the raffle info from shared preferences
  Future<void> clearInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('raffleNums');
    await prefs.remove('raffleSoldNums');
  }

  //Get the saved numbers and raffle details from sharedpreferences
  Future<void> getRaffleNums() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //Verifies if the shared preferences contains de the key raffleDetails, if so, retrieve it and pass back to the system.
    if (prefs.containsKey('raffleDetails')) {
      var getDetails = prefs.getString('raffleDetails');
      RaffleDetails details = RaffleDetails.fromJson(jsonDecode(getDetails!));
      setState(() {
        raffleDetails = details;
      });
    }

    //Verifies if the shared preferences contains de the key raffleNums if so, retrieve it and pass back to the system.
    if (prefs.containsKey('raffleNums')) {
      var getRaffleNums = prefs.getString('raffleNums');
      List<RaffleNum> list = (jsonDecode(getRaffleNums!) as List)
          .map((data) => RaffleNum.fromJSON(data))
          .toList();
      setState(() {
        raffleNums = list;
      });
    }

    //Verifies if the shared preferences contains de the key raffleSoldNums, if so, retrieve it and pass back to the system.
    if (prefs.containsKey('raffleSoldNums')) {
      var getraffleSoldNums = prefs.getString('raffleSoldNums');
      List<RaffleNum> list = (jsonDecode(getraffleSoldNums!) as List)
          .map((data) => RaffleNum.fromJSON(data))
          .toList();
      setState(() {
        raffleSoldNums = list;
      });
    }
    print("read");
  }

  //Function buying a raffle number
  void buyingRaffleNum(RaffleNum number) {
    raffleSellingNums.add(number);
    raffleNums.removeWhere((num) => num.number == number.number);

    total += raffleDetails.quotaValue;
    setState(() {});
  }

  //Select all remaining numbers to sell
  void sellAllRaffleNumbers() {
    for (var num in raffleNums) {
      raffleSellingNums.add(num);
      total += raffleDetails.quotaValue;
      setState(() {});
    }
    setState(() {
      raffleNums.clear();
    });
  }

  //Confirms the selling
  void confirmSelling() {
    for (var num in raffleSellingNums) {
      num.buyer = _buyer;
      raffleSoldNums.add(num);
    }
    freeNums = raffleNums.length - raffleSellingNums.length;
    setState(() {});
    clearValues();
    print(raffleSoldNums.length);
    saveRaffleNums().then((value) {
      print("Raffle nums saved successfuly!");
    });
    saveraffleSoldNums().then((value) {
      print("Raffle sold nums saved sucessfuly!");
    });
    raffleSellingNums.clear();
  }

  //cancell the selling number runing every one and reinserting on raffleNums
  void cancelSelling() {
    for (var i = 0; i < raffleSellingNums.length; i++) {
      raffleNums.insert(i, raffleSellingNums[i]);
    }

    setState(() {});
    clearValues();
    print(raffleSellingNums.length);
    raffleSellingNums.clear();
  }

  //Clears all the values after the raffle
  void clearValues() async {
    if (finished) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('raffleDetails');
      setState(() {
        raffleSoldNums.clear();
        raffleNums.clear();
        winner.clear();
        total = 0;
        selling = true;
      });
    } else {
      setState(() {
        total = 0;
        selling = true;
      });
    }
  }

  void raffle(context) {
    //Verifies if the sold nums size are bigger than zero, if so the raffle runs, else shows an alert saying that no numbers where sold
    if (raffleSoldNums.isNotEmpty) {
      Timer sort = Timer(raffleTime, () {
        Navigator.of(context, rootNavigator: true).pop();
      });
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("Raffling"),
            content: CircularProgressIndicator(),
          );
        },
      ).then((value) {
        sort.cancel();
      });
      sorteado = Random().nextInt(raffleDetails.max);//Random number between 1 and the raffle max quotas
      Timer.periodic(
        raffleTime,
        (timer) {
          DateTime now = DateTime.now();
          setState(() {
            finished = true;
          });
          for (var num in raffleSoldNums) {
            if (num.number == sorteado) {
              setState(() {
                winner = {
                  "number": num.number,
                  "buyer": num.buyer,
                };
              });
            }
          }
          if (winner.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    "Drawn number: ${winner['number']}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  content: SizedBox(
                    height: 100,
                    child: Column(
                      children: [
                        Text(
                          "The winner is ${winner['buyer']}",
                        ),
                        Text("Premium: ${raffleDetails.premiumDescription}"),
                        Text("$now")
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        getEarnigs(context);
                        timer.cancel();
                      },
                      child: const Text("OK"),
                    )
                  ],
                );
              },
            );
            timer.cancel();
            setState(() {
              selling = false;
            });
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(
                    "Drawn number: $sorteado",
                  ),
                  content: const Text(
                    "Unfortunately we didn't have any winners this time.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        getEarnigs(context);
                        timer.cancel();
                      },
                      child: const Text("OK"),
                    )
                  ],
                );
              },
            );
            timer.cancel();
            setState(() {
              selling = false;
            });
          }
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "You haven't sold any number",
            ),
            content: const Text(
              "You need to sell at least one number to sell the draw",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              )
            ],
          );
        },
      );
    }
  }

  //Gets the total earnings
  void getTotalEarnings() {
    // ignore: unused_local_variable
    for (var element in raffleSoldNums) {
      total += raffleDetails.quotaValue;
      setState(() {});
    }

    liquidEarning = total - raffleDetails.premiumValue;
    setState(() {});
  }

  //Shows an alert dialog with the raffle details
  void showRaffleDetails(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Raffle details"),
          content: SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Premium"),
                    Text(raffleDetails.premiumDescription)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Premium value"),
                    Text("\$ ${raffleDetails.premiumValue}")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Quota price"),
                    Text("\$ ${raffleDetails.quotaValue}")
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ok"),
            )
          ],
        );
      },
    );
  }

//shows an alert dialog with the earnings
  void getEarnigs(context) {
    getTotalEarnings();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Earnings",
              ),
            ],
          ),
          content: SizedBox(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Premium value"),
                    Text(
                      "\$ ${raffleDetails.premiumValue}",
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sold"),
                    Text(
                      "\$ $total",
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                winner.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Earning"),
                          Text(
                            "\$ $liquidEarning",
                            style: TextStyle(
                              color:
                                  liquidEarning < 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Earning"),
                          Text(
                            "R\$ $total",
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                clearValues();
                if (finished) {
                  clearInfo().then((value) {
                    createRaffle(context);
                  });
                }
              },
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  //Shows an alert with all the selling numbers
  void showSellingNumbers(context) {
    if (raffleSellingNums.isNotEmpty && total >= 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 50,
                  width: 200,
                  padding: const EdgeInsetsDirectional.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.blue),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Quotas: ${raffleSellingNums.length}"),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text("Total: R\$ $total"),
              ],
            ),
            content: SizedBox(
              height: 250,
              width: 100,
              child: Form(
                child: Column(
                  children: [
                    SizedBox(
                      height: 148,
                      width: 400,
                      child: GridView.builder(
                        itemCount: raffleSellingNums.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.2,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.amber,
                            ),
                            child: TextButton(
                              child: Center(
                                child: Text(
                                  raffleSellingNums[index].number.toString(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              onPressed: () {},
                            ),
                          );
                        },
                      ),
                    ),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _buyer = value;
                        });
                      },
                      decoration: const InputDecoration(
                        label: Text('Buyer name'),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please inform the buyer";
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  confirmSelling();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Confirm",
                  style: TextStyle(
                    color: Colors.green,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.plus_one_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Colors.amber,
              ),
              TextButton(
                onPressed: () {
                  cancelSelling();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Whoops"),
            content: const Text("The cart is empty"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }
}
