public class ConsoleNode{
  public String Text;
  public int Time;
  public ConsoleNode Next;
  public static final int StayTime = 10 * 1000;
  
  public ConsoleNode(String text){
    Text = text;
    Time = millis() + StayTime;
  }
  
  public boolean remove(){
    return millis() > Time;
  }
}
