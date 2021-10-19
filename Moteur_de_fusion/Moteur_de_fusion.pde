import fr.dgac.ivy.*;
import javax.swing.JOptionPane;

Ivy bus;
boolean test;
  
void setup() {
  size(400, 250);
  surface.setTitle("Gesture Recognizer");
  surface.setLocation(50,50);
  
  // === START WITH NO TEMPLATES ===
  try {
    bus = new Ivy("OneDollarIvy", " OneDollarIvy is ready", null);
    bus.start("127.255.255.255:2010");
  }
  catch (IvyException ie) {}
    test= false;
}
