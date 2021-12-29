import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.Point; 
import fr.dgac.ivy.*; 
import javax.swing.JOptionPane; 

import fr.dgac.ivy.*; 
import fr.dgac.ivy.tools.*; 
import gnu.getopt.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Moteur_de_fusion extends PApplet {






Ivy bus;

ArrayList<Forme> formes; // liste de formes stockées
FSM mae; // Finite Sate Machine
int indice_forme;
PImage sketch_icon;
int couleur;


String act="";
String lieu="";
String forme="";
String coul="";
String loca="";
float confid=0.0f;
boolean newMsg;

String lieuSave=" ";
char formeSave;
int coulSave = color(0,0,0);

String formeIcar="";

Point p = new Point(100,100);

int cptlieu=1;

Forme formetomove;
int coulask = color(100,100,100);



  
public void setup() {

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
        confid=PApplet.parseFloat(confidstr);
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



public void draw() {
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
public void affiche(String msg) {
  text(msg, 50,80);
  /* afficher tous les objets */
  for (int i=0;i<formes.size();i++) // on affiche les objets de la liste
    (formes.get(i)).update();
}

public void clrvar() {
  act=" ";
  lieu=" ";
  forme=" ";
  coul=" ";
  loca=" ";
  coulSave = color(0,0,0);
  coulask = color(100,100,100);
}

public void passageAct() {
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


public void mousePressed() { // sur l'événement clic
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


public void keyPressed() {
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
/*
 * Classe Cercle
 */ 
 
public class Cercle extends Forme {
  
  int rayon;
  
  public Cercle(Point p) {
    super(p);
    this.rayon=80;
  }
   
  public void update() {
    fill(this.c);
    circle((int) this.origin.getX(),(int) this.origin.getY(),this.rayon);
  }  
   
  public boolean isClicked(Point p) {
    // vérifier que le cercle est cliqué
   PVector OM= new PVector( (int) (p.getX() - this.origin.getX()),(int) (p.getY() - this.origin.getY())); 
   if (OM.mag() <= this.rayon/2)
     return(true);
   else 
     return(false);
  }
  
  protected double perimetre() {
    return(2*PI*this.rayon);
  }
  
  protected double aire(){
    return(PI*this.rayon*this.rayon);
  }
}
/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 *
 */
 
public enum FSM {
  INITIAL, /* Etat Initial */
  ATTENTE_ACTION,
  
  CREER,
  ATTENTE_FORME,
  ATTENTE_COULEUR,
  ATTENTE_LIEU,
  CREATION_FORME,
  
  DEPLACER,
  DEPLACER_FORMES_SELECTION,
  DEPLACER_FORMES_DESTINATION,
  
  MODIF_COULEUR,
  ATTENTE_MODIF_COULEUR,
  
  SUPPRIMER_FORME,
  
  
  
}
/*****
 * Création d'un nouvelle classe objet : Forme (Cercle, Rectangle, Triangle
 * 
 * Date dernière modification : 28/10/2019
 */

abstract class Forme {
 Point origin;
 int c;
 
 Forme(Point p) {
   this.origin=p;
   this.c = color(127);
 }
 
 public void setColor(int c) {
   this.c=c;
 }
 
 public int getColor(){
   return(this.c);
 }
 
 public abstract void update();
 
 public Point getLocation() {
   return(this.origin);
 }
 
 public void setLocation(Point p) {
   this.origin = p;
 }
 
 public abstract boolean isClicked(Point p);
 
 // Calcul de la distance entre 2 points
 protected double distance(Point A, Point B) {
    PVector AB = new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
    return(AB.mag());
 }
 
 protected abstract double perimetre();
 protected abstract double aire();
}
/*
 * Classe Rectangle
 */ 
 
public class Rectangle extends Forme {
  
  int longueur;
  
  public Rectangle(Point p) {
    super(p);
    this.longueur=60;
  }
   
  public void update() {
    fill(this.c);
    square((int) this.origin.getX(),(int) this.origin.getY(),this.longueur);
  }  
  
  public boolean isClicked(Point p) {
    int x= (int) p.getX();
    int y= (int) p.getY();
    int x0 = (int) this.origin.getX();
    int y0 = (int) this.origin.getY();
    
    // vérifier que le rectangle est cliqué
    if ((x>x0) && (x<x0+this.longueur) && (y>y0) && (y<y0+this.longueur))
      return(true);
    else  
      return(false);
  }
  
  // Calcul du périmètre du carré
  protected double perimetre() {
    return(this.longueur*4);
  }
  
  protected double aire(){
    return(this.longueur*this.longueur);
  }
}
/*
 * Classe Triangle
 */ 
 
public class Triangle extends Forme {
  Point A, B,C;
  public Triangle(Point p) {
    super(p);
    // placement des points
    A = new Point();    
    A.setLocation(p);
    B = new Point();    
    B.setLocation(A);
    C = new Point();    
    C.setLocation(A);
    B.translate(40,60);
    C.translate(-40,60);
  }
  
    public void setLocation(Point p) {
      super.setLocation(p);
      // redéfinition de l'emplacement des points
      A.setLocation(p);   
      B.setLocation(A);  
      C.setLocation(A);
      B.translate(40,60);
      C.translate(-40,60);   
  }
  
  public void update() {
    fill(this.c);
    triangle((float) A.getX(), (float) A.getY(), (float) B.getX(), (float) B.getY(), (float) C.getX(), (float) C.getY());
  }  
  
  public boolean isClicked(Point M) {
    // vérifier que le triangle est cliqué
    
    PVector AB= new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
    PVector AC= new PVector( (int) (C.getX() - A.getX()),(int) (C.getY() - A.getY())); 
    PVector AM= new PVector( (int) (M.getX() - A.getX()),(int) (M.getY() - A.getY())); 
    
    PVector BA= new PVector( (int) (A.getX() - B.getX()),(int) (A.getY() - B.getY())); 
    PVector BC= new PVector( (int) (C.getX() - B.getX()),(int) (C.getY() - B.getY())); 
    PVector BM= new PVector( (int) (M.getX() - B.getX()),(int) (M.getY() - B.getY())); 
    
    PVector CA= new PVector( (int) (A.getX() - C.getX()),(int) (A.getY() - C.getY())); 
    PVector CB= new PVector( (int) (B.getX() - C.getX()),(int) (B.getY() - C.getY())); 
    PVector CM= new PVector( (int) (M.getX() - C.getX()),(int) (M.getY() - C.getY())); 
    
    if ( ((AB.cross(AM)).dot(AM.cross(AC)) >=0) && ((BA.cross(BM)).dot(BM.cross(BC)) >=0) && ((CA.cross(CM)).dot(CM.cross(CB)) >=0) ) { 
      return(true);
    }
    else
      return(false);
  }
  
  protected double perimetre() {
    //
    PVector AB= new PVector( (int) (B.getX() - A.getX()),(int) (B.getY() - A.getY())); 
    PVector AC= new PVector( (int) (C.getX() - A.getX()),(int) (C.getY() - A.getY())); 
    PVector BC= new PVector( (int) (C.getX() - B.getX()),(int) (C.getY() - B.getY())); 
    
    return( AB.mag()+AC.mag()+BC.mag()); 
  }
   
  // Calcul de l'aire du triangle par la méthode de Héron 
  protected double aire(){
    double s = perimetre()/2;
    double aire = s*(s-distance(B,C))*(s-distance(A,C))*(s-distance(A,B));
    return(sqrt((float) aire));
  }
}
  public void settings() { 
size(800,600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Moteur_de_fusion" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
