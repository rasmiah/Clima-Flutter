import 'dart:io';

void main(){
  performTasks();
}

void performTasks() async{
  task1();
 String task2Result= await task2();
  task3(task2Result);
}

void task1() {
  String result='Task1 data';
  print('Task1 complete');
}
Future  task2() async{
  Duration three= Duration(seconds: 3);
  String? result;
  await Future.delayed(three, (){
    result='Task2 data';
    print('Task2 complete');
  });
  return result;
}
void task3(String task2Data) {
  String result='Task3 data';
  print('Task3 complete with $task2Data');
}