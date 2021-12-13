
import java.awt.Point;
import fr.dgac.ivy.*;
import javax.swing.JOptionPane;

Ivy bus;

ArrayList<Forme> formes; // liste de formes stockées
FSM mae; // Finite Sate Machine
int indice_forme;
PImage sketch_icon;
color couleur;


String act="";
String lieu="";
String forme="";
String coul="";
String loca="";
float confid=0.0;
boolean newMsg;



  
void setup() {
size(800,600);
  surface.setResizable(true);
  surface.setTitle("Le Gestionneur de Formes");
  surface.setLocation(20,20);
  
  try {
    bus = new Ivy("Moteur_Fusion", " Moteur_Fusion is ready", null);
    bus.start("127.255.255.255:2010");
    
    bus.bindMsg("^sra5 Parsed=action=(.*)where=(.*)form=(.*)color=(.*)localisation=(.*)Confidence=(.*)NP=.*", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        act=args[0];
        lieu=args[1];
        forme=args[2];
        coul=args[3];
        loca=args[4];
        String confidstr=args[5];
        
        println("Action= "+act);
        println("Lieu= "+lieu);
        println("Forme= "+forme);
        println("Couleur= "+coul);
        println("Localisation= "+loca);
        
        confidstr=confidstr.replace(',','.');
        confid=float(confidstr);
        println("Confindence= "+confid);
        println("--------------------");
        newMsg=true;
        
        try {
          bus.sendMsg("Moteur_de_fusion: " + "act="+act+" lieu="+lieu+" forme="+forme+" coul"+coul+" loca"+loca+" confid"+confidstr);
        }
        catch(IvyException ie){}
      }
      
    });
    
  }
    
  catch (IvyException ie) {
    System.err.println("Error : "+ ie.getMessage());
  }
  
  formes= new ArrayList(); // nous créons une liste vide
  noStroke();
  mae = FSM.INITIAL;
  indice_forme = -1;
  
}



void draw() {
  background(0);
  println("MAE : " + mae + " indice forme active ; " + indice_forme);
  switch (mae) {
    case INITIAL:  // Etat INITIAL
      background(255);
      fill(0);
      text("Etat initial (c(ercle)/r(ectangle)/t(riangle) pour créer la forme à la position courante)", 50,50);
      text("click pour sélectionner un objet et click pour sa nouvelle position", 50,80);
      passageAct();
      break;
    
    case CREER:
    case DEPLACER:
    case SELECTION_FORME: 
    case DEPLACER_FORMES_SELECTION:
    case DEPLACER_FORMES_DESTINATION: 
    case MODIF_COULEUR:
      affiche();
      break;   
      
    default:
      break;
  }  
}

// fonction d'affichage des formes m
void affiche() {
  background(255);
  /* afficher tous les objets */
  for (int i=0;i<formes.size();i++) // on affiche les objets de la liste
    (formes.get(i)).update();
}

void passageAct() {
  int val=0;
  if(act.equals("CREATE ")){
    val=1;
  }
  if(act.equals("MOVE ")){
    val=2;
  }
  switch (val) {
    case 1:
      mae= FSM.CREER;
    break;
    
    case 2:
      mae= FSM.DEPLACER;
    break;
    
    default:
      println("Aucune action reconnu");
    break;
  }
}


void mousePressed() { // sur l'événement clic
  Point p = new Point(mouseX,mouseY);
      
      
    switch (mae) {
    case MODIF_COULEUR: 
      for (int i=0;i<formes.size();i++) { // we're trying every object in the list
        // println((formes.get(i)).isClicked(p));
        if ((formes.get(i)).isClicked(p)) {
          (formes.get(i)).setColor(couleur);
        }
      } 
      break;
      
      
      
   case DEPLACER_FORMES_SELECTION:
     for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
        if ((formes.get(i)).isClicked(p)) {
          indice_forme = i;
          mae = FSM.DEPLACER_FORMES_DESTINATION;
        }         
     }
     if (indice_forme == -1)
       mae= FSM.MODIF_COULEUR;
     break;
     
   case DEPLACER_FORMES_DESTINATION:
     if (indice_forme !=-1)
       (formes.get(indice_forme)).setLocation(new Point(mouseX,mouseY));
     indice_forme=-1;
     mae=FSM.SELECTION_FORME;
     break;
     
    default:
      break;
  }
}



void keyPressed() {
  Point p = new Point(mouseX,mouseY);
  switch(key) {
    case 'r':
      Forme f= new Rectangle(p);
      formes.add(f);
      mae=FSM.MODIF_COULEUR;
      break;
      
    case 'c':
      Forme f2=new Cercle(p);
      formes.add(f2);
      mae=FSM.MODIF_COULEUR;
      break;
    
    case 't':
      Forme f3=new Triangle(p);
      formes.add(f3);
       mae=FSM.MODIF_COULEUR;
      break;  
    
    case 'm' : // move
      mae=FSM.DEPLACER_FORMES_SELECTION;
      break;
      
    case '1' :
      couleur = color(255,0,0);
      mae=FSM.MODIF_COULEUR;
      break;
      
    case '2' : 
      couleur = color(0,255,0);    
      mae=FSM.MODIF_COULEUR;
      break;
      
    case '3' : 
      couleur = color(0,0,255); 
      mae=FSM.MODIF_COULEUR;
      break;
    
      
  }
}
