package com.example.deakig.new_application;

/**
 * Created by greg on 24/12/15.
 */
public class CharacterBase {

    private Integer charisma;
    private Integer intelligence;
    private Integer wisdom;
    private Integer reactions;
    private Integer will;
    private Integer constitution;
    private Integer dexterity;

    /*public void CharacterBase(){
        initCharacterBase();
    }

    private void initCharacterBase() {
    }*/

    public void setCharisma(Integer i) {
        charisma = i;

    }

    public void setIntelligence(Integer i) {
        intelligence = i;
    }

    public void setWisdom(Integer i) {
        wisdom = i;
    }

    public void setReactions(Integer i) {
        reactions = i;
    }

    public void setWill(Integer i) {
        will = i;
    }

    public void setConstitution(Integer i) {
        constitution = i;
    }

    public void setDexterity(Integer i) {
        dexterity = i;
    }

    public Integer getCharisma() {
       return(charisma);
    }

    public Integer getIntelligence() {
        return(intelligence);
    }

    public Integer getWisdom() {
        return(wisdom);
    }

    public Integer getReactions() {
        return(reactions);
    }

    public Integer getWill() {
        return(will);
    }

    public Integer getConstitution() {
        return(constitution);
    }

    public Integer getDexterity() {
        return(dexterity);
    }

}
