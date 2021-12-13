
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
  //println("MAE : " + mae + " indice forme active ; " + indice_forme);
  switch (mae) {
    case INITIAL:  // Etat INITIAL
      background(255);
      fill(0);
      text("Etat initial (c(ercle)/r(ectangle)/t(riangle) pour créer la forme à la position courante)", 50,50);
      text("click pour sélectionner un objet et click pour sa nouvelle position", 50,80);
      passageAct();
      break;
      
    case ATTENTE_ACTION:
      passageAct();
    break;
    
    case CREER:
      passageForme();
      affiche("Etat CREER");
    break;
    
    case DEPLACER:
      delay(1000);
      mae= FSM.INITIAL;
    break;
    
    case CREATION_FORME:
      affiche("Etat CREATION_FORME");
      println("Fin de l'action");
      clrvar();
      mae= FSM.ATTENTE_ACTION;
    break;
    
    case SELECTION_FORME: 
    case DEPLACER_FORMES_SELECTION:
    case DEPLACER_FORMES_DESTINATION: 
    case MODIF_COULEUR:
      affiche("");
      break;   
      
    default:
      break;
  }  
}

// fonction d'affichage des formes m
void affiche(String msg) {
  text(msg, 50,80);
  /* afficher tous les objets */
  for (int i=0;i<formes.size();i++) // on affiche les objets de la liste
    (formes.get(i)).update();
}

void clrvar() {
  act="";
  lieu="";
  forme="";
  coul="";
  loca=""; 
}

void passageAct() {
  char val='z';
  if(act.equals("CREATE ")){
    val='c';
  }
  if(act.equals("MOVE ")){
    val='m';
  }
  switch (val) {
    case 'c':
      mae= FSM.CREER;
    break;
    
    case 'm':
      mae= FSM.DEPLACER;
    break;
    
    default:
    break;
  }
}

void passageForme() {
  if(forme.equals("RECTANGLE ")){
      Point p = new Point(mouseX,mouseY);
      Forme f= new Rectangle(p);
      formes.add(f);
      mae=FSM.CREATION_FORME;
  }
  else if(forme.equals("TRIANGLE ")){
      Point p = new Point(mouseX,mouseY);
      Forme f1= new Triangle(p);
      formes.add(f1);
      mae=FSM.CREATION_FORME;
  }
  else if(forme.equals("CIRCLE ")){
      Point p = new Point(mouseX,mouseY);
      Forme f2= new Cercle(p);
      formes.add(f2);
      mae=FSM.CREATION_FORME;
  }
  else {
    println("Aucune forme donnée");
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
      forme = "RECTANGLE ";
      Forme f= new Rectangle(p);
      formes.add(f);
      mae=FSM.CREATION_FORME;
      break;
      
    case 'c':
    forme = "CERCLE ";
      Forme f2=new Cercle(p);
      formes.add(f2);
      mae=FSM.CREATION_FORME;
      break;
    
    case 't':
    forme = "TRIANGLE ";
      Forme f3=new Triangle(p);
      formes.add(f3);
       mae=FSM.CREATION_FORME;
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
