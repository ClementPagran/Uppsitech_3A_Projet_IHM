/*
 * Enumération de a Machine à Etats (Finite State Machine)
 *
 *
 */
 
public enum FSM {
  INITIAL, /* Etat Initial */
  ATTENTE_ACTION,
  CREER,
  DEPLACER,
  CREATION_FORME,
  SELECTION_FORME, 
  DEPLACER_FORMES_SELECTION,
  DEPLACER_FORMES_DESTINATION,
  MODIF_COULEUR
}
