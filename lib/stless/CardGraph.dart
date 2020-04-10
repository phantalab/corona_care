import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class CardGraph extends StatelessWidget {

  IconData iconLoc;
  var n;
  String s1;
  Color textColor;
  var activeData;
  List<Color> gradientColors;

  CardGraph(this.iconLoc, this.n, this.s1,this.textColor,this.activeData,this.gradientColors);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        child: Container(
          width: MediaQuery.of(context).size.width*0.2,
          height: MediaQuery.of(context).size.width*0.25,
          child: Stack(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: LineChart(LineChartData(
                  borderData: FlBorderData(
                      show: false
                  ),
                  gridData: const FlGridData(
                    show: false,
                  ),
                  titlesData: FlTitlesData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: activeData["maxX"],
                  minY: activeData["minY"],
                  maxY: activeData["maxY"],
                  lineBarsData: [
                    LineChartBarData(
                      spots: activeData["points"] as List<FlSpot>,
                      isCurved: true,
                      colors: gradientColors,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(
                        show: false,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: gradientColors
                            .map((color) => color.withOpacity(0.1))
                            .toList(),
                      ),
                    ),
                  ],
                )),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(iconLoc,color: textColor,),
                    Text(
                      n.toString(),
                      style: TextStyle(
                          color: textColor, fontSize: 20,fontWeight: FontWeight.w900),
                    ),
                    Text(
                      s1,
                      style: TextStyle(color: Colors.grey,fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
