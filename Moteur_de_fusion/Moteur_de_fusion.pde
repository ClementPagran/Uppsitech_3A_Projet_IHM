
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

String lieuSave=" ";
char formeSave;
color coulSave = color(0,0,0);

String formeIcar="";

Point p = new Point(100,100);

int cptlieu=1;

Forme formetomove;
color coulask = color(100,100,100);



  
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
    
    bus.bindMsg("ICAR Gesture=(.*)", new IvyMessageListener() {
      public void receive(IvyClient client, String[] args) {
        formeIcar=args[0];
        println("formeIcar= "+formeIcar);
        if(formeIcar.equals("rectangle")){
          forme="RECTANGLE ";
        }
        else if(formeIcar.equals("triangle")){
          forme="TRIANGLE ";
        }
        else if(formeIcar.equals("cercle")){
          forme="CIRCLE ";
        }
          
        try {
          bus.sendMsg("Moteur_de_fusion: " + "formeIcar= "+formeIcar + "forme= "+forme);
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
  background(255);
  //println("MAE : " + mae);
  switch (mae) {
    case INITIAL:  // Etat INITIAL
      background(255);
      fill(0);
      text("Bienvenue dans le moteur de fusion", 50,50);
      text("Dites Creer ou Deplacer pour effectuer une action", 50,80);
      passageAct();
      break;
      
    case ATTENTE_ACTION:
      affiche("Etat ATTENTE_ACTION");
      passageAct();
    break;
    
    case CREER:
      affiche("Etat CREER");
      delay(500);
      mae= FSM.ATTENTE_FORME;
    break;
    
    case ATTENTE_FORME:
      affiche("Etat ATTENTE_FORME");
      if(forme.equals("RECTANGLE ")){
        formeSave = 'r';
        mae=FSM.ATTENTE_COULEUR;
      }
      else if(forme.equals("TRIANGLE ")){
        formeSave = 't';
        mae=FSM.ATTENTE_COULEUR;
      }
      else if(forme.equals("CIRCLE ")){
        formeSave = 'c';
        mae=FSM.ATTENTE_COULEUR;
      }
      else {
        println("Aucune forme donnée");
        mae= FSM.ATTENTE_FORME;
      }
    break;
    
    case ATTENTE_COULEUR:
      affiche("Etat ATTENTE_COULEUR");
      if(coul.equals("RED ")){
        coulSave = color(255,0,0);
        mae=FSM.ATTENTE_LIEU;
      }
      else if(coul.equals("BLUE ")){
          coulSave = color(0,0,255);
          mae=FSM.ATTENTE_LIEU;
      }
      else if(coul.equals("GREEN ")){
          coulSave = color(0,255,0);
          mae=FSM.ATTENTE_LIEU;
      }
      else {
        println("Aucune forme donnée");
        mae= FSM.ATTENTE_LIEU;
      }
    break;
    
    case ATTENTE_LIEU:
      affiche("Etat ATTENTE_LIEU");
      if(loca.equals("THERE ")){
        p = new Point(mouseX,mouseY);
        mae=FSM.CREATION_FORME;
      }
      else {
        println("Aucun lieu donnée");
        p = new Point(cptlieu*100,200);
        cptlieu+=1;
        mae= FSM.CREATION_FORME;
      }
    break;
    
    case CREATION_FORME:
      switch (formeSave) {
        case 'r':
          Forme f= new Rectangle(p);
          f.setColor(coulSave);
          formes.add(f);
          clrvar();
          mae=FSM.ATTENTE_ACTION;
        break;
        
        case 't':
          Forme f1= new Triangle(p);
          f1.setColor(coulSave);
          formes.add(f1);
          clrvar();
          mae=FSM.ATTENTE_ACTION;
        break;
        
        case 'c':;
          Forme f2= new Cercle(p);
          f2.setColor(coulSave);
          formes.add(f2);

          clrvar();
          mae=FSM.ATTENTE_ACTION;
        break;
        
        default:
          //println("Default");
        break;
      }
    break;
    
    case DEPLACER:
      affiche("Etat DEPLACER");
      mae=FSM.DEPLACER_FORMES_SELECTION;
    break;
    
    case DEPLACER_FORMES_SELECTION:
      ArrayList<Forme> formescollect;
      formescollect= new ArrayList();
      affiche("Etat DEPLACER_FORMES_SELECTION");
    
      if(coul.equals("RED ")){
          coulask = color(255,0,0);
      }
      else if(coul.equals("BLUE ")){
          coulask = color(0,0,255);
      }
      else if(coul.equals("GREEN ")){
          coulask = color(0,255,0);
      }
      else if(coul.equals("DARK ")){
          coulask = color(0,0,0);
      }
      else {
        coulask = color(100,100,100);
      }
    
      if(forme.equals("RECTANGLE ")){
        for (int i=0;i<formes.size();i++) {
          if ((formes.get(i)) instanceof Rectangle)
            formescollect.add(formes.get(i));
        }
        if(formescollect.size() >= 2) {
          formetomove = formescollect.get(formescollect.size()-1);
          for (int i=0;i<formescollect.size();i++) {
            if ((formescollect.get(i)).getColor() == coulask){
              formetomove = formescollect.get(i);
            }
          }
          mae=FSM.DEPLACER_FORMES_DESTINATION;
        }
        else {
          if (formescollect.size()==0){
            println("Aucune rectangle à deplacer");
            clrvar();
            mae=FSM.ATTENTE_ACTION;
          }
          else {
            formetomove = formescollect.get(0);
            mae=FSM.DEPLACER_FORMES_DESTINATION;
          }
        }
      }
      
      else if(forme.equals("TRIANGLE ")){
        for (int i=0;i<formes.size();i++) {
          if ((formes.get(i)) instanceof Triangle)
            formescollect.add(formes.get(i));
        }
        if(formescollect.size() >= 2) {
          formetomove = formescollect.get(formescollect.size()-1);
          for (int i=0;i<formescollect.size();i++) {
            if ((formescollect.get(i)).getColor() == coulask){
              formetomove = formescollect.get(i);
            }
          }
          mae=FSM.DEPLACER_FORMES_DESTINATION;
        }
        else {
          if (formescollect.size()==0){
            println("Aucune triangle à deplacer");
            clrvar();
            mae=FSM.ATTENTE_ACTION;
          }
          else {
            formetomove = formescollect.get(0);
            mae=FSM.DEPLACER_FORMES_DESTINATION;
          }
        }
      }
      
      
      else if(forme.equals("CIRCLE ")){
        for (int i=0;i<formes.size();i++) {
          if ((formes.get(i)) instanceof Cercle)
            formescollect.add(formes.get(i));
        }
        if(formescollect.size() >= 2) {
          formetomove = formescollect.get(formescollect.size()-1);
          for (int i=0;i<formescollect.size();i++) {
            if ((formescollect.get(i)).getColor() == coulask){
              formetomove = formescollect.get(i);
            }
          }
          mae=FSM.DEPLACER_FORMES_DESTINATION;
        }
        else {
          if (formescollect.size()==0){
            println("Aucune cerclede à deplacer");
            clrvar();
            mae=FSM.ATTENTE_ACTION;
          }
          else {
            formetomove = formescollect.get(0);
            mae=FSM.DEPLACER_FORMES_DESTINATION;
          }
        }
      }
      
    break;
    
    case DEPLACER_FORMES_DESTINATION:
      affiche("Etat DEPLACER_FORMES_DESTINATION");
      if(loca.equals("THERE ")){
        if (formetomove != null){
          formetomove.setLocation(new Point(mouseX,mouseY));
          indice_forme=-1;
          clrvar();
        }
      mae=FSM.ATTENTE_ACTION;
      }
    break;
    
    case MODIF_COULEUR:
      affiche("Etat MODIF_COULEUR");
    break;
    
    case ATTENTE_MODIF_COULEUR:
      affiche("Etat ATTENTE_MODIF_COULEUR");
      if(coul.equals("RED ")){
        coulSave = color(255,0,0);
        mae=FSM.MODIF_COULEUR;
      }
      else if(coul.equals("BLUE ")){
          coulSave = color(0,0,255);
          mae=FSM.MODIF_COULEUR;
      }
      else if(coul.equals("GREEN ")){
          coulSave = color(0,255,0);
          mae=FSM.MODIF_COULEUR;
      }
      else {
        println("Aucune forme donnée");
        mae= FSM.ATTENTE_MODIF_COULEUR;
      }
    break;
    
    case SUPPRIMER_FORME:
      affiche("Etat SUPPRIMER_FORME");
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
  act=" ";
  lieu=" ";
  forme=" ";
  coul=" ";
  loca=" ";
  coulSave = color(0,0,0);
  coulask = color(100,100,100);
}

void passageAct() {
  char val='z';
  if(act.equals("CREATE ")){
    val='c';
  }
  if(act.equals("MOVE ")){
    val='m';
  }
  if(act.equals("COLOR ")){
    val='l';
  }
  if(act.equals("DELETE ")){
    val='d';
  }
  if(act.equals("QUIT ")){
    val='q';
  }
  switch (val) {
    case 'c':
      mae= FSM.CREER;
    break;
    
    case 'm':
      mae= FSM.DEPLACER;
    break;
    
    case 'l':
      mae= FSM.ATTENTE_MODIF_COULEUR;
    break;
    
    case 'd':
      mae= FSM.SUPPRIMER_FORME;
    break;
    
    case 'q':
      exit();
    break;
    
    default:
      //println("Default");
    break;
  }
}


void mousePressed() { // sur l'événement clic
  Point p = new Point(mouseX,mouseY);
      
      
    switch (mae) {
       case DEPLACER_FORMES_SELECTION:
         for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
            if ((formes.get(i)).isClicked(p)) {
              formetomove = formes.get(i);
              mae = FSM.DEPLACER_FORMES_DESTINATION;
            }         
         }
         break;
         
       case DEPLACER_FORMES_DESTINATION:
         if (formetomove != null){
           formetomove.setLocation(new Point(mouseX,mouseY));
         }
         clrvar();
         mae=FSM.ATTENTE_ACTION;
         break;
     
       case MODIF_COULEUR: 
          for (int i=0;i<formes.size();i++) { // we're trying every object in the list
            // println((formes.get(i)).isClicked(p));
            if ((formes.get(i)).isClicked(p)) {
              (formes.get(i)).setColor(coulSave);
            }
          }
          clrvar();
          mae= FSM.ATTENTE_ACTION;
       break;

       case SUPPRIMER_FORME:
         for (int i=0;i<formes.size();i++) { // we're trying every object in the list        
            if ((formes.get(i)).isClicked(p)) {
              indice_forme = i;
              formes.remove(indice_forme);
              clrvar();
              mae = FSM.ATTENTE_ACTION;
            }         
         }
         break;
       
    default:
      break;
  }
}


void keyPressed() {
  switch(key) {
    case 'r':
      forme = "RECTANGLE ";
      break;
      
    case 'c':
      forme = "CIRCLE ";
      break;
    
    case 't':
      forme = "TRIANGLE ";
      break;  
    
    case 'm' : // move
      mae=FSM.DEPLACER_FORMES_SELECTION;
      break;
      
    case '1' :
      coulSave = color(255,0,0);
      break;
      
    case '2' : 
      coulSave = color(0,255,0);    
      break;
      
    case '3' : 
      coulSave = color(0,0,255); 
      break;
    
      
  }
}
